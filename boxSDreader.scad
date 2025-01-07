// 9v battery battery box
//34567891123456789212345678931234567894123456789512345678961234567897123456789
$fn = 100;

module BoxSDreader(l=24, w=8.0, h=39, ws=2.0, r=4.0, t=0.2,
        taperR=false, taperL=true) {
    // Rounded box with open top, sized for the average 9v battery
    // t is tolerance; extra room for the battery to slide in
    // taperR and taperL will give a 45 degree ramp to print without overhangs
    //  if needed after rotation
    union() {
        difference() {
            hull() {
                cylinder(h=h, r=r, center=false);
                translate([0,w-2*(r-ws),0])
                    cylinder(h=h, r=r, center=false);
                translate([l-2*(r-ws),w-2*(r-ws),0])
                    cylinder(h=h, r=r, center=false);
                translate([l-2*(r-ws),0,0])
                    cylinder(h=h, r=r, center=false);
            }
            hull() {
                translate([-t,-t,ws-t])
                    cylinder(h=h*2, r=r-ws, center=false);
                translate([-t,(w-2*(r-ws))+t,ws-t])
                    cylinder(h=h*2, r=r-ws, center=false);
                translate([(l-2*(r-ws))+t,(w-2*(r-ws))+t,ws-t])
                    cylinder(h=h*2, r=r-ws, center=false);
                translate([(l-2*(r-ws))+t,-t,ws-t])
                    cylinder(h=h*2, r=r-ws, center=false);
            }
        }
        if(taperR) {
            linear_extrude(height=h, center=false, convexity=5, twist=0) {
                polygon( points=[
                    [l-2*(r-ws)+sqrt(r*r/2),(w-2*(r-ws))+sqrt(r*r/2)],
                    [l-2*(r-ws)+((w-2*(r-ws))+3*sqrt(r*r/2)),-sqrt(r*r/2)],
                    [l-2*(r-ws)+sqrt(r*r/2),-sqrt(r*r/2)],
                    [l-2*(r-ws)+sqrt(r*r/2),(w-2*(r-ws))+sqrt(r*r/2)]]);
            }
        }
        if(taperL) {
            linear_extrude(height=h, center=false, convexity=5, twist=0) {
                polygon( points=[[-sqrt(r*r/2),(w-2*(r-ws))+sqrt(r*r/2)],
                    [-((w-2*(r-ws))+3*sqrt(r*r/2)),-sqrt(r*r/2)],
                    [-sqrt(r*r/2),-sqrt(r*r/2)],
                    [-sqrt(r*r/2),(w-2*(r-ws))+sqrt(r*r/2)]]);
            }
        }
    }
}

BoxSDreader();
