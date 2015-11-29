//------------------------------------------------------------------


//------------------------------------------------------------------

casting = false;

//------------------------------------------------------------------
// control the number of facets on cylinders

_accuracy = 0.001;
function fn(r) = 180 / acos(1 - (_accuracy / r));

//------------------------------------------------------------------

module carb_body() {
  rotate_extrude($fn = 64)
  import(file = "carburetor.dxf", layer = "body_profile",  $fn = fn(0.1));
}

module carb_body_bore() {
  rotate_extrude($fn = 64)
  import(file = "carburetor.dxf", layer = "body_bore_profile",  $fn = fn(0.1));
}

//------------------------------------------------------------------

tb_w = 3/4;

module throttle_body() {
  rotate([90,0,0]) {
    translate([0,0,-tb_w/2]) {
      linear_extrude(height = tb_w)
      import(file = "carburetor.dxf", layer = "throttle_body_profile",  $fn = fn(0.1));
    }
  }
}

//------------------------------------------------------------------

ah_d = 5/32;
ah_r = ah_d/2;
ah_l = 2;
ah_z = (3.125 - (7/16));

module air_holes() {
  translate([0,0,ah_z]) {
    for (theta= [0,60,120]) {
      rotate([0,0,theta]) {
        rotate([90,0,0]) {
          translate([0,0,-ah_l/2]) {
            cylinder(h = ah_l, r = ah_r, $fn = fn(ah_r));
          }
        }
      }
    }
  }
}

//------------------------------------------------------------------

module base_add() {
  carb_body();
  throttle_body();
}

module base_sub() {
  if (casting) {
  } else {
    carb_body_bore();
    air_holes();
  }
}

module base_model() {
  difference() {
    base_add();
    base_sub();
  }
}

//------------------------------------------------------------------

module model() {
  base_model();
}


model();

//------------------------------------------------------------------
