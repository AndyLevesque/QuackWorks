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
- 2025-04-15
    - Tile stacking for ironing mode (vs. interface layer)
- 2025-04-25
    - Chamfer customization for each corner
    - Connector hole customization for each side
    - Fix to allow screw head inset of zero and screw head chamfer matching screw diameter
- 2025-04-27
    - Fix chamfers and connector hole options to initial orientation of MW
- 2025-06-06 - Fill Space
    - New ability to enter a larger space and max tile size and generate all tiles needed to fill available space
- 2025-07-12 (thanks mitufy!)
    - Screw positioning options
    - Formatting changes
- 2025-07-13 (thanks ColinCmabell!)
    - New ability to specify an adhesive mounting type which prints a solid bottom on the board 
- 2025-10-25 (thanks KYZ Design and sfcgeorge!)
    - Added openGrid Heavy option 
      - Like 2 openGrids back to back for rigidity in freestanding / side hung installations and double sided use
      - Original Heavy design by @KYZ Design on Makerworld https://makerworld.com/en/@KYZDesign
      - Implementation by sfcgeorge



Credit to 
    @David D on Printables for openGrid https://www.printables.com/@DavidD
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord https://handsonkatie.com/
    Pedro Leite for research and contributions on script performance improvements https://makerworld.com/en/@pedroleite
    mitufy for screw position options and formatting improvements

*/

include <BOSL2/std.scad>

/*[Board Size]*/
Board_Type = "Lite"; //[Standard, Lite, Heavy]
Board_Width = 2;
Board_Height = 2;

/*[Chamfer and Connector Options]*/
//Cosmetic Chamfers - If screw holes turned on, Chamfers will only be on the outside corners. 
Chamfers = "Corners"; //[Everywhere, Corners, None]
Chamfer_Top_Left = true;
Chamfer_Top_Right = true;
Chamfer_Bottom_Left = true;
Chamfer_Bottom_Right = true;
//Enable/Disable connector spaces to connect tiles together.
Connector_Holes = true;
Connector_Holes_Bottom = true;
Connector_Holes_Right = true;
Connector_Holes_Left = true;
Connector_Holes_Top = true;

/*[Screw Options]*/
//Screw holes for mounting -
Screw_Mounting = "Corners"; //[Everywhere, Corners, By Row and Column, Custom, None]
Screw_Every_X_Rows = 1;
Screw_Every_X_Columns = 2;
//Custom positions for screws, left to right, top to bottom. 1 = screw. Short Input defaults the rest to no screw.
Screw_Custom_Positions = "011110";

Screw_Thread_Diameter = 4.1;
Screw_Head_Diameter = 7.2;
Screw_Head_Inset = 1; //0.1
Screw_Head_Is_CounterSunk = true;
Screw_Head_CounterSunk_Degree = 90;

/*[Screw Cap Options]*/
//Generate caps to hide mounting holes after installation, enhancing the appearance of the board.
Add_Screw_Caps = false;
//When screw caps are enabled, Screw_Head_Inset increases automatically to accommodate the cap.
Screw_Cap_Thickness = 1; //0.1
Screw_Cap_Tolerance = 0.1; //0.01
//Flip and align caps to the top of the board, convenient when printing facing down.
Screw_Cap_Flip_For_Printing = false;

/*[Cutout Options]*/
//Use cutouts to further customize the shape of the board.
Add_Cutouts = false;
// Enter coordinates as [row-col,row-col], corresponding to the upper-left and lower-right corner of a rectangular cutout.
Cutout_Coordinates = "[2-1,2-2][4-3,5-6]";

/*[Adhesive Base Options]*/
//[Lite only] Adds a backing which allows you to adhere with double sided tape
Add_Adhesive_Base = false;
//0.6 allows space for a channel to fit into the board.
Adhesive_Base_Thickness = 0.6;

/*[Advanced - Tile Parameters]*/
//Customize tile sizes - openGrid standard is 28mm
Tile_Size = 28;
Tile_Thickness = 6.8;
Lite_Tile_Thickness = 4; //0.1
Heavy_Tile_Thickness = 13.8;
Heavy_Tile_Gap = 0.2; // Space between the two grid sides (prevents snaps from snagging)
/*[Tile Stacking]*/
//Stacking more than 6 tiles may time out. Desktop version recommended for larger stacks.
Stack_Count = 1;
//Use Interface Layer if you have a multimaterial printer or AMS to alternative PLA and PETG. Use Ironing for single-material printing and ironing of top-layer.
Stacking_Method = "Interface Layer"; //[Interface Layer, Ironing - BETA]
//Thickness of the interface between tiles. This is the distance between the top of the tile and the bottom of the next tile.
Interface_Thickness = 0.4;
//Distance between the interface and the tile. This is the distance between the top of the tile and the bottom of the interface. Try to use a multiple of the layer height when combined with the interface thickness.
Interface_Separation = 0.1;

/*[Beta - Fill Space]*/
Fill_Space_Mode = "None"; //[None, Complete Tiles Only, Fill Available Space]
Space_Width = 330;
Space_Depth = 500;
Max_Tile_Width = 8;
Max_Tile_Depth = 8;
Tile_Spacing = 5;

adjustedStackCount = Add_Adhesive_Base ? 1 : Stack_Count;
adjustedInterfaceThickness =
    Stacking_Method == "Interface Layer" ? Interface_Thickness : 0;
parsedCutoutCoordinates = Add_Cutouts ? parseCutoutCoordinates(Cutout_Coordinates) : [];
normalizedParsedCutoutBounds = [for (cutoutVector = parsedCutoutCoordinates) normalizedCutoutBounds(cutoutVector)];

if (Fill_Space_Mode == "Complete Tiles Only")
    FillSpaceFullTiles();
if (Fill_Space_Mode == "Fill Available Space")
    FillSpaceClipOneSide();

//GENERATE SINGLE TILES
if (Fill_Space_Mode == "None") {
    if (Board_Type == "Standard" && adjustedStackCount == 1) openGrid(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Add_Adhesive_Base=Add_Adhesive_Base, anchor=BOT, Connector_Holes=Connector_Holes);
    if (Board_Type == "Lite" && adjustedStackCount == 1) openGridLite(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Add_Adhesive_Base=Add_Adhesive_Base, anchor=BOT, Connector_Holes=Connector_Holes);
    if (Board_Type == "Heavy" && adjustedStackCount == 1) openGridHeavy(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT, Connector_Holes=Connector_Holes);

    //GENERATE STACKED TILES
    if (Board_Type == "Standard" && adjustedStackCount > 1) {
        zcopies(spacing=Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount, sp=[0, 0, Tile_Thickness])
            zflip()
                openGrid(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT, Connector_Holes=Connector_Holes);
        if (Stacking_Method == "Interface Layer")
            zcopies(spacing=Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount - 1, sp=[0, 0, Tile_Thickness + Interface_Separation])
                color("red") interfaceLayer(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Standard", anchor=BOT);
    }

    if (Board_Type == "Lite" && adjustedStackCount > 1) {
        zcopies(spacing=Lite_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount, sp=[0, 0, Lite_Tile_Thickness])
            openGridLite(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Connector_Holes=Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
        if (Stacking_Method == "Interface Layer")
            zcopies(spacing=Lite_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount - 1, sp=[0, 0, Lite_Tile_Thickness + Interface_Separation])
                color("red") interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Lite", topSide=$idx % 2 == 0 ? false : true);
    }

    if (Board_Type == "Heavy" && adjustedStackCount > 1) {
        zcopies(spacing=Heavy_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount, sp=[0, 0, Heavy_Tile_Thickness])
            openGridHeavy(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Connector_Holes=Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
        if (Stacking_Method == "Interface Layer")
            zcopies(spacing=Heavy_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount - 1, sp=[0, 0, Heavy_Tile_Thickness + Interface_Separation])
                color("red") interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Lite", topSide=$idx % 2 == 0 ? false : true);
    }
}

module interfaceLayer(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Chamfers = "None", Connector_Holes = false, anchor = CENTER, spin = 0, orient = UP, boardType = "Standard") {
    linear_extrude(height=Interface_Thickness)
        projection(cut=true)
            interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=tileSize, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType=boardType);
}

module interfaceLayer2D(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Chamfers = "None", Connector_Holes = false, anchor = CENTER, spin = 0, orient = UP, boardType = "Standard", topSide = false) {
    linear_extrude(height=Interface_Thickness)
        projection(cut=true)
        //bottom_half(z = 0.1, s = max(tileSize * Board_Width, tileSize * Board_Height) * 2)
        if (boardType == "Lite") {
            down(0.01)
                openGridLite(
                    Board_Width=Board_Width,
                    Board_Height=Board_Height,
                    tileSize=tileSize,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers,
                    Connector_Holes=Connector_Holes,
                    anchor=topSide ? BOT : TOP,
                    orient=topSide ? UP : DOWN
                );
        } else {
            openGrid(
                Board_Width=Board_Width,
                Board_Height=Board_Height,
                tileSize=tileSize,
                Tile_Thickness=Tile_Thickness,
                Screw_Mounting=Screw_Mounting,
                Chamfers=Chamfers,
                Connector_Holes=Connector_Holes,
                anchor=BOT
            );
        }
}
module openGridLite(Board_Width, Board_Height, tileSize = 28, Screw_Mounting = "None", Chamfers = "None", Add_Adhesive_Base = false, anchor = CENTER, spin = 0, orient = UP, Connector_Holes = false) {
    // Screw_Mounting options: [Everywhere, Corners, None]
    // Bevel options: [Everywhere, Corners, None]
    Tile_Thickness = 6.8;
    total_thickness = Lite_Tile_Thickness + (Add_Adhesive_Base ? Adhesive_Base_Thickness : 0);

    attachable(anchor, spin, orient, size=[Board_Width * tileSize, Board_Height * tileSize, total_thickness]) {
        render(convexity=2)
            down(Lite_Tile_Thickness / 2)
            union() {
                down(Tile_Thickness - Lite_Tile_Thickness)
                top_half(z=Tile_Thickness - Lite_Tile_Thickness, s=max(tileSize * Board_Width, tileSize * Board_Height) * 2)
                    openGrid(
                        Board_Width=Board_Width,
                        Board_Height=Board_Height,
                        tileSize=tileSize,
                        Screw_Mounting=Screw_Mounting,
                        Chamfers=Chamfers,
                        anchor=BOT,
                        Connector_Holes=Connector_Holes
                    );

                if (Add_Adhesive_Base) {
                    adhesiveBase(Board_Width, Board_Height, tileSize);
                }
            }
        children();
    }

    module adhesiveBase(Board_Width, Board_Height, tileSize = 28, anchor = CENTER, spin = 0, orient = UP) {
        attachable(anchor, spin, orient, size = [tileSize * Board_Width, tileSize * Board_Height, Adhesive_Base_Thickness]) {
            render(convexity=2)
                diff() {
                    cube([tileSize * Board_Width, tileSize * Board_Height, Adhesive_Base_Thickness], anchor=BOT, orient=DOWN);
                    down(Adhesive_Base_Thickness)
                    applyTileCornerModifications(Board_Width=Board_Width, Board_Height=Board_Height, Tile_Thickness=Adhesive_Base_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT);
                    down(Adhesive_Base_Thickness)
                    force_tag("remove")
                        for (cutoutVector = parsedCutoutCoordinates)
                            cutoutCuboid(cutoutVector, Board_Width=Board_Width, Board_Height=Board_Height, tileSize=tileSize, Tile_Thickness=total_thickness, Accurate_Side_Sweep=false);
                }

            children();
        }
    }
}

module openGridHeavy(Board_Width, Board_Height, tileSize = 28, Screw_Mounting = "None", Chamfers = "None", anchor = CENTER, spin = 0, orient = UP, Connector_Holes = false) {
    // Screw_Mounting options: [Everywhere, Corners, None]
    // Bevel options: [Everywhere, Corners, None]
    Tile_Thickness = 6.8;

    attachable(anchor, spin, orient, size=[Board_Width * tileSize, Board_Height * tileSize, Heavy_Tile_Thickness]) {
        render(convexity=4) union() {
            up(Heavy_Tile_Gap / 2)
                openGrid(
                    Board_Width=Board_Width,
                    Board_Height=Board_Height,
                    tileSize=tileSize,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers,
                    anchor=BOT,
                    Connector_Holes=Connector_Holes
                );
            down(Heavy_Tile_Gap / 2) linear_extrude(Heavy_Tile_Gap) projection(cut = true) 
                openGrid(
                    Board_Width=Board_Width,
                    Board_Height=Board_Height,
                    tileSize=tileSize,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers,
                    anchor=BOT,
                    Connector_Holes=false // a little faster
                );
            down(Heavy_Tile_Gap / 2)
                mirror([0, 0, 1]) openGrid(
                    Board_Width=Board_Width,
                    Board_Height=Board_Height,
                    tileSize=tileSize,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers,
                    anchor=BOT,
                    Connector_Holes=Connector_Holes
                );
        };
        children();
    }
}

module openGrid(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Chamfers = "None", Connector_Holes = false, anchor = CENTER, spin = 0, orient = UP) {
    //Screw_Mounting options: [Everywhere, Corners, None]
    //Bevel options: [Everywhere, Corners, None]

    $fn = 30;
    //2D is fast. 3D is slow. No benefits of 3D. 
    Render_Method = "2D"; //[3D, 2D]
    Tile_Thickness = Tile_Thickness;

    lite_cutout_distance_from_top = 1;
    connector_cutout_height = 2.4 + 0.01;

    attachable(anchor, spin, orient, size=[Board_Width * tileSize, Board_Height * tileSize, Tile_Thickness]) {

        down(Tile_Thickness / 2)
            render(convexity=2)
                diff() {
                    render() union() {
                            grid_copies(spacing=tileSize, n=[Board_Width, Board_Height])
                            if (Render_Method == "2D")
                                openGridTileAp1(tileSize=tileSize, Tile_Thickness=Tile_Thickness);
                            else
                                wonderboardTileAp2();
                        }

                    //TODO: Modularize positioning (Outside Corners, inside corners, inside all) and holes (chamfer and screw holes)
                    applyTileCornerModifications(Board_Width, Board_Height, tileSize, Tile_Thickness, Screw_Mounting, Chamfers, anchor);

                    if (Connector_Holes) {
                        //top and bottom connector holes
                        if (Board_Height > 1)
                            tag("remove")
                                up(Board_Type != "Lite" ? Tile_Thickness / 2 : Tile_Thickness - connector_cutout_height / 2 - lite_cutout_distance_from_top) {
                                    //bottom connector holes
                                    if (Connector_Holes_Right)
                                        for (rowIndex = [1:Board_Height - 1])
                                            if (!connectorHoleTouchesCutout("right", rowIndex, Board_Width, Board_Height))
                                                left(-tileSize * Board_Width / 2 - 0.005)
                                                    move([0, tileSize * (Board_Height / 2 - rowIndex), 0])
                                                        zrot(180)
                                                            connector_cutout_delete_tool(anchor=LEFT);
                                    //xflip_copy(offset = -tileSize*Board_Width/2-0.005)
                                    //top connector holes
                                    if (Connector_Holes_Left)
                                        for (rowIndex = [1:Board_Height - 1])
                                            if (!connectorHoleTouchesCutout("left", rowIndex, Board_Width, Board_Height))
                                                right(-tileSize * Board_Width / 2 - 0.005)
                                                    move([0, tileSize * (Board_Height / 2 - rowIndex), 0])
                                                        connector_cutout_delete_tool(anchor=LEFT);
                                }
                        //right and left connector holes
                        if (Board_Width > 1)
                            tag("remove")
                                up(Board_Type != "Lite" ? Tile_Thickness / 2 : Tile_Thickness - connector_cutout_height / 2 - lite_cutout_distance_from_top) {
                                    //right connector holes
                                    if (Connector_Holes_Top)
                                        for (columnIndex = [1:Board_Width - 1])
                                            if (!connectorHoleTouchesCutout("top", columnIndex, Board_Width, Board_Height))
                                                fwd(-tileSize * Board_Height / 2 - 0.005)
                                                    move([tileSize * (columnIndex - Board_Width / 2), 0, 0])
                                                        zrot(-90)
                                                            connector_cutout_delete_tool(anchor=LEFT);
                                    //yflip_copy(offset = -tileSize*Board_Height/2-0.005)
                                    //left connector holes
                                    if (Connector_Holes_Bottom)
                                        for (columnIndex = [1:Board_Width - 1])
                                            if (!connectorHoleTouchesCutout("bottom", columnIndex, Board_Width, Board_Height))
                                                back(-tileSize * Board_Height / 2 - 0.005)
                                                    move([tileSize * (columnIndex - Board_Width / 2), 0, 0])
                                                        zrot(90)
                                                            connector_cutout_delete_tool(anchor=LEFT);
                                }
                    }
                   force_tag("remove")up(0.01)
                        for (cutoutVector = parsedCutoutCoordinates)
                            cutoutCuboid(cutoutVector, Board_Width=Board_Width, Board_Height=Board_Height, tileSize=tileSize, Tile_Thickness=Tile_Thickness);
                }
        //end diff
        children();
    }
    //BEGIN CUTOUT TOOL
    module connector_cutout_delete_tool(anchor = CENTER, spin = 0, orient = UP) {
        //Begin connector cutout profile
        connector_cutout_radius = 2.6;
        connector_cutout_dimple_radius = 2.7;
        connector_cutout_separation = 2.5;
        connector_cutout_height = 2.4;
        dimple_radius = 0.75 / 2;

        attachable(anchor, spin, orient, size=[connector_cutout_radius * 2 - 0.1, connector_cutout_radius * 2, connector_cutout_height]) {
            //connector cutout tool
            tag_scope()
                translate([-connector_cutout_radius + 0.05, 0, -connector_cutout_height / 2])
                    render()
                        half_of(RIGHT, s=connector_cutout_dimple_radius * 4)
                            linear_extrude(height=connector_cutout_height)
                                union() {
                                    left(0.1)
                                        diff() {
                                            $fn = 50;
                                            //primary round pieces
                                            hull()
                                                xcopies(spacing=connector_cutout_radius * 2)
                                                    circle(r=connector_cutout_radius);
                                            //inset clip
                                            tag("remove")
                                                right(connector_cutout_radius - connector_cutout_separation)
                                                    ycopies(spacing=(connector_cutout_radius + connector_cutout_separation) * 2)
                                                        circle(r=connector_cutout_dimple_radius);
                                            //dimple (ass) to force seam. Only needed for positive connector piece (not delete tool)
                                            //tag("remove")
                                            //right(connector_cutout_radius*2 + 0.45 )//move dimple in or out
                                            //    yflip_copy(offset=(dimple_radius+connector_cutout_radius)/2)//both sides of the dimpme
                                            //        rect([1,dimple_radius+connector_cutout_radius], rounding=[0,-connector_cutout_radius,-dimple_radius,0], $fn=32); //rect with rounding of inner flare and outer smoothing
                                        }
                                    //outward flare fillet for easier insertion
                                    rect([1, connector_cutout_separation * 2 - (connector_cutout_dimple_radius - connector_cutout_separation)], rounding=[0, -.25, -.25, 0], $fn=32, corner_flip=true, anchor=LEFT);
                                }
            children();
        }
    }
    //END CUTOUT TOOL

    module openGridTileAp1(tileSize = 28, Tile_Thickness = 6.8) {
        Tile_Thickness = Tile_Thickness;

        Outside_Extrusion = 0.8;
        Inside_Grid_Top_Chamfer = 0.4;
        Inside_Grid_Middle_Chamfer = 1;
        Top_Capture_Initial_Inset = 2.4;
        Corner_Square_Thickness = 2.6;
        Intersection_Distance = 4.2;

        Tile_Inner_Size_Difference = 3;

        calculatedCornerSquare = sqrt(tileSize ^ 2 + tileSize ^ 2) - 2 * sqrt(Intersection_Distance ^ 2 / 2) - Intersection_Distance / 2;
        Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference; //25mm default
        insideExtrusion = (tileSize - Tile_Inner_Size) / 2 - Outside_Extrusion; //0.7 default
        middleDistance = Tile_Thickness - Top_Capture_Initial_Inset * 2;
        cornerChamfer = Top_Capture_Initial_Inset - Inside_Grid_Middle_Chamfer; //1.4 default

        CalculatedCornerChamfer = sqrt(Intersection_Distance ^ 2 / 2);
        cornerOffset = CalculatedCornerChamfer + Corner_Square_Thickness; //5.56985 (half of 11.1397)

        CorderSquareWidth = sqrt(Corner_Square_Thickness ^ 2 + Corner_Square_Thickness ^ 2) + Intersection_Distance;


        full_tile_profile = Board_Type == "Heavy" ? [
            [0, 0],
            [Outside_Extrusion, 0],
            [Outside_Extrusion, Tile_Thickness - Top_Capture_Initial_Inset],
            [Outside_Extrusion + insideExtrusion, Tile_Thickness - Top_Capture_Initial_Inset + Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion + insideExtrusion, Tile_Thickness - Inside_Grid_Top_Chamfer],
            [Outside_Extrusion + insideExtrusion - Inside_Grid_Top_Chamfer, Tile_Thickness],
            [0, Tile_Thickness],
        ] : [
            [0, 0],
            [Outside_Extrusion + insideExtrusion - Inside_Grid_Top_Chamfer, 0],
            [Outside_Extrusion + insideExtrusion, Inside_Grid_Top_Chamfer],
            [Outside_Extrusion + insideExtrusion, Top_Capture_Initial_Inset - Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion, Top_Capture_Initial_Inset],
            [Outside_Extrusion, Tile_Thickness - Top_Capture_Initial_Inset],
            [Outside_Extrusion + insideExtrusion, Tile_Thickness - Top_Capture_Initial_Inset + Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion + insideExtrusion, Tile_Thickness - Inside_Grid_Top_Chamfer],
            [Outside_Extrusion + insideExtrusion - Inside_Grid_Top_Chamfer, Tile_Thickness],
            [0, Tile_Thickness],
        ];

        full_tile_corners_profile = [
            [0, 0],
            [cornerOffset - cornerChamfer, 0],
            [cornerOffset, cornerChamfer],
            [cornerOffset, Tile_Thickness - cornerChamfer],
            [cornerOffset - cornerChamfer, Tile_Thickness],
            [0, Tile_Thickness],
        ];

        path_tile = [[tileSize / 2, -tileSize / 2], [-tileSize / 2, -tileSize / 2]];

        intersection() {
            union() {
                zrot_copies(n=4)
                    union() {
                        path_extrude2d(path_tile)
                            polygon(full_tile_profile);
                        move([-tileSize / 2, -tileSize / 2])
                            rotate([0, 0, 45])
                                back(cornerOffset)
                                    rotate([90, 0, 0])
                                        linear_extrude(cornerOffset * 2)
                                            polygon(full_tile_corners_profile);
                    }
            }
            cube([tileSize, tileSize, Tile_Thickness], anchor=BOT);
        }
    }
}

module applyTileCornerModifications(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Chamfers = "None", anchor = CENTER) {
    Intersection_Distance = 4.2;
    tileChamfer = sqrt(Intersection_Distance ^ 2 * 2);

    cornerChamfers = concat(
        Chamfer_Bottom_Right ? [[tileSize * Board_Width / 2, -tileSize * Board_Height / 2, 0]] : [],
        Chamfer_Top_Right ? [[tileSize * Board_Width / 2, tileSize * Board_Height / 2, 0]] : [],
        Chamfer_Bottom_Left ? [[-tileSize * Board_Width / 2, -tileSize * Board_Height / 2, 0]] : [],
        Chamfer_Top_Left ? [[-tileSize * Board_Width / 2, tileSize * Board_Height / 2, 0]] : []
    );

    //TODO: Modularize positioning (Outside Corners, inside corners, inside all) and holes (chamfer and screw holes)
    //Bevel Everywhere
    if (Chamfers == "Everywhere" && Screw_Mounting != "Everywhere" && Screw_Mounting != "Corners")
        tag("remove")
            grid_copies(spacing=tileSize, size=[Board_Width * tileSize, Board_Height * tileSize])
                down(0.01)
                    zrot(45)
                        cuboid([tileChamfer, tileChamfer, Tile_Thickness + 0.02], anchor=BOT);
    //Bevel Corners
    if (Chamfers == "Corners" || (Chamfers == "Everywhere" && (Screw_Mounting == "Everywhere" || Screw_Mounting == "Corners")))
        tag("remove")
            move_copies(
                cornerChamfers
                //[
                //[tileSize*Board_Width/2,tileSize*Board_Height/2,0],
                //[-tileSize*Board_Width/2,tileSize*Board_Height/2,0],
                //[tileSize*Board_Width/2,-tileSize*Board_Height/2,0],
                //[-tileSize*Board_Width/2,-tileSize*Board_Height/2,0]
                //]
            )
                down(0.01)
                    zrot(45)
                        cuboid([tileChamfer, tileChamfer, Tile_Thickness + 0.02], anchor=BOT);
    module place_screw_hole(columnIndex, rowIndex) {
        if (!screwHoleTouchesCutout(rowIndex, columnIndex))
            move_copies([[tileSize * (columnIndex - Board_Width / 2), tileSize * (Board_Height / 2 - rowIndex), 0]])
                screw_hole();
    }
    //Screw Mount Corners
    if (Screw_Mounting == "Corners")
        for (rowIndex = [1, Board_Height - 1])
            for (columnIndex = [1, Board_Width - 1])
                place_screw_hole(columnIndex, rowIndex);
    //Screw Mount Everywhere
    if (Screw_Mounting == "Everywhere")
        for (rowIndex = [1:Board_Height - 1])
            for (columnIndex = [1:Board_Width - 1])
                place_screw_hole(columnIndex, rowIndex);
    if (Screw_Mounting == "By Row and Column")
        for (rowIndex = centeredScrewIndices(Board_Height, Screw_Every_X_Rows))
            for (columnIndex = centeredScrewIndices(Board_Width, Screw_Every_X_Columns))
                place_screw_hole(columnIndex, rowIndex);
    if (Screw_Mounting == "Custom") {
        for (i = [0:min(len(Screw_Custom_Positions), (Board_Width - 1) * (Board_Height - 1)) - 1]) {
            if (Screw_Custom_Positions[i] == "1")
                place_screw_hole(1 + (i % (Board_Width - 1)), 1 + floor(i / (Board_Width - 1)));
        }
    }
    module screw_hole() {
        Screw_Cap_Middle_Thinning= 0.6;
        Final_Screw_Head_Inset = max(0.01,(Add_Screw_Caps && Screw_Cap_Thickness > 0 && Stack_Count == 1 && Board_Type != "Heavy" ? max(0 , Screw_Cap_Thickness) + Screw_Head_Inset : Screw_Head_Inset));
        //idea for screw hole caps comes from Gavin F
        if (Add_Screw_Caps && Screw_Cap_Thickness > 0 && Stack_Count == 1 && Board_Type != "Heavy" && !Add_Adhesive_Base) {
            Screw_Cap_Z_Offset =
                Screw_Cap_Flip_For_Printing ? Tile_Thickness
                : Board_Type == "Lite" ? Tile_Thickness - Lite_Tile_Thickness
                : 0;
            tag_diff(tag="keep",remove="remove")
                right(tileSize / 2) fwd(tileSize / 2) 
                    up(Screw_Cap_Z_Offset) xrot(Screw_Cap_Flip_For_Printing?180:0)
                            tag("")cyl(l=Screw_Cap_Thickness, d=Screw_Head_Diameter - Screw_Cap_Tolerance, $fn=64,anchor=BOTTOM)
                            if(Screw_Cap_Middle_Thinning > 0)
                                attach(TOP,TOP,inside=true)
                                    tag("remove")cyl(l=Screw_Cap_Middle_Thinning, d=3, $fn=64);
        }
        if(Screw_Head_Diameter > 0)
            tag("remove")
                up(Tile_Thickness + 0.01)
                    cyl(d=Screw_Head_Diameter, h=Final_Screw_Head_Inset, anchor=TOP, $fn=64) 
                        if(Screw_Thread_Diameter > 0)
                            up(0.005) attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Thread_Diameter, h=Screw_Head_Is_CounterSunk ? min(100, max(0.01, tan((180 - Screw_Head_CounterSunk_Degree) / 2) * (Screw_Head_Diameter - Screw_Thread_Diameter) / 2)) : 0.01, $fn=64)
                                    attach(BOT, TOP) cyl(d=Screw_Thread_Diameter, h=Tile_Thickness + 0.02, $fn=64);
    }
  children();
}


module FillSpaceFullTiles() {
    // === Derived tile space ===
    Total_Grid_Width = floor(Space_Width / Tile_Size);
    Total_Grid_Depth = floor(Space_Depth / Tile_Size);

    // === Max tile counts ===
    Max_Tiles_Wide = floor(Total_Grid_Width / Max_Tile_Width);
    Max_Tiles_Deep = floor(Total_Grid_Depth / Max_Tile_Depth);

    // === Remaining grid spaces ===
    Remaining_Width = Total_Grid_Width - (Max_Tiles_Wide * Max_Tile_Width);
    Remaining_Depth = Total_Grid_Depth - (Max_Tiles_Deep * Max_Tile_Depth);

    // === Output for debugging ===
    echo("Grid Width (tiles):", Total_Grid_Width);
    echo("Grid Depth (tiles):", Total_Grid_Depth);
    echo("Max Tiles Wide:", Max_Tiles_Wide);
    echo("Max Tiles Deep:", Max_Tiles_Deep);
    echo("Remaining Width (tiles):", Remaining_Width);
    echo("Remaining Depth (tiles):", Remaining_Depth);
    spacing_x = Tile_Size + Tile_Spacing;
    spacing_y = Tile_Size + Tile_Spacing;

    // === Tile placement function ===
    module place_tile(x, y, w, h) {
        translate([x * spacing_x, y * spacing_y, 0]) if (Board_Type == "Standard")
            openGrid(
                Board_Width=w, Board_Height=h,
                tileSize=Tile_Size,
                Tile_Thickness=Tile_Thickness,
                Screw_Mounting=Screw_Mounting,
                Chamfers=Chamfers, anchor=BOT,
                Connector_Holes=Connector_Holes
            );
        else if (Board_Type == "Heavy")
            openGridHeavy(
                Board_Width=w, Board_Height=h,
                tileSize=Tile_Size,
                Screw_Mounting=Screw_Mounting,
                Chamfers=Chamfers, anchor=BOT,
                Connector_Holes=Connector_Holes
            );
        else
            openGridLite(
                Board_Width=w,
                Board_Height=h,
                tileSize=Tile_Size,
                Screw_Mounting=Screw_Mounting,
                Chamfers=Chamfers, anchor=BOT,
                Connector_Holes=Connector_Holes
            );
    }

    // === Main grid of full max-size tiles ===
    for (x = [0:Max_Tile_Width:Max_Tile_Width * (Max_Tiles_Wide - 1)])
        for (y = [0:Max_Tile_Depth:Max_Tile_Depth * (Max_Tiles_Deep - 1)])
            place_tile(x, y, Max_Tile_Width, Max_Tile_Depth);

    // === Right edge: fill remaining width with a full-height tile
    if (Remaining_Width > 0)
        for (y = [0:Max_Tile_Depth:Max_Tile_Depth * (Max_Tiles_Deep - 1)])
            place_tile(Max_Tile_Width * Max_Tiles_Wide, y, Remaining_Width, Max_Tile_Depth);

    // === Bottom edge: fill remaining height with a full-width tile
    if (Remaining_Depth > 0)
        for (x = [0:Max_Tile_Width:Max_Tile_Width * (Max_Tiles_Wide - 1)])
            place_tile(x, Max_Tile_Depth * Max_Tiles_Deep, Max_Tile_Width, Remaining_Depth);

    // === Bottom-right corner: one tile for remaining width and height
    if (Remaining_Width > 0 && Remaining_Depth > 0)
        place_tile(Max_Tile_Width * Max_Tiles_Wide, Max_Tile_Depth * Max_Tiles_Deep, Remaining_Width, Remaining_Depth);
}

module FillSpaceClipOneSide() {
    /* — 1) Compute each full 8×8 tile’s size in pure millimeters (no spacing) — */
    full_tile_width_mm = Max_Tile_Width * Tile_Size; // 8 × 28 = 224 mm
    full_tile_depth_mm = Max_Tile_Depth * Tile_Size; // 8 × 28 = 224 mm

    /* — 2) Determine how many full‐width columns fit — */
    num_full_cols = floor(Space_Width / full_tile_width_mm);
    // leftover width (in mm) beyond full columns
    rem_width_mm = Space_Width - (num_full_cols * full_tile_width_mm);
    // If any leftover > 0, we’ll need one extra (clipped) column:
    num_cols = num_full_cols + (rem_width_mm > 0 ? 1 : 0);

    /* — 3) Determine how many full‐depth rows fit — */
    num_full_rows = floor(Space_Depth / full_tile_depth_mm);
    // leftover depth (in mm) beyond full rows
    rem_depth_mm = Space_Depth - (num_full_rows * full_tile_depth_mm);
    // If any leftover > 0, we’ll need one extra (clipped) row:
    num_rows = num_full_rows + (rem_depth_mm > 0 ? 1 : 0);

    /* — 4) Build lists of X and Y origins (in mm) for each column/row —
    //     Each origin = (i * full_tile_width_mm) + (i * Tile_Spacing)
    //     so that the 5 mm gap is only used when positioning, not in count. — */
    X_origins = [
        for (i = [0:num_cols - 1]) (i * full_tile_width_mm) + (i * Tile_Spacing),
    ];
    Y_origins = [
        for (j = [0:num_rows - 1]) (j * full_tile_depth_mm) + (j * Tile_Spacing),
    ];

    /* — 5) Debug echoes to verify calculation — */
    echo("Drawer interior (mm):", Space_Width, "×", Space_Depth);
    echo("Full‐tile size  (mm):", full_tile_width_mm, "×", full_tile_depth_mm);
    echo("num_full_cols, rem_width_mm:", num_full_cols, ",", rem_width_mm);
    echo("num_cols total (incl. clipped):", num_cols, "→ X_origins:", X_origins);
    echo("num_full_rows, rem_depth_mm:", num_full_rows, ",", rem_depth_mm);
    echo("num_rows total (incl. clipped):", num_rows, "→ Y_origins:", Y_origins);

    /* — 6) Module: place a full 8×8 tile at bottom‐left = (x_mm, y_mm),
        then clip it to the drawer bounds. openGrid(8,8) is centered,
        so we shift its center to (x_mm + half_w, y_mm + half_d). — */
    module place_centered_and_clipped(x_mm, y_mm) {
        // Half‐dimensions of an 8×8 tile (because openGrid is centered)
        half_w = full_tile_width_mm / 2; // 224/2 = 112 mm
        half_d = full_tile_depth_mm / 2; // 224/2 = 112 mm

        // Center point for openGrid:
        cx = x_mm + half_w;
        cy = y_mm + half_d;

        // Naive extents (before clipping)
        x0 = cx - half_w; // = x_mm
        x1 = cx + half_w; // = x_mm + full_tile_width_mm
        y0 = cy - half_d; // = y_mm
        y1 = cy + half_d; // = y_mm + full_tile_depth_mm

        // Clipped extents:
        clipped_x0 = max(x0, 0);
        clipped_x1 = min(x1, Space_Width);
        clipped_y0 = max(y0, 0);
        clipped_y1 = min(y1, Space_Depth);

        // Intersection: drawer cube ∩ translated, centered openGrid(8,8)
        intersection() {
            cube([Space_Width + num_full_cols * Tile_Spacing, Space_Depth + num_full_rows * Tile_Spacing, Heavy_Tile_Thickness + 1], center=false);
            translate([cx, cy, 0]) if (Board_Type == "Standard")
                openGrid(
                    Board_Width=Max_Tile_Width,
                    Board_Height=Max_Tile_Depth,
                    tileSize=Tile_Size,
                    Tile_Thickness=Tile_Thickness,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers, anchor=BOT,
                    Connector_Holes=Connector_Holes
                );
            else if (Board_Type == "Heavy")
                openGridHeavy(
                    Board_Width=Max_Tile_Width,
                    Board_Height=Max_Tile_Depth,
                    tileSize=Tile_Size,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers, anchor=BOT,
                    Connector_Holes=Connector_Holes
                );
            else {
                openGridLite(
                    Board_Width=Max_Tile_Width,
                    Board_Height=Max_Tile_Depth,
                    tileSize=Tile_Size,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers, anchor=BOT,
                    Connector_Holes=Connector_Holes
                );
            }
        }
    }

    /* — 7) Place every column × row of 8×8 modules — */
    for (ci = [0:num_cols - 1]) {
        x_base = X_origins[ci];
        for (rj = [0:num_rows - 1]) {
            y_base = Y_origins[rj];
            place_centered_and_clipped(x_base, y_base);
        }
    }
}

function _parsePositiveInteger(numberString, index = 0, value = 0) =
    index >= len(numberString) ? value
    : _parsePositiveInteger(
        numberString,
        index + 1,
        value * 10 + ord(numberString[index]) - ord("0")
    );

function _extractNumbersFromString(input, index = 0, current = "", numbers = []) =
    index >= len(input) ? (len(current) > 0 ? concat(numbers, [_parsePositiveInteger(current)]) : numbers)
    : ord(input[index]) >= ord("0") && ord(input[index]) <= ord("9") ? _extractNumbersFromString(input, index + 1, str(current, input[index]), numbers)
    : _extractNumbersFromString(
        input,
        index + 1,
        "",
        len(current) > 0 ? concat(numbers, [_parsePositiveInteger(current)]) : numbers
    );

function parseCutoutCoordinates(input) =
    !is_string(input) || len(input) == 0 ? []
    : let (numbers = _extractNumbersFromString(input)) [for (i = [0:4:len(numbers) - 4]) [numbers[i], numbers[i + 1], numbers[i + 2], numbers[i + 3]]];

function normalizedCutoutBounds(cutoutVector) =
    len(cutoutVector) == 4
        ? [
            min(cutoutVector[0], cutoutVector[2]),
            max(cutoutVector[0], cutoutVector[2]),
            min(cutoutVector[1], cutoutVector[3]),
            max(cutoutVector[1], cutoutVector[3])
        ]
        : [];

function screwHoleTouchesCutout(rowIndex, columnIndex, cutouts = normalizedParsedCutoutBounds, cutoutIndex = 0) =
    cutoutIndex >= len(cutouts)
        ? false
        : let(bounds = cutouts[cutoutIndex])
            (
                len(bounds) == 4
                && rowIndex >= bounds[0] - 1
                && rowIndex <= bounds[1]
                && columnIndex >= bounds[2] - 1
                && columnIndex <= bounds[3]
                && !(
                    (rowIndex == bounds[0] - 1 || rowIndex == bounds[1])
                    && (columnIndex == bounds[2] - 1 || columnIndex == bounds[3])
                )
            )
            || screwHoleTouchesCutout(rowIndex, columnIndex, cutouts, cutoutIndex + 1);

function connectorHoleTouchesCutout(side, seamIndex, boardWidth, boardHeight, cutouts = normalizedParsedCutoutBounds, cutoutIndex = 0) =
    cutoutIndex >= len(cutouts)
        ? false
        : let(bounds = cutouts[cutoutIndex])
            (
                len(bounds) == 4
                && (
                    (side == "left"
                        && bounds[2] <= 1
                        && (
                            (bounds[2] < 1 && seamIndex >= bounds[0] - 1 && seamIndex <= bounds[1])
                            || (bounds[2] == 1 && seamIndex > bounds[0] - 1 && seamIndex < bounds[1])
                        )
                    )
                    || (side == "right"
                        && bounds[3] >= boardWidth
                        && (
                            (bounds[3] > boardWidth && seamIndex >= bounds[0] - 1 && seamIndex <= bounds[1])
                            || (bounds[3] == boardWidth && seamIndex > bounds[0] - 1 && seamIndex < bounds[1])
                        )
                    )
                    || (side == "top"
                        && bounds[0] <= 1
                        && (
                            (bounds[0] < 1 && seamIndex >= bounds[2] - 1 && seamIndex <= bounds[3])
                            || (bounds[0] == 1 && seamIndex > bounds[2] - 1 && seamIndex < bounds[3])
                        )
                    )
                    || (side == "bottom"
                        && bounds[1] >= boardHeight
                        && (
                            (bounds[1] > boardHeight && seamIndex >= bounds[2] - 1 && seamIndex <= bounds[3])
                            || (bounds[1] == boardHeight && seamIndex > bounds[2] - 1 && seamIndex < bounds[3])
                        )
                    )
                )
            )
            || connectorHoleTouchesCutout(side, seamIndex, boardWidth, boardHeight, cutouts, cutoutIndex + 1);

function centeredScrewIndices(boardSpan, step) =
    let(
        clampedStep = max(1, step),
        count = max(0, floor((boardSpan - 2) / clampedStep) + 1),
        startIndex = boardSpan / 2 + ((((boardSpan - 2) % clampedStep) % 2 == 0) ? 0 : -0.5) - (count - 1) * clampedStep / 2
    )
        [for (i = [0:count - 1]) startIndex + i * clampedStep];

module cutoutCuboid(cutoutVector, Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Accurate_Side_Sweep=true) {
    if (len(cutoutVector) == 4)
        let (
            rowStart = min(cutoutVector[0], cutoutVector[2]),
            rowEnd = max(cutoutVector[0], cutoutVector[2]),
            columnStart = min(cutoutVector[1], cutoutVector[3]),
            columnEnd = max(cutoutVector[1], cutoutVector[3]),
            totalCutoutWidth = (columnEnd - columnStart + 1) * tileSize,
            totalCutoutHeight = (rowEnd - rowStart + 1) * tileSize,
            cutoutCenterX = (columnStart + columnEnd - Board_Width - 1) * tileSize / 2,
            cutoutCenterY = (Board_Height + 1 - rowStart - rowEnd) * tileSize / 2,
            Outside_Extrusion = 0.8,
            Inside_Grid_Top_Chamfer = 0.4,
            Inside_Grid_Middle_Chamfer = 1,
            Top_Capture_Initial_Inset = 2.4,
            Tile_Inner_Size_Difference = 3,
            Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference,
            insideExtrusion = (tileSize - Tile_Inner_Size) / 2 - Outside_Extrusion,
            fullTileProfile =
                Board_Type == "Heavy" ? [
                    [0, 0],
                    [Outside_Extrusion, 0],
                    [Outside_Extrusion, Tile_Thickness - Top_Capture_Initial_Inset],
                    [Outside_Extrusion + insideExtrusion, Tile_Thickness - Top_Capture_Initial_Inset + Inside_Grid_Middle_Chamfer],
                    [Outside_Extrusion + insideExtrusion, Tile_Thickness - Inside_Grid_Top_Chamfer],
                    [Outside_Extrusion + insideExtrusion - Inside_Grid_Top_Chamfer, Tile_Thickness],
                    [0, Tile_Thickness],
                ] : [
                    [0, 0],
                    [Outside_Extrusion + insideExtrusion - Inside_Grid_Top_Chamfer, 0],
                    [Outside_Extrusion + insideExtrusion, Inside_Grid_Top_Chamfer],
                    [Outside_Extrusion + insideExtrusion, Top_Capture_Initial_Inset - Inside_Grid_Middle_Chamfer],
                    [Outside_Extrusion, Top_Capture_Initial_Inset],
                    [Outside_Extrusion, Tile_Thickness - Top_Capture_Initial_Inset],
                    [Outside_Extrusion + insideExtrusion, Tile_Thickness - Top_Capture_Initial_Inset + Inside_Grid_Middle_Chamfer],
                    [Outside_Extrusion + insideExtrusion, Tile_Thickness - Inside_Grid_Top_Chamfer],
                    [Outside_Extrusion + insideExtrusion - Inside_Grid_Top_Chamfer, Tile_Thickness],
                    [0, Tile_Thickness],
                ],
            profileDepth = max([for (point = fullTileProfile) point[0]]),
            negativeProfile = concat(fullTileProfile, [[profileDepth, Tile_Thickness], [profileDepth, 0]]),
            innerCutoutWidth = max(0.01, totalCutoutWidth - profileDepth * 2),
            innerCutoutHeight = max(0.01, totalCutoutHeight -profileDepth * 2),
            cornerCutoutOffset= 0.7,
            cornerCutoutFiller=(2.7 + 1 / sqrt(2)) * sqrt(2) + profileDepth,
        ){
            move([cutoutCenterX, cutoutCenterY, -0.01])
                diff("rm0"){
                    cuboid([innerCutoutWidth, innerCutoutHeight, Tile_Thickness + 0.02], anchor=BOT)
                        tag("rm0")
                            edge_profile(["Z"])
                            fwd(cornerCutoutOffset)left(cornerCutoutOffset)
                                mask2d_chamfer(x=cornerCutoutFiller);
                    if(Accurate_Side_Sweep)
                        force_tag("") {
                            for (side = [
                                [-totalCutoutWidth / 2, 0, 0, innerCutoutHeight],
                                [totalCutoutWidth / 2, 0, 180, innerCutoutHeight],
                                [0, totalCutoutHeight / 2, -90, innerCutoutWidth],
                                [0, -totalCutoutHeight / 2, 90, innerCutoutWidth]
                            ])
                                translate([side[0], side[1], 0])
                                    zrot(side[2])
                                        rotate([90, 0, 0])
                                            linear_extrude(height=side[3], center=true)
                                                polygon(negativeProfile);
                        }
                }
        }
}
