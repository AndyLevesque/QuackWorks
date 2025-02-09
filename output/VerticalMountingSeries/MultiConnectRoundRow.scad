/*Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
*/

/*
TODO: 
    - Separate distanceBetweenEach and front/back thickness and ends thickness
    - SmallTriangleY is the vertical distance of the lower front
*/

include <BOSL2/std.scad>

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
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
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
totalHeight = max((triangleY)*itemsDeep+shelfFrontHeight+shelfStepdown*itemsDeep,25);

echo(str("hypotenuse: ", hypotenuse, "; smallHypotenuse: ", smallHypotenuse, "; triangleY: ", triangleY, "; smallTriangleY: ", smallTriangleY, "; inverseSmallTriangleY: ", inverseSmallTriangleY))
echo(str("hypotenuse: ", hypotenuse, "; smallHypotenuse: ", smallHypotenuse, "; triangleX: ", triangleX, "; smallTriangleX: ", smallTriangleX, "; inverseSmallTriangleX: ", inverseSmallTriangleX))


//start build
multiconnectBack(backWidth = totalWidth, backHeight = totalHeight+additionalBackerHeight, distanceBetweenSlots = distanceBetweenSlots);
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
module multiconnectBack(backWidth, backHeight, distanceBetweenSlots)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth,distanceBetweenSlots), backHeight = max(backHeight, 25),slotCount = floor(backWidth/distanceBetweenSlots), backThickness = 6.5){
        difference() {
            translate(v = [0,-backThickness,0]) cube(size = [backWidth,backThickness,backHeight]);
            //Loop through slots and center on the item
            //Note: I kept doing math until it looked right. It's possible this can be simplified.
            for (slotNum = [0:1:slotCount-1]) {
                translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-13]) {
                    slotTool(backHeight);
                }
            }
        }
    }
    //Create Slot Tool
    module slotTool(totalHeight) {
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
                        translate(v = [0,-5,-y*distanceBetweenSlots]) 
                            rotate(a = [-90,0,0]) 
                                color(c = "orange") cylinder(h = 5, r1 = 12, r2 = 10.15);
            }
            //dimple
            if (slotQuickRelease == false)
                scale(v = dimpleScale) 
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = [[0,0],[0,1.5],[1.5,0]]);
        }
    }
}

//this function accepts the parameter of which iteration of the loop your are in and what the parameter should be if not the first. If it is the first, use zero. 
function zeroIfFirst(i, input) = (i == 0) ? 0 : input;
