#! /usr/bin/python

import math
import numpy as np
import matplotlib.pyplot as plt

_scale = 1.25

_mm_per_inch = 25.4
_mm_per_cm = 10.0

mm3_per_in3 = math.pow(_mm_per_inch, 3.0)
mm3_per_cm3 =  math.pow(_mm_per_cm, 3.0)
cm3_per_in3 = mm3_per_in3 / mm3_per_cm3

_piston_diameter = 1.0 * _scale
_piston_top = 0.5 * _scale # gudgeon pin center line to top of piston
_conrod_length = 2.25 * _scale
_crank_throw = 0.5625 * _scale

_piston_stroke = 2 * _crank_throw
_num_cylinders = 2

_steps = 1024

def piston_position(theta):
  """return the distance from the crank centerline to the top of the piston"""
  s = _crank_throw * math.cos(theta) + math.sqrt(math.pow(_conrod_length,2.0) - math.pow(_crank_throw * math.sin(theta), 2.0))
  return s + _piston_top

def main():

  piston_radius = _piston_diameter / 2.0
  piston_vol = math.pi * piston_radius * piston_radius * _piston_stroke

  total_vol = piston_vol * _num_cylinders
  print('%f total volume (ci)' % total_vol)
  print('%f total volume (cc)' % (total_vol * cm3_per_in3))

  x = np.linspace(0, 4.0 * math.pi, num = _steps)
  y = [piston_position(theta) for theta in x]

  plt.plot(x, y)
  plt.grid(True)
  plt.show()


main()

