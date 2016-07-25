//------------------------------------------------------------------
/*

Wallaby Cylinder Head

No draft version for 3d printing and lost-PLA investment casting.

*/
//-----------------------------------------------------------------
// casting == true
// add: machining allowances
// remove: machined features

//casting = false;
casting = true;

//-----------------------------------------------------------------
// scaling

desired_scale = 1.25;
mm_per_inch = 25.4;
al_shrink = 1/0.99; // ~1%
pla_shrink = 1/0.998; //~0.2%
abs_shrink = 1/0.995; //~0.5%

function scale(x) = x * desired_scale * mm_per_inch * al_shrink * pla_shrink;

//-----------------------------------------------------------------
// control the number of facets on cylinders

facet_epsilon = 0.01;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// small tweak to avoid differencing artifacts
epsilon = 0.05;

//------------------------------------------------------------------
// rounded/filleted edges

module inverse() {
  difference() {
    square(1e5, center=true);
    children(0);
  }
}

module rounded(r=1) {
  offset(r=r, $fn=facets(r)) offset(r=-r, $fn=facets(r)) children(0);
}

module filleted(r=1) {
  offset(r=-r, $fn=facets(r)) render() offset(r=r, $fn=facets(r)) children(0);
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
  linear_extrude(dome_h, convexity=2) offset(r=-epsilon) head_wall_outer_2d();
}

module cylinder_head(d, mode) {
  if (mode == "dome") {
    translate([d,0,dome_h]) rotate([0,180,0]) {
      linear_extrude(height = dome_h, scale = dome_draft) circle(r = dome_r, $fn = facets(dome_r));
    }
  }
  if (mode == "chamber") {
    translate([d, 0 , -epsilon]) {
      cylinder(h = cylinder_h + epsilon, r = cylinder_r, $fn=facets(cylinder_r));
    }
  }
}

module cylinder_heads(mode) {
  cylinder_head(-c2c_d/2, mode);
  cylinder_head(c2c_d/2, mode);
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
    inverse() offset(r=-head_wall_t) head_wall_outer_2d();
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

eb_side_r = scale(5/32);
eb_main_r = scale(5/16);
eb_hole_r = scale(3/16);
eb_c2c_d = scale(13/16);
eb_d = eb_c2c_d/2;

eb_y_ofs = (head_w/2) - eb_d - eb_side_r;
eb_z_ofs = scale(1/2);
eb_h = scale(1/8);
eb_draft = [0.97,0.97];

module exhaust_boss_2d(mode) {
  if (mode == "body") {
    hull() {
      circle(r=eb_main_r, $fn=facets(eb_main_r));
      translate([0,eb_d,0]) circle(r=eb_side_r, $fn=facets(eb_side_r));
      translate([0,-eb_d,0]) circle(r=eb_side_r, $fn=facets(eb_side_r));
    }
  }
  if (mode == "hole") {
    circle(r=eb_hole_r, $fn=facets(eb_hole_r));
  }
}

module exhaust_boss(d, theta, mode) {
  if (mode == "body") {
    translate([d,eb_y_ofs,eb_z_ofs]) rotate([0,theta,0]) union() {
      linear_extrude(height = eb_h, scale = eb_draft) exhaust_boss_2d(mode);
      translate([0,0,-eb_h + epsilon]) linear_extrude(height = eb_h) exhaust_boss_2d(mode);
    }
  }
  if (mode == "hole") {
    translate([d,eb_y_ofs,eb_z_ofs]) rotate([0,theta,0]) {
      translate([0,0,eb_h/2]) linear_extrude(height = eb_h) exhaust_boss_2d(mode);
    }
  }
}

module exhaust_bosses(mode) {
  exhaust_boss(head_l/2 - epsilon, 90, mode);
  exhaust_boss(-head_l/2 + epsilon, -90, mode);
}

//------------------------------------------------------------------
// put a recess into the plastic so I can jam the wax sprue into it

sprue_d = scale(3/10);
sprue_h = scale(1/5);

module sprue_hole() {
  translate([-head_l/2 - eb_h, eb_y_ofs, eb_z_ofs])
  rotate([0,90,0])
  cylinder(h = sprue_h, d = sprue_d, $fn = facets(sprue_d));
}

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
      if (mode == "boss") {
        linear_extrude(height = head_h - cylinder_h - epsilon, scale = valve_draft)
          circle(r = valve_r + valve_wall, $fn = facets(valve_r + valve_wall));
      }
      if (mode == "hole") {
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
// spark plug bosses

sp2sp_d = scale(1 + (5/8));
sp_theta = 30;

sp_boss_r1 = scale(21/64);
sp_boss_r2 = scale(15/32);
sp_boss_h1 = scale(0.79);
sp_boss_h2 = scale(0.94);
sp_boss_h3 = scale(2);

sp_hole_d = scale(21/64);
sp_hole_r = sp_hole_d/2;
sp_hole_h = scale(1);

sp_cb_h1 = scale(1);
sp_cb_h2 = scale(2);
sp_cb_r = scale(5/16);

sp_hyp = sp_hole_h + sp_cb_r * tan(sp_theta);
sp_y_ofs = (sp_hyp * cos(sp_theta)) - (head_w/2);
sp_z_ofs = (head_h/2) - (sp_hyp * sin(sp_theta));

module sparkplug_feature(d, mode) {
  translate([d,sp_y_ofs,sp_z_ofs]) rotate([90-sp_theta,0,0]) {
    if (mode == "boss") {
      points = [
        [0,0],
        [sp_boss_r1,0],
        [sp_boss_r1,sp_boss_h1],
        [sp_boss_r2,sp_boss_h2],
        [sp_boss_r2,sp_boss_h3],
        [0,sp_boss_h3],
      ];
      rotate_extrude($fn=facets(sp_boss_r2))
        filleted(sp_boss_r1 * 0.3) rounded(sp_boss_r2 * 0.3)
        polygon(points=points, convexity=2);
    }
    if (mode == "hole") {
      points = [
        [0, 0],
        [sp_hole_r,0],
        [sp_hole_r,sp_hole_h + (2 * epsilon)],
        [0,sp_hole_h + (2 * epsilon)],
      ];
      translate([0,0,-epsilon]) rotate_extrude($fn=facets(sp_hole_r)) polygon(points=points, convexity=2);
    }
    if (mode == "counterbore") {
      points = [
        [0,sp_cb_h1],
        [sp_cb_r,sp_cb_h1],
        [sp_cb_r,sp_cb_h2 + (2 * epsilon)],
        [0,sp_cb_h2 + (2 * epsilon)],
      ];
      translate([0,0,-epsilon]) rotate_extrude($fn=facets(sp_cb_r)) polygon(points=points, convexity=2);
    }
  }
}

module sparkplugs(mode) {
  sparkplug_feature(-sp2sp_d/2, mode);
  sparkplug_feature(sp2sp_d/2, mode);
}

module sparkplugs_boss() {
  intersection () {
    sparkplugs("boss");
    head_outer();
  }
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
  //cylinder_heads("dome");
  valve_sets("boss");
  sparkplugs_boss();
  manifolds();
  exhaust_bosses("body");
}

module subtractive() {
  if (casting) {
    sprue_hole();
    //cylinder_heads("chamber");
    //sparkplugs("counterbore");
  } else {
    head_stud_holes();
    cylinder_heads("chamber");
    valve_sets("hole");
    sparkplugs("hole");
    sparkplugs("counterbore");
    exhaust_bosses("hole");
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
// Add machining allowances to top and bottom surfaces

allowance_width = scale(1/32);

module allowances() {
  color("Red", 0.5) {
    // bottom surface
    translate([0,0,-allowance_width + epsilon]) {
      linear_extrude(height = allowance_width) projection(cut = true)
      translate ([0,0,-epsilon]) base_model();
    }
    // top surface
    translate([0,0,head_h - epsilon]) {
      linear_extrude(height = allowance_width) projection(cut = true)
      translate ([0,0,-head_h + epsilon]) base_model();
    }
  }
}

//-----------------------------------------------------------------

module model() {
  base_model();
  if (casting) {
    allowances();
  }
}

model();

//-----------------------------------------------------------------
