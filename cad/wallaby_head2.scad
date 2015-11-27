//------------------------------------------------------------------
/*

Wallaby Cylinder Head

No draft version intended for 3d printing and investment casting.

*/
//------------------------------------------------------------------
// scaling

// note: STL is unit-less, so I'm leaving all measurements as plan
// and handling the scaling on the print side.

_desired_scale = 1.25;
_al_shrink = 0.98;
_scale = _desired_scale / _al_shrink;

//------------------------------------------------------------------
// tweak a height to avoid rendering issues when diff-ed surfaces
// align with each other.

tweak = 0.001;

//------------------------------------------------------------------
// control the number of facets on cylinders

_accuracy = 0.001;
function fn(r) = 180 / acos(1 - (_accuracy / r));

//------------------------------------------------------------------
// cylinder domes - or full base

cylinder_h = 3/16;
cylinder_d = 1 + (1/8);
cylinder_wall = 1/4;
cylinder_r = cylinder_d / 2;

dome_r = cylinder_wall + cylinder_r;
dome_h = cylinder_wall + cylinder_h;
dome_draft = [1.04,1.04];

c2c_d = (1 + (3/8));

// cylinder domes - the metal
module cylinder_dome(d) {
  translate([d,0,dome_h]) {
    rotate([0,180,0]) {
      linear_extrude(height = dome_h, scale = dome_draft)
      circle(r = dome_r, $fn = fn(dome_r));
    }
  }
}

module cylinder_domes() {
  cylinder_dome(-c2c_d/2);
  cylinder_dome(c2c_d/2);
}

// full cylinder head base
module head_base() {
  translate([0,0,0]) {
    linear_extrude(height = dome_h)
    import(file = "head_cover.dxf", layer = "head_wall_outer", $fn = fn(0.25));
  }
}

//------------------------------------------------------------------
// cylinder heads - the empty space

head_tweak = 1;

module cylinder_head(d) {
  translate([d,0,-head_tweak]) {
    cylinder(h = cylinder_h + head_tweak, r = cylinder_r, $fn = fn(cylinder_r));
  }
}

module cylinder_heads() {
  cylinder_head(-c2c_d / 2.0);
  cylinder_head(c2c_d / 2.0);
}

//------------------------------------------------------------------
// cylinder head wall

head_w = 1 + (3/4);
head_h = (7/8);
head_l = 3.382;

eb_h = head_l + (3/16);
eb_z_ofs = (1/2);

module head_outer() {
  // wall
  translate([0,0,head_h]) {
    rotate([0,180,0]) {
      linear_extrude(height = head_h)
      import(file = "head_cover.dxf", layer = "head_wall_outer", $fn = fn(0.25));
    }
  }
  // exhaust bosses
  translate([-eb_h/2,0,eb_z_ofs]) {
    rotate([0,90,0]) {
      linear_extrude(height = eb_h)
      import(file = "head_cover.dxf", layer = "exhaust_boss", $fn = fn(1/4));
    }
  }
}

module head_inner() {
  translate([0,0,head_h + tweak/2]) {
    rotate([0,180,0]) {
      linear_extrude(height = head_h + tweak)
      import(file = "head_cover.dxf", layer = "head_wall_inner", $fn = fn(1/4));
    }
  }
}

module head_stud_holes() {
  translate([0,0,-tweak/2]) {
    linear_extrude(height = head_h + tweak)
    import(file = "head_cover.dxf", layer = "head_wall_holes", $fn = fn(1/4));
  }
}

module head_walls()
{
  difference() {
    head_outer();
    head_inner();
  }
}

//------------------------------------------------------------------
// valve bosses

valve_d = 1/4;
valve_r = valve_d/2;
valve_y_ofs = 1/8;
valve_wall = 5/32;
v2v_d = 1/2;
valve_draft = [1.2,1.2];

module valve(d) {
  translate([d,valve_y_ofs,head_h]) {
    rotate([180,0,0]) {
      linear_extrude(height = head_h - cylinder_h, scale = valve_draft)
      circle(r = valve_r + valve_wall, $fn = fn(1/4));
    }
  }
}

module valve_set(d) {
  translate([d,0,0]) {
    valve(-v2v_d/2);
    valve(v2v_d/2);
  }
}

module valve_sets() {
    valve_set(-c2c_d/2);
    valve_set(c2c_d/2);
}

module valve_holes() {
  translate([0,0,-tweak/2]) {
    linear_extrude(height = head_h + tweak)
    import(file = "head_cover.dxf", layer = "valve_holes", $fn = fn(1/8));
  }
}

//------------------------------------------------------------------
// spark plug bosses

sp_hole_d = 21/64;
sp_hole_r = sp_hole_d/2;
sp2sp_d = 1 + (5/8);
sp_hole_h = 3;
sp_theta = 30;
sp_gap = (head_w/2) - ((7/16)/tan(sp_theta));
sp_base = ((7/16)/tan(sp_theta)) - ((5/16)*sin(sp_theta));
sp_y_ofs = -(sp_gap + sp_base);
sp_z_ofs = (sp_base * tan(sp_theta));

module sp_boss(d) {
  translate([d,sp_y_ofs,sp_z_ofs]) {
    rotate([90-sp_theta,0,0]) {
      rotate_extrude($fn = 64)
      import(file = "sparkplug.dxf", layer = "outer");
    }
  }
}

module sp_bosses() {
  intersection() {
    head_outer();
    union() {
      sp_boss(-sp2sp_d/2);
      sp_boss(sp2sp_d/2);
    }
  }
}

module sp_hole(d) {
  translate([d,sp_y_ofs,sp_z_ofs]) {
    rotate([90-sp_theta,0,0]) {
      rotate_extrude($fn = 64)
      import(file = "sparkplug.dxf", layer = "inner");
    }
  }
}

module sp_holes() {
  sp_hole(-sp2sp_d/2);
  sp_hole(sp2sp_d/2);
}

//------------------------------------------------------------------

manifold_r = 5/16;
manifold_hole_r = 1/8;
inlet_theta = 30.2564;
exhaust_theta = 270 + 13.9736;
exhaust_x_ofs = (c2c_d/2) + (v2v_d/2);
inlet_x_ofs = (c2c_d/2) - (v2v_d/2);

module manifold_set(r) {
  translate([exhaust_x_ofs,valve_y_ofs,eb_z_ofs]) {
    rotate([-90,0,exhaust_theta]) {
      cylinder(h=2,r=r, $fn = fn(r));
    }
  }
  translate([inlet_x_ofs,valve_y_ofs,eb_z_ofs]) {
    rotate([-90,0,inlet_theta]) {
      cylinder(h=2,r=r, $fn = fn(r));
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

//------------------------------------------------------------------

casting = true;

module additive() {
  head_walls();
  head_base();
  //cylinder_domes();
  sp_bosses();
  valve_sets();
  manifolds();
}

module subtractive() {
  if (casting == true) {
    cylinder_heads();
  } else {
    head_stud_holes();
    cylinder_heads();
    valve_holes();
    sp_holes();
    manifold_holes();
  }
}

//------------------------------------------------------------------

difference() {
  additive();
  subtractive();
}

//------------------------------------------------------------------

