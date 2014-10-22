//------------------------------------------------------------------
/*

Wallaby Engine Block Core

*/
//------------------------------------------------------------------
// basic units

_scale = 1.25;
_mm_per_inch = 25.4;
_inches = _mm_per_inch * _scale;

//------------------------------------------------------------------
// cylinder cores

cylinder_d = 1.0 * _inches; // diameter
cylinder_h = 2.0 * _inches; // height
c2c_d = 2.0 * _inches;

cylinder_r = cylinder_d / 2.0;

module cylinder_core(d) {
	translate([0, d, 0]) {
		cylinder(h = cylinder_h, r = cylinder_r);
	}
}

module cylinder_cores() {
	cylinder_core(-c2c_d / 2.0);
	cylinder_core(c2c_d / 2.0);
}

//------------------------------------------------------------------
// camshaft core

camshaft_d = 1.0 * _inches; // diameter
camshaft_l = 5.0 * _inches; // length
camshaft_dx = 2.0 * _inches; // x-displacement
camshaft_dz = 1.0 * _inches; // z-displacement

camshaft_r = camshaft_d / 2.0;

module camshaft_core() {
	translate([camshaft_dx, 0, camshaft_dz]) {
		rotate([90, 0, 0]) {
			cylinder(h = camshaft_l, r = camshaft_r, center = true);
		}
	}
}

//------------------------------------------------------------------
// water jacket

wj_sx = 1.5 * _inches;
wj_sy = 5.0 * _inches;
wj_sz = 1.0 * _inches;
wj_dz = 1.0 * _inches;

module water_jacket_core() {
	translate([0, 0, wj_dz]) {
		cube(size = [wj_sx, wj_sy, wj_sz], center = true);
	}
}

//------------------------------------------------------------------

cylinder_cores();
water_jacket_core();
camshaft_core();

//------------------------------------------------------------------
