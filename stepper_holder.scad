$fn=100;
FUDGE = 0.001;

OutsideD = 42; // will go out to the edges of the 28byj-48 stepper
  // motor screw holes
OutsideH = 22;
StepperD = 31.5;
StepperDI = 28.5;
WireH = 3.8;
WireHole = 5;
StepperH = 20;
earD = 15;
earH = 2;
earHole = 4.5;

// Cut out for the wired side (bottom) of the stepper motor
// Need xtra room -x to cover the cylindar and +x for the wire channel
module WireRelief(h=4, od=4, id=3, wireH=1, xtra=7) {
rotate([90,0,90])
    linear_extrude(height=h, center=true, convexity=5) {
        polygon(points=[[-xtra,0],
            [0,0],
            [od-id,od-id],
            [od-id,h-wireH],
            [(od-id)+wireH,h-wireH],
            [(od-id)+wireH,h],
            [0,h],
            [-xtra,h],
            [-xtra,0]]);
    }
}


union() {
    difference(){
        cylinder(h=OutsideH, d=OutsideD, center=true);
        translate([0,0,(OutsideH - StepperH)/2 + FUDGE])
            cylinder(h=StepperH, d=StepperDI, center=true);
        translate([0,StepperDI/2,
            -(StepperH/2-(OutsideH - StepperH)/2 - FUDGE)])
            WireRelief(h=StepperH, od=StepperD, id=StepperDI, wireH=WireH);
    }
    // Will need an attachment surface someplace
    // How about two ears on the bottom with holes for screws
    translate([OutsideD/2.8,OutsideD/2.8,-(OutsideH/2-earH/2)])
        rotate([0,0,45])
            difference(){
                cylinder(h=earH, d=earD, center=true);
                translate([earD/4,0,0])
                    cylinder(h=earH+FUDGE, d=earHole, center=true);
            }
    translate([-OutsideD/2.8,OutsideD/2.8,-(OutsideH/2-earH/2)])
        rotate([0,0,135])
            difference(){
                cylinder(h=earH, d=earD, center=true);
                translate([earD/4,0,0])
                    cylinder(h=earH+FUDGE, d=earHole, center=true);
            }
}
