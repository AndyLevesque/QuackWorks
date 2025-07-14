/* 
Drawer Spacer
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

//Thickness (mm) of the drawer
Drawer_Thickness = 19;
//Thickness (mm) of the spacer (top of drawer wall to top of spacer)
Spacer_Thickness = 4;


/*[Hidden]*/
wallThickness = 3;
spacerDepth = 50;
spacerWallHeight = 16;

$fn = 50;

//base
cuboid([Drawer_Thickness + wallThickness*2, spacerDepth, Spacer_Thickness]){
    //walls
    attach(TOP, BOT, align=[LEFT, RIGHT], overlap=0.01)
        cuboid([wallThickness, spacerDepth, spacerWallHeight], chamfer = wallThickness/3, edges = ($idx == 1 ? TOP+LEFT : TOP+RIGHT));
}


