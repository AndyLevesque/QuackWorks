/*Created by Andy Levesque

This code is licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/
References to Multipoint are for the Multiboard ecosystem by Jonathan at Keep Making. The Multipoint mount system is licensed under https://www.multiboard.io/license.


Credit to 
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @fawix on GitHub for her contributions on parameter descriptors
    @SnazzyGreenWarrior on GitHub for their contributions on the Multipoint-compatible mount
    @Dontic on GitHub for Multiconnect v2 code


Change Log:
- 2024-12-06 
    - Initial release
- 2024-12-08 
    - Renamed depth and width
    - Multiconnect On-Ramps off by default
    - Multiconnect On-Ramps at 1/2 grid intervals for more contact points
    - Rounding added to edges
- 2024-12-10
    - Hexagon panel option
-2024-12-11
    - Updated on-ramp logic to prevent on-ramps every slot when half offset is disabled
    - Updated (in mm) to (by mm) for clarity
-2024-12-13
    -Ability to override slot distance from edge
-2025-05-02
    - Added dropdown for Multiconnect vs. Threaded Snap connections
    - Added dropdown for openGrid vs Multiboard mounting surfaces
    - Created threaded snap matching threaded snap profile of Underware (but also a teardrop for vertical printing)
    - Added 'backer only' option
    - Added 'Force Back Thickness' option to override the default back thickness of 6.5mm or 3.6mm depending on mounting style
    - Allowed mm adjustements to the tength of a mm
-2025-05-28
    - Added Clamshell move v0.1 (no independent customizations)
-2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
    - Enabled OnRamp by default
-2025-07-25
    - Added ability to subtract slots if wanting few slots than generated
-2026-08-30
    - Refactored the whole model into the mounted frame of reference (see below).
      Print orientation is applied only on render/export, via Print_Orientation.
    - Cutout groups renamed to match the mounted faces they actually cut
      (old "front" is now "bottom", old "bottom" is now "back").
    - Left/right are now from the user's point of view at the open front face,
      so the right wall is at -X.
    - Added Print_Orientation, which rotates the model onto its printing
      orientation for render and export while leaving the preview mounted.
    - ClamShell_Mode now orients each half separately so both lie plate-down on
      the bed, packs them together with Print_Part_Spacing, and emits them as
      two separate top level objects.

Frame of reference:
    The model is drawn as it is mounted, not as it is printed. The mounting
    surface is horizontal and above the part (for example the underside of a
    desk), so the connectors sit on TOP and the holder hangs below them.

        -X = right, +X = left        -> Internal_Width
        -Y = back,  +Y = front       -> Internal_Depth  (front face is open)
        +Z = up,    -Z = down        -> Internal_Height (hangs downward)

    "Back" and "front" are named relative to the mounting surface, following the
    original model's usage: the back wall is the one against the board, and the
    front is the open face you load the item through. The item extends in +Y so
    it sits in front of you as you face the mount.

    "Left" and "right" are from your point of view as the user standing at the
    open front face. Because you look in the -Y direction, your right hand points
    toward -X, so the right wall is the one at -X.

    The origin is at the centre of the front edge of the mounting plane: the
    connector plate occupies z > 0 and the holder occupies z < 0, y > 0.

    Orienting the part for printing is handled by the Print_Orientation
    parameter, applied only in printOrient() at the top level. The preview (F5)
    always stays in the frame above; a render (F6) or an export rotates the
    model +90 degrees about X to lay the connector plate flat on the bed.
    Everything else in this file is written in the mounted frame.

    In ClamShell_Mode the two halves face opposite ways, so they are oriented
    separately: each rotates about X in the direction that brings its own
    mounted back face down, and the partner is then packed alongside the first
    half with Print_Part_Spacing between them. Each half is a separate top level
    object, so exporting with --enable=lazy-union to a format that supports
    multiple objects (3MF does, STL does not) keeps them as two parts.

Notes:
- Slot test fit - For a slot test fit, set the following parameters
    - Internal_Height = 0
    - Internal_Depth = 25
    - Internal_Width = 0
    - wallThickness = 0
*/

include <BOSL2/std.scad>
include <BOSL2/walls.scad>
include <BOSL2/threading.scad>

/*[Mounting Options]*/
Mounting_Style = "Multiconnect"; //[Multiconnect, Threaded Snap]
//Surface on which you are mounting (which determines grid spacing). Select Custom and define the grid spacing in 'Slot Customization'.
Mounting_Surface = "Multiboard"; //[Multiboard, openGrid, Custom]

/* [Internal Dimensions] */
//Width (by mm): internal dimension along the X axis, measured left to right as mounted.
Internal_Width = 60.0; //.1
//Depth (by mm): internal dimension along the Y axis, measured front to back as mounted. The front face is the open side you load the item through.
Internal_Depth = 50.0; //.1
//Height (by mm): internal dimension along the Z axis, measured from the mounting surface straight down to the inside of the bottom wall.
Internal_Height = 15.0; //.1

/*[Style Customizations]*/
//Edge rounding (by mm)
edgeRounding = 0.5; // [0:0.1:2]

/* [Bottom Cutout Customizations] */
//Cut out the bottom (the wall the item rests on)
bottomCutout = true;
//Distance inward (Y axis) from the back (by mm). This captures the back of the item where it meets the bottom
bottomBackCapture = 7;
//Distance inward (Y axis) from the front (by mm). This captures the front of the item where it meets the bottom. Use zero (0) to open the bottom all the way to the front.
bottomFrontCapture = 0;
//Distance inward (X axis) from the sides (by mm) that captures the sides of the item
bottomSideCapture = 3;


/*[Back Cutout Customizations]*/
//Cut out the back (the wall between the item and the mounting surface)
backCutout = false;
//Distance downward (Z axis) from the mounting surface (by mm). This captures the top back of the item
backUpperCapture = 3;
//Distance upward (Z axis) from the bottom (by mm). This captures the bottom back of the item
backLowerCapture = 3;
//Distance inward (X axis) from the sides (by mm) that captures the back side of the item
backSideCapture = 3;

/*[Cord Cutout Customizations]*/
//Cut out a hole through the back and a slot down through the bottom for a cord to connect to the device
cordCutout = false;
//Diameter/width of cord cutout
cordCutoutDiameter = 10;
//Move the cord cutout laterally (X axis), left is positive and right is negative (by mm)
cordCutoutLateralOffset = 0;
//Move the cord cutout vertically (Z axis), up is positive and down is negative (by mm)
cordCutoutVerticalOffset = 0;

/* [Right Cutout Customizations] */
rightCutout = false; 
//Distance inward (Y axis) from the back (by mm) that captures the back right of the item
rightBackCapture = 7;
//Distance inward (Y axis) from the front (by mm) that captures the front right of the item. Use zero (0) to open the cutout to the front.
rightFrontCapture = 0;
//Distance inward (Z axis) from the top and bottom (by mm) that captures the right side of the item
rightVerticalCapture = 3;


/* [Left Cutout Customizations] */
leftCutout = false; 
//Distance inward (Y axis) from the back (by mm) that captures the back left of the item
leftBackCapture = 7;
//Distance inward (Y axis) from the front (by mm) that captures the front left of the item. Use zero (0) to open the cutout to the front.
leftFrontCapture = 0;
//Distance inward (Z axis) from the top and bottom (by mm) that captures the left side of the item
leftVerticalCapture = 3;

/*[BETA - Clamshell mode]*/
//NOT COMPATIBLE WITH THREADED SNAPS YET. Clamshell mode is when you want to enclose the item with two separate holders. This calculates the distance between the two holders while also aligning with the mounting points.
ClamShell_Mode = false;
//total width of the item to be mounted
total_item_width = 150;
//Extra room between the two holders (total between the two sides). Recommended to be at least 0.3mm. 
item_slop = 0.3;
//Minimum distance the center of a mount point can be from the edge of the item holder (by mm). Decreasing less than 10 may cause the slot to clip out the edge (which is usually fine).
Minimum_Safe_Mount_Clearance_From_Edge = 13;

/* [Additional Customization] */
//Thickness of the left, right and bottom walls (by mm)
wallThickness = 2; //.1
//Thickness of the back wall, between the item and the mounting surface (by mm)
baseThickness = 3; //.1

/*[Advanced]*/
//Rotate the model into a print-friendly orientation when rendering or exporting. The
//preview (F5) always stays in the mounted orientation so the model reads the way it
//mounts. Note this also applies to a full render (F6), not just to export.
Print_Orientation = true;
//Gap (by mm) left between the two clamshell halves when laid out for printing.
Print_Part_Spacing = 4;
Backer_Only_Mode = false;
Backer_Negatives_Only = false; //If true, the backer will be negative space. If false, the backer will be positive space.
//Set to 0 to use the default thickness of the back. Set to a number to force the back to be that thickness.
Force_Back_Thickness = 0; //0.1


/*[Slot Customization]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
//Reduce the number of slots
subtractedSlots = 0;
//Offset the multiconnect on-ramps to be between grid slots rather than on the slot
onRampHalfOffset = true;
//Change slot orientation, when enabled slots are entered from the back of the mount, when disabled from the front
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
onRampEnabled = true;
//Frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
On_Ramp_Every_X_Slots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
Multiconnect_Stop_Distance_From_Back = 13;

/* [Hidden] */
Wall_Type = "Solid"; //["Hex","Solid"]

distanceBetweenSlots = 
    Mounting_Surface == "Multiboard" ? 25 : 
    Mounting_Surface == "openGrid" ? 28 : 
    Custom_Distance_Between_Slots;


onRampEveryXSlots = 
    onRampHalfOffset ? On_Ramp_Every_X_Slots : 
    On_Ramp_Every_X_Slots == 1 ? 2 : On_Ramp_Every_X_Slots;

debugItemRepresentation = false;

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
//Slop in thread. Increase to make threading easier. Decrease to make threading harder.
Slop = 0.075;

//Calculated. These are the outside dimensions of the holder in the mounted frame.
totalDepth = Backer_Only_Mode ? Internal_Depth : Internal_Depth+baseThickness;
totalHeight = Backer_Only_Mode ? Internal_Height : Internal_Height + wallThickness;
totalWidth = Backer_Only_Mode ? Internal_Width : Internal_Width + wallThickness*2;

//Maps the mounting plate generator's own frame (plate face in XZ, thickness along -Y,
//slots running along +Z) into the mounted frame, where the plate lies flat on top with
//its slots running front to back.
//This is a pure rotation, deliberately not a mirror: mirroring would reverse the
//handedness of the threads generated by threadedSnapBack. The plate's slot pattern is
//symmetric across X, so rotating about Z lands it in the same place a mirror would.
PLATE_TO_MOUNTED = [[1,0,0,0],[0,0,1,0],[0,-1,0,0],[0,0,0,1]];

//calculate total working space, respecting minimum mounting value.
//The mounting points should be 'inside' the total width. Therefore, we are rounding down to the next mounting points on both sides
mount_point_distance = quantdn(total_item_width+baseThickness*2+item_slop*2-(Minimum_Safe_Mount_Clearance_From_Edge)*2, distanceBetweenSlots);
echo(str("Mount Point Distance: ", mount_point_distance));
new_mount_point_inward_adjustement = (total_item_width - mount_point_distance + item_slop*2 + baseThickness*2)/2;
echo(str("New Mount Point Inward Adjustment: ", new_mount_point_inward_adjustement));
echo(str("Grid spaces apart: ",  mount_point_distance/distanceBetweenSlots));

//Everything below is drawn in the mounted frame. The print transform is applied per
//half, at the top level, and is the only place print orientation is introduced.
//$preview is true for F5 and false for F6 and for command-line export, so the preview
//stays in the mounted orientation while exports come out print-ready.
//
//Each half is kept as its own top-level statement rather than being grouped under a
//shared wrapper. With --enable=lazy-union that keeps them as separate objects in
//formats that support it (such as 3MF); grouping them would fuse them into one.
if(debugItemRepresentation){
    %printOrient() back(Internal_Depth/2) down(Internal_Height/2)
        cuboid([Internal_Width, Internal_Depth, Internal_Height]);
}

printOrient() itemHolder();

//The clamshell partner faces back toward the first holder across the item. This is a
//180 degree rotation about Z rather than a mirror, so that thread handedness and the
//slot profiles are preserved on both halves.
if(ClamShell_Mode)
    printOrient(partner=true)
        back(total_item_width+item_slop*2) zrot(180)
            itemHolder();

//Applies the print orientation to its children, or leaves them in the mounted
//orientation for preview.
//
//Printing wants a large flat face on the bed, so each half rotates about X to bring
//its mounted back face down. The two halves face opposite ways, so they rotate in
//opposite directions: +90 lays the first half down, -90 does the same for the partner,
//which is already turned 180 about Z. Rotating both the same way would stand the
//partner on its open front face instead.
//
//The partner is then moved back down onto the bed and in alongside the first half,
//instead of being left a full item-width away where the mounted layout put it.
//partnerLift undoes that item-width displacement in the rotated frame, and partnerSlide
//packs the two halves together with Print_Part_Spacing between them.
partnerLift = total_item_width + item_slop*2;
partnerSlide = totalHeight*2 + Print_Part_Spacing;

module printOrient(partner=false){
    if(!$preview && Print_Orientation)
        translate(partner ? [0, partnerSlide, partnerLift] : [0,0,0])
            rotate(partner ? [-90,0,0] : [90,0,0])
                children();
    else
        children();
}

//A single holder: the basket hanging below the mounting plane, plus the plate that
//attaches it to the board above.
module itemHolder(){
    union(){
        if(!Backer_Only_Mode)
            basket();
        multmatrix(PLATE_TO_MOUNTED)
            if(Mounting_Style == "Multiconnect")
                translate([0,0.02,totalDepth/2-baseThickness])
                    rotate([0,Slot_From_Top ? 180 : 0,0])
                        translate([-totalWidth/2,0,-totalDepth/2])//center
                            multiconnectBack(
                                backWidth = totalWidth, 
                                backHeight = totalDepth, 
                                distanceBetweenSlots = distanceBetweenSlots, 
                                slotStopFromBack = ClamShell_Mode ? new_mount_point_inward_adjustement : Multiconnect_Stop_Distance_From_Back,
                            );
            else
                translate([0,0.02,-baseThickness])
                    threadedSnapBack(backWidth = totalWidth, backHeight= totalDepth, distanceBetweenSlots = distanceBetweenSlots, anchor=BOT+BACK);
    }
}

//Create Basket.
//Interior occupies x [-Internal_Width/2, +Internal_Width/2], y [-Internal_Depth, 0],
//z [-Internal_Height, 0]. The mounting plane is z = 0 and the front (y = -Internal_Depth)
//is open so the item can be loaded in.
module basket() {
    halfWidth = Internal_Width/2;
    difference() {
        union() {
            //back wall, between the item and the mounting surface
            translate([0, -baseThickness/2, -totalHeight/2])
                if (backCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([totalWidth, baseThickness, totalHeight], rounding=edgeRounding, edges = [FRONT+LEFT,FRONT+RIGHT,FRONT+BOT,LEFT+BOT,RIGHT+BOT]);
                else    
                    cuboid([totalWidth, baseThickness, totalHeight]);

            //right wall (at -X: you face -Y, so your right hand points to -X)
            translate([-halfWidth-wallThickness/2, Internal_Depth/2, -totalHeight/2])
                if (rightCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([wallThickness, Internal_Depth, totalHeight], rounding=edgeRounding, edges = [BACK+LEFT,BACK+BOT,BOT+LEFT]);
                else    
                    yrot(90) hex_panel([totalHeight, Internal_Depth, wallThickness], strut = 1, spacing = 7, frame = wallThickness);

            //left wall (at +X)
            translate([halfWidth+wallThickness/2, Internal_Depth/2, -totalHeight/2])
                if (leftCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([wallThickness, Internal_Depth, totalHeight], rounding=edgeRounding, edges = [BACK+RIGHT,BACK+BOT,BOT+RIGHT]);
                else    
                    yrot(90) hex_panel([totalHeight, Internal_Depth, wallThickness], strut = 1, spacing = 7, frame = wallThickness);

            //bottom wall, which the item rests on
            translate([0, Internal_Depth/2, -Internal_Height-wallThickness/2])
                if (bottomCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([Internal_Width, Internal_Depth, wallThickness], rounding=edgeRounding, edges = [BACK+BOT]);
                else    
                    hex_panel([Internal_Width, Internal_Depth, wallThickness], strut = 1, spacing = 7, frame = wallThickness);
        }

        //Delete tools. Each one opens up a face while leaving a lip that captures the item.
        //A front capture of zero opens the cutout to the front face, so the tool has to
        //overshoot that face slightly. Otherwise it would end exactly on it and leave a
        //coincident zero-depth face that renders as a flickering rectangle in preview.
        if (bottomCutout == true)
            translate([-Internal_Width/2+bottomSideCapture, bottomBackCapture-0.01, -Internal_Height-wallThickness-1])
                cube([Internal_Width-bottomSideCapture*2, Internal_Depth-bottomFrontCapture-bottomBackCapture+0.01+(bottomFrontCapture == 0 ? 0.01 : 0), wallThickness+2]);
        if (backCutout == true)
            translate([-Internal_Width/2+backSideCapture, -baseThickness-1, -Internal_Height+backLowerCapture])
                cube([Internal_Width-backSideCapture*2, baseThickness+2, Internal_Height-backLowerCapture-backUpperCapture]);
        if (rightCutout == true)
            translate([-halfWidth-wallThickness-1, rightBackCapture-0.01, -Internal_Height+rightVerticalCapture])
                cube([wallThickness+2, Internal_Depth-rightFrontCapture-rightBackCapture+0.01+(rightFrontCapture == 0 ? 0.01 : 0), Internal_Height-rightVerticalCapture*2]);
        if (leftCutout == true)
            translate([halfWidth-1, leftBackCapture-0.01, -Internal_Height+leftVerticalCapture])
                cube([wallThickness+2, Internal_Depth-leftFrontCapture-leftBackCapture+0.01+(leftFrontCapture == 0 ? 0.01 : 0), Internal_Height-leftVerticalCapture*2]);
        if (cordCutout == true)
            translate([cordCutoutLateralOffset, -baseThickness-1, -Internal_Height/2+cordCutoutVerticalOffset])
                union(){
                    //hole through the back wall
                    xrot(-90) cylinder(h = baseThickness + bottomBackCapture + 2, r = cordCutoutDiameter/2);
                    //slot running down and out through the bottom wall
                    translate([-cordCutoutDiameter/2, 0, -Internal_Height/2-wallThickness-1])
                        cube([cordCutoutDiameter, baseThickness+bottomBackCapture+2, Internal_Height/2+wallThickness+1]);
                }
    }
}


//BEGIN MODULES
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
module multiconnectBack(backWidth, backHeight, distanceBetweenSlots, slotStopFromBack = 13)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth,distanceBetweenSlots), backHeight = max(backHeight, 25),slotCount = floor(backWidth/distanceBetweenSlots) - subtractedSlots, backThickness = Force_Back_Thickness == 0 ? 6.5 : Force_Back_Thickness){
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
