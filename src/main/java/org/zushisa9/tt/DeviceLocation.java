package org.zushisa9.tt;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import io.quarkus.hibernate.reactive.panache.PanacheEntityBase;

@Entity
@Table(name = "device_locations")
public class DeviceLocation extends PanacheEntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "device_locations_id_seq")
    public int id;

    @Column(name = "loc_ident")
    public String locIdent;

    public String description;

    @OneToOne
    @JoinColumn(name = "iot_device_id", referencedColumnName = "id")
    public IotDevice iotDevice;

    @Column(name = "created_at")
    public Date createdAt;

    @Column(name = "updated_at")
    public Date updatedAt;
}
