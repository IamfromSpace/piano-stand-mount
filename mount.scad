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
  clasp_screw_shaft_radius,
  clasp_screw_offset,
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

  module tube_clasp(has_arm) {
    difference() {
      union() {
        if (has_arm)
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

        translate([-outer_radius, 0, 0])
          cube([outer_radius*2, outer_radius, depth]);
        for (i = [-1,1]) {
          translate([i*(thickness + inner_radius + clasp_screw_shaft_radius), 0, depth/2])
            rotate([270, 0, 0])
              cylinder(outer_radius, thickness + clasp_screw_shaft_radius, thickness + clasp_screw_shaft_radius);
          if (!has_arm)
            translate([i*(thickness + inner_radius + clasp_screw_shaft_radius), outer_radius - thickness - clasp_screw_offset, depth/2])
              rotate([270, 0, 0]) {
                translate([0, 0, thickness])
                  cylinder(clasp_screw_offset, thickness + clasp_screw_shaft_radius + thickness, thickness + clasp_screw_shaft_radius + thickness);
                cylinder(thickness, thickness + clasp_screw_shaft_radius, thickness + clasp_screw_shaft_radius + thickness);
              }
        }
      }
      translate([0, 0, -$tolerance/2])
        cylinder(depth + $tolerance, true_inner_radius, true_inner_radius);
      for (i = [-1,1]) {
        translate([i * (inner_radius + thickness + clasp_screw_shaft_radius), 0, depth/2])
          rotate([-90, 0, 0])
            cylinder(outer_radius, clasp_screw_shaft_radius, clasp_screw_shaft_radius);
        if (!has_arm)
          translate([i * (inner_radius + thickness + clasp_screw_shaft_radius), outer_radius - thickness - clasp_screw_offset, depth/2])
            rotate([270, 0, 0]) {
              translate([0, 0, thickness])
                cylinder(clasp_screw_offset, clasp_screw_shaft_radius + thickness, clasp_screw_shaft_radius + thickness);
              cylinder(thickness, clasp_screw_shaft_radius, clasp_screw_shaft_radius + thickness);
            }
      }
    }
  }

  if (component == "ALL" || component == "TOP_TUBE")
    tube_clasp(true);

  if (component == "BOTTOM_TUBE")
    tube_clasp(false);

  if (component == "ALL")
    translate([0, -effective_explode, depth])
      rotate([180, 0, 0])
        tube_clasp(false);

}

mount(
  25,
  8/3,
  15,
  45,
  27.5,
  2.5,
  2.45,
  5,
  $fn=30,
  $tolerance=0.7
);
