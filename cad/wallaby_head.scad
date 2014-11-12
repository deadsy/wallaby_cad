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

head_h = (1/2) + (3/8);

module head_walls() {
    linear_extrude(height = head_h, center = true)
    difference() {
	    import(file = "head_cover.dxf", layer = "head_wall_outer", $fn = fn(0.25));
	    import(file = "head_cover.dxf", layer = "head_wall_inner", $fn = fn(0.25));
    }
}

//------------------------------------------------------------------

head_walls();

//------------------------------------------------------------------
