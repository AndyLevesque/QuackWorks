/*Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
*/

/*
TODO: 
    - Separate distanceBetweenEach and front/back thickness and ends thickness
    - SmalllargeTriangleY is the vertical distance of the lower front
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/*[Standard Parameters]*/
//diameter (in mm) of the item you wish to insert (this becomes the internal diameter)
itemDiameter = 25; //0.1
//number of items you wish to hold width-wise (along the back)
itemsWide = 3;
//number of items you wish to hold depth-wise (away from back)
itemsDeep = 3;
//Additional height (in mm) of the rim protruding upward to hold the item
holeDepth = 15; //.1
//Chamfer at the top of the hole
enableChamfer = false;
//Depth of Chamfer (in mm)
holeChamfer = 0.7; //.1
//distance between each item (in mm)
distanceBetweenEach = 2;
//Front support
frontBuffer = 3;
//Back Support
backBuffer = 3;
//side support
sideBuffer = 2; 
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
totalWidth = itemDiameter*itemsWide + distanceBetweenEach*itemsWide + distanceBetweenEach + sideBuffer*2;
shelfDepth = itemDiameter+frontBuffer+backBuffer;
shelfHeight = holeDepth+baseThickness;

//calculate the Y and Z distances for the two triangels formed when rotating a square. 
largeHypotenuse = shelfDepth;
largeTriangleY = largeHypotenuse*cos(itemAngle);
largeTriangleZ = largeHypotenuse*sin(itemAngle);
smallHypotenuse = shelfHeight;
smallTriangleY = smallHypotenuse*sin(itemAngle);
smallTriangleZ = smallHypotenuse*cos(itemAngle);
echo(str("Shelf Depth: ", shelfDepth));
echo(str("Hypostenuse: ", largeHypotenuse));


//START BUILD
%zcopies(smallTriangleZ+largeTriangleZ, n=itemsDeep)
    translate(v = [0,(largeTriangleY-smallTriangleY)*$idx,0]) 
        xrot(itemAngle, cp=BACK)
            diff()
                cuboid(size = [totalWidth, itemDiameter+frontBuffer+backBuffer, holeDepth+baseThickness], chamfer=2, edges=[TOP+LEFT,TOP+RIGHT], anchor=BOTTOM+BACK)
                        attach(TOP,TOP, inside=true, shiftout=0.01) 
                            xcopies(itemDiameter + distanceBetweenEach, n = itemsWide)
                                cylinder(h = holeDepth, r = itemDiameter/2, anchor=BOTTOM);

zcopies(smallTriangleZ+largeTriangleZ, n=itemsDeep)
    translate(v = [0,0,0]) 
        xrot(itemAngle, cp=BACK)
            diff()
                cuboid(size = [totalWidth, itemDiameter+frontBuffer+backBuffer, holeDepth+baseThickness], chamfer=2, edges=[TOP+LEFT,TOP+RIGHT], anchor=BOTTOM+BACK)
                        attach(TOP,TOP, inside=true, shiftout=0.01) 
                            xcopies(itemDiameter + distanceBetweenEach, n = itemsWide)
                                cylinder(h = holeDepth, r = itemDiameter/2, anchor=BOTTOM);




//alternative
/*
%xrot(itemAngle)
    ycopies(shelfDepth, n=itemsDeep)
        translate(v = [0,0,0]) 
            diff()
                cuboid(size = [totalWidth, itemDiameter+frontBuffer+backBuffer, holeDepth+baseThickness], chamfer=2, edges=[TOP+LEFT,TOP+RIGHT], anchor=BOTTOM+BACK)
                        attach(TOP,TOP, inside=true, shiftout=0.01) 
                            xcopies(itemDiameter + distanceBetweenEach, n = itemsWide)
                                cylinder(h = holeDepth, r = itemDiameter/2, anchor=BOTTOM);
*/

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
                    color(c = "red")  slotTool(backHeight);
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
                        translate(v = [0,-5,-y*distanceBetweenSlots]) 
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