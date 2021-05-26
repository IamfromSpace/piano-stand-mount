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
  top_bias,
  slot_width,
  slot_depth,
  rail_width,
  rail_depth,
  component = "ALL",
  explode, // only valid when "ALL" is selected
) {
  outer_radius = thickness + inner_radius;
  true_inner_radius = inner_radius + $tolerance/2;
  effective_explode = component == "ALL"
    ? explode == undef
      ? depth + thickness * 2 + 5
      : explode
    : 0;
  bottom_bias = 1 - top_bias;

  module tube_clasp(bias, is_rounded) {
    opposite_bias = 1 - bias;
    difference() {
      union() {
        if (is_rounded) {
          intersection() {
            cylinder(depth, outer_radius, outer_radius);
            translate([-outer_radius, 0, 0])
              cube([outer_radius*2, outer_radius, depth]);
          }
        } else {
          translate([-outer_radius, 0, 0])
            cube([outer_radius*2, outer_radius, depth]);
        }
        translate([-outer_radius - 2*thickness, 0, 0])
          cube([4*thickness + outer_radius*2, outer_radius - 4*thickness - $tolerance, depth/2 + 3*thickness]);
      }
      translate([0, 0, -$tolerance/2])
        cylinder(depth + $tolerance, true_inner_radius, true_inner_radius);
      for (i = [0:1])
        translate([(i*2-1) * (outer_radius + (thickness + $tolerance)/2) - (thickness + $tolerance)/2, 0, (depth - 4*thickness - $tolerance)/2])
          cube([thickness + $tolerance, outer_radius - 4*thickness - $tolerance, 4*thickness + $tolerance]);
    }
  }

  if (component == "ALL" || component == "TOP_TUBE")
    tube_clasp(top_bias, false);

  if (component == "BOTTOM_TUBE")
    tube_clasp(bottom_bias, true);

  if (component == "ALL")
    translate([0, 0, depth + effective_explode])
      rotate([180, 0, 0])
        tube_clasp(bottom_bias, true);

  module cantilever_full() {
    simple_cantilever_set(2*outer_radius - 8*thickness - $tolerance, thickness - $tolerance, thickness, 2*thickness/3, 2*thickness - $tolerance);
  }

  if (component == "ALL")
    for (i = [0:1])
      translate([(2*i-1)*-outer_radius, outer_radius - 4*thickness - $tolerance/2 - effective_explode, depth/2 + 2*thickness -$tolerance/2])
        mirror([i, 0, 0])
          rotate([0, 90, 0])
            rotate([0, 0, -90])
              cantilever_full();

  if (component == "CANTILEVER")
    cantilever_full();

  translate([outer_radius, true_inner_radius+thickness-$tolerance/2, screw_offset + depth])
  rotate([90, 0, 0])
  difference() {
    union() {
      intersection() {
        translate([0, -screw_offset-depth, 0])
          cube([screw_distance + depth/2 - outer_radius, screw_offset + depth, 2*thickness - $tolerance/2]);
        difference() {
          scale([screw_distance + depth/2 - outer_radius, screw_offset + depth, 1])
            cylinder(2*thickness - $tolerance/2, 1, 1);
          translate([0, 0, -$tolerance/4])
            scale([screw_distance - depth/2 - outer_radius, screw_offset, 1])
              cylinder(2*thickness, 1, 1);
        }
      }
      translate([screw_distance - outer_radius, 0, 0])
        cylinder(2*thickness - $tolerance/2, depth/2, depth/2);
    }
    translate([screw_distance - outer_radius, 0, -$tolerance/2])
      cylinder(2 * thickness + $tolerance, screw_radius + $tolerance/2, screw_radius + $tolerance/2);
  }
}

module simple_cantilever_arm(
  depth, // how deep the arm will go
  width, // how far the cantilever shape will be projected
  thickness, // how thick the arm will be in the direction of deflection
  overhang // how deep the grip will go
) {
  cube([depth, thickness, width]);
  difference() {
    translate([0, (thickness - overhang)/2, 0])
      cylinder(width, (overhang + thickness)/2, (overhang + thickness)/2);
    translate([0, -overhang, -$tolerance/2])
      cube([depth, overhang, width + $tolerance]);
  }
}

module simple_cantilever_set(
  depth, // how deep the arm will go
  width, // how far the cantilever shape will be projected
  thickness, // how thick the arm will be in the direction of deflection
  overhang, // how deep the grip will go
  spacing, // gap between the two levers
) {
  translate([depth, -thickness])
    cube([thickness, 4*thickness + spacing, width + thickness]);
  simple_cantilever_arm(depth,width,thickness,overhang);
  translate([0, 2*thickness + spacing, 0])
    mirror([0,1,0])
      simple_cantilever_arm(depth,width,thickness,overhang);
}


mount(
  25,
  8/3,
  15,
  45,
  27.5,
  2.5,
  1/2,
  22.5,
  1.25,
  1.25,
  1.25,
  $fn=30,
  $tolerance=0.7
);
