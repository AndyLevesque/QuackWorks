/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model from Hands on Katie (https://handsonkatie.com/)
This code and all non-Gridfinity parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Gridfinity components are licensed under the MIT License.


Documentation available at https://handsonkatie.com/

Change Log:
- 2025-06-08
    - Initial Release
- 2025-07-17
    - Added custom grid options for Gridfinity (e.g., half-grid)
    - Added ability to define grids larger than 1x1 (Gridfinity only)

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    Zack Freedman for his work on the original Gridfinity
    David D for openGrid
    metasyntactic for the opengrid-snap code
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/fnliterals.scad>

/*[Part Selection)]*/
Select_Part = "Straight"; //[Drawer Wall Mounts, Straight, Straight End, X Intersection, T Intersection, L Intersection, Vertical Trim, Label]
Top_or_Bottom = "Both"; //[Top, Bottom, Both]

/*[Base Options]*/
//Not yet implemented
Selected_Base = "Gridfinity"; //[Gridfinity, openGrid, Flat, None]
openGrid_Full_or_Lite = "Lite"; //[Full, Lite]
//openGrid Directional Snaps are for vertical mounting and additional strength against downward forces. See arrow on bottom of snap for direction of up.
openGrid_Directional_Snap = false;
//Orientation of openGrid Directional Snap. See arrow on bottom for orientation of up. Rotate by selecting 1 - 4.
openGrid_Directional_Snap_Orientation = 1; //[1:1:4]
//Thickness of the flat baseplate (by mm)
Flat_Base_Thickness = 1.4; //0.1


/*[Material Size]*/
//Material Thickness (by mm)
Material_Thickness = 3.5; //.01
//Depth of the channel for the material to sit in.
Channel_Depth = 20; 

/*[Experimental - Material Holding Options]*/
//Print a retention spike inside the channels to firmly hold softer material like MDF.
Retention_Spike = false;
//Adjust the size of the spike. Spike auto-calculates to 1/3 the thickness of the material.
Spike_Scale = 1;

/*[Vertical Trim Channel Only]*/
//Length of the channel (by mm)
Total_Trim_Width = 42; 
Middle_Seam_Width = 5;
Total_Trim_Height = 20;

/*[Label Only]*/
//Length of the label (in mm)
Label_Width = 84;

/*[Drawer Wall Screw Mounting]*/
Screw_Mounting = true;
//Wood screw diameter (in mm)
Wood_Screw_Thread_Diameter = 3.5;
//Wood Screw Head Diameter (in mm)
Wood_Screw_Head_Diameter = 7;
//Wood Screw Head Height (in mm)
Wood_Screw_Head_Height = 1.75;

/*[Advanced]*/
//Thickness of the walls of the channel (by mm)
Wall_Thickness = 4;
//Size of the grid (by mm) if not Gridfinity or openGrid. Other sizes not tested. 
custom_grid_size = 0;
//Emboss the material thickness on the bottom of the baseplate.
Print_Specs = true;
Top_Chamfers = true;
Custom_Base_Chamfer = false;
Custom_Base_Chamfer_Size = 2;
//Additional thickness added to the base beyond just the profile (Gridfinity only at the moment)
Added_Base_Thickness = 1; //0.1

//Extend NeoGrid multiple tiles (Only supported by Gridifinity at the moment)
grid_x = 1;
//Extend NeoGrid multiple tiles (Only supported by Gridifinity at the moment)
grid_y = 1;

Base_Chamfer = 
    Selected_Base == "Gridfinity" && !Custom_Base_Chamfer && custom_grid_size == 0 ? 5 : //default gridfinity baseplate chamfer size
    Selected_Base == "Flat" && !Custom_Base_Chamfer ? 4 : //default flat baseplate chamfer size
    Selected_Base == "openGrid" && !Custom_Base_Chamfer ? 3 : //default openGrid full baseplate chamfer size
    Custom_Base_Chamfer_Size;

/*[Hidden]*/
//Additional channel length beyond center for partial channels. This allows slop in cutting dividers. 
Partial_Channel_Buffer = 3;
Part_Separation = 5;



grid_size = 
    custom_grid_size > 0 ? custom_grid_size :
    Selected_Base == "Gridfinity" ? 42 : //grid size for gridfinity baseplate
    Selected_Base == "openGrid" ? 25 : //grid size for openGrid baseplate
    Selected_Base == "Flat" && custom_grid_size == 0 ? 30 : 
    Selected_Base == "Flat" ? custom_grid_size ://grid size for flat baseplate
    0; //no grid size for no baseplate
calculated_base_height = 
    Selected_Base == "Gridfinity" ? 4.75 + Added_Base_Thickness : //0.6 is the additional height for the gridfinity baseplate by default. Update this if parameterized. 
    Selected_Base == "Flat" ? Flat_Base_Thickness:
    Selected_Base == "openGrid" && openGrid_Full_or_Lite == "Full" ? 6.8:
    Selected_Base == "openGrid" && openGrid_Full_or_Lite == "Lite" ? 3.4:
    0;

///*[Straight Channel]*/
//Length of the channel (by mm)
Channel_Length = grid_size*grid_y; 

outside_radius = 7.5; //radius of the outside corner of the baseplate
inside_radius = 0.8; //radius of the inside corner of the baseplate
retention_spike_size = 0.6;
part_placement = grid_size/2+Part_Separation;
grid_clearance = Selected_Base == "Gridfinity" ? 0.5 : 1; //adjusted grid size for spacing between grids


//Text parameters
text_depth = 0.2;
text_size = 6;
font = "Monsterrat:style=Bold";
specs_text = str(Material_Thickness);

    
/*

BEGIN DISPLAYS

*/

Shelf_Wall_Thickness = 17;
Shelf_Wall_Clearance = 2;
Shelf_Bracket_Thickness = 2;
Shelf_Exterior_Drop = 10;

Adhesive_Backer_Thickness = 2;
Adhesive_Backer_Width = 20;

//!openGridSnap(lite=true, directional=true); 

if(Select_Part == "Drawer Wall Mounts"){
    //drawer wall hook
    diff(){
        //Channel Walls
        cuboid([Wall_Thickness*2+Material_Thickness, Channel_Length, Channel_Depth+Wall_Thickness], anchor=FRONT+BOT, orient=FRONT){ //Gridfinity Base
            //Removal tool for channel
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, Channel_Length+0.02, Channel_Depth+0.02]);
            //top of shelf bracket
            attach(BOT, FRONT, overlap=0.01, align=BACK)
                cuboid([Wall_Thickness*2+Material_Thickness, Shelf_Wall_Thickness, Shelf_Bracket_Thickness])
                    attach(BACK, FRONT, overlap=0.01, align=TOP)
                        cuboid([Wall_Thickness*2+Material_Thickness, Shelf_Bracket_Thickness, Shelf_Exterior_Drop+Shelf_Bracket_Thickness]);
        }
    }

    //drawer wall adhesive
    back(42+Part_Separation)
    diff(){
        //Channel Walls
        cuboid([Wall_Thickness*2+Material_Thickness, Channel_Length, Channel_Depth+Wall_Thickness-Adhesive_Backer_Thickness], anchor=FRONT+BOT, orient=FRONT){ //Gridfinity Base
            //Removal tool for channel
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, Channel_Length+0.02, Channel_Depth+0.02]);
            //back bracket
            attach(BOT, TOP, align=BACK)
                cuboid([max(Wall_Thickness*2+Material_Thickness, Adhesive_Backer_Width), Channel_Length, Adhesive_Backer_Thickness]);
        }
    }

    Screw_Backer_Thickness = 2;
    Screw_Backer_Buffer_Width = 4;
    //drawer wall screw
    back(42*2+Part_Separation)
    diff(){
        //Channel Walls
        cuboid([Wall_Thickness*2+Material_Thickness, Channel_Length, Channel_Depth+Wall_Thickness-Adhesive_Backer_Thickness], anchor=FRONT+BOT, orient=FRONT){ //Gridfinity Base
            //Removal tool for channel
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, Channel_Length+0.02, Channel_Depth+0.02]);
            //back bracket
            attach(BOT, TOP, align=BACK)
                cuboid([max(Wall_Thickness*2+Material_Thickness, Wall_Thickness*2+Material_Thickness+Wood_Screw_Head_Diameter*2+Screw_Backer_Buffer_Width*2), Channel_Length, Adhesive_Backer_Thickness])
                    //wood screw head
                    if(Screw_Mounting)
                    attach(TOP, TOP, inside=true, shiftout=0.01)
                    xcopies(n=2, spacing = Wall_Thickness*2+Material_Thickness+Wood_Screw_Head_Diameter+4) 
                        cyl(h=Wood_Screw_Head_Height+0.05, d1=Wood_Screw_Thread_Diameter, d2=Wood_Screw_Head_Diameter, $fn=25)
                            attach(BOT, TOP, overlap=0.01) cyl(h=3.5 - Wood_Screw_Head_Height+0.05, d=Wood_Screw_Thread_Diameter, $fn=25, anchor=TOP);
        }
    }
}

if(Select_Part == "Straight"){
    if(Top_or_Bottom != "Top") 
    fwd(quantup(Channel_Length, grid_size)/2+Part_Separation) 
        NeoGrid_Straight_Thru_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Channel_Length);
    if(Top_or_Bottom != "Bottom") 
    back(Channel_Length/2+Part_Separation)
        NeoGrid_Straight_Thru_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Channel_Length);
}
if(Select_Part == "X Intersection"){
    if(Top_or_Bottom != "Top") 
    left(part_placement + (grid_size - 1)/2 * grid_x)
        NeoGrid_X_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    if(Top_or_Bottom != "Bottom") 
    right(part_placement + (grid_size - 1)/2 * grid_x)
        NeoGrid_X_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

if(Select_Part == "T Intersection"){
    if(Top_or_Bottom != "Top") 
    left(part_placement + (grid_size - 1)/2 * grid_x)
        NeoGrid_T_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    if(Top_or_Bottom != "Bottom") 
    right(part_placement + (grid_size - 1)/2 * grid_y)
        NeoGrid_T_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);

}

if(Select_Part == "Straight End"){
    if(Top_or_Bottom != "Top") 
    left(part_placement + (grid_size - 1)/2)
        NeoGrid_Straight_End_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    if(Top_or_Bottom != "Bottom") 
    right(part_placement)
        zrot(90)
        NeoGrid_Straight_End_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);

}

if(Select_Part == "L Intersection"){
    if(Top_or_Bottom != "Top") 
    left(part_placement + (grid_size - 1)/2 * grid_x)
        NeoGrid_L_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    if(Top_or_Bottom != "Bottom") 
    right(part_placement + (grid_size - 1)/2 * grid_y)
        NeoGrid_L_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);

}

if(Select_Part == "Vertical Trim"){
    NeoGrid_Vertical_Trim(Material_Thickness, Wall_Thickness = Wall_Thickness, Total_Trim_Width = Total_Trim_Width, Middle_Seam_Width = Middle_Seam_Width, Total_Trim_Height = Total_Trim_Height);
}

if(Select_Part == "Label"){
    NeoGrid_Straight_Thru_Label(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Label_Width);
}

/* Display all
//Straight
left(part_placement*3){
    fwd(quantup(Channel_Length, grid_size)/2+Part_Separation) 
        NeoGrid_Straight_Thru_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Channel_Length);
    back(Channel_Length/2+Part_Separation)
        NeoGrid_Straight_Thru_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Channel_Length);
}

//X Intersection
fwd(part_placement){
    left(part_placement)
        NeoGrid_X_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_X_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

//T Intersection
back(part_placement){
    left(part_placement)
        NeoGrid_T_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_T_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

//Straight End
back(part_placement*3){
    left(part_placement)
        NeoGrid_Straight_End_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_Straight_End_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

//L Intersection
fwd(part_placement*3){
    left(part_placement) 
        NeoGrid_L_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_L_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

//Vertical Trim
if(Show_Vertical_Trim ) 
    right(100)
    NeoGrid_Vertical_Trim(Material_Thickness, Wall_Thickness = Wall_Thickness, Total_Trim_Width = Total_Trim_Width, Middle_Seam_Width = Middle_Seam_Width, Total_Trim_Height = Total_Trim_Height);

//debugging delete tool
//channelDeleteTool([Material_Thickness, grid_size+0.02, Channel_Depth-Wall_Thickness+0.02]);
*/

/*
    
END DISPLAYS
    
*/

/*

BEGIN NEOGRID MODULES

*/


module neoGridBase(Channel_Length, grid_size){
        //Gridfinity Base
        if(Selected_Base == "Gridfinity")
            gridfinity_bin_bottom_grid( x = grid_x, y = quantup(Channel_Length, grid_size)/grid_size, grid_size = grid_size, additionalHeight = Added_Base_Thickness, anchor=BOT);
        //Flat Base
        if(Selected_Base == "Flat")
            cuboid( [grid_size, Channel_Length, Flat_Base_Thickness], chamfer=0.5, except=BOT, anchor=BOT);
        if(Selected_Base == "openGrid")
            zrot(90*openGrid_Directional_Snap_Orientation)
            openGridSnap(lite= (openGrid_Full_or_Lite == "Full" ? false : true), directional=openGrid_Directional_Snap, anchor=BOT, spin=0, orient=UP);
        if(Print_Specs)
            baseText();
}

module baseText(){
    translate([grid_x % 2 == 0 ? grid_size / 2 : 0, grid_y % 2 == 0 ? grid_size / 2 : 0, 0])
    zrot(90*(openGrid_Directional_Snap_Orientation-1))
        tag("text")
            mirror([1,0,0])
                text3d(specs_text, size=text_size, font=font, h=text_depth, anchor=CENTER, atype="ycenter");
}

module channelDeleteTool(size, chamfer_edges = [BOT], spike_count = 1, anchor = CENTER, spin = 0, orient = UP){
    tag_scope()
    diff("spike"){
        cuboid(size, anchor=anchor, spin=spin, orient=orient){ //passthru attachables
                //material insertion chamfer 
                if(Top_Chamfers) edge_profile_asym(chamfer_edges, corner_type="chamfer")
                    xflip() mask2d_chamfer(Wall_Thickness/3);
        if(Retention_Spike)
            //Retention Spike
            tag("spike") ycopies(n=spike_count, spacing=size[1]/2)attach([LEFT,RIGHT], BOT, inside=true, overlap=0.01, $fn=30)
                cyl(h=retention_spike_size*Spike_Scale,d2=0, d1=retention_spike_size*Spike_Scale*2);
        children();
        }
    }
}

//STRAIGHT CHANNELS

module NeoGrid_Straight_Thru_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42, Channel_Length = 42){
    diff(){
        //Channel Walls
        cuboid([Wall_Thickness*2+Material_Thickness, Channel_Length, Channel_Depth], anchor=BOT){ //Gridfinity Base
            //top chamfer
                edge_profile([BOT+LEFT, BOT+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3);
        //Removal tool for channel
        attach(TOP, BOT, inside=true, shiftout=0.01)
            channelDeleteTool([Material_Thickness, Channel_Length+0.02, Channel_Depth-Wall_Thickness+0.02]);
        }
    }
}

module NeoGrid_Straight_Thru_Label(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42, Channel_Length = 42, Label_Angle = 30){
    shift_amount = (Wall_Thickness*2+Material_Thickness) * tan(Label_Angle);
    diff(){
        //Channel Walls
        prismoid(
            size1=[Channel_Depth, Channel_Length], 
            size2=[Channel_Depth+shift_amount, Channel_Length],
            h=Wall_Thickness*2+Material_Thickness,
            shift=[shift_amount/2,0],
            orient=LEFT,
        ){
            //top chamfer
            if (Top_Chamfers)
                edge_profile([TOP+LEFT, BOTTOM+LEFT])
                    mask2d_chamfer(Wall_Thickness/3);  
        //Removal tool for channel
        attach(LEFT, BOTTOM, spin=90, inside=true, shiftout=0.01)
            channelDeleteTool(size=[Material_Thickness, Channel_Length+0.02, Channel_Depth-Wall_Thickness+0.02], orient=DOWN);
        attach(TOP-LEFT, TOP, spin=90, shiftout=-Wall_Thickness/6)
            //sharp corner chamfer
            tag("remove") cube(Channel_Length+0.02);
        }
    }
}

module NeoGrid_Straight_Thru_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, Channel_Length = 42, grid_size = 42){
    //Straight Channel
    diff("remove text"){
        neoGridBase(Channel_Length = Channel_Length, grid_size = grid_size);
        //Channel Walls
        up(calculated_base_height-0.01)
            cuboid([ Wall_Thickness*2+Material_Thickness, Channel_Length-grid_clearance,  Channel_Depth], anchor=BOT){ //Gridfinity Base
                //bottom chamfer
                tag("keep") //must label keep due to chamfering out an addition and not a diff. 
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip()mask2d_chamfer(Base_Chamfer);
                //top chamfer
                    if(Top_Chamfers)
                    edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3);
            //Removal tool for channel
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, Channel_Length+0.02,Channel_Depth+0.02]);
            }
    }
}

//X INTERSECTIONS

module NeoGrid_X_Intersection_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    diff(){
        //Channel Walls
        zrot_copies([0,90]) 
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size * ($idx == 1 ? grid_x : grid_y), Channel_Depth], anchor=BOT){ //Gridfinity Base
                //top chamfer
                    if(Top_Chamfers) edge_profile([BOT+LEFT, BOT+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3);
            //Removal tool for channel
            zrot_copies([0,90]) 
                attach(TOP, BOT, inside=true, shiftout=0.01)
                    channelDeleteTool([Material_Thickness, (grid_size * max(grid_x, grid_y))+0.02, Channel_Depth-Wall_Thickness+0.02], spike_count=2);
        }
    }
}

module NeoGrid_X_Intersection_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff("channel chamf text"){ //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        neoGridBase(Channel_Length = Channel_Length, grid_size = grid_size);
        //Channel Wall Y
        up(calculated_base_height-0.01)
            cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_y) -grid_clearance, Channel_Depth], anchor=BOT){
                //bottom outward chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip() //xflip to put the chamfer out rather than in
                            mask2d_chamfer(Base_Chamfer); 
                //top inward chamfer
                    if(Top_Chamfers) tag("chamf") edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            }
        //Channel Wall X
        up(calculated_base_height-0.01)
            zrot(90) down(0.01)
            cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_x) - grid_clearance, Channel_Depth], anchor=BOT){
            //bottom chamfer
                edge_profile_asym([BOT+LEFT, BOT+RIGHT])
                    xflip() //xflip to put the chamfer out rather than in
                        mask2d_chamfer(5); 
            //top chamfer
                if(Top_Chamfers) tag("chamf") edge_profile_asym([TOP+LEFT, TOP+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
        }
        //clear the channels in both directions
        //x
        tag("channel")zrot(90) up(calculated_base_height-0.02)
            channelDeleteTool([Material_Thickness, (grid_size * grid_x)+0.01, Channel_Depth+0.04], spike_count=2, chamfer_edges=[TOP], anchor=BOT);
        //y
        tag("channel")up(calculated_base_height-0.02)
            channelDeleteTool([Material_Thickness, (grid_size * grid_y)+0.01, Channel_Depth+0.04], spike_count=2, chamfer_edges=[TOP], anchor=BOT);
        }//end gridfinity base
}

//T INTERSECTIONS
module NeoGrid_T_Intersection_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    diff(){
        //Full Width Channel
        cuboid([Wall_Thickness*2+Material_Thickness, grid_size * grid_x, Channel_Depth], anchor=BOT){
            //top chamfer
            if(Top_Chamfers) edge_profile([BOT+LEFT, BOT+RIGHT])
                mask2d_chamfer(Wall_Thickness/3);
            //Removal tool - Full Width
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, (grid_size * grid_x) + 0.02, Channel_Depth-Wall_Thickness+0.02], spike_count=2);
        }
        //Partial Width Channel
        zrot(90)
        fwd(Material_Thickness/2+Wall_Thickness-0.01)
        cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_y)/2+Material_Thickness/2+Wall_Thickness, Channel_Depth], anchor=BOT+FRONT){ //Gridfinity Base
            //top chamfer
            if(Top_Chamfers) edge_profile([BOT+LEFT, BOT+RIGHT])
                mask2d_chamfer(Wall_Thickness/3);
            //Removal tool - Partial
            attach(TOP, BOT, shiftout=0.01, inside=true, align=BACK)
                channelDeleteTool([Material_Thickness, (grid_size * grid_y)/2++Material_Thickness/2+0.02, Channel_Depth-Wall_Thickness+0.02]);
        }
    }
}

module NeoGrid_T_Intersection_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff("channel chamf text"){ //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        neoGridBase(Channel_Length = Channel_Length, grid_size = grid_size);
        //Channel Wall partial 
        up(calculated_base_height-0.01)//attach to the top of the gridfinity base
            fwd((grid_size*grid_y)/4-grid_clearance/2)
            cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_y)/2, Channel_Depth], anchor=BOT){
                //bottom outward chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip() //xflip to put the chamfer out rather than in
                            mask2d_chamfer(Base_Chamfer); 
                //top inward chamfer
                    if(Top_Chamfers) tag("chamf")edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            }
        //Channel Wall full width
        up(calculated_base_height-0.01)
            zrot(90)
            cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_x)-grid_clearance, Channel_Depth], anchor=BOT){
            //bottom chamfer
                edge_profile([BOT+LEFT, BOT+RIGHT])
                    xflip() //xflip to put the chamfer out rather than in
                        mask2d_chamfer(Base_Chamfer); 
            //top chamfer
                if(Top_Chamfers) tag("chamf")edge_profile([TOP+LEFT, TOP+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
        }
        //clear the channels in both directions
        //channel clear partial
        tag("channel")up(calculated_base_height-0.02) fwd((grid_size*grid_y)/4-grid_clearance/2)
            channelDeleteTool([Material_Thickness, (grid_size*grid_y)/2+0.02, Channel_Depth+0.02], chamfer_edges=[TOP], anchor=BOT);
        //channel clear full length
        tag("channel")zrot(90)up(calculated_base_height-0.02)
            channelDeleteTool([Material_Thickness, (grid_size*grid_x)+0.02, Channel_Depth+0.02], spike_count=2, chamfer_edges=[TOP], anchor=BOT);
    }//end gridfinity base
}

//End Channels
module NeoGrid_Straight_End_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    diff(){
        //Channel Walls
            cuboid([ Channel_Length, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT){
            //top chamfer
                if(Top_Chamfers) edge_profile([BOT+FRONT, BOT+BACK, BOT+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3);
        //Removal tool for channel
        attach(TOP, BOT, inside=true, shiftout=0.01, align=LEFT, spin=90)
                channelDeleteTool([Material_Thickness, Channel_Length-Partial_Channel_Buffer+0.02, Channel_Depth-Wall_Thickness+0.02]);
        }
    }
}

module NeoGrid_Straight_End_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //Straight Channel
    diff("remove text"){
        neoGridBase(Channel_Length = Channel_Length, grid_size = grid_size);
        //Channel Walls
        zrot(90)
        up(calculated_base_height-0.01)
            cuboid([Channel_Length - grid_clearance, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT){
                //bottom chamfer
                tag("keep") //must label keep due to chamfering out an addition and not a diff. 
                    edge_profile_asym([BOT+FRONT, BOT+BACK])
                        xflip()mask2d_chamfer(Base_Chamfer);
                //top chamfer
                    if(Top_Chamfers) edge_profile([TOP+FRONT, TOP+BACK])
                        mask2d_chamfer(Wall_Thickness/3);
                //Removal tool for channel
                attach(TOP, BOT, inside=true, shiftout=0.01, spin=90, align=LEFT)
                    channelDeleteTool([ Material_Thickness, Channel_Length-Partial_Channel_Buffer+0.02, Channel_Depth+0.02]);
            }
    }
}



module NeoGrid_L_Intersection_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff(){ //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        //Channel Wall X axis
        back(Material_Thickness/2+Wall_Thickness)
        cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_x)/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Channel_Depth], anchor=BOT+BACK){
            //inward chamfer
                edge_profile([BOT+LEFT, BOT+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer half the wall thickness
        }
        //Channel Wall Y axis
        right(Material_Thickness/2+Wall_Thickness)
        cuboid([(grid_size * grid_y)/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT+RIGHT){
        //inward chamfer
            edge_profile([BOT+FRONT, BOT+BACK])
                mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            tag("remove")
                attach(TOP, TOP, inside=true, shiftout=0.01, align=LEFT, spin=90)
                channelDeleteTool([ Material_Thickness, (grid_size * grid_y)/2+Material_Thickness/2-grid_clearance/2+0.02, Channel_Depth-Wall_Thickness+0.02], chamfer_edges=TOP, anchor=BOT+RIGHT);
        }
        //clear the channels in both directions
        //channel clear partial
        tag("remove")
            up(Wall_Thickness) back(Material_Thickness/2)
            channelDeleteTool([Material_Thickness, (grid_size * grid_x)/2+Material_Thickness/2-grid_clearance/2+0.02, Channel_Depth-Wall_Thickness+0.02], chamfer_edges=TOP, anchor=BOT+BACK);
    }
}


module NeoGrid_L_Intersection_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff("channel text"){ //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        neoGridBase(Channel_Length = Channel_Length, grid_size = grid_size);
        //Channel Wall Y axis
        up(calculated_base_height-0.01) //attach to the top of the gridfinity base
            fwd((grid_size * grid_y)/4-grid_clearance/4-Material_Thickness/4-Wall_Thickness/2)
            cuboid([Wall_Thickness*2+Material_Thickness, (grid_size * grid_y)/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Channel_Depth], anchor=BOT){
                //bottom outward chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip() //xflip to put the chamfer out rather than in
                            mask2d_chamfer(Base_Chamfer); 
                //top inward chamfer
                    edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            }
        //Channel Wall X axis
        up(calculated_base_height-0.01)
            left((grid_size * grid_x)/4-grid_clearance/4-Material_Thickness/4-Wall_Thickness/2)
            cuboid([(grid_size * grid_x)/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT){
            //bottom chamfer
                edge_profile_asym([BOT+FRONT, BOT+BACK, BOT+RIGHT], corner_type="sharp")
                    xflip() //xflip to put the chamfer out rather than in
                        mask2d_chamfer(Base_Chamfer); 
            //top chamfer
                edge_profile([TOP+LEFT, TOP+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
        }
        //clear the channels in both directions
        tag("channel")up(calculated_base_height-0.02) fwd((grid_size * grid_y)/4-grid_clearance/4-Material_Thickness/4)
            channelDeleteTool([Material_Thickness, (grid_size * grid_y)/2+Material_Thickness/2-grid_clearance/2+0.03, Channel_Depth+0.04], chamfer_edges=TOP, anchor=BOT);
        tag("channel")up(calculated_base_height-0.02) zrot(90) back((grid_size * grid_x)/4-grid_clearance/4-Material_Thickness/4)
            channelDeleteTool([Material_Thickness, (grid_size * grid_x)/2+Material_Thickness/2-grid_clearance/2+0.03, Channel_Depth+0.04], chamfer_edges=TOP, anchor=BOT);

        }//end gridfinity base
}

module NeoGrid_Vertical_Trim(Material_Thickness, Wall_Thickness = 4, Total_Trim_Width = 42, Middle_Seam_Width = 4, Total_Trim_Height = 40){
    diff()
    cuboid([Total_Trim_Width, Wall_Thickness*2+Material_Thickness, Total_Trim_Height], anchor=BOT){
        //cutouts
        attach([LEFT, RIGHT], LEFT, inside=true, shiftout=0.01)
            cuboid([Total_Trim_Width/2-Middle_Seam_Width/2, Material_Thickness, Total_Trim_Height+0.02]);
        //chamfers
        edge_profile([BOT+FRONT, BOT+BACK, TOP+FRONT, TOP+BACK])
            mask2d_chamfer(Wall_Thickness/3);
    }
}

/*

END NEOGRID MODULES

*/

/*

BEGIN GRIDFINITY MODULES

*/

module gridfinity_bin_bottom_grid(x, y, additionalHeight = 1, grid_size = 42, anchor, spin, orient){
    
    attachable(anchor, spin, orient, size=[grid_size*x-0.5, grid_size*y-0.5, 4.75+additionalHeight]){
        down((4.75+additionalHeight)/2)
        union(){
            up(4.75+additionalHeight/2-0.01)
                minkowski(){
                    cuboid([grid_size*x-.5-outside_radius,grid_size*y-0.5-outside_radius, additionalHeight]);
                    cyl(h=0.01, d=outside_radius, $fn=50);
                }
            translate([grid_size/2-grid_size/2*x,grid_size/2-grid_size/2*y,0])
                for (i = [0:x-1]){
                    for (j = [0:y-1]){
                        translate([i*grid_size, j*grid_size, 0]){
                            gridfinity_bin_bottom(anchor=BOT, grid_size = grid_size);
                        }
                    }
                }
        }
    children();
    }
    
}

//Gridfinity bin bottom profile with inside radius added (for minkowski)
base_profile_adj = [
                    [0,0], //start at inner profile
                    [inside_radius,0], //start at inner profile
                    [0.8+inside_radius, 0.8], //up and out 0.8
                    [0.8+inside_radius, 0.8 + 1.8], //up 1.8
                    [0.8 + 2.15+inside_radius, 0.8 + 1.8 + 2.15], //up and out 2.15
                    [0, 0.8 + 1.8 + 2.15] //back to inside
                ]; //Gridfinity Bin Bottom Specs

module gridfinity_bin_bottom(additionalHeight = 0, grid_size = 42, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[grid_size - 0.5, grid_size - 0.5, 4.75]){
                translate(v = [-(grid_size - 6.4 - inside_radius*2)/2,-(grid_size - 6.4 - inside_radius*2)/2,-4.75/2]) 
                    rotate(a = [0,0,0]) 
                        minkowski() {
                            rotate_extrude($fn=50) 
                                    polygon(points=base_profile_adj); //Gridfinity Bin Bottom Specs
                            cube(size = [grid_size - 6.4 - inside_radius*2,grid_size - 6.4-inside_radius*2,0.01+additionalHeight]);
                        }
    children();
    }
}
module gridfinity_base(grid_size = 42) {
    //TODO - finish grid size implementation
    difference() {
        cube(size = [grid_size,grid_size,4.65]);
        /*
        baseplate delete tool
        This is a delete tool which is the inverse profile of the baseplate intended for Difference.
        Using polygon, I sketched the profile of the base edge per gridfinity specs.
        I then realized I need rounded corners with 8mm outer diameter, so I increased the x axis enough to have a 4mm total outer length (radius).
        I rotate extrude to created the rounded corner 
        Finally, I used minkowski (thank you Katie from "Hands on Katie") using a cube that is 42mm minus the 8mm of the edges (equalling 34mm)
        I also added separate minkowski tools to extend the top and the bottom for proper deleting
        */
        union() {
            //primary profile
            translate(v = [4,38,5.65]) 
                rotate(a = [180,0,0]) 
                    minkowski() {
                        rotate_extrude($fn=50) 
                                polygon(points = [[0,0],[4,0],[3.3,0.7],[3.3,2.5],[1.15,4.65],[0,4.65]]);
                        cube(size = [34,34,1]);
                    }
            //bottom extension bottom tool
            translate(v = [4,4,-2]) 
                    minkowski() {
                        linear_extrude(height = 1) circle(r = 4-2.85, $fn=50);
                        cube(size = [34,34,6]);
            }
            //top extension
                translate(v = [4,4,5])
                    minkowski() {
                        linear_extrude(height = 1) circle(r = 4, $fn=50);
                        cube(size = [34,34,2]);
            }
        }
    }
}

module openGridSnap(lite=false, directional=false, orient, anchor, spin){
	module openGridSnapNub(w, nub_h, nub_w, nub_d, b_y, top_wedge_h, bot_wedge_h, r_x, r_r, r_s){
		move([w/2-0.01, 0, 0]) 
		intersection(){
			difference(){
				//bounding box
				zmove(nub_h) cuboid([nub_d,nub_w,2-nub_h], anchor=CENTER+LEFT+BOTTOM) ;
				//top part
				zmove(2) rotate([0,180,90]) wedge([nub_w,nub_d,top_wedge_h], anchor=CENTER+BOTTOM+BACK);
				//bottom part
				zmove(nub_h) rotate([0,0,90]) ymove(b_y) wedge([nub_w,0.4,bot_wedge_h], anchor=CENTER+BOTTOM+BACK);
			};
			//rounding
			xmove(r_x) yscale(r_s) cyl($fn=600, r=r_r, h=2, anchor=BOTTOM);
		};
	}

	w=24.80;
	fulldiff=3.4;
	h=lite ? 3.4 : fulldiff*2;
	attachable(orient=orient, anchor=anchor, spin=spin, size=[w,w,h]){
		zmove(-h/2) difference(){
			core=3 + (lite ? 0 : fulldiff);
			top_h=0.4; 
			top_nub_h=1.1;

			union() {
				//top
				zmove(h-top_h) cuboid([w,w,top_h], rounding=3.262743, edges="Z", $fn=2, anchor=BOTTOM);
				// core
				cuboid([w,w,core], rounding=4.81837, edges="Z", $fn=2, anchor=BOTTOM);
				//top nub
				offs=2.02;
				intersection(){
					zmove(core-top_nub_h) cuboid([w,w,top_nub_h], rounding=3.262743, edges="Z", $fn=2, anchor=BOTTOM);
					zrot_copies(n=4) move([w/2-offs,w/2-offs,core]) rotate([180, 0, 135]) wedge(size=[6.817,top_nub_h,top_nub_h], anchor=CENTER+BOTTOM);
				};
				//bottom nub
				zmove(lite ? 0 : fulldiff) zrot_copies(n=4)
					if (!directional || ($idx==1 || $idx==3))
					openGridSnapNub(
						w=w,
						nub_h=0.2,
						nub_w=11,
						nub_d=0.4,
						top_wedge_h=0.6,
						bot_wedge_h=0.6,
						r_x=-12.36,
						r_s=1.36,
						r_r=13.025,
						b_y=-0
					);
				//directional nubs 
				 if (directional) {
					//front directional nub
					zmove(lite ? 0 : fulldiff) openGridSnapNub(
						w=w,
						nub_h=0,
						nub_w=14,
						nub_d=0.8,
						top_wedge_h=1.0,
						bot_wedge_h=0.4,
						r_x=-11.75,
						r_s=1.26,
						r_r=13.025,
						b_y=-0.4
					);
					 
					//rear directional nub
					zrot(180) zmove(lite ? 0 : fulldiff) openGridSnapNub(
						w=w,
						nub_h=0.65,
						nub_w=10.8,
						nub_d=0.4,
						top_wedge_h=0.6,
						bot_wedge_h=0.6,
						r_x=-12.41,
						r_s=1.37,
						r_r=13.025,
						b_y=0
					);
				};
			};
			//bottom click holes
			zrot_copies(n=4)
				move([w/2-1, 0, 0])
				if (!directional || $idx==1 || $idx==3)
					cuboid([0.6,12.4,2.8 + (lite ? 0 : fulldiff)], rounding=0.3, $fn=100, edges="Z", anchor=BOTTOM);
			//bottom click holes for rear directional
			if (directional) {
				zrot(180) move([w/2-1, 0, 0.599]) cuboid([0.6, 12.4, 2.2 + (lite ? 0 : fulldiff) ], rounding=0.3, $fn=100, edges="Z", anchor=BOTTOM);
				zrot(180) move([w/2-1.2, 0, 0]) prismoid(size1=[0.6, 12.4], size2=[0.6, 12.4], h=0.6, shift=[0.2,0], rounding=0.3, $fn=100);
				zrot(180) move([w/2-0.1, 0, 0]) rotate([0,0,0]) prismoid(size1=[0.2, 20], size2=[0, 20], shift=[0.1,0], h=0.6, anchor=BOTTOM);
			};

			//bottom wall click holes
			zrot_copies(n=4)
				move([w/2, 0, 2.2 + (lite ? 0 : fulldiff)])
				if (!directional || ($idx>0))
					cuboid([1.4,12,0.4], anchor=BOTTOM);

			//directional indicator
			if (directional) move([9.5,0,0]) cylinder(r1=2, r2=1.5, h=0.4, $fn=2);
		};
		children();
	};
};

