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
// cylinder domes (or full base)

cylinder_h = scale(3/16);
cylinder_d = scale(1 + (1/8));
cylinder_wall = scale(1/4);
cylinder_r = cylinder_d / 2;

dome_r = cylinder_wall + cylinder_r;
dome_h = cylinder_wall + cylinder_h;
dome_draft = [1.04,1.04];

c2c_d = scale(1 + (3/8));

module head_base() {
  linear_extrude(dome_h, convexity=2) head_wall_outer_2d();
}

//------------------------------------------------------------------
// cylinder heads - the empty space

module cylinder_head(d) {
  translate([d, 0 , -epsilon]) {
    cylinder(h = cylinder_h + epsilon, r = cylinder_r, $fn=facets(cylinder_r));
  }
}

module cylinder_heads() {
  cylinder_head(-c2c_d/2);
  cylinder_head(c2c_d/2);
}

//-----------------------------------------------------------------
// stud holes

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

module head_wall_studs(r) {
  for (p = stud_locations) {
    translate([p[0], p[1], 0]) circle(r, $fn=facets(r));
  }
}

module head_stud_holes() {
  translate([0,0,-epsilon]) linear_extrude(head_h + (2 * epsilon)){
    head_wall_studs(stud_hole_r);
  }
}

//-----------------------------------------------------------------
// Head Walls

head_l = scale(4.30/1.25);
head_w = scale(2.33/1.25);
head_h = scale(7/8);
head_corner_r = scale((5/32)/1.25);
head_wall_t = scale(0.154);

module head_wall_outer_2d() {
  rounded(head_corner_r) square([head_l, head_w], center = true);
}

module head_wall_inner_2d() {
  rounded(head_corner_r) inverse() union() {
    inverse() inset(head_wall_t) head_wall_outer_2d();
    head_wall_studs(stud_boss_r);
  }
}

module head_wall() {
  linear_extrude(head_h, convexity=2) difference() {
    head_wall_outer_2d();
    head_wall_inner_2d();
  }
}

module head_outer() {
  linear_extrude(head_h, convexity=2) head_wall_outer_2d();
}

//-----------------------------------------------------------------
// exhaust bosses

eb_z_ofs = scale(1/2);
eb_h = head_l + scale(3/16);

//------------------------------------------------------------------
// valve bosses

valve_d = scale(1/4);
valve_r = valve_d/2;
valve_y_ofs = scale(1/8);
valve_wall = scale(5/32);
v2v_d = scale(1/2);
valve_draft = [1.2,1.2];

module valve(d, mode) {
  translate([d,valve_y_ofs,head_h]) {
    rotate([180,0,0]) {
      if (mode == "body") {
        linear_extrude(height = head_h - cylinder_h, scale = valve_draft)
          circle(r = valve_r + valve_wall, $fn = facets(valve_r + valve_wall));
      } else {
        translate([0,0,-epsilon]) linear_extrude(height = head_h + (2 * epsilon))
          circle(r = valve_r, $fn = facets(valve_r));
      }
    }
  }
}

module valve_set(d, mode) {
  translate([d,0,0]) {
    valve(-v2v_d/2, mode);
    valve(v2v_d/2, mode);
  }
}

module valve_sets(mode) {
    valve_set(-c2c_d/2, mode);
    valve_set(c2c_d/2, mode);
}

//------------------------------------------------------------------
// manifolds

manifold_r = scale(5/16);
manifold_hole_r = scale(1/8);
inlet_theta = 30.2564;
exhaust_theta = 270 + 13.9736;
exhaust_x_ofs = (c2c_d/2) + (v2v_d/2);
inlet_x_ofs = (c2c_d/2) - (v2v_d/2);

module manifold_set(r) {
  translate([exhaust_x_ofs,valve_y_ofs,eb_z_ofs]) {
    rotate([-90,0,exhaust_theta]) {
      cylinder(h=scale(2),r=r, $fn = facets(r));
    }
  }
  translate([inlet_x_ofs,valve_y_ofs,eb_z_ofs]) {
    rotate([-90,0,inlet_theta]) {
      cylinder(h=scale(2),r=r, $fn = facets(r));
    }
  }
}

module manifold_x() {
  manifold_set(manifold_r);
  mirror([1,0,0]) {
    manifold_set(manifold_r);
  }
}

module manifolds() {
  intersection() {
    manifold_x();
    head_outer();
  }
}

module manifold_holes() {
  manifold_set(manifold_hole_r);
  mirror([1,0,0]) {
    manifold_set(manifold_hole_r);
  }
}

//-----------------------------------------------------------------

module additive() {
  head_wall();
  head_base();
  valve_sets("body");
  manifolds();
}

module subtractive() {
  if (casting) {
  } else {
    head_stud_holes();
    cylinder_heads();
    valve_sets("hole");
    manifold_holes();
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
