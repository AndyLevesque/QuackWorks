/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model from Hands on Katie (https://handsonkatie.com/)
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @cosmicdust on MakerWorld and @freakadings_1408562 on Printables for the idea of diagonals (forward and turn)
    @siyrahfall+1155967 on Printables for the idea of top exit holes
    @Lyric on Printables for the flush connector idea
    @dmgerman on MakerWorld for the specs on the small screw profile
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Choose Part]*/
Choose_Part = "I-Channel - Straight"; // [I-Channel - Straight, C-Channel - Curved, L-Channel,  T-Channel, X-Channel, Y-Channel, Diagonal Channel, Mitre Channel]
Base_Top_or_Both = "Both"; // [Base, Top, Both]

/*[Channel Height and Width]*/
//width of channel in units (default unit is 25mm)
Channel_Width_in_Units = 1;
//height inside the channel (in mm)
Channel_Internal_Height = 12; //[12:6:72]

/*[Mounting Options]*/
//How do you intend to connect the channels to a surface such as Honeycomb Storage Wall or Multiboard? See options at https://coda.io/@andylevesque/underware
Mounting_Method = "Threaded Snap Connector"; //[Threaded Snap Connector, Direct Multiboard Screw]

/*[Options: I-Channel]*/
//length of channel in units (default unit is 25mm)
Channel_Length_Units = 5; 
Number_of_Cord_Cutouts = 0;
//Cutouts on left side, right side, or both (note that it can be flipped so left and right is moot)
Cord_Side_Cutouts = "Both Sides"; //[Left Side, Right Side, Both Sides, None]
//Width of each cord cutout (in mm)
Cord_Cutout_Width = 12;
Distance_Between_Cutouts = 25;
//Distance (in mm) to shift all cutouts forward (positive) or back (negative)
Shift_Cutouts_Forward_or_Back = 0;

/*[Options: L-Channel]*/
//Number of grids extending from the corner grid
L_Channel_Length_in_Units = 1;

/*[Options: C-Channel]*/
//Grid units to curve. 2 = up 2 and over 2 grids.
Curve_Radius_in_Units = 2;

/*[Options: Diagonal Channel]*/
//Grid units to move over
Units_Over = 2; //[-10:1:10]
//Grid units to move up
Units_Up = 2; //[-10:1:10]
//Output the same direction (Forward) or at 90 degrees in direction of shift (Turn).
Output_Direction = "Turn"; //[Forward, Turn]
//Distance that the parts are straight in on the ends (before the angle)
Straight_Distance = 25;//[12.5:12.5:100]

/*[Options: Y-Channel]*/
//Grid units to move over. Both sides will move over and away from the center by this amount.
Y_Units_Over = 1; //[1:1:10]
//Grid units to move up
Y_Units_Up = 1;//[1:1:10]
//Output the same direction (Forward) or at 90 degrees in direction of shift (Turn).
Y_Output_Direction = "Forward"; //[Forward, Turn]
//Distance that the parts are straight in on the ends (before the angle). Unexpected behavior on wider channels may be resolved by changing this slider. 
Y_Straight_Distance = 12.5; //[12.5:12.5:100]

/*[Options: Waterfall Channel]*/
//Length (in mm) the longest edge of one top channel. This should be the distance of where the channel starts to the wall or corner.
Length_of_Longest_Edge = 75;

/*[Advanced Options]*/
//Units of measurement (in mm) for hole and length spacing. Multiboard is 25mm. Untested
Grid_Size = 25;
//Color of part (color names found at https://en.wikipedia.org/wiki/Web_colors)
Global_Color = "SlateBlue";



/*[I-Channel Label]*/
//Create label using multicolor on straight channel
Add_Label = false;
//Text to appear on label
Text = "Hands on Katie";  // Text to be displayed
Text_x_coordinate = 0;  // Adjusting the x position of the text
//Font must be installed on local machine if using local OpenSCAD
Font = "Raleway"; // [Asap, Bangers, Changa One, Chewy, Harmony OS Sans,Inter,Inter Tight,Lora,Merriweather Sans,Montserrat,Noto Emoji,Noto Sans,Noto Sans Adlam,Noto Sans Adlam Unjoined,Noto Sans Arabic,Noto Sans Arabic UI,Noto Sans Armenian,Noto Sans Balinese,Noto Sans Bamum,Noto Sans Bassa Vah,Noto Sans Bengali,Noto Sans Bengali UI,Noto Sans Canadian Aboriginal,Noto Sans Cham,Noto Sans Cherokee,Noto Sans Devanagari,Noto Sans Display,Noto Sans Ethiopic,Noto Sans Georgian,Noto Sans Gujarati,Noto Sans Gunjala Gondi,Noto Sans Gurmukhi,Noto Sans Gurmukhi UI,Noto Sans HK,Noto Sans Hanifi Rohingya,Noto Sans Hebrew,Noto Sans JP,Noto Sans Javanese,Noto Sans KR,Noto Sans Kannada,Noto Sans Kannada UI,Noto Sans Kawi,Noto Sans Kayah Li,Noto Sans Khmer,Noto Sans Khmer UI,Noto Sans Lao,Noto Sans Lao Looped,Noto Sans Lao UI,Noto Sans Lisu,Noto Sans Malayalam,Noto Sans Malayalam UI,Noto Sans Medefaidrin,Noto Sans Meetei Mayek,Noto Sans Mono,Noto Sans Myanmar,Noto Sans NKo Unjoined,Noto Sans Nag Mundari,Noto Sans New Tai Lue,Noto Sans Ol Chiki,Noto Sans Oriya,Noto Sans SC,Noto Sans Sinhala,Noto Sans Sinhala UI,Noto Sans Sora Sompeng,Noto Sans Sundanese,Noto Sans Symbols,Noto Sans Syriac,Noto Sans Syriac Eastern,Noto Sans TC,Noto Sans Tai Tham,Noto Sans Tamil,Noto Sans Tamil UI,Noto Sans Tangsa,Noto Sans Telugu,Noto Sans Telugu UI,Noto Sans Thaana,Noto Sans Thai,Noto Sans Thai UI,Noto Sans Vithkuqi,Nunito,Nunito Sans,Open Sans,Open Sans Condensed,Oswald,Playfair Display,Plus Jakarta Sans,Raleway,Roboto,Roboto Condensed,Roboto Flex,Roboto Mono,Roboto Serif,Roboto Slab,Rubik,Source Sans 3,Ubuntu Sans,Ubuntu Sans Mono,Work Sans]
//Styling of selecte font. Note that not all fonts support all styles. 
Font_Style = "Regular"; // [Regular,Bold,Medium,SemiBold,Light,ExtraBold,Black,ExtraLight,Thin,Bold Italic,Italic,Light Italic,Medium Italic]
Text_size = 10;    // Font size
//Color of label text (color names found at https://en.wikipedia.org/wiki/Web_colors)
Text_Color = "Pink";
surname_font = str(Font , ":style=", Font_Style);

/*[Hidden]*/
channelWidth = Channel_Width_in_Units * Grid_Size;
baseHeight = 9.63;
topHeight = 10.968;
interlockOverlap = 3.09; //distance that the top and base overlap each other
interlockFromFloor = 6.533; //distance from the bottom of the base to the bottom of the top when interlocked
partSeparation = 10;

///*[Visual Options]*/
Debug_Show_Grid = false;
//View the parts as they attach. Note that you must disable this before exporting for printing. 
Show_Attached = false;

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


///*[Direct Screw Mount]*/
Base_Screw_Hole_Inner_Diameter = 7;
Base_Screw_Hole_Outer_Diameter = 15;
//Thickness of of the base bottom and the bottom of the recessed hole (i.e., thicknes of base at the recess)
Base_Screw_Hole_Inner_Depth = 1;
Base_Screw_Hole_Cone = false;

//Part Size Calculations
straight_channel_Y = Grid_Size * Channel_Length_Units;
l_channel_Y = channelWidth*1.5 + Grid_Size * L_Channel_Length_in_Units;
x_channel_X = channelWidth+Grid_Size*2;
x_channel_Y = channelWidth+Grid_Size*2;
radius_channel_Y = Grid_Size + channelWidth + (Curve_Radius_in_Units*channelWidth/2 - channelWidth/2)/2 - channelWidth/2;
c_channel_arc = Grid_Size*(Channel_Width_in_Units/2 + Curve_Radius_in_Units-1);
//solved via https://chatgpt.com/share/6736552f-ce1c-8010-ab4c-36a095eee6b5

/*

***BEGIN DISPLAYS***

*/

/*
//Testing top riser
!extrude_from_to([0,0,0],[0,25,0]) {
    topProfile(widthMM = 25, heightMM = 12);
    topProfile(widthMM = 25, heightMM = 12);
}
*/

//if(Debug_Show_Grid)
//#back(12.5) back(12.5*Channel_Width_in_Units-12.5) grid_copies(spacing=Grid_Size, inside=rect([200,200]))cyl(h=8, d=7, $fn=25);//temporary 

/*

CHANNELS

*/

if(Choose_Part == "I-Channel - Straight" && Base_Top_or_Both != "Top")
color_this(Global_Color)
        left(Show_Attached ? 0 : channelWidth/2)
            straightChannelBase(lengthMM = Channel_Length_Units * Grid_Size, widthMM = channelWidth, anchor=BOT);
if(Choose_Part == "I-Channel - Straight" && Base_Top_or_Both != "Base")
color_this(Global_Color)
        right(Show_Attached ? 0 : channelWidth/2 + 5)
        up(Show_Attached ? interlockFromFloor : Add_Label ? 0.01 : 0)
            diff("text")
            straightChannelTop(lengthMM = Channel_Length_Units * Grid_Size, widthMM = channelWidth, heightMM = Channel_Internal_Height, anchor=Show_Attached ? BOT : TOP, orient=Show_Attached ? TOP : BOT)
                if(Add_Label) tag("text") recolor(Text_Color) zrot(-90) attach(TOP) //linear_extrude(height = 0.02)
                right(Text_x_coordinate)text3d(Text, size = Text_size, h=0.05, font = surname_font, atype="ycenter", anchor=CENTER);


if(Choose_Part == "Diagonal Channel" && Base_Top_or_Both != "Top")
    color_this(Global_Color) 
        diagonalChannelBase(unitsOver = Units_Over, unitsUp = Units_Up, outputDirection = Output_Direction, straightDistance = Straight_Distance, widthMM = Channel_Width_in_Units * Grid_Size, anchor = BOT);
if(Choose_Part == "Diagonal Channel" && Base_Top_or_Both != "Base")
    color_this(Global_Color) left(channelWidth*sign(Units_Over)+partSeparation*sign(Units_Over)) 
        diagonalChannelTop(unitsOver = Units_Over, unitsUp = Units_Up, outputDirection = Output_Direction, straightDistance = Straight_Distance, widthMM = Channel_Width_in_Units * Grid_Size, heightMM = Channel_Internal_Height, anchor = TOP, orient = Show_Attached ? TOP :  BOT);

if(Choose_Part == "Mitre Channel")
color_this(Global_Color) left(3)
    half_of(UP+LEFT, s=Channel_Length_Units*Grid_Size*2+10)
        path_sweep(topProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Length_of_Longest_Edge_1*2-50+14.032*2- (Channel_Internal_Height-12)*2]), anchor=TOP, orient=BOT);

if(Choose_Part == "Mitre Channel")
    color_this(Global_Color) down(3)yrot(-90) xrot(180)half_of(UP+LEFT, s=Channel_Length_Units*Grid_Size*2+10)
            path_sweep(topProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Length_of_Longest_Edge_2+14.032*2+14 - (Channel_Internal_Height-12)*2]), anchor=TOP, orient=BOT);

if(Choose_Part == "Y-Channel" && Base_Top_or_Both != "Top")
    color_this(Global_Color)
        left(partSeparation/2) yChannelBase(widthMM = channelWidth, unitsOver = Y_Units_Over, unitsUp = Y_Units_Up, outputDirection = Y_Output_Direction, straightDistance = Y_Straight_Distance, anchor=BOT+RIGHT);

if(Choose_Part == "Y-Channel" && Base_Top_or_Both != "Base")
    color_this(Global_Color)
        right(partSeparation/2) yChannelTop(widthMM = channelWidth, unitsOver = Y_Units_Over, unitsUp = Y_Units_Up, heightMM = Channel_Internal_Height, outputDirection = Y_Output_Direction, straightDistance = Y_Straight_Distance, anchor=TOP+RIGHT, orient=BOT);

if(Choose_Part == "L-Channel" && Base_Top_or_Both != "Top")
color_this(Global_Color)
    left(Show_Attached ? 0 : partSeparation)
        lChannelBase(lengthMM = L_Channel_Length_in_Units * Grid_Size, widthMM = Channel_Width_in_Units * Grid_Size, anchor=Show_Attached ? BOT : BOT+RIGHT);
if(Choose_Part == "L-Channel" && Base_Top_or_Both != "Base")
color_this(Global_Color)
    up(Show_Attached ? interlockFromFloor : 0)
    right(Show_Attached ? 0 : partSeparation)
        lChannelTop(lengthMM = L_Channel_Length_in_Units * Grid_Size, widthMM = Channel_Width_in_Units * Grid_Size, heightMM = Channel_Internal_Height, anchor= Show_Attached ? BOT : TOP+RIGHT, orient=Show_Attached ? TOP : BOT);

if(Choose_Part == "C-Channel - Curved" && Base_Top_or_Both != "Top")
color_this(Global_Color)
    left(Show_Attached ? 0 : radius_channel_Y + partSeparation / 2)
        curvedChannelBase(radiusMM = c_channel_arc, widthMM = channelWidth, anchor=BOT);
if(Choose_Part == "C-Channel - Curved" && Base_Top_or_Both != "Base")
color_this(Global_Color)
    right(Show_Attached ? 0 : radius_channel_Y + partSeparation / 2)
    up(Show_Attached ? interlockFromFloor : 0)
        curvedChannelTop(radiusMM = c_channel_arc, widthMM = channelWidth, heightMM = Channel_Internal_Height, anchor = Show_Attached ? BOT : TOP, orient= Show_Attached ? TOP : BOT);

if(Choose_Part == "X-Channel" && Base_Top_or_Both != "Top")
    //cross intersection
color_this(Global_Color) 
    left(Show_Attached ? 0 : x_channel_X / 2 + partSeparation/2)
        XChannelBase(widthMM = channelWidth, anchor=BOT);
if(Choose_Part == "X-Channel" && Base_Top_or_Both != "Base")
color_this(Global_Color)
    right(Show_Attached ? 0 : x_channel_X / 2 + partSeparation/2)
    up(Show_Attached ? interlockFromFloor : 0) 
        XChannelTop(widthMM = channelWidth, heightMM = Channel_Internal_Height, anchor=Show_Attached ? BOT : TOP, orient= Show_Attached ? TOP : BOT);


if(Choose_Part == "T-Channel"&& Base_Top_or_Both != "Top")
color_this(Global_Color)
    left(Show_Attached ? 0 : partSeparation)
        tIntersectionBase(widthMM = channelWidth, anchor=Show_Attached ? BOT : BOT+RIGHT);
if(Choose_Part == "T-Channel"&& Base_Top_or_Both != "Base")
color_this(Global_Color)
    right(Show_Attached ? 0 : partSeparation)
    up(Show_Attached ? interlockFromFloor : 0) 
        tIntersectionTop(widthMM = channelWidth, heightMM = Channel_Internal_Height, anchor=Show_Attached ? BOT : TOP+RIGHT, orient= Show_Attached ? TOP : BOT);


/*

***BEGIN MODULES***

*/

//STRAIGHT CHANNELS
module straightChannelBase(lengthMM, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, baseHeight]){
        fwd(lengthMM/2) down(maxY(baseProfileHalf)/2)
        diff("holes")
        zrot(90) path_sweep(baseProfile(widthMM = widthMM), turtle(["xmove", lengthMM]))
        tag("holes")  right(lengthMM/2) grid_copies(spacing=Grid_Size, inside=rect([lengthMM-1,widthMM-1])) 
            if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3.5-Base_Screw_Hole_Inner_Depth+0.02, d1=Base_Screw_Hole_Cone ? Base_Screw_Hole_Inner_Diameter : Base_Screw_Hole_Outer_Diameter, d2=Base_Screw_Hole_Outer_Diameter, $fn=25);
            else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
    children();
    }
}



module straightChannelTop(lengthMM, widthMM, heightMM = 12, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, topHeight + (heightMM-12)]){
        fwd(lengthMM/2) down(10.968/2 + (heightMM - 12)/2)
        diff("Cable_Cutouts")
        zrot(90) path_sweep(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["xmove", lengthMM]))
            tag("Cable_Cutouts") down(5+0.01) up(10.968/2 + (heightMM - 12)/2) right(lengthMM/2)
                xcopies(n=Number_of_Cord_Cutouts, spacing= Distance_Between_Cutouts) 
                    up(2.49)
                    fwd(Cord_Side_Cutouts == "Left Side" ? channelWidth/2 :
                        Cord_Side_Cutouts == "Right Side" ? -channelWidth/2 : 
                        0)
                    left(-Shift_Cutouts_Forward_or_Back)
                        cuboid([Cord_Cutout_Width, Cord_Side_Cutouts == "Both Sides" ? channelWidth + 5 : channelWidth/2, Channel_Internal_Height-2], chamfer = 2, edges=[TOP+LEFT, TOP+RIGHT]);
    children();
    }
}

//STRAIGHT CHANNEL DELETE TOOLS
module straightChannelBaseDeleteTool(lengthMM, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, baseHeight]){
        fwd(lengthMM/2) down(maxY(baseProfileHalf)/2)
        zrot(90) path_sweep(baseDeleteProfile(widthMM = widthMM), turtle(["xmove", lengthMM])); 
    children();
    }
}

module straightChannelTopDeleteTool(lengthMM, widthMM, heightMM = 12, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, topHeight + (heightMM-12)]){
        fwd(lengthMM/2) down(topHeight/2 + (heightMM - 12)/2)
        zrot(90) path_sweep(topDeleteProfile(widthMM = widthMM, heightMM = heightMM), turtle(["xmove", lengthMM])); 
    children(); 
    }
}

//L CHANNELS
module lChannelBase(lengthMM = 50, widthMM = 25, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM+lengthMM, widthMM+lengthMM, baseHeight]){
        let(calculatedPath = widthMM/2+lengthMM)
        left(widthMM/2+lengthMM/2) fwd(lengthMM/2)
        down(baseHeight/2)
        diff("holes"){
            path_sweep2d(baseProfile(widthMM = widthMM), turtle(["move", calculatedPath, "turn", 90, "move",calculatedPath] )); 
            tag("holes") right(widthMM/2+lengthMM/2) back(lengthMM/2) grid_copies(spacing=Grid_Size, inside=rect([widthMM+lengthMM-1,widthMM+lengthMM-1])) 
                if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=10, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
        }
    children();
    }
}
module lChannelTop(lengthMM = 50, widthMM = 25, heightMM = 12, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM+lengthMM, widthMM+lengthMM, topHeight + (heightMM-12)]){
        let(calculatedPath = widthMM/2+lengthMM)
        left(widthMM/2+lengthMM/2) fwd(lengthMM/2) 
        down(topHeight/2 + (heightMM - 12)/2)
        path_sweep2d(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["move", calculatedPath, "turn", 90, "move",calculatedPath] )); 
    children();
    }
}

//C CHANNELS
module curvedChannelBase(radiusMM, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[Grid_Size + channelWidth + (radiusMM - channelWidth/2), Grid_Size + channelWidth + (radiusMM - channelWidth/2), baseHeight]){ //Curve_Radius_in_Units*channelWidth/2
        let(adjustedWidth = Grid_Size + channelWidth + (radiusMM - channelWidth/2))
        fwd((Grid_Size + channelWidth + (radiusMM - channelWidth/2))/2 - channelWidth/2) 
        left((Grid_Size + channelWidth + (radiusMM - channelWidth/2))/2) 
        down(baseHeight/2)
            diff("holes"){
                path_sweep(baseProfile(widthMM = widthMM), turtle(["move", Grid_Size, "arcleft", radiusMM, 90, "move", Grid_Size])) {
                    tag("holes") ycopies(spacing = Grid_Size, n = Channel_Width_in_Units) right(Grid_Size/2) down(0.01) 
                        if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                        else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                    tag("holes") xcopies(spacing = Grid_Size, n = Channel_Width_in_Units) right(Grid_Size + channelWidth/2 + (radiusMM - channelWidth/2)) back(channelWidth/2 + Grid_Size/2 + (radiusMM - channelWidth/2)) down(0.01) 
                        if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                        else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                    //#tag("holes") right(12.5) back(12.5*Channel_Width_in_Units-12.5)#grid_copies(spacing=Grid_Size, inside=rect([200,200]))cyl(h=8, d=7, $fn=25);//temporary 
                }
            }
        children();
    }
}

module curvedChannelTop(radiusMM, widthMM, heightMM = 12, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[Grid_Size + channelWidth + (radiusMM - channelWidth/2), Grid_Size + channelWidth + (radiusMM - channelWidth/2), topHeight + (heightMM-12)]){
        fwd((Grid_Size + channelWidth + (radiusMM - channelWidth/2))/2 - channelWidth/2) 
        left((Grid_Size + channelWidth + (radiusMM - channelWidth/2))/2)  
        down(topHeight/2 + (heightMM - 12)/2)
        path_sweep(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["move", Grid_Size, "arcleft", radiusMM, 90, "move", Grid_Size])); 
        children();
    }
}

//DIAGONAL CHANNELS
module diagonalChannelBase(unitsOver = 1, unitsUp=3, outputDirection = "Forward", straightDistance = Grid_Size, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[50,50, baseHeight]){
        down(baseHeight/2)
            diff("holes"){
                path_sweep2d(baseProfile(widthMM = widthMM), 
                    path= outputDirection == "Forward" ? [
                        [0,0], //start
                        [0,Straight_Distance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                        [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-Straight_Distance*sign(unitsUp)-0.1], //movement to position before last straight
                        [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)] //last position either out the angle or straight out
                    ] :
                    [ //90 degree path
                        [0,0], //start
                        [0,Straight_Distance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                        [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver)-straightDistance*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)], //movement to position before last straight
                        [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)] //last position either out the angle or straight out
                    ]
                    ) {
                    tag("holes") xcopies(spacing = Grid_Size, n = Channel_Width_in_Units) back(Grid_Size/2*sign(unitsUp)) down(0.01) 
                        if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                        else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                    //outside holes forward option
                    tag("holes") 
                        if(outputDirection == "Forward") xcopies(spacing = Grid_Size, n = Channel_Width_in_Units) back(unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-Grid_Size/2*sign(unitsUp)) right(unitsOver*Grid_Size)down(0.01) 
                        if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                        else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                    //outside holes turn option
                    tag("holes") 
                        if(outputDirection == "Turn") ycopies(spacing = Grid_Size, n = Channel_Width_in_Units) back(unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)) right(unitsOver*Grid_Size)down(0.01) 
                        if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                        else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                }
            }
        children();
    }
}

module diagonalChannelTop(unitsOver = 1, unitsUp=3, outputDirection = "Forward", straightDistance = Grid_Size, widthMM, heightMM = 12, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[50,50, topHeight + (heightMM-12)]){ //Curve_Radius_in_Units*channelWidth/2
        down(topHeight/2 + (heightMM - 12)/2)
            diff("holes"){
                path_sweep2d(topProfile(widthMM = widthMM, heightMM = heightMM), 
                    path= outputDirection == "Forward" ? [
                        [0,0], //start
                        [0,Straight_Distance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                        [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-Straight_Distance*sign(unitsUp)-0.1], //movement to position before last straight
                        [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)] //last position either out the angle or straight out
                    ] :
                    [ //90 degree path
                        [0,0], //start
                        [0,Straight_Distance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                        [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver)-straightDistance*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)], //movement to position before last straight
                        [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)] //last position either out the angle or straight out
                    ]
                    ) ;
            }
        children();
    }
}

//X CHANNELS
module XChannelBase(widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[channelWidth+Grid_Size*2, channelWidth+Grid_Size*2, baseHeight]){
        diff("channelClear holes"){
        down(baseHeight/2)left((channelWidth/2+Grid_Size)) path_sweep(baseProfile(widthMM = widthMM), turtle(["xmove", channelWidth+Grid_Size*2]));
        down(baseHeight/2)fwd(channelWidth/2+Grid_Size) zrot(90)path_sweep(baseProfile(widthMM = widthMM), turtle(["xmove", channelWidth+Grid_Size*2]));
        //zrot_copies(n=4) straightChannelBase(lengthMM = Grid_Size*3, widthMM = channelWidth) //old approach with unwanted straight channel inheritance
        tag("channelClear") zrot_copies(n=4) straightChannelBaseDeleteTool(widthMM = channelWidth+0.02, lengthMM = Grid_Size+channelWidth); 
        tag("holes") down(4)grid_copies(spacing=Grid_Size, inside=rect([x_channel_X-1,x_channel_Y-1])) 
            if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
            else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
        }
        children();
    }
}

module XChannelTop(widthMM, heightMM = 12, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[Grid_Size*3, Grid_Size*3, topHeight + (heightMM-12)]){
    down((topHeight + (heightMM-12))/2)
    diff("channelClear"){
        left((channelWidth/2+Grid_Size)) path_sweep(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["xmove", channelWidth+Grid_Size*2]));
        fwd(channelWidth/2+Grid_Size) zrot(90) path_sweep(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["xmove", channelWidth+Grid_Size*2]));
        tag("channelClear") zrot_copies(n=4) straightChannelTopDeleteTool(widthMM = channelWidth+0.02, lengthMM = Grid_Size+channelWidth, heightMM = heightMM, anchor=BOT); 
    }
    children();
    }
}

//T CHANNELS
module tIntersectionBase(widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[channelWidth+Grid_Size, channelWidth+Grid_Size*2, baseHeight]){
        down(baseHeight/2) 
        left(Grid_Size/2)
        union(){
        diff("channelClear holes")
        //side channel
        path_sweep(baseProfile(widthMM = widthMM), turtle(["move", channelWidth/2 + Grid_Size])){
            tag("channelClear") zrot(90) fwd(channelWidth/2) straightChannelBaseDeleteTool(widthMM = channelWidth+0.02, lengthMM = channelWidth/2 + Grid_Size, anchor=BOT);
        //long channel
        zrot(90) left(channelWidth/2+Grid_Size)path_sweep(baseProfile(widthMM = widthMM), turtle(["move", channelWidth+Grid_Size*2]));
        tag("channelClear") straightChannelBaseDeleteTool(widthMM = channelWidth+0.02, lengthMM = channelWidth+Grid_Size*2, anchor=BOT);
        tag("holes") grid_copies(n=2+Channel_Width_in_Units, spacing=Grid_Size) 
            if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
            else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
        }
        }
        children();
    }
}

module tIntersectionTop(widthMM, heightMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[channelWidth+Grid_Size, channelWidth+Grid_Size*2, topHeight + (heightMM-12)]){
        down((topHeight + (heightMM-12))/2) left(Grid_Size/2)
        diff("channelClear")
        //side channel
        path_sweep(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["move", channelWidth/2 + Grid_Size])){
            tag("channelClear") zrot(90) fwd(channelWidth/2) straightChannelTopDeleteTool(widthMM = channelWidth+0.02, lengthMM = channelWidth/2 + Grid_Size, heightMM = heightMM, anchor=BOT);
        //long channel
        zrot(90) left(channelWidth/2+Grid_Size)path_sweep(topProfile(widthMM = widthMM, heightMM = heightMM), turtle(["move", channelWidth+Grid_Size*2]));
            tag("channelClear") straightChannelTopDeleteTool(widthMM = channelWidth+0.02, lengthMM = channelWidth+Grid_Size*2, heightMM = heightMM, anchor=BOT);

        }
        children();
    }
}

//Y-Channels
module yChannelBase(unitsOver = 1, unitsUp=3, outputDirection = "Forward", straightDistance = Grid_Size, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[unitsOver*Grid_Size*2+channelWidth,unitsUp*Grid_Size+straightDistance*2, baseHeight]){
        fwd(unitsUp*Grid_Size/2+straightDistance)
        down(baseHeight/2)
            diff("holes"){
                xflip_copy() 
                {
                    right_half(s=max(unitsUp*Grid_Size*4,unitsOver*Grid_Size*4)) {//s should be a number larger than twice the size of the object's largest axis. Thew some random numbers in here for now. If mirror issues surface, this is likely the culprit. 
                        path_sweep2d(baseProfile(widthMM = widthMM), 
                            path= outputDirection == "Forward" ? [
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-straightDistance*sign(unitsUp)-0.1], //movement to position before last straight
                                [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)] //last position either out the angle or straight out
                            ] :
                            [ //90 degree path
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver)-straightDistance*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)], //movement to position before last straight
                                [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)] //last position either out the angle or straight out
                            ]
                            );
                    }}
                            tag("holes") xcopies(spacing = Grid_Size, n = Channel_Width_in_Units) back(Grid_Size/2*sign(unitsUp)) down(0.01) 
                                if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                                else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                            //outside holes forward option (right side)
                            tag("holes") 
                                if(outputDirection == "Forward")
                                    move_copies([
                                        [unitsOver*Grid_Size, unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-Grid_Size/2*sign(unitsUp),-0.01],//right side
                                        [unitsOver*Grid_Size*-1, unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-Grid_Size/2*sign(unitsUp),-0.01]
                                        ])
                                        xcopies(spacing = Grid_Size, n = Channel_Width_in_Units) //back(Units_Up*Grid_Size+Grid_Size*sign(unitsUp)-Grid_Size/2*sign(unitsUp)) //right(unitsOver*Grid_Size)down(0.01) 
                                    if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                                    else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);
                            //outside holes turn option
                            tag("holes") 
                                if(outputDirection == "Turn") 
                                    move_copies([
                                        [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp),-0.01],
                                        [-unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp),-0.01]
                                        ])
                                        ycopies(spacing = Grid_Size, n = Channel_Width_in_Units)// back(Units_Up*Grid_Size+Grid_Size/2*sign(unitsUp)) //right(unitsOver*Grid_Size)down(0.01) 
                                if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
                                else up(6.5) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=9, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, bevel2 = true, blunt_start=false, anchor=TOP);  
            if(Debug_Show_Grid)
                #back(12.5) back(12.5*Channel_Width_in_Units-12.5) grid_copies(spacing=Grid_Size, inside=rect([200,200]))cyl(h=8, d=7, $fn=25);//temporary 
            }
        children();
    }
}

module yChannelTop(unitsOver = 1, unitsUp=3, heightMM = 12, outputDirection = "Forward", straightDistance = Grid_Size, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[unitsOver*Grid_Size*2+channelWidth,unitsUp*Grid_Size+straightDistance*2, topHeight + (heightMM-12)]){
        fwd(unitsUp*Grid_Size/2+straightDistance)
        down((topHeight + (heightMM-12))/2)
            diff("holes"){
                xflip_copy() 
                {
                    right_half(s=max(unitsUp*Grid_Size*4,unitsOver*Grid_Size*4)) {//s should be a number larger than twice the size of the object's largest axis. Thew some random numbers in here for now. If mirror issues surface, this is likely the culprit. 
                        path_sweep2d(topProfile(widthMM = widthMM, heightMM = heightMM), 
                            path= outputDirection == "Forward" ? [
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)-straightDistance*sign(unitsUp)-0.1], //movement to position before last straight
                                [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size*sign(unitsUp)] //last position either out the angle or straight out
                            ] :
                            [ //90 degree path
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver)-straightDistance*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)], //movement to position before last straight
                                [unitsOver*Grid_Size+Grid_Size/2*sign(unitsOver),unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp)] //last position either out the angle or straight out
                            ]
                            );
                    }}
            }
        children();
    }
}



//BEGIN PROFILES - Must match across all files

//take the two halves of base and merge them
function baseProfile(widthMM = 25) = 
    union(
        left((widthMM-25)/2,baseProfileHalf), 
        right((widthMM-25)/2,mirror([1,0],baseProfileHalf)), //fill middle if widening from standard 25mm
        back(3.5/2,rect([widthMM-25+0.02,3.5]))
    );

//take the two halves of base and merge them
function topProfile(widthMM = 25, heightMM = 12) = 
    union(
        left((widthMM-25)/2,topProfileHalf(heightMM)), 
        right((widthMM-25)/2,mirror([1,0],topProfileHalf(heightMM))), //fill middle if widening from standard 25mm
        back(topHeight-1 + heightMM-12 , rect([widthMM-25+0.02,2])) 
    );

function baseDeleteProfile(widthMM = 25) = 
    union(
        left((widthMM-25)/2,baseDeleteProfileHalf), 
        right((widthMM-25)/2,mirror([1,0],baseDeleteProfileHalf)), //fill middle if widening from standard 25mm
        back(6.575,rect([widthMM-25+0.02,6.15]))
    );

function topDeleteProfile(widthMM, heightMM = 12) = 
    union(
        left((widthMM-25)/2,topDeleteProfileHalf(heightMM)), 
        right((widthMM-25)/2,mirror([1,0],topDeleteProfileHalf(heightMM))), //fill middle if widening from standard 25mm
        back(4.474 + (heightMM-12)/2,rect([widthMM-25+0.02,8.988 + heightMM - 12])) 
    );

baseProfileHalf = 
    fwd(-7.947, //take Katie's exact measurements for half the profile and use fwd to place flush on the Y axis
        //profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,-4.447],
            [-8.5,-4.447],
            [-9.5,-3.447],
            [-9.5,1.683],
            [-10.517,1.683],
            [-11.459,1.422],
            [-11.459,-0.297],
            [-11.166,-0.592],
            [-11.166,-1.414],
            [-11.666,-1.914],
            [-12.517,-1.914],
            [-12.517,-4.448],
            [-10.517,-6.448],
            [-10.517,-7.947],
            [0,-7.947]
        ]
);

function topProfileHalf(heightMM = 12) =
        back(1.414,//profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,7.554 + (heightMM - 12)],//-0.017 per Katie's diagram. Moved to zero
            [0,9.554 + (heightMM - 12)],
            [-8.517,9.554 + (heightMM - 12)],
            [-12.517,5.554 + (heightMM - 12)],
            [-12.517,-1.414],
            [-11.166,-1.414],
            [-11.166,-0.592],
            [-11.459,-0.297],
            [-11.459,1.422],
            [-10.517,1.683],
            [-10.517,4.725 + (heightMM - 12)],
            [-7.688,7.554 + (heightMM - 12)]
        ]
        );

baseDeleteProfileHalf = 
    fwd(-7.947, //take Katie's exact measurements for half the profile of the inside
        //profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,-4.447], //inner x axis point with width adjustment
            [0,1.683+0.02],
            [-9.5,1.683+0.02],
            [-9.5,-3.447],
            [-8.5,-4.447],
        ]
);

function topDeleteProfileHalf(heightMM = 12)=
        back(1.414,//profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,7.554 + (heightMM - 12)],
            [-7.688,7.554 + (heightMM - 12)],
            [-10.517,4.725 + (heightMM - 12)],
            [-10.517,1.683],
            [-11.459,1.422],
            [-11.459,-0.297],
            [-11.166,-0.592],
            [-11.166,-1.414-0.02],
            [0,-1.414-0.02]
        ]
        );


//calculate the max x and y points. Useful in calculating size of an object when the path are all positive variables originating from [0,0]
function maxX(path) = max([for (p = path) p[0]]) + abs(min([for (p = path) p[0]]));
function maxY(path) = max([for (p = path) p[1]]) + abs(min([for (p = path) p[1]]));


