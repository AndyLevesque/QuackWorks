/* 
Drawer Handle Aligner
Design by Hands on Katie and OpenSCAD by BlackjackDuck (Andy) https://makerworld.com/en/@BlackjackDuck
This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)


Change Log:
- 2025-
    - Initial release



Credit to 
    @David D on Printables for openGrid https://www.printables.com/@DavidD
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord https://handsonkatie.com/
    SnazzyGreenWarrior for Keyhole design, logic, and testing
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

//Distance (mm) between the two screw holes (on center)
Screw_Separation_Distance = 125;
//Height distance (mm) from the top of the drawer to the screw center
Screw_Distance_from_Drawer_Top = 50;


/*[Hidden]*/
Top_Lip_Depth = 20;
Depth_Past_Screws = 20;
screw_hole_side_buffer = 10;
plate_thickness = 3;
pencil_hole_size = 2;

$fn = 50;

total_width = Screw_Separation_Distance + screw_hole_side_buffer*2;
total_depth = Screw_Distance_from_Drawer_Top + Depth_Past_Screws + plate_thickness;
center_finder_height = total_depth - screw_hole_side_buffer*2;
base_plate_radius = Depth_Past_Screws;


//main section on plate
diff()
cuboid([total_width, total_depth, plate_thickness], rounding = base_plate_radius, edges = [FRONT+LEFT, FRONT+RIGHT]){
    //Top Lip
    attach(TOP, BOT, align = BACK, overlap = 0.01)
        cuboid([total_width, plate_thickness, Top_Lip_Depth], rounding = Top_Lip_Depth / 2, edges = [TOP+LEFT, TOP+RIGHT]);
    //pencil holes for screws
    #attach(TOP, TOP, inside = true, shiftout = 0.01, align = BACK) 
        fwd(-pencil_hole_size/2 + plate_thickness + Screw_Distance_from_Drawer_Top)
        xcopies(spacing = Screw_Separation_Distance)
            cyl(d1 = pencil_hole_size * 3, d2 = pencil_hole_size, h = plate_thickness+0.02);
    //center finder
    attach(TOP, TOP, inside = true, shiftout = 0.01)
        cuboid([pencil_hole_size, center_finder_height, plate_thickness + 0.02], chamfer = - plate_thickness, edges=[BOT]);
}