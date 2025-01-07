// Arduino Mega2560 compatible enclosure
//34567891123456789212345678931234567894123456789512345678961234567897123456789
// includes
use <threads_v2p1.scad>;
use <pins.scad>;
use <box9v.scad>;
use <boxSDreader.scad>;

// Global settings
$fn = 100;
FUDGE = 0.01; // To ensure non-perfect difference edges
printCover = false;

// Specs from arduino.cc which matched the measured size well
boardWidth = 53.3;
boardLength = 101.52;
// Measured specs
boardHeight = 15.5; // lowest reverse-side wire to front of power jack
boardKeyLength = 99.0; // the little cut-out on the end
boardKeyWidthMax = 15.5;
boardKeyWidthMin = 13.0;
usbWidth = 12.1;
usbHeight = 11.0+3.0; // We need some z space for shinkage and insert
usbStart = 32.5;
powerWidth = 10.1;
powerHeight = 11.05+3.0; // We need some z space for shinkage and insert
powerStart = 3.9;
mountHoleDia = 3.4;
maxSolderH = 2.3;
pcbThickness = 1.8;

// Options
tol = .4; // room to make sure things fit
// Box options
extraLength = 6; // needed to get the board in and out
botRoom = 1.0; // bottom air gap
topRoom = 20.0; // room for jumpers to connect to board pins
wallThickness = 3.0;
cornerR = 4.0; // radius for rounding box corners
hasWireChannelsY = true;
hasWireChannelsX = true;
wireChannelD = 8;
hasVents = true;
numVents = 8;
ventWidth = 3; // up to you to make sure this is not too many
usePins = true;
pinH = 3;
pinR = 2.9/2;  // Slightly less than the hole diameter
pinLipH = 1;
pinLipT = 0.3;
hasFeet = true;
footD = 11.0;
footHD = 4.7; // Foot hole diameter
footRelief = 8.0; // Distance from long side
lidHeight = wallThickness;
box9vWall = 2.0;
box9vOffSet = 75;
box9vZOff = 10;
hasSDholder = true;
sDyOffset = cornerR;
sDzOffset = 12.5;
sDwidth = 6.2;
// Mount options
mountDia = 5.5;
mountHeight = botRoom+maxSolderH;
screwDia = 2.9;
threadPitch = .448;
mountPositions = [
    [11.0,0.3],
    [94.4,0.3],
    [12.3,48.9],
    [87.8,48.7]];

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
        hull() {
            cylinder(h=h, d=d, center=false);
            translate([0,-d,0])
                cylinder(h=h, d=d, center=false);
        }
        translate([0,0,-FUDGE/2])
            cylinder(h=h+FUDGE, d=hd);
    }
}

module MountPoint(d, h, ss, p) {
    // ss = screw outside diameter. If non-zero, put threads in the top
    // p = thread pitch
    if(usePins) {
        union() {
            cylinder(h=h, d=d);
            translate([0,0,h-FUDGE/2])
                pin(h=pinH, r=pinR, lh=pinLipH, lt=pinLipT, side=false);
        }
    } else {
        difference() {
            cylinder(h=h, d=d);
            translate([0,0,FUDGE])
                ScrewHole(ss, h, pitch=p);
        }
    }
}

module LidMount(h, ss, p) {
    // h=depth of thread, ss=screw outside dia, p= thread pitch
    difference() {
        translate([-ss,0,-(ss*2+h)]) // to center x with top on z=0
            rotate([90,0,90])
                linear_extrude(height=ss*2, twist = 0)
                    polygon([
                        [0,0],
                        [ss*2,ss*2],
                        [ss*2,ss*2+h],
                        [0,ss*2+h],
                        [0,0]]);
        translate([0,ss,(-h)+FUDGE])
            ScrewHole(ss, h, pitch=p);
    }
}

module Tab(width) {
    rotate([90,0,90])
        linear_extrude(height=width, twist = 0)
            polygon([
                [0,0],
                [width/2,0],
                [width/2,width/2],
                [width/2+width/8,width],
                [width/2,width+width/2],
                [width/2,width+width/2+width/4],
                [0,width+width/2+width/4],
                [0,0]]);
}

module Lid(l, w, h, r, hd=0, t=0) {
    union() {
        difference() {
            hull() {  // slight overhang to help get cover off
                cylinder(h=h, r1=r, r2=r*1.3, center=false);
                translate([0,w,0])
                    cylinder(h=h, r1=r, r2=r*1.3, center=false);
                translate([l,w,0])
                    cylinder(h=h, r1=r, r2=r*1.3, center=false);
                translate([l,0,0])
                    cylinder(h=h, r1=r, r2=r*1.3, center=false);
            }
            if(hd != 0) {
                translate([mountPositions[0][0],hd/2, -FUDGE/2])
                    cylinder(h=h+FUDGE, d=hd, center=false);
                translate([mountPositions[1][0],hd/2, -FUDGE/2])
                    cylinder(h=h+FUDGE, d=hd, center=false);
                translate([mountPositions[2][0],boxWidth-hd/2, -FUDGE/2])
                    cylinder(h=h+FUDGE, d=hd, center=false);
                translate([mountPositions[3][0],boxWidth-hd/2, -FUDGE/2])
                    cylinder(h=h+FUDGE, d=hd, center=false);
            } 
        }
        if (t != 0) {
            translate([mountPositions[0][0]+t/2,t/2-(cornerR-wallThickness),
                    h-FUDGE/2])
                rotate([0,0,180])
                    Tab(t);
            translate([mountPositions[1][0]+t/2,t/2-(cornerR-wallThickness),
                    h-FUDGE/2])
                rotate([0,0,180])
                    Tab(t);
            translate([mountPositions[2][0]-t/2,
                    (boxWidth-t/2)+(cornerR-wallThickness), h-FUDGE/2])
                Tab(t);
            translate([mountPositions[3][0]-t/2,
                    (boxWidth-t/2)+(cornerR-wallThickness), h-FUDGE/2])
                Tab(t);
        }
    }
}
            
boxHeight = boardHeight+botRoom+topRoom+2*wallThickness+tol;
boxWidth = boardWidth+tol; // to cylinder centers (-2*r)
boxLength = boardLength+extraLength+tol;

if(!printCover) {
    union() {
        difference() {
            RoundedBox(l=boxLength, w=boxWidth, h=boxHeight,
                    t=wallThickness, r=cornerR);
            translate([-(wallThickness+(cornerR-wallThickness+FUDGE/2)),
                    usbStart-tol/2,
                    (wallThickness+mountHeight+pcbThickness)-tol/2])
                cube([wallThickness+tol+FUDGE,usbWidth+tol,usbHeight+tol],
                    center=false);
            translate([-(wallThickness+(cornerR-wallThickness+FUDGE/2)),
                    powerStart-tol/2,
                    (wallThickness+mountHeight++pcbThickness)-tol/2])
                cube([wallThickness+tol+FUDGE,powerWidth+tol,powerHeight+tol], 
                    center=false);
            if(hasWireChannelsY) { // wire routing holes
                translate([boxLength/2,-(cornerR+FUDGE/2),boxHeight])
                    rotate([-90,0,0]) // sticking out in positive Y
                        cylinder(h=wallThickness+FUDGE, d=wireChannelD,
                                center=false);
                translate([boxLength/2,boxWidth+cornerR+FUDGE/2,boxHeight])
                    rotate([90,0,0]) // sticking out in negative Y
                        cylinder(h=wallThickness+FUDGE, d=wireChannelD,
                                center=false);
            }
            if(hasWireChannelsX) { // wire routing holes
                translate([-(cornerR+FUDGE/2),boxWidth/2,boxHeight])
                    rotate([0,90,0]) // sticking out in positive x
                        cylinder(h=wallThickness+FUDGE, d=wireChannelD,
                                center=false);
                translate([boxLength+cornerR+FUDGE/2,boxWidth/2,boxHeight])
                    rotate([0,-90,0]) // sticking out in negative Y
                        cylinder(h=wallThickness+FUDGE, d=wireChannelD,
                                center=false);
            }
            if(hasVents) {
                l = 0.75*boxLength; // venting 75% of box length
                for (i=[0:numVents-1]) {
                    translate([boxLength*(0.25/2)+i*(l/numVents)+(l/numVents)/2,
                            -(cornerR-(wallThickness+FUDGE/2)/2),
                            boxHeight/2])
                        cube([ventWidth,wallThickness+FUDGE,boxHeight*0.45],
                            center=true);
                }
                for (i=[0:numVents-1]) {
                    translate([boxLength*(0.25/2)+i*(l/numVents)+(l/numVents)/2,
                            boxWidth+(cornerR-(wallThickness+FUDGE/2)/2),
                            boxHeight/2])
                        cube([ventWidth,wallThickness+FUDGE,boxHeight*0.45],
                            center=true);
                }
            }
            // lid subtract to get the indentations
            translate([0, boxWidth, boxHeight+lidHeight])
                rotate([180,0,0])
                    Lid(l=boxLength, w=boxWidth, h=lidHeight, r=cornerR,
                        hd=0, t=5);
        }

        for(i=mountPositions) { // board mounts
            translate([i[0]+mountDia/2,i[1]+mountDia/2,wallThickness-FUDGE])
                MountPoint(d=mountDia, h=mountHeight, ss=screwDia, p=threadPitch);
        }
        // mount feet
        translate([footRelief,boxWidth+cornerR*2+wallThickness,0])
            AttachFoot(d=footD, hd=footHD);
        translate([boxLength-footRelief,
                boxWidth+cornerR*2+wallThickness,0])
            AttachFoot(d=footD, hd=footHD);
        translate([footRelief,-(footD/2+cornerR+wallThickness/2),0])
            rotate([0,0,180])
                AttachFoot(d=footD, hd=footHD);
        translate([boxLength-footRelief,
                -(footD/2+cornerR+wallThickness/2),0])
            rotate([0,0,180])
                AttachFoot(d=footD, hd=footHD);
        // battery holder
        difference() {
            translate([box9vOffSet,
                    boxWidth+cornerR*2+tol/2+FUDGE-box9vWall,box9vZOff])
                rotate([0,-90,0])
                    Box9V();
            translate([box9vOffSet-42-FUDGE/2,boxWidth,-42])
                cube([42+FUDGE,17.1+8,42], center=false);
        }
        // card reader
        if(hasSDholder) {
            translate([boxLength+sDwidth,
                sDyOffset,sDzOffset])
            rotate([0,-90,-90])
                BoxSDreader();
        }
    }
}

if(printCover) {
    Lid(l=boxLength, w=boxWidth, h=lidHeight, r=cornerR,
                        hd=0, t=5);
}
