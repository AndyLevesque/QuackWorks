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
Full_or_Lite = "Lite"; //[Full, Lite, Heavy]
Board_Width = 2;
Board_Height = 2;

/*[Chamfer and Connector Options]*/
//Cosmetic Chamfers
Chamfers = "Corners"; //[Everywhere, Border Only, Non-Border Only, Corners, None]
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

Screw_Diameter = 4.1;
Screw_Head_Diameter = 7.2;
Screw_Head_Inset = 1;
Screw_Head_Is_CounterSunk = true;
Screw_Head_CounterSunk_Degree = 90;

// Optional backside screw head cut
Backside_Screw_Hole = false;
Backside_Screw_Head_Diameter_Shrink = 0.0; // amount subtracted from Screw_Head_Diameter on the back side
Backside_Screw_Head_Inset = Screw_Head_Inset;
Backside_Screw_Head_Is_CounterSunk = Screw_Head_Is_CounterSunk;
Backside_Screw_Head_CounterSunk_Degree = Screw_Head_CounterSunk_Degree;

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

function og_node_pos(ix, iy, bw, bh, tileSize) = [
    -tileSize * bw / 2 + ix * tileSize,
     tileSize * bh / 2 - iy * tileSize,
    0
];

function og_point_in_list(p, pts) =
    len([for (q = pts) if (q[0] == p[0] && q[1] == p[1]) 1]) > 0;

function og_copy_coords(size, spacing, offset = 0) =
    size < 0 ? [] :
    let(
        n = floor(size / spacing) + 1,
        start = -((n - 1) * spacing) / 2 + offset
    )
    [for (i = [0:n - 1]) start + i * spacing];

function og_chamfer_allowed_at(ix, iy, bw, bh) =
    (ix == 0  && iy == 0 ) ? Chamfer_Top_Left :
    (ix == bw && iy == 0 ) ? Chamfer_Top_Right :
    (ix == 0  && iy == bh) ? Chamfer_Bottom_Left :
    (ix == bw && iy == bh) ? Chamfer_Bottom_Right :
    true;

if (Fill_Space_Mode == "Complete Tiles Only")
    FillSpaceFullTiles();
if (Fill_Space_Mode == "Fill Available Space")
    FillSpaceClipOneSide();

//GENERATE SINGLE TILES
if (Fill_Space_Mode == "None") {
    if (Full_or_Lite == "Full" && adjustedStackCount == 1)
        openGrid(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Add_Adhesive_Base=Add_Adhesive_Base, anchor=BOT, Connector_Holes=Connector_Holes);

    if (Full_or_Lite == "Lite" && adjustedStackCount == 1)
        openGridLite(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Add_Adhesive_Base=Add_Adhesive_Base, anchor=BOT, Connector_Holes=Connector_Holes);

    if (Full_or_Lite == "Heavy" && adjustedStackCount == 1)
        openGridHeavy(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT, Connector_Holes=Connector_Holes);

    //GENERATE STACKED TILES
    if (Full_or_Lite == "Full" && adjustedStackCount > 1) {
        zcopies(spacing=Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount, sp=[0, 0, Tile_Thickness])
            zflip()
                openGrid(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT, Connector_Holes=Connector_Holes);
        if (Stacking_Method == "Interface Layer")
            zcopies(spacing=Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount - 1, sp=[0, 0, Tile_Thickness + Interface_Separation])
                color("red") interfaceLayer(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Full", anchor=BOT);
    }

    if (Full_or_Lite == "Lite" && adjustedStackCount > 1) {
        zcopies(spacing=Lite_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount, sp=[0, 0, Lite_Tile_Thickness])
            openGridLite(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Connector_Holes=Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
        if (Stacking_Method == "Interface Layer")
            zcopies(spacing=Lite_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount - 1, sp=[0, 0, Lite_Tile_Thickness + Interface_Separation])
                color("red") interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Lite", topSide=$idx % 2 == 0 ? false : true);
    }

    if (Full_or_Lite == "Heavy" && adjustedStackCount > 1) {
        zcopies(spacing=Heavy_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount, sp=[0, 0, Heavy_Tile_Thickness])
            openGridHeavy(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Connector_Holes=Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
        if (Stacking_Method == "Interface Layer")
            zcopies(spacing=Heavy_Tile_Thickness + adjustedInterfaceThickness + 2 * Interface_Separation, n=adjustedStackCount - 1, sp=[0, 0, Heavy_Tile_Thickness + Interface_Separation])
                color("red") interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Lite", topSide=$idx % 2 == 0 ? false : true);
    }
}

module interfaceLayer(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Chamfers = "None", Connector_Holes = false, anchor = CENTER, spin = 0, orient = UP, boardType = "Full") {
    linear_extrude(height=Interface_Thickness)
        projection(cut=true)
            interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=tileSize, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType=boardType);
}

module interfaceLayer2D(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Chamfers = "None", Connector_Holes = false, anchor = CENTER, spin = 0, orient = UP, boardType = "Full", topSide = false) {
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
                    applyTileCornerModifications(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=tileSize, Tile_Thickness=Adhesive_Base_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT);
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

                    applyTileCornerModifications(Board_Width, Board_Height, tileSize, Tile_Thickness, Screw_Mounting, Chamfers, anchor);

                    if (Connector_Holes) {
                        //top and bottom connector holes
                        if (Board_Height > 1)
                            tag("remove")
                                up(Full_or_Lite != "Lite" ? Tile_Thickness / 2 : Tile_Thickness - connector_cutout_height / 2 - lite_cutout_distance_from_top) {
                                    //bottom connector holes
                                    if (Connector_Holes_Right && Chamfers != "Everywhere" && Chamfers != "Border Only")
                                        left(-tileSize * Board_Width / 2 - 0.005)
                                            zrot(180)
                                                ycopies(spacing=tileSize, l=Board_Height > 2 ? Board_Height * tileSize - tileSize * 2 : Board_Height * tileSize - tileSize - 1)
                                                    connector_cutout_delete_tool(anchor=LEFT);

                                    //top connector holes
                                    if (Connector_Holes_Left && Chamfers != "Everywhere" && Chamfers != "Border Only")
                                        right(-tileSize * Board_Width / 2 - 0.005)
                                            ycopies(spacing=tileSize, l=Board_Height > 2 ? Board_Height * tileSize - tileSize * 2 : Board_Height * tileSize - tileSize - 1)
                                                connector_cutout_delete_tool(anchor=LEFT);
                                }

                        //right and left connector holes
                        if (Board_Width > 1)
                            tag("remove")
                                up(Full_or_Lite != "Lite" ? Tile_Thickness / 2 : Tile_Thickness - connector_cutout_height / 2 - lite_cutout_distance_from_top) {
                                    //right connector holes
                                    if (Connector_Holes_Top && Chamfers != "Everywhere" && Chamfers != "Border Only")
                                        fwd(-tileSize * Board_Height / 2 - 0.005)
                                            xcopies(spacing=tileSize, l=Board_Width > 2 ? Board_Width * tileSize - tileSize * 2 : Board_Width * tileSize - tileSize - 1)
                                                zrot(-90)
                                                    connector_cutout_delete_tool(anchor=LEFT);

                                    //left connector holes
                                    if (Connector_Holes_Bottom && Chamfers != "Everywhere" && Chamfers != "Border Only")
                                        back(-tileSize * Board_Height / 2 - 0.005)
                                            xcopies(spacing=tileSize, l=Board_Width > 2 ? Board_Width * tileSize - tileSize * 2 : Board_Width * tileSize - tileSize - 1)
                                                zrot(90)
                                                    connector_cutout_delete_tool(anchor=LEFT);
                                }
                    }
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

        full_tile_profile = Full_or_Lite == "Heavy" ? [
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

    cornerChamferPositions = concat(
        Chamfer_Bottom_Right ? [og_node_pos(Board_Width, Board_Height, Board_Width, Board_Height, tileSize)] : [],
        Chamfer_Top_Right ? [og_node_pos(Board_Width, 0, Board_Width, Board_Height, tileSize)] : [],
        Chamfer_Bottom_Left ? [og_node_pos(0, Board_Height, Board_Width, Board_Height, tileSize)] : [],
        Chamfer_Top_Left ? [og_node_pos(0, 0, Board_Width, Board_Height, tileSize)] : []
    );

    step_cols = max(1, Screw_Every_X_Columns);
    step_rows = max(1, Screw_Every_X_Rows);

    byrow_xs = og_copy_coords(
        (Board_Width - 2) * tileSize,
        tileSize * step_cols,
        ((Board_Width - 2) % step_cols) % 2 == 0 ? 0 : -tileSize / 2
    );

    byrow_ys = og_copy_coords(
        (Board_Height - 2) * tileSize,
        tileSize * step_rows,
        ((Board_Height - 2) % step_rows) % 2 == 0 ? 0 : tileSize / 2
    );

    screwPositions =
        Screw_Mounting == "Corners"
            ? (
                Board_Width > 1 && Board_Height > 1
                    ? [
                        og_node_pos(1, 1, Board_Width, Board_Height, tileSize),
                        og_node_pos(Board_Width - 1, 1, Board_Width, Board_Height, tileSize),
                        og_node_pos(1, Board_Height - 1, Board_Width, Board_Height, tileSize),
                        og_node_pos(Board_Width - 1, Board_Height - 1, Board_Width, Board_Height, tileSize)
                    ]
                    : []
            )
        : Screw_Mounting == "Everywhere"
            ? [for (ix = [1:Board_Width - 1], iy = [1:Board_Height - 1]) og_node_pos(ix, iy, Board_Width, Board_Height, tileSize)]
        : Screw_Mounting == "By Row and Column"
            ? [for (x = byrow_xs, y = byrow_ys) [x, y, 0]]
        : Screw_Mounting == "Custom"
            ? (
                Board_Width > 1 && Board_Height > 1
                    ? [
                        for (i = [0:min(len(Screw_Custom_Positions), (Board_Width - 1) * (Board_Height - 1)) - 1])
                            if (Screw_Custom_Positions[i] == "1")
                                og_node_pos(
                                    1 + (i % (Board_Width - 1)),
                                    1 + floor(i / (Board_Width - 1)),
                                    Board_Width,
                                    Board_Height,
                                    tileSize
                                )
                    ]
                    : []
            )
        : [];

    everywhereChamferPositions =
        Chamfers == "Everywhere"
            ? [
                for (ix = [0:Board_Width], iy = [0:Board_Height])
                    let(
                        p = og_node_pos(ix, iy, Board_Width, Board_Height, tileSize),
                        chamfer_allowed = og_chamfer_allowed_at(ix, iy, Board_Width, Board_Height)
                    )
                    if (chamfer_allowed && !og_point_in_list(p, screwPositions))
                        p
            ]
            : [];

    borderChamferPositions =
        Chamfers == "Border Only"
            ? [
                for (ix = [0:Board_Width], iy = [0:Board_Height])
                    let(
                        p = og_node_pos(ix, iy, Board_Width, Board_Height, tileSize),
                        is_border = ix == 0 || ix == Board_Width || iy == 0 || iy == Board_Height,
                        chamfer_allowed = og_chamfer_allowed_at(ix, iy, Board_Width, Board_Height)
                    )
                    if (is_border && chamfer_allowed && !og_point_in_list(p, screwPositions))
                        p
            ]
            : [];

    nonBorderChamferPositions =
        Chamfers == "Non-Border Only"
            ? [
                for (ix = [0:Board_Width], iy = [0:Board_Height])
                    let(
                        p = og_node_pos(ix, iy, Board_Width, Board_Height, tileSize),
                        is_border = ix == 0 || ix == Board_Width || iy == 0 || iy == Board_Height,
                        chamfer_allowed = og_chamfer_allowed_at(ix, iy, Board_Width, Board_Height)
                    )
                    if (!is_border && chamfer_allowed && !og_point_in_list(p, screwPositions))
                        p
            ]
            : [];

    module screw_hole_cut(Tile_Thickness) {
        front_head_d = Screw_Head_Diameter;
        back_head_d = max(Screw_Diameter, Screw_Head_Diameter - Backside_Screw_Head_Diameter_Shrink);

        front_cs_h =
            Screw_Head_Is_CounterSunk
                ? tan((180 - Screw_Head_CounterSunk_Degree) / 2) * (front_head_d / 2 - Screw_Diameter / 2) - 0.01
                : 0.01;

        back_cs_h =
            Backside_Screw_Head_Is_CounterSunk
                ? tan((180 - Backside_Screw_Head_CounterSunk_Degree) / 2) * (back_head_d / 2 - Screw_Diameter / 2) - 0.01
                : 0.01;

        enable_backside_screw_hole = Backside_Screw_Hole && Full_or_Lite != "Heavy";

        union() {
            up(Tile_Thickness + 0.01)
                cyl(d=front_head_d, h=Screw_Head_Inset > 0 ? Screw_Head_Inset : 0.01, anchor=TOP)
                    attach(BOT, TOP)
                        cyl(d2=front_head_d, d1=Screw_Diameter, h=front_cs_h)
                            attach(BOT, TOP)
                                cyl(d=Screw_Diameter, h=Tile_Thickness + 0.02);

            if (enable_backside_screw_hole)
                down(0.01)
                    cyl(d=back_head_d, h=Backside_Screw_Head_Inset > 0 ? Backside_Screw_Head_Inset : 0.01, anchor=BOT)
                        attach(TOP, BOT)
                            cyl(d1=back_head_d, d2=Screw_Diameter, h=back_cs_h);
        }
    }

    if (Chamfers == "Corners")
        tag("remove")
            move_copies(cornerChamferPositions)
                down(0.01)
                    zrot(45)
                        cuboid([tileChamfer, tileChamfer, Tile_Thickness + 0.02], anchor=BOT);

    if (Chamfers == "Everywhere")
        tag("remove")
            move_copies(everywhereChamferPositions)
                down(0.01)
                    zrot(45)
                        cuboid([tileChamfer, tileChamfer, Tile_Thickness + 0.02], anchor=BOT);

    if (Chamfers == "Border Only")
        tag("remove")
            move_copies(borderChamferPositions)
                down(0.01)
                    zrot(45)
                        cuboid([tileChamfer, tileChamfer, Tile_Thickness + 0.02], anchor=BOT);

    if (Chamfers == "Non-Border Only")
        tag("remove")
            move_copies(nonBorderChamferPositions)
                down(0.01)
                    zrot(45)
                        cuboid([tileChamfer, tileChamfer, Tile_Thickness + 0.02], anchor=BOT);

    if (Screw_Mounting != "None")
        tag("remove")
            move_copies(screwPositions)
                screw_hole_cut(Tile_Thickness);

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
        translate([x * spacing_x, y * spacing_y, 0]) if (Full_or_Lite == "Full")
            openGrid(
                Board_Width=w, Board_Height=h,
                tileSize=Tile_Size,
                Tile_Thickness=Tile_Thickness,
                Screw_Mounting=Screw_Mounting,
                Chamfers=Chamfers, anchor=BOT,
                Connector_Holes=Connector_Holes
            );
        else if (Full_or_Lite == "Heavy")
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
            translate([cx, cy, 0]) if (Full_or_Lite == "Full")
                openGrid(
                    Board_Width=Max_Tile_Width,
                    Board_Height=Max_Tile_Depth,
                    tileSize=Tile_Size,
                    Tile_Thickness=Tile_Thickness,
                    Screw_Mounting=Screw_Mounting,
                    Chamfers=Chamfers, anchor=BOT,
                    Connector_Holes=Connector_Holes
                );
            else if (Full_or_Lite == "Heavy")
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