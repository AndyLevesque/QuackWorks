/*Created by Andy (BlackjackDuck)

This code is licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
References to Multipoint are for the Multiboard ecosystem by Jonathan at Keep Making. The Multipoint mount system is licensed under https://www.multiboard.io/license.

Credit to 
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @fawix on GitHub for her contributions on parameter descriptors
    @SnazzyGreenWarrior on GitHub for their contributions on the Multipoint-compatible mount

Change Log:
- 2024-08-10 
    - Initial release
- 2024-12-08
    - Multiconnect on-ramps now in-between grids for easier mounting
    - Rounded edges to Item Holder
    - Thanks @user_2270779674 on MakerWorld!
    - Multiconnect On-Ramps at 1/2 grid intervals for more contact points
    - Rounding added to edges
- 2025-01-02
    - Multipoint mounting
    - Thanks @SnazzyGreenWarrior!
- 2025-01-16
    - Added GOEWS cleats option (@andrew_3d)

Notes:
- Slot test fit - For a slot test fit, set the following parameters
    - internalDepth = 0
    - internalHeight = 25
    - internalWidth = 0
    - wallThickness = 0
*/

include <BOSL2/std.scad>
include <BOSL2/walls.scad>
include <../lib/mounting_backers.scad>

/* [Beta Feature - Slot Type] */
//Multipoint in Beta - Please share feedback! How do you intend to mount the item holder to a surface such as Multipoint connections or DavidD's Multiconnect?
Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect, GOEWS]

/* [Internal Dimensions] */
//Height (in mm) from the top of the back to the base of the internal floor
internalHeight = 50.0; //.1
//Width (in mm) of the internal dimension or item you wish to hold
internalWidth = 50.0; //.1
//Length (i.e., distance from back) (in mm) of the internal dimension or item you wish to hold
internalDepth = 15.0; //.1

/*[Style Customizations]*/
//Edge rounding (in mm)
edgeRounding = 0.5; // [0:0.1:2]

/* [Front Cutout Customizations] */
//cut out the front
frontCutout = true; 
//Distance upward from the bottom (in mm) that captures the bottom front of the item
frontLowerCapture = 7;
//Distance downward from the top (in mm) that captures the top front of the item. Use zero (0) for a cutout top. May require printing supports if used. 
frontUpperCapture = 0;
//Distance inward from the sides (in mm) that captures the sides of the item
frontLateralCapture = 3;


/*[Bottom Cutout Customizations]*/
//Cut out the bottom 
bottomCutout = false;
//Distance inward from the front (in mm) that captures the bottom of the item
bottomFrontCapture = 3;
//Distance inward from the back (in mm) that captures the bottom of the item
bottomBackCapture = 3;
//Distance inward from the sides (in mm) that captures the bottom of the item
bottomSideCapture = 3;

/*[Cord Cutout Customizations]*/
//cut out a slot on the bottom and through the front for a cord to connect to the device
cordCutout = false;
//diameter/width of cord cutout
cordCutoutDiameter = 10;
//move the cord cutout left (positive) or right (negative) (in mm)
cordCutoutLateralOffset = 0;
//move the cord cutout forward (positive) and back (negative) (in mm)
cordCutoutDepthOffset = 0;

/* [Right Cutout Customizations] */
rightCutout = false; 
//Distance upward from the bottom (in mm) that captures the bottom right of the item
rightLowerCapture = 7;
//Distance downward from the top (in mm) that captures the bottom right of the item. Use zero (0) for a cutout top. May require printing supports if used. 
rightUpperCapture = 0;
//Distance inward from the sides (in mm) that captures the sides of the item
rightLateralCapture = 3;


/* [Left Cutout Customizations] */
leftCutout = false; 
//Distance upward from the bottom (in mm) that captures the upper left of the item
leftLowerCapture = 7;
//Distance downward from the top (in mm) that captures the upper left of the item. Use zero (0) for a cutout top. May require printing supports if used. 
leftUpperCapture = 0;
//Distance inward from the sides (in mm) that captures the sides of the item
leftLateralCapture = 3;


/* [Additional Customization] */
//Thickness of bin walls (in mm)
wallThickness = 2; //.1
//Thickness of bin  (in mm)
baseThickness = 3; //.1
//Only generate the backer mounting plate
backPlateOnly = false;

/*[Slot Customization]*/
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
//Reduce the number of slots
subtractedSlots = 0;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
//frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
On_Ramp_Every_X_Slots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
Multiconnect_Stop_Distance_From_Back = 13;

/*[GOEWS Customization]*/
GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
GOEWS_Cleat_custom_height_from_top_of_back = 11.24;

/* [Hidden] */
debugCutoutTool = false;

if(debugCutoutTool){
    if(Connection_Type == "Multiconnect") multiConnectSlotTool(totalHeight);
    else multiPointSlotTool(totalHeight);
}

//Calculated
totalHeight = internalHeight+baseThickness;
totalDepth = internalDepth + wallThickness;
totalWidth = internalWidth + wallThickness*2;
totalCenterX = internalWidth/2;

if(!debugCutoutTool)
union(){
    if(!backPlateOnly)
    //move to center
    translate(v = [-internalWidth/2,0,0]) 
        basket();
        //slotted back
    translate([-max(totalWidth,distanceBetweenSlots)/2,0.01,-baseThickness])
        makebackPlate(
            backWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            onRampEveryXSlots = On_Ramp_Every_X_Slots,
            Connection_Type = Connection_Type
        );
    }


//Create Basket
module basket() {
    difference() {
        union() {
            //bottom
            translate([-wallThickness,0,-baseThickness])
                cuboid([internalWidth + wallThickness*2, internalDepth + wallThickness,baseThickness], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [BOTTOM+LEFT,BOTTOM+RIGHT,BOTTOM+BACK,LEFT+BACK,RIGHT+BACK]);
            //left wall
            translate([-wallThickness,0,0])
                cuboid([wallThickness, internalDepth + wallThickness, internalHeight], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [TOP+LEFT,TOP+BACK,BACK+LEFT]);
            //right wall
            translate([internalWidth,0,0])
                cuboid([wallThickness, internalDepth + wallThickness, internalHeight], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [TOP+RIGHT,TOP+BACK,BACK+RIGHT]);
            //front wall
            translate([0,internalDepth,0])
                cuboid([internalWidth,wallThickness,internalHeight], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [TOP+BACK]);
        }

        //frontCaptureDeleteTool for item holders
            if (frontCutout == true)
                translate([frontLateralCapture,internalDepth-1,frontLowerCapture])
                    cube([internalWidth-frontLateralCapture*2,wallThickness+2,internalHeight-frontLowerCapture-frontUpperCapture+0.01]);
            if (bottomCutout == true)
                translate(v = [bottomSideCapture,bottomBackCapture,-baseThickness-1]) 
                    cube([internalWidth-bottomSideCapture*2,internalDepth-bottomFrontCapture-bottomBackCapture,baseThickness+2]);
                    //frontCaptureDeleteTool for item holders
            if (rightCutout == true)
                translate([-wallThickness-1,rightLateralCapture,rightLowerCapture])
                    cube([wallThickness+2,internalDepth-rightLateralCapture*2,internalHeight-rightLowerCapture-rightUpperCapture+0.01]);
            if (leftCutout == true)
                translate([internalWidth-1,leftLateralCapture,leftLowerCapture])
                    cube([wallThickness+2,internalDepth-leftLateralCapture*2,internalHeight-leftLowerCapture-leftUpperCapture+0.01]);
            if (cordCutout == true) {
                translate(v = [internalWidth/2+cordCutoutLateralOffset,internalDepth/2+cordCutoutDepthOffset,-baseThickness-1]) {
                    union(){
                        cylinder(h = baseThickness + frontLowerCapture + 2, r = cordCutoutDiameter/2);
                        translate(v = [-cordCutoutDiameter/2,0,0]) cube([cordCutoutDiameter,internalWidth/2+wallThickness+1,baseThickness + frontLowerCapture + 2]);
                    }
                }
            }
    }
    
}
