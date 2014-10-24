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
function fn(r) = 180.0 / acos(1 - (_accuracy / r));

//------------------------------------------------------------------
// cylinder cores

cylinder_d = (7/8); // diameter
cylinder_h = (3 + (5/16)); // height
c2c_d = (1 + (3/8));

cylinder_r = cylinder_d / 2.0;

module cylinder_core(d) {
	translate([0, d, 0]) {
		cylinder(h = cylinder_h, r = cylinder_r, $fn = fn(cylinder_r));
	}
}

module cylinder_cores() {
	cylinder_core(-c2c_d / 2.0);
	cylinder_core(c2c_d / 2.0);
}

//------------------------------------------------------------------
// camshaft core

camshaft_d = (3/4); // diameter
camshaft_l = 4.0; // length
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

wj_sx = 1 + (1/2);
wj_sy = 2 + (7/8);
wj_sz = 1 + (3/16);
wj_dz = 1 + (14/16) + (wj_sz / 2);

module water_jacket_core() {
	translate([0, 0, wj_dz]) {
		cube(size = [wj_sx, wj_sy, wj_sz], center = true);
	}
}

//------------------------------------------------------------------
// body outline

module body_outline() {
	 color([0,1.0,0,0.2])
    rotate([90,0,0])
    linear_extrude(height = camshaft_l, center = true)
    import(file = "engine_body_outline.dxf", $fn = fn(0.25));
}

//------------------------------------------------------------------
// lower cores

module lower_core(d) {
    translate([0, d, 0])
    rotate([90,0,0])
    linear_extrude(height = cylinder_d, center = true)
    import(file = "lower_core.dxf", layer = "lower_core", $fn = fn(0.25));
}

module lower_cores() {
	lower_core(-c2c_d / 2.0);
	lower_core(c2c_d / 2.0);
}

//------------------------------------------------------------------

cylinder_cores();
lower_cores();
water_jacket_core();
camshaft_core();
body_outline();

//------------------------------------------------------------------
