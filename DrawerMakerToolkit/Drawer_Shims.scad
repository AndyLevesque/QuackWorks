/* 
Drawer Shims
Design by Hands on Katie and OpenSCAD by BlackjackDuck (Andy) https://makerworld.com/en/@BlackjackDuck
This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2025-
    - Initial release

Credit to 
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord https://handsonkatie.com/
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

//Distance (mm) to shim vertically between drawer fronts
Drawer_Vertical_Spacing = 3;
//Distance (mm) to shim horizontally (if applicable)
Drawer_Horizontal_Spacing = 5;

/*[Hidden]*/
Total_Height = 60;
Shimming_Depth = 21;
Wall_Thickness = 1;
chamfer = 10;
separateDistance = 10;

//Text parameters
text_depth = 0.2;
text_size = 6;
font = "Monsterrat:style=Bold";

$fn = 50;

totalDepth = Shimming_Depth + Drawer_Horizontal_Spacing;

fwd(totalDepth + separateDistance)
DrawerShim();

DrawerShim(edge = true);


//EDGE main section on plate
module DrawerShim(edge = false)
diff()
cuboid([Total_Height, totalDepth, Wall_Thickness], chamfer = chamfer, edges=[FRONT+LEFT, FRONT+RIGHT]){
    //back
    attach(TOP, BOT, align=BACK, overlap = 0.01)
        cuboid([Total_Height, Drawer_Horizontal_Spacing, Shimming_Depth], chamfer = chamfer, edges=[TOP+RIGHT, TOP+LEFT])
            //text
            tag("remove")
            attach(BACK)
                text3d(str(Drawer_Horizontal_Spacing, "MM"), size=text_size, font=font, h=text_depth*2, atype="ycenter", anchor=CENTER);
    //shim
    if(edge)
    attach(TOP, BOT, overlap = 0.01)
        cuboid([Drawer_Vertical_Spacing, totalDepth, Shimming_Depth], chamfer = Drawer_Vertical_Spacing/3, edges=[FRONT+LEFT, FRONT+RIGHT])
        //text
            tag("remove")
            attach(LEFT)
                text3d(str(Drawer_Vertical_Spacing), size=text_size, font=font, h=text_depth*2, atype="ycenter", anchor=CENTER);
}