/*Created by Hands on Katie and BlackjackDuck (Andy)

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @dmgerman on MakerWorld and @David D on Printables for the bolt thread specs
    Jonathan at Keep Making for Multiboard
    @Lyric on Printables for the flush connector idea
    SnazzyGreenWarrior for split printing logic

    
Change Log:
- 2024-12-06 
    - Initial release
- 2025-01-27
    - Split snap connectors

All parts except for Snap Connector are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Snap Connector adopts the Multiboard.io license at multiboard.io/license
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Choose Part]*/
//How do you intend to mount the channels to a surface such as Honeycomb Storage Wall or Multiboard? See options at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/
Show_Part = "Snap Connector"; // [Snap Connector, Bolts]

/*[Options: Thread Snap Connector ]*/
//Height (in mm) the snap connector rests above the board. 3mm is standard. 0mm results in a flush fit. 
Snap_Connector_Height = 3;
//Scale of the Snap Connector holding 'bumpouts'. 1 is standard. 0.5 is half size. 1.5 is 50% larger. Large = stronger hold. 
Snap_Holding_Tolerance = 1; //[0.5:0.05:2.0]
//Length of the treaded portion of the snap connector. 3.6mm is standard.
Snap_Thread_Height = 3.6;
//Configure the snap to be split-printed for stronger holding.
Split_Printing = true;


/*[Options: Bolts]*/
//Length of the threaded portion of small screw. MB is 6mm thick and the recessed hole in base channels is 1mm deep.
Thread_Length_Sm = 6.5;

Bolt_Selection = "Small MB T Screw"; // [All, Small MB Screw, Small MB Screw split, Small MB T Screw, Small MB T Screw tool]


/*[Advanced Options]*/
//Color of part (color names found at https://en.wikipedia.org/wiki/Web_colors)
Global_Color = "SlateBlue";
//Octogon Scaling - Decrease if the octogon is too large for the snap connector. Increase if the octogon is too small.
Oct_Scaling = 1; //[0.8:0.01:1.2]

/*[Hidden]*/
///*[Small Screw Profile]*/
//Distance (in mm) between threads
Pitch_Sm = 3;
//Diameter (in mm) at the outer threads
Outer_Diameter_Sm = 6.747;
//Angle of the one side of the thread
Flank_Angle_Sm = 60;
//Depth (in mm) of the thread
Thread_Depth_Sm = 0.5;
//Diameter of the hole down the middle of the screw (for strength)
Inner_Hole_Diameter_Sm = 3.3;

///*[Large Screw Profile]*/
//Distance (in mm) between threads
Pitch_Lg = 2.5;
//Diameter (in mm) at the outer threads
Outer_Diameter_Lg = 22.245;
//Angle of the one side of the thread
Flank_Angle_Lg = 45;  
//Depth (in mm) of the thread
Thread_Depth_Lg = 0.75;
//Diameter of the hole down the middle of the bolt
Inner_Hole_Diameter_Lg = 10;

/*

MOUNTING PARTS

*/

//!make_ThreadedSnap(offset = Snap_Connector_Height, anchor=BOT) show_anchors();
union(){
    if(Show_Part == "Snap Connector")
        
            recolor(Global_Color)
            if (Split_Printing)
                split_Part(split_width =20, connect=BOT, largest_size = 45) zrot(45)
                    make_ThreadedSnap(offset = Snap_Connector_Height, anchor=BOT);
            else
                make_ThreadedSnap(offset = Snap_Connector_Height, anchor=BOT);
}


//Small MB Screw based on step file
if(Show_Part == "Bolts" && (Bolt_Selection == "All" || Bolt_Selection == "Small MB Screw")){
    recolor(Global_Color)
    diff()
    fwd(30)
    cyl(d=12,h=2.5, $fn=6, anchor=BOT, chamfer2=0.6){
        attach(TOP, BOT) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=Thread_Length_Sm, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false);
        tag("remove")attach(BOT, BOT, inside=true, shiftout=0.01) cyl(h=16.01, d= Inner_Hole_Diameter_Sm, $fn=25, chamfer1=-1);
    }
}


//Small MB Screw split

if(Show_Part == "Bolts" && (Bolt_Selection == "All" || Bolt_Selection == "Small MB Screw split")){
    recolor(Global_Color)
    back(50)
    diff()
    {
        left(0.2)yrot(-90)right_half()cyl(d=12,h=2.5, $fn=6, anchor=BOT, chamfer2=0.6){
            attach(TOP, BOT) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=Thread_Length_Sm, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false);
        }
        right(0.2)yrot(90)left_half()cyl(d=12,h=2.5, $fn=6, anchor=BOT, chamfer2=0.6){
            attach(TOP, BOT) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=Thread_Length_Sm, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false);
        }
        cuboid([0.42,10,0.2], anchor=BOT);
    }
}


//Small MB T Screw
if(Show_Part == "Bolts" && (Bolt_Selection == "All" || Bolt_Selection == "Small MB T Screw")){
    recolor(Global_Color)
    diff()
    up(2)yrot(90)left_half(x=2)right_half(x=-2)cuboid([4,14,2.5], chamfer=0.75, edges=[LEFT+FRONT, RIGHT+FRONT, RIGHT+BACK, LEFT+BACK], anchor=BOT){
        attach(TOP, BOT) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=Thread_Length_Sm, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false);
    }
}

if(Show_Part == "Bolts" && (Bolt_Selection == "All" || Bolt_Selection == "Small MB T Screw tool" || Bolt_Selection == "Small MB T Screw")){
//Small MB T Screw tool
recolor(Global_Color)
back(30)
    diff()
    cyl(h=8, d=14.5, $fn=50, anchor=BOT, chamfer2=1, chamfer1=0.5){
       //bottom cutout
       attach(BOT, BOT, inside=true, shiftout=0.01) cuboid([4.2,15,3.5], chamfer=1, edges=[TOP+RIGHT,TOP+LEFT]);
        //top wing
        attach(TOP, BOT, overlap=0.01) cuboid([2,12,7], chamfer=0.5, edges=[TOP,LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK]){
            position([RIGHT+BOT])fillet(l=11, r=1.5, orient=FRONT);
            position([LEFT+BOT])fillet(l=11, r=1.5, spin=180, orient=BACK);
        }
    }
}


//Large MB Screw based on step file (not used yet)
if(Show_Part == "Large Bolt")
    color_this(Global_Color)
    diff()
    right(channelWidth+25) back(30)
    cyl(d=30,h=2.5, $fn=6, anchor=BOT, chamfer2=0.6){
        attach(TOP, BOT) trapezoidal_threaded_rod(d=Outer_Diameter_Lg, l=10, pitch=Pitch_Lg, flank_angle = Flank_Angle_Lg, thread_depth = Thread_Depth_Lg, $fn=50, bevel2 = true, blunt_start=false);
        tag("remove")attach(BOT, BOT, inside=true, shiftout=0.01) cyl(h=16.01, d= Inner_Hole_Diameter_Lg, $fn=25 );
}

//SPLIT PART
//Split part takes a part and splits in half on the bed with a connector. This is often used for stronger connections in things like threads due to layer line orientation. 
module split_Part(split_distance=0.4, split_width=5, connect=TOP, largest_size = 50, connector_height = 0.2){
    union(){
        cuboid([split_distance+0.02, split_width, connector_height], anchor=BOT){
            xrot(-90) back(split_distance/4) attach(RIGHT, connect, overlap=0.01)
                left_half(s = largest_size*2) children();
            xrot(-90) back(split_distance/4)attach(LEFT, connect, overlap=0.01)
                right_half(s = largest_size*2) children();
        }
    }
}

//THREADED SNAP
module make_ThreadedSnap (offset = 3, anchor=BOT,spin=0,orient=UP){
    attachable(anchor, spin, orient, size=[11.4465*2, 11.4465*2, 6.21+offset+Snap_Thread_Height]){
    down(Snap_Thread_Height/2)
    union(){
        snapConnectBacker(offset = offset, holdingTolerance = Snap_Holding_Tolerance) {
            attach(TOP, BOT, overlap=0.05) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=Snap_Thread_Height, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=anchor,spin=spin,orient=orient);
        }
    }
    children();
    }
}

/*

BEGIN SNAP CONNECTOR

*/

module snapConnectBacker(offset = 0, holdingTolerance=1, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[11.4465*2, 11.4465*2, 6.21+offset]){ 
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
            oct_prism(h = 4.23, r = 11.4465*Oct_Scaling, anchor=BOT) {
                //first bevel
                attach(TOP, BOT, shiftout=-0.01) oct_prism(h = 1.97, r1 = 11.4465, r2 = 12.5125, $fn =8, anchor=BOT)
                    //top - used as offset. Independen snap height is 2.2
                    attach(TOP, BOT, shiftout=-0.01) oct_prism(h = offset, r = 12.9885, anchor=BOTTOM);
                        //top bevel - not used when applied as backer
                        //position(TOP) oct_prism(h = 0.4, r1 = 12.9985, r2 = 12.555, anchor=BOTTOM);
            
            //end base
            //bumpouts
            attach([RIGHT, LEFT, FWD, BACK],LEFT, shiftout=-0.01)  color("green") down(0.87) fwd(1)scale([1,1,holdingTolerance]) zrot(90)offset_sweep(path = bumpout, height=3);
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
