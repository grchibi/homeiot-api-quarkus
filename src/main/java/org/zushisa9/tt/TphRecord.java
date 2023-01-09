package org.zushisa9.tt;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import io.quarkus.hibernate.reactive.panache.PanacheEntityBase;

@Entity
@Table(name = "tph_records")
public class TphRecord extends PanacheEntityBase {
    
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "tph_records_id_seq")
    @SequenceGenerator(name = "tph_records_id_seq", sequenceName = "tph_records_id_seq", allocationSize = 1)
    public int id;

    public Date dt;
    public double t, p, h;  // ex. 16.58, 1021.07, 54.28

    @Column(name = "iot_device_id")
    public int iotDeviceId;

    public String loc;

    @Column(name = "created_at")
    public Date createdAt;

    @Column(name = "updated_at")
    public Date updatedAt;
    
}
