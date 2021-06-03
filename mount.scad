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
  clasp_screw_minor_radius,
  clasp_screw_major_radius,
  clasp_screw_inset,
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

          // Our cutout is at a 45deg so that we can still print flat.  We
          // rotate a cube and d is the length of the side so that the cutout
          // will be a half a tolerance away from the corner of the slot.
          d = sqrt(2) * (rail_width + rail_depth) + $tolerance/2;
          for (i = [-1,1])
            translate([screw_distance/2, i*(slot_width/2 + rail_width/2), 0])
              rotate([45,0,0])
                cube([screw_distance + $tolerance, d, d], center = true);

        }

        translate([-outer_radius, 0, 0])
          cube([outer_radius*2, outer_radius, depth]);

        for (i = [-1,1]) {
          translate([i*(thickness + inner_radius + clasp_screw_major_radius), 0, depth/2])
            rotate([270, 0, 0])
              cylinder(outer_radius, thickness + clasp_screw_major_radius, thickness + clasp_screw_major_radius);
          if (!has_arm)
            translate([i*(thickness + inner_radius + clasp_screw_major_radius), outer_radius - thickness - clasp_screw_inset, depth/2])
              rotate([270, 0, 0]) {
                translate([0, 0, thickness])
                  cylinder(clasp_screw_inset, thickness + clasp_screw_major_radius + thickness, thickness + clasp_screw_major_radius + thickness);
                cylinder(thickness, thickness + clasp_screw_major_radius, thickness + clasp_screw_major_radius + thickness);
              }
        }
      }
      translate([0, 0, -$tolerance/2])
        cylinder(depth + $tolerance, true_inner_radius, true_inner_radius);
      for (i = [-1,1]) {
        clasp_screw_hole_radius = has_arm
          ? clasp_screw_minor_radius
          : clasp_screw_major_radius;

        translate([i * (inner_radius + thickness + clasp_screw_major_radius), 0, depth/2])
          rotate([-90, 0, 0])
            cylinder(outer_radius, clasp_screw_hole_radius, clasp_screw_hole_radius);

        if (!has_arm)
          translate([i * (inner_radius + thickness + clasp_screw_major_radius), outer_radius - thickness - clasp_screw_inset, depth/2])
            rotate([270, 0, 0]) {
              translate([0, 0, thickness])
                cylinder(clasp_screw_inset, clasp_screw_major_radius + thickness, clasp_screw_major_radius + thickness);
              cylinder(thickness, clasp_screw_major_radius, clasp_screw_major_radius + thickness);
            }
      }
    }
  }

  module slot_spacer() {
    difference() {
      cylinder(slot_depth, (slot_width - $tolerance)/2, (slot_width - $tolerance)/2);
      cylinder(slot_depth, screw_radius + $tolerance/2, screw_radius + $tolerance/2);
    }
  }

  if (component == "ALL")
    translate([screw_distance, slot_depth + outer_radius + effective_explode, screw_offset + depth])
      rotate([90, 0, 0])
        slot_spacer();

  if (component == "SLOT_SPACER")
    slot_spacer();

  if (component == "ALL" || component == "TOP_TUBE")
    tube_clasp(true);

  if (component == "BOTTOM_TUBE")
    tube_clasp(false);

  if (component == "ALL")
    translate([0, -effective_explode, depth])
      rotate([180, 0, 0])
        tube_clasp(false);

}



module sided_mount(
  depth,
  thickness,
  inner_radius,
  screw_radius,
  clasp_screw_minor_radius,
  clasp_screw_major_radius,
  clasp_screw_inset,
  slot_width,
  slot_depth,
  rail_width,
  rail_depth,
  component = "LEFT",
  explode
) {
  is_left =
    component == "LEFT_TOP_TUBE" ||
    component == "LEFT_BOTTOM_TUBE" ||
    component == "LEFT_SLOT_SPACER" ||
    component == "LEFT";

  subcomponent =
    component == "LEFT" || component == "RIGHT"
      ? "ALL" :
    component == "LEFT_TOP_TUBE" || component == "RIGHT_TOP_TUBE"
      ?  "TOP_TUBE" :
    component == "LEFT_BOTTOM_TUBE" || component == "RIGHT_BOTTOM_TUBE"
      ? "BOTTOM_TUBE" :
    component == "LEFT_SLOT_SPACER" || component == "RIGHT_SLOT_SPACER"
      ? "SLOT_SPACER" :
    undef;

  mount(
    depth,
    thickness,
    inner_radius,
    is_left ? 96 : 45,
    is_left ? 54 : 27.5,
    screw_radius,
    clasp_screw_minor_radius,
    clasp_screw_major_radius,
    clasp_screw_inset,
    slot_width,
    slot_depth,
    rail_width,
    rail_depth,
    subcomponent,
    explode
  );
}

sided_mount(
  25,
  8/3,
  15,
  2.5,
  2.2, // TODO: Ideally this is affected by $tolerance in a reliable way??
  2.55,
  5,
  22.25,
  1.25,
  1.25,
  1.25,
  $fn=30,
  $tolerance=0.7
);
