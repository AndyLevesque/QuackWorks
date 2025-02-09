/*
Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

This file is the master copy of the multiconnect slot back. 
All components of this file are required in any file using this backer

NOTE: This module may break if the child of another object subject to diff(), intersect(), or union(). 
    Instead, attach to an object 
    For example: 
        cuboid([1]){
            somthing else;
            attach() multiconnectGenerator()
        }
    NOT: 
        cuboid([1])
            attach() multiconnectGenerator()
    https://github.com/BelfrySCAD/BOSL2/issues/270
*/

include <BOSL2/std.scad>

/*[Part Selection]*/
//Backer is for vertical mounting. Passthru for horizontal mounting. Linear Connector is for generating the male connector. 
multiconnectPartType = "Backer"; //[Backer, Passthru, Linear Connector]

/*[Receptor Parameters]*/
totalWidth = 50;
totalHeight = 75;

/*[Male Connector Parameters]*/
unitsWide = 4;

/*[General Multiconnect Customization]*/
//QuickRelease removes the small indent in the top of the slots that lock the part into place
dimplesEnabled = true;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back
slotTolerance = 1.00; //[1:0.005:1.075]
//Move the slot in (positive) or out (negative) - Disabled at the moment
//slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//enable a slot on-ramp for easy mounting of tall items
//ADVANCED: Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
/*[Backer-Style Slot Customization]*/
onRampEnabled = true;
//frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
onRampEveryNSlots = 2;
//move the start of the series of on-ramps n number of slots down
onRampOffsetNSlots = 1;
//move the start of the slots (in mm) up (positive) or down (negative)
slotVerticalOffset = 0;
/*[Passthru-Style Slot Customization]*/
//change slot orientation
slotOrientation = "Vertical"; //["Horizontal", "Vertical"]
//set distance (in mm) inward from the start if the set. 0 = middle of slot. 
//dimpleInset = 0;
//set a multiconnect to be at exact center rather
centerMulticonnect = true;
//enable on-ramp for passthru-type backers
onRampPassthruEnabled = false; 
//modify how many units between each dimple
dimpleEveryNSlots = 2;
//shift the series of dimples left or right by n units
dimpleOffset = 1;

/* [Hidden] */
debug = false; 

//standard module call
multiconnectGenerator(
    width = multiconnectPartType == "Linear Connector" ? (unitsWide-1) *distanceBetweenSlots : totalWidth, 
    height = multiconnectPartType == "Linear Connector" ? 0 : totalHeight, 
    multiconnectPartType = multiconnectPartType, 
    slotTolerance = slotTolerance, 
    slotOrientation=slotOrientation,
    //dimple values
    slotDimple = dimplesEnabled, 
    dimpleScale = dimpleScale, 
    dimpleEveryNSlots = dimpleEveryNSlots, 
    dimpleOffset = dimpleOffset, 
    dimpleCount = 1, 
    centerMulticonnect=centerMulticonnect,
    slotVerticalOffset = slotVerticalOffset, 
    //onramp values
    onRampEnabled = onRampEnabled, 
    onRampEveryNSlots = onRampEveryNSlots, 
    onRampOffsetNSlots = onRampOffsetNSlots, 
    onRampPassthruEnabled = onRampPassthruEnabled,
    //other values
    distanceBetweenSlots = distanceBetweenSlots, 
    anchor=BOTTOM 
    );

//BEGIN MODULES
module multiconnectGenerator(width, height, multiconnectPartType = "Backer", distanceBetweenSlots = 25, onRampEnabled = true, onRampEveryNSlots = 1, onRampOffsetNSlots = 0, slotTolerance = 1, slotVerticalOffset = 2.85, backerThickness = 6.5, slotOrientation = "Vertical", slotDimple = true, dimpleScale = 1, dimpleEveryNSlots = 1, dimpleOffset = 0, dimpleCount = 999, centerMulticonnect=centerMulticonnect, onRampPassthruEnabled = onRampPassthruEnabled, anchor=CENTER, spin=0, orient=UP){

    attachable(anchor, spin, orient, size=[width, backerThickness, height]*slotTolerance){ 
    
        slotStandardPath = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,4.15],[0,4.15]];
        connectorStandardPath = [[0,0], [10, 0], [10, 1], [7.5, 3.5], [7.5, 4], [0, 4]];

        //Backer type
        if (multiconnectPartType == "Backer"){
            width = width < distanceBetweenSlots ? distanceBetweenSlots : width; //if width is less than 25, force 25 to ensure at least 1 slot
            diff("slot"){
            cuboid([width, backerThickness, height]);
                xcopies(n = floor(width/distanceBetweenSlots), spacing = distanceBetweenSlots)
                    tag("slot") 
                        down((13-10.15-slotVerticalOffset)*slotTolerance) attach(TOP, TOP, inside=true, align=FRONT, shiftout=0.01) 
                            scale(slotTolerance) 
                                multiconnectRoundedEnd(slotProfile = slotStandardPath, slotDimple = slotDimple, dimpleScale = dimpleScale, anchor=BOT+BACK)
                                    up(0.1) attach(BOT, TOP, overlap=0.01) 
                                        multiconnectSlot(length = height, slotProfile = slotStandardPath, multiconnectPartType = multiconnectPartType, slotDimple = dimplesEnabled, distanceBetweenSlots = distanceBetweenSlots, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, anchor=FRONT, dimpleScale = dimpleScale, dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, dimpleCount=dimpleCount);
            }
        }
        //Passthru type
        else if (multiconnectPartType == "Passthru"){
            diff("slot"){
                    cuboid([width, backerThickness, height]){
                    if (slotOrientation == "Vertical") {
                        xcopies(n = floor(width/distanceBetweenSlots), spacing = distanceBetweenSlots)
                            tag("slot") 
                                attach(TOP, TOP, inside=true, align=FRONT, shiftout = 0.01) 
                                    multiconnectSlot(length = height, slotProfile = slotStandardPath, multiconnectPartType = multiconnectPartType, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, slotDimple = dimplesEnabled,  dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, onRampPassthruEnabled = onRampPassthruEnabled, anchor=FRONT);
                    }
                    else { //slots horizontal
                        zcopies(n = floor(height/distanceBetweenSlots), spacing = distanceBetweenSlots)
                            tag("slot") 
                                attach(LEFT, TOP, inside=true, align=FRONT, shiftout = 0.01) back(10.15)
                                    multiconnectSlot(length = width+1, slotProfile = slotStandardPath, multiconnectPartType = multiconnectPartType, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, slotDimple = dimplesEnabled, dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, onRampPassthruEnabled = onRampPassthruEnabled, distanceBetweenSlots=distanceBetweenSlots, anchor=FRONT, spin=90);
                    }
                    }
                }
        }
        //male connector
        else  {   
            multiconnectSlot(width, slotProfile = connectorStandardPath, onRampEnabled = false, spin=[90,0,0])
                attach([TOP, BOT], BOT) multiconnectRoundedEnd(slotProfile = connectorStandardPath);
        }
        children();  
    }

    //round top
    module multiconnectRoundedEnd(slotProfile, slotDimple = true, dimpleScale = 1, anchor=CENTER, spin=0, orient=UP){
        attachable(anchor, spin, orient, size=[maxX(slotProfile)*2,maxY(slotProfile),maxX(slotProfile)]){
            down(maxX(slotProfile)/2)
            //top_half() 
            diff("slotDimple"){
                multiconnectRounded(slotProfile = slotProfile)
                if(slotDimple) tag("slotDimple")attach(BACK, BOT, inside=true, shiftout=0.01) cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);
            }
            children();
        }
        module multiconnectRounded(slotProfile, anchor=CENTER, spin=0, orient=UP){
            attachable(anchor, spin, orient, size=[maxX(slotProfile)*2,maxY(slotProfile),maxX(slotProfile)*2]){
                back(maxY(slotProfile)/2)
                    top_half()
                        rotate(a = [90,0,0,]) 
                            rotate_extrude($fn=50) 
                                polygon(points = slotProfile);
                children();
            }
        }//End multiconnectRounded
    }

    module multiconnectSlot(length, slotProfile, multiconnectPartType = "Backer", distanceBetweenSlots = 25, onRampEnabled = true, onRampEveryNSlots = 1, onRampOffsetNSlots = 0, slotDimple = true, dimpleScale = 1, dimpleEveryNSlots = 1, dimpleOffset = 0, dimpleCount = 999, onRampPassthruEnabled = false, anchor=CENTER, spin=0, orient=UP){
        attachable(anchor, spin, orient, size=[maxX(slotProfile)*2,maxY(slotProfile),length]){
            diff("slotDimple"){
                multiconnectLinear(length = length, slotProfile = slotProfile, multiconnectPartType = multiconnectPartType, distanceBetweenSlots = distanceBetweenSlots, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, onRampPassthruEnabled = onRampPassthruEnabled);
                if(slotDimple && dimpleEveryNSlots != 0 && multiconnectPartType == "Backer") {
                    //calculate the dimples. Dimplecount can override if less than calculated slots
                    if(debug) echo("Dimples for Backer");
                    tag("slotDimple") attach(BACK, BOT, align=TOP, inside=true, shiftout=0.01) back(1.5*dimpleScale) 
                            cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);
                    zcopies(n = min(length/distanceBetweenSlots/dimpleEveryNSlots+1, dimpleCount), spacing = -distanceBetweenSlots*dimpleEveryNSlots, sp=[0,0,dimpleOffset*distanceBetweenSlots]) 
                        tag("slotDimple") attach(BACK, BOT, align=TOP, inside=true, shiftout=0.01) back(1.5*dimpleScale) 
                            cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);
                }
                if(slotDimple && dimpleEveryNSlots != 0 && multiconnectPartType == "Passthru"){ //passthru
                    //calculate the dimples. Dimplecount can override if less than calculated slots
                    if(debug) echo(str("Dimples for Passthru: ", min(length/distanceBetweenSlots/dimpleEveryNSlots+2, dimpleCount), ". Distance between: ", -distanceBetweenSlots*dimpleEveryNSlots));
                    zcopies(n = min(length/distanceBetweenSlots/dimpleEveryNSlots+2, dimpleCount), spacing = -distanceBetweenSlots*dimpleEveryNSlots, sp=[0,0,centerMulticonnect ? -length/2+25*3/2-12.5+25+dimpleOffset*distanceBetweenSlots: -length/2+25*3/2+25+dimpleOffset*distanceBetweenSlots]) 
                        tag("slotDimple") attach(BACK, BOT, align=TOP, inside=true, shiftout=0.01) back(1.5*dimpleScale) 
                            cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);

                }
            
            }
            children();
        }
        //long slot
        module multiconnectLinear(length, slotProfile, multiconnectPartType = "Backer", distanceBetweenSlots = 25, onRampEnabled = true, onRampEveryNSlots = 1, onRampOffsetNSlots = 0, onRampPassthruEnabled = false, anchor=CENTER, spin=0, orient=UP){
            attachable(anchor, spin, orient, size=[maxX(slotProfile)*2,maxY(slotProfile),length]){
                up(length/2) back(maxY(slotProfile)/2) 
                intersection() {
                    union(){
                        rotate(a = [180,0,0]) 
                            linear_extrude(height = length) 
                                union(){
                                    polygon(points = slotProfile);
                                        mirror([1,0,0])
                                            polygon(points = slotProfile);
                                }
                        //onramp
                        if(onRampEnabled && onRampEveryNSlots != 0 && multiconnectPartType == "Backer") {
                                zcopies(spacing=-distanceBetweenSlots*onRampEveryNSlots, n=length/distanceBetweenSlots/onRampEveryNSlots+1, sp=[0,0,-distanceBetweenSlots-onRampOffsetNSlots*distanceBetweenSlots]) 
                                    fwd(maxY(slotProfile)/2) color("orange") 
                                        cyl(h = maxY(slotProfile), r1 = maxX(slotProfile)+1.75, r2 = maxX(slotProfile), spin=([90,0,180]));
                        } 
                        if(onRampPassthruEnabled && onRampEveryNSlots != 0 && multiconnectPartType == "Passthru"){
                                zcopies(spacing=-distanceBetweenSlots*onRampEveryNSlots, n=length/distanceBetweenSlots+2, sp=[0,0,centerMulticonnect ? -length/2+distanceBetweenSlots*3/2-distanceBetweenSlots/2+distanceBetweenSlots: -length/2+distanceBetweenSlots*3/2+distanceBetweenSlots]) 
                                    fwd(maxY(slotProfile)/2) color("orange") 
                                        cyl(h = maxY(slotProfile), r1 = maxX(slotProfile)+1.75, r2 = maxX(slotProfile), spin=([90,0,180]));
                        }                    
                    }
                    //lop off any extra zcopies pieces
                    cuboid([25,25, length], anchor=TOP);
                }
                children();
            }
        }
    }
}

//take a total length and divisible by and calculate the remainder
//For example, if the total length is 81 and units are 25 each, then the excess is 5
function excess(total, divisibleBy) = round(total - floor(total/divisibleBy)*divisibleBy);
//calculate the max x and y points. Useful in calculating size of an object when the path are all positive variables originating from [0,0]
function maxX(path) = max([for (p = path) p[0]]);
function maxY(path) = max([for (p = path) p[1]]);

