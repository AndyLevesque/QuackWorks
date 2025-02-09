include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/*Created by Hands on Katie and BlackjackDuck (Andy)
Credit to 
    Katie (and her community) at Hands on Katie on Youtube and Patreon
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for MulticonnMultiboard
    
Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
*/


/*[Standard Parameters]*/
//Profile
//Select_Profile = "Standard"; //[Standard, Jr., Mini, Multipoint Beta, Custom]
//Select_Part_Type = "Connector Round"; //[Connector Round, Connector Rail, Connector Double sided Round, Connector Double-Sided Rail, Connector Rail Delete Tool, Receiver Open-Ended, Receiver Passthrough, Backer Open-Ended, Backer Passthrough]
//Generate one of each type of part
//Length of rail (in mm) (excluding rounded ends)
//Length = 25; 
//Add dimples for position locking
Dimples = "Enabled";//[Enabled, Disabled]
//Change the scale (as a multiplier) of dimple size 
Dimple_Scale = 1; //[0.5: 0.25: 1.5]
/* [Hidden] */

///*[Rail Customization]*/
//Rounding of rail ends
Rounding = "Both Sides";//[None, One Side, Both Sides]

///*[Receiver Customization]*/
Receiver_Side_Wall_Thickness = 2.5;
Receiver_Back_Thickness = 2;
Receiver_Top_Wall_Thickness = 2.5;
OnRamps = "Enabled"; //[Enabled, Disabled]
OnRamp_Every_n_Holes = 2;
OnRamp_Start_Offset = 1;

///*[Backer Customization]*/
Width = 50; 

///*[AdvancedParameters]*/
//Distance (in mm) between each grid (25 for Multiboard)
Grid_Size = 25;

///*[Custom MC Builder]*/
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
//Radius (in mm) of dimple
DimpleSize = 1; //.1

//unadjusted cordinates, dimple size, default offset
customSpecs = [Radius, Depth1, Depth2, Depth3, Offset, DimpleSize];
standardSpecs = [10, 1, 2.5, 0.5, 0.15, 1];
jrSpecs = [5, 0.6, 1.2, 0.4, 0.16, 0.8];
miniSpecs = [3.2, 1, 1.2, 0.4, 0.16, 0.8];
multipointBeta = [7.9, 0.4, 2.2, 0.4, 0.15, 0.8];

debug = false; 

onRampEnabled = 
    OnRamps == "Enabled" ? true : 
    false; 

dimplesEnabled = 
Dimples == "Enabled" ? true : 
false;

onRampEveryNHoles = OnRamp_Every_n_Holes * Grid_Size;
onRampOffset = OnRamp_Start_Offset * Grid_Size;

/*[Customizations]*/
Hook_Depth = 25;
Center_Post_Thickness = 5;
Center_Post_Length = 20;
Base_Thickness = 5;
Groove_Depth = 10;
Individual_Post_Thickness = 4;
Number_of_Grooves = 6;
Groove_Width = 10;
Chamfer = 1;

debug_3d = false;
/*

START PARTS

*/
//3D Version

if(debug_3d)
test_shape();

module test_shape() {
    attachable(size=[Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Hook_Depth,Base_Thickness+Center_Post_Length]){
        down(Center_Post_Length/2)
        union()
        //base
        cuboid([Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Hook_Depth,Base_Thickness], chamfer=1, edges=[BOT,TOP]){
            //center post
            attach(TOP, BOT, overlap=Chamfer) cuboid([Center_Post_Thickness,Hook_Depth,Center_Post_Length+Chamfer])
                attach(TOP, FRONT) make_backer_openEnded(Length=max(Hook_Depth, Grid_Size), Width=25);
            attach(TOP, BOT, overlap=Chamfer) xflip_copy()
                xcopies(sp=[Center_Post_Thickness/2+Groove_Width+Individual_Post_Thickness/2,0,0], n = Number_of_Grooves/2, spacing = Groove_Width+Individual_Post_Thickness) 
                    //individual post
                    cuboid([Individual_Post_Thickness, Hook_Depth,Groove_Depth+Chamfer], chamfer=Chamfer, edges=[LEFT+FRONT, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK]);
        } 
        children();
    }
}

if(!debug_3d)
// 2D ATTEMPT
    union()
    rect([89,10], rounding=[0,0,5,5], $fn=15){
        //center post
            attach(TOP, BOT) rect([5,20]);
            //individual posts
            xflip_copy()attach(TOP, BOT)
                xcopies(sp=[14.5,0], n = 3, spacing = 14) 
                    //individual post
                    rect([4, 10], rounding=[1.5,1.5,0,0], $fn=15);
    }

//offset_sweep(object_profile, height=20); 
//!linear_extrude(height = 20) object_profile();

//bottom rail
module hook_profile() {
    linear_extrude(height = Hook_Depth)
    rect([Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Base_Thickness], rounding=[0,0,Base_Thickness,Base_Thickness], $fn=15){
    //center post
        attach(TOP, BOT) rect([Center_Post_Thickness,Center_Post_Length]);
        //individual posts
        xflip_copy()attach(TOP, BOT)
            xcopies(sp=[Center_Post_Thickness/2+Groove_Width+Individual_Post_Thickness/2,0], n = Number_of_Grooves/2, spacing = Groove_Width+Individual_Post_Thickness) 
                //individual post
                rect([Individual_Post_Thickness, Groove_Depth], rounding=[1.5,1.5,0,0], $fn=15);
    }
}
/*
union()
rect([Center_Post_Thickness + Groove_Width*Number_of_Grooves+Individual_Post_Thickness*Number_of_Grooves,Base_Thickness], rounding=[0,0,Base_Thickness,Base_Thickness], $fn=15){
    //center post
        attach(TOP, BOT) rect([Center_Post_Thickness,Center_Post_Length]);
        //individual posts
        xflip_copy()attach(TOP, BOT)
            xcopies(sp=[Center_Post_Thickness/2+Groove_Width+Individual_Post_Thickness/2,0], n = Number_of_Grooves/2, spacing = Groove_Width+Individual_Post_Thickness) 
                //individual post
                rect([Individual_Post_Thickness, Groove_Depth], rounding=[1.5,1.5,0,0], $fn=15);
    }
;
/*


BEGIN Multiconnect Modules and Functions


*/

module make_backer_openEnded(Width = 25, Length = 50, Select_Profile = "Standard", Dimples = "Enabled", OnRamps = "Enabled", anchor, spin, orient){
    attachable(anchor, spin, orient, size=[Width, 6, Length]){

    isOffset = true;

    profile = 
        Select_Profile == "Standard" ? [dimensionsToCoords(standardSpecs[0], standardSpecs[1], standardSpecs[2], standardSpecs[3], isOffset ? standardSpecs[4] : 0), standardSpecs[5]] :
        Select_Profile == "Jr." ? [dimensionsToCoords(jrSpecs[0], jrSpecs[1], jrSpecs[2], jrSpecs[3], isOffset ? jrSpecs[4] : 0), jrSpecs[5]] :
        Select_Profile == "Mini" ? [dimensionsToCoords(miniSpecs[0], miniSpecs[1], miniSpecs[2], miniSpecs[3], isOffset ? miniSpecs[4] : 0), miniSpecs[5]] :
        Select_Profile == "Multipoint Beta" ? [dimensionsToCoords(multipointBeta[0], multipointBeta[1], multipointBeta[2], multipointBeta[3], isOffset ? multipointBeta[4] : 0), multipointBeta[5]] :
        Select_Profile == "Custom" ? [dimensionsToCoords(customSpecs[0], customSpecs[1], customSpecs[2], customSpecs[3], isOffset ? customSpecs[4] : 0), customSpecs[5]] :
        [];

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
    children();
    }
}

module make_receiver_openEnded(Width = 25, Length = 50, Select_Profile = "Standard", Dimples = "Enabled", OnRamps = "Enabled", anchor, spin, orient){
    attachable(anchor, spin, orient, size=[Width, 6, Length]){

    isOffset = true;

    profile = 
        Select_Profile == "Standard" ? [dimensionsToCoords(standardSpecs[0], standardSpecs[1], standardSpecs[2], standardSpecs[3], isOffset ? standardSpecs[4] : 0), standardSpecs[5]] :
        Select_Profile == "Jr." ? [dimensionsToCoords(jrSpecs[0], jrSpecs[1], jrSpecs[2], jrSpecs[3], isOffset ? jrSpecs[4] : 0), jrSpecs[5]] :
        Select_Profile == "Mini" ? [dimensionsToCoords(miniSpecs[0], miniSpecs[1], miniSpecs[2], miniSpecs[3], isOffset ? miniSpecs[4] : 0), miniSpecs[5]] :
        Select_Profile == "Multipoint Beta" ? [dimensionsToCoords(multipointBeta[0], multipointBeta[1], multipointBeta[2], multipointBeta[3], isOffset ? multipointBeta[4] : 0), multipointBeta[5]] :
        Select_Profile == "Custom" ? [dimensionsToCoords(customSpecs[0], customSpecs[1], customSpecs[2], customSpecs[3], isOffset ? customSpecs[4] : 0), customSpecs[5]] :
        [];

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
    children();
    }
}

module make_receiver_passthru(Width = 25, Length = 50, Select_Profile = "Standard", Dimples = "Enabled", OnRamps = "Enabled", anchor, spin, orient){
    attachable(anchor, spin, orient, size=[Width, 6, Length]){

    isOffset = true;
    onRampEnabled = false;

    profile = 
        Select_Profile == "Standard" ? [dimensionsToCoords(standardSpecs[0], standardSpecs[1], standardSpecs[2], standardSpecs[3], isOffset ? standardSpecs[4] : 0), standardSpecs[5]] :
        Select_Profile == "Jr." ? [dimensionsToCoords(jrSpecs[0], jrSpecs[1], jrSpecs[2], jrSpecs[3], isOffset ? jrSpecs[4] : 0), jrSpecs[5]] :
        Select_Profile == "Mini" ? [dimensionsToCoords(miniSpecs[0], miniSpecs[1], miniSpecs[2], miniSpecs[3], isOffset ? miniSpecs[4] : 0), miniSpecs[5]] :
        Select_Profile == "Multipoint Beta" ? [dimensionsToCoords(multipointBeta[0], multipointBeta[1], multipointBeta[2], multipointBeta[3], isOffset ? multipointBeta[4] : 0), multipointBeta[5]] :
        Select_Profile == "Custom" ? [dimensionsToCoords(customSpecs[0], customSpecs[1], customSpecs[2], customSpecs[3], isOffset ? customSpecs[4] : 0), customSpecs[5]] :
        [];

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
    children();
    }
}

module GeneratePart(Width, Length, Select_Profile, Select_Part_Type, Dimples, OnRamps){

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
