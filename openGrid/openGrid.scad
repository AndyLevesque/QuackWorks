/* 
openGrid
Design by DavidD
OpenSCAD by BlackjackDuck (Andy) https://makerworld.com/en/@BlackjackDuck
This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025-04-08
    - Initial release
- 2025-04-10
    - Tile stacking added for lite tiles with updated interface layer
    -Significant performance improvements (thanks Pedro Leite!)

Credit to 
    @David D on Printables for openGrid https://www.printables.com/@DavidD
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord https://handsonkatie.com/
    Pedro Leite for research and contributions on script performance improvements https://makerworld.com/en/@pedroleite

*/

include <BOSL2/std.scad>

/*[Board Size]*/
Full_or_Lite = "Lite";//[Full, Lite]
Board_Width = 2;
Board_Height= 2;

/*[Style and Mounting Options]*/
//Screw holes for mounting -  
Screw_Mounting = "Corners"; //[Everywhere, Corners, None]
//Cosmetic bevels - If screw holes turned on, bevels will only be on the outside corners. 
Bevels = "Corners"; //[Everywhere, Corners, None]
Connector_Holes = true;

/*[Screw Mounting Sizes]*/
Screw_Diameter = 4.1;
Screw_Head_Diameter = 7.2;
Screw_Head_Inset = 1;

/*[Advanced - Tile Parameters]*/
//Customize tile sizes - openGrid standard is 28mm
Tile_Size = 28;
//Thickness of the tile (full only)
Tile_Thickness = 6.8;

/*[Tile Stacking]*/
//Stacking more than 6 tiles may time out. Desktop version recommended for larger stacks.
Stack_Count = 1;
//Thickness of the interface between tiles. This is the distance between the top of the tile and the bottom of the next tile.
Interface_Thickness = 0.4; 
//Distance between the interface and the tile. This is the distance between the top of the tile and the bottom of the interface. Try to use a multiple of the layer height when combined with the interface thickness.
Interface_Separation = 0.1;

//GENERATE TILES
if(Full_or_Lite == "Full" && Stack_Count == 1) openGrid(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT, Connector_Holes = Connector_Holes);
if(Full_or_Lite == "Lite" && Stack_Count == 1) openGridLite(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size,  Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT, Connector_Holes = Connector_Holes);

//Stacked tiles
if(Full_or_Lite == "Full" && Stack_Count > 1){
    zcopies(spacing = Tile_Thickness + Interface_Thickness + 2*Interface_Separation, n=Stack_Count, sp=[0,0,Tile_Thickness])
        zflip()
        openGrid(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT, Connector_Holes = Connector_Holes);
    zcopies(spacing = Tile_Thickness + Interface_Thickness + 2*Interface_Separation, n=Stack_Count-1, sp=[0,0,Tile_Thickness + Interface_Separation])
        color("red") interfaceLayer(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, boardType = "Full", anchor=BOT);
}

if(Full_or_Lite == "Lite" && Stack_Count > 1){
    Lite_Tile_Thickness = 4;
    zcopies(spacing = Lite_Tile_Thickness + Interface_Thickness + 2*Interface_Separation, n=Stack_Count, sp=[0,0,Lite_Tile_Thickness])
        openGridLite(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size,  Screw_Mounting = Screw_Mounting, Bevels = Bevels, Connector_Holes = Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
    zcopies(spacing = Lite_Tile_Thickness + Interface_Thickness + 2*Interface_Separation, n=Stack_Count-1, sp=[0,0,Lite_Tile_Thickness + Interface_Separation])
        color("red") interfaceLayer2D(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, boardType = "Lite", topSide = $idx % 2 == 0 ? false : true);
}

module interfaceLayer(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP, boardType = "Full"){
    linear_extrude(height = Interface_Thickness) 
        projection(cut=true)
            interfaceLayer2D(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = tileSize, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, boardType = boardType);
}
/*
projection(cut=true)
down(0.01)openGridLite(
                    Board_Width = Board_Width,
                    Board_Height = Board_Height,
                    tileSize = 28,
                    Screw_Mounting = Screw_Mounting,
                    Bevels = Bevels,
                    Connector_Holes = Connector_Holes,
                    anchor=BOT,
                    orient=UP
                );
*/
//create a 2d profile of the interface layer to be extruded later. This is used to create the interface layer between tiles.
module interfaceLayer2D(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP, boardType = "Full", topSide = false){
    linear_extrude(height = Interface_Thickness) 
        projection(cut=true)
            //bottom_half(z = 0.1, s = max(tileSize * Board_Width, tileSize * Board_Height) * 2)
            if (boardType == "Lite") {
                down(0.01)
                openGridLite(
                    Board_Width = Board_Width,
                    Board_Height = Board_Height,
                    tileSize = tileSize,
                    Screw_Mounting = Screw_Mounting,
                    Bevels = Bevels,
                    Connector_Holes = Connector_Holes,
                    anchor=topSide ? BOT : TOP,
                    orient=topSide ? UP : DOWN
                );
            } else {
                openGrid(
                    Board_Width = Board_Width,
                    Board_Height = Board_Height,
                    tileSize = tileSize,
                    Tile_Thickness = Tile_Thickness,
                    Screw_Mounting = Screw_Mounting,
                    Bevels = Bevels,
                    Connector_Holes = Connector_Holes,
                    anchor=BOT
                );
            }
}
module openGridLite(Board_Width, Board_Height, tileSize = 28, Screw_Mounting = "None", Bevels = "None", anchor = CENTER, spin = 0, orient = UP, Connector_Holes = false) {
    // Screw_Mounting options: [Everywhere, Corners, None]
    // Bevel options: [Everywhere, Corners, None]
    Tile_Thickness = 6.8;
    Lite_Tile_Thickness = 4;
    
    attachable(anchor, spin, orient, size = [Board_Width * tileSize, Board_Height * tileSize, 4]) {
        render(convexity = 2)
        down(4 / 2)
        down(Tile_Thickness - 4)
        top_half(z = Tile_Thickness - 4, s = max(tileSize * Board_Width, tileSize * Board_Height) * 2)
        openGrid(
            Board_Width = Board_Width,
            Board_Height = Board_Height,
            tileSize = tileSize,
            Screw_Mounting = Screw_Mounting,
            Bevels = Bevels,
            anchor = BOT,
            Connector_Holes = Connector_Holes
        );
    children();
    }
}

module openGrid(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP){
    //Screw_Mounting options: [Everywhere, Corners, None]
    //Bevel options: [Everywhere, Corners, None]

    $fn=30;
    //2D is fast. 3D is slow. No benefits of 3D. 
    Render_Method = "2D";//[3D, 2D]
    Intersection_Distance = 4.2;
    Tile_Thickness = Tile_Thickness;
    
    tileChamfer = sqrt(Intersection_Distance^2*2);
    lite_cutout_distance_from_top = 1;
    connector_cutout_height = 2.4;

    attachable(anchor, spin, orient, size=[Board_Width*tileSize,Board_Height*tileSize,Tile_Thickness]){

        down(Tile_Thickness/2)
        render(convexity=2)
        diff(){
            render() union() {
                grid_copies(spacing = tileSize, n = [Board_Width, Board_Height])

                    if(Render_Method == "2D") openGridTileAp1(tileSize = tileSize, Tile_Thickness = Tile_Thickness);
                        else wonderboardTileAp2();
                
            }
            //TODO: Modularize positioning (Outside Corners, inside corners, inside all) and holes (chamfer and screw holes)
            //Bevel Everywhere
            if(Bevels == "Everywhere" && Screw_Mounting != "Everywhere" && Screw_Mounting != "Corners")
            tag("remove")
                grid_copies(spacing=tileSize, size=[Board_Width*tileSize,Board_Height*tileSize])
                    down(0.01)
                    zrot(45)
                        cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
            //Bevel Corners
            if(Bevels == "Corners" || (Bevels == "Everywhere" && (Screw_Mounting == "Everywhere" || Screw_Mounting == "Corners")))
                tag("remove")
                move_copies([[tileSize*Board_Width/2,tileSize*Board_Height/2,0],[-tileSize*Board_Width/2,tileSize*Board_Height/2,0],[tileSize*Board_Width/2,-tileSize*Board_Height/2,0],[-tileSize*Board_Width/2,-tileSize*Board_Height/2,0]])
                    down(0.01)
                    zrot(45)
                        cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
            //Screw Mount Corners
            if(Screw_Mounting == "Corners")
                tag("remove")
                move_copies([[tileSize*Board_Width/2-tileSize,tileSize*Board_Height/2-tileSize,0],[-tileSize*Board_Width/2+tileSize,tileSize*Board_Height/2-tileSize,0],[tileSize*Board_Width/2-tileSize,-tileSize*Board_Height/2+tileSize,0],[-tileSize*Board_Width/2+tileSize,-tileSize*Board_Height/2+tileSize,0]])
                up(Tile_Thickness+0.01)
                    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                            attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
            //Screw Mount Everywhere
            if(Screw_Mounting == "Everywhere")
                tag("remove")
                grid_copies(spacing=tileSize, size=[(Board_Width-2)*tileSize,(Board_Height-2)*tileSize])            up(Tile_Thickness+0.01)
                    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                            attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
            if(Connector_Holes){
                if(Board_Height > 1)
                tag("remove")
                up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
                xflip_copy(offset = -tileSize*Board_Width/2-0.005)
                    ycopies(spacing=tileSize, l=Board_Height > 2 ? Board_Height*tileSize-tileSize*2 : Board_Height*tileSize - tileSize - 1)
                        connector_cutout_delete_tool(anchor=LEFT);
                if(Board_Width > 1)
                tag("remove")
                up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
                yflip_copy(offset = -tileSize*Board_Height/2-0.005)
                    xcopies(spacing=tileSize, l=Board_Width > 2 ? Board_Width*tileSize-tileSize*2 : Board_Width*tileSize-tileSize-1)
                        zrot(90)
                            connector_cutout_delete_tool(anchor=LEFT);
            }

        }//end diff
        children();
    }

    //BEGIN CUTOUT TOOL
    module connector_cutout_delete_tool(anchor=CENTER, spin=0, orient=UP){
        //Begin connector cutout profile
        connector_cutout_radius = 2.6;
        connector_cutout_dimple_radius = 2.7;
        connector_cutout_separation = 2.5;
        connector_cutout_height = 2.4;
        dimple_radius = 0.75/2;
        
        attachable(anchor, spin, orient, size=[connector_cutout_radius*2-0.1 ,connector_cutout_radius*2,connector_cutout_height]){
            //connector cutout tool
            tag_scope()
            translate([-connector_cutout_radius+0.05,0,-connector_cutout_height/2])
            render()
            half_of(RIGHT, s=connector_cutout_dimple_radius*4)
                linear_extrude(height = connector_cutout_height) 
                union(){
                    left(0.1)
                    diff(){
                        $fn=50;
                        //primary round pieces
                        hull()
                            xcopies(spacing=connector_cutout_radius*2)
                                circle(r=connector_cutout_radius);
                        //inset clip
                        tag("remove")
                        right(connector_cutout_radius-connector_cutout_separation)
                            ycopies(spacing = (connector_cutout_radius+connector_cutout_separation)*2)
                                circle(r=connector_cutout_dimple_radius);
                        //dimple (ass) to force seam. Only needed for positive connector piece (not delete tool)
                        //tag("remove")
                        //right(connector_cutout_radius*2 + 0.45 )//move dimple in or out
                        //    yflip_copy(offset=(dimple_radius+connector_cutout_radius)/2)//both sides of the dimpme
                        //        rect([1,dimple_radius+connector_cutout_radius], rounding=[0,-connector_cutout_radius,-dimple_radius,0], $fn=32); //rect with rounding of inner flare and outer smoothing

                    }
                    //outward flare fillet for easier insertion
                    rect([1,connector_cutout_separation*2-(connector_cutout_dimple_radius-connector_cutout_separation)], rounding=[0,-.25,-.25,0], $fn=32, corner_flip=true, anchor=LEFT);
                }
            children();
        }
    }
    //END CUTOUT TOOL

    module openGridTileAp1(tileSize = 28, Tile_Thickness = 6.8){
        Tile_Thickness = Tile_Thickness;
        
        Outside_Extrusion = 0.8;
        Inside_Grid_Top_Chamfer = 0.4;
        Inside_Grid_Middle_Chamfer = 1;
        Top_Capture_Initial_Inset = 2.4;
        Corner_Square_Thickness = 2.6;
        Intersection_Distance = 4.2;

        Tile_Inner_Size_Difference = 3;



        calculatedCornerSquare = sqrt(tileSize^2+tileSize^2)-2*sqrt(Intersection_Distance^2/2)-Intersection_Distance/2;
        Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference; //25mm default
        insideExtrusion = (tileSize-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
        middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
        cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default

        CalculatedCornerChamfer = sqrt(Intersection_Distance^2 / 2);
        cornerOffset = CalculatedCornerChamfer + Corner_Square_Thickness; //5.56985 (half of 11.1397)

        CorderSquareWidth = sqrt(Corner_Square_Thickness^2 + Corner_Square_Thickness^2)+Intersection_Distance;
        
        full_tile_profile = [
            [0,0],
            [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,0],
            [Outside_Extrusion+insideExtrusion,Inside_Grid_Top_Chamfer],
            [Outside_Extrusion+insideExtrusion,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion,Top_Capture_Initial_Inset],
            [Outside_Extrusion,Tile_Thickness-Top_Capture_Initial_Inset],
            [Outside_Extrusion+insideExtrusion,Tile_Thickness-Top_Capture_Initial_Inset+Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion+insideExtrusion,Tile_Thickness-Inside_Grid_Top_Chamfer],
            [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,Tile_Thickness],
            [0,Tile_Thickness]
            ];
        full_tile_corners_profile = [
            [0,0],
            [cornerOffset-cornerChamfer,0],
            [cornerOffset,cornerChamfer],
            [cornerOffset,Tile_Thickness-cornerChamfer],
            [cornerOffset-cornerChamfer,Tile_Thickness],
            [0,Tile_Thickness]

            ];
        
        path_tile = [[tileSize/2,-tileSize/2],[-tileSize/2,-tileSize/2]];
        
        intersection() {
        union() {
            zrot_copies(n=4)
                union() {
                    path_extrude2d(path_tile) 
                        polygon(full_tile_profile);
                    move([-tileSize/2,-tileSize/2])
                        rotate([0,0,45])
                            back(cornerOffset)
                                rotate([90,0,0])
                                    linear_extrude(cornerOffset*2) 
                                        polygon(full_tile_corners_profile);
                }
        } 
        cube([tileSize, tileSize, Tile_Thickness], anchor = BOT);
        }
    }
}
