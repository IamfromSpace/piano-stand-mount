/**
 * Copyright 2021 Nathan Fairhurst.
 */
module mount(
  depth,
  thickness,
  inner_radius,
  pin_radius,
  screw_distance,
  screw_offset,
  screw_radius,
) {
  outer_radius = thickness + inner_radius;
  true_inner_radius = inner_radius + $tolerance/2;

  difference() {
    translate([-outer_radius, 0, 0])
      cube([outer_radius*2, outer_radius, depth]);
    translate([0, 0, -$tolerance/2])
      cylinder(depth + $tolerance, true_inner_radius, true_inner_radius);
    for (i = [0:1]) {
      translate([(i*2-1) * (pin_radius + thickness + inner_radius + $tolerance), 0, depth/2])
        cylinder((depth + $tolerance)/2, pin_radius + thickness + $tolerance/2, pin_radius + thickness + $tolerance/2);
    }
  }

  for (i = [0:1]) {
    translate([(i*2-1) * (pin_radius + thickness + inner_radius + $tolerance), 0, 0])
      difference() {
        cylinder(depth/2, pin_radius + thickness, pin_radius + thickness);
        translate([0,0,-$tolerance/2])
          cylinder(depth/2 + $tolerance, pin_radius + $tolerance/2, pin_radius + $tolerance/2);
      }
  }

  translate([0, true_inner_radius, 0])
    cube([screw_distance - depth/2, thickness - $tolerance/2, depth]);

  difference() {
    translate([screw_distance - depth/2 - thickness, inner_radius-thickness*2, 0])
      cube([depth + thickness*2, thickness*3, depth]);
    translate([screw_distance - depth/2 - $tolerance/2, inner_radius - thickness - $tolerance/2, -$tolerance/2])
      cube([depth + $tolerance, thickness + $tolerance, depth+$tolerance]);
  }

  translate([screw_distance - depth/2, thickness + inner_radius, depth])
    rotate([90,0,0])
      difference() {
        union() {
          translate([0, 0, thickness])
            cube([depth, screw_offset, thickness]);
          translate([depth/2, screw_offset, 0])
            cylinder(thickness*2, depth/2, depth/2);
        }
        translate([depth/2, screw_offset, -$tolerance/2])
          cylinder(2 * thickness + $tolerance, screw_radius + $tolerance/2, screw_radius + $tolerance/2);
      }
}

mount(
  20,
  4,
  15,
  3,
  50,
  20,
  2,
  $fn=30,
  $tolerance=0.6
);
