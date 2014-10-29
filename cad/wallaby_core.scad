//------------------------------------------------------------------
/*

Wallaby Engine Block Core

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
// cylinder cores

// unscaled sizes: core = 0.875, cylinder bore = 1.000, liner bore = 1.125
// scaled sizes: core = 1.125, cylinder bore = 1.25, liner bore = 1.406
// So: In the scaled engine we have core size that matches a standard dowel and > 1/4"
// of machining tolerance on the liner bore diameter.

cylinder_d = (1 + (1/8)) / _scale; // diameter
cylinder_h = (3 + (5/16)); // height
core_print_h = 3/4;
c2c_d = (1 + (3/8));

cylinder_r = cylinder_d / 2.0;

module cylinder_core(d) {
	translate([0, d, 0]) {
		cylinder(h = cylinder_h + core_print_h, r = cylinder_r, $fn = fn(cylinder_r));
	}
}

module cylinder_cores() {
	cylinder_core(-c2c_d / 2.0);
	cylinder_core(c2c_d / 2.0);
}

//------------------------------------------------------------------
// camshaft core

camshaft_d = (3/4); // diameter
camshaft_l = 2 + (3/8); // length
camshaft_dx = (1 + (1/8)); // x-displacement
camshaft_dz = 1.084; // z-displacement

camshaft_r = camshaft_d / 2.0;

module camshaft_core() {
	translate([camshaft_dx, 0, camshaft_dz]) {
		rotate([90, 0, 0]) {
			cylinder(h = camshaft_l, r = camshaft_r, center = true, $fn = fn(camshaft_r));
		}
	}
}

//------------------------------------------------------------------
// water jacket

wj_sy = 2 + (7/8);

module water_jacket_core() {
    rotate([90,0,0])
    linear_extrude(height = wj_sy, center = true)
    import(file = "engine_body.dxf", layer = "water_jacket", $fn = fn(0.25));
}

//------------------------------------------------------------------
// body outline

body_l = 3 + (1/8);

module body_outline() {
	 color([0,1,0,0.3])
    rotate([90,0,0])
    linear_extrude(height = body_l, center = true)
    import(file = "engine_body_outline.dxf", $fn = fn(0.25));
}

//------------------------------------------------------------------
// lower cores

lower_sy = 1;

module lower_core(d) {
    translate([0, d, 0])
    rotate([90,0,0])
    linear_extrude(height = lower_sy, center = true)
    import(file = "engine_body.dxf", layer = "lower_core", $fn = fn(0.25));
}

module lower_cores() {
	lower_core(-c2c_d / 2);
	lower_core(c2c_d / 2);
}

//------------------------------------------------------------------

cylinder_cores();
lower_cores();
water_jacket_core();
camshaft_core();
body_outline();

//------------------------------------------------------------------
