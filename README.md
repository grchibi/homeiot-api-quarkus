# homeiot-api-quarkus

## Build prerequisites

Before building, install the following software.
- docker
- docker-compose
- OpenJDK 11
- Maven

After installing the software, execute the following command.
```
$ mvn wrapper:wrapper
```

## Prepare the environment config file

```
$ vi .env
```

- DB_USER=[database user name to access]
- DB_PWD=[database user's password to access]
- DB_INSIDE_PORT=[database port number to access from the api server]
- DB_OUTSIDE_PORT=[database port number to access from the outside of the container]
- API_PORT=[API server's port number to access]

## Build

```
$ ./mvnw package
```

## Run the servers

To run the API server, execute this command.
```
$ docker compose up -d
```
Then, to stop the API server, execute the following command.
```
$ docker compose down
```

To test the connection from a client, try the following URL via your browser.
```
http://<Server's IP address or the FQDN>:<API_PORT>/q/swagger-ui
```

With Swagger UI, you can try out the API tph_register. For example, post the following JSON string.
```
{"tph_register":{"dsrc":"BME280_BEACON_2", "dt":"202301031300", "t":12.17, "p":1014.45, "h":44.86}}
```

## Register to Systemd

```
$ cp -a  homeiot-api-quarkus.service /etc/systemd/system/
$ systemctl enable homeiot-api-quarkus
```

## Check the logs
```
$ docker logs homeiotapi
```
You can view the journal logs, too.
```
$ journalctl -u homeiot-api-quarkus.service --no-pager --since="2023-01-27 18:00:00"
```
