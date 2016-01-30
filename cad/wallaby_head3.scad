//------------------------------------------------------------------
/*

Wallaby Cylinder Head

No draft version for 3d printing and lost-PLA investment casting.

*/
//-----------------------------------------------------------------
// casting == true
// add: machining allowances
// remove: machined features

casting = false;
//casting = true;

//-----------------------------------------------------------------
// scaling

desired_scale = 1.25;
mm_per_inch = 25.4;
al_shrink = 1/0.98; // ~2%
pla_shrink = 1/0.998; //~0.2%

function scale(x) = x * desired_scale * mm_per_inch * al_shrink * pla_shrink;

//-----------------------------------------------------------------
// control the number of facets on cylinders

facet_epsilon = 0.01;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// small tweak to avoid differencing artifacts
epsilon = 0.05;

//------------------------------------------------------------------
// rounded/filleted edges

module outset(d=1) {
  minkowski() {
    circle(r=d, $fn=facets(d));
    children(0);
  }
}

module inset(d=1) {
  render() inverse() outset(d=d) inverse() children(0);
}

module inverse() {
  difference() {
    square(1e5, center=true);
    children(0);
  }
}

module rounded(r=1) {
  outset(d=r) inset(d=r) children(0);
}

module filleted(r=1) {
  inset(d=r) render() outset(d=r) children(0);
}

//-----------------------------------------------------------------
// Lengths (at original scale in inches)

head_l = scale(4.30/1.25);
head_w = scale(2.33/1.25);
head_h = scale(7/8);
head_corner_r = scale((5/32)/1.25);
head_wall_t = scale(0.154);

stud_hole_r = scale(1/16);
stud_boss_r = scale(3/16);
stud_hole_dy = scale(11/16);
stud_hole_dx0 = scale(7/16);
stud_hole_dx1 = scale(1.066);

stud_locations = [
 [stud_hole_dx0 + stud_hole_dx1, 0],
 [stud_hole_dx0 + stud_hole_dx1, stud_hole_dy],
 [stud_hole_dx0 + stud_hole_dx1, -stud_hole_dy],
 [stud_hole_dx0, stud_hole_dy],
 [stud_hole_dx0, -stud_hole_dy],
 [-stud_hole_dx0 - stud_hole_dx1, 0],
 [-stud_hole_dx0 - stud_hole_dx1, stud_hole_dy],
 [-stud_hole_dx0 - stud_hole_dx1, -stud_hole_dy],
 [-stud_hole_dx0, stud_hole_dy],
 [-stud_hole_dx0, -stud_hole_dy],
];

//-----------------------------------------------------------------

module head_wall_outer_2d() {
  square([head_l, head_w], center = true);
}

module head_wall_inner_2d() {
  rounded(head_corner_r) inverse() union() {
    inverse() inset(head_wall_t) head_wall_outer_2d();
    head_wall_studs(stud_boss_r);
  }
}

module head_wall_studs(r) {
  for (p = stud_locations) {
    translate([p[0], p[1], 0]) circle(r, $fn=facets(r));
  }
}

module head_wall_2d() {
  difference() {
    rounded(head_corner_r) head_wall_outer_2d();
    rounded(head_corner_r) head_wall_inner_2d();
  }
}

module head_wall() {
    linear_extrude(head_h, convexity=2) head_wall_2d();
}

module head_stud_holes() {
  translate([0,0,-epsilon]) linear_extrude(head_h + (2 * epsilon)){
    head_wall_studs(stud_hole_r);
  }
}

//-----------------------------------------------------------------

module additive() {
  head_wall();
}

module subtractive() {
  if (casting) {
  } else {
    head_stud_holes();
  }
}

module base_model() {
  difference() {
    additive();
    subtractive();
  }
}

//-----------------------------------------------------------------

module model() {
  base_model();
}

model();

//-----------------------------------------------------------------
