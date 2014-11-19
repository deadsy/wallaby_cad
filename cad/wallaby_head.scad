//------------------------------------------------------------------
/*

Wallaby Cylinder Head

*/
//------------------------------------------------------------------
// scaling

_desired_scale = 1.25;
_al_shrink = 0.98;
_scale = _desired_scale / _al_shrink;

//------------------------------------------------------------------
// tweak a height to avpoid rendering issues when diff-ed surfaces
// align with each other.

tweak = 0.001;

//------------------------------------------------------------------
// control the number of facets on cylinders

_accuracy = 0.001;
function fn(r) = 180 / acos(1 - (_accuracy / r));

//------------------------------------------------------------------

cylinder_h = 3/16;
cylinder_d = 1 + (1/8);
c2c_d = (1 + (3/8));
cylinder_wall = 1/8;
tweak = 1/64;

cylinder_r = cylinder_d / 2.0;

module cylinder_head(d) {
  translate([d, 0, -head_h / 2]) {
    difference() {
      cylinder(h = cylinder_h + cylinder_wall, r = cylinder_r + cylinder_wall, $fn = fn(cylinder_r));
      translate([0, 0, -tweak]) {
	     cylinder(h = cylinder_h + tweak, r = cylinder_r, $fn = fn(cylinder_r));
      }
    }
  }
}

module cylinder_heads() {
  cylinder_head(-c2c_d / 2.0);
  cylinder_head(c2c_d / 2.0);
}

//------------------------------------------------------------------
// cylinder head wall

head_h_lower = 1/2;
head_h_upper = 3/8;
head_h = head_h_upper + head_h_lower;
head_draft_outer = [1.01,1.01];
head_draft_inner = [0.98,0.98];

module head_outer() {
  translate([0,0,-head_h_lower]) {
    linear_extrude(height = head_h_lower, scale = head_draft_outer)
    import(file = "head_cover.dxf", layer = "head_wall_outer", $fn = fn(0.25));
  }
  translate([0,0,head_h_upper]) {
    rotate([0,180,0]) {
      linear_extrude(height = head_h_upper, scale = head_draft_outer)
      import(file = "head_cover.dxf", layer = "head_wall_outer", $fn = fn(0.25));
    }
  }
}

module head_inner() {
  translate([0,0,head_h_upper]) {
    rotate([0,180,0]) {
      linear_extrude(height = head_h + tweak, scale = head_draft_inner)
      import(file = "head_cover.dxf", layer = "head_wall_inner", $fn = fn(0.25));
    }
  }
}

module head_stud_holes() {
  translate([0,0,-head_h_lower]) {
    linear_extrude(height = head_h + tweak)
    import(file = "head_cover.dxf", layer = "head_wall_holes", $fn = fn(0.25));
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

module additive() {
  head_walls();
}

module subtractive() {
  head_stud_holes();
}

//------------------------------------------------------------------

difference() {
  additive();
  subtractive();
}

//------------------------------------------------------------------
