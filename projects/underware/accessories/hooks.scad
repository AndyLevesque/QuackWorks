/*Created by Xavier Detant

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
TODO

Notes:
TODO
*/

include <BOSL2/std.scad>
include <BOSL2/walls.scad>
include <BOSL2/threading.scad>

/* [Slot Type] */
//How do you intend to mount the item holder to a surface such as Multipoint, Multiconnect, or Underware Threaded Snaps?
Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect, Threaded Snap]

//total width of the item to be mounted
total_item_width = 150;
//Extra room between the two holders (total between the two sides). Recommended to be at least 0.3mm. 
item_slop = 0.3;
//Minimum distance the center of a mount point can be from the edge of the item holder (by mm). Decreasing less than 10 may cause the slot to clip out the edge (which is usually fine).
Minimum_Safe_Mount_Clearance_From_Edge = 10;

/* [Internal Dimensions] */
//Depth (by mm): internal dimension along the Z axis of print orientation. Measured from the top to the base of the internal floor, equivalent to the depth of the item you wish to hold when mounted horizontally.
Depth = 25.0; //.1
//Width (by mm): internal dimension along the X axis of print orientation. Measured from left to right, equivalent to the width of the item you wish to hold when mounted horizontally.
Width = 25.0; //.1
//Height (by mm): internal dimension along the Y axis of print orientation. Measured from the front to the back, equivalent to the thickness of the item you wish to hold when mounted horizontally.
Height = 20.0; //.1

/*[Style Customizations]*/
//Edge rounding (by mm)
edgeRounding = 0.5; // [0:0.1:2]

hookHeight = 10;
hookRound = 1;
nbSecondaryHooks = 0;
secondaryHookHeight = 5;

onSided = true;
supportPosition = "Inside"; //  ["Center", "Outside", "Inside"]
onSidedWidth = 40;



/* [Additional Customization] */
//Thickness of item holder walls (by mm)
wallThickness = 2; //.1
//Thickness of item holder base (by mm)
baseThickness = 3; //.1



/*[Slot Customization]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
//Offset the multiconnect on-ramps to be between grid slots rather than on the slot
onRampHalfOffset = true;
//Change slot orientation, when enabled slots to come from the top of the back, when disabled slots come from the bottom
Reverse_Slot_Direction = true;
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

if(debugCutoutTool){
    if(Connection_Type == "Multiconnect") multiConnectSlotTool(totalHeight);
    else multiPointSlotTool(totalHeight);
}


//UNDERWARE SPECIFIC CODE
//Underware Conversion
//Depth and Height in the lateral version are switched to match the orientation of the item holder (vertical mounting vs. horizontal). This sets them back so the same code (vertical) is used between the two
internalDepth = Height;
internalHeight = Depth;
internalWidth = Width;
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

nbHooks=1+nbSecondaryHooks;

//calculate total working space, respecting minimum mounting value.
//The mounting points should be 'inside' the total width. Therefore, we are rounding down to the next mounting points on both sides
mount_point_distance = quantdn(total_item_width+baseThickness*2+item_slop*2-(Minimum_Safe_Mount_Clearance_From_Edge)*2, distanceBetweenSlots);
echo(str("Mount Point Distance: ", mount_point_distance));
new_mount_point_inward_adjustement = (total_item_width - mount_point_distance+item_slop )/2;
echo(str("New Mount Point Inward Adjustment: ", new_mount_point_inward_adjustement));



if(!debugCutoutTool)
union(){
        //move to center
        //translate(v = [-internalWidth/2,0,0]) 
            hooks();
    //slotted back
    if(Connection_Type == "Multipoint" || Connection_Type == "Multiconnect")
    makeSlottedBackplate(
        maxBackWidth = totalWidth, 
        backHeight = totalHeight, 
        distanceBetweenSlots = distanceBetweenSlots,
        backThickness= Connection_Type == "Multipoint" ? 4.8 : 
            Connection_Type == "Multiconnect" ? 6.5 :
            6,
        enforceMaxWidth=true,
        slotStopFromBack = Multiconnect_Stop_Distance_From_Back,
        anchor=BOT+BACK
        );
    if(Connection_Type == "Threaded Snap")
    makeThreadedBackplate(
        maxBackWidth = totalWidth, 
        backHeight = totalHeight, 
        distanceBetweenSlots = distanceBetweenSlots,
        backThickness= 3,
        slotStopFromBack = Multiconnect_Stop_Distance_From_Back,
        anchor=BOT+BACK
        );
}

//Create Hooks
module hooks() {
    if(onSided){
        translate([
        supportPosition == "Outside" ? (totalWidth/2)-wallThickness/2
        :supportPosition == "Inside" ? -((totalWidth/2)-wallThickness/2)
        :0,0,0])
        rightHook(onSidedWidth);
    } else {
        mirrorHook()
        rightHook(totalWidth/2);
    }
}


module rightHook(width){
    translate([-wallThickness/2,0,0])
    cuboid([wallThickness, internalDepth + 2*wallThickness, totalHeight], anchor=FRONT+LEFT+BOT);
    for ( i = [1:1:nbSecondaryHooks]) 
        translate([(width/nbHooks)*(i-1),0,0]) hookPart(width/nbHooks,secondaryHookHeight);
    translate([(width/nbHooks)*(nbSecondaryHooks),0,0]) hookPart(width/nbHooks,hookHeight,hookRound);
}
module hookPart(width,height,rounding=0){
    translate([0,wallThickness,0])
    difference(){
        translate([0,wallThickness+internalDepth-height,0])
        cuboid([width, height, totalHeight], anchor=FRONT+LEFT+BOT, rounding=rounding, edges = [RIGHT+FRONT,RIGHT+BACK]);
        translate([-wallThickness,0,-wallThickness])
        cuboid([width, internalDepth, totalHeight+2*wallThickness], anchor=FRONT+LEFT+BOT, rounding=max(0,(rounding-wallThickness)), edges = [RIGHT+BACK]);
    }
}

module mirrorHook(){
    children();
    mirror([1,0,0]) children();
}

//BEGIN MODULES

module makeThreadedBackplate(maxBackWidth, backHeight, distanceBetweenSlots, backThickness, slotStopFromBack = 13-baseThickness, enforceMaxWidth, anchor=CENTER, spin=0, orient=UP){
    slotCount = floor(maxBackWidth/distanceBetweenSlots) - subtractedSlots;
    //trueWidth = (enforceMaxWidth) ? maxBackWidth : slotCount * distanceBetweenSlots;
    trueBackHeight = max(backHeight, 25);
    backPlateTranslation = [0,-backThickness/2+0.01, 0];
    attachable(anchor, spin, orient, size=[maxBackWidth,backThickness,trueBackHeight]){
        translate(v = backPlateTranslation) 
            diff(){
                translate(v = [0,0,-trueBackHeight/2])
                cuboid(size = [maxBackWidth, backThickness, trueBackHeight], 
                    rounding=edgeRounding, 
                    except_edges=BACK, 
                    anchor=FRONT+BOT
                    );
                xrot(90) 
                tag("remove")grid_copies(size=[maxBackWidth-Outer_Diameter_Sm, trueBackHeight-Outer_Diameter_Sm], spacing = distanceBetweenSlots)
                    up(0.01)trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=backThickness+0.02, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, internal=true, bevel2 = true, blunt_start=false, anchor=TOP, $slop=Slop);

            }
        children();
    }
}

//Slotted back Module
module makeSlottedBackplate(maxBackWidth, backHeight, distanceBetweenSlots, backThickness, slotStopFromBack = 13-baseThickness, enforceMaxWidth, anchor=CENTER, spin=0, orient=UP)
{
    //every slot is a multiple of distanceBetweenSlots. The default of 25 accounts for the rail, and the ~5mm to either side.
    //first calculate the starting slot location based on the number of slots.
    slotCount = floor(maxBackWidth/distanceBetweenSlots) - subtractedSlots;
    // only use maxBackWidth if we have to, otherwise scale down by slots.
    trueWidth = (enforceMaxWidth) ? maxBackWidth : slotCount * distanceBetweenSlots;
    trueBackHeight = max(backHeight, 25);
    backPlateTranslation = [0,-backThickness, 0];
    attachable(anchor, spin, orient, size=[trueWidth,backThickness,trueBackHeight]){
        //final position for anchor alignment
        translate(v = [0,backThickness/2,-trueBackHeight/2]) 
        //flip if slotting from top
        yrot(Reverse_Slot_Direction ? 180 : 0) up(Reverse_Slot_Direction ? -trueBackHeight : 0)
        //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
        //slot width needs to be at least the distance between slot for at least 1 slot to generate
        difference() {
            translate(v = backPlateTranslation) 
            cuboid(size = [trueWidth, backThickness, trueBackHeight], 
                rounding=edgeRounding, 
                except_edges=BACK, 
                anchor=FRONT+BOT
                );
            //Loop through slots and center on the item
            //Note: I kept doing math until it looked right. It's possible this can be simplified.
            if(slotCount % 2 == 1){
                //odd number of slots, place on on x=0
                translate(v = [0,
                            -2.35 + slotDepthMicroadjustment,
                            trueBackHeight-slotStopFromBack-baseThickness
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
            remainingSlots = (slotCount % 2 == 1) ? (slotCount - 1)/2 : slotCount/2; //now place this many slots offset from center
            initialLoc = (slotCount % 2 == 1) ? 1 : 0.5;  // how far from center to start the incrementor?
            for (slotLoc = [initialLoc:1:remainingSlots]) {
                // place a slot left and right of center.
                    translate(v = [slotLoc * distanceBetweenSlots,
                            -2.35 + slotDepthMicroadjustment,
                            trueBackHeight-slotStopFromBack-baseThickness
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
                            -2.35 + slotDepthMicroadjustment,
                            trueBackHeight-slotStopFromBack-baseThickness
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
        children();
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
                union(){
                    difference() {
                        // Main half slot
                        linear_extrude(height = totalHeight+1) 
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
                            linear_extrude(height = totalHeight+1) 
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
                for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
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