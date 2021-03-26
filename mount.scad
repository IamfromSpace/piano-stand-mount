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
) {
  outer_radius = thickness + inner_radius;
  true_inner_radius = inner_radius + $tolerance/2;

  module tube_clasp() {
    difference() {
      translate([-outer_radius, 0, 0])
        cube([outer_radius*2, outer_radius, depth]);
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
    tube_clasp();

  if (component == "ALL")
    translate([0, 0, depth])
      rotate([180, 0, 0])
        tube_clasp();

  if (component == "ALL" || component == "TOP_TUBE") {
    translate([outer_radius,outer_radius,0])
      mirror([0,1,0])
        box_arm(thickness, screw_distance - outer_radius, depth);
  }

  module full_screw_arm() {
    screw_arm(thickness, depth + screw_offset, depth + $tolerance, depth, screw_radius, 0.1*thickness);
  }

  if (component == "ALL") {
    translate([screw_distance - depth/2, inner_radius - thickness, 0])
      mirror([0,1,0])
        rotate([90,0,0])
          full_screw_arm();
  } else if (component == "SCREW_ARM") {
    full_screw_arm();
  }
}

module box_arm(
  thickness,
  length, // start of the arm to the center of the box
  box_width,
) {
  cube([length, thickness - $tolerance/2, box_width]);

  difference() {
    translate([length - box_width/2 - thickness, 0, 0])
      cube([box_width + thickness*2, thickness*3, box_width]);
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
      translate([0, -2*bump_height, 0])
        cube([width, 2*bump_height, thickness]);
      translate([0,-bump_height/2,0])
        cylinder(thickness, bump_height, bump_height);
      translate([width,-bump_height/2,0])
        cylinder(thickness, bump_height, bump_height);
      translate([0, box_length, 0])
        cube([width, length-box_length, thickness*2]);
      translate([width/2, length, 0])
        cylinder(thickness*2, width/2, width/2);
    }
    translate([width/2, length, -$tolerance/2])
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
