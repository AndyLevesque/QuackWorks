/*Created by BlackjackDuck (Andy)

This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2025-05-04: Initial Release

*/

include <BOSL2/std.scad>

/*[Badge Section Parameters]*/
Outer_Diameter = 70;
Border_Width = 3;
Total_Thickness = 5;
Recess_Depth = 3;

/*[Key Ring Section Parameters]*/
Key_Ring_Outer_Diameter = 15;
Key_Ring_Width = 3;
Key_Ring_Thickness = 3;

$fn= 120;

//Outer cylinder
diff()
cyl(d= Outer_Diameter, h = Total_Thickness, anchor=BOT){
    attach(TOP, TOP, inside=true, shiftout=0.01)
        cyl(d=Outer_Diameter - Border_Width*2, h = Recess_Depth);
    //Key Ring
    attach(BACK, FRONT, align=BOT, overlap=min(Key_Ring_Width, Border_Width))
        cyl(d= Key_Ring_Outer_Diameter, h=Key_Ring_Thickness)
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cyl(d= Key_Ring_Outer_Diameter - Key_Ring_Width*2, h=Key_Ring_Thickness+0.02);
};