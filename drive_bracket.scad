// bracket to attach the drive wheel to the rest of the rig
$fn = 100;
FUDGE = 0.01;
thickness = 6;
width = 50;
arm = 76;
mountHoleOuter = 39.4;
dia = 3.6;
inFromArm = 14.5;

// Let's call it a hole with print relief
module holePR(d, l) {
    union() {
        cylinder(h=l, d=d, center=true);
        translate([0,0,-l/2])
            cube([d/2,d/2,l], center=false);
    }
}

difference(){
    // The bracket
    union() {
        cube([arm,50,thickness], center=false);
        translate([arm-thickness,0,thickness-FUDGE])
            cube([thickness,50,50], center=false);
        translate([0,0,thickness-FUDGE])
            cube([thickness,50,50], center=false);
    }
    // Holes for screws
    translate([thickness/2,(width-mountHoleOuter)/2+dia/2,
                (width-inFromArm)+thickness+dia/2])
        rotate([90,-45,90])
            holePR(d=dia+1.4, l=thickness+FUDGE);
    translate([thickness/2,
                (width-(width-mountHoleOuter)/2)-dia/2,
                (width-inFromArm)+thickness+dia/2])
        rotate([90,-45,90])
            holePR(d=dia+1.4, l=thickness+FUDGE);
    translate([arm-thickness/2,(width-mountHoleOuter)/2+dia/2,
                (width-inFromArm)+thickness+dia/2])
        rotate([90,-45,90])
            holePR(d=dia, l=thickness+FUDGE);
    translate([arm-thickness/2,
                (width-(width-mountHoleOuter)/2)-dia/2,
                (width-inFromArm)+thickness+dia/2])
        rotate([90,-45,90])
            holePR(d=dia, l=thickness+FUDGE);
}
