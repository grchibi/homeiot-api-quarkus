package org.zushisa9.tt;

public class Tph {
    
    public String dsrc;     // ex. "rbpi0-4"
    public String dt;       // ex. "202012022300"
    public double t, p, h;  // ex. 16.58, 1021.07, 54.28

    /**
     * Default Constructor
     */
    public Tph() {}

    public Tph(String dsrc, String dt, double t, double p, double h) {
        this.dsrc = dsrc;
        this.dt = dt;
        this.t = t;
        this.p = p;
        this.h = h;
    }

    public String toString() {
        return String.format("{\"dsrc\": \"%s\", \"dt\": \"%s\", \"t\": %.2f, \"p\": %.2f, \"h\": %.2f}", this.dsrc, this.dt, this.t, this.p, this.h);
    }

}
