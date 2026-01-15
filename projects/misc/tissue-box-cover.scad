/*Created by BlackjackDuck (Andy)

This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2025-: Initial Release

*/

include <BOSL2/std.scad>

/*[Style Options]*/
Opening_Style = "Rounded Fully"; //[Rounded Fully, Square, Rounded Square]
Rounded_Square_Rounding = 5;
Box_Style = "Chamfered"; //[Chamfered, Rounded, Square]

/*[Tissue Box Dimensions]*/
Box_Width_mm = 228;
Box_Depth_mm = 120;
Box_Height_mm = 53;

/*[Tissue Box Opening]*/
Opening_Width_mm = 166;
Opening_Depth_mm = 42;

/*[Advanced]*/
Wall_Thickness_mm = 1.8;

outsideWidth = Box_Width_mm+Wall_Thickness_mm*2;
outsideDepth = Box_Depth_mm + Wall_Thickness_mm*2;
outsideHeight = Box_Height_mm + Wall_Thickness_mm;
openingRounding = 
    Opening_Style == "Rounded Fully" ? Opening_Depth_mm/2 :
    Opening_Style == "Rounded Square" ? Rounded_Square_Rounding : 
    0;
chamfer = 
    Box_Style == "Chamfered" ? 1 : 0;
rounding = 
    Box_Style == "Rounded" ? 1 : 0;

diff(){
    cuboid([outsideWidth, outsideDepth, outsideHeight], chamfer = chamfer, rounding = rounding, except = BOT, anchor=TOP, orient=DOWN, $fn = 25){
        //box cutout
        attach(TOP, TOP, inside=true, shiftout=-Wall_Thickness_mm)
            cuboid([Box_Width_mm, Box_Depth_mm, Box_Height_mm+0.01]);
        //top slot
        attach(TOP, TOP, inside=true, shiftout=0.01)
            cuboid([Opening_Width_mm, Opening_Depth_mm, Wall_Thickness_mm+0.02], rounding = openingRounding, edges="Z");
    }
}
