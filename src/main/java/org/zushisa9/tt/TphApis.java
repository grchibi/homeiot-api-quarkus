package org.zushisa9.tt;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Set;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.Response;

import org.jboss.logging.Logger;

import io.quarkus.hibernate.reactive.panache.Panache;
import io.smallrye.mutiny.Uni;


@Path("/tph_register")
public class TphApis {
    
    private final static Logger LOG = Logger.getLogger(TphApis.class);

    //private Set<Tph> tphs = Collections.newSetFromMap(Collections.synchronizedMap(new LinkedHashMap<>()));
    
    /*@GET
    public Set<Tph> list() {
        return tphs;
    }*/

    /**
     * @param tph
     * @return
     */
    @POST
    public Uni<Response> add(TphEnvelope tphEnvelope) {
        Tph tph = tphEnvelope.tph_register;
        LOG.info("RECEIVED MSG => " + tph.toString());

        Uni<IotDevice> iotdev = IotDevice.findByUname(tph.dsrc);

        return iotdev.onItem()
            .ifNull().failWith(new IllegalArgumentException("TPH's dsrc(" + tph.dsrc + ") may be invalid."))
            .onItem()
            .transform(item -> {
                LOG.infof("FOUND DEVICE => id:%d, loc:%s", item.id, item.deviceLocation.locIdent);

                TphRecord newRecord = new TphRecord();

                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("+yyyyMMddHHmm");
                    newRecord.dt = sdf.parse(tph.dt);
                    newRecord.t = tph.t;
                    newRecord.p = tph.p;
                    newRecord.h = tph.h;
                    newRecord.iotDeviceId = item.id;
                    newRecord.loc = item.deviceLocation.locIdent;
                    newRecord.createdAt = newRecord.updatedAt = new Date();

                } catch (ParseException pex) {
                    LOG.error(pex.fillInStackTrace());
                    throw new java.lang.IllegalArgumentException(pex);
                }
                    
                return newRecord;
            })
            .call(item -> Panache.withTransaction(item::persist) )
            .map(item -> Response.ok(new MyHttpResponse("SUCCESS")).build())
            .onFailure()
            .invoke(failure -> {LOG.warn(failure.fillInStackTrace()); })
            .onFailure()
            .recoverWithItem(Response.status(500).entity(new MyHttpResponse("FAILED")).build());
            /*.onFailure().recoverWithNull()
            .subscribe().with(item -> {
                    LOG.infof("TPH object persisted. => id:%d, loc:%s", item.id, item.loc);
                },
                failure -> {
                    LOG.warn(failure.fillInStackTrace());
                }
            );

        return Response.ok(new MyHttpResponse("SUCCESS")).build();*/
    }

    public class MyHttpResponse {
        public String status;

        public MyHttpResponse(String status) { this.status = status; }
    }
}
