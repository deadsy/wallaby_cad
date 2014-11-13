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

head_h = (1/2) + (3/8);

module head_walls() {
    linear_extrude(height = head_h, center = true)
    difference() {
	    import(file = "head_cover.dxf", layer = "head_wall_outer", $fn = fn(0.25));
	    import(file = "head_cover.dxf", layer = "head_wall_inner", $fn = fn(0.25));
	    import(file = "head_cover.dxf", layer = "head_wall_holes", $fn = fn(0.125));
    }
}

//------------------------------------------------------------------

head_walls();
cylinder_heads();

//------------------------------------------------------------------
