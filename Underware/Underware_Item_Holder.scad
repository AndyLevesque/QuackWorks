/*Created by Andy Levesque

This code is licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

References to Multipoint are for the Multiboard ecosystem by Jonathan at Keep Making. The Multipoint mount system is licensed under https://www.multiboard.io/license.


Credit to 
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @fawix on GitHub for her contributions on parameter descriptors
    @SnazzyGreenWarrior on GitHub for their contributions on the Multipoint-compatible mount


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
- 2025-01-02
    - Multipoint mounting
    - Thanks @SnazzyGreenWarrior!
- 2025-01-11
    - Logic changes on slot placement

Notes:
- Slot test fit - For a slot test fit, set the following parameters
    - Internal_Height = 0
    - Internal_Depth = 25
    - Internal_Width = 0
    - wallThickness = 0
*/

include <BOSL2/std.scad>
include <BOSL2/walls.scad>

/* [Beta Feature - Slot Type] */
//Multipoint in Beta - Please share feedback! How do you intend to mount the item holder to a surface such as Multipoint connections or DavidD's Multiconnect?
Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect]


/* [Internal Dimensions] */
//Depth (by mm): internal dimension along the Z axis of print orientation. Measured from the top to the base of the internal floor, equivalent to the depth of the item you wish to hold when mounted horizontally.
Internal_Depth = 50.0;
//Width (by mm): internal dimension along the X axis of print orientation. Measured from left to right, equivalent to the width of the item you wish to hold when mounted horizontally.
Internal_Width = 50.0; 
//Height (by mm): internal dimension along the Y axis of print orientation. Measured from the front to the back, equivalent to the thickness of the item you wish to hold when mounted horizontally.
Internal_Height = 15.0;

/*[Style Customizations]*/
//Edge rounding (by mm)
edgeRounding = 0.5; // [0:0.1:2]

/* [Front Cutout Customizations] */
//Cut out the front
frontCutout = true; 
//Distance upward (Z axis) from the bottom (by mm). This captures the bottom front of the item
frontLowerCapture = 7;
//Distance downward (Z axis) from the top (by mm). This captures the top front of the item. Use zero (0) for a cutout top. May require printing supports if used. 
frontUpperCapture = 0;
//Distance inward (X axis) from the sides (by mm) that captures the sides of the item
frontLateralCapture = 3;


/*[Bottom Cutout Customizations]*/
//Cut out the bottom 
bottomCutout = false;
//Distance inward (Y axis) from the front (by mm). This captures the bottom front of the item
bottomFrontCapture = 3;
//Distance inward (Y axis) from the back (by mm). That captures the bottom back of the item
bottomBackCapture = 3;
//Distance inward (X axis) from the sides (by mm) that captures the bottom side of the item
bottomSideCapture = 3;

/*[Cord Cutout Customizations]*/
//Cut out a slot on the bottom and through the front for a cord to connect to the device
cordCutout = false;
//Diameter/width of cord cutout
cordCutoutDiameter = 10;
//Move the cord cutout laterally (X axis), left is positive and right is negative (by mm)
cordCutoutLateralOffset = 0;
//Move the cord cutout depth (Y axis), forward is positive and back is negative (by mm)
cordCutoutDepthOffset = 0;

/* [Right Cutout Customizations] */
rightCutout = false; 
//Distance upward (Z axis) from the bottom (by mm) that captures the bottom right of the item
rightLowerCapture = 7;
//Distance downward (Z axis) from the top (by mm) that captures the top right of the item. Use zero (0) for a cutout top. May require printing supports if used. 
rightUpperCapture = 0;
//Distance inward (Y axis) from the sides (by mm) that captures the right sides of the item
rightLateralCapture = 3;


/* [Left Cutout Customizations] */
leftCutout = false; 
//Distance upward (Z axis) from the bottom (by mm) that captures the bottom left of the item
leftLowerCapture = 7;
//Distance downward (Z axis) from the top (by mm) that captures the top left of the item. Use zero (0) for a cutout top. May require printing supports if used. 
leftUpperCapture = 0;
//Distance inward (Y axis) from the sides (by mm) that captures the left sides of the item
leftLateralCapture = 3;


/* [Additional Customization] */
//Thickness of item holder walls (by mm)
wallThickness = 2; //.1
//Thickness of backplate (by mm)
backPlateThickness = 6.5; //.1
//Thickness of item holder base (by mm)
baseThickness = 3; //.1
//Only generate the backer mounting plate
backPlateOnly = false;


/*[Slot Customization]*/
//Offset the multiconnect on-ramps to be between grid slots rather than on the slot
onRampHalfOffset = true;
//Change slot orientation, when enabled slots to come from the top of the back, when disabled slots come from the bottom
Slot_From_Top = true;
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
//Move the slot (Y axis) inwards (positive) or outwards (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//Enable a slot on-ramp for easy mounting of tall items
onRampEnabled = false;
//Frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
On_Ramp_Every_X_Slots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
Multiconnect_Stop_Distance_From_Back = 13;

/* [Hidden] */
Wall_Type = "Solid"; //["Hex","Solid"]
debugCutoutTool = false;

if(debugCutoutTool){
    if(Connection_Type == "Multiconnect") multiConnectSlotTool(totalHeight);
    else multiPointSlotTool(totalHeight);
}

//UNDERWARE SPECIFIC CODE
//Underware Conversion
//Depth and Height in the lateral version are switched to match the orientation of the item holder (vertical mounting vs. horizontal). This sets them back so the same code (vertical) is used between the two
internalDepth = Internal_Height;
internalHeight = Internal_Depth;
internalWidth = Internal_Width;
//Due to horizontal mounting, do not allow users to do on-ramps every slot unless half offset is enabled
onRampEveryXSlots = 
    onRampHalfOffset ? On_Ramp_Every_X_Slots : 
    On_Ramp_Every_X_Slots == 1 ? 2 : On_Ramp_Every_X_Slots;
//UNDERWARE SPECIFIC CODE


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
    if(Connection_Type == "Multipoint"){
        makebackPlate(
            maxBackWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            backThickness=4.8,
            enforceMaxWidth=true,
            slotStopFromBack = Multiconnect_Stop_Distance_From_Back
            );
    }
    if(Connection_Type == "Multiconnect"){

        makebackPlate(
            maxBackWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            backThickness=6.5,
            enforceMaxWidth=true,
            slotStopFromBack = Multiconnect_Stop_Distance_From_Back
            );
    }
}

//Create Basket
module basket() {
    difference() {
        union() {
            //bottom
            translate([-wallThickness,0,0])
                if (bottomCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([internalWidth + wallThickness*2, internalDepth + wallThickness,baseThickness], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [BOTTOM+LEFT,BOTTOM+RIGHT,BOTTOM+BACK,LEFT+BACK,RIGHT+BACK]);
                else    
                     fwd(wallThickness)hex_panel([Internal_Width + wallThickness*2,Internal_Height+wallThickness*2, baseThickness], strut = 1, spacing = 5, frame= wallThickness, anchor=FRONT+LEFT+BOT);

            //left wall
            translate([-wallThickness,0,baseThickness])
                if (leftCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                   cuboid([wallThickness, internalDepth + wallThickness, internalHeight], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [TOP+LEFT,TOP+BACK,BACK+LEFT]);
                else    
                     fwd(wallThickness)hex_panel([Internal_Depth, Internal_Height + wallThickness*2,wallThickness], strut = 1, spacing = 7, frame= wallThickness, orient=RIGHT, anchor=FRONT+RIGHT+BOT);

            //right wall
            translate([internalWidth,0,baseThickness])
                if (rightCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([wallThickness, internalDepth + wallThickness, internalHeight], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [TOP+RIGHT,TOP+BACK,BACK+RIGHT]);
                else    
                     fwd(wallThickness)hex_panel([Internal_Depth, Internal_Height + wallThickness*2,wallThickness], strut = 1, spacing = 7, frame= wallThickness, orient=RIGHT, anchor=FRONT+RIGHT+BOT);

            //front wall            
            translate([0,internalDepth,baseThickness])
                if (frontCutout == true || Wall_Type == "Solid") //cutouts are not compatible with hex panels at this time. Need to build a frame first. 
                    cuboid([internalWidth,wallThickness,internalHeight], anchor=FRONT+LEFT+BOT, rounding=edgeRounding, edges = [TOP+BACK]);
                else    
                    back(wallThickness)zrot(-90) hex_panel([Internal_Depth,Internal_Width,wallThickness], strut = 1, spacing = 7, frame= wallThickness,orient=RIGHT, anchor=FRONT+RIGHT+BOT);
        }

        //frontCaptureDeleteTool for item holders
            if (frontCutout == true)
                translate([frontLateralCapture,internalDepth-1,frontLowerCapture+baseThickness])
                    cube([internalWidth-frontLateralCapture*2,wallThickness+2,internalHeight-frontLowerCapture-frontUpperCapture+0.01]);
            if (bottomCutout == true)
                translate(v = [bottomSideCapture,bottomBackCapture,-1]) 
                    cube([internalWidth-bottomSideCapture*2,internalDepth-bottomFrontCapture-bottomBackCapture,baseThickness+2]);
                    //frontCaptureDeleteTool for item holders
            if (rightCutout == true)
                translate([-wallThickness-1,rightLateralCapture,rightLowerCapture+baseThickness])
                    cube([wallThickness+2,internalDepth-rightLateralCapture*2,internalHeight-rightLowerCapture-rightUpperCapture+0.01]);
            if (leftCutout == true)
                translate([internalWidth-1,leftLateralCapture,leftLowerCapture+baseThickness])
                    cube([wallThickness+2,internalDepth-leftLateralCapture*2,internalHeight-leftLowerCapture-leftUpperCapture+0.01]);
            if (cordCutout == true) {
                translate(v = [internalWidth/2+cordCutoutLateralOffset,internalDepth/2+cordCutoutDepthOffset,-1]) {
                    union(){
                        cylinder(h = baseThickness + frontLowerCapture + 2, r = cordCutoutDiameter/2);
                        translate(v = [-cordCutoutDiameter/2,0,0]) cube([cordCutoutDiameter,internalWidth/2+wallThickness+1,baseThickness + frontLowerCapture + 2]);
                    }
                }
            }
    }
    
}


//BEGIN MODULES
//Slotted back Module
module makebackPlate(maxBackWidth, backHeight, distanceBetweenSlots, backThickness, slotStopFromBack = 13, enforceMaxWidth)
{
    
    //every slot is a multiple of distanceBetweenSlots. The default of 25 accounts for the rail, and the ~5mm to either side.
    //first calculate the starting slot location based on the number of slots.
    slotCount = floor(maxBackWidth/distanceBetweenSlots) - subtractedSlots;
    // only use maxBackWidth if we have to, otherwise scale down by slots.
    trueWidth = (enforceMaxWidth) ? maxBackWidth : slotCount * distanceBetweenSlots;
    trueBackHeight = max(backHeight, 25);
    backPlateTranslation = [0,-backThickness, 0];
    
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    yrot(Slot_From_Top ? 180 : 0) up(Slot_From_Top ? -trueBackHeight : 0)
    difference() {
        translate(v = backPlateTranslation) 
        cuboid(size = [trueWidth, backThickness, trueBackHeight], 
               rounding=edgeRounding, 
               except_edges=BACK, 
               anchor=FRONT+BOT
              );
        // Compute yslot pos given backplate thickness
        yslot = -backThickness + 5 + slotDepthMicroadjustment;
        //Loop through slots and center on the item
        //Note: I kept doing math until it looked right. It's possible this can be simplified.
        if(slotCount % 2 == 1){
            //odd number of slots, place on on x=0
            translate(v = [0,
                           yslot,
                           trueBackHeight-slotStopFromBack
                          ])
                {
                if(Connection_Type == "Multipoint"){
                    multiPointSlotTool(totalHeight);
                }
                if(Connection_Type == "Multiconnect"){
                    multiConnectSlotTool(totalHeight);
                }
            }
        }
        remainingSlots = (slotCount % 2 == 1) ? (slotCount - 1) : slotCount; //now place this many slots offset from center
        initialLoc = (slotCount % 2 == 1) ? 1 : 0.5;  // how far from center to start the incrementor?
        for (slotLoc = [initialLoc:2:remainingSlots]) {
            // place a slot left and right of center.
            echo("slotLoc", slotLoc)
            translate(v = [slotLoc * distanceBetweenSlots,
                           yslot,
                           trueBackHeight-slotStopFromBack
                          ])
                {
                if(Connection_Type == "Multipoint"){
                    multiPointSlotTool(totalHeight);
                }
                if(Connection_Type == "Multiconnect"){
                    multiConnectSlotTool(totalHeight);
                }
            }
            translate(v = [slotLoc * distanceBetweenSlots * -1,
                           yslot,
                           trueBackHeight-slotStopFromBack
                          ])
                {
                if(Connection_Type == "Multipoint"){
                    multiPointSlotTool(totalHeight);
                }
                if(Connection_Type == "Multiconnect"){
                    multiConnectSlotTool(totalHeight);
                }
            }
        }
    }   
}

//Create Slot Tool
module multiConnectSlotTool(totalHeight) {
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
                linear_extrude(height = totalHeight+1) 
                    union(){
                        polygon(points = slotProfile);
                        mirror([1,0,0])
                            polygon(points = slotProfile);
                    }
            //on-ramp
            if(onRampEnabled)
                for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                    //then modify the translate within the on-ramp code to include the offset
                    translate(v = [0,-5,(-y*distanceBetweenSlots)+distanceOffset])
                        rotate(a = [-90,0,0]) 
                            cylinder(h = 5, r1 = 12, r2 = 10.15);
        }
        //dimple
        if (slotQuickRelease == false)
            scale(v = dimpleScale) 
            rotate(a = [90,0,0,]) 
                rotate_extrude($fn=50) 
                    polygon(points = [[0,0],[0,1.5],[1.5,0]]);
    }
}

module multiPointSlotTool(totalHeight) {
    slotBaseRadius = 17.0 / 2.0;  // wider width of the inner part of the channel
    slotSkinRadius = 13.75 / 2.0;  // narrower part of the channel near the skin of the model
    slotBaseCatchDepth = .2;  // innermost before the chamfer, base to chamfer height
    slotBaseToSkinChamferDepth = 2.2;  // middle part of the chamfer
    slotSkinDepth = .1;  // top or skinmost part of the channel
    distanceOffset = onRampHalfOffset ? distanceBetweenSlots / 2 : 0;
    octogonScale = 1/sin(67.5);  // math convenience function to convert an octogon hypotenuse to the short length
    let (slotProfile = [
        [0,0],
        [slotBaseRadius,0],
        [slotBaseRadius, slotBaseCatchDepth],
        [slotSkinRadius, slotBaseCatchDepth + slotBaseToSkinChamferDepth],
        [slotSkinRadius, slotBaseCatchDepth + slotBaseToSkinChamferDepth + slotSkinDepth],
        [0, slotBaseCatchDepth + slotBaseToSkinChamferDepth + slotSkinDepth]
    ])
    union() {
        //octagonal top. difference on union because we need to support the dimples cut in.
        difference(){
            //union of top and rail.
            union(){
                scale([octogonScale,1,octogonScale])
                rotate(a = [90,67.5,0,]) 
                    rotate_extrude($fn=8) 
                        polygon(points = slotProfile);
                //long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0]) 
                    linear_extrude(height = totalHeight+1) 
                        union(){
                            polygon(points = slotProfile);
                            mirror([1,0,0])
                                polygon(points = slotProfile);
                        }
            }
            //dimples on each catch point
            if (!slotQuickRelease){
                for(z = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots ])
                {
                    echo("building on z", z);
                    yMultipointSlotDimples(z, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                }
            }
        }
        //on-ramp
        if(onRampEnabled)
            union(){
                for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                {
                    // create the main entry hexagons
                    translate(v = [0,-5,(-y*distanceBetweenSlots)+distanceOffset])
                    scale([octogonScale,1,octogonScale])
                        rotate(a = [-90,67.5,0]) 
                            cylinder(h=5, r=slotBaseRadius, $fn=8);

                // make the required "pop-in" locking channel dimples.
                xSlotDimples(y, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                mirror([1,0,0])
                     xSlotDimples(y, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                }
            }
    }
}

module xSlotDimples(y, slotBaseRadius, distanceBetweenSlots, distanceOffset){
    //Multipoint dimples are truncated (on top and side) pyramids
    //this function makes one pair of them
    dimple_pitch = 4.5 / 2; //distance between locking dimples
    difference(){
        translate(v = [slotBaseRadius ,0,(-y*distanceBetweenSlots)+distanceOffset+dimple_pitch])
            rotate(a = [90,45,90]) 
            rotate_extrude($fn=4) 
                polygon(points = [[0,0],[0,1.5],[1.7,0]]);
        translate(v = [slotBaseRadius+.75, -2, (-y*distanceBetweenSlots)+distanceOffset-1])
                cube(4);
        translate(v = [slotBaseRadius-2, 0, (-y*distanceBetweenSlots)+distanceOffset-1])
                cube(7);
        }
        difference(){
        translate(v = [slotBaseRadius ,0,(-y*distanceBetweenSlots)+distanceOffset-dimple_pitch])
            rotate(a = [90,45,90]) 
            rotate_extrude($fn=4) 
                polygon(points = [[0,0],[0,1.5],[1.7,0]]);
        translate(v = [slotBaseRadius+.75, -2, (-y*distanceBetweenSlots)+distanceOffset-3])
                cube(4);
        translate(v = [slotBaseRadius-2, 0, (-y*distanceBetweenSlots)+distanceOffset-5])
                cube(10);
        }
}
module yMultipointSlotDimples(z, slotBaseRadius, distanceBetweenSlots, distanceOffset){
    //This creates the multipoint point out dimples within the channel.
    octogonScale = 1/sin(67.5);
    difference(){
        translate(v = [0,0,((-z+.5)*distanceBetweenSlots)+distanceOffset])
            scale([octogonScale,1,octogonScale])
                rotate(a = [-90,67.5,0]) 
                    rotate_extrude($fn=8) 
                        polygon(points = [[0,0],[0,-1.5],[5,0]]);
        translate(v = [0,0,((-z+.5)*distanceBetweenSlots)+distanceOffset])
            cube([10,3,3], center=true);
        translate(v = [0,0,((-z+.5)*distanceBetweenSlots)+distanceOffset])
           cube([3,3,10], center=true);
    }
}   
