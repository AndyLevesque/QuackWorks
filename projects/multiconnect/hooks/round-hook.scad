/* Created by Andy Levesque, remixed by Moritz Weller

Credits:
    Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
    @Dontic on GitHub for Multiconnect v2 code

Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

Change Log: 
-2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
*/

/*[Round Hook specific parameters]*/
// Enable edge beveling
enableMinkowski = true;

// Bevel radius
r = 2.3;//[0:.1:2.3]

//Hook diameter
hookDiameter = 75;//[0:1:200]

//Hook angle
angle=90;//[0:1:180]

/* [Standard Parameters] */
hookWidth = 25;
hookInternalDepth = 0;//[0:1:100]


/* [Additional Customization] */

hookBottomThickness = 5;
backHeight = 40;

/* [Slot Customization] */
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
distanceBetweenSlots = 25;
slotQuickRelease = false;
dimpleScale = 1; //[0.5:.05:1.5]
slotTolerance = 1.00; //[0.925:0.005:1.075]
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
onRampEnabled = false;
onRampEveryXSlots = 1;

/*[Hidden]*/
backWidth = max(distanceBetweenSlots, hookWidth);
subDivCircles=66;
subDivMinkowski=32;
// Show Hook Back
showHookBack = true;
// Show Hook Base
showHookBase = true;
// Show Hook Lip
showHookLip = false;
// Cut slots
cutSlots = true;
//radius1
r1=hookDiameter/2;//[10:1:50]
hookLipThickness = 3;
//Hook angle
hookAngle=-angle+180;
hookLipHeight = 4;

// Round Hook Experiment

module roundHook(flag){
let (adj = flag ? r : 0)
{
    translate([hookWidth/2-adj,hookInternalDepth+hookLipThickness,r1])
        rotate([0,-90,0])
            linear_extrude(hookWidth-2*adj)
    {
        difference(){
        //translate([hookWidth/2,hookInternalDepth+hookLipThickness,hookBottomThickness])
            rotate([0,0,0])
                circle(r1-adj, $fn=subDivCircles);
        //translate([hookWidth/2,hookInternalDepth+hookLipThickness,hookBottomThickness])
        rotate([0,0,0])
            circle(r1-hookBottomThickness+adj, $fn=subDivCircles);
        rotate([0,0,hookAngle-90])
            translate([0,-r1*2,r1/2])
                square([r1*2,r1*2]);
        translate([0,-r1*2,r1/2])         
            rotate([0,0,-hookAngle-180])
                square([r1*2,r1*1.1]);
        translate([0,-r1*2,r1/2])         
            rotate([0,0,-hookAngle-145])
                square([r1*2,r1*1.1]);
        translate([0,-r1*2,r1/2])         
            rotate([0,0,-hookAngle-140])
                square([r1*2,r1*1.1]);
        
        rotate([0,0,0])
            translate([-r1*2,-r1*2,r1/2])
                square([r1*2,r1*2]);
        rotate([0,0,hookAngle])
            translate([0,-r1*2,r1/2])
                square([r1*2,r1*2]);
}
        }
    }
}



// Hook
module hookBack(flag) {
    translate(v = [-backWidth / 2, 0, 0]) 
        multiconnectBack(backWidth, backHeight, distanceBetweenSlots, flag);
}

module hookBase(flag) {
let (adj = flag ? r : 0)
    {   
    translate(v = [-hookWidth / 2+adj, 0-adj, 0+adj]) 
        cube(size = [hookWidth-2*adj, hookInternalDepth + hookLipThickness+2*adj, hookBottomThickness-2*adj]);
    }
}

module hookLip(flag) {
let (adj = flag ? r : 0)
    {
    translate(v = [-hookWidth / 2+adj, hookInternalDepth+adj, 0+adj]) 
        cube(size = [hookWidth-2*adj, hookLipThickness-2*adj, hookLipHeight + hookBottomThickness-2*adj]);
    }
}

module union1round() {
    if (enableMinkowski) {
        minkowski(convexity = 3) {
            union1(true);
            sphere(r, $fn = subDivMinkowski);
        }
    } else {
        union1();
    }
}

module union1(flag) {
    union() {
        if (showHookBack) hookBack(flag);
        if (showHookBase) hookBase(flag);
        if (showHookLip) hookLip(flag);
        roundHook(flag);
    }
}

module diff1() {
    if (cutSlots) {
        difference() {
            union1round();
            slotCutter(backWidth, backHeight, distanceBetweenSlots);
        }
    } else {
        union1round();
    }
}

diff1();

// Multiconnect Modules
module multiconnectBack(backWidth, backHeight, distanceBetweenSlots, flag) {
    let (
        slotCount = floor(backWidth / distanceBetweenSlots),
        backThickness = 6.5,
        adj = flag ? r : 0
    ) {
        translate(v = [0+(adj), -backThickness+adj, 0+(adj)]) 
            cube(size = [backWidth-2*adj, backThickness-2*adj, backHeight-2*adj]);
    }
}


module slotCutter(backWidth, backHeight, distanceBetweenSlots) {
    let (slotCount = floor(backWidth / distanceBetweenSlots)) {
        for (slotNum = [0 : 1 : slotCount - 1]) {
            translate(v = [
                distanceBetweenSlots / 2 + 
                (backWidth / distanceBetweenSlots - 2*slotCount) * distanceBetweenSlots / 2 + 
                slotNum * distanceBetweenSlots,
                -2.35 + slotDepthMicroadjustment,
                backHeight - 13
            ]) {
                slotTool(backHeight);
            }
        }
    }
}

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