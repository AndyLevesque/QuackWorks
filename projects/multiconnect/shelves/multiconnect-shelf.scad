/*Created by Andy Levesque

Credits
    Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
    @Dontic on GitHub for Multiconnect v2 code
    
Change Log: 
-2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
    - Enabled OnRamp by default
-2025-07-24
    - Added new backer options for Multipoint, GOEWS, OpenGrid Multiconnect
    
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
*/

include <BOSL2/std.scad>

/*[Shelf Type and Mounting Type]*/
//Select shelf type
Shelf_Type = "Bottom Shelf"; //[Bottom Shelf, Top Shelf]
//How do you intend to mount to a surface and which surface?
Connection_Type = "Multiconnect - Multiboard"; // [Multipoint, Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size, GOEWS]


/* [Internal Dimensions] */
//Height (in mm) from the top of the back to the base of the internal floor
internalHeight = 50.0; //.1
//Width (in mm) of the internal dimension or item you wish to hold
internalWidth = 50.0; //.1
//Length (i.e., distance from back) (in mm) of the internal dimension or item you wish to hold
internalDepth = 40.0; //.1
/* [Shelf Customizations] */
//Distance upward from the bottom (in mm) that captures the bottom front of the item
rimHeight = 3;
bracket_style = "45deg"; //[45deg,half_distance,none]

/* [Additional Customization] */
//Thickness of bin walls (in mm)
wallThickness = 3; //.1
//Thickness of bin  (in mm)
baseThickness = 3; //.1

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

adjustedBackThickness = 
    Connection_Standard == "Multipoint" ? 4.8 : 
    Connection_Standard == "Multiconnect" ? 6.5 : 
    Connection_Standard == "GOEWS" ? 7 : 
    6.5;

//Calculated
totalHeight = max(internalHeight+baseThickness,distanceBetweenSlots);
totalDepth = internalDepth + wallThickness;
totalWidth = max(internalWidth + wallThickness*2,distanceBetweenSlots);
productCenterX = internalWidth/2;

//Backer
if(Shelf_Type == "Bottom Shelf")
translate(v = [-totalWidth/2,0,-baseThickness]) {
        makebackPlate(
            backWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            backThickness=adjustedBackThickness);
}
if(Shelf_Type == "Top Shelf")
rot([0,180,0])
translate(v = [-totalWidth/2,0,-totalHeight + baseThickness]) {
        makebackPlate(
            backWidth = totalWidth, 
            backHeight = totalHeight, 
            distanceBetweenSlots = distanceBetweenSlots,
            backThickness=adjustedBackThickness);
}

translate(v = [-internalWidth/2,0,0]) 
    //Basket minus slots
    difference() {
        shelf();
            //delete tool for anything above the product (i.e., bracket fix)
        translate(v = [-wallThickness-1 ,-1,internalHeight]) cube([totalWidth+2,totalDepth+2,totalHeight]); 
    }

//Create Basket
module shelf() {
    union() {
        //bottom
        translate([-wallThickness,0,-baseThickness])
            cube([internalWidth + wallThickness*2, internalDepth + wallThickness,baseThickness]);

        //left wall
        if(Shelf_Type == "Bottom Shelf"){
        translate([-wallThickness,0,0])
            cube([wallThickness, internalDepth + wallThickness, rimHeight]);

        //right wall
        translate([internalWidth,0,0])
            cube([wallThickness, internalDepth + wallThickness, rimHeight]);

        //front wall
        translate([0,internalDepth,0]) 
            cube([internalWidth,wallThickness,rimHeight]);
        }

        bracketDistance = min(internalHeight/2,internalDepth/2);
        echo(str("Bracket Distance: ",bracketDistance));
        
        //shelf brackets      
        if (bracket_style == "half_distance") {
            translate(v = [0,0,internalHeight/2+(Shelf_Type == "Bottom Shelf" ? rimHeight : 0)])
                shelfBracket(bracketHeight = internalHeight/2, bracketDepth = internalDepth/2);
            translate(v = [internalWidth+wallThickness,0,internalHeight/2+(Shelf_Type == "Bottom Shelf" ? rimHeight : 0)])
                shelfBracket(bracketHeight = internalHeight/2, bracketDepth = internalDepth/2);
        }
        if (bracket_style == "45deg"){
            translate(v = [0,0,bracketDistance+ (Shelf_Type == "Bottom Shelf" ? rimHeight : 0)])
                shelfBracket(bracketHeight = bracketDistance, bracketDepth = bracketDistance);
            translate(v = [internalWidth+wallThickness,0,bracketDistance+(Shelf_Type == "Bottom Shelf" ? rimHeight : 0)])
                shelfBracket(bracketHeight = bracketDistance, bracketDepth = bracketDistance);
        }
    }
            
}

module shelfBracket(bracketHeight, bracketDepth){
        rotate(a = [-90,0,90]) 
            linear_extrude(height = wallThickness) 
                polygon([[0,0],[0,bracketHeight],[bracketDepth,bracketHeight]]);
}

//BEGIN OLD MODULES
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


//END OLD MODULES

/*

BEGIN NEW MODULES

*/

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

