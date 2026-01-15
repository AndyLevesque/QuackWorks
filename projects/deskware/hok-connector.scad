/* 
HOK Connector
Design by Hands on Katie
OpenSCAD by BlackjackDuck (Andy)

This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025-06-04
    - Initial release

Credit to 
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
*/

include <BOSL2/std.scad>


Side_1_Depth = 15;
//Side_2_Depth = 15; //not implemented yet
Pre_Tab_Width = 15;
Total_Thickness = 2.75;
Half = false;

/*[Hidden]*/
$fn = 25;

HOKConnector(side1depth = Side_1_Depth, preTabWidth = Pre_Tab_Width, totalThickness = Total_Thickness, half = Half);

module HOKConnector(side1depth = 15, preTabWidth = 15, totalThickness = 2.75, half = false, spin = 0, orient = UP, anchor=CENTER){

    //Thickness of the chamfer for one side
    Chamfer_thickness = 0.5;

    cutout1Depth = side1depth - 1.5;
    distanceBetweenCutouts = preTabWidth - 7;
    cutoutWidth = 2.75; //including chamfers

    middleThickness = totalThickness - Chamfer_thickness*2;

    attachable(anchor, spin, orient, size=[half ? side1depth : side1depth*2, preTabWidth, totalThickness]){
        translate([half ? -side1depth/2 : 0,preTabWidth/2,-totalThickness/2])
        if(half)
            right_half()
                HOKConnectorFull();
        else
            HOKConnectorFull();
        children();
    }

    module HOKConnectorFull(){
        diff(){
            force_tag("")
                chamferProfile(profile = HOKOutsideProfileFull_Turtle, middleThickness = middleThickness, chamferThickness = Chamfer_thickness);
            //cutouts
            force_tag("remove")
                translate([0,-preTabWidth/2,0])
                down(0.01)
                    //copy top and bottom
                    xflip_copy(offset = 1 - 0.05)
                        //copy left and right
                        yflip_copy(offset = -distanceBetweenCutouts/2) 
                            cutout();
            //cutout inside chamfer
            tag("keep")
                right(0.05)
                fwd(preTabWidth/2)
                    cuboid([side1depth*2-1 - 0.05,distanceBetweenCutouts+2,totalThickness], chamfer=1, edges = [FRONT, BACK], anchor=BOT);
        }
    }

    module cutout(){
        linear_extrude(height = totalThickness + 0.02)
            polygon(HOKInsideCutoutProfile(cutout1Depth));
    }

    //define the turtle points for half the profile (to be mirrored later)
    HOKOutsideProfileHalf_Turtle = [
        "move", 5- (15 - side1depth)/2, //middle to start of first tab 
        "left", 45, //start first tab
        "move", 0.54,
        "arcright", 1, 45,
        "move", 1.86 ,
        "arcright", 1, 45,
        "move", 0.54,
        "left", 45, //end first tab
        "move", 3.156 - (15 - side1depth)/2, //top of first tab to start of curve inward
        "arcright", 2, 45,
        "move", 1.172,
        "arcright", 2, 45,
        "move", preTabWidth - 5.657,// middle span (equals 9.343 at standard 15mm width)
        "arcright", 2, 45,
        "move", 1.172,
        "arcright", 2, 45,
        "move", 3.156- (15 - side1depth)/2,
        "left", 45,
        "move", 0.54,
        "arcright", 1, 45,
        "move", 1.8,
        "arcright", 1, 45,
        "move", 0.54,
        "left", 45,
        "move", 5- (15 - side1depth)/2,
    ];

    //join two turtle paths to effectively mirror
    HOKOutsideProfileFull_Turtle = turtle(concat(HOKOutsideProfileHalf_Turtle, HOKOutsideProfileHalf_Turtle));

    function HOKInsideCutoutProfile(cutoutDepth) = 
        turtle([
            "move", cutoutDepth,
            "right", 90 + 45, 
            "move", 3.474,
            "arcright", 1, 45,
            "move", 9.336 - (15 - side1depth),
            "arcright", 1, 90,
        ]);

    //take a profile and chamfer top and bottom
    module chamferProfile(profile, middleThickness, chamferThickness){
        totalThickness = middleThickness + chamferThickness*2;

        intersection(){
            mainBody();
            scopeBody();
        }
        
        module mainBody(){
            //top
            up(chamferThickness + middleThickness)
                roof() 
                    polygon(profile);
            //mid
            up(chamferThickness)
                linear_extrude(height = middleThickness) polygon(profile); 
            //bot
            up(chamferThickness)
                zflip()
                    roof() 
                        polygon(profile);
        }   
        module scopeBody(){
            linear_extrude(height = totalThickness) polygon(profile); 
        }
    }

}