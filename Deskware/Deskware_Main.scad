/* 
Deskware
Design by Hands on Katie
OpenSCAD by BlackjackDuck (Andy)
openGrid by David D

This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025-04-17 v1.0
    - Initial release
- 2025-04-18 v1.01
    - Remove drawer handle render when choosing hardware mount option
- 2025-04-18 v1.1 - SVG Export
    - SVG Generator for Top Plate
    - Revealed customizations for top plate inserts
- 2025-04-20 v1.1.1
    - Fix for MakerWorld plating of squared ends
- 2025-04-25 v1.2 - Curve Sections
    - Added curved section pieces customizable by degrees of arc and radius
- 2025-04-28 v1.2.1
    - Added HOK Connectors to bottom of riser for stacking risers
    - Small performance improvements to improve render time
    - Resolved top plate support snapping to grid sizes for odd-numbered grid depths
    - Curved sections properly plated for MakerWorld printing
- 2025-05-15 v1.2.2
    - Fix for end plates when depth exceeds core width
- 2025-05-19 v1.3 - Top Plate Customizer v1
    - Top Plate Customizer recesses for Gridfinity and OpenGrid (to be printed separately and place in)
    - Top Plate Customizer for wireless chargers 
- 2025-06-06 v1.4 - Riser Customizer
    - Customize riser slide sides and front chamfer
- 2025-08-03 v1.4.1
    - Removed drawer width contraints to match drawers to other mm-level width customization
    - Updated assembly view to only show one drawer (in top position) to reduce render time and prevent MakerWorld timeouts
- 2025-08-10 v1.5
    - Riser Customizer - Added split height option
     

Credit to 
    @David D on Printables for openGrid
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    Pedro Leite for openGrid optimization
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/joiners.scad>
include <BOSL2/threading.scad>


/*[Core Section Dimensions]*/
//Width (in mm) from riser center to riser center. 84mm increments (2 Gridfinity units / 3 openGrid units)
Core_Section_Width = 196; //[112:84:952] 
//Depth (in mm) from front of the riser to the rear of the backer (top plate will be deeper out the front). 28mm increments (openGrid units).
Core_Section_Depth = 196.5; //[112.5:84:840.5]
//Total Height of the core section from the bottom of the riser to the base of the top plate.
Total_Height = 107.5; //[67.5:40:387.5]


/*[End Style]*/
//Style of outer edges of Deskware.
End_Style = "Rounded Square"; //[Rounded, Squared, Rounded Square]
//If selecting Rounded Square, change the rounding radius of the rounded square
Rounded_Square_Rounding = 50; //[1:1:100]

/*[Drawers]*/
//Mounting method of drawer pull (printed vs hardware screws)
Drawer_Mounting_Method = "Handle - Printed"; //[Screw Holes - Single, Screw Holes - Double, Handle - Printed]
//If using screw holes for hardware, enter the diameter (mm) of the screw (5mm is common)
Drawer_Pull_Screw_Diameter = 5;
//Distance from screw hole centers if using double-screw drawer pulls
Drawer_Pull_Double_Screw_Hole_Distance_from_Center = 75;
//Adjust the height (mm) of the drawer pull holes up(positive) or down (negative)
Drawer_Pull_Height_Adjustement = 0;

/*[Top Plate]*/
//The depth (mm) of the recess at the top of the top plate. If inserting a material on the top plate, this should match the thickness of that material for a flush top.
Top_Plate_Recess = 1; //0.1
//The width (mm) of the top lip of the top plate. A thicker width equates to a larger border around the top.
Top_Plate_Lip_Width = 0.5;

/*[Top Plate Customizer]*/
Enable_Top_Plate_Customizer = false;
Top_Plate_Customization = "Gridfinity Top"; //[Gridfinity Top, openGrid Lite Top, openGrid Full Top, Wireless Charger]
//Specify a specific grid width. Leave Zero (0) for standard.
Custom_Grid_Width = 0;
//Specify a specific grid width. Leave Zero (0) for standard.
Custom_Grid_Depth = 0;
//Total Diameter (mm) of the wireless charger to embed.
Wireless_Charger_Diameter = 50;
//Total Thickness (mm) of the wireless charger to embed. If thicker than the top plate, you will need to prop it up from the baseplate underneath. Reach out if you need a generator for that. 
Wireless_Charger_Thickness = 8;
Wireless_Charger_Cord_Width = 6;
Wireless_Charger_Cord_Length_Outward = 14;

/*[Curve Section]*/
Enable_Curve_Mode = false;
Degrees_of_Arc = 45;
Core_Radius = 50;

/*[Riser Customizer]*/
Enable_Riser_Customizer = false;
Slide_Side_Selection = "BOTH"; //[BOTH, LEFT, RIGHT, NONE]
Riser_Front_Chamfer = 0; 
//Total Height of the core section from the bottom of the riser to the base of the top plate.
Outer_Total_Height = 107.5; //[67.5:40:387.5]
Inner_Total_Height = 67.5; //[67.5:40:387.5]

/*[Colors]*/
Primary_Color = "#dadada"; // color
Drawer_Front_Color = "#dadada"; // color
Top_Plate_Color = "#dadada"; // color
Drawer_Handle_Color = "#dadada"; // color
//dadada 00cf30 2e2e2e

/*[Advanced Options]*/
//Additional reach of top plate support built into the baseplate. 1 = 1 openGrid unit.
Additional_Top_Plate_Support = 1; //[1:1:8] 

/*[Assembly Display]*/
Show_Connected=true;
Show_Baseplate = true;
Show_Risers = true;
Show_Backer = true;
Show_Top_Plate = true;
Show_Drawers = true;
Show_Core = true;
Show_Ends = true;
Connector_Fit_Tests = false;

/*[SVG Multi-Material Exports]*/
//You acknowledge that SVG exports are not supported in MakerWorld and that you are using the latest DEVELOPER RELEASE desktop version of OpenSCAD with the BOSL2 library installed.
MultiMaterial_Desktop_Acknowledgement = false;
//DESKTOP VERSION ONLY - Check this box to show the SVG export
Show_Top_Plate_SVG = false;
//The additional clearance (mm) for the SVG output. For example, a value of 0.15 will create a 0.15mm space around the perimeter when outputing the SVG resulting in easier fit. 0mm will export the exact size of the recess.
Multi_Material_Clearance = 0.15; //0.01

/*[Desktop Debug]*/
//Set to true when running on MakerWorld  https://makerworld.com/en/makerlab/parametricModelMaker
MakerWorld_Render_Mode = false;
Show_Plate = 0;
Disable_Colors = false;
//DISPLAY PURPOSES ONLY - May not render large displays on MakerWorld (likely due to size! For full display, use desktop OpenSCAD. The output will always contain the parts needed for 1 core. For extra cores, simply print 1 more of the following: 1 Riser, 1 Backer, 1 Baseplate, 1 Top plate.
Core_Section_Count_DISPLAY_ONLY = 1; //[1:1:8]

/*[Hidden]*/
///*[Advanced]*/
clearance = 0.15;
openGridSize = 28;
openGrid_Render = true;
Show_Top_Plate_all_options = false;

///*[Printable Bed Volume]*/
//Select printer and a log entry will tell you if it will fit
Select_Printer = "X1C/P1S"; //[X1C/P1S, A1, A1 Mini, H2D, Other - Enter Below]
Custom_Bed_Width = 256;
Custom_Bed_Depth = 256;

curve_resolution = 100;

Core_Section_Count = Core_Section_Count_DISPLAY_ONLY;

///*[Riser Slide]*/
//Width (and rise of angle) of the slide recess
Slide_Width = 4;
//Total height of the slide recess
Slide_Height = 10.5;
//Vertical distance between slides
Slide_Vertical_Separation = 40;
//Distance from the bottom of the riser to the bottom of the slide delete tool. Drawers should add clearance
Slide_Distance_From_Bottom = 11.75;
//Minimum clearance required for a top of a slide to the top of the riser
Slide_Minimum_Distance_From_Top = 16.75;
Slide_Clearance = 0.25;

///*[Base Plate]*/
Base_Plate_Width = Core_Section_Width;
Base_Plate_Depth = Core_Section_Depth + 10.5;
Base_Plate_Thickness = 19;

//Baseplate to top plate interface parameters
//The chamfer depth and height of the outermost chamfer on the base plate
Top_Bot_Plates_Interface_Chamfer = 3;
//The minimum depth of the surface that the top plate rests on the base plate (excluding the chamfer above)
Minimum_Flat_Resting_Surface = 7.5;
TabDistanceFromOutsideEdge = 6;
TabProtrusionHeight = 4;

///*[Top Plate]*/
//Starting thickness of the top plate at default numbers. Increased recess will increase this value after the fact. 
Top_Plate_Thickness = 8.5;
//Lateral clearance (in mm) between the top plate and the base plate
Top_Plate_Clearance = 1;
//The chamfer at the top of the top plate.
Top_Plate_Depth = Base_Plate_Depth + Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2;
topChamfer = 2;
topLipWidth = Top_Plate_Lip_Width;
topLipHeight = Top_Plate_Recess; 
topPlateSquareVersionRadius = 1;

Core_Section_Height = Total_Height - Top_Plate_Thickness - Base_Plate_Thickness;

///*[Riser]*/
Riser_Depth = Core_Section_Depth - 7.5;
Riser_Height = Core_Section_Height;
Outer_Riser_Height = Outer_Total_Height - Top_Plate_Thickness - Base_Plate_Thickness;
Inner_Riser_Height = Inner_Total_Height - Top_Plate_Thickness - Base_Plate_Thickness;
Riser_Width = 22;

///*[Backer]*/
Backer_Width = Core_Section_Width;
Backer_Height = Core_Section_Height;
Backer_Thickness = 12.5;
//these are the cutouts that allow the riser to overlap with the backer
sideCutoutDepth = 3.65;
sideCutoutWidth = Riser_Width/2+clearance;
Backer_To_Riser_Tab_Inset = 2;
Backer_To_Riser_Tab_Depth = 8;

//Baseplate parameters
Grid_Min_Side_Clearance = Riser_Width/2;
Grid_Min_Depth_Clearance = 18;
Grid_Min_FrontBack_Clearance = 2;
Tile_Thickness = 11.5;
Baseplate_Bottom_Chamfer = 5;
Top_Plate_Baseplate_Depth_Difference = Top_Plate_Depth - Base_Plate_Depth;
echo(str("Difference between top plate depth and base plate depth: ", Top_Plate_Baseplate_Depth_Difference));
Top_Plate_Riser_Depth_Difference = Top_Plate_Depth - Riser_Depth;
echo(str("Difference between top plate depth and riser depth: ", Top_Plate_Riser_Depth_Difference));

//oG Height Calculations
Grid_Dist_From_Bot = 2; //size of base on bottom of BACKER before starting the grid
minimumTopSpacing = 2; //minimum height of the grid from the top of the backer
safeHOKClearance = 17;
Available_Grid_Height = quantdn((Backer_Height-Grid_Dist_From_Bot-minimumTopSpacing)/openGridSize, 1);
Grid_Height_mm = Available_Grid_Height * openGridSize;
Grid_Height_is_Odd = Available_Grid_Height % 2 == 0 ? false : true; 
enableHOKBlocks = Backer_Height - Grid_Height_mm - Grid_Dist_From_Bot < safeHOKClearance ? true : false;

//oG Width Calculations
Available_openGrid_Width_Units = quantdn((Base_Plate_Width - Grid_Min_Side_Clearance*2) / openGridSize, 1);
Grid_Width_is_Odd = Available_openGrid_Width_Units % 2 == 0 ? false : true; 
Grid_Width_mm = Available_openGrid_Width_Units * openGridSize;

Available_Gridfinity_Width_Units = quantdn((Base_Plate_Width - Grid_Min_Side_Clearance*2) / 42, 1);


//oG Depth Calculations
Available_openGrid_Depth_Units = quantdn((Base_Plate_Depth - Grid_Min_Depth_Clearance*2) / openGridSize, 1);
Grid_Depth_is_Odd = Available_openGrid_Depth_Units % 2 == 0 ? false : true; 
Grid_Depth_mm = Available_openGrid_Depth_Units * openGridSize;

Available_Gridfinity_Depth_Units = quantdn((Base_Plate_Depth - Grid_Min_Depth_Clearance*2) / 42, 1);

echo(str(Grid_Width_is_Odd));

//HOK Parameters
HOK_Connector_Spacing_Depth = Grid_Depth_is_Odd ? openGridSize*2 : openGridSize*3;

Default_HOK_Connector_Spacing_Back = min(openGridSize*(Available_openGrid_Width_Units - 1), Grid_Width_is_Odd ? openGridSize*4 : openGridSize*3); //Spacing between multiple HOK connecters (center to center). Either the outer grids or 
//Distance from part edge to center of HOK Connector
HOK_Connector_Inset = 4.5;
HOK_Connector_Thickness = 3.00;
HOK_Connector_Width = 8.9*2;

//Baseplate Dovetails
Dovetail_Spacing = 40;
Dovetail_Depth = 3.15;
Dovetail_Width = 10;
Dovetail_Height = 9;
Dovetail_Chamfer = 0.6;
Dovetail_Slop = 0.1;



//Baseplate End Angle Parameters
baseplateEndAngleUp= 11; //the angle of the end
baseplateEndAngleDistance = 89; //the width of the rectangle that is then angled upwards for the ends
baseplateEndAngleBevel = 5; //the bevel value for the rectangle that is then angled upwards for the ends
baseplateEndLateralWidth = cos(baseplateEndAngleUp) * baseplateEndAngleDistance; //Because the total width is determined by the angle and the width of the angled piece, this calculates the lateral width

//Tab parameters
TopPlateTabWidth = 3;

//Drawer Parameters
DrawerThickness = 3;
DrawerVerticalClearance = 1.5;
//Moves the drawers up (positive) or down (negative relative to the slide). Zero = the drawers sitting flush with the bottom of the riser. 
DrawerSlideHeightMicroadjustement = 0.5;
Drawer_Outside_Width = Core_Section_Width - Riser_Width - clearance*2;
Drawer_Outside_Depth = quantdn(Core_Section_Depth - sideCutoutDepth - clearance, 42)+DrawerThickness*2; //find the available space and round down to the nearest 42mm (gridfinity)
//Distance from the top of the drawer to the top of the slide.
Drawer_Slide_From_Top = Slide_Vertical_Separation - Slide_Distance_From_Bottom - Slide_Height-Slide_Clearance-DrawerVerticalClearance+clearance;
DrawerDovetailWidth = 10;
DrawerDovetailHeight = 25;
DrawerPullHoleCount = 
    Drawer_Mounting_Method == "Screw Holes - Single" ? 1 :
    Drawer_Mounting_Method == "Screw Holes - Double" ? 2 :
    0;
DrawerHandle_Connection_Type = "Screw";

drawerFrontThickness = 3.5;


//Printed Drawer Handle Dovetail Parameters
handleDovetail_DistanceBetweenCenters = 70;
handleDovetail_Slide = 4.8; //the height of the dovetail
handleDovetail_width = 7;
handleDovetail_height = drawerFrontThickness + DrawerThickness+0.01; //the depth of the dovetail which should just penetrate both the drawer front and the drawer casing
handleDovetail_chamfer = 1;
handleDovetail_taper = 6;
handleDovetail_InsertHoleWidth = 8.1; //the hole above the drawer handle dovetail that allows insertion of the drawer handle
handleDovetail_Center = 10 - handleDovetail_Slide*2;
handleDovetail_Slop = 0.1; //enlargement of the male dovetail piece to increase friction fit

///*[Small Screw Profile]*/
//Distance (in mm) between threads
Pitch_Sm = 3;
//Diameter (in mm) at the outer threads
Outer_Diameter_Sm = 6.747;
//Angle of the one side of the thread
Flank_Angle_Sm = 60;
//Depth (in mm) of the thread
Thread_Depth_Sm = 0.5;
//Diameter of the hole down the middle of the screw (for strength)
Inner_Hole_Diameter_Sm = 3.3;

//Bed Size Calculations
availablePrintVolume = 
    Select_Printer == "Other - Enter Below" ? [Custom_Bed_Width, Custom_Bed_Depth] :
    Select_Printer == "X1C/P1S" ? [255, 227] :
    Select_Printer == "A1" ? [256, 256] :
    Select_Printer == "A1 Mini" ? [180, 180] :
    Select_Printer == "H2D" ? [350, 320] :
    [Custom_Bed_Width, Custom_Bed_Depth];

print_volume_message = 
    availablePrintVolume[0] >= Core_Section_Width && availablePrintVolume[1] >= Core_Section_Depth ? "Print will fit!" : "Warning: Print will not fit!";
echo(print_volume_message);

//If viewing on desktop
if(!MakerWorld_Render_Mode && Show_Plate == 0){
    if(Show_Top_Plate_SVG) 
    //    up(110)
        TopPlateSVGBuilder();
    //else if (Enable_Curve_Mode){
    //    mw_plate_10();
   // }
    else 
        mw_assembly_view();
}

//OpenScad Desktop plate-specific render options
if(!MakerWorld_Render_Mode && Show_Plate == 1)
    mw_plate_1();
if(!MakerWorld_Render_Mode && Show_Plate == 2)
    mw_plate_2();
if(!MakerWorld_Render_Mode && Show_Plate == 3)
    mw_plate_3();
if(!MakerWorld_Render_Mode && Show_Plate == 4)
    mw_plate_4();
if(!MakerWorld_Render_Mode && Show_Plate == 5)
    mw_plate_5();
if(!MakerWorld_Render_Mode && Show_Plate == 6)
    mw_plate_6();
if(!MakerWorld_Render_Mode && Show_Plate == 7)
    mw_plate_7();
if(!MakerWorld_Render_Mode && Show_Plate == 8)
    mw_plate_8();
if(!MakerWorld_Render_Mode && Show_Plate == 9)
    mw_plate_9();
if(!MakerWorld_Render_Mode && Show_Plate == 10)
    mw_plate_10();
if(!MakerWorld_Render_Mode && Show_Plate == 11)
    mw_plate_11();
if(!MakerWorld_Render_Mode && Show_Plate == 12)
    mw_plate_12();
if(!MakerWorld_Render_Mode && Show_Plate == 13)
    mw_plate_13();
if(!MakerWorld_Render_Mode && Show_Plate == 14)
    mw_plate_14();



module mw_assembly_view() {
    if(Show_Top_Plate_SVG){
        TopPlateSVGBuilder();
    }
    else if (Enable_Curve_Mode){
        //Curved Series
        arc_series_gap = Show_Connected ? clearance : 50;
        if(Enable_Curve_Mode){
            fwd(4+9)
            if(Show_Risers)
            riserBuilderPath(Riser_Depth, Riser_Height, arc=Degrees_of_Arc, radius = Core_Radius, $fn=150, anchor=BOT);

            if(Show_Baseplate)
            up(Riser_Height + clearance + arc_series_gap)
                basePlateBuilderPath(Base_Plate_Depth, Base_Plate_Width, arc=Degrees_of_Arc, radius = Core_Radius, anchor=BOT);

            if(Show_Top_Plate)
            up(Riser_Height + Base_Plate_Thickness + clearance + arc_series_gap*2)
                fwd(Top_Plate_Baseplate_Depth_Difference)
                    topPlateBuilderPath(Top_Plate_Depth, Core_Section_Width, arc=Degrees_of_Arc, radius = Core_Radius, totalHeight = Top_Plate_Thickness + topLipHeight, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topLipHeight, $fn=150, anchor=BOT);
        }
    }
    else if (Enable_Top_Plate_Customizer){
        echo(str("Top Plate Customizer Enabled"));
        customizableTopPlateCore(depth = Top_Plate_Depth, width = Core_Section_Width, anchor=BOT) show_anchors();
    }
    else if (Enable_Riser_Customizer){
        xdistribute(spacing = Riser_Width+10){
            RiserSplit(slideSides = Slide_Side_Selection, chamfer = Riser_Front_Chamfer, orient=DOWN, anchor=TOP);
            RiserSplit(slideSides = Slide_Side_Selection, reverseSides = true, chamfer = Riser_Front_Chamfer, orient=DOWN, anchor=TOP);
        }
    }
    else{
        if(Show_Backer)
            xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
                back(Riser_Depth/2+ Backer_Thickness/2 + (Show_Connected ? -sideCutoutDepth + clearance : 15))
                    Backer();

        if(Show_Risers)
            xcopies(spacing = Backer_Width, n = Core_Section_Count + 1)
                Riser(slideSides = Slide_Side_Selection, chamfer = Riser_Front_Chamfer);

        if(Show_Baseplate)
            
            up(Show_Connected ? Riser_Height + clearance : Riser_Height + 50){
                if(Show_Core)
                xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
                    basePlateBuilderPath(Base_Plate_Depth, Base_Plate_Width, anchor=BOT);
                    //BasePlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth,  height = Base_Plate_Thickness);
                if(End_Style == "Rounded Square" && Show_Ends){
                    xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? 0: 50))
                        zrot($idx == 0 ? 0 : 180)
                            baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = Rounded_Square_Rounding, anchor=BOT+RIGHT);
                }
                else if(End_Style == "Squared" && Show_Ends){
                    xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? 0: 50))
                        zrot($idx == 0 ? 0 : 180)
                            baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = 1, anchor=BOT+RIGHT);
                }

                else if(End_Style == "Rounded" && Show_Ends){
                    left (Core_Section_Width / 2 * Core_Section_Count + (Show_Connected ? 0 : 25))
                        BasePlateEndRounded(width = Base_Plate_Width, depth = Base_Plate_Depth, height = Base_Plate_Thickness, half=LEFT, style=End_Style);
                    right (Core_Section_Width / 2 * Core_Section_Count + (Show_Connected ? 0 : 25))
                        BasePlateEndRounded(width = Base_Plate_Width, depth = Base_Plate_Depth, height = Base_Plate_Thickness, half=RIGHT, style=End_Style);
                }
            }

        if(Show_Top_Plate){
            up(Riser_Height + (Show_Connected ? Base_Plate_Thickness: 150))
            {
                if(Show_Core)
                xcopies(n=Core_Section_Count, spacing = Core_Section_Width)
                    topPlateBuilderPath(depth = Top_Plate_Depth, width = Core_Section_Width, totalHeight = Top_Plate_Thickness + topLipHeight, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topLipHeight, anchor=BOT);
                    //Deprecated the below for the faster-rendering option above
                    //TopPlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, anchor=BOT);
                if(End_Style == "Rounded" && Show_Ends){
                    xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? clearance*2: 50))
                        TopPlateEndRoundNew(depth = Top_Plate_Depth, thickness = Top_Plate_Thickness, topRecess = topLipHeight, half=$idx == 0 ? LEFT : RIGHT);
                }
                else if(End_Style == "Squared" && Show_Ends){
                    xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? clearance*2: 50))
                        TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Top_Plate_Depth, thickness = Top_Plate_Thickness, topRecess = topLipHeight, radius = topPlateSquareVersionRadius, half=$idx == 0 ? LEFT : RIGHT);
                }
                else if(End_Style == "Rounded Square" && Show_Ends){
                    xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? clearance*2: 50))
                        TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Top_Plate_Depth, thickness = Top_Plate_Thickness, topRecess = topLipHeight, radius = Rounded_Square_Rounding, half=$idx == 0 ? LEFT : RIGHT);
                }
            }
        }

        if(Show_Drawers){
            //bottom drawer
            up(DrawerSlideHeightMicroadjustement)
            xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
                fwd(Show_Connected ? 8.5 : 50)
                    //1-unit drawer
                    if($idx % 2 == 0){
                        up(40 * ((Riser_Height / 40) - 1)) //Change 2025-08-03 - Only show 1 drawer (and in the top position to save render time)
                        //zcopies(spacing = 40, sp=0, n = Riser_Height / 40) //Change 2025-08-03 - Only show 1 drawer (and in the top position to save render time)
                        Drawer(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT)
                            //drawer fronts
                            if(Show_Connected)
                            attach(FRONT, TOP)
                                DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2)
                                    if(Drawer_Mounting_Method == "Handle - Printed")
                                    //drawer handle
                                    recolor(Disable_Colors ? undef : Drawer_Handle_Color)
                                    attach(BOT, BACK)
                                            DrawerHandle();
                    }
                    else
                        Drawer(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT)
                            //drawer fronts
                            if(Show_Connected)
                            attach(FRONT, TOP)
                                DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2)
                                    if(Drawer_Mounting_Method == "Handle - Printed")
                                    recolor(Disable_Colors ? undef : Drawer_Handle_Color)
                                    attach(BOT, BACK)
                                        DrawerHandle();
            //drawer fronts if not connected
            if(!Show_Connected){
                up(DrawerSlideHeightMicroadjustement)
                fwd(Core_Section_Depth/2 + 25 + 60)
                    xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
                        if($idx == 0)
                        ycopies(spacing = 40)
                            DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2);
                        else
                            DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2);
                if(Drawer_Mounting_Method == "Handle - Printed"){
                    fwd(Core_Section_Depth/2 + 25 + 125)
                        DrawerHandle();
                    fwd(Core_Section_Depth/2 + 25 + 125)
                        xcopies(spacing = 150) T_Screw();
                }
            }
        }
        

        if(Connector_Fit_Tests){
            diff()
            cube([19,5,18], anchor=BOT)
                attach(TOP, BOT, inside=true, shiftout=0.01)
                    HOKConnectorDeleteTool();
            
            move([10,20])
                Dovetail_Male(anchor=UP, orient=DOWN);

            ycopies(spacing = Dovetail_Width+5)
                diff()
                    move([-10,20])
                        zrot($idx == 0 ? 180 : 0)
                        cuboid([Dovetail_Width+4,Dovetail_Width,Dovetail_Depth+1], anchor=BOT)
                            attach(TOP, BACK, align = FRONT, inside=true) 
                                    Dovetail_Female();
        }
    }
}

//are we rendering a special part or the regular entire deskware standard
function special_render_mode() = Enable_Curve_Mode || Enable_Top_Plate_Customizer || Enable_Riser_Customizer;

echo(str("special render mode? ", special_render_mode()));

//BEGIN MAKERWORLD PLATING

//Plate 1 - Core Baseplate
module mw_plate_1(){
    if(!special_render_mode())
        basePlateBuilderPath(Base_Plate_Depth, Base_Plate_Width, anchor=BOT);
        //deprecated for the faster-rendering option above
        //BasePlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth,  height = Base_Plate_Thickness);
}


//Plate 2 - Risers and Backer
module mw_plate_2(){
    widthOfAllRisers = (2) * (Riser_Width+5); //removed dynamic riser adds based on core count (to keep render times down)
    widthOfAllBackers = 1 * (Backer_Height + 5); //removed dynamic riser adds based on core count (to keep render times down)

    if(!special_render_mode()){
        left(widthOfAllRisers/2)
        xcopies(spacing = Riser_Width+5, n = 2)
            Riser(slideSides = Slide_Side_Selection, chamfer = Riser_Front_Chamfer, orient=DOWN, anchor=TOP) ;
        right(widthOfAllBackers/2)
            xcopies(spacing = Backer_Height + 5, n=1)
                zrot(90)
                    Backer(orient=BACK, anchor=BACK);
    }
}

//Plate 3 - Baseplate Ends
module mw_plate_3(){
    if(!special_render_mode()){
        if(End_Style == "Rounded Square"){
                    xcopies(spacing = -5)
                        zrot($idx == 0 ? 0 : 180)
                            baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = Rounded_Square_Rounding, anchor=BOT+RIGHT, orient=RIGHT);
        }
        else if(End_Style == "Squared"){
            xcopies(spacing = -5)
                zrot($idx == 0 ? 0 : 180)
                    baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = topPlateSquareVersionRadius, anchor=BOT+RIGHT, orient=RIGHT);
        }

        else{
                xcopies(spacing = 5)
                    BasePlateEndRounded(width = Base_Plate_Width, depth = Base_Plate_Depth, height = Base_Plate_Thickness, half=$idx == 0 ? LEFT : RIGHT, style=End_Style);
        }

        move([0, Base_Plate_Depth/2 + 15,0])
            xcopies(n = 4, spacing = 15)
                Dovetail_Male(anchor=UP, orient=DOWN);
    }
}

//Plate 4 - Core Top plate
module mw_plate_4(){
    if(!special_render_mode())
        topPlateBuilderPath(depth = Top_Plate_Depth, width = Core_Section_Width, totalHeight = Top_Plate_Thickness + topLipHeight, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topLipHeight, anchor=BOT);
        //below deprecated for the faster-rendering option above
        //TopPlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, anchor=BOT);

}

//Plate 5 - Ends Top plate
module mw_plate_5(){
    if(!special_render_mode()){
        if(End_Style == "Rounded"){
            xcopies(spacing = 5)
                TopPlateEndRoundNew(depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, topRecess = topLipHeight, half=$idx == 0 ? LEFT : RIGHT);
        }
        else if(End_Style == "Squared"){
            xcopies(5)
                TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Top_Plate_Depth, radius = topPlateSquareVersionRadius, thickness = Top_Plate_Thickness, topRecess = topLipHeight, half=$idx == 0 ? LEFT : RIGHT);
        }
        else{
            xcopies(5)
                TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Top_Plate_Depth, radius = Rounded_Square_Rounding, thickness = Top_Plate_Thickness, topRecess = topLipHeight, half=$idx == 0 ? LEFT : RIGHT);
        }
    }

}

//Plate 6 - Drawer 1 Unit High
module mw_plate_6(){
    if(!special_render_mode())
        Drawer(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT);
}

//Plate 7 - Drawer 2 Units High
module mw_plate_7(){
    if(!special_render_mode())
        Drawer(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT);

}

//Plate 8 - Drawer Fronts Single
module mw_plate_8(){
    if(!special_render_mode()){
        ydistribute(sizes=[40, 40], spacing = 5){
            DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2, anchor=BOT);
            //DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2);
            if(Drawer_Mounting_Method == "Handle - Printed"){
                DrawerHandle(anchor=BOT);
                xcopies(spacing = 15)
                back(10)T_Screw();
            }
        }
    }
}

//Plate 9 - Drawer Fronts Single
module mw_plate_9(){
    if(!special_render_mode()){
        ydistribute(sizes=[80, 40], spacing = 5){
            //DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2);
            DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2, anchor=BOT);
            if(Drawer_Mounting_Method == "Handle - Printed"){
                DrawerHandle(anchor=BOT);
                xcopies(spacing = 15)
                back(10)T_Screw();
            }
        }
    }
}
//Plate 10 - Arc Series - Baseplate
module mw_plate_10(){
    //Curved Series
    arc_series_gap = 50;
    if(Enable_Curve_Mode){
        basePlateBuilderPath(Base_Plate_Depth, Base_Plate_Width, arc=Degrees_of_Arc, radius = Core_Radius, anchor=BOT);

                topPlateBuilderPath(Top_Plate_Depth, Core_Section_Width, arc=Degrees_of_Arc, radius = Core_Radius, totalHeight = Top_Plate_Thickness + topLipHeight, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topLipHeight, $fn=150, anchor=BOT)  ;
    }
}
//Plate 11 - Arc Series - Top plate
module mw_plate_11(){
    //Curved Series
    arc_series_gap = 50;
    if(Enable_Curve_Mode){
            fwd(Top_Plate_Baseplate_Depth_Difference)
                topPlateBuilderPath(Top_Plate_Depth, Core_Section_Width, arc=Degrees_of_Arc, radius = Core_Radius, totalHeight = Top_Plate_Thickness + topLipHeight, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topLipHeight, $fn=150, anchor=BOT)  ;
    }
}
//Plate 11 - Arc Series - Top plate
module mw_plate_12(){
    //Curved Series
    arc_series_gap = 50;
    if(Enable_Curve_Mode){
        up(Riser_Height)xrot(180) 
        fwd(4+9) 
        riserBuilderPath(Riser_Depth, Riser_Height, arc=Degrees_of_Arc, radius = Core_Radius, $fn=150, anchor=BOT);
    }
}

//Plate 13 - Top Plate Customizer
module mw_plate_13(){
    if(Enable_Top_Plate_Customizer)
        customizableTopPlateCore(depth = Top_Plate_Depth, width = Core_Section_Width, anchor=BOT);
}
module mw_plate_14(){
    if(Enable_Riser_Customizer)
        xdistribute(spacing = Riser_Width+10){
            RiserSplit(slideSides = Slide_Side_Selection, chamfer = Riser_Front_Chamfer, orient=DOWN, anchor=TOP);
            RiserSplit(slideSides = Slide_Side_Selection, reverseSides = true, chamfer = Riser_Front_Chamfer, orient=DOWN, anchor=TOP);
        }
}
//END MAKERWORLD PLATING

//BEGIN CUSTOMIZATION SERIES
module customizableTopPlateCore(width, depth, spin = 0, orient = UP, anchor=CENTER){
    diff()
    topPlateBuilderPath(depth = depth, width = width, totalHeight = Top_Plate_Thickness + topLipHeight, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topLipHeight, anchor=BOT){
        down(topLipHeight)
            attach(TOP, TOP, inside=true, shiftout=0.01){
                if(Top_Plate_Customization == "Gridfinity Top")
                    cuboid([Custom_Grid_Depth == 0 ? Available_Gridfinity_Depth_Units * 42 : Custom_Grid_Depth * 42 , Custom_Grid_Width == 0 ? Available_Gridfinity_Width_Units * 42 : Custom_Grid_Width * 42, 5]);
                if(Top_Plate_Customization == "openGrid Lite Top")
                    cuboid([Custom_Grid_Depth == 0 ? Available_openGrid_Depth_Units * 28 : Custom_Grid_Depth * 28 , Custom_Grid_Width == 0 ? Available_openGrid_Width_Units * 28 : Custom_Grid_Width * 28, 4]);
                if(Top_Plate_Customization == "openGrid Full Top")
                    cuboid([Custom_Grid_Depth == 0 ? Available_openGrid_Depth_Units * 28 : Custom_Grid_Depth * 28 , Custom_Grid_Width == 0 ? Available_openGrid_Width_Units * 28 : Custom_Grid_Width * 28, 6.8]);
                if(Top_Plate_Customization == "Wireless Charger")
                    cyl(d=Wireless_Charger_Diameter, h=Wireless_Charger_Thickness)
                        attach(RIGHT, BOT, overlap = 3)//cylinder out for cord
                            cyl(d = Wireless_Charger_Cord_Width, h = Wireless_Charger_Cord_Length_Outward + 3)
                                attach(FRONT, TOP, overlap = Wireless_Charger_Cord_Width/2)
                                    cuboid([Wireless_Charger_Cord_Width, Wireless_Charger_Cord_Length_Outward+3, Top_Plate_Thickness]);
            }
    //show_anchors();
    }

}

//END CUSTOMIZATION SERIES

//BEGIN DRAWER PARTS
module DrawerHandle(handle_OutsideWidth = 100, handle_InsideDepth = 15, handle_Thickness = 10, spin = 0, orient = UP, anchor = CENTER){
    attachable(anchor, spin, orient, size=[handle_OutsideWidth, handle_InsideDepth + handle_Thickness, handle_Thickness]){

        recolor(Disable_Colors ? undef : Drawer_Handle_Color)
        fwd(-handle_Thickness/2+ (handle_Thickness+handle_InsideDepth)/2)
        diff("thread"){
            //main handle
            cuboid([handle_OutsideWidth, handle_Thickness, handle_Thickness]);
            //handle pegs forced to standard width
            back(handle_InsideDepth/2+handle_Thickness/2-0.01)
            xcopies(spacing = handleDovetail_DistanceBetweenCenters)
                cuboid([handle_Thickness, handle_InsideDepth, handle_Thickness])
                    if(DrawerHandle_Connection_Type == "Screw")
                    tag("thread")
                    attach(BACK, BOT, inside=true, shiftout=0.01)
                        DrawerHandleScrewFemale();
        }
        children();
    }
}


module DrawerFront(height_units, inside_width, anchor=CENTER, orient=UP, spin=0){
    drawerFrontChamfer = 1;
    drawerFrontRecess = 3.1;
    drawer_height = height_units * Slide_Vertical_Separation - DrawerVerticalClearance;
    drawerFrontHeightReduction = 4.5;

    drawerFrontLateralClearance = 2;
    
    inside_width_adjusted = inside_width + clearance*2; //Update 2025-08-03 - replaced rounding for drawer width as calculations are managed by enforcing Core_Section_Width
    //inside_width_adjusted = quant(inside_width, 42);
    drawerOuterWidth = inside_width_adjusted + DrawerThickness*2;
    drawerFrontWidth = drawerOuterWidth + Riser_Width - drawerFrontLateralClearance*2;

    tag_scope()
    recolor(Disable_Colors ? undef : Drawer_Front_Color)
    diff()
    cuboid([drawerFrontWidth, drawer_height, drawerFrontThickness], chamfer = drawerFrontChamfer, edges=BOT, anchor=anchor, orient=orient, spin=spin){
        //drawer dovetails
        tag("keep")
        xcopies(spacing=inside_width_adjusted - 28 )
        attach(TOP, FRONT, overlap=0.01, align=BACK, inset=drawerFrontHeightReduction)
            cuboid([DrawerDovetailWidth+DrawerThickness*2-clearance*2, DrawerThickness+0.02, DrawerDovetailHeight*height_units - clearance], chamfer=DrawerThickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        //drawer pull screw hole(s)
        if(Drawer_Mounting_Method == "Screw Holes - Single" || Drawer_Mounting_Method == "Screw Holes - Double")
        tag("remove")
            back(Drawer_Pull_Height_Adjustement)
            xcopies(spacing = Drawer_Pull_Double_Screw_Hole_Distance_from_Center, n=DrawerPullHoleCount)
            attach(TOP, BOT, inside = true, shiftout=0.01)
                cyl(d=Drawer_Pull_Screw_Diameter, h = drawerFrontThickness + 0.02, $fn = 25);
        if(Drawer_Mounting_Method == "Handle - Printed"){
            if(DrawerHandle_Connection_Type == "Screw")
            tag("remove")
                xcopies(spacing = handleDovetail_DistanceBetweenCenters)
                    attach(BOT, TOP, inside=true, shiftout=0.01)
                        cyl(d=Outer_Diameter_Sm+0.25, h=drawerFrontThickness + DrawerThickness + 0.02, $fn=25);
        }
        children();
    }
}

module Drawer(height_units, inside_width, Drawer_Outside_Depth, anchor=CENTER, orient=UP, spin=0){
    //FORCE INSIDE TO STANDARD UNITS - Update 2025-08-03 - Removed now that input parameters force standard units.
    inside_width_adjusted = inside_width + clearance*2;
    //inside_width_adjusted = quant(inside_width, 42); //Update 2025-08-03 - replaced rounding for drawer width as calculations are managed by enforcing Core_Section_Width
    additionalMMBeyondGFPerfectFit = inside_width_adjusted % 42;
    echo(str("Drawer inside are Gridfinity perfect fit? ", additionalMMBeyondGFPerfectFit == 0 ? "Yes - " : "No - ", additionalMMBeyondGFPerfectFit, " mm extra"));

    drawer_height = height_units * Slide_Vertical_Separation - DrawerVerticalClearance;
    drawerFloorThickness = 2;
    drawerOuterWidth = inside_width_adjusted + DrawerThickness*2;

    drawerInsideRounding = 3.75;
    drawerFrontHeightReduction = 4.5;

    tag_scope()
    recolor(Disable_Colors ? undef : Primary_Color)
    diff()
    rect_tube(size = [drawerOuterWidth, Drawer_Outside_Depth], h = drawer_height, wall=DrawerThickness, anchor=anchor, orient=orient, spin=spin){
        attach([LEFT, RIGHT], LEFT, align=TOP, overlap=0.01, inset=Drawer_Slide_From_Top+DrawerSlideHeightMicroadjustement)
            Drawer_Slide(length = Drawer_Outside_Depth);
        //drawer bottom
        tag("keep")
        attach(BOT, BOT, inside=true)
            cuboid([drawerOuterWidth-0.01, Drawer_Outside_Depth-0.01, drawerFloorThickness]);
        //drawer front dovetails
        xcopies(spacing=inside_width_adjusted - 28 )
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([DrawerDovetailWidth+DrawerThickness*2, DrawerThickness+0.02, DrawerDovetailHeight*height_units+drawerFrontHeightReduction], chamfer=DrawerThickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        //drawer front height reduction
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([drawerOuterWidth+0.02, DrawerThickness+0.02, drawerFrontHeightReduction]);
        //front drawer pull
        color(Disable_Colors ? undef : Primary_Color)
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=drawerFrontHeightReduction-0.02)
            cuboid([50, DrawerThickness+0.02, 20], 
                        //bottom rounding at 5 or maximum possible given cutout width
                        rounding = min(5,5), 
                        edges=[LEFT+BOT, RIGHT+BOT]) 
                        //top round out
                        edge_profile_asym([TOP+LEFT, TOP+RIGHT], corner_type="round") xflip() mask2d_roundover(2) 
                        ;
        //Back cable port
        attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            color(Disable_Colors ? undef : Primary_Color)
            cuboid([20, DrawerThickness+0.02, 15], 
                        //bottom rounding at 5 or maximum possible given cutout width
                        rounding = min(5,5), 
                        edges=[LEFT+BOT, RIGHT+BOT]) 
                        //top round out
                        edge_profile_asym(TOP, corner_type="round") xflip() mask2d_roundover(3) 
                        ;
        //Back cable port inside
        attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=20)
            cuboid([20, DrawerThickness+0.02, 10], 
                        //bottom rounding at 5 or maximum possible given cutout width
                        rounding = 2, 
                        edges=[LEFT+BOT, RIGHT+BOT, TOP+LEFT, TOP+RIGHT]) 
                        ;
        //drawer pull screw hole(s)
        if(Drawer_Mounting_Method == "Screw Holes - Single" || Drawer_Mounting_Method == "Screw Holes - Double")
        tag("remove")
            up(Drawer_Pull_Height_Adjustement)
            xcopies(spacing = Drawer_Pull_Double_Screw_Hole_Distance_from_Center, n=DrawerPullHoleCount)
            attach(FRONT, BOT, inside = true, shiftout=0.01)
                cyl(d=Drawer_Pull_Screw_Diameter, h = DrawerThickness + 0.02, $fn = 25);
        //drawer handle dovetails
        if(Drawer_Mounting_Method == "Handle - Printed"){
            if(DrawerHandle_Connection_Type == "Screw")
            tag("remove")
                xcopies(spacing = handleDovetail_DistanceBetweenCenters)
                    attach(FRONT, TOP, inside=true, shiftout=0.01)
                        cyl(d=Outer_Diameter_Sm+0.25, h=DrawerThickness-2.5, $fn=25)
                            attach(BOT, TOP, overlap=0.01)
                                cyl(d=15, h=DrawerThickness, $fn=25);
        }
        children();
    }
}
//END DRAWER PARTS

module TopPlateEndSquared(width, depth, thickness, radius = 50, topRecess = 1, half = LEFT){
    //topPlateAdjustedDepth = depth + Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2;
    thicknessAdjusted = thickness + topLipHeight;
    
    color(Disable_Colors ? undef : Top_Plate_Color)
    diff(){
        half_of(half, s = depth*2 + 5)
            topPlateBuilderShape(totalHeight = thicknessAdjusted, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topRecess)
                rect([width,depth], rounding = [radius,radius,radius,radius]);
            tag("remove")
               up(TabProtrusionHeight/2-0.01)
               xcopies(spacing = TopPlateTabWidth+TabDistanceFromOutsideEdge*2)
                    TopPlateTab(height = TabProtrusionHeight, deleteTool = true, anchor=BOT);
    }
}

module TopPlateEndRoundNew(depth, thickness, topRecess = 1, half = LEFT){
    
    //topPlateAdjustedDepth = depth + Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2;
    thicknessAdjusted = thickness + topLipHeight;
    
    color(Disable_Colors ? undef : Top_Plate_Color)
    diff(){
        half_of(half, s = depth*2 + 5)
            topPlateBuilderShape(totalHeight = thicknessAdjusted, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer, topInset = topLipWidth, topRecess = topRecess)
                ellipse(d=depth);
        tag("remove")
            up(TabProtrusionHeight/2-0.01)
            xcopies(spacing = TopPlateTabWidth+TabDistanceFromOutsideEdge*2)
                TopPlateTab(height = TabProtrusionHeight, deleteTool = true);
    }
}

module TopPlateSVGBuilder(){
    $fn=150;

    roundingAdjustment = Rounded_Square_Rounding-topChamfer-topLipWidth-Multi_Material_Clearance;

    //partition(size = Top_Plate_Depth-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2, spread=Base_Plate_Width + clearance*2, cutpath = "flat", spin=90){
    left(Base_Plate_Width/2 + (Show_Connected ? clearance : 5))
    half_of(LEFT, s = Top_Plate_Depth*2 + 5, planar=true)
        fullHalf();
    right(Base_Plate_Width/2 + (Show_Connected ? clearance : 5))
    half_of(RIGHT, s = Top_Plate_Depth*2 + 5, planar=true)
        fullHalf();
    
        rect([Base_Plate_Width,Top_Plate_Depth-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2]);

    module fullHalf(){
    {
        if(End_Style == "Rounded")
            ellipse(d=Top_Plate_Depth-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2);
        else if(End_Style == "Squared")
            rect([baseplateEndAngleDistance*2-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2,Top_Plate_Depth-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2]);
        else
            rect([baseplateEndAngleDistance*2-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2,Top_Plate_Depth-topChamfer*2-topLipWidth*2-Multi_Material_Clearance*2], rounding = [roundingAdjustment,roundingAdjustment,roundingAdjustment,roundingAdjustment]);
    }
    }
    
}

//BEGIN EXTRUDED SERIES
module topPlateBuilderPath(depth, width, arc = 0, radius = 30, totalHeight = 9.5, bottomChamfer = 6, topChamfer = 1, topInset = 0.5, topRecess = 1, $fn = 150, anchor=CENTER,spin=0,orient=UP){
    
    middleSectionHeight = totalHeight - bottomChamfer - topChamfer; 
    echo(str("topPlateBuilderPath middleSectionHeight: ", middleSectionHeight));

    attachable(anchor, spin, orient, size = [width-clearance*2, depth, totalHeight]){
        //straight piece
        if(arc == 0)
            color(Disable_Colors ? undef : Top_Plate_Color)
            diff("tabs")
            down(totalHeight/2)
            zrot(90)
                path_sweep(topPlatePath, [[0,-width/2 + clearance],[0,width/2 - clearance]]){
                    tag("tabs")
                    attach(["start", "end"], BOT, inside=true)
                        up(TopPlateTabWidth/2 + TabDistanceFromOutsideEdge)
                        xrot(-90) zrot(90) down(0.01)
                        TopPlateTab(height = TabProtrusionHeight, deleteTool = true);
                    echo(str("Top Plate arc = 0"));
                    //children();
                }
        //arc
        else
            //fwd(radius + Riser_Depth/2)
            diff("tabs")
            down(totalHeight/2)
            zrot(90-arc/2)
                path_sweep(topPlatePath, arc(r = Riser_Depth/2 + radius, angle=arc), anchor=anchor,spin=spin,orient=orient) {
                    //top plate tabs
                    //#attach(BOT, BOT, inside=false, shiftout=0.01, align=[LEFT, RIGHT], inset=TabDistanceFromOutsideEdge-clearance)
                    tag("tabs")
                    attach(["start", "end"], BOT, inside=true)
                        up(TopPlateTabWidth/2 + TabDistanceFromOutsideEdge)
                        xrot(-90) zrot(90) down(0.01)
                        TopPlateTab(height = TabProtrusionHeight, deleteTool = true);
                    echo(str("Top Plate arc != 0"));
                    //children();
                }

        
    children();
    }

    topPlatePath = [
            [-depth/2 + bottomChamfer,0], //starting bottom front
            [-depth/2, bottomChamfer], 
            [-depth/2, bottomChamfer + middleSectionHeight],
            [-depth/2 + topChamfer, bottomChamfer + middleSectionHeight + topChamfer], //top of lip outside
            [-depth/2 + topChamfer + topInset, bottomChamfer + middleSectionHeight + topChamfer], //top of lip inside
            [-depth/2 + topChamfer + topInset, bottomChamfer + middleSectionHeight + topChamfer-topRecess], //bottom of recess
            [depth/2 - topChamfer - topInset, bottomChamfer + middleSectionHeight + topChamfer-topRecess], //bottom of recess
            [depth/2 - topChamfer - topInset, bottomChamfer + middleSectionHeight + topChamfer], //top of lip inside
            [depth/2 - topChamfer, bottomChamfer + middleSectionHeight + topChamfer], //top of lip outside
            [depth/2, bottomChamfer + middleSectionHeight],
            [depth/2, bottomChamfer], 
            [depth/2 - bottomChamfer,0],
        ];
}

//extrudes a base plate along a path
module basePlateBuilderPath(depth, width, height = 19, arc = 0, radius = 30, totalHeight = 9.5, bottomChamfer = 6, topChamfer = 1, topInset = 0.5, topRecess = 1, $fn = 150, anchor=CENTER,spin=0,orient=UP){
    
    //straight piece
    if(arc == 0)
        color(Disable_Colors ? undef : Primary_Color)
        diff("HOKConnectors Dovetails", "k1")
        diff("r1", "keep HOKConnectors Dovetails")
        //diff()
        zrot(90) 
            right(0.5)
            path_sweep(basePlatePath, [[0,width/2 - clearance], [0,-width/2 + clearance]], anchor=anchor,spin=spin,orient=orient) {        
                //tabs
                attach(["start", "end"], BOT, inside=false)
                    down(TopPlateTabWidth/2 + TabDistanceFromOutsideEdge)
                    xrot(-90) zrot(90)
                    TopPlateTab(height = height + TabProtrusionHeight, deleteTool = false);
                //HOK Connectors sides
                tag("HOKConnectors")
                
                attach(["start", "end"], BOT, inside=true)
                    xcopies(spacing = HOK_Connector_Spacing_Depth)
                    up(HOK_Connector_Inset-clearance)
                        xrot(-90) zrot(90) down(0.01)
                            HOKConnectorDeleteTool(spin=90);
                //HOK Connectors back
                tag("HOKConnectors")
                down(11)
                attach(RIGHT, BOT, inside=true)
                    xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                    up(HOK_Connector_Inset)
                        xrot(-90) zrot(90) down(0.01)
                            HOKConnectorDeleteTool(spin=90);
                //Top plate support
                tag("keep")
                attach(["start", "end"], BOT, inside=false)
                    back(6.8)
                    down(28*(Additional_Top_Plate_Support + 0.5)/2)
                    xrot(-90) zrot(90)
                    cuboid([28*(Additional_Top_Plate_Support + 0.5),28*((Available_openGrid_Depth_Units % 2 == 0 ? 4 : 3)),height - 6.8], chamfer=height-Tile_Thickness, edges=[TOP], except=LEFT){
                        //dovetail
                        tag("Dovetails")
                            attach(LEFT, BOT, inside=true, shiftout = 0.01, align=TOP) 
                                xcopies(spacing = Dovetail_Spacing)
                                Dovetail_Female();
                    }
                //cutout for opengrid and opengrid. 
                tag("r1")
                left(0.5)
                attach(BOT, BOT, inside=true, shiftout=0.01)
                    cuboid([Grid_Depth_mm, Grid_Width_mm, Tile_Thickness+0.02]){
                        tag("keep")
                            openGrid(Board_Height = openGrid_Render ? Available_openGrid_Width_Units : 1, Board_Width = openGrid_Render ? Available_openGrid_Depth_Units : 1, Tile_Thickness = Tile_Thickness);
                    }

                children();
            }
    //arc
    else{
        diff()
        zrot(90+arc/2)
            path_sweep(basePlatePath, arc(r = Riser_Depth/2 + radius, angle=-arc), anchor=anchor,spin=spin,orient=orient) {
                //tabs
                attach(["start", "end"], BOT, inside=false)
                    down(TopPlateTabWidth/2 + TabDistanceFromOutsideEdge)
                    xrot(-90) zrot(90)
                    TopPlateTab(height = height + TabProtrusionHeight, deleteTool = false);
                //HOK Connectors
                attach(["start", "end"], BOT, inside=true)
                    xcopies(spacing = HOK_Connector_Spacing_Depth)
                    up(HOK_Connector_Inset-clearance)
                        xrot(-90) zrot(90) down(0.01)
                            HOKConnectorDeleteTool(spin=90);
                //Top plate support
                attach(["start", "end"], BOT, inside=false)
                    down(18/2)
                    xrot(-90) zrot(90)
                    cuboid([18,28*4,height], chamfer=height-Tile_Thickness, edges=[TOP], except=LEFT){
                        //dovetail
                        tag("remove")
                            attach(LEFT, BOT, inside=true, shiftout = 0.01, align=TOP) 
                                xcopies(spacing = Dovetail_Spacing)
                                Dovetail_Female();
                    }
                children();
            }
    }

    basePlatePath = [
        [-depth/2 + Baseplate_Bottom_Chamfer, 0], //bottom front, bottom of chamfer
        [-depth/2, Baseplate_Bottom_Chamfer], //bottom front, top of chamfer
        [-depth/2, height + Top_Bot_Plates_Interface_Chamfer], //top of front (including lip)
        [-depth/2 + Top_Bot_Plates_Interface_Chamfer, height], //top of front (behind lip)
        [-depth/2 + Top_Bot_Plates_Interface_Chamfer + Minimum_Flat_Resting_Surface, height], //top front shelf
        [-depth/2 + Top_Bot_Plates_Interface_Chamfer + Minimum_Flat_Resting_Surface + (height - Tile_Thickness), height - (height - Tile_Thickness)], //front chamfer down to tiles
        [depth/2 - Top_Bot_Plates_Interface_Chamfer - Minimum_Flat_Resting_Surface - (height - Tile_Thickness), height - (height - Tile_Thickness)], //back chamfer down to tiles
        [depth/2 - Top_Bot_Plates_Interface_Chamfer - Minimum_Flat_Resting_Surface, height], //top back shelf
        [depth/2 - Top_Bot_Plates_Interface_Chamfer, height], //top of back (behind lip)
        [depth/2, height + Top_Bot_Plates_Interface_Chamfer], //top of back (including lip)
        //[depth/2, Baseplate_Bottom_Chamfer], //bottom back, top of chamfer
        [depth/2, 0], //bottom back, bottom of chamfer
    ];
}

//extrudes a riser along a path
//warning - bad math to remove the middle section of the arc - could use improvements
module riserBuilderPath(depth, height, arc = 0, radius = 30, anchor=CENTER,spin=0,orient=UP){
        number_of_slides = quantdn((Riser_Height - Slide_Distance_From_Bottom - Slide_Height - Slide_Minimum_Distance_From_Top)/Slide_Vertical_Separation+1, 1);

        //zrot(180-arc/2)
        diff(){
            zrot(180-arc/2)
            path_sweep(riserPath, riserExtrusionPath, anchor=anchor,spin=spin,orient=orient) {
                //HOK Connectors
                attach(["start", "end"], BOT, inside=true)
                    zcopies(spacing = HOK_Connector_Inset*2 - clearance)
                    xcopies(spacing = HOK_Connector_Spacing_Depth)
                    up(Riser_Width/2-clearance)
                    xrot(90) zrot(90) down(Riser_Height/2 + 0.01)
                    HOKConnectorDeleteTool(spin=90);
                //drawer slides
                attach(["start", "end"], BOT, inside=true, shiftout=-Slide_Width/2 + 0.01)
                    ycopies(spacing = Slide_Vertical_Separation, sp=[0,Slide_Distance_From_Bottom], n = number_of_slides)
                        xrot(-90)zrot(-90)down(Riser_Height/2 + 0.01)
                        Drawer_Slide(deleteTool = true);
                //backer tab slots
                //right(Riser_Width/2 - Backer_To_Riser_Tab_Inset - TopPlateTabWidth/2 - clearance)
                attach([LEFT, RIGHT], BOT, inside=true, shiftout=0.01)
                    yrot($idx == 0 ? 45 : -45)
                        left((Riser_Width/2 - Backer_To_Riser_Tab_Inset - TopPlateTabWidth/2 - clearance) * ($idx == 0 ? 1 : -1))
                            TopPlateTab(height = Backer_To_Riser_Tab_Depth + clearance, deleteTool = true);
                children();
                
            }
            if(arc >= 15)
            tag("remove")
                down(0.01)
                back(arc < 25 ? 30 + 25 - arc : 30)
                zrot(180-arc/2)
                path_sweep(riserDeleteSize, riserDeletePath, anchor=anchor,spin=spin,orient=orient);
        }

    riserPath = rect([depth, height]);
    riserDeleteSize = rect([depth, height+0.02]);
    riserExtrusionPath = turtle([
        "move", Riser_Width/2,
        "arcleft", Riser_Depth/2 + radius, arc,
        "move", Riser_Width/2,
    ]);
    riserDeletePath = turtle([
        "arcleft", (Riser_Depth/2 + radius) - (arc < 45 ? (45 - arc) *1.6 : 0), arc, //if arc is less than 45, subtract from radius here the amount less than 45
    ]);
}
//END EXTRUDED SERIES



module topPlateBuilderShape(totalHeight = 9.5, bottomChamfer = 6, topChamfer = 1, topInset = 0.5, half = LEFT, topRecess = 1, $fn = 150){
    //takes any 2D shape and builds a top plate to match
    //for end pieces, this shape is expected to be split down the middle to produce symmetrical sides
    //the children() is the 2D shape received when this module is called

    //totalHeight is the base of the top plate to the top of the lip (i.e., the true total height)
    //topRecess is the depth of the top cutout (i.e., if inserting a material, it is the thickness of the material. Otherwise considered the lip height)
    middleSectionHeight = totalHeight - bottomChamfer - topChamfer;  


    translate([0,0,bottomChamfer])
    difference(){
        chamferedBody() children();
        topCutout() children();
    }

    module chamferedBody(){
        middleSection() children();
        topChamfer() children();
        bottomChamfer() children();
    }

    module topCutout(){
        translate([0,0,middleSectionHeight+topChamfer-topRecess+0.001])
        linear_extrude(topRecess+0.01)
            offset(delta=-topInset-topChamfer)
                children(); 
    }

    module middleSection()
        linear_extrude(totalHeight-topChamfer - bottomChamfer)
            children();
    
    module topChamfer()
        intersection(){
            scopeBody() children();
            translate([0,0,middleSectionHeight])
                roof()
                    children();
        }

    module scopeBody()
        translate([0,0,-bottomChamfer])
            linear_extrude(totalHeight)
                children();

    module bottomChamfer()
        intersection(){
            mirror([0,0,1])
                roof()
                    children();
            scopeBody() children();
        }
}

module baseplateEndSquared(width = 120, depth = 207, height = 19, radius = 50, spin = 0, orient = UP, anchor=CENTER){
    //NOTE: attachments are being passed through from main_section
    
    $fn = 150;
  
    color(Disable_Colors ? undef : Primary_Color)
    diff("HOKConnectors", "k1")
        diff("r1", "keep HOKConnectors"){
            main_section(spin = spin, orient = orient, anchor = anchor){
                //top cutout
                tag("r1")
                attach(TOP, TOP, inside=true, shiftout=0.01)            
                    intersection(){
                        translate([-baseplateEndLateralWidth/2,-depth/2])
                            roof()
                                rect([baseplateEndLateralWidth*2,depth], rounding = radius);
                        cube([baseplateEndLateralWidth*2,depth, Top_Bot_Plates_Interface_Chamfer], center=true);
                    }
                //inside deep cutout
                tag("r1")
                attach(TOP, TOP, inside=true, shiftout=0.01, align=RIGHT)
                    cuboid([baseplateEndAngleDistance-Minimum_Flat_Resting_Surface*3-radius/2, depth-Minimum_Flat_Resting_Surface*2-Top_Bot_Plates_Interface_Chamfer*2, height-Tile_Thickness+Top_Bot_Plates_Interface_Chamfer],  chamfer = (height - Tile_Thickness), edges=BOT, except_edges=RIGHT);
                if(Additional_Top_Plate_Support)
                    //middle support
                    tag("keep")
                    down(Top_Bot_Plates_Interface_Chamfer)
                    attach(TOP, TOP, inside=true, align=RIGHT)
                        cuboid([20,28*4,height - 4], chamfer=height-Tile_Thickness, edges=TOP, except_edges=RIGHT)
                            tag("HOKConnectors")
                            attach(RIGHT, BOT, inside=true, shiftout = 0.01, align=TOP) 
                                    xcopies(spacing = Dovetail_Spacing)
                                        Dovetail_Female();
                                    //dovetail("female", slide=Dovetail_Depth, width=Dovetail_Width, height=Dovetail_Height,chamfer=0.6);
                //top plate tabs
                tag("keep")
                attach(BOT, BOT, inside=true, shiftout=0.01, align=RIGHT, inset=TabDistanceFromOutsideEdge)
                    TopPlateTab(height = height + TabProtrusionHeight, deleteTool = false);
                //HOK Connector cutouts
                tag("HOKConnectors")
                attach(BOT, BOT, inside=true, shiftout=0.01, align=RIGHT, spin=90, inset = HOK_Connector_Inset-HOK_Connector_Thickness/2-clearance) 
                    xcopies(spacing=HOK_Connector_Spacing_Depth)
                    //zrot(90)
                        HOKConnectorDeleteTool();
                //openGrid
                /* disabling for now due to print orientation challenges
                tag("r1")
                    attach(BOT, BOT, inside=true, align=RIGHT)
                    ycopies(spacing = openGridSize*5)
                    up(Tile_Thickness-4+0.02) left(openGridSize/2 - clearance)
                        cube([openGridSize,openGridSize,height])
                            tag("keep")                                
                                
                                attach(BOT, BOT, inside=true, align=RIGHT)
                                    openGridLite(Board_Width = 1, Board_Height = 1);
                */
                children();
            }
    }

    module main_section(spin = 0, orient = UP, anchor=CENTER){
        attachable(anchor, spin, orient, size=[baseplateEndLateralWidth,depth,height+Top_Bot_Plates_Interface_Chamfer]){
            //build base
            translate([baseplateEndLateralWidth/2,0,-(height+Top_Bot_Plates_Interface_Chamfer)/2])
            mirror([0, 0, 1])
            intersection(){
                tilt(); //tilt bevel stretched upward
                
                base(); //base bevel stretched upward

                //rest                
                translate([-width/2, 0])
                    linear_extrude((height+Top_Bot_Plates_Interface_Chamfer)*2, center = true)
                    square([width, depth], true);
            }
            children();
        }
    }

    //the lower chamfer section
    module base() {
        
        stretch()
        down(baseplateEndAngleBevel)
        intersection(){
            //basechamfer
            //scale([1, 1, 1])
            roof()
            square([width*2, depth], true);
            
            linear_extrude(baseplateEndAngleBevel)
            square([width*2, depth], true);
        }
    }

        //tilt();

    module tilt() {
        stretch()
        rotate([0, -baseplateEndAngleUp, 0])
        intersection(){
            roof()
            radius(radius)
            square([baseplateEndAngleDistance*2, depth], true);
            
            linear_extrude(baseplateEndAngleBevel/2)
            square([baseplateEndAngleDistance*2, depth], true);
        }    
    }

    module stretch() { 
        minkowski(){
            children();
            
            mirror([0, 0, 1])
            cylinder(r1 = 0, r2 = 0.001, h = 100);
        }
    }

    module radius(amount) {
        offset(r = amount)
        offset(delta = -amount)
        children();
    }
}

module BasePlateEndRounded(width, depth, height = 19, half = LEFT, style="Oct"){

    $fn = 
        style == "Rounded" ? curve_resolution : 
        style == "Oct" ? 8 :
        style == "Hex" ? 6 :
        curve_resolution;

    //adjust the diameter if a hexagon
    adjusted_diameter = 
        style == "Hex" ? depth * sqrt(3) / 1.5 +1: depth;

    color(Disable_Colors ? undef : Primary_Color)
    half_of(half, s = adjusted_diameter*2 + 5)
    diff("HOKConnectors Dovetails", "k1")
    diff("r1", "keep HOKConnectors Dovetails"){
        //main plate
        cyl(d=adjusted_diameter, h= height+Top_Bot_Plates_Interface_Chamfer, anchor=BOT){
            //bot chamfer
            tag("r1")
            edge_profile([BOT])
                mask2d_chamfer(x=Baseplate_Bottom_Chamfer);
            //top chamfer
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cyl(d=adjusted_diameter, h=Top_Bot_Plates_Interface_Chamfer, chamfer1 = Top_Bot_Plates_Interface_Chamfer);
            //inside cutout
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.02)
                cyl(d=depth-Minimum_Flat_Resting_Surface*2-Top_Bot_Plates_Interface_Chamfer*2, h=height-Tile_Thickness+Top_Bot_Plates_Interface_Chamfer, chamfer1 = (height - Tile_Thickness));
            //top plate tabs
            tag("keep")
            right(half == LEFT ? -TabDistanceFromOutsideEdge-TopPlateTabWidth/2 : TabDistanceFromOutsideEdge+TopPlateTabWidth/2)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                TopPlateTab(height = height + TabProtrusionHeight, deleteTool = false);

            //HOK Connector cutouts
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01) 
                grid_copies(spacing=[HOK_Connector_Inset*2-clearance*2,HOK_Connector_Spacing_Depth])
                zrot(90)
                    HOKConnectorDeleteTool();
            if(Additional_Top_Plate_Support)
                //middle support
                tag("keep")
                down(Top_Bot_Plates_Interface_Chamfer)
                attach(TOP, TOP, inside=true)
                    cuboid([28*2.5-2,28*4,height - 4], chamfer=height-Tile_Thickness, edges=[TOP])
                    //dovetails
                    right(half == LEFT ? -4.5 : 4.5)zrot(half == LEFT ? 90 : -90)
                    tag("Dovetails")
                        attach(TOP, BACK, inside=true, shiftout = 0.01) 
                            xcopies(spacing = Dovetail_Spacing)
                                Dovetail_Female();
                                //dovetail("female", slide=Dovetail_Depth, width=Dovetail_Width, height=Dovetail_Height,chamfer=Dovetail_Chamfer);
        }
    }
}

//BEGIN ORIGINAL CORE PARTS
module TopPlateCore(width, depth, thickness, spin = 0, orient = UP, anchor=CENTER){

    color(Disable_Colors ? undef : Top_Plate_Color)
    diff()
    cuboid([width-clearance*2, depth+Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2, thickness+topLipHeight], spin=spin, orient=orient, anchor=anchor){
        //bot chamfer
        edge_profile([BOT+FRONT, BOT+BACK])
            mask2d_chamfer(x=Top_Bot_Plates_Interface_Chamfer*2);
        //top chamfer
        edge_profile([TOP+FRONT, TOP+BACK])
            mask2d_chamfer(x=topChamfer);
        //top lip cutout
        attach(TOP, TOP, inside=true, shiftout=0.01)
            cuboid([width+0.02, depth+Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2 - topChamfer*2-topLipWidth*2, topLipHeight]);
        //top plate tabs
        attach(BOT, BOT, inside=true, shiftout=0.01, align=[LEFT, RIGHT], inset=TabDistanceFromOutsideEdge-clearance)
            TopPlateTab(height = TabProtrusionHeight, deleteTool = true);
        children();
    }
}
module BasePlateCore(width, depth, height = 19, spin = 0, orient = UP, anchor=CENTER){


    color(Disable_Colors ? undef : Primary_Color)
    diff("HOKConnectors Dovetails", "k1")
        diff("r1", "keep HOKConnectors Dovetails"){
        //main plate
        cuboid([width-clearance*2, depth, height + Top_Bot_Plates_Interface_Chamfer], chamfer=Baseplate_Bottom_Chamfer, edges=BOT+FRONT, anchor=BOT, spin=0,orient=UP){
            //top chamfer
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cuboid([width+0.02, depth, Top_Bot_Plates_Interface_Chamfer+0.02], chamfer = Top_Bot_Plates_Interface_Chamfer, edges=[BOT+FRONT, BOT+BACK]);
            //Inside cutout
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cuboid([width+0.02, depth-Minimum_Flat_Resting_Surface*2-Top_Bot_Plates_Interface_Chamfer*2, height + Top_Bot_Plates_Interface_Chamfer - Tile_Thickness +0.02],  chamfer = (height - Tile_Thickness), edges=[BOT+FRONT, BOT+BACK]);
            //cutout for opengrid and opengrid. 
            tag("r1")
            attach(BOT, BOT, inside=true, shiftout=0.01)
                cuboid([Grid_Width_mm, Grid_Depth_mm, Tile_Thickness+0.01]){
                    tag("keep")
                        openGrid(Board_Width = openGrid_Render ? Available_openGrid_Width_Units : 1, Board_Height = openGrid_Render ? Available_openGrid_Depth_Units : 1, Tile_Thickness = Tile_Thickness);
                }
            //top plate tabs
            tag("keep")
            attach(BOT, BOT, inside=true, align=[LEFT, RIGHT], inset=TabDistanceFromOutsideEdge)
                TopPlateTab(height = height + TabProtrusionHeight);
            //middle support
            tag_this("keep")
            down(Top_Bot_Plates_Interface_Chamfer)
                attach(TOP, TOP, inside=true, align=[LEFT, RIGHT])
                    cuboid([28*(Additional_Top_Plate_Support + 0.5),28*((Available_openGrid_Depth_Units % 2 == 0 ? 4 : 3)),height - 6.8], chamfer=height-Tile_Thickness, edges=[TOP], except=$idx == 0 ? LEFT : RIGHT){
                        //dovetail
                        tag("Dovetails")
                            attach($idx == 0 ? LEFT : RIGHT, BOT, inside=true, shiftout = 0.01, align=TOP) 
                                xcopies(spacing = Dovetail_Spacing)
                                Dovetail_Female();
                        //display-only male dovetails
                        //if(Show_Connected){
                        //    #tag("keep")
                        //    back($idx == 0 ? Dovetail_Width/2 : -Dovetail_Width/2)
                        //        attach(TOP, TOP, inside=true, shiftout = 0.01, align=$idx == 0 ? LEFT : RIGHT, inset = 0) 
                        //            ycopies(spacing = Dovetail_Spacing)
                        //                zrot(90)
                        //                    Dovetail_Male();
                        //}
                    }
            children();
        
            //HOK connector cutouts back
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01, align=BACK) 
                    fwd(HOK_Connector_Inset-HOK_Connector_Thickness/2)
                    xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                        HOKConnectorDeleteTool(anchor=CENTER);
            //HOK connector cutouts sides
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01, align=[LEFT, RIGHT], inset=HOK_Connector_Inset-clearance) 
                    back($idx == 1 ? HOK_Connector_Width/2 : -HOK_Connector_Width/2)
                    ycopies(spacing = HOK_Connector_Spacing_Depth)
                            HOKConnectorDeleteTool(spin=90);
        }
    }
}

module Backer(anchor=BOT, spin=0, orient=UP){

        //main body
        color(Disable_Colors ? undef : Primary_Color)
        diff("HOKConnector", "k1")
        diff("remove", "keep HOKConnector"){
            cuboid([Backer_Width-clearance*2, Backer_Thickness, Backer_Height], anchor=anchor, orient=orient, spin=spin){
                //clear space for opengrid
                //if(Available_Grid_Height>0)
                up(Grid_Dist_From_Bot)
                    attach(BACK, BOT, inside=true, align=BOT, shiftout=0.01) 
                        cuboid([Available_openGrid_Width_Units*openGridSize-0.02, Available_Grid_Height > 0 ? Available_Grid_Height*openGridSize -0.02 : Backer_Height - minimumTopSpacing - Grid_Dist_From_Bot, Backer_Thickness+0.02]);
                //opengrid
                tag("keep")
                up(Grid_Dist_From_Bot)
                attach(BACK, BOT, inside=true, align=BOT) 
                    openGrid(openGrid_Render ? Available_openGrid_Width_Units : 1, openGrid_Render ? Available_Grid_Height : 1)
                        //HOK Tab Blocks
                        if(enableHOKBlocks)
                        xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                        attach(BOT, TOP, inside=true, align=BACK, shiftout=0.01)
                            cuboid([openGridSize, openGridSize, Backer_Thickness-sideCutoutDepth], chamfer=0.5, edges=BOT, except_edges=BACK);
                //cutouts for risers
                attach(FRONT, FRONT, inside=true, shiftout=0.01, align=[LEFT, RIGHT])
                    cuboid([sideCutoutWidth,sideCutoutDepth,Backer_Height+0.02]);
                //HOK Connector cutouts
                tag("HOKConnector")
                attach(TOP, BOT, inside=true, shiftout=0.01, align=BACK) 
                    fwd(HOK_Connector_Inset-HOK_Connector_Thickness/2)
                    xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                        HOKConnectorDeleteTool(anchor=CENTER);
                //Riser Tabs
                tag("keep")
                attach(BACK, BOT, align=[LEFT, RIGHT], inset=Backer_To_Riser_Tab_Inset-clearance, inside=true)
                    TopPlateTab(height = Backer_Thickness - sideCutoutDepth + Backer_To_Riser_Tab_Depth, deleteTool = false);

                children();
            }
        }          

}

module RiserSplit(slideSides = "BOTH", height1 = Outer_Riser_Height, height2 = Inner_Riser_Height, chamfer = 0, reverseSides = false, anchor=BOT, spin=0, orient=UP){

    slideSidesReversed = 
        slideSides == "BOTH" ? "BOTH" : 
        slideSides == "LEFT" ? "RIGHT" :
        slideSides == "RIGHT" ? "LEFT" : 
        "NONE";

    echo(str("Side Slides in RiserSplit: ", slideSides));
    echo(str("Reversed Side Slides in RiserSplit: ", slideSidesReversed));

    union(){
        left_half(s = Core_Section_Depth*2)
            Riser(slideSides = reverseSides ? slideSidesReversed : slideSides, chamfer = chamfer, height = reverseSides ? height2 : height1);
        right_half(s = Core_Section_Depth*2)
            Riser(slideSides = reverseSides ? slideSidesReversed : slideSides, chamfer = chamfer, height = reverseSides ? height1 : height2);
    }
}

module Riser(slideSides = "BOTH", height = Riser_Height, chamfer = 0, anchor=BOT, spin=0, orient=UP){
    echo(str("Riser() Slide Sides before processing: ", slideSides));
    
    number_of_slides = quantdn((height - Slide_Distance_From_Bottom - Slide_Height - Slide_Minimum_Distance_From_Top)/Slide_Vertical_Separation+1, 1);
    
    
    slideSides = 
        slideSides == "BOTH" ? [LEFT, RIGHT] : 
        slideSides == "LEFT" ? [LEFT] :
        slideSides == "RIGHT" ? [RIGHT] : 
        slideSides == "NONE" ? [] : 
        slideSides;

    echo(str("Slide Sides after processing: ", slideSides));

    //main riser body
    color(Disable_Colors ? undef : Primary_Color)
    diff(){
        cuboid([Riser_Width-clearance*2, Riser_Depth, height], chamfer = chamfer, edges = [FRONT+LEFT, FRONT+RIGHT], anchor=anchor, orient=orient, spin=spin){
            //Slides
            attach(slideSides, LEFT, inside=true, shiftout=0.01, align=BOT) 
                ycopies(spacing = Slide_Vertical_Separation, sp=[0,Slide_Distance_From_Bottom], n = number_of_slides)
                    Drawer_Slide(deleteTool = true);
            //HOK Connector cutouts
            attach([TOP, BOT], BOT, inside=true, shiftout=0.01) 
                grid_copies(spacing=[HOK_Connector_Inset*2-clearance,HOK_Connector_Spacing_Depth])
                zrot(90)
                    HOKConnectorDeleteTool();
            xcopies(spacing = TopPlateTabWidth + Backer_To_Riser_Tab_Inset*2)
            //backer tab holes
            attach(BACK, BOT, inside=true, shiftout=0.01)
                    TopPlateTab(height = Backer_To_Riser_Tab_Depth + clearance, deleteTool = true);
            children();
        }
    }
}
//END ORIGINAL CORE PARTS

//BEGIN ADDON PARTS AND MODIFIERS
module TopPlateTab(height = 19, deleteTool = false, anchor=CENTER, spin=0, orient=UP){
    TopPlateTabWidth = 3;
    TopPlateTabDepth = 20;
    //TopPlateTabHeight = 4;
    TopPlateTabChamfer = 0.5;

    cuboid([ deleteTool ? TopPlateTabWidth + clearance*2 : TopPlateTabWidth, deleteTool ? TopPlateTabDepth + clearance*2 : TopPlateTabDepth, deleteTool ? height + clearance : height], chamfer=TopPlateTabChamfer, except=BOT)
        children();
}

module Dovetail_Male(anchor=CENTER, spin = 0, orient = UP){
    attachable(anchor, spin, orient, size=[Dovetail_Width,Dovetail_Height*2,Dovetail_Depth-0.6]){
        color(Disable_Colors ? undef : Primary_Color)
        mirror_copy([0,1,0])
            dovetail("male", slide=Dovetail_Depth-0.6, width=Dovetail_Width, height=Dovetail_Height,chamfer=Dovetail_Chamfer, taper = -3, slope = 4, anchor=BOT, orient=FRONT);
        children();
    }
}

module Dovetail_Female(anchor=BOT, spin = 0, orient = DOWN){
    dovetail("female", slide=Dovetail_Depth, width=Dovetail_Width, height=Dovetail_Height, chamfer=Dovetail_Chamfer, slope = 4, taper = -3, $slop = 0, anchor=anchor, spin=spin, orient=orient)
        children();
}

module Drawer_Slide(length = Riser_Depth+0.02, deleteTool = false, anchor=CENTER, spin=0, orient=UP){
    
    
    attachable(anchor, spin, orient, size=[Slide_Width,length,Slide_Height]){
        move([-Slide_Width/2, length/2,-Slide_Height/2 ])
            xrot(90)
                linear_sweep(deleteTool ? Drawer_Slide_DeleteTool_Profile() : Drawer_Slide_Profile(), height = length) ;
        children();
    }

    function Drawer_Slide_DeleteTool_Profile() = [
        [0,0],
        [Slide_Width,Slide_Width],
        [Slide_Width,Slide_Height],
        [0,Slide_Height]
    ];

    function Drawer_Slide_Profile() = [
        [0,0],
        [Slide_Width-Slide_Clearance,Slide_Width-Slide_Clearance],
        [Slide_Width-Slide_Clearance,Slide_Height-Slide_Clearance*2],
        [0,Slide_Height-Slide_Clearance*2]
    ];
}



module HOKConnectorDeleteTool(anchor=CENTER, spin=0, orient=UP){
    //thickness = 3.2;
    chamfer = 0.5;

    attachable(anchor, spin, orient, size=[8.9*2,HOK_Connector_Thickness,15.2]){
    down(15.2/2)xrot(90)
        skin( 
            [mirrorXProfile(connector_path_chamfered()), mirrorXProfile(connector_path_full()), mirrorXProfile(connector_path_full()), mirrorXProfile(connector_path_chamfered())],
            z=[-HOK_Connector_Thickness/2,-HOK_Connector_Thickness/2+chamfer, HOK_Connector_Thickness/2-chamfer, HOK_Connector_Thickness/2],
            slices=0
        );
    children();
    }

    //outer profile of connector cutout
    function connector_path_full() = [
        [-7.9, 0],
        [-7.9, 4.875],
        [-8.9, 5.862],
        [-8.9, 8.084],
        [-7.9, 9.097],
        [-7.9, 13.083],
        [-5.783, 15.2],
        //[0, 15.2] midpoint
    ];

    //couldn't figure out the chamfer so I just mapped the points of the smaller profile for now
    function connector_path_chamfered() = [
        [-7.4, 0],
        [-7.4, 5.084],
        [-8.4, 6.071],
        [-8.4, 7.879],
        [-7.4, 8.892],
        [-7.4, 12.876],
        [-5.576, 14.7],
        //[0, 14.7] midpoint
    ];

    function mirrorX(pt) = [ -pt[0], pt[1] ];

    function mirrorXProfile(pathInput) =
        let(
            half = pathInput
        )
        concat(
            half,
            // Mirror in *reverse index* so the final perimeter is a continuous loop
            [ for(i = [len(half)-1 : -1 : 0]) mirrorX(half[i]) ]
        );

}

module DrawerHandleThread(){
    trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=6, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, internal=true, bevel2 = true, blunt_start=false, anchor=TOP, $slop=Slop);
}

module DrawerHandleScrewFemale(anchor=TOP, orient=UP, spin=0){
    trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=6, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, internal=true, bevel2 = true, teardrop = true, blunt_start=false, $slop=0.075, anchor=anchor, orient=orient, spin=spin)
        children();
}

module T_Screw(){
    color(Disable_Colors ? undef : Primary_Color)
    up(2)yrot(90)left_half(x=2)right_half(x=-2)cuboid([4,14,2.5], chamfer=0.75, edges=[LEFT+FRONT, RIGHT+FRONT, RIGHT+BACK, LEFT+BACK], anchor=BOT){
        attach(TOP, BOT) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=10, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false);
    }
}

//END ADDON PARTS AND MODIFIERS

//BEGIN openGrid Import - Replace with import
module openGridLite(Board_Width, Board_Height, tileSize = 28, Screw_Mounting = "None", Bevels = "None", anchor = CENTER, spin = 0, orient = UP, Connector_Holes = false) {
    // Screw_Mounting options: [Everywhere, Corners, None]
    // Bevel options: [Everywhere, Corners, None]
    Tile_Thickness = 6.8;
    Lite_Tile_Thickness = 4;
    
    attachable(anchor, spin, orient, size = [Board_Width * tileSize, Board_Height * tileSize, 4]) {
        render(convexity = 2)
        down(4 / 2)
        down(Tile_Thickness - 4)
        top_half(z = Tile_Thickness - 4, s = max(tileSize * Board_Width, tileSize * Board_Height) * 2)
        openGrid(
            Board_Width = Board_Width,
            Board_Height = Board_Height,
            tileSize = tileSize,
            Screw_Mounting = Screw_Mounting,
            Bevels = Bevels,
            anchor = BOT,
            Connector_Holes = Connector_Holes
        );
    children();
    }
}

module openGrid(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP){
    //Screw_Mounting options: [Everywhere, Corners, None]
    //Bevel options: [Everywhere, Corners, None]

    $fn=30;
    //2D is fast. 3D is slow. No benefits of 3D. 
    Render_Method = "2D";//[3D, 2D]
    Intersection_Distance = 4.2;
    Tile_Thickness = Tile_Thickness;
    
    tileChamfer = sqrt(Intersection_Distance^2*2);
    lite_cutout_distance_from_top = 1;
    connector_cutout_height = 2.4;

    attachable(anchor, spin, orient, size=[Board_Width*tileSize,Board_Height*tileSize,Tile_Thickness]){

        down(Tile_Thickness/2)
        render(convexity=2)
        diff(){
            render() union() {
                grid_copies(spacing = tileSize, n = [Board_Width, Board_Height])

                    if(Render_Method == "2D") openGridTileAp1(tileSize = tileSize, Tile_Thickness = Tile_Thickness);
                        else wonderboardTileAp2();
                
            }
            //TODO: Modularize positioning (Outside Corners, inside corners, inside all) and holes (chamfer and screw holes)
            //Bevel Everywhere
            if(Bevels == "Everywhere" && Screw_Mounting != "Everywhere" && Screw_Mounting != "Corners")
            tag("remove")
                grid_copies(spacing=tileSize, size=[Board_Width*tileSize,Board_Height*tileSize])
                    down(0.01)
                    zrot(45)
                        cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
            //Bevel Corners
            if(Bevels == "Corners" || (Bevels == "Everywhere" && (Screw_Mounting == "Everywhere" || Screw_Mounting == "Corners")))
                tag("remove")
                move_copies([[tileSize*Board_Width/2,tileSize*Board_Height/2,0],[-tileSize*Board_Width/2,tileSize*Board_Height/2,0],[tileSize*Board_Width/2,-tileSize*Board_Height/2,0],[-tileSize*Board_Width/2,-tileSize*Board_Height/2,0]])
                    down(0.01)
                    zrot(45)
                        cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
            //Screw Mount Corners
            if(Screw_Mounting == "Corners")
                tag("remove")
                move_copies([[tileSize*Board_Width/2-tileSize,tileSize*Board_Height/2-tileSize,0],[-tileSize*Board_Width/2+tileSize,tileSize*Board_Height/2-tileSize,0],[tileSize*Board_Width/2-tileSize,-tileSize*Board_Height/2+tileSize,0],[-tileSize*Board_Width/2+tileSize,-tileSize*Board_Height/2+tileSize,0]])
                up(Tile_Thickness+0.01)
                    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                            attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
            //Screw Mount Everywhere
            if(Screw_Mounting == "Everywhere")
                tag("remove")
                grid_copies(spacing=tileSize, size=[(Board_Width-2)*tileSize,(Board_Height-2)*tileSize])            up(Tile_Thickness+0.01)
                    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                            attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
            if(Connector_Holes){
                if(Board_Height > 1)
                tag("remove")
                up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
                xflip_copy(offset = -tileSize*Board_Width/2-0.005)
                    ycopies(spacing=tileSize, l=Board_Height > 2 ? Board_Height*tileSize-tileSize*2 : Board_Height*tileSize - tileSize - 1)
                        connector_cutout_delete_tool(anchor=LEFT);
                if(Board_Width > 1)
                tag("remove")
                up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
                yflip_copy(offset = -tileSize*Board_Height/2-0.005)
                    xcopies(spacing=tileSize, l=Board_Width > 2 ? Board_Width*tileSize-tileSize*2 : Board_Width*tileSize-tileSize-1)
                        zrot(90)
                            connector_cutout_delete_tool(anchor=LEFT);
            }

        }//end diff
        children();
    }

    //BEGIN CUTOUT TOOL
    module connector_cutout_delete_tool(anchor=CENTER, spin=0, orient=UP){
        //Begin connector cutout profile
        connector_cutout_radius = 2.6;
        connector_cutout_dimple_radius = 2.7;
        connector_cutout_separation = 2.5;
        connector_cutout_height = 2.4;
        dimple_radius = 0.75/2;
        
        attachable(anchor, spin, orient, size=[connector_cutout_radius*2-0.1 ,connector_cutout_radius*2,connector_cutout_height]){
            //connector cutout tool
            tag_scope()
            translate([-connector_cutout_radius+0.05,0,-connector_cutout_height/2])
            render()
            half_of(RIGHT, s=connector_cutout_dimple_radius*4)
                linear_extrude(height = connector_cutout_height) 
                union(){
                    left(0.1)
                    diff(){
                        $fn=50;
                        //primary round pieces
                        hull()
                            xcopies(spacing=connector_cutout_radius*2)
                                circle(r=connector_cutout_radius);
                        //inset clip
                        tag("remove")
                        right(connector_cutout_radius-connector_cutout_separation)
                            ycopies(spacing = (connector_cutout_radius+connector_cutout_separation)*2)
                                circle(r=connector_cutout_dimple_radius);
                    }
                    //outward flare fillet for easier insertion
                    rect([1,connector_cutout_separation*2-(connector_cutout_dimple_radius-connector_cutout_separation)], rounding=[0,-.25,-.25,0], $fn=32, corner_flip=true, anchor=LEFT);
                }
            children();
        }
    }
    //END CUTOUT TOOL

    module openGridTileAp1(tileSize = 28, Tile_Thickness = 6.8){
        Tile_Thickness = Tile_Thickness;
        
        Outside_Extrusion = 0.8;
        Inside_Grid_Top_Chamfer = 0.4;
        Inside_Grid_Middle_Chamfer = 1;
        Top_Capture_Initial_Inset = 2.4;
        Corner_Square_Thickness = 2.6;
        Intersection_Distance = 4.2;

        Tile_Inner_Size_Difference = 3;



        calculatedCornerSquare = sqrt(tileSize^2+tileSize^2)-2*sqrt(Intersection_Distance^2/2)-Intersection_Distance/2;
        Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference; //25mm default
        insideExtrusion = (tileSize-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
        middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
        cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default

        CalculatedCornerChamfer = sqrt(Intersection_Distance^2 / 2);
        cornerOffset = CalculatedCornerChamfer + Corner_Square_Thickness; //5.56985 (half of 11.1397)

        CorderSquareWidth = sqrt(Corner_Square_Thickness^2 + Corner_Square_Thickness^2)+Intersection_Distance;
        
        full_tile_profile = [
            [0,0],
            [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,0],
            [Outside_Extrusion+insideExtrusion,Inside_Grid_Top_Chamfer],
            [Outside_Extrusion+insideExtrusion,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion,Top_Capture_Initial_Inset],
            [Outside_Extrusion,Tile_Thickness-Top_Capture_Initial_Inset],
            [Outside_Extrusion+insideExtrusion,Tile_Thickness-Top_Capture_Initial_Inset+Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion+insideExtrusion,Tile_Thickness-Inside_Grid_Top_Chamfer],
            [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,Tile_Thickness],
            [0,Tile_Thickness]
            ];
        full_tile_corners_profile = [
            [0,0],
            [cornerOffset-cornerChamfer,0],
            [cornerOffset,cornerChamfer],
            [cornerOffset,Tile_Thickness-cornerChamfer],
            [cornerOffset-cornerChamfer,Tile_Thickness],
            [0,Tile_Thickness]

            ];
        
        path_tile = [[tileSize/2,-tileSize/2],[-tileSize/2,-tileSize/2]];
        
        intersection() {
        union() {
            zrot_copies(n=4)
                union() {
                    path_extrude2d(path_tile) 
                        polygon(full_tile_profile);
                    move([-tileSize/2,-tileSize/2])
                        rotate([0,0,45])
                            back(cornerOffset)
                                rotate([90,0,0])
                                    linear_extrude(cornerOffset*2) 
                                        polygon(full_tile_corners_profile);
                }
        } 
        cube([tileSize, tileSize, Tile_Thickness], anchor = BOT);
        }
    }
}