/* 
Drawer Slide Mounting Adapter
OpenSCAD by BlackjackDuck (Andy)

This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2026-01-02 Initial Release

About: This adapter serves as a spacer and adapter between a cabinet and drawer slides. 
This allows you do adapt drawer slides to existing mounting holes, mount drawers/shelves not as wide as the opening, or address other incompatibilities between your cabinet, slide, and the material to be mounted.

*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/joiners.scad>
include <BOSL2/threading.scad>


/*[Hidden]*/
//Removing until I can take the time to put this back in everywhere
Input_is_Inches_or_mm = "mm"; //[Inches, mm]

/*[Primary Parameters]*/
//Total length from front to back
Total_Length = 352; 
//Total height from top to bottom
Total_Height = 55;
Slide_Height = 46; 
//How much distance to you want to fill inward. Cannot be zero. This number will be the thickness between the slide and the cabinet.
Total_Gap_to_Fill_Excluding_Slides = 21;

/*[Cabinet Mount Points]*/
//Distance from the back of the adapter to the center of the first mounting hole in the cabinet. Enter 0 to disable.
Hole_1_Distance_from_Back = 76;
//Distance from the back of the adapter to the center of the first mounting hole in the cabinet. Enter 0 to disable.
Hole_2_Distance_from_Back = 300;
//Distance from the back of the adapter to the center of the first mounting hole in the cabinet. Enter 0 to disable.
Hole_3_Distance_from_Back = 332;

/*[Slide Mount Points]*/
//Distance from the back of the adapter to the center of the first mounting hole in the slide. Enter 0 to disable.
Hole_1_Slide_Distance_from_Back = 27;
Hole_1_Slide_Vertical_Separation = 20;
//Distance from the back of the adapter to the center of the first mounting hole in the slide. Enter 0 to disable.
Hole_2_Slide_Distance_from_Back = 157;
//Distance from the back of the adapter to the center of the first mounting hole in the slide. Enter 0 to disable.
Hole_3_Slide_Distance_from_Back = 317;
//Vertically adjust slide position
Slide_Vertical_Adjustment = 0; //0.1


/*[Slide Recess]*/
Recess_Slide = true;
Slide_Thickness = 12;

/*[Other Options]*/
Edge_Rounding = 0.5;
//If wanting to cut into two parts for printing on smaller printers (or save filament). Recommend you recess the slide to prevent rotation.
Cut_Middle = false;
//Enter the distance from the back to start the cut. Be sure this cut does not remove any mounting points.
Cut_Start_From_Back = 170;
//Total distance to cut
Cut_Distance = 110;
Show_Slide = false;

//Generate an alignment template for fast printing to verify parameters
Alignment_Template = false;

/*[Mounting Hole Parameters]*/
Cabinet_Screw_Diameter = 5;
Cabinet_Screw_Recess_Diameter = 9;
Cabinet_Screw_Support_Thickness = 2;

Slide_Screw_Diameter = 2.6;



//Make conversions for inches vs mm
totalLengthAdjusted = inches_to_mm(Total_Length);
totalHeightAdjusted = inches_to_mm(Total_Height);
totalThicknessAdjusted = Alignment_Template ? 1 : inches_to_mm(Total_Gap_to_Fill_Excluding_Slides/2) + (Recess_Slide ? Slide_Thickness : 0);
slideHeightAdjusted = inches_to_mm(Slide_Height);
slideThicknessAdjusted = Alignment_Template ? 0.4 : inches_to_mm(Slide_Thickness);

diff()
//main piece
cuboid([totalThicknessAdjusted, totalLengthAdjusted, totalHeightAdjusted], rounding = Edge_Rounding, except_edges = LEFT, $fn = 20, orient=LEFT, anchor=LEFT){
    //slide recess (if enabled)
    if(Recess_Slide) 
        up(Slide_Vertical_Adjustment)
        attach(RIGHT, RIGHT, inside = true, shiftout = 0.01) 
            Slide();
    //additional backer that follows the slide to ensure the slide always has support
    tag_scope()
        up(Slide_Vertical_Adjustment)
        attach(RIGHT, RIGHT, inside = true) 
            cuboid([totalThicknessAdjusted, totalLengthAdjusted, slideHeightAdjusted],rounding = Edge_Rounding, except_edges = LEFT, $fn = 20,);
    if(Show_Slide) 
        up(Slide_Vertical_Adjustment)
        attach(RIGHT, RIGHT, inside = Recess_Slide ? true : false, shiftout = 0.01) 
            #Slide();
    //Cabinet Mounting Holes
    tag("remove")
    attach(LEFT, BOT, align=BACK, inside = true, shiftout=0.01){
        //Hole 1
        if(Hole_1_Distance_from_Back != 0)
        left(Hole_1_Distance_from_Back - Cabinet_Screw_Diameter/2)
            Cabinet_Screw_Hole();
        //Hole 2
        if(Hole_2_Distance_from_Back != 0)
        left(Hole_2_Distance_from_Back - Cabinet_Screw_Diameter/2)
            Cabinet_Screw_Hole();
        //Hole 3
        if(Hole_3_Distance_from_Back != 0)
        left(Hole_3_Distance_from_Back - Cabinet_Screw_Diameter/2)
            Cabinet_Screw_Hole();
    }
    //slide mounting holes
    up(Slide_Vertical_Adjustment)
    attach(LEFT, BOT, align=BACK, inside = true, shiftout=0.01){
        //Hole 1
        if(Hole_1_Distance_from_Back != 0)
        left(Hole_1_Slide_Distance_from_Back - Slide_Screw_Diameter/2)
            ycopies(spacing = Hole_1_Slide_Vertical_Separation)
            Slide_Screw_Hole();
        //Hole 2
        if(Hole_2_Distance_from_Back != 0)
        left(Hole_2_Slide_Distance_from_Back - Slide_Screw_Diameter/2)
            Slide_Screw_Hole();
        //Hole 3
        if(Hole_3_Distance_from_Back != 0)
        left(Hole_3_Slide_Distance_from_Back - Slide_Screw_Diameter/2)
            Slide_Screw_Hole();
    }
    //cutter block
    if(Cut_Middle)
    attach(LEFT, LEFT, align=BACK, inside=true, shiftout=0.01)
        left(Cut_Start_From_Back)
        cuboid([totalThicknessAdjusted + 0.02, Cut_Distance, totalHeightAdjusted + 0.02]);
    
}

module Cabinet_Screw_Hole(Cabinet_Screw_Diameter = Cabinet_Screw_Diameter, Cabinet_Screw_Recess_Diameter = Cabinet_Screw_Recess_Diameter, Cabinet_Screw_Support_Thickness = Cabinet_Screw_Support_Thickness, Depth = totalThicknessAdjusted + 0.02, spin = 0, orient = UP, anchor=CENTER){
    cyl(d = Cabinet_Screw_Diameter, h = Depth, $fn = 20, anchor=anchor, orient=orient, spin=spin)
        up(Depth + Cabinet_Screw_Support_Thickness)
        attach(BOT, BOT)
            cyl(d = Cabinet_Screw_Recess_Diameter, h = Depth);
}

module Slide_Screw_Hole(Slide_Screw_Diameter = Slide_Screw_Diameter, Depth = totalThicknessAdjusted + 0.02, spin = 0, orient = UP, anchor=CENTER){
    cyl(d = Slide_Screw_Diameter, h = Depth, $fn = 20, anchor=anchor, orient=orient, spin=spin);
}

module Slide(){
    cuboid([slideThicknessAdjusted, totalLengthAdjusted + 0.02, slideHeightAdjusted]);
}

function inches_to_mm(input) = Input_is_Inches_or_mm == "Inches" ? input * 25.4 : input;