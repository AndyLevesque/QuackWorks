/*Created by Andy Levesque

Credits:
    Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
    @Dontic on GitHub for Multiconnect v2 code
    @timtucker for all the 2025-7-19 improvements listed below

Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

Change Log: 
- 2024-12-07
    - Initial Release
- 2025-03-11
    - Hole Cutout and Slot Cutout added (thanks @user_3620134323)
- 2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
- 2025-07-19 @timtucker
    - Curved support structure (should be stronger, print faster, and use less filament)
    - Allow oval objects
    - Allow generation of rectangular items
    - Allow the hole / slot to be repositioned
    - Prevent the hole / slot from extending into the back wall
    - Allow tuning for the number of slots wide / high
    - Allow tuning of the resolution of circles and curves
    - Simplify / reorganize parameters
- 2025-07-19
    - Add ability to have cutout go out the back of the slots
    
*/

include <BOSL2/std.scad>

/*[Parameters]*/
// Width (in mm) of the item you wish to insert
itemWidth = 50; // 0.1
// Length (in mm) of the item you wish to insert (leave 0 for a circular item)
itemLength = 0; // 0.1
itemShape = "Round"; // [Round, Rectangular]
// Distance (in mm) from the back wall to the back rim
offSet = 0;

/*[Rim]*/
// Height (in mm) of the rim protruding upward to hold the item
rimHeight = 10;
// Thickness (in mm) of the wall surrounding the item
rimThickness = 1;

/*[Cutout]*/
// Diameter of a hole (in mm) for items to pass through (leave 0 for no cutout)
cutoutDiameter = 0;
// Offset from the center (in mm) for the hole to start (postive values extend towards the front wall, negative values extend towards the back wall)
cutoutStart = 0;
// Offset from the center (in mm) for the hole to end (postive values extend towards the front wall, negative values extend towards the back wall)
cutoutEnd = 0;
//Override so that the slot can cut into the back. If doing so, be sure to have enough valid slots in the back (using the slotWide parameters under Multiconnect settings)
Override_Back_Wall_Safety = false;
//Override slot cutout height. Use this when pushing a slot out the back when you don't want the cutout to be the entire height of the back. 
Override_Slot_Cutout_Height = 0;

/*[Support]*/
// Thickness (in mm) of the base underneath the item you are holding (leave 0 for an open hole to hang items)
baseThickness = 3;

/*[Multiconnect]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
// Distance between Multiconnect slots on the back (25mm is standard for MultiBoard, 28mm for openGrid)
distanceBetweenSlots = 25;
// Number of vertical slots for the attachment (recommended to have at least 1/4 the item diameter)
slotsHigh = 1; // [1:0.5:20]
// Number of horizontal slots for the attachment
slotsWide = 2; // [1:1:20]
// QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
// Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; // [0.5:0.05:1.5]
// Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; // [0.925:0.005:1.075]
// Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; // [-0.5:0.05:0.5]
// Enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
// Frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
onRampEveryXSlots = 1;

/*[Performance]*/
// Resolution for circles and curves (higher values are smoother but slower to render)
circleResolution = 500; // [50:50:1000]

/*[Hidden]*/

// Shortcuts for reference measurements and positions
totalItemX = itemWidth + (rimThickness * 2);
adjustedItemLength = itemLength > 0 ? itemLength : itemWidth;
totalItemY = adjustedItemLength + (rimThickness * 2);

totalHeight = slotsHigh * distanceBetweenSlots;
itemCenterX = totalItemX / 2;
itemCenterY = (totalItemY / 2) + offSet;

maxZHeight = max(totalHeight, rimHeight + baseThickness);

beyondX = itemCenterX * 10;
beyondY = itemCenterY * 10;
beyondZ = maxZHeight * 10;

// Support angling up towards the back wall
supportHeight = totalHeight;
if (rimHeight + baseThickness > supportHeight) {
    supportHeight = rimHeight + baseThickness;
}
supportCurveY = itemCenterY * 2;
// Have the support extend up to 2 times the grid distance
supportCurveZ = min(distanceBetweenSlots * 2, (totalHeight - rimHeight) * 2);

// Stop the cutout from extending into the back wall
adjustedCutoutDiameter = min(cutoutDiameter, itemWidth);
adjustedCutoutStart = Override_Back_Wall_Safety ? cutoutStart : 
    max((adjustedCutoutDiameter/2) - itemCenterY + rimThickness, cutoutStart);
adjustedCutoutEnd = max((adjustedCutoutDiameter/2) - itemCenterY + rimThickness, cutoutEnd);
//if cutout height override is used, use that value. Otherwise use beyondz to ensure full cutout
adjustedCutoutHeight = Override_Slot_Cutout_Height == 0 ? beyondZ : Override_Slot_Cutout_Height;

offsetWidth = min(totalItemX, distanceBetweenSlots * slotsWide);

//item holder
difference() {
    // Item holder and support structure
    union() {
        // Outer cylinder for the item holder
        createElongatedObject(shape = itemShape,height = rimHeight + baseThickness, diameterX = totalItemX, diameterY = totalItemY, yCenterStart = itemCenterY, yCenterEnd = itemCenterY, circleResolution = circleResolution);

        // Support structure
        difference() {
            // Fill the space between the item holder and the back wall along the base
            hull() {
                createElongatedObject(shape = itemShape, height = supportHeight, diameterX = totalItemX, diameterY = totalItemY, yCenterStart = itemCenterY, yCenterEnd = itemCenterY, circleResolution = circleResolution);

                // Create the shell to hold the multiconnect slots
                createMulticonnectBackShell(distanceBetweenSlots = distanceBetweenSlots, slotsWide = slotsWide, slotsHigh = slotsHigh);
            }

            // Slope from rim to back wall
            if (totalHeight > rimHeight + baseThickness) {
                union() {
                    // For the curve, subtract a cylinder that extends from the rim up to the back wall
                    translate(v = [-0.5 * beyondX, supportCurveY / 2, baseThickness + rimHeight + (supportCurveZ / 2)]) {
                        scale(v = [1, supportCurveY, supportCurveZ]) {
                            rotate([0, 90, 0]) {
                                cylinder(h = beyondX, d = 1, $fn = circleResolution);
                            }
                        }
                    }

                    // Remove the front half of the cylinder
                    translate(v = [-0.5* beyondX, itemCenterY, rimHeight + baseThickness]) {
                        cube([beyondX, beyondY, beyondZ]);
                    }

                    // Remove anything above the cylinder
                    translate(v = [-0.5 * beyondX, 0, baseThickness + rimHeight + supportCurveZ / 2]) {
                        cube([beyondX, beyondY, beyondZ]);
                    }                    
                }
            }
        }
    }
    union() {
        // Cut out space for the item to fit into
        translate(v = [0, 0, (baseThickness > 0) ? baseThickness : -0.5 * beyondZ]) {
            createElongatedObject(shape = itemShape, height = beyondZ, diameterX = itemWidth, diameterY = adjustedItemLength, yCenterStart = itemCenterY, yCenterEnd = itemCenterY, circleResolution = circleResolution);
        }

        // Cut out a hole / slot
        createCutout(holeDiameter = adjustedCutoutDiameter, yCenterStart = itemCenterY + adjustedCutoutStart, yCenterEnd = itemCenterY + adjustedCutoutEnd, height = adjustedCutoutHeight, circleResolution = circleResolution);

        // Remove the slots for multiconnect
        translate(v = [-(slotsWide * distanceBetweenSlots)/2,0,0]) {
            createMulticonnectSlots(backWidth = slotsWide * distanceBetweenSlots, backHeight = slotsHigh * distanceBetweenSlots, distanceBetweenSlots = distanceBetweenSlots, circleResolution = circleResolution);
        }
    }
}

module createCutout(holeDiameter=0, yCenterStart=0, yCenterEnd=0, height = beyondZ, circleResolution=100) {
    // Use extreme values to ensure that the cutout extends beyond the bounds of the object
    translate(v = [0, 0, -0.01]) {
        createElongatedObject(height = height, diameterX = holeDiameter, diameterY = holeDiameter, yCenterStart = yCenterStart, yCenterEnd = yCenterEnd, circleResolution = circleResolution);
    }
}

module createElongatedObject(height, shape="Round", diameterX=0, diameterY=0, xCenterStart=0, xCenterEnd=0, yCenterStart=0, yCenterEnd=0, circleResolution=100) {
    // There's no object to create if the diameter is 0 or less
    if (diameterX > 0 && diameterY > 0) {
        // Create an elongated round object (like a cylinder) that extends from start to end position
        hull() {
            // Starting position for the object
            translate(v = [xCenterStart, yCenterStart, 0]) {
                createObject(height = height, shape = shape, diameterX = diameterX, diameterY = diameterY, circleResolution = circleResolution);
            }
            
            // Ending position for the object
            translate(v = [xCenterEnd, yCenterEnd, 0]) {
                createObject(height = height, shape = shape, diameterX = diameterX, diameterY = diameterY, circleResolution = circleResolution);
            }
        }
    }
}

module createObject(height, shape="Round", diameterX=0, diameterY=0, circleResolution=100) {
    // There's no object to create if the diameter is 0 or less
    if (diameterX > 0 && diameterY > 0) {
        // Create a round object (like a cylinder)
        if (shape == "Round") {
            scale(v = [diameterX, diameterY, 1]) {
                cylinder(h = height, d = 1, $fn = circleResolution);
            }
        }
        else if (shape == "Rectangular") {
            translate(v = [-diameterX/2, -diameterY/2, 0]) {
                // Create a rectangular prism
                cube([diameterX, diameterY, height]);
            }
        }
    }
}

//BEGIN MODULES
//Slotted back Module
module createMulticonnectSlots(backWidth, backHeight, distanceBetweenSlots, circleResolution=100)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth, distanceBetweenSlots), backHeight = max(backHeight, distanceBetweenSlots), slotCount = floor(backWidth / distanceBetweenSlots), backThickness = 6.5){
        //Loop through slots and center on the item
        //Note: I kept doing math until it looked right. It's possible this can be simplified.
        for (slotNum = [0:1:slotCount-1]) {
            translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-13]) {
                slotTool(backHeight);
            }
        }
    }

    // Create Slot Tool
    module slotTool(totalHeight) {
        scale(v = slotTolerance)
        // Slot minus optional dimple with optional on-ramp
        let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
        difference() {
            union() {
                // Round top
                rotate(a = [90,0,0,]) {
                    rotate_extrude($fn = circleResolution) {
                        polygon(points = slotProfile);
                    }
                }

                // Long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0])
                    union() {
                        difference() {
                            // Main half slot
                            linear_extrude(height = totalHeight+1) {
                                polygon(points = slotProfile);
                            }
                            
                            // Snap cutout
                            if (slotQuickRelease == false && multiConnectVersion == "v2") {
                                translate(v= [10.15,0,0]) {
                                    rotate(a= [-90,0,0]) {
                                        linear_extrude(height = 5) {  // match slot height (5mm)
                                            polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 specs
                                        }
                                    }
                                }
                            }
                        }

                        mirror([1,0,0]) {
                            difference() {
                                // Main half slot
                                linear_extrude(height = totalHeight+1) {
                                    polygon(points = slotProfile);
                                }
                                
                                // Snap cutout
                                if (slotQuickRelease == false && multiConnectVersion == "v2") {
                                    translate(v= [10.15,0,0]) {
                                        rotate(a= [-90,0,0]) {
                                            linear_extrude(height = 5) {  // match slot height (5mm)
                                                polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 spec
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                // On-ramp
                if(onRampEnabled)
                    for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots]) {
                        translate(v = [0,-5,-y*distanceBetweenSlots]) {
                            rotate(a = [-90,0,0]) {
                                cylinder(h = 5, r1 = 12, r2 = 10.15);
                            }
                        }
                    }
            }
            // Dimple
            if (slotQuickRelease == false && multiConnectVersion == "v1") {
                scale(v = dimpleScale) {
                    rotate(a = [90,0,0,]) {
                        rotate_extrude($fn = circleResolution) {
                            polygon(points = [[0,0],[0,1.5],[1.5,0]]);
                        }
                    }
                }
            }
        }
    }
}

module createMulticonnectBackShell(distanceBetweenSlots=25, slotsWide=1, slotsHigh=1, backThickness=6.5) {
    translate(v = [-(distanceBetweenSlots * slotsWide) / 2, -backThickness, 0]) {
        cube([distanceBetweenSlots * slotsWide, backThickness, distanceBetweenSlots * slotsHigh]);
    }
}
