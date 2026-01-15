/*
Upload STL from https://thangs.com/designer/Keep%20Making/3d-model/8%20mm%20-%20Dual%20Offset%20Snaps%20%28DS%20Part%20A%29-974338
This file receives the double mount and positions it with the top-right hole on 0,0,0

*/

include <BOSL2/std.scad>

Width = 340;
Height = 25;
RightOffset = Width%25;

//original stl
fwd(25)//place upper hole at y = 0
    up(15.5) //bring the bottom to z=0
        right(8) //place upper hole at x = 0
        yrot(270) //face z up
            import("c:/Users/andym/OneDrive/Documents/OpenSCAD/libraries/STLs/DSPartA8mm.stl");

diff("remove", "keep"){
    //mounting block
    fwd(37)right(5) //remains fixed
        cuboid([RightOffset+5, 49, 4], anchor=BOT+LEFT+FRONT, chamfer=1, edges=[RIGHT+TOP,FRONT+TOP, BACK+TOP]);
        //attach(TOP, BOT, align=LEFT)
            //#color("red") cyl(h=2, r1 = 3, r2 = 6);
    //screw hole tool
    ycopies(n=2, spacing = -Height, sp=[0,0,0])tag("remove")down(0.01)right(15)
        //lower straight
        cyl(h=1.52, r1 = 2.3, r2 = 2.3, $fn=25, anchor=BOT)
        //screw hole chamfer
        attach(TOP, BOT, overlap=0.01) cyl(h=2.51, r1 = 2.3, r2 = 4.75, $fn=25);
}

//ikea lateral 340mm
//ikea vertical 25

function calc_offset(width, height) = 
    [
        width%25,
        height%25
    ];

echo(str(calc_offset(340, 25)));
