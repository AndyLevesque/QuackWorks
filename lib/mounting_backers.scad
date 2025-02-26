/*
Created by Andy (BlackjackDuck)

This code is licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
References to Multipoint are for the Multiboard ecosystem by Jonathan at Keep Making. The Multipoint mount system is licensed under https://www.multiboard.io/license.

Credit to 
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @SnazzyGreenWarrior on GitHub for their contributions on the Multipoint-compatible mount
    MrExo3D on Printables for the GOEWS system

Using this module: 
    This module imports the various mounting systems created within the QuackWorks repo and generates a "backer plate" with that standard. The backer plate is a flat plate intended to be attached to the back of various items to be mounted. 
    Parameters below should be passed to the main module to appear in the customizer.
    Primary inputs are width and height.
    distanceBetweenSlots is indicative to the grid size and drives the distance between slots or other mounting points. 
*/

include <BOSL2/std.scad>
include <BOSL2/walls.scad>

include <goews.scad>
include <multiconnect.scad>
include <multipoint.scad>


// /*[Mounting]*/
// //Multipoint in Beta - Please share feedback! How do you intend to mount the item holder to a surface such as Multipoint connections or DavidD's Multiconnect?
// Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect, GOEWS]

// /*[Style Customizations]*/
// //Edge rounding (in mm)
// edgeRounding = 0.5; // [0:0.1:2]

// /*[Slot Customization]*/

// onRampHalfOffset = true;
// //Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
// distanceBetweenSlots = 25;
// //Reduce the number of slots
// subtractedSlots = 0;
// //QuickRelease removes the small indent in the top of the slots that lock the part into place
// slotQuickRelease = false;
// //Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
// dimpleScale = 1; //[0.5:.05:1.5]
// //Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
// slotTolerance = 1.00; //[0.925:0.005:1.075]
// //Move the slot in (positive) or out (negative)
// slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
// //enable a slot on-ramp for easy mounting of tall items
// onRampEnabled = true;
// //frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
// On_Ramp_Every_X_Slots = 1;
// //Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
// Multiconnect_Stop_Distance_From_Back = 13;

// /*[GOEWS Customization]*/
// GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
// GOEWS_Cleat_custom_height_from_top_of_back = 11.24;

//example call makebackPlate
//makebackPlate(backWidth = 50, backHeight = 50, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);

//Slotted back Module
module makebackPlate(backWidth, backHeight, distanceBetweenSlots = 25, backThickness = 0, slotStopFromBack = 13, onRampEveryXSlots = 1, Connection_Type = "Multiconnect")
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (
            backWidth = max(backWidth,distanceBetweenSlots), 
            backHeight = max(backHeight, 25),
            slotCount = floor(backWidth/distanceBetweenSlots)- subtractedSlots,
            backThickness = backThicknessCalc(backThicknessRequested = backThickness, Connection_Type)
        ){
        if(Connection_Type != "GOEWS"){
            difference() {
                translate(v = [0,-backThickness,0]) 
                cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, except_edges=BACK, anchor=FRONT+LEFT+BOT);
                //Loop through slots and center on the item
                //Note: I kept doing math until it looked right. It's possible this can be simplified.
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-Multiconnect_Stop_Distance_From_Back]) {
                        if(Connection_Type == "Multipoint"){
                            multiPointSlotTool(backHeight, onRampEveryXSlots);
                        }
                        if(Connection_Type == "Multiconnect"){
                            multiConnectSlotTool(backHeight, onRampEveryXSlots);
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
                            GOEWSCleatTool(backHeight);
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


function backThicknessCalc(backThicknessRequested, mountingType) = 
    backThicknessRequested != 0 ? backThicknessRequested : 
    mountingType == "GOEWS" ? 7 :
    mountingType == "Multipoint" ? 4.8 :
    mountingType == "Multiconnect" ? 6.5 : 
    backThickenssRequested;