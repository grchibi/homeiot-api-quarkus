--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Raspbian 11.12-0+deb10u1)
-- Dumped by pg_dump version 11.12 (Raspbian 11.12-0+deb10u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: create_hl_hist(); Type: FUNCTION; Schema: public; Owner: iot
--

CREATE FUNCTION public.create_hl_hist() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  dt_finish DATE;
  dt_start DATE;
  rc_dev RECORD;
  rc_tmp RECORD;
  refcur_recs REFCURSOR;
  ts_now TIMESTAMP;

BEGIN
  SELECT INTO ts_now NOW();
  RAISE INFO 'START function create_hl_hist() => %', ts_now;

  FOR rc_dev IN SELECT id FROM iot_devices LOOP
    RAISE INFO '[create_hl_hist] start id => %', rc_dev.id;

    -- Start date

    SELECT MAX(dt AT TIME ZONE 'UTC' AT TIME ZONE 'JST') INTO dt_start FROM tph_hl_records WHERE iot_device_id = rc_dev.id;
    IF dt_start IS NULL THEN  -- no historical data
      SELECT MIN(CAST(dt AT TIME ZONE 'UTC' AT TIME ZONE 'JST' AS DATE)) INTO dt_start FROM tph_records WHERE iot_device_id = rc_dev.id;
      IF dt_start IS NULL THEN
        RAISE INFO '[create_hl_hist]   data not found => %', rc_dev.id;
        CONTINUE;
      END IF;

    ELSE
      SELECT dt_start + INTERVAL '1 day' INTO dt_start;

    END IF;

    RAISE INFO '[create_hl_hist]   start date => %', dt_start;

    -- Finish date

    SELECT MAX(CAST(dt AT TIME ZONE 'UTC' AT TIME ZONE 'JST' AS DATE)) INTO dt_finish FROM tph_records WHERE iot_device_id = rc_dev.id;
    IF dt_finish IS NULL THEN
      SELECT INTO dt_finish CAST(NOW() AS DATE);
    END IF;

    SELECT dt_finish - INTERVAL '1 day' INTO dt_finish;

    RAISE INFO '[create_hl_hist]   finish date => %', dt_finish;

    -- Calculation

    OPEN refcur_recs FOR EXECUTE 'SELECT CAST(dt AT TIME ZONE ''UTC'' AT TIME ZONE ''JST'' AS DATE) AS dt, MIN(h) AS min_h, MAX(h) AS max_h, MIN(p) AS min_p, MAX(p) AS max_p, MIN(t) AS min_t, MAX(t) AS max_t FROM tph_records WHERE iot_device_id = ' || rc_dev.id || ' AND ' || dt_start || ' <= CAST(dt AT TIME ZONE ''UTC'' AT TIME ZONE ''JST'' AS DATE) AND CAST(dt AT TIME ZONE ''UTC'' AT TIME ZONE ''JST'' AS DATE) <= ' || dt_finish || ' GROUP BY CAST(dt AT TIME ZONE ''UTC'' AT TIME ZONE ''JST'' AS DATE)';

    FETCH NEXT FROM refcur_recs INTO rc_tmp;
    WHILE FOUND LOOP

      RAISE INFO '[create_hl_hist]     %:  t(%, %)  p(%, %)  h(%, %)', rc_tmp.dt, rc_tmp.min_t, rc_tmp.max_t, rc_tmp.min_p, rc_tmp.max_p, rc_tmp.min_h, rc_tmp.max_h;

      FETCH NEXT FROM refcur_recs INTO rc_tmp;
    END LOOP;	-- WHILE LOOP

  END LOOP;	-- FOR LOOP

  RETURN;

END;
$$;


ALTER FUNCTION public.create_hl_hist() OWNER TO iot;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: device_locations; Type: TABLE; Schema: public; Owner: iot
--

CREATE TABLE public.device_locations (
    id integer NOT NULL,
    loc_ident character varying NOT NULL,
    description character varying,
    iot_device_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.device_locations OWNER TO iot;

--
-- Name: device_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: iot
--

CREATE SEQUENCE public.device_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.device_locations_id_seq OWNER TO iot;

--
-- Name: device_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iot
--

ALTER SEQUENCE public.device_locations_id_seq OWNED BY public.device_locations.id;


--
-- Name: iot_devices; Type: TABLE; Schema: public; Owner: iot
--

CREATE TABLE public.iot_devices (
    id integer NOT NULL,
    uname character varying NOT NULL,
    model character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.iot_devices OWNER TO iot;

--
-- Name: iot_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: iot
--

CREATE SEQUENCE public.iot_devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.iot_devices_id_seq OWNER TO iot;

--
-- Name: iot_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iot
--

ALTER SEQUENCE public.iot_devices_id_seq OWNED BY public.iot_devices.id;


--
-- Name: ip_restrictions; Type: TABLE; Schema: public; Owner: iot
--

CREATE TABLE public.ip_restrictions (
    id integer NOT NULL,
    list_type character varying NOT NULL,
    ip character varying NOT NULL,
    "desc" character varying,
    enabled boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ip_restrictions OWNER TO iot;

--
-- Name: ip_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: iot
--

CREATE SEQUENCE public.ip_restrictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ip_restrictions_id_seq OWNER TO iot;

--
-- Name: ip_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iot
--

ALTER SEQUENCE public.ip_restrictions_id_seq OWNED BY public.ip_restrictions.id;


--
-- Name: tph_hl_records; Type: TABLE; Schema: public; Owner: iot
--

CREATE TABLE public.tph_hl_records (
    id integer NOT NULL,
    dt date NOT NULL,
    t double precision,
    p double precision,
    h double precision,
    is_h boolean,
    iot_device_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.tph_hl_records OWNER TO iot;

--
-- Name: tph_hl_records_id_seq; Type: SEQUENCE; Schema: public; Owner: iot
--

CREATE SEQUENCE public.tph_hl_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tph_hl_records_id_seq OWNER TO iot;

--
-- Name: tph_hl_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iot
--

ALTER SEQUENCE public.tph_hl_records_id_seq OWNED BY public.tph_hl_records.id;


--
-- Name: tph_records; Type: TABLE; Schema: public; Owner: iot
--

CREATE TABLE public.tph_records (
    id integer NOT NULL,
    dt timestamp without time zone NOT NULL,
    t double precision,
    p double precision,
    h double precision,
    iot_device_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    loc character varying
);


ALTER TABLE public.tph_records OWNER TO iot;

--
-- Name: tph_records_id_seq; Type: SEQUENCE; Schema: public; Owner: iot
--

CREATE SEQUENCE public.tph_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tph_records_id_seq OWNER TO iot;

--
-- Name: tph_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iot
--

ALTER SEQUENCE public.tph_records_id_seq OWNED BY public.tph_records.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: iot
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO iot;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: iot
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO iot;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iot
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: device_locations id; Type: DEFAULT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.device_locations ALTER COLUMN id SET DEFAULT nextval('public.device_locations_id_seq'::regclass);


--
-- Name: iot_devices id; Type: DEFAULT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.iot_devices ALTER COLUMN id SET DEFAULT nextval('public.iot_devices_id_seq'::regclass);


--
-- Name: ip_restrictions id; Type: DEFAULT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.ip_restrictions ALTER COLUMN id SET DEFAULT nextval('public.ip_restrictions_id_seq'::regclass);


--
-- Name: tph_hl_records id; Type: DEFAULT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.tph_hl_records ALTER COLUMN id SET DEFAULT nextval('public.tph_hl_records_id_seq'::regclass);


--
-- Name: tph_records id; Type: DEFAULT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.tph_records ALTER COLUMN id SET DEFAULT nextval('public.tph_records_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: device_locations; Type: TABLE DATA; Schema: public; Owner: iot
--

COPY public.device_locations (id, loc_ident, description, iot_device_id, created_at, updated_at) FROM stdin;
2	WCL	Walk-in Closet	1	2019-12-15 07:33:58.856944	2019-12-15 07:33:58.856944
3	ECL	Entrance Closet	2	2019-12-15 07:33:58.857787	2019-12-15 07:33:58.857787
1	FR	Free Room	4	2019-12-15 07:33:58.855618	2019-12-15 07:33:58.855618
4	LIV	Living Room	3	2020-11-15 19:41:22.895825	2020-11-15 19:41:22.895825
\.


--
-- Data for Name: iot_devices; Type: TABLE DATA; Schema: public; Owner: iot
--

COPY public.iot_devices (id, uname, model, description, created_at, updated_at) FROM stdin;
1	rbpi0-1	RaspberryPi Zero WH	1st pi zero	2019-07-20 11:46:44.823823	2019-07-20 11:46:44.823823
2	rbpi0-2	RaspberryPi Zero WH	2nd pi zero	2019-07-28 13:22:10.132316	2019-07-28 13:22:10.132316
3	rbpi0-4	RaspberryPi Zero WH	4th pi zero	2019-10-22 15:54:33.62863	2019-10-22 15:54:33.62863
4	BME280_BEACON_2	ESP32	1st ESP32	2020-11-15 19:33:11.971491	2020-11-15 19:33:11.971491
\.


--
-- Data for Name: ip_restrictions; Type: TABLE DATA; Schema: public; Owner: iot
--

COPY public.ip_restrictions (id, list_type, ip, "desc", enabled, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tph_hl_records; Type: TABLE DATA; Schema: public; Owner: iot
--

COPY public.tph_hl_records (id, dt, t, p, h, is_h, iot_device_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tph_records; Type: TABLE DATA; Schema: public; Owner: iot
--

COPY public.tph_records (id, dt, t, p, h, iot_device_id, created_at, updated_at, loc) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: iot
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at) FROM stdin;
\.


--
-- Name: device_locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: iot
--

SELECT pg_catalog.setval('public.device_locations_id_seq', 3, true);


--
-- Name: iot_devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: iot
--

SELECT pg_catalog.setval('public.iot_devices_id_seq', 1, true);


--
-- Name: ip_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: iot
--

SELECT pg_catalog.setval('public.ip_restrictions_id_seq', 1, false);


--
-- Name: tph_hl_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: iot
--

SELECT pg_catalog.setval('public.tph_hl_records_id_seq', 1, false);


--
-- Name: tph_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: iot
--

SELECT pg_catalog.setval('public.tph_records_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: iot
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: device_locations device_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.device_locations
    ADD CONSTRAINT device_locations_pkey PRIMARY KEY (id);


--
-- Name: iot_devices iot_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.iot_devices
    ADD CONSTRAINT iot_devices_pkey PRIMARY KEY (id);


--
-- Name: ip_restrictions ip_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.ip_restrictions
    ADD CONSTRAINT ip_restrictions_pkey PRIMARY KEY (id);


--
-- Name: tph_hl_records tph_hl_records_pkey; Type: CONSTRAINT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.tph_hl_records
    ADD CONSTRAINT tph_hl_records_pkey PRIMARY KEY (id);


--
-- Name: tph_records tph_records_pkey; Type: CONSTRAINT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.tph_records
    ADD CONSTRAINT tph_records_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: iot
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_device_locations_on_iot_device_id; Type: INDEX; Schema: public; Owner: iot
--

CREATE INDEX index_device_locations_on_iot_device_id ON public.device_locations USING btree (iot_device_id);


--
-- Name: index_device_locations_on_loc_ident; Type: INDEX; Schema: public; Owner: iot
--

CREATE UNIQUE INDEX index_device_locations_on_loc_ident ON public.device_locations USING btree (loc_ident);


--
-- Name: index_iot_devices_on_uname; Type: INDEX; Schema: public; Owner: iot
--

CREATE UNIQUE INDEX index_iot_devices_on_uname ON public.iot_devices USING btree (uname);


--
-- Name: index_tph_records_on_iot_device_id_and_dt; Type: INDEX; Schema: public; Owner: iot
--

CREATE UNIQUE INDEX index_tph_records_on_iot_device_id_and_dt ON public.tph_records USING btree (iot_device_id, dt);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: iot
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: iot
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- PostgreSQL database dump complete
--

