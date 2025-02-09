/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model from Hands on Katie (https://handsonkatie.com/)
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @cosmicdust on MakerWorld and @freakadings_1408562 on Printables for the idea of diagonals (forward and turn)
    @siyrahfall+1155967 on Printables for the idea of top exit holes
    @Lyric on Printables for the flush connector idea
    @fawix on GitHub for her contributions on parameter descriptors
    @Mole. on  MakerWorld for Desk Edge channel

Release Notes
    - 2025-02-04 
        - Initial Release

*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Choose Part]*/
Base_Top_or_Both = "Both"; // [Base, Top, Both]

/*[Channel Size]*/
//Width (Y axis) of channel in units. Default unit is 25mm
Channel_Width_in_Units = 1;
//Height inside the channel (in mm). Z axis for top channel and X axis bottom channel.
Channel_Internal_Height = 12; //[12:6:72]
//Length (X axis) in mm of offset from edge of desk to start of Multiboard tiles.
Offset_to_Multiboard = 5;
//Length (X axis) of channel in units. Default unit is 25mm
Connector_channel_length = 2; 
//Length (Z axis) in mm of the channel up the edge of the desk.
Thickness_of_Desk = 40;
//Slot for cable access (in mm)
Cable_slot = 7;

/*[Mounting Options]*/
//How do you intend to mount the channels to a surface such as Honeycomb Storage Wall or Multiboard? See options at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/
Mounting_Method = "Threaded Snap Connector"; //[Threaded Snap Connector, Direct Multiboard Screw, Direct Multipoint Screw, Magnet, Wood Screw, Flat]
//Diameter of the magnet (in mm)
Magnet_Diameter = 4.0; 
//Thickness of the magnet (in mm)
Magnet_Thickness = 1.5;
//Add a tolerance to the magnet hole to make it easier to insert the magnet.
Magnet_Tolerance = 0.1;
//Wood screw diameter (in mm)
Wood_Screw_Thread_Diameter = 3.5;
//Wood Screw Head Diameter (in mm)
Wood_Screw_Head_Diameter = 7;
//Wood Screw Head Height (in mm)
Wood_Screw_Head_Height = 1.75;

/*[Advanced Options]*/
//Units of measurement (in mm) for hole and length spacing. Multiboard is 25mm. Untested
Grid_Size = 25;
//Color of part (color names found at https://en.wikipedia.org/wiki/Web_colors)
Global_Color = "SlateBlue";

/*[Hidden]*/
channelWidth = Channel_Width_in_Units * Grid_Size;
baseHeight = 9.63;
topHeight = 10.968;
totalHeight = 17.4897; // Combined height
actualHeight = (totalHeight - 12) + Channel_Internal_Height; // Calculate height with selected Internal channel height
interlockOverlap = 3.09; //distance that the top and base overlap each other
interlockFromFloor = 6.533; //distance from the bottom of the base to the bottom of the top when interlocked
partSeparation = 10;
//length of channel in units (default unit is 25mm)
Channel_Length_Units = 6; 
cable_slot_limit = min(Cable_slot,(channelWidth - 10));

/*[Visual Options]*/
Debug_Show_Grid = false;

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
MultipointBase_Screw_Hole_Outer_Diameter = 16;


/*

***BEGIN DISPLAYS***

*/

//top 'L' piece
// Top channel
if(Base_Top_or_Both != "Base")
    difference(){
        // Offset piece
        color_this(Global_Color)
            back(30)zrot(180) {
            half_of(DOWN+RIGHT, s=Channel_Length_Units*Grid_Size*2)
                path_sweep(topProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", (Offset_to_Multiboard+actualHeight)*2+(Connector_channel_length * Grid_Size)*2]), anchor=TOP, orient=BOT);

        // Desk piece
        color_this(Global_Color)
            rot([180,-90,0])
            half_of(DOWN+RIGHT, s=Channel_Length_Units*Grid_Size*2)
                path_sweep(completeProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", (Thickness_of_Desk+actualHeight)*2]), anchor=TOP, orient=BOT);

        // Join piece
        color_this(Global_Color)
            up(Channel_Internal_Height+5.5)
            zrot(180)
                path_sweep(joinProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Channel_Internal_Height+5.5]), orient=BOT);
            };

    // Delete pieces
    // Inside
    color_this(Global_Color)
        back(30)zrot(180) {
        right(2)
        up((Thickness_of_Desk/2)+5.5)
        rot([180,-90,0])
            path_sweep(completeInside(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Thickness_of_Desk]), anchor=TOP, orient=BOT);
        };

    // Outside
    color_this(Global_Color)
        back(30)zrot(180) {
        up((Thickness_of_Desk/2)+5.5)
        rot([180,-90,0])
            path_sweep(completeOutside(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Thickness_of_Desk*2]), anchor=TOP, orient=BOT);

        };
    // Join Inside
    color_this(Global_Color)
        zrot(180) {
        up(Channel_Internal_Height+5.75)
        right(Channel_Internal_Height*1.5)
        fwd(30)
            path_sweep(joinInside(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Channel_Internal_Height ]), orient=BOT);
        };
    }


// Base units
if(Base_Top_or_Both != "Top")
    color_this(Global_Color)
    fwd(channelWidth - 50)zrot(180) {
        straightChannelBase(lengthMM = Connector_channel_length * Grid_Size, widthMM = channelWidth, heightMM = Channel_Internal_Height, anchor=BOT);
    };



/*

***BEGIN MODULES***

*/

//STRAIGHT CHANNELS
module straightChannelBase(lengthMM, widthMM, anchor, spin, orient,heightMM){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, baseHeight]){
        back(40)
        down(4.75)
        right((Offset_to_Multiboard+actualHeight)+(Connector_channel_length * Grid_Size))
        diff("holes")
        zrot(180, cp) path_sweep(baseProfile(widthMM = widthMM), turtle(["xmove", lengthMM + Offset_to_Multiboard]))
        tag("holes")  right(lengthMM/2) grid_copies(spacing=Grid_Size, inside=rect([lengthMM-1,Grid_Size*Channel_Width_in_Units-1])) 
            if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3.5-Base_Screw_Hole_Inner_Depth+0.02, d1=Base_Screw_Hole_Cone ? Base_Screw_Hole_Inner_Diameter : Base_Screw_Hole_Outer_Diameter, d2=Base_Screw_Hole_Outer_Diameter, $fn=25);
            else if(Mounting_Method == "Direct Multipoint Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3.5-Base_Screw_Hole_Inner_Depth+0.02, d1=Base_Screw_Hole_Cone ? Base_Screw_Hole_Inner_Diameter : MultipointBase_Screw_Hole_Outer_Diameter, d2=MultipointBase_Screw_Hole_Outer_Diameter, $fn=25);
            else if(Mounting_Method == "Magnet") up(Magnet_Thickness+Magnet_Tolerance-0.01) cyl(h=Magnet_Thickness+Magnet_Tolerance, d=Magnet_Diameter+Magnet_Tolerance, $fn=50, anchor=TOP);
            else if(Mounting_Method == "Wood Screw") up(3.5 - Wood_Screw_Head_Height) cyl(h=3.5 - Wood_Screw_Head_Height+0.05, d=Wood_Screw_Thread_Diameter, $fn=25, anchor=TOP)
                //wood screw head
                attach(TOP, BOT, overlap=0.01) cyl(h=Wood_Screw_Head_Height+0.05, d1=Wood_Screw_Thread_Diameter, d2=Wood_Screw_Head_Diameter, $fn=25);
            else if(Mounting_Method == "Flat") ; //do nothing
            //Default is Threaded Snap Connector
            else up(5.99) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=6, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, internal=true, bevel2 = true, blunt_start=false, anchor=TOP, $slop=Slop);
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

// BEGIN CUSTOM PROFILES

//take the two halves of complete and merge them
function completeProfile(widthMM, heightMM) =
    difference(
        union(
            left((widthMM-25)/2,completeProfileHalf(heightMM, widthMM)), 
            right((widthMM-25)/2,mirror([1,0],completeProfileHalf(heightMM, widthMM))) //fill middle if widening from standard 25mm
        ),
    back((heightMM-12)/2,rect([cable_slot_limit+0.02,heightMM]))  
    );


//take the two halves the base 'join piece' and merge them
function joinProfile(widthMM = 25, heightMM = 12) =
    difference(
        union(
                left((widthMM-25)/2,baseJoinHalf(heightMM)), 
                right((widthMM-25)/2,mirror([1,0],baseJoinHalf(heightMM))) //fill middle if widening from standard 25m
        ),
    back((heightMM-12)/2,rect([cable_slot_limit+0.02,heightMM])) 
    );

// Build the inside/outside delete part
function completeInside(widthMM, heightMM) =
    union(
        left((widthMM-25)/2,completeInsideHalf(heightMM, widthMM)), 
        right((widthMM-25)/2,mirror([1,0],completeInsideHalf(heightMM, widthMM))) //fill middle if widening from standard 25mm
    );

function completeOutside(widthMM, heightMM) =
    union(
        left((widthMM-25)/2,completeOutsideHalf(heightMM, widthMM)), 
        right((widthMM-25)/2,mirror([1,0],completeOutsideHalf(heightMM, widthMM)))
    );

function joinInside(widthMM, heightMM) =
    union(
        left((widthMM-25)/2,joinInsideHalf(heightMM, widthMM)), 
        right((widthMM-25)/2,mirror([1,0],joinInsideHalf(heightMM, widthMM)))
    );

// BEGIN COORDS  - Must match across all files

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

// BEGIN CUSTOM COORDS

// Desk edge 'Complete' profile
function completeProfileHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947, 
        [
            [0 + (widthMM - 25)/2,-4.447],
            [-8.5,-4.447],
            [-9.5,-3.447],
            [-9.5,5.7427 + (heightMM - 12)],
            [-7.7,7.5427 + (heightMM - 12)],
            [0 + (widthMM - 25)/2,7.5427 + (heightMM - 12)],
            [0 + (widthMM - 25)/2,9.554 + (heightMM - 12)],
            [-8.517,9.554 + (heightMM - 12)],
            [-12.517,5.554 + (heightMM - 12)],
            [-12.517,-4.448],
            [-10.517,-6.448],
            [-10.517,-7.947],
            [0 + (widthMM - 25)/2,-7.947],
        ]
);

// Extra bits to allign base and top neatly at the join
function baseJoinHalf(heightMM = 12) =
        fwd(-7.947,
        [
            [-9.5,6 + (heightMM - 12)],
            [-12.517,5.554 + (heightMM - 12)],
            [-12.517,-4.448],
            [-10.517,-6.448],
            [-10.517,-7.947],
            [-2.967,-7.947],
            [-9.5,-1.414]
        ]
);
// Delete inside 'Complete'
function completeInsideHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947,
        [
            [0 + (widthMM-25)/2,-4.447],
            [-8.5,-4.447],
            [-9.5,-3.447],
            [-9.5,0],
            [-9.5,5.7427 + (heightMM - 12)],
            [-7.7,7.5427 + (heightMM - 12)],
            [0 + (widthMM-25)/2,7.5427 + (heightMM - 12)]
        ]
);
// Delete outside 'Complete'
function completeOutsideHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947,
        [
            [-8.517,9.554],
            [-13.517,4.554],
            [-12.517,9.554],
        ]
);

// Delete inside 'Join'
function joinInsideHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947,
        [
            [0 + (widthMM-25)/2,-8],
            [-2.914,-8],
            [-9.5,-1.414],
            [-9.5,0],
            [-9.5,5.7427 + (heightMM - 12)],
            [-7.7,7.5427 + (heightMM - 12)],
            [0 + (widthMM-25)/2,7.5427 + (heightMM - 12)]
        ]
);


//calculate the max x and y points. Useful in calculating size of an object when the path are all positive variables originating from [0,0]
function maxX(path) = max([for (p = path) p[0]]) + abs(min([for (p = path) p[0]]));
function maxY(path) = max([for (p = path) p[1]]) + abs(min([for (p = path) p[1]]));



