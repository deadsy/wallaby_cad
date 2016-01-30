//------------------------------------------------------------------
/*

Wallaby Cylinder Head

No draft version intended for 3d printing and investment casting.

*/
//-----------------------------------------------------------------
// scaling

desired_scale = 1.25;
mm_per_inch = 25.4;
al_shrink = 1/0.98; // ~2%
pla_shrink = 1/0.998; //~0.2%

function scale(x) = x * desired_scale * mm_per_inch * al_shrink * pla_shrink;

//-----------------------------------------------------------------
// control the number of facets on cylinders

facet_epsilon = 0.01;
function facets(r) = 180 / acos(1 - (facet_epsilon / r));

// small tweak to avoid differencing artifacts
epsilon = 0.05;

//------------------------------------------------------------------
// rounded/filleted edges

module outset(d=1) {
  minkowski() {
    circle(r=d, $fn=facets(d));
    children(0);
  }
}

module inset(d=1) {
  render() inverse() outset(d=d) inverse() children(0);
}

module inverse() {
  difference() {
    square(1e5, center=true);
    children(0);
  }
}

module rounded(r=1) {
  outset(d=r) inset(d=r) children(0);
}

module filleted(r=1) {
  inset(d=r) render() outset(d=r) children(0);
}

//-----------------------------------------------------------------
// Lengths (at original scale in inches)

head_l = scale(4.30/1.25);
head_w = scale(2.33/1.25);
head_h = scale(7/8);
head_corner_r = scale((5/32)/1.25);

//-----------------------------------------------------------------

// return a 2D polygon for the outer head
module head_outer() {
  points = [
    [0,0],
    [head_l,0],
    [head_l,head_w]
  ];
  polygon(points=points);
}

head_outer();

//-----------------------------------------------------------------
