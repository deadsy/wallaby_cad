#! /usr/bin/python

import math

_scale = 1.25

_mm_per_inch = 25.4
_mm_per_cm = 10.0

mm3_per_in3 = math.pow(_mm_per_inch, 3.0)
mm3_per_cm3 =  math.pow(_mm_per_cm, 3.0)
cm3_per_in3 = mm3_per_in3 / mm3_per_cm3

_piston_diameter = 1.0 * _scale
_piston_stroke = 1.125 * _scale
_num_cylinders = 2.0

def main():

    piston_radius = _piston_diameter / 2.0
    piston_vol = math.pi * piston_radius * piston_radius * _piston_stroke

    total_vol = piston_vol * _num_cylinders
    print('%f total volume (ci)' % total_vol)
    print('%f total volume (cc)' % (total_vol * cm3_per_in3))

main()

