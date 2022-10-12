package org.zushisa9.tt;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import io.quarkus.hibernate.reactive.panache.PanacheEntityBase;
import io.smallrye.mutiny.Uni;

@Entity
@Table(name = "iot_devices")
public class IotDevice extends PanacheEntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "iot_devices_id_seq")
    public int id;

    public String uname;
    public String model;
    public String description;

    @Column(name = "created_at")
    public Date createdAt;

    @Column(name = "updated_at")
    public Date updatedAt;

    @OneToOne(mappedBy = "iotDevice")
    public DeviceLocation deviceLocation;
    
    public static Uni<IotDevice> findByUname(String dsrc) {
        return find("uname", dsrc).firstResult();
    }
}