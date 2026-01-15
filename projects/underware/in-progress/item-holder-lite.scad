/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model by @dmgerman on MakerWorld

This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @dmgerman on MakerWorld for the specs on the small screw profile
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/*[Item Dimensions]*/
//Width of the item you wish to mount
Item_Width_MM = 50;
//Height of the item you wish to mount
Item_Height_MM = 30;
//Length of the item you wish to mount
Item_Length_MM = 261;

/*[Bracket Options]*/
//Type of Bracket
Bracket_Type = "One-Piece"; //[One-Piece, Two-Piece]
//Width of the bracket
Bridge_Width_MM = 10;
//Thickness of the bracket
Bridge_Wall_Thickness_MM = 1.5;
//If Two-Piece, the distance (in mm) that the tab extends from the bracket
Capture_Distance = 5; 

/*[Advanced Settings]*/
Grid_Size = 25;

/*[Hidden]*/
///*[Direct Screw Mount]*/
Base_Screw_Hole_Inner_Diameter = 7;
Base_Screw_Hole_Outer_Diameter = 15;
//Thickness of of the base bottom and the bottom of the recessed hole (i.e., thicknes of base at the recess)
Base_Screw_Hole_Inner_Depth = 1;
Base_Screw_Hole_Cone = false;
//Minimum distance from the edge of the base to the center of the screw hole
Minimum_Mount_Clearance = 7;
minDistanceBetweenMountPoints = Item_Width_MM + Minimum_Mount_Clearance*2 + Base_Screw_Hole_Inner_Diameter/2;
echo(str("Min distance between mounting points: ", minDistanceBetweenMountPoints));
function calculatedMountPointCenters() = quantup(minDistanceBetweenMountPoints, Grid_Size);
echo(str("Next available grid point: ", calculatedMountPointCenters()));
function calculatedHoleOffsetFromEdge() = (calculatedMountPointCenters()-Item_Width_MM-Bridge_Wall_Thickness_MM*2)/2;

debug=false;

//Item Representation
if(debug)
    #cuboid([Item_Width_MM,Item_Length_MM, Item_Height_MM ], anchor = BOT);

//One-piece U Style
//Bridge
up(Item_Height_MM)
diff() 
cuboid([Item_Width_MM + Bridge_Wall_Thickness_MM*2, Bridge_Width_MM, Bridge_Wall_Thickness_MM], anchor=BOT){
    //downward walls
    attach(BOT, TOP, align=[LEFT,RIGHT])
        cuboid([Bridge_Wall_Thickness_MM, Bridge_Width_MM, Item_Height_MM], anchor=BOT)
            //horizontal mounting points (mount on outside)
            attach($idx == 0 ? LEFT : RIGHT, LEFT , align=BOT)
                //prismoid(size1=[Base_Screw_Hole_Inner_Diameter+1,3], size2=[Bridge_Width_MM,3], h=calculatedHoleOffsetFromEdge()+Base_Screw_Hole_Inner_Diameter/2+2){
                //    edge_profile([BOT+RIGHT, BOT+LEFT], excess=10, convexity=5) 
                //        mask2d_roundover(h=3,mask_angle=$edge_angle);
                cuboid([calculatedHoleOffsetFromEdge()+Base_Screw_Hole_Inner_Diameter/2+2, Bridge_Width_MM, 3], anchor=BOT, rounding=4, edges=[FRONT+RIGHT, BACK+RIGHT]){
                    //screw cutouts
                    attach(TOP, BOT, inside=true, shiftout=0.01, align=LEFT, inset=-1*Base_Screw_Hole_Inner_Diameter/2+calculatedHoleOffsetFromEdge()) cyl(r=Base_Screw_Hole_Inner_Diameter/2, h=3.1, $fn=25);
                    //down(-1*Base_Screw_Hole_Inner_Diameter/2+calculatedHoleOffsetFromEdge())attach(TOP, FRONT, inside=true, shiftout=0.01) cyl(r=Base_Screw_Hole_Inner_Diameter/2, h=3.1, $fn=25);
                };
    tag("remove")
        //splitter
        if(Bracket_Type == "Two-Piece")attach(TOP, BOT, inside=true, shiftout=0.01)
        cuboid([Item_Width_MM -Capture_Distance*2, Bridge_Width_MM+0.02, Bridge_Wall_Thickness_MM+0.02], anchor=BOT);
    }

//view grid
if(debug)
left(calculatedMountPointCenters/2)
#grid_copies(size=150, spacing = 25) cyl(h=0.1, r=Base_Screw_Hole_Inner_Diameter/2);

if(debug)
#xcopies(spacing=quantup(minDistanceBetweenMountPoints, Grid_Size))anchor_arrow();

