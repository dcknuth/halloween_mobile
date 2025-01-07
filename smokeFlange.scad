// 9v battery battery box
//34567891123456789212345678931234567894123456789512345678961234567897123456789
$fn = 100;

insideD = 34.0;
wallSize = 2.0;
outsideD = insideD + 2*wallSize;
flangeD = outsideD + 10*wallSize;

module PvcCoupler(h=26, d=34.0, fd=45.0, ws=2) {
    union() {
        difference() {
            cylinder(h=h, d=d+2*ws, center=false);
            translate([0,0,-0.001/2])
                cylinder(h=h+0.001, d=d, center=false);
        }
        difference() {
            cylinder(h=ws, d=fd, center=false);
            translate([0,0,-0.001/2])
                cylinder(h=ws+0.001, d=d+2*ws-0.001, center=false);
        }
    }
}

PvcCoupler(d=insideD, ws=2, fd=flangeD);
