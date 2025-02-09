/*
Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial - Sharable with Attribution

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

/* [Hidden] */
debug = false; 

//
//BEGIN Start Stand-alone part generator
//

profileList = ["Standard", "Jr.", "Mini", "Multipoint Beta", "Custom"];
partList = ["Connector Round", "Connector Double sided Round", "Connector Rail",  "Connector Double-Sided Rail", "Connector Rail Delete Tool", "Receiver Open-Ended", "Receiver Passthrough"]; //removed backers due to performance issues , "Backer Open-Ended", "Backer Passthrough"


if(One_of_Everything){
    for(n = [0 : 1 : len(profileList)-1]){
        for(i = [0 : 1 : len(partList)-1]){
            echo(str("Generating Profile: ", profileList[n], "; Part: ", partList[i]));
            fwd((n)*25) 
            left(partList[i] == "Backer Open-Ended" ? Width*2+(i+1)*27 : (i+1)*27) 
                GeneratePart(profileList[n], partList[i], Dimples, OnRamps);
        }
    }
}
else if(One_of_Each){
    for(i = [0 : 1 : len(partList)-1])
        left(
            partList[i] == "Backer Open-Ended" ? Width/2+(i+1)*27 :
            partList[i] == "Backer Passthrough" ? Width+27+(i+1)*27 :
            (i+1)*27
        ) 

        GeneratePart(Select_Profile, partList[i], Dimples, OnRamps);
}
else GeneratePart(Select_Profile, Select_Part_Type, Dimples, OnRamps);

//
//END Stand-alone part generator
//

//
//BEGIN Multiconnect Modules and Functions
//
module GeneratePart(Width, Length, Select_Profile, Select_Part_Type, Dimples, OnRamps){
    

    //unadjusted cordinates, dimple size, default offset
    customSpecs = [Radius, Depth1, Depth2, Depth3, Offset, DimpleSize];
    standardSpecs = [10, 1, 2.5, 0.5, 0.15, 1];
    jrSpecs = [5, 0.6, 1.2, 0.4, 0.16, 0.8];
    miniSpecs = [3.2, 1, 1.2, 0.4, 0.16, 0.8];
    multipointBeta = [7.9, 0.4, 2.2, 0.4, 0.15, 0.8];


    dimplesEnabled = 
    Dimples == "Enabled" ? true : 
    false;

    onRampEnabled = 
        OnRamps == "Enabled" ? true : 
        false; 

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
    
    if(Select_Part_Type == "Connector Round"){
        //echo(str("Generating: ", Select_Part_Type));
        rail(0,profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size, spin=[90,0,0], anchor=FRONT)
            attach([TOP, BOT], BOT, overlap=0.01)
                roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);       
    }
    else if(Select_Part_Type == "Connector Rail"){
        //echo(str("Generating: ", Select_Part_Type));
        rail(Length, profile[0], onRampEnabled = onRampEnabled, dimpleSize = profile[1], dimplesEnabled = dimplesEnabled, dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size)
            if(Rounding != "None")
                attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                    roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
    }
    else if(Select_Part_Type == "Connector Double sided Round"){
        //echo(str("Generating: ", Select_Part_Type));
        rail(0,profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size, spin=[90,0,0], anchor=FRONT)
                        attach([TOP, BOT], BOT, overlap=0.01)
                            roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale)
                            attach(FRONT, FRONT, overlap=0.01)
                                roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
    }
    else if(Select_Part_Type == "Connector Double-Sided Rail"){
        rail(Length,profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size, spin=180){
            if(Rounding != "None")
                attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                    roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
                attach(FRONT, FRONT, overlap=0.01)
                    rail(Length,profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size)
                    if(Rounding != "None")
                        attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                            roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
                }
    }
    else if(Select_Part_Type == "Receiver Open-Ended"){
        diff(){
            cuboid([maxX(profile[0])*2+Receiver_Side_Wall_Thickness*2, maxY(profile[0])+Receiver_Back_Thickness, Length])
                attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=maxX(profile[0])+Receiver_Top_Wall_Thickness) 
                    rail(Length+0.04, profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size){
                        if(Rounding != "None"){
                            attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                                roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
                        }
                        //onramp
                        if(onRampEnabled==true) attach(BACK, TOP, inside=true, align=TOP, shiftout=0.02, inset=-maxX(profile[0])+onRampEveryNHoles+onRampOffset) ycopies(n = Length/onRampEveryNHoles+1, spacing = -onRampEveryNHoles, sp=[0,0,0]) cylinder(h = maxY(profile[0])+0.04, r1 = maxX(profile[0])+1.5, r2 = maxX(profile[0]));
                    }
            }
    }
    else if(Select_Part_Type == "Backer Open-Ended"){
        diff(){
            cuboid([Width, maxY(profile[0])+Receiver_Back_Thickness, Length])
                    attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=maxX(profile[0])+Receiver_Top_Wall_Thickness) 
                    xcopies(n=floor(Width/Grid_Size), spacing = Grid_Size) 
                        rail(Length+0.04, profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size){
                            if(Rounding != "None"){
                                attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                                    roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
                            }
                            //onramp
                            if(onRampEnabled==true) attach(BACK, TOP, inside=true, align=TOP, shiftout=0.02, inset=-maxX(profile[0])+onRampEveryNHoles+onRampOffset) ycopies(n = Length/onRampEveryNHoles+1, spacing = -onRampEveryNHoles, sp=[0,0,0]) cylinder(h = maxY(profile[0])+0.04, r1 = maxX(profile[0])+1.5, r2 = maxX(profile[0]));
                    }
            }
    }
    else if(Select_Part_Type == "Backer Passthrough"){
        diff(){
            cuboid([Width, maxY(profile[0])+Receiver_Back_Thickness, Length])
                attach(BACK, FRONT, inside=true, shiftout=0.01) 
                xcopies(n=floor(Width/Grid_Size), spacing = Grid_Size) 
                rail(Length+0.04, profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size){
                    if(Rounding != "None")
                        attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                            roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
                //onramp
                if(onRampEnabled==true) attach(BACK, TOP, inside=true, align=TOP, shiftout=0.02, inset=-maxX(profile[0])+onRampOffset) ycopies(n = Length/onRampEveryNHoles+1, spacing = -onRampEveryNHoles, sp=[0,0,0]) cylinder(h = maxY(profile[0])+0.04, r1 = maxX(profile[0])+1.5, r2 = maxX(profile[0]));

                }
            }
    }
    else if(Select_Part_Type == "Receiver Passthrough"){
        diff(){
            cuboid([maxX(profile[0])*2+Receiver_Side_Wall_Thickness*2, maxY(profile[0])+Receiver_Back_Thickness, Length])
                attach(BACK, FRONT, inside=true, shiftout=0.01) rail(Length+0.04, profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size){
                    if(Rounding != "None")
                        attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                            roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
                //onramp
                if(onRampEnabled==true) attach(BACK, TOP, inside=true, align=TOP, shiftout=0.02, inset=-maxX(profile[0])+onRampOffset) ycopies(n = Length/onRampEveryNHoles+1, spacing = -onRampEveryNHoles, sp=[0,0,0]) cylinder(h = maxY(profile[0])+0.04, r1 = maxX(profile[0])+1.5, r2 = maxX(profile[0]));

                }
            }
    }
    else if(Select_Part_Type == "Connector Rail Delete Tool"){
        //echo(str("Generating: ", Select_Part_Type));
        rail(Length, profile[0], onRampEnabled = onRampEnabled, dimpleSize = profile[1], dimplesEnabled = dimplesEnabled, dimpleScale = Dimple_Scale, distanceBetweenDimples = Grid_Size){
            if(Rounding != "None")
                attach(Rounding ==  "Both Sides" ? [TOP, BOT] : TOP, BOT, overlap=0.01)
                    roundedEnd(profile[0], dimplesEnabled = dimplesEnabled, dimpleSize = profile[1], dimpleScale = Dimple_Scale);
            if(onRampEnabled==true) attach(BACK, TOP, inside=true, align=TOP, shiftout=0.02, inset=-maxX(profile[0])+onRampOffset) ycopies(n = Length/onRampEveryNHoles+1, spacing = -onRampEveryNHoles, sp=[0,0,0]) cylinder(h = maxY(profile[0])+0.04, r1 = maxX(profile[0])+1.5, r2 = maxX(profile[0]));
        }
    }
}

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
