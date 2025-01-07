// Side enclosure for motion sensor and SD card reader
//34567891123456789212345678931234567894123456789512345678961234567897123456789

// Global settings
$fn = 100;
FUDGE = 0.01; // To ensure non-perfect difference edges

// Specs, measured
width = 20.0;
boardLength = 32.0;
boardHeight = 11.0; // bottom of diffuser dome to top of caps/jumper

// Options
tol = .1; // room to make sure things fit
// Box options
botRoom = 1.0; // bottom air gap
wallThickness = 3.0;
cornerR = 4.0; // radius for rounding box corners
hasFeet = true;
footD = 11.0;
footHD = 4.5; // Foot hole diameter
footRelief = 0.0;

module RoundedBox(l, w, h, t, r) {
    // Rounded box with open top
    difference() {
        hull() {
            cylinder(h=h, r=r, center=false);
            translate([0,w,0])
                cylinder(h=h, r=r, center=false);
            translate([l,w,0])
                cylinder(h=h, r=r, center=false);
            translate([l,0,0])
                cylinder(h=h, r=r, center=false);
        }
        hull() {
            translate([0,0,t])
                cylinder(h=h, r=r-t, center=false);
            translate([0,w,t])
                cylinder(h=h, r=r-t, center=false);
            translate([l,w,t])
                cylinder(h=h, r=r-t, center=false);
            translate([l,0,t])
                cylinder(h=h, r=r-t, center=false);
        }
    }
}

module AttachFoot(d, hd, h=wallThickness) {
    difference() {
        translate([0,-h/2,h/2])
            cube([d,d*1.3,h], center=true);
        translate([0,0,-FUDGE/2])
            cylinder(h=h+FUDGE, d=hd);
    }
}

          
boxHeight = boardHeight+2*wallThickness+width+tol;
boxWidth = width+tol; // to cylinder centers (-2*r)
boxLength = boardLength+tol;

union() {
    difference() {
        RoundedBox(l=boxLength, w=boxWidth, h=boxHeight,
                t=wallThickness, r=cornerR);
        translate([boxLength/2,-cornerR/2,boxHeight+cornerR])
            cube([boxLength*2,boxWidth*2,boxHeight*2], center=true);
    }
    // screw hole feet
    translate([-(footD/2+cornerR),
            -cornerR+wallThickness,
            footD/2])
        rotate([0,-90,90])
            AttachFoot(d=footD, hd=footHD);
    translate([boxLength+(footD/2+cornerR),
            -cornerR+wallThickness,
            footD/2])
        rotate([0,90,-90])
            AttachFoot(d=footD, hd=footHD);
}
