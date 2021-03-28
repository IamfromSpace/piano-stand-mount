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
  component = "ALL",
  explode = 30, // only valid when "ALL" is selected
) {
  outer_radius = thickness + inner_radius;
  true_inner_radius = inner_radius + $tolerance/2;
  effective_explode = component == "ALL"
    ? explode
    : 0;

  module tube_clasp(is_rounded) {
    difference() {
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
      translate([0, 0, -$tolerance/2])
        cylinder(depth + $tolerance, true_inner_radius, true_inner_radius);
      for (i = [0:1]) {
        translate([(i*2-1) * (pin_radius + thickness + inner_radius + $tolerance), 0, depth/2-$tolerance/2])
          cylinder(depth/2 + $tolerance, pin_radius + thickness + $tolerance/2, pin_radius + thickness + $tolerance/2);
      }
    }

    for (i = [0:1]) {
      translate([(i*2-1) * (pin_radius + thickness + inner_radius + $tolerance), 0, 0])
        difference() {
          cylinder(depth/2 - $tolerance/2, pin_radius + thickness, pin_radius + thickness);
          translate([0,0,-$tolerance/2])
            cylinder(depth/2 + $tolerance, pin_radius + $tolerance/2, pin_radius + $tolerance/2);
        }
    }
  }

  if (component == "ALL" || component == "TOP_TUBE" || component == "BOTTOM_TUBE")
    tube_clasp(component == "BOTTOM_TUBE");

  if (component == "ALL")
    translate([0, 0, depth + effective_explode])
      rotate([180, 0, 0])
        tube_clasp(true);

  if (component == "ALL" || component == "TOP_TUBE") {
    translate([outer_radius,outer_radius,0])
      mirror([0,1,0])
        box_arm(thickness, screw_distance - outer_radius, depth);
  }

  module full_screw_arm() {
    screw_arm(thickness, depth + screw_offset, depth + $tolerance, depth, screw_radius, 0.1*thickness);
  }

  if (component == "ALL") {
    translate([screw_distance - depth/2, inner_radius - thickness, effective_explode])
      mirror([0,1,0])
        rotate([90,0,0])
          full_screw_arm();
  } else if (component == "SCREW_ARM") {
    full_screw_arm();
  }

  module full_screw_arm_pin() {
    square_pin(thickness - $tolerance, depth - 2*thickness - $tolerance, 2*thickness);
  }

  if (component == "ALL")
    translate([screw_distance - depth/2 + $tolerance, outer_radius + effective_explode, -$tolerance/2])
      rotate([180, 0, 0])
        full_screw_arm_pin();

  if (component == "SCREW_ARM_PIN")
    full_screw_arm_pin();
}

module box_arm(
  thickness,
  length, // start of the arm to the center of the box
  box_width,
) {
  difference() {
    cube([length + box_width/2 + thickness, thickness*3, box_width]);
    translate([length - box_width/2 - $tolerance/2, thickness - $tolerance/2, -$tolerance/2])
      cube([box_width + $tolerance, thickness + $tolerance, box_width+$tolerance]);
  }
}

module screw_arm(
  thickness,
  length, // from the inside of the lip to the center of the screw hole
  box_length, // How much the box will cover
  width,
  screw_radius,
  bump_height
) {
  difference() {
    union() {
      cube([width, length, thickness]);
      translate([0, -2*thickness, 0])
        cube([width, 2*thickness, thickness]);
      translate([0, box_length, 0])
        cube([width, length-box_length, thickness*2]);
      translate([width/2, length, 0])
        cylinder(thickness*2, width/2, width/2);
    }
    translate([thickness, -thickness, -$tolerance/2])
      cube([width - 2*thickness, thickness, thickness + $tolerance]);
    translate([width/2, length, -$tolerance/2])
      cylinder(2 * thickness + $tolerance, screw_radius + $tolerance/2, screw_radius + $tolerance/2);
  }
}

module square_pin(
  thickness,
  width,
  depth
) {
  cube([width + 2*thickness, thickness, thickness,]);
  translate([thickness, 0, 0])
    cube([width, depth + thickness, thickness]);
}

mount(
  15,
  25,
  8/3,
  3,
  45,
  27.5,
  2,
  $fn=30,
  $tolerance=0.6
);
