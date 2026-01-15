/*Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

Credit to 
    Katie (and her community) at Hands on Katie on Youtube 
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @SnazzyGreenWarrior on GitHub for their contributions on the Multipoint-compatible mount
    @Dontic on GitHub for Multiconnect v2 code

Change Log:
- 2024-09-01 
    - Initial release
- 2025-04-29
    - New backs (Multipoint, openGrid, GOEWS)
-2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
    - Enabled OnRamp by default

*/


/*
TODO: 
    - Separate distanceBetweenEach and front/back thickness and ends thickness
    - SmallTriangleY is the vertical distance of the lower front
*/

include <BOSL2/std.scad>

/*[Slot Types]*/
//How do you intend to mount to a surface and which surface?
Connection_Type = "Multiconnect - Multiboard"; // [Multipoint, Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size, GOEWS]


/*[Standard Parameters]*/
//diameter (in mm) of the item you wish to insert (this becomes the internal diameter)
itemDiameter = 25; //0.1
//number of items you wish to hold width-wise (along the back)
itemsWide = 3;
//number of items you wish to hold depth-wise (away from back)
itemsDeep = 2;
//Additional height (in mm) of the rim protruding upward to hold the item
holeDepth = 15; //.1
//Chamfer at the top of the hole
enableChamfer = false;
//Depth of Chamfer (in mm)
holeChamfer = 0.7; //.1
//distance between each item (in mm)
distanceBetweenEach = 2;
//Minimum thickness (in mm) of the base underneath the item you are holding
baseThickness = 2;
//Angle for items
itemAngle = 30; //[0:2.5:90]

//Additional Backer Height (in mm) in case you prefer additional support for something heavy
additionalBackerHeight = 0;
//have front of holder vertical. Recommend enabling if angle exceeds 45 degrees to avoid print overhang issues. 
forceFlatFront = false;
//Shelf stepdown is the heigh (in mm) that rows/shelves will vertically step down. If zero, all rows will be on the same plane. 
shelfStepdown = 5; //.1
/*[Slot Customization]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
customDistanceBetweenSlots = 25;
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

onRampEveryXSlots = On_Ramp_Every_X_Slots;


/*[GOEWS Customization]*/
GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
GOEWS_Cleat_custom_height_from_top_of_back = 11.24;


/* [Hidden] */

//Calculated
//totalWidth = internalWidth + wallThickness*2;
//totalHeight = internalHeight + baseThickness;

distanceBetweenSlots = 
    Connection_Type == "Multiconnect - openGrid" ? 28 :
    Connection_Type == "Multiconnect - Custom Size" ? customDistanceBetweenSlots :
    25; //default for multipoint

Connection_Standard = 
    Connection_Type == "Multipoint" ? "Multipoint" :
    Connection_Type == "Multiconnect - Multiboard" ? "Multiconnect" :
    Connection_Type == "Multiconnect - openGrid" ? "Multiconnect" :
    Connection_Type == "Multiconnect - Custom Size" ? "Multiconnect" :
    Connection_Type == "GOEWS" ? "GOEWS" : 
    "Unknown";


/*[Hidden]*/

//fit items plus 
totalWidth = itemDiameter*itemsWide + distanceBetweenEach*itemsWide + distanceBetweenEach;


rowDepth = itemDiameter+distanceBetweenEach*2;
//inputs the row depth and desired angle to calculate the height of the back
rowBackHeight = rowDepth * tan(itemAngle);

//this is why I should have paid attention in trig...
hypotenuse = rowDepth;
smallHypotenuse = holeDepth+baseThickness;
triangleY = min(sin(itemAngle)*hypotenuse,tan(itemAngle)*hypotenuse);
triangleX = min(cos(itemAngle)*hypotenuse,tan(itemAngle)*hypotenuse);
smallTriangleY = min(sin(itemAngle)*smallHypotenuse,tan(itemAngle)*smallHypotenuse);
smallTriangleX = min(cos(itemAngle)*smallHypotenuse,tan(itemAngle)*smallHypotenuse);
inverseSmallTriangleY = min(sin(90-itemAngle)*smallHypotenuse,tan(90-itemAngle)*smallHypotenuse);
inverseSmallTriangleX = min(cos(90-itemAngle)*smallHypotenuse,tan(90-itemAngle)*smallHypotenuse);
unadjustedShelfDepth = cos(itemAngle)*hypotenuse;
additionalShelfDepth = smallTriangleY;
shelfDepth = unadjustedShelfDepth + additionalShelfDepth;
shelfFrontHeight = inverseSmallTriangleY;
shelfBackHeight = triangleY+inverseSmallTriangleY;
//totalHeight = max((shelfBackHeight)*itemsDeep,25);
totalHeight = max((triangleY)*itemsDeep+shelfFrontHeight+shelfStepdown*itemsDeep,28) + additionalBackerHeight;

echo(str("hypotenuse: ", hypotenuse, "; smallHypotenuse: ", smallHypotenuse, "; triangleY: ", triangleY, "; smallTriangleY: ", smallTriangleY, "; inverseSmallTriangleY: ", inverseSmallTriangleY))
echo(str("hypotenuse: ", hypotenuse, "; smallHypotenuse: ", smallHypotenuse, "; triangleX: ", triangleX, "; smallTriangleX: ", smallTriangleX, "; inverseSmallTriangleX: ", inverseSmallTriangleX))


//start build
//multiconnectBack(backWidth = totalWidth, backHeight = totalHeight+additionalBackerHeight, distanceBetweenSlots = distanceBetweenSlots);

right(totalWidth/2)
union(){
    back(0.01)
        //Basket();
    if(Connection_Standard == "Multipoint"){
    translate([-max(totalWidth,distanceBetweenSlots)/2,0.01,0])
        makebackPlate(
            backWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            backThickness=4.8);
    }
    if(Connection_Standard == "Multiconnect"){
        translate([-max(totalWidth,distanceBetweenSlots)/2,0.01,0])
        makebackPlate(
            backWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            backThickness=6.5);
    }
    if(Connection_Standard == "GOEWS"){
        translate([-max(totalWidth,distanceBetweenSlots)/2,0.01,0])
        makebackPlate(
            backWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = 42,
            backThickness=7
        );
    }
}

//shelf and delete tools. The most parent translates need to match.
difference() {
    for(itemY = [0:1:itemsDeep-1]){
        //position each shelf. Start at the closets to the back and work forward. Several multipliers should not apply to the first shelf, hence the formula. 
        //the min() check for shelf stepdown is to nullify the shelf stepdown if it will create a gap between the shelves. 
        //y axis is to push the item out the full depth and then bring it back if not the first row. 
        echo(str("Shelf Stepdown: ", shelfStepdown, "; inverseSmallTriangleY", inverseSmallTriangleY, "; itemY: ", itemY));
        translate(v = [0,unadjustedShelfDepth*itemY,(itemsDeep-itemY-1)*triangleY-shelfStepdown*itemY+shelfStepdown*(itemsDeep-1)]) {
                difference() {
                //shelf
                    rotate(a = [90,0,90]) 
                        linear_extrude(height = totalWidth) {
                            //craft the 5-sided outline for the shelf that accomodates the desired angle and depth
                            //Don't chamfer the front if angle is over 45 degrees, user doesn't want it, or it is not in the front row
                            if(itemAngle > 45 || forceFlatFront || (itemsDeep > 1 && itemY != itemsDeep-1))
                                polygon(points = [[0,0],[0,shelfBackHeight],[smallTriangleY,shelfBackHeight],[shelfDepth,shelfFrontHeight],[shelfDepth,0]]);
                            else polygon(points = [[0,0],[0,shelfBackHeight],[smallTriangleY,shelfBackHeight],[shelfDepth,shelfFrontHeight],[shelfDepth-smallTriangleY,0]]);
                        }
                }
                //fill from back of row to back
                if (unadjustedShelfDepth*itemY>0){
                    translate(v = [0,-unadjustedShelfDepth*itemY,0]) cube(size = [totalWidth,unadjustedShelfDepth*itemY,triangleY-shelfStepdown*itemY+shelfStepdown*(itemsDeep)]);
                }
        }
    }

    //delete tools
    for(itemY = [0:1:itemsDeep-1]){
        translate(v = [0,unadjustedShelfDepth*itemY,(itemsDeep-itemY-1)*triangleY-shelfStepdown*itemY+shelfStepdown*(itemsDeep-1)]) {
                //delete tools
                for (itemX = [0:1:itemsWide-1]){
                    translate(v = [0,0,triangleY])     
                        //delete tools
                        rotate([-itemAngle,0,0]) {
                            translate(v = [itemDiameter/2+distanceBetweenEach + (itemX*itemDiameter+distanceBetweenEach*itemX),itemDiameter/2+distanceBetweenEach,baseThickness]) {
                                    cylinder(h = holeDepth+1, r = itemDiameter/2, $fn = 50);
                                //chamfer
                                if(enableChamfer)
                                    translate(v = [0,0,holeDepth-holeChamfer]) 
                                        cylinder(h = itemDiameter, r1 = itemDiameter/2, r2 = itemDiameter*2, $fn = 50); 
                            }
                        }
                }
        }
    }
}

//BEGIN MODULES
//Slotted back Module
module makebackPlate(backWidth, backHeight, distanceBetweenSlots, backThickness, slotStopFromBack = 13, edgeRounding = 1)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth,distanceBetweenSlots), backHeight = max(backHeight, 25),slotCount = floor(backWidth/distanceBetweenSlots)- subtractedSlots){
        if(Connection_Standard != "GOEWS"){
            difference() {
                translate(v = [0,-backThickness,0]) 
                cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, edges=FRONT, except_edges=BOT, anchor=FRONT+LEFT+BOT, $fn = 25);
                //Loop through slots and center on the item
                //Note: I kept doing math until it looked right. It's possible this can be simplified.
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-Multiconnect_Stop_Distance_From_Back]) {
                        if(Connection_Standard == "Multipoint"){
                            multiPointSlotTool(totalHeight);
                        }
                        if(Connection_Standard == "Multiconnect"){
                            multiConnectSlotTool(totalHeight);
                        }
                    }
                }
            }
        } else {
            // GOEWS
            GOEWS_Cleat_custom_height_from_top_of_back = (GOEWS_Cleat_position == "normal") ? 11.24 : (GOEWS_Cleat_position == "top") ? 0 :  (GOEWS_Cleat_position == "bottom") ? backHeight - 13.15 : GOEWS_Cleat_custom_height_from_top_of_back;
            
            difference() {
                union() {
                    // Back plate
                    translate(v = [0,-backThickness,0]) 
                    cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, except_edges=BACK, anchor=FRONT+LEFT+BOT);
                    //Loop through slots and center on the item
                    //Note: I kept doing math until it looked right. It's possible this can be simplified.
                    // Add cleats
                    for (slotNum = [0:1:slotCount-1]) {
                        translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-1 * backThickness,backHeight-GOEWS_Cleat_custom_height_from_top_of_back]) {
                            GOEWSCleatTool(totalHeight);
                        }
                    }
                };
                // Remove back plate cut outs for screw threads
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots, 0, backHeight + 0.46 - GOEWS_Cleat_custom_height_from_top_of_back + 11.24]) {
                        rotate([90, 0, 0])
                            cylinder(h = backThickness + 0.1, r = 7, $fn = 256);
                    }
                }
                // Remove back plate cut outs for screw heads
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots, -4, backHeight + 0.46 - GOEWS_Cleat_custom_height_from_top_of_back + 11.24]) {
                        rotate([-90, 0, 0])
                            cylinder(h = 4.1, r = 10, $fn = 256);
                    }
                }
            }
        }
    }   
}

//Create GOEWS cleats
module GOEWSCleatTool(totalHeight) {
    difference() {
        // main profile
        rotate(a = [180,0,0]) 
            linear_extrude(height = 13.15) 
                let (cleatProfile = [[0,0],[15.1,0],[17.6,2.5],[15.1,5],[0,5]])
                union(){
                    polygon(points = cleatProfile);
                    mirror([1,0,0])
                        polygon(points = cleatProfile);
                };
        // angled slice off bottom
        translate([-17.6, -8, -26.3])
            rotate([45, 0, 0])
                translate([0, 5, 0])
                    cube([35.2, 10, 15]);
        // cutout
        translate([0, -0.005, 2.964])
            rotate([90, 0, 0])
                cylinder(h = 6, r = 9.5, $fn = 256);
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
                for(z = [1:On_Ramp_Every_X_Slots:totalHeight/distanceBetweenSlots ])
                {
                    echo("building on z", z);
                    yMultipointSlotDimples(z, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                }
            }
        }
        //on-ramp
        if(onRampEnabled)
            union(){
                for(y = [1:On_Ramp_Every_X_Slots:totalHeight/distanceBetweenSlots])
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
        translate(v = [slotBaseRadius-0.01,0,(-y*distanceBetweenSlots)+distanceOffset+dimple_pitch])
            rotate(a = [90,45,90]) 
            rotate_extrude($fn=4) 
                polygon(points = [[0,0],[0,1.5],[1.7,0]]);
        translate(v = [slotBaseRadius+.75, -2, (-y*distanceBetweenSlots)+distanceOffset-1])
                cube(4);
        translate(v = [slotBaseRadius-2, 0.01, (-y*distanceBetweenSlots)+distanceOffset-1])
                cube(7);
        }
        difference(){
        translate(v = [slotBaseRadius-0.01,0,(-y*distanceBetweenSlots)+distanceOffset-dimple_pitch])
            rotate(a = [90,45,90]) 
            rotate_extrude($fn=4) 
                polygon(points = [[0,0],[0,1.5],[1.7,0]]);
        translate(v = [slotBaseRadius+.75, -2.01, (-y*distanceBetweenSlots)+distanceOffset-3])
                cube(4);
        translate(v = [slotBaseRadius-2, 0.01, (-y*distanceBetweenSlots)+distanceOffset-5])
                cube(10);
        }
}
module yMultipointSlotDimples(z, slotBaseRadius, distanceBetweenSlots, distanceOffset){
    //This creates the multipoint point out dimples within the channel.
    octogonScale = 1/sin(67.5);
    difference(){
        translate(v = [0,0.01,((-z+.5)*distanceBetweenSlots)+distanceOffset])
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


//this function accepts the parameter of which iteration of the loop your are in and what the parameter should be if not the first. If it is the first, use zero. 
function zeroIfFirst(i, input) = (i == 0) ? 0 : input;