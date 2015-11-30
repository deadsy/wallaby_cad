//------------------------------------------------------------------


//------------------------------------------------------------------

casting = false;

//------------------------------------------------------------------
// tweak a length to avoid rendering issues when diff-ed surfaces
// align with each other.

tweak = 0.001;

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

hh_r = (1/16)/2;
hh_l = (1/2);
hh_pcr = (13/16)/2;
head_z = 3 + (1/8);

module head_holes() {
  for (theta = [30,90,150,210,270,330]) {
    rotate([0,0,theta]) {
      translate([hh_pcr,0,-hh_l/2 + head_z]) {
        cylinder(h = hh_l, r = hh_r, $fn = fn(hh_r));
      }
    }
  }
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

tbb_r = (1/2)/2;
tbb_l = 5/8;
tbb_z = 1 + (1/2);

module tb_bore() {
  translate([0,tb_w/2 + tweak,tbb_z]) {
    rotate([90,0,0]) {
      cylinder(h = tbb_l, r = tbb_r, $fn = fn(tbb_r));
    }
  }
}

tbh_r = (1/8)/2;
tbh_l = 2;

module tb_holes() {
  for (ofs = [-(3/8), 0, (3/8)]) {
    translate([ofs,0,tbb_z]) {
      rotate([90,0,0]) {
        translate([0,0,-tbh_l/2]) {
          cylinder(h = tbh_l, r = tbh_r, $fn = fn(tbh_r));
        }
      }
    }
  }
}

tp_h = 1;

module throttle_plate() {
  translate([0,-tb_w/2 + tweak,tbb_z]) {
    rotate([90,0,0]) {
      intersection() {
        translate([0,0,-tp_h/2]) {
          linear_extrude(height=tp_h)
          import(file = "carburetor.dxf", layer = "throttle_plate_pattern",  $fn = fn(0.1));
        }
        rotate_extrude($fn = 64)
        import(file = "carburetor.dxf", layer = "throttle_plate_profile",  $fn = fn(0.1));
      }
    }
  }
}

//------------------------------------------------------------------
// airholes

aht_r = (5/32)/2;
aht_l = 2;
aht_z = (3.125 - (7/16));

module air_holes_top() {
  translate([0,0,aht_z]) {
    for (theta= [0,60,120]) {
      rotate([0,0,theta]) {
        rotate([90,0,0]) {
          translate([0,0,-aht_l/2]) {
            cylinder(h = aht_l, r = aht_r, $fn = fn(aht_r));
          }
        }
      }
    }
  }
}

ahb_r = (1/8)/2;
ahb_l = 2;
ahb_z = (5/16);

module air_holes_bottom() {
  translate([0,0,ahb_z]) {
    for (theta= [0,90]) {
      rotate([0,0,theta]) {
        rotate([90,0,0]) {
          translate([0,0,-ahb_l/2]) {
            cylinder(h = ahb_l, r = ahb_r, $fn = fn(ahb_r));
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
  throttle_plate();
}

module base_sub() {
  if (casting) {
  } else {
    carb_body_bore();
    air_holes_top();
    air_holes_bottom();
    tb_bore();
    tb_holes();
    head_holes();
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
