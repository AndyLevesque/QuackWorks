/*Created by BlackjackDuck (Andy)
Credit to 
    @David D on Printables for Multiboard
    Jonathan at Keep Making for Multiconnect
    Zach at gridfinity.xyz for the Gridfinity standard
    Katie (and her community) at Hands on Katie on Youtube for advice
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
TODO: 
    - Add ability to tweak rim height
    - Ability to trim grid height (some versions lop off a tiny bit off the top)
*/

/*[Parameters]*/
unitsWide = 2;
unitsDeep = 2;
rimThickness = 1.5;
additionalRimHeight = 2;
baseThickness = 1.5;
overrideBackHeight = false;
customBackHeight = 60;
backHeight = overrideBackHeight ? customBackHeight : 15+15*unitsDeep;
removeBase = true;
bracketDepthPercentage = 50; //[0:1:100]

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
adjustedBaseThickness = removeBase ? 0 : baseThickness;
totalWidth = unitsWide*42+rimThickness*2;
totalDepth = unitsDeep*42+rimThickness;
bracketDepth = totalDepth*bracketDepthPercentage/100;

//begin build
translate(v = [-totalWidth/2,-totalDepth/2]) 
union(){
    translate(v = [rimThickness,0,0]) 
        gridfinity_grid(xCount = unitsWide, yCount = unitsDeep);
    translate(v = [0,0,-adjustedBaseThickness]) 
        multiconnectBack(backWidth = totalWidth, backHeight = backHeight, distanceBetweenSlots = distanceBetweenSlots);
    //shelf
    difference(){
            translate(v = [0,0,-adjustedBaseThickness+0.01]) 
                cube([totalWidth,totalDepth,4.65+adjustedBaseThickness+additionalRimHeight]);
            translate(v = [rimThickness,0,0]) 
                cube([totalWidth-rimThickness*2-0.02,totalDepth-rimThickness-0.02,6+additionalRimHeight]);
    }
    //bracket
    exposedBackHeight = backHeight-adjustedBaseThickness-4.65;
    translate(v = [rimThickness,0,backHeight-adjustedBaseThickness])
        shelfBracket(bracketHeight = exposedBackHeight, bracketDepth = bracketDepth,rimThickness = rimThickness);
    translate(v = [totalWidth,0,backHeight-adjustedBaseThickness])
        shelfBracket(bracketHeight = exposedBackHeight, bracketDepth = bracketDepth,rimThickness = rimThickness);
}

module gridfinity_grid(xCount, yCount) {
  //Gridfinity Grid
    for (columnY = [0:1:yCount-1]){
        for (rowX = [0:1:xCount-1]) {
            translate(v = [rowX*42,columnY*42,0]) gridfinity_base();
        }
    }
}

module gridfinity_base() {
    difference() {
        cube(size = [42,42,4.65]);
        /*
        baseplate delete tool
        This is a delete tool which is the inverse profile of the baseplate intended for Difference.
        Using polygon, I sketched the profile of the base edge per gridfinity specs.
        I then realized I need rounded corners with 8mm outer diameter, so I increased the x axis enough to have a 4mm total outer length (radius).
        I rotate extrude to created the rounded corner 
        Finally, I used minkowski (thank you Katie from "Hands on Katie") using a cube that is 42mm minus the 8mm of the edges (equalling 34mm)
        I also added separate minkowski tools to extend the top and the bottom for proper deleting
        */
        union() {
            //primary profile
            translate(v = [4,38,5.65]) 
                rotate(a = [180,0,0]) 
                    minkowski() {
                        rotate_extrude($fn=50) 
                                polygon(points = [[0,0],[4,0],[3.3,0.7],[3.3,2.5],[1.15,4.65],[0,4.65]]);
                        cube(size = [34,34,1]);
                    }
            //bottom extension bottom tool
            translate(v = [4,4,-2]) 
                    minkowski() {
                        linear_extrude(height = 1) circle(r = 4-2.85, $fn=50);
                        cube(size = [34,34,6]);
            }
            //top extension
                translate(v = [4,4,5])
                    minkowski() {
                        linear_extrude(height = 1) circle(r = 4, $fn=50);
                        cube(size = [34,34,2]);
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
}

module shelfBracket(bracketHeight, bracketDepth, rimThickness){
        rotate(a = [-90,0,90]) 
            linear_extrude(height = rimThickness) 
                polygon([[0,0],[0,bracketHeight],[bracketDepth,bracketHeight]]);
}

