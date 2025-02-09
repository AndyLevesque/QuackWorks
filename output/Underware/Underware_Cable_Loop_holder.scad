/*Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Credit to @jcahoursfor the original version.
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution


Change Log:
- 2024-1-07
    - Initial release
    
*/

include <BOSL2/std.scad>
include <BOSL2/walls.scad>
/* [Slot Type] */
//How do you intend to mount the item holder to a surface such as Multipoint connections or DrewD's Multiconnect?
Connection_Type = "Multipoint"; // [Multipoint, Multiconnect]

/* [Holder Dimensions] */
// Height (in mm) of the entire holder (minus baseplate)
holderHeight = 45;
// Diameter (in mm) of the connecting post
postDiameter = 20;
// Diameter (in mm) of the cable space
holderDiameter = 40;
// Additional radius flat space to add for cable space
extraHoldingEdgeLength = 14;

/* [Resolution Customization] */
horizontalResolution = 20;
verticalResolution = 6;


/*[Style Customizations]*/
//Edge rounding (in mm)
edgeRounding = 0.5; // [0:0.1:2]

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
onRampEveryXSlots = 1;
//Multipoint on ramp enforcement. Expands rails to ensure an 'I' interface is at the entrance.abs
onRampMPEntranceEnforce = true;

/* [Hidden] */

//Calculated
trueHolderHeight = (holderHeight >= holderDiameter) ? holderHeight : holderDiameter;
totalDiameter = holderDiameter + postDiameter + (2 * extraHoldingEdgeLength);
totalHeight = 0.5 * totalDiameter;
totalWidth = totalDiameter;

//move to center
cableHolder(trueHolderHeight, holderDiameter, postDiameter, extraHoldingEdgeLength, verticalResolution, horizontalResolution);
    
    //slotted back
echo("firstTranslate point", [-max(totalWidth,distanceBetweenSlots)/2,0,0]);
if(Connection_Type == "Multipoint"){
    makebackPlate(
        maxBackWidth = totalWidth, 
        backHeight = totalHeight, 
        distanceBetweenSlots = distanceBetweenSlots,
        backThickness=4.8,
        enforceMaxWidth=false);
}
if(Connection_Type == "Multiconnect"){
    makebackPlate(
        maxBackWidth = totalWidth, 
        backHeight = totalHeight, 
        distanceBetweenSlots = distanceBetweenSlots,
        backThickness=6.5,
        enforceMaxWidth=false);
}
//Create Basket
module cableHolder(trueHolderHeight, holderDiameter, postDiameter, extraHoldingEdgeLength, verticalResolution, horizontalResolution) {
    totalHolderDiameter = holderDiameter + postDiameter + (2 * extraHoldingEdgeLength);
    
    bottomBoxSize = trueHolderHeight + totalHolderDiameter;
    bottomBoxCutoutY = (0.499 * bottomBoxSize);  // offset for render z-fighting
    bottomBoxCutoutZ = (-0.5 * (bottomBoxSize));  // offset for render z-fighting

    holderCutterRadius = 0.5 * holderDiameter ;
    holderCutterTranslate = [
    (0.5 * postDiameter) + holderCutterRadius, 
    (-0.5 * holderDiameter),
    0];
    
    difference(){
        union(){
            translate(v = [0,(0.5 * trueHolderHeight),0]) 
            rotate(a = [90,0,0]) 
                cyl(h=trueHolderHeight, d=totalHolderDiameter, rounding=edgeRounding);
        };
        
        rotate(a = [90,0,0]) 
            rotate_extrude(convexity = 10, $fn = verticalResolution * 4, angle = 360)
                union(){
                    translate(holderCutterTranslate)
                        circle(r = holderCutterRadius, $fn=horizontalResolution * 2);
                    translate(holderCutterTranslate + [.55*extraHoldingEdgeLength,0,0])
                        square( [1.1*extraHoldingEdgeLength,2*holderCutterRadius], 
                                $fn=horizontalResolution * 2, 
                                anchor = CENTER);
                }
        translate([0,bottomBoxCutoutY, bottomBoxCutoutZ])
            cube(bottomBoxSize, center=true);
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
                           -2.35 + slotDepthMicroadjustment,
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
                           -2.35 + slotDepthMicroadjustment,
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
