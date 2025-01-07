// image print

difference() {
  scale([0.35,0.35,0.08])
    surface(file = "skull1.png", center = true, convexity = 7);
  cube([200,250,1], center = true);
  translate([0,58,0])
    cylinder($fn=30, h=40, d=5, center=true);
}
  