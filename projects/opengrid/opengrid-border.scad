/*
openGrid Border Generator
Complementary to openGrid by DavidD
OpenSCAD implementation for border creation
This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Creates border sections that snap into openGrid tiles with matching connector slots
and optional chamfer filling elements.

Change Log:
  - 2025-04-08
    - Initial release. Supports variable length border, optionally fills chamfers and allows straight borders and corner borders.
*/

include <BOSL2/std.scad>

/*[Border Configuration]*/
Full_or_Lite = "Lite"; // [Full, Lite]
// Length of border in cells
Border_width = 2;
// Border thickness (min 5.2mm)
Border_thickness = 5.2;
Chamfered_at_left_end = true;
Chamfered_at_right_end = true;
// Controls how the left end terminates
Left_end_is_corner = false;
// Controls how the right end terminates
Right_end_is_corner = false;
// [Profile Shape Configuration]
// Profile_Shape = "Rectangle"; // [Rectangle, Triangle, Quarter_Circle]


/*[Advanced Parameters]*/
Connector_Tolerance = 0.1;
Connector_Protrusion = 2.0;
Tile_Size = 28;

/* ========== Derived Parameters ========== */
Connector_Depth = Connector_Protrusion; // How far the cutout goes inward (Z axis)
Connector_Width = 3.9;                  // Width of connector cutout (match openGrid)
Connector_Height = 2.0;                 // Height of connector cutout
Full_Tile_Thickness = 6.8;
Lite_Tile_Thickness = 4;
Selected_Tile_Thickness = Full_or_Lite == "Full" ? Full_Tile_Thickness : Lite_Tile_Thickness;
// Thinner than 5.2mm and the hole for the connector pokes through.
// TODO: Could we have a connector printed into the part (positive instead of a negative)? Maybe a short connector since it's not weight bearing?
Selected_Border_Thickness = max(5.2, Border_thickness);
Chamfer_Triangle_Depth = Selected_Border_Thickness;
Border_Length_mm = Border_width * Tile_Size;
Chamfer_Triangle_Size = 4.2;
eps = 0.005;



module profile_shape() {
    // TODO: Allow profile to be configured. Support chamfer or fillet 
    // if (Profile_Shape == "Rectangle") {
        square([Selected_Border_Thickness, Selected_Tile_Thickness], center = false);
    /*} else if (Profile_Shape == "Triangle") {
        polygon(points = [
            [0, 0], 
            [Selected_Border_Thickness, 0], 
            [0, Border_Base_Thickness]
        ]);
    } else if (Profile_Shape == "Quarter_Circle") {
        // Generate a quarter circle wedge
        arc_pts = arc(angle=90, r=Selected_Tile_Thickness, $fn=50);
        polygon(points = concat([[0, 0]], arc_pts, [[radius, 0]]));
    } else {
        echo("Invalid Profile_Shape. Falling back to square.");
        square([Selected_Border_Thickness, Selected_Tile_Thickness], center = false);
    }*/
}


/* ========== Main Border Generator ========== */
module border_stick() {
    leftBorderOverlap =  Left_end_is_corner ? Border_thickness : 0;
    rightBorderOverlap =  Right_end_is_corner ? Border_thickness : 0;
    extrudeLength = Border_Length_mm + leftBorderOverlap + rightBorderOverlap;
    difference() {
        union() {
            // Main body of the border
            translate([-1 * leftBorderOverlap, 0, 0])
                rotate([90, 0, 90])  // Rotate so extrusion goes along X
                    linear_extrude(height = extrudeLength)
                        profile_shape();
            // Left chamfer tooth
            if (Chamfered_at_left_end)
                chamfer_fill(true);

            // Right chamfer tooth
            if (Chamfered_at_right_end)
                chamfer_fill(false);
        };
        union() {
            up(Selected_Tile_Thickness / 2) {
                color("LightBlue")
                fwd(eps)
                    xcopies(spacing=Tile_Size, n=Border_width - 1, sp=Tile_Size)
                        zrot(90)
                        connector_cutout_delete_tool(anchor=LEFT);    
            }
            if (Left_end_is_corner)
                corner_cutout(true);
            if (Right_end_is_corner)
                corner_cutout(false);
        }
    }
}

/*
back(-tileSize * Board_Height / 2 - 0.005)
    xcopies(spacing=tileSize, l=Board_Width > 2 ? Board_Width * tileSize - tileSize * 2 : Board_Width * tileSize - tileSize - 1)
        zrot(90)
            connector_cutout_delete_tool(anchor=LEFT);
*/
    //BEGIN CUTOUT TOOL
    module connector_cutout_delete_tool(anchor = CENTER, spin = 0, orient = UP) {
        //Begin connector cutout profile
        connector_cutout_radius = 2.6;
        connector_cutout_dimple_radius = 2.7;
        connector_cutout_separation = 2.5;
        connector_cutout_height = 2.4;
        dimple_radius = 0.75 / 2;

        attachable(anchor, spin, orient, size=[connector_cutout_radius * 2 - 0.1, connector_cutout_radius * 2, connector_cutout_height]) {
            //connector cutout tool
            tag_scope()
                translate([-connector_cutout_radius + 0.05, 0, -connector_cutout_height / 2])
                    render()
                        half_of(RIGHT, s=connector_cutout_dimple_radius * 4)
                            linear_extrude(height=connector_cutout_height)
                                union() {
                                    left(0.1)
                                        diff() {
                                            $fn = 50;
                                            //primary round pieces
                                            hull()
                                                xcopies(spacing=connector_cutout_radius * 2)
                                                    circle(r=connector_cutout_radius);
                                            //inset clip
                                            tag("remove")
                                                right(connector_cutout_radius - connector_cutout_separation)
                                                    ycopies(spacing=(connector_cutout_radius + connector_cutout_separation) * 2)
                                                        circle(r=connector_cutout_dimple_radius);
                                            //dimple (ass) to force seam. Only needed for positive connector piece (not delete tool)
                                            //tag("remove")
                                            //right(connector_cutout_radius*2 + 0.45 )//move dimple in or out
                                            //    yflip_copy(offset=(dimple_radius+connector_cutout_radius)/2)//both sides of the dimpme
                                            //        rect([1,dimple_radius+connector_cutout_radius], rounding=[0,-connector_cutout_radius,-dimple_radius,0], $fn=32); //rect with rounding of inner flare and outer smoothing
                                        }
                                    //outward flare fillet for easier insertion
                                    rect([1, connector_cutout_separation * 2 - (connector_cutout_dimple_radius - connector_cutout_separation)], rounding=[0, -.25, -.25, 0], $fn=32, corner_flip=true, anchor=LEFT);
                                }
            children();
        }
    }
    //END CUTOUT TOOL

/* ========== Chamfer Filler Triangle ========== */
module chamfer_fill(left) {
    translate([left ? 0 : Border_Length_mm, 0, 0])
        linear_extrude(height = Selected_Tile_Thickness)
            polygon(points = [
                [0, 0],
                [left ? Chamfer_Triangle_Size : -1 * Chamfer_Triangle_Size, 0],
                [0, -1 * Chamfer_Triangle_Size]
            ]);
}

/* ========== Corner Cutout Triangle ========== */
module corner_cutout(left) {
    color("Purple")
    translate([left ? 0 : Border_Length_mm, 0, 0 - eps])
        linear_extrude(height = Selected_Tile_Thickness + eps + eps)
            polygon(points = [
                [(left ? -1 : 1) * (Border_thickness + eps), Border_thickness + eps],
                [(left ? -1 : 1) * (Border_thickness + eps), 0 - Border_thickness - eps],
                [(left ? 1 : -1) * (Border_thickness + eps), 0 - Border_thickness - eps]
            ]);
}

/* ========== Render ========== */
border_stick();
