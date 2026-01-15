include <BOSL2/std.scad>

Roll_Thickness = 6.5;
Thin_Metal_Thickness = 0.85;

/*[Standard Parameters]*/
//Profile
Select_Profile = "Standard"; //[Standard, Jr., Mini, Multipoint Beta, Custom]
Select_Part_Type = "Connector Round"; //[Connector Round, Connector Rail, Connector Double sided Round, Connector Double-Sided Rail, Connector Rail Delete Tool, Receiver Open-Ended, Receiver Passthrough, Backer Open-Ended, Backer Passthrough]
//Generate one of each part type of the selected profile
One_of_Each = false;
//Generate one of each part type of every profile, including custom
One_of_Everything = false;
//Generate one of each type of part
//Length of rail (in mm) (excluding rounded ends)
Length = 50; 
//Add dimples for position locking
Dimples = "Enabled";//[Enabled, Disabled]
//Change the scale (as a multiplier) of dimple size 
Dimple_Scale = 1; //[0.5: 0.25: 1.5]

/*[Rail Customization]*/
//Rounding of rail ends
Rounding = "Both Sides";//[None, One Side, Both Sides]

/*[Receiver Customization]*/
Receiver_Side_Wall_Thickness = 2.5;
Receiver_Back_Thickness = 2;
Receiver_Top_Wall_Thickness = 2.5;
OnRamps = "Enabled"; //[Enabled, Disabled]
OnRamp_Every_n_Holes = 2;
OnRamp_Start_Offset = 1;

/*[Backer Customization]*/
Width = 75; 

/*[AdvancedParameters]*/
//Distance (in mm) between each grid (25 for Multiboard)
Grid_Size = 25;

/*[Custom MC Builder]*/
//Radius of connector
Radius = 10; //.1
//Depth of inside capture
Depth1 = 1; //.1
//Lateral depth of angle dovetail
Depth2 = 2.5; //.1
//Depth of stem
Depth3 = 0.5; //.1
//Offset/Tolerance of receiver part
Offset = 0.15; //.01
//Radius (in mm) of dimple. Default for standard Multiconnect is 1mm radius (2mm diameter)
DimpleSize = 1; //.1


profileList = ["Standard", "Jr.", "Mini", "Multipoint Beta", "Custom"];

//unadjusted cordinates, dimple size, default offset
standardSpecs = [10, 1, 2.5, 0.5, 0.15, 1];
jrSpecs = [5, 0.6, 1.2, 0.4, 0.16, 0.8];
miniSpecs = [3.2, 1, 1.2, 0.4, 0.16, 0.8];
multipointBeta = [7.9, 0.4, 2.2, 0.4, 0.15, 0.8];


dimplesEnabled = true;
onRampEnabled = true;

backer_width = 20;
rolls_forward = false;
diff()
//backer plate

cuboid([backer_width,Roll_Thickness+3,Length+7.45], chamfer=0.5, anchor=BOT+BACK, except=BOT+BACK)
    fwd(Roll_Thickness/4) attach(BOT, BOT, inside=true, align=BACK, shiftout= 0.01)
        //slot
        cuboid([backer_width+.02,Roll_Thickness*.8, Length-Roll_Thickness/2])
            fwd(Roll_Thickness*.1)
            attach(TOP, RIGHT, inside=false, overlap= Roll_Thickness/2, spin=90)
                //roll retention
                cyl(d=Roll_Thickness, h=backer_width+.02, $fn=25);


//echo(str("Generating: ", Select_Part_Type));
back(2) up(Length/2)
rail(Length, profile[0], onRampEnabled = onRampEnabled, dimpleSize = profile[1], dimplesEnabled = dimplesEnabled, dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size)
    if(Rounding != "None")
        attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
            roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);


onRampEveryNHoles = OnRamp_Every_n_Holes * Grid_Size;
onRampOffset = OnRamp_Start_Offset * Grid_Size;

//if part is intended for a receiver, apply offset
isOffset = 
    Select_Part_Type == "Receiver Open-Ended" ? true : 
    Select_Part_Type == "Receiver Passthrough" ? true :
    Select_Part_Type == "Connector Rail Delete Tool" ? true :
    Select_Part_Type == "Backer Open-Ended" ? true :
    Select_Part_Type == "Backer Passthrough" ? true :
    false;

profile = 
    Select_Profile == "Standard" ? [dimensionsToCoords(standardSpecs[0], standardSpecs[1], standardSpecs[2], standardSpecs[3], isOffset ? standardSpecs[4] : 0), standardSpecs[5]] :
    Select_Profile == "Jr." ? [dimensionsToCoords(jrSpecs[0], jrSpecs[1], jrSpecs[2], jrSpecs[3], isOffset ? jrSpecs[4] : 0), jrSpecs[5]] :
    Select_Profile == "Mini" ? [dimensionsToCoords(miniSpecs[0], miniSpecs[1], miniSpecs[2], miniSpecs[3], isOffset ? miniSpecs[4] : 0), miniSpecs[5]] :
    Select_Profile == "Multipoint Beta" ? [dimensionsToCoords(multipointBeta[0], multipointBeta[1], multipointBeta[2], multipointBeta[3], isOffset ? multipointBeta[4] : 0), multipointBeta[5]] :
    Select_Profile == "Custom" ? [dimensionsToCoords(customSpecs[0], customSpecs[1], customSpecs[2], customSpecs[3], isOffset ? customSpecs[4] : 0), customSpecs[5]] :
    [];




module roundedEnd(profile, dimplesEnabled = true, dimpleSize = 1, dimpleScale = 1, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[maxX(profile)*2,maxY(profile),maxX(profile)]){
        //align to anchors
        down(maxX(profile)/2) back(maxY(profile)/2)
            top_half()
            rotate(a = [90,0,0]) 
                difference(){
                    //rail
                    rotate_extrude($fn=25) 
                        polygon(points = profile);
                    //dimples
                    if(dimplesEnabled == true) {
                        down(0.01) cylinder(h = dimpleSize*dimpleScale, r1 = dimpleSize*dimpleScale, r2 = 0, $fn = 25);
                    }                        
                }
        children();
    }
}

module rail(length, profile, dimplesEnabled = true, dimpleSize = 1, dimpleScale = 1, distanceBetweenDimples = 25, onRampEnabled = false, onRampDistanceBetween = 50, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[maxX(profile)*2,maxY(profile),length]){
        up(length/2) back(maxY(profile)/2) 
        difference(){
            //rail
            rotate(a = [180,0,0]) 
                linear_extrude(height = length) 
                    union(){
                        polygon(points = profile);
                            mirror([1,0,0])
                                polygon(points = profile);
                    }
            //dimples
            if(dimplesEnabled) 
                zcopies(n = ceil(length/distanceBetweenDimples)+1, spacing = distanceBetweenDimples, sp=[0,0,-length+length%distanceBetweenDimples]) 
                    back(0.01)cylinder(h = dimpleSize*dimpleScale, r1 = dimpleSize*dimpleScale, r2 = 0, $fn = 25, orient=FWD);
        }
        children();
    }
}

//calculate the max x and y points. Useful in calculating size of an object when the path are all positive variables originating from [0,0]
function maxX(path) = max([for (p = path) p[0]]);
function maxY(path) = max([for (p = path) p[1]]);

//this function takes the measurements of a multiconnect-style dovetail and converts them to profile coordinates. 
//When generating the male connector, set offsetMM to zero. Otherwise standard is 0.15 offset for delete tool
function dimensionsToCoords(radius, depth1, depth2, depth3, offsetMM) = [
    [0,0],
    [radius+offsetMM, 0],
    [radius+offsetMM,offsetMM == 0 ? depth1 : depth1+sin(45)*offsetMM*2],
    [radius-depth2+offsetMM, offsetMM == 0 ? depth2+depth1 : depth2+depth1+sin(45)*offsetMM*2],
    [radius-depth2+offsetMM, depth2+depth1+depth3+offsetMM],
    [0,depth2+depth1+depth3+offsetMM]
    ];
//
//END Multiconnect Modules and Functions
//