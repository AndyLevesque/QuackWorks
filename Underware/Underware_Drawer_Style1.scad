include <BOSL2/std.scad>
include <BOSL2/walls.scad>
/*Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution for all parts except the snaps, which fall under the Keep Making license at multiboard.io/license
*/

/*[Standard Parameters]*/
//Depth of drawer (in units).
shelfDepthUnits = 7;
//Width of drawer (in units) (slide mount to slide mount). The inside space of the drawer is 29mm less than this value.
Drawer_Width_in_Units = 5;
//internal height of drawer (in mm)
shelfHeight = 20;//5

/*[Drawer Bottom]*/
bottomType = "Hex"; //["Hex","Solid"]
//Center-to-center spacing of hex cells in the honeycomb
hexSpacing = 8; //[1:0.5:20]
//Thickness of hexagonal bracing. Must be less than hexSpacing.
hexStrut = 1.5; //[0.5:0.25:5]

/*[Drawer Front]*/
drawerFrontType = "Detached Dovetail";// [Attached, Detached Dovetail]
drawerPullType = "Upper Notch";// [Upper Notch, Hardware, None]

//Diameter of the drawer pull screw hole
drawerPullHardwareDiameter = 4;
//Drawer pull one screw or two? 
drawerPullHardwareMounting = "Dual";//[Single, Dual]
//If Multiple hardware mounting points, distance FROM CENTER of each
drawerPullHardwareHoleSeparation = 40;
//Difference (in mm) the shelf front dovetail is to the hole
dovetailTolerance = 0.3;
//Additional total width of the drawer front (0 matches the shelf width plus walls; 25 covers most of the drawer slide)
drawerFrontExtraWidth = 24;

/*[Strength Parameters]*/
//thickness (in mm) of the shelf floor
baseThickness = 1.5; //[0.5:0.25:7.5]
//wallThickness - need to figure out how to handle differing wall thicknesses without throwing off 25mm mounting increments
wallThickness = 1.5; 

/*[Export Selection]*/
ExportDrawer = true;
ExportSlides = true;
ExportSlideTabs = true; 
ExportDrawerFront = true; 
ExportStopSnaps = true; 

/*[Hidden]*/
//Lateral protrusion of the slide mechanism. MODIFYING WILL CAUSE THE DRAWERS TO NOT LINE UP. 
slideDepth = 7.5;
//additional space on the drawer slides for sliding room
slideSlop = 1;
unitsInMM = 25;
depthInMM = shelfDepthUnits*unitsInMM;
widthInMM = (Drawer_Width_in_Units-1)*unitsInMM;

shelfWidthUnits = Drawer_Width_in_Units - 1; //add 1 unit to account for the slides

//Drawer Dovetail Mounting
//The small measurement (in mm) For the slot to slide in the drawer of the drawer
drawerMountConeMin = 4.2;
//The small measurement (in mm) For the dovetail to slide in the drawer of the drawer
drawerMountConeMax = 8.2;
//Depth/distance (in mm) from the small part of the cone to the large part of the cone
drawerMountConeDepth = 3.6; 
//Total depth/distance of the dovetail
drawerMountInset = 3.6;


/*[Slot Customization]*/
//number of slots between multiconnect mounts
slotSpacing = 2;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
dimplesEnabled = true;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back
slotTolerance = 1.00; //[1:0.005:1.075]
//Move the slot in (positive) or out (negative) - Disabled at the moment
//slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
//frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
onRampEveryNSlots = 2;
//move the start of the series of on-ramps n number of slots down
onRampOffsetNSlots = 1;
//move the start of the slots (in mm) up (positive) or down (negative)
slotVerticalOffset = 0;


/*[Debug]*/
//If the front is detached, show the fit. Do not print in this orientation. 
drawerDovetailTest = false;
slideFitTest = false; 

/*[Hidden]*/
drawerDimpleRadius = 1;
drawerDimpleHeight = 7.5;
drawerDimpleInset = 5; 
drawerDimpleSlideToDrawerRatio = 1.25;
//Distance (in mm) the top of the drawer will have to the multiboard it is mounted to (not including slop)
drawerPlateClearance = 2; //[0:.5:6.5]
//size (in mm) the slide lock (which prevents the multiconnect from sliding off) is thinner than the slot 
slideLockTolerance = 0.15;

//slot settings hidden
//Slot type. Backer is for vertical mounting. Passthru for horizontal mounting.
slotType = "Backer"; //[Backer, Passthru]
//ADVANCED: Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;

///*[Passthru-Style Slot Customization]*/
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
dimpleOffset = 0;

//drawer
if(ExportDrawer) diff("remove"){
    up(baseThickness) rect_tube(size=[shelfWidthUnits*25-slideSlop,shelfDepthUnits*25], wall=wallThickness, h=shelfHeight, anchor=BOT){
        //slide sides
        tag("keep") down(6.5-drawerPlateClearance) attach([LEFT, RIGHT], BOT, align=TOP) 
                tag("") prismoid(size1=[shelfDepthUnits*25,slideDepth*2+0.25], size2=[shelfDepthUnits*25,0], h=slideDepth+0.25){
                    //drawer dimple
                    attach(FRONT, CENTER+FRONT, align=[LEFT, RIGHT], inset=drawerDimpleInset, shiftout = -drawerDimpleRadius) 
                        force_tag("remove") 
                            cyl(h= 10.9, r = drawerDimpleRadius*drawerDimpleSlideToDrawerRatio, $fn=30);
                }
        //drawer bottom
        if (bottomType == "Solid") tag("keep")attach(BOT, TOP) cuboid([shelfWidthUnits*25-slideSlop,shelfDepthUnits*25,baseThickness]);
        if (bottomType == "Hex") tag("keep") attach(BOT, TOP) 
            hex_panel([shelfWidthUnits*25-slideSlop,shelfDepthUnits*25,baseThickness], strut=hexStrut < hexSpacing ? hexStrut : hexSpacing - 0.25, spacing = hexSpacing, frame = wallThickness+2);
        //upper notch drawer pull
        if (drawerPullType == "Upper Notch") tag("remove") attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP) 
            cuboid([widthInMM/3,wallThickness+1, 10], rounding=3, edges = [BOTTOM+LEFT, BOTTOM+RIGHT]);
        //drawer pull hardware
        if(drawerPullType == "Hardware") tag("remove") attach(FRONT, BOT, inside=true, shiftout=0.01) 
            xcopies(n=drawerPullHardwareMounting=="Single" ? 1 : 2, spacing = drawerPullHardwareHoleSeparation)cyl(r=drawerPullHardwareDiameter/2, h = wallThickness+1, $fn=25);
        //Detached Dovetail Front
        if (drawerFrontType == "Detached Dovetail"){
            //front removal tool
            up(3) attach(FRONT, FRONT, inside = true, shiftout=0.01) 
                tag("remove")cuboid([widthInMM-wallThickness*2-(drawerMountConeMax+3)*2-slideSlop, wallThickness+1,shelfHeight+1]);
            //dovetail slots
            attach(FRONT, FRONT, align=[LEFT, RIGHT], inside=true, inset=wallThickness)
                //mounting block
                tag("")cuboid([drawerMountConeMax+3,drawerMountInset+2,shelfHeight]) 
                //dovetail cone
                    attach(FRONT, BOT, inside=true, shiftout=drawerMountConeDepth-drawerMountInset) prismoid(size1=[drawerMountConeMin, shelfHeight+0.01], size2=[drawerMountConeMax, shelfHeight+0.01], h=drawerMountConeDepth)
                    attach(BOT, FRONT, shiftout=-0.01) cuboid([drawerMountConeMin, drawerMountInset+drawerMountConeDepth+0.01, shelfHeight+0.01]);   
        }           
    }
}

//drawer front
if(drawerFrontType == "Detached Dovetail" && ExportDrawerFront){
    diff("remove"){
        fwd(drawerDovetailTest ? depthInMM/2+wallThickness/2 : depthInMM/2+wallThickness/2+shelfHeight/2) 
        left(0) //front face placement for export
        //drawer front wall
        up(drawerDovetailTest ? 0 :  wallThickness/2)
            cuboid([widthInMM+drawerFrontExtraWidth, wallThickness, shelfHeight+baseThickness], anchor=BOT, spin=[drawerDovetailTest ? 0 : 90,0,0]){
        //dovetails
        up(baseThickness/2)attach(BACK, BOT, align=[LEFT, RIGHT], inset=(drawerMountConeMax+3)/2+wallThickness-drawerMountConeMin/2+drawerFrontExtraWidth/2+slideSlop/2+dovetailTolerance/2) 
            prismoid(size1=[drawerMountConeMin-dovetailTolerance, shelfHeight], size2=[drawerMountConeMax-dovetailTolerance, shelfHeight], h=drawerMountConeDepth-dovetailTolerance/2);
        //drawer pull cutout
        if(drawerPullType == "Upper Notch") tag("remove") attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP) 
                cuboid([widthInMM/3,wallThickness+1, 10], rounding=3, edges = [BOTTOM+LEFT, BOTTOM+RIGHT]);
        //drawer pull hardware
        if(drawerPullType == "Hardware") tag("remove") attach(FRONT, BOT, inside=true, shiftout=0.01) 
                    xcopies(n=drawerPullHardwareMounting=="Single" ? 1 : 2, spacing = drawerPullHardwareHoleSeparation)cyl(r=drawerPullHardwareDiameter/2, h = wallThickness+1, $fn=25);
        }
    }
}

//slides
if(ExportSlides)
diff(){
    up(slideFitTest ? shelfHeight+baseThickness-6.5/2-drawerPlateClearance-slideDepth*2+0.5 : 0)
    xcopies(n = 2, spacing = slideFitTest ? widthInMM+ 25 + slideSlop*2 : widthInMM+slideDepth*2+30)
    cuboid(size = [25,depthInMM,slideDepth*2], anchor=BOT){
        //slide slots
        attach([LEFT, RIGHT], BOT, align=TOP, inside=true, shiftout=0.01) 
            tag("remove") 
                diff("slideDimple")
                prismoid(size1=[shelfDepthUnits*25,slideDepth*2+0.25], size2=[shelfDepthUnits*25+1,0], h=slideDepth+0.25){
                    attach(FRONT, CENTER+FRONT, align=[LEFT, RIGHT], inset=drawerDimpleInset, shiftout = -drawerDimpleRadius+.5) 
                        tag("slideDimple") cyl(h= drawerDimpleHeight-1, r = drawerDimpleRadius, $fn=30);
}
        //bottom cutout
        attach(BOT, BOT, inside=true, shiftout=0.01) 
            tag("remove") prismoid(size1=[slideDepth*2, shelfDepthUnits*25], size2=[0,shelfDepthUnits*25+1], h=slideDepth);
        //distributed multiconnect slots
        //ycopies(n=ceil(depthInMM/(slotSpacing*unitsInMM)), spacing = slotSpacing*unitsInMM, sp=[0,25,0]) attach(TOP, BACK, align=FRONT) multiconnectBacker(height = 25, width = 25, slotType = slotType, scale = slotTolerance, onRampEnabled = false, slotDimple = !slotQuickRelease, dimpleScale = dimpleScale, anchor=BOTTOM+BACK, slotOrientation=slotOrientation, spin=[0,180,0]);
        //long multiconnect slot
        attach(TOP, BACK) 
            multiconnectBacker(height = depthInMM, width = 25, slotType = slotType, slotTolerance = slotTolerance, onRampEnabled = true, onRampEveryNSlots = slotSpacing,slotDimple = dimplesEnabled, dimpleScale = dimpleScale, dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, anchor=BOTTOM+BACK, slotOrientation=slotOrientation, spin=[0,180,0])
        //slide lock slot
        tag("remove")attach(FRONT, BOT, align=TOP, inset = 19, shiftout=-5.99) cuboid([26, 2, 6]);
    }
}

//slide lock tools
if(ExportSlideTabs)
xcopies(n = 2, spacing = widthInMM+slideDepth*2+30) fwd(depthInMM/2-12.5) cuboid([6 , 25,  2-slideLockTolerance], anchor=BOT);

//drawer stop snaps
if(ExportStopSnaps)
ycopies(n = 2, spacing= 25) move([widthInMM/2+50,-depthInMM/2+50,0]) snapConnectBacker(offset=1, anchor=BOT)
    attach(TOP, BOT, align=FRONT, shiftout=-0.1) cuboid([6, 4, 4+drawerPlateClearance], chamfer=0.5, edges=TOP);



/*
BEGIN MODULES
*/

//BEGIN MODULES
module multiconnectBacker(width, height, slotType = "Backer", distanceBetweenSlots = 25, onRampEnabled = true, onRampEveryNSlots = 1, onRampOffsetNSlots = 0, slotTolerance = 1, slotVerticalOffset = 0, backerThickness = 6.5, slotOrientation = "Vertical", slotDimple = true, dimpleScale = 1, dimpleEveryNSlots = 1, dimpleOffset = 0, dimpleCount = 999, centerMulticonnect=centerMulticonnect, onRampPassthruEnabled = onRampPassthruEnabled, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[width, backerThickness, height]*slotTolerance){ 
    //Backer type
    if (slotType == "Backer"){
        width = width < 25 ? 25 : width; //if width is less than 25, force 25 to ensure at least 1 slot
        diff("slot"){
        cuboid([width, backerThickness, height]);
            xcopies(n = floor(width/distanceBetweenSlots), spacing = distanceBetweenSlots)
                tag("slot") 
                    down((13-10.15-slotVerticalOffset)*slotTolerance) attach(TOP, TOP, inside=true, align=FRONT, shiftout=0.01) 
                        scale(slotTolerance) 
                            multiconnectRoundedEnd(slotDimple = slotDimple, dimpleScale = dimpleScale, anchor=BOT+BACK)
                                up(0.1) attach(BOT, TOP, overlap=0.01) 
                                    multiconnectSlot(length = height, slotType = slotType, slotDimple = dimplesEnabled, distanceBetweenSlots = distanceBetweenSlots, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, anchor=FRONT, dimpleScale = dimpleScale, dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, dimpleCount=dimpleCount);
        }
    }
    //Passthru type
    else {
        diff("slot"){
                cuboid([width, backerThickness, height]){
                if (slotOrientation == "Vertical") {
                    xcopies(n = floor(width/distanceBetweenSlots), spacing = distanceBetweenSlots)
                        tag("slot") 
                            attach(TOP, TOP, inside=true, align=FRONT, shiftout = 0.01) multiconnectSlot(length = height, slotType = slotType, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, slotDimple = dimplesEnabled,  dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, onRampPassthruEnabled = onRampPassthruEnabled, anchor=FRONT);
                }
                else { 
                    zcopies(n = floor(height/distanceBetweenSlots), spacing = distanceBetweenSlots)
                    tag("slot") 
                        attach(LEFT, TOP, inside=true, align=FRONT, shiftout = 0.01) back(10.15)
                            multiconnectSlot(length = width+1, slotType = slotType, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, slotDimple = dimplesEnabled, dimpleEveryNSlots = dimpleEveryNSlots, dimpleOffset = dimpleOffset, onRampPassthruEnabled = onRampPassthruEnabled, anchor=FRONT, spin=90);
                }
                }
            }
    }
        children();
    }

    //round top
    module multiconnectRoundedEnd(slotDimple = true, dimpleScale = 1, anchor=CENTER, spin=0, orient=UP){
        attachable(anchor, spin, orient, size=[10.15*2,4.15,10.15]){
            down(10.15/2)
            //top_half() 
            diff("slotDimple"){
                multiconnectRounded()
                if(slotDimple) tag("slotDimple")attach(BACK, BOT, inside=true, shiftout=0.01) cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);
            }
            children();
        }
        module multiconnectRounded(anchor=CENTER, spin=0, orient=UP){
            attachable(anchor, spin, orient, size=[10.15*2,4.15,20.3]){
                down(0) back(4.15/2)
                    top_half()
                        rotate(a = [90,0,0,]) 
                            rotate_extrude($fn=50) 
                                polygon(points = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,4.15],[0,4.15]]);
                children();
            }
        }//End multiconnectRounded
    }

    module multiconnectSlot(length, slotType = "Backer", distanceBetweenSlots = 25, onRampEnabled = true, onRampEveryNSlots = 1, onRampOffsetNSlots = 0, slotDimple = true, dimpleScale = 1, dimpleEveryNSlots = 1, dimpleOffset = 0, dimpleCount = 999, onRampPassthruEnabled = false, anchor=CENTER, spin=0, orient=UP){
        attachable(anchor, spin, orient, size=[10.15*2,4.15,length]){
            diff("slotDimple"){
                multiconnectLinear(length = length, slotType = slotType, distanceBetweenSlots = distanceBetweenSlots, onRampEnabled = onRampEnabled, onRampEveryNSlots = onRampEveryNSlots, onRampOffsetNSlots = onRampOffsetNSlots, onRampPassthruEnabled = onRampPassthruEnabled);
                if(slotDimple && dimpleEveryNSlots != 0 && slotType == "Backer") {
                    //calculate the dimples. Dimplecount can override if less than calculated slots
                    echo("Dimples for Backer");
                    tag("slotDimple") attach(BACK, BOT, align=TOP, inside=true, shiftout=0.01) back(1.5*dimpleScale) 
                            cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);
                    zcopies(n = min(length/distanceBetweenSlots/dimpleEveryNSlots+1, dimpleCount), spacing = -distanceBetweenSlots*dimpleEveryNSlots, sp=[0,0,dimpleOffset*distanceBetweenSlots]) 
                        tag("slotDimple") attach(BACK, BOT, align=TOP, inside=true, shiftout=0.01) back(1.5*dimpleScale) 
                            cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);
                }
                if(slotDimple && dimpleEveryNSlots != 0 && slotType == "Passthru"){ //passthru
                    //calculate the dimples. Dimplecount can override if less than calculated slots
                    echo("Dimples for Passthru");
                    zcopies(n = min(length/distanceBetweenSlots/dimpleEveryNSlots+2, dimpleCount), spacing = -distanceBetweenSlots*dimpleEveryNSlots, sp=[0,0,centerMulticonnect ? -length/2+25*3/2-12.5+25+dimpleOffset*distanceBetweenSlots: -length/2+25*3/2+25+dimpleOffset*distanceBetweenSlots]) 
                        tag("slotDimple") attach(BACK, BOT, align=TOP, inside=true, shiftout=0.01) back(1.5*dimpleScale) 
                            cylinder(h = 1.5*dimpleScale, r1 = 1.5*dimpleScale, r2 = 0, $fn = 50);

                }
            
            }
            children();
        }
        //long slot
        module multiconnectLinear(length, slotType = "Backer", distanceBetweenSlots = 25, onRampEnabled = true, onRampEveryNSlots = 1, onRampOffsetNSlots = 0, onRampPassthruEnabled = false, anchor=CENTER, spin=0, orient=UP){
            attachable(anchor, spin, orient, size=[10.15*2,4.15,length]){
                up(length/2) back(4.15/2) 
                intersection() {
                    union(){
                        rotate(a = [180,0,0]) 
                            linear_extrude(height = length) 
                                union(){
                                    polygon(points = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,4.15],[0,4.15]]);
                                        mirror([1,0,0])
                                            polygon(points = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,4.15],[0,4.15]]);
                                }
                        //onramp
                        if(onRampEnabled && onRampEveryNSlots != 0 && slotType == "Backer") {
                                zcopies(spacing=-distanceBetweenSlots*onRampEveryNSlots, n=length/distanceBetweenSlots/onRampEveryNSlots+1, sp=[0,0,-distanceBetweenSlots-onRampOffsetNSlots*distanceBetweenSlots]) 
                                    fwd(4.15/2) color("orange") 
                                        cyl(h = 4.15, r1 = 12, r2 = 10.15, spin=([90,0,180]));
                        } 
                        if(onRampPassthruEnabled && onRampEveryNSlots != 0 && slotType == "Passthru"){
                                zcopies(spacing=-distanceBetweenSlots*onRampEveryNSlots, n=length/distanceBetweenSlots+2, sp=[0,0,centerMulticonnect ? -length/2+25*3/2-12.5+25: -length/2+25*3/2+25]) 
                                    fwd(4.15/2) color("orange") 
                                        cyl(h = 4.15, r1 = 12, r2 = 10.15, spin=([90,0,180]));
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

module snapConnectBacker(offset = 0, holdingTolerance=1, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[11.4465*2, 11.4465*2, 6.2+offset]){ 
    //bumpout profile
    bumpout = turtle([
        "ymove", -2.237,
        "turn", 40,
        "move", 0.557,
        "arcleft", 0.5, 50,
        "ymove", 0.252
        ]   );

    down(6.2/2+offset/2)
    union(){
    diff("remove")
        //base
            oct_prism(h = 4.23, r = 11.4465, anchor=BOT) {
                //first bevel
                attach(TOP, BOT, shiftout=-0.01) oct_prism(h = 1.97, r1 = 11.4465, r2 = 12.5125, $fn =8, anchor=BOT)
                    //top - used as offset. Independen snap height is 2.2
                    attach(TOP, BOT, shiftout=-0.01) oct_prism(h = offset, r = 12.9885, anchor=BOTTOM);
                        //top bevel - not used when applied as backer
                        //position(TOP) oct_prism(h = 0.4, r1 = 12.9985, r2 = 12.555, anchor=BOTTOM);
            
            //end base
            //bumpouts
            attach([RIGHT, LEFT, FWD, BACK],LEFT, shiftout=-0.01)  color("green") down(0.87) fwd(1)scale([1,1,holdingTolerance])offset_sweep(path = bumpout, height=3, spin=[0,270,0]);
            //delete tools
            //Bottom and side cutout - 2 cubes that form an L (cut from bottom and from outside) and then rotated around the side
            tag("remove") 
                 align(BOTTOM, [RIGHT, BACK, LEFT, FWD], inside=true, shiftout=0.01, inset = 1.6) 
                    color("lightblue") cuboid([0.8,7.161,3.4], spin=90*$idx)
                        align(RIGHT, [TOP]) cuboid([0.8,7.161,1], anchor=BACK);
            }
    }
    children();
    }

    //octo_prism - module that creates an oct_prism with anchors positioned on the faces instead of the edges (as per cyl default for 8 sides)
    module oct_prism(h, r=0, r1=0, r2=0, anchor=CENTER, spin=0, orient=UP) {
        attachable(anchor, spin, orient, size=[max(r*2, r1*2, r2*2), max(r*2, r1*2, r2*2), h]){ 
            down(h/2)
            if (r != 0) {
                // If r is provided, create a regular octagonal prism with radius r
                rotate (22.5) cylinder(h=h, r1=r, r2=r, $fn=8) rotate (-22.5);
            } else if (r1 != 0 && r2 != 0) {
                // If r1 and r2 are provided, create an octagonal prism with different top and bottom radii
                rotate (22.5) cylinder(h=h, r1=r1, r2=r2, $fn=8) rotate (-22.5);
            } else {
                echo("Error: You must provide either r or both r1 and r2.");
            }  
            children(); 
        }
    }
    
}

//take a total length and divisible by and calculate the remainder
//For example, if the total length is 81 and units are 25 each, then the excess is 5
function excess(total, divisibleBy) = round(total - floor(total/divisibleBy)*divisibleBy);