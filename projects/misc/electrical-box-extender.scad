/*Created by BlackjackDuck (Andy)

This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2025-03-26: Initial Release
- 2025-06-21: Offset screw option

*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>



Gang_Count = 2; //[1:1:4]
//Depth of the box in mm
Depth_in_mm = 25;
//Thickness of the extender box walls (in mm)
Wall_Thickness = 3;

//Width of the post that the screw will go through (in mm)
Mount_Post_Width = 12;

//Height of the box in inches
Box_Height_in_Inches = 3.75;

/*[Overrides]*/
//Override the width of the box in inches. 0 will use the default values.
Box_Width_in_Inches_Override = 0;
Screw_Mount_Height_Distance_Inches = 3+9/32;
Screw_Mount_Lateral_Distance_Inches = 1+13/16;
Screw_Hole_Size_in_mm = 3.25; //0.01
//Shift (mm) screw mounts left (negative) or right (positive)
Screw_Mount_Lateral_Offset = 0;

Screw_Mount_Inset = inches_to_mm(Box_Height_in_Inches-Screw_Mount_Height_Distance_Inches)/2;


Box_Width_in_Inches = 
    Box_Width_in_Inches_Override != 0 ? Box_Width_in_Inches_Override
    : Gang_Count == 1 ? 2.25
    : Gang_Count == 2 ? 3.75
    : Gang_Count == 3 ? 5.75
    : Gang_Count == 4 ? 7.6
    : 0; 

/*[Hidden]*/
$fn=25;

function inches_to_mm(inches) = inches * 25.4;

union(){
    //outer box
    rect_tube(size=[inches_to_mm(Box_Width_in_Inches),inches_to_mm(Box_Height_in_Inches)], wall = Wall_Thickness, h=Depth_in_mm, rounding=Wall_Thickness, irounding=Wall_Thickness/2);

    //screw mounts
    right(Screw_Mount_Lateral_Offset)
    xcopies(spacing = inches_to_mm(Screw_Mount_Lateral_Distance_Inches), n=Gang_Count)
        ycopies(spacing=inches_to_mm(Screw_Mount_Height_Distance_Inches)+0.02)
            union(){
                diff(){
                cyl(d=Mount_Post_Width, h=Depth_in_mm, anchor=BOT);    
                cuboid([Mount_Post_Width, Screw_Mount_Inset-1, Depth_in_mm], anchor=$idx==0 ? BOT+BACK : BOT+FRONT);
                tag("remove")down(0.01)cyl(d=Screw_Hole_Size_in_mm, h=Depth_in_mm+0.02, anchor=BOT);
                }
            }
}