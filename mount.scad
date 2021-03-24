/**
 * Copyright 2021 Nathan Fairhurst.
 */
module mount(
  depth,
  thickness,
  inner_radius,
  screw_distance,
  screw_offset,
  screw_radius,
) {
  outer_radius = thickness + inner_radius;

  difference() {
    union() {
      cylinder(depth, outer_radius-$tolerance/2, outer_radius-$tolerance/2);
      translate([-outer_radius, 0, 0])
        cube([outer_radius*2, outer_radius, depth]);
    }
    translate([0, 0, -$tolerance/2])
      cylinder(depth + $tolerance, inner_radius+$tolerance/2, inner_radius+$tolerance/2);
  }

  translate([0, inner_radius, 0])
    cube([screw_distance - depth/2, thickness, depth]);

  translate([screw_distance - depth/2, inner_radius, 0])
    cube([depth, thickness, depth]);


  translate([screw_distance - depth/2, thickness + inner_radius, depth])
    rotate([90,0,0])
      difference() {
        union() {
          cube([depth, screw_offset, thickness]);
          translate([depth/2, screw_offset, 0])
            cylinder(thickness, depth/2, depth/2);
        }
        translate([depth/2, screw_offset, -$tolerance/2])
          cylinder(thickness + $tolerance, screw_radius + $tolerance/2, screw_radius + $tolerance/2);
      }
}

mount(
  20,
  4,
  15,
  50,
  20,
  2,
  $fn=30,
  $tolerance=0.01
);
