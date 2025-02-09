/*Created by Andy Levesque
Credit to 
    - @David D on Printables for Multiconnect
    - Jonathan at Keep Making for Multiboard
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
This file also adopts the Multiboard License https://www.multiboard.io/license
All adaptations must have attribution and follow the more restrictive of the two licenses. 
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

//snap connector https://a360.co/3AI9ZVW

//distance (in mm) to offset the back from the multiboard.
offset = 0; 
//scaling of the bumpout that holds the snap in place
holdingTolerance = 1; //[0.5:0.05:1.5]
//width of backer  (in mm)
width = 100;
//height of backer  (in mm)
height = 100; 
//thickness of backer (in mm)
thickness = 2.0; //.1
//frequency of snaps. 2 means 1 snap every 2 spots (or 50mm)
snapEveryNSpots = 2;


cuboid([width, height, thickness])
 attach(TOP, TOP, shiftout=-0.01) grid_copies(spacing=snapEveryNSpots*25, size=[width-11.4465*2, height-11.4465*2])
    snapConnectBacker(offset = offset, holdingTolerance = holdingTolerance);


module snapConnectBacker(offset = 0, holdingTolerance=1, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[11.4465*2, 11.4465*2, 6.17+offset]){ 
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

