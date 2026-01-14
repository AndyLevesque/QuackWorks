include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/*Created by Hands on Katie and BlackjackDuck (Andy)
Credit to 
    Katie (and her community) at Hands on Katie on Youtube and Patreon
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for MulticonnMultiboard
    @Dontic on GitHub for Multiconnect v2 code

Change Log:
- 2025-07-17
    - Initial Release
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
    
Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
*/

/*[Mounting Options]*/
//Mounting_Style = "Multiconnect"; //[Multiconnect, Threaded Snap] //not yet implemented
Mounting_Surface = "Multiboard"; //[Multiboard, openGrid]
Slot_Count = 2;

/*[Hook Parameters]*/
Number_of_Grooves = 6; //[2:2:20]
//Depth (mm) of the inside of each groove
Groove_Depth = 10;
//Width (mm) of the inside of each groove
Groove_Width = 10;
//Length (mm) of the center post. Deeper grooves may require a longer center post.
Center_Post_Length = 20;

/*[Advanced Options]*/
//Depth (mm) of the entire hook. 25mm minimum recommended for the multiconnect. 
Hook_Depth = 25;
//Thickness (mm) of the center post. 
Center_Post_Thickness = 4;
//Thickness (mm) of the base of the hook.
Base_Thickness = 4;
//Thickness (mm) of the individual posts between the grooves.
Individual_Post_Thickness = 4;
//Chamfer (mm) of the edges of the hook.
Chamfer = 1; //0.1

/*[Advanced - Tile Parameters]*/
//Customize tile sizes - openGrid standard is 28mm
Tile_Size = 28;
//Thickness of the tile (standard only)
Tile_Thickness = 6.8;

/*[Advanced - Slot Customization]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
//Offset the multiconnect on-ramps to be between grid slots rather than on the slot
onRampHalfOffset = true;
//Change slot orientation, when enabled slots to come from the top of the back, when disabled slots come from the bottom
Slot_From_Top = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
Custom_Distance_Between_Slots = 25;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot (Y axis) inwards (positive) or outwards (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//Enable a slot on-ramp for easy mounting of tall items
onRampEnabled = false;
//Frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
On_Ramp_Every_X_Slots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
Multiconnect_Stop_Distance_From_Back = 13;

Force_Back_Thickness = 0; //0.1

/*[Hidden]*/
debug_3d = true;

Backer_Negatives_Only = false; //If true, the backer will be negative space. If false, the backer will be positive space.
//Set to 0 to use the default thickness of the back. Set to a number to force the back to be that thickness.

distanceBetweenSlots = 
    Mounting_Surface == "Multiboard" ? 25 : 
    Mounting_Surface == "openGrid" ? 28 : 
    Custom_Distance_Between_Slots;

onRampEveryXSlots = 
    onRampHalfOffset ? On_Ramp_Every_X_Slots : 
    On_Ramp_Every_X_Slots == 1 ? 2 : On_Ramp_Every_X_Slots;

/*[Standard Parameters]*/
//Profile
//Select_Profile = "Standard"; //[Standard, Jr., Mini, Multipoint Beta, Custom]
//Select_Part_Type = "Connector Round"; //[Connector Round, Connector Rail, Connector Double sided Round, Connector Double-Sided Rail, Connector Rail Delete Tool, Receiver Open-Ended, Receiver Passthrough, Backer Open-Ended, Backer Passthrough]
//Generate one of each type of part
//Length of rail (in mm) (excluding rounded ends)
//Length = 25; 

/* [Hidden] */

///*[Style Customizations]*/
//Edge rounding (by mm)
edgeRounding = 0.5; // [0:0.1:2]

///*[Rail Customization]*/
//Rounding of rail ends
Rounding = "Both Sides";//[None, One Side, Both Sides]

///*[Receiver Customization]*/
Receiver_Side_Wall_Thickness = 2.5;
Receiver_Back_Thickness = 2;
Receiver_Top_Wall_Thickness = 2.5;
OnRamps = "Enabled"; //[Enabled, Disabled]
OnRamp_Every_n_Holes = 2;
OnRamp_Start_Offset = 1;

///*[Backer Customization]*/
Width = 50; 

///*[AdvancedParameters]*/
//Distance (in mm) between each grid (25 for Multiboard)
Grid_Size = 25;

///*[Custom MC Builder]*/
//Radius of connector
Radius = 10; //.1
//Depth of inside capture
Depth1 = 1; //.1
//Lateral depth of angle dovetail
Depth2 = 2.5; //.1
//Depth of stem
Depth3 = 0.5; //.1
//Offset/Tolerance of receiver part
Offset = 0.15; //.01
//Radius (in mm) of dimple
DimpleSize = 1; //.1

//unadjusted cordinates, dimple size, default offset
customSpecs = [Radius, Depth1, Depth2, Depth3, Offset, DimpleSize];
standardSpecs = [10, 1, 2.5, 0.5, 0.15, 1];
jrSpecs = [5, 0.6, 1.2, 0.4, 0.16, 0.8];
miniSpecs = [3.2, 1, 1.2, 0.4, 0.16, 0.8];
multipointBeta = [7.9, 0.4, 2.2, 0.4, 0.15, 0.8];

debug = false; 

onRampEveryNHoles = OnRamp_Every_n_Holes * distanceBetweenSlots;
onRampOffset = OnRamp_Start_Offset * distanceBetweenSlots;


/*

START PARTS

*/
//3D Version

if(debug_3d)
test_shape();

module test_shape() {
    attachable(size=[Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Hook_Depth,Base_Thickness+Center_Post_Length]){
        down(Center_Post_Length/2)
        union()
        //base`
        cuboid([Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Hook_Depth,Base_Thickness], chamfer=Chamfer, edges=[BOT,TOP, LEFT, RIGHT]){
            //center post
            attach(TOP, BOT, overlap=Chamfer) cuboid([Center_Post_Thickness,Hook_Depth,Center_Post_Length+Chamfer])
                attach(TOP, BACK) 
                    multiconnectBack(distanceBetweenSlots*Slot_Count, Hook_Depth, distanceBetweenSlots, slotStopFromBack = 13);
            attach(TOP, BOT, overlap=Chamfer) xflip_copy()
                xcopies(sp=[Center_Post_Thickness/2+Groove_Width+Individual_Post_Thickness/2,0,0], n = Number_of_Grooves/2, spacing = Groove_Width+Individual_Post_Thickness) 
                    //individual post
                    cuboid([Individual_Post_Thickness, Hook_Depth,Groove_Depth+Chamfer], chamfer=Chamfer, except_edges= $idx == 1 ? [BOT] : [BOT]);
        } 
        children();
    }
}

if(!debug_3d)
// 2D ATTEMPT
    union()
    rect([89,10], rounding=[0,0,5,5], $fn=15){
        //center post
            attach(TOP, BOT) rect([5,20]);
            //individual posts
            xflip_copy()attach(TOP, BOT)
                xcopies(sp=[14.5,0], n = 3, spacing = 14) 
                    //individual post
                    rect([4, 10], rounding=[1.5,1.5,0,0], $fn=15);
    }

//offset_sweep(object_profile, height=20); 
//!linear_extrude(height = 20) object_profile();

//bottom rail
module hook_profile() {
    linear_extrude(height = Hook_Depth)
    rect([Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Base_Thickness], rounding=[0,0,Base_Thickness,Base_Thickness], $fn=15){
    //center post
        attach(TOP, BOT) rect([Center_Post_Thickness,Center_Post_Length]);
        //individual posts
        xflip_copy()attach(TOP, BOT)
            xcopies(sp=[Center_Post_Thickness/2+Groove_Width+Individual_Post_Thickness/2,0], n = Number_of_Grooves/2, spacing = Groove_Width+Individual_Post_Thickness) 
                //individual post
                rect([Individual_Post_Thickness, Groove_Depth], rounding=[1.5,1.5,0,0], $fn=15);
    }
}
/*
union()
rect([Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Base_Thickness], rounding=[0,0,Base_Thickness,Base_Thickness], $fn=15){
    //center post
        attach(TOP, BOT) rect([Center_Post_Thickness,Center_Post_Length]);
        //individual posts
        xflip_copy()attach(TOP, BOT)
            xcopies(sp=[Center_Post_Thickness/2+Groove_Width+Individual_Post_Thickness/2,0], n = Number_of_Grooves/2, spacing = Groove_Width+Individual_Post_Thickness) 
                //individual post
                rect([Individual_Post_Thickness, Groove_Depth], rounding=[1.5,1.5,0,0], $fn=15);
    }
;



/*

BEGIN Multiconnect Modules and Functions

*/

//Threaded back
module threadedSnapBack(backWidth, backHeight, distanceBetweenSlots, anchor=BOT, orient=UP, spin=0){
    diff()
    tag(Backer_Negatives_Only ? "remove" : "")
    cuboid(size = [backWidth, Force_Back_Thickness == 0 ? 3.59 : Force_Back_Thickness, backHeight], rounding=edgeRounding, except_edges=BACK, anchor=anchor, orient=orient, spin=spin){ 
        tag(Backer_Negatives_Only ? "keep" : "remove")
        attach(FRONT, BOT, inside=true, shiftout=0.01)
            grid_copies(size = [backWidth - Outer_Diameter_Sm*2, backHeight - Outer_Diameter_Sm*2], spacing = distanceBetweenSlots)
                trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=3.6, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, internal=true, bevel2 = true, blunt_start=false, teardrop=true, anchor=TOP, $slop=Slop);
        children();
    };
}

//Slotted back Module
module multiconnectBack(backWidth, backHeight, distanceBetweenSlots, slotStopFromBack = 13, anchor = BOT, spin = 0, orient = UP)
{   
        //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
        //slot width needs to be at least the distance between slot for at least 1 slot to generate
        let (backWidth = max(backWidth,distanceBetweenSlots), backHeight = max(backHeight, 25),slotCount = floor(backWidth/distanceBetweenSlots), backThickness = Force_Back_Thickness == 0 ? 6.5 : Force_Back_Thickness){
            attachable(anchor, spin, orient, size = [backWidth, backThickness, backHeight]) {
            translate([-backWidth/2, backThickness/2, -backHeight/2])
            diff() {
                tag(Backer_Negatives_Only ? "remove" : "")
                    translate(v = [0,-backThickness,0]) 
                        cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, except_edges=BACK, anchor=FRONT+LEFT+BOT);
                //Loop through slots and center on the item
                //Note: I kept doing math until it looked right. It's possible this can be simplified.
                for (slotNum = [0:1:slotCount-1]) {
                    force_tag(Backer_Negatives_Only ? "keep" : "remove")    
                        translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment + (Force_Back_Thickness == 0 ? 0 : 6.5 - Force_Back_Thickness),backHeight-slotStopFromBack]){
                            if(Backer_Negatives_Only)
                                back_half(y=-4.15, s=backHeight * 2 + 20)
                                    slotTool(backHeight);
                            else 
                                slotTool(backHeight);
                        }
                }
            }
            children();
        }
        
    }
    //Create Slot Tool
    module slotTool(totalDepth) {
        //In slotTool, added a new variable distanceOffset which is set by the option:
        distanceOffset = onRampHalfOffset ? distanceBetweenSlots / 2 : 0;

        scale(v = slotTolerance)
        //slot minus optional dimple with optional on-ramp
        let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
        difference() {
            union() {
                //round top
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = slotProfile);
                //long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0]) 
                    union(){
                        difference() {
                            // Main half slot
                            linear_extrude(height = totalDepth+1) 
                                polygon(points = slotProfile);
                            
                            // Snap cutout
                            if (slotQuickRelease == false && multiConnectVersion == "v2")
                                translate(v= [10.15,0,0])
                                rotate(a= [-90,0,0])
                                linear_extrude(height = 5)  // match slot height (5mm)
                                    polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 specs
                            }

                        mirror([1,0,0])
                            difference() {
                                // Main half slot
                                linear_extrude(height = totalDepth+1) 
                                    polygon(points = slotProfile);
                                
                                // Snap cutout
                                if (slotQuickRelease == false && multiConnectVersion == "v2")
                                    translate(v= [10.15,0,0])
                                    rotate(a= [-90,0,0])
                                    linear_extrude(height = 5)  // match slot height (5mm)
                                        polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 spec
                            }
                    }
                //on-ramp
                if(onRampEnabled)
                    for(y = [1:onRampEveryXSlots:totalDepth/distanceBetweenSlots])
                        //then modify the translate within the on-ramp code to include the offset
                        translate(v = [0,-5,(-y*distanceBetweenSlots)+distanceOffset])
                            rotate(a = [-90,0,0]) 
                                cylinder(h = 5, r1 = 12, r2 = 10.15);
            }
            //dimple
            if (slotQuickRelease == false && multiConnectVersion == "v1")
                scale(v = dimpleScale) 
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = [[0,0],[0,1.5],[1.5,0]]);
        }
    }
}

//calculate the max x and y points. Useful in calculating size of an object when the path are all positive variables originating from [0,0]
function maxX(path) = max([for (p = path) p[0]]);
function maxY(path) = max([for (p = path) p[1]]);

//this function takes the measurements of a multiconnect-style dovetail and converts them to profile coordinates. 
//When generating the male connector, set offsetMM to zero. Otherwise standard is 0.15 offset for delete tool
function dimensionsToCoords(radius, depth1, depth2, depth3, offsetMM) = [
    [0,0],
    [radius+offsetMM, 0],
    [radius+offsetMM,offsetMM == 0 ? depth1 : depth1+sin(45)*offsetMM*2],
    [radius-depth2+offsetMM, offsetMM == 0 ? depth2+depth1 : depth2+depth1+sin(45)*offsetMM*2],
    [radius-depth2+offsetMM, depth2+depth1+depth3+offsetMM],
    [0,depth2+depth1+depth3+offsetMM]
    ];
//
//END Multiconnect Modules and Functions
//