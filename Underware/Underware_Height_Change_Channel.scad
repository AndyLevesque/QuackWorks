/*Created by Hands on Katie and BlackjackDuck (Andy)
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

Change Log:
- 2025-02-26 
    - Initial release
- 2025-07-12
    - Added 2.5 profile option (thanks Skaronator!)

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @cosmicdust on MakerWorld and @freakadings_1408562 on Printables for the idea of diagonals (forward and turn)
    @siyrahfall+1155967 on Printables for the idea of top exit holes
    @Lyric on Printables for the flush connector idea
    @fawix on GitHub for her contributions on parameter descriptors
    @Skaronator on GitHub for 2.5 profile update

*/


include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Choose Part]*/
Base_Top_or_Both = "Both"; // [Base, Top, Both]

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

/*[Channel Size]*/
//Width (X axis) of channel in units. Default unit is 25mm
Channel_Width_in_Units = 1;  // Ensure this is an integer
//Height (Z axis) inside the channel (in mm)
Channel_Internal_Height_1 = 18; //[12:6:72]
//Height (Z axis) inside the channel (in mm)
Channel_Internal_Height_2 = 12; //[12:6:72]
//Length (Y axis) of channel in units. Default unit is 25mm
Channel_Length_Units = 3; 
//The lateral distance of the rising portion of the channel
Rise_Distance = 25; //[12.5:12.5:100]


/*[Advanced Options]*/
//Units of measurement (in mm) for hole and length spacing. Multiboard is 25mm. Untested
Grid_Size = 25;
//Color of part (color names found at https://en.wikipedia.org/wiki/Web_colors)
Global_Color = "SlateBlue";
//0 to use Channel_Width_in_Units, otherwise use this value as internal width in MM
Override_Width_Using_Internal_MM = 0; 
//Slop in thread. Increase to make threading easier. Decrease to make threading harder.
Slop = 0.075;
//Thickness of the top channel (in mm)
Top_Thickness = 2; //[0.4:0.2:3]

/*[Beta Features - Please Send Feedback]*/
//BETA FEATURE: Change the profile type to an inverse connection where the top clips from the inside allowing stronger connections. Not backwards compatible. This profile is still likely to change.
Profile_Type = "Original"; // [Original, v2.5]

/*[Hidden]*/

//BETA FEATURE: For channels wider than 1 unit or taller than 18mm, reduce the top channel width to increase holding strength.
Flex_Compensation_Scaling = 0.99; // 
//BETA FEATURE - Original Profile Only: Change snap profile for strong holding strength. Not backwards compatible.
Additional_Holding_Strength = 0.0;//[0:0.1:1.5]


/*[Hidden]*/
channelWidth = Override_Width_Using_Internal_MM == 0 ? Channel_Width_in_Units * Grid_Size : Override_Width_Using_Internal_MM + 6;
baseHeight = 9.63;
topHeight = 10.968;
interlockOverlap = 3.09; //distance that the top and base overlap each other
interlockFromFloor = 6.533; //distance from the bottom of the base to the bottom of the top when interlocked
partSeparation = 10;

selectTopProfile = Profile_Type == "Original" ? topProfileHalf(Channel_Internal_Height_1) : topProfileInverseHalf(Channel_Internal_Height_1);
selectBaseProfile = Profile_Type == "Original" ? baseProfileHalf() : baseProfileInverseHalf();
//scale the top inward in some circumstances for a stronger connection
topScaling = Profile_Type == "Original" && (Channel_Width_in_Units > 1 || Channel_Internal_Height_1 > 18) ?  Flex_Compensation_Scaling : 1;
echo(str("Top Channel Scaling: ", topScaling));

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
MultipointBase_Screw_Hole_Outer_Diameter = 16;

if(Base_Top_or_Both != "Top")
color_this(Global_Color)
        left(Show_Attached ? 0 : channelWidth/2+5)
            straightChannelBase(lengthMM = Channel_Length_Units * Grid_Size, widthMM = channelWidth, anchor=BOT);

color_this(Global_Color)
        right(Show_Attached ? 0 : channelWidth/2+5)
straightHeightChangeChannelTop(lengthMM = Channel_Length_Units * Grid_Size, widthMM = channelWidth * topScaling, heightMM1 = Channel_Internal_Height_1, heightMM2 = Channel_Internal_Height_2, topThickness = Top_Thickness);

/*

***BEGIN MODULES***

*/

module straightHeightChangeChannelTop(lengthMM, widthMM, heightMM1 = 12, heightMM2 = 18, topThickness = 2, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, topHeight + (heightMM2-12)]){
        skin(
            [
                selectedTopProfile(heightMM1, widthMM, topThickness),
                selectedTopProfile(heightMM1, widthMM, topThickness),
                selectedTopProfile(heightMM2, widthMM, topThickness),
                selectedTopProfile(heightMM2, widthMM, topThickness)
            ],
            z=[0,lengthMM/2-Rise_Distance/2,lengthMM/2+Rise_Distance/2,lengthMM],
            slices = 0
            );
    children();
    }

}

//Return the appropriate top profile based on Profile_Type
function selectedTopProfile(h, w, t) =
    Profile_Type == "Original"
        ? newTopProfileFull(heightMM = h, totalWidth = w, topThickness = t)
        : topProfileInverseFull(widthMM = w, heightMM = h);


//STRAIGHT CHANNELS
module straightChannelBase(lengthMM, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[widthMM, lengthMM, baseHeight]){
        fwd(lengthMM/2) down(maxY(selectBaseProfile)/2)
        diff("holes")
        zrot(90) path_sweep(baseProfile(widthMM = widthMM), turtle(["xmove", lengthMM]))
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
        left((widthMM-25)/2,selectBaseProfile), 
        right((widthMM-25)/2,mirror([1,0],selectBaseProfile)), //fill middle if widening from standard 25mm
        back(3.5/2,rect([widthMM-25+0.02,3.5]))
    );

//take the two halves of base and merge them
function topProfile(widthMM = 25, heightMM = 12) = 
    union(
        left((widthMM-25)/2,selectTopProfile), 
        right((widthMM-25)/2,mirror([1,0],selectTopProfile)), //fill middle if widening from standard 25mm
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
        back(4.474 + (heightMM-12 - Additional_Holding_Strength)/2,rect([widthMM-25+0.02,8.988 + heightMM - 12 + Additional_Holding_Strength])) 
    );

function baseProfileHalf() = 
    fwd(-7.947, //take Katie's exact measurements for half the profile and use fwd to place flush on the Y axis
        //profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,-4.447], //Point 1
            [-8.5+Additional_Holding_Strength*1.5,-4.447], //Point 2
            [-9.5+Additional_Holding_Strength*1.5,-3.447],  //Point 3
            [-9.5+Additional_Holding_Strength*1.5,1.683], //Point 4
            [-10.517+Additional_Holding_Strength/2,1.683], //Point 5
            [-11.459+Additional_Holding_Strength/2,1.422], //Point 6
            [-11.459+Additional_Holding_Strength/2,-0.297], //Point 7
            [-11.166+Additional_Holding_Strength+Additional_Holding_Strength/2,-0.592-Additional_Holding_Strength/2], //Point 8 move
            [-11.166+Additional_Holding_Strength+Additional_Holding_Strength/2,-1.414-Additional_Holding_Strength], //Point 9 move
            [-11.666+Additional_Holding_Strength,-1.914-Additional_Holding_Strength], //Point 10 move
            [-12.517,-1.914-Additional_Holding_Strength], //Point 11 move
            [-12.517,-4.448], //Point 12
            [-10.517,-6.448], //Point 13
            [-10.517,-7.947], //Point 14
            [0,-7.947] //Point 15
        ]
);


//BEGIN New Profile

function newTopProfileHalf(heightMM = 12, totalWidth=25, topThickness = 2) =
        let(
            topChamfer = Additional_Holding_Strength < .4 ? 0 : 1,
            adjustedWidth =  totalWidth/2 - 12.5, //the profile is normalized off a 12.5 width
            //Thinkness adjustment to apply the 2.0mm thickness assumption in the coordinates below
            thicknessAdjustment = topThickness - 2,
            //additional adjustment for the chamfer portion
            deltaChamfer = (thicknessAdjustment) * sqrt(2) - thicknessAdjustment
        )
        //profile extracted from exact coordinates in Master Profile F360 sketch. Rounding was applied 2025-2-26
        [
            [8.5 + adjustedWidth + deltaChamfer , 11  + (heightMM - 12) + thicknessAdjustment],//Point 1 
            [12.5 + adjustedWidth, 7  + thicknessAdjustment+ (heightMM - 12) + deltaChamfer],//Point 2
            [12.5 + adjustedWidth, 0 - Additional_Holding_Strength],//Point 3
            [11.1 + adjustedWidth + Additional_Holding_Strength * 1.5 - topChamfer, 0 - Additional_Holding_Strength],//Point 4
            [11.1 + adjustedWidth + Additional_Holding_Strength * 1.5, 0.8 - Additional_Holding_Strength/2],//Point 5
            [11.5 + adjustedWidth + Additional_Holding_Strength/2, 1.1],//Point 6
            [11.5 + adjustedWidth + Additional_Holding_Strength/2, 2.8],//Point 7
            [10.5 + adjustedWidth + Additional_Holding_Strength/2, 3.1],//Point 8
            [10.5 + adjustedWidth + Additional_Holding_Strength/2, 6.1 + (heightMM - 12)],//Point 9
            [7.7 + adjustedWidth, 9 + (heightMM - 12)],//Point 10
        ];

// Mirror a single point about X=0 (i.e. negate its X coordinate).
function mirrorX(pt) = [ -pt[0], pt[1] ];

function newTopProfileFull(heightMM = 12, totalWidth = 25, topThickness = 2) =
    let(
        half = newTopProfileHalf(heightMM = heightMM, totalWidth = totalWidth, topThickness = topThickness)
    )
    concat(
        half,
        // Mirror in *reverse index* so the final perimeter is a continuous loop
        [ for(i = [len(half)-1 : -1 : 0]) mirrorX(half[i]) ]
    );


//END New Profile


topChamfer = Additional_Holding_Strength < .4 ? 0 : 1;

function topProfileHalf(heightMM = 12) =
        let(topChamfer = Additional_Holding_Strength < .4 ? 0 : 1)
        back(1.414,//profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,7.554 + (heightMM - 12)],//Point 1 (-0.017 per Katie's diagram. Moved to zero)
            [0,9.554 + (heightMM - 12)],//Point 2
            [-8.517,9.554 + (heightMM - 12)],//Point 3 
            [-12.517,5.554 + (heightMM - 12)],//Point 4
            [-12.517,-1.414-Additional_Holding_Strength],//Point 5
            [-11.166+Additional_Holding_Strength+Additional_Holding_Strength/2-topChamfer,-1.414-Additional_Holding_Strength],//Point 6
            [-11.166+Additional_Holding_Strength+Additional_Holding_Strength/2,-0.592-Additional_Holding_Strength/2],//Point 7
            [-11.459+Additional_Holding_Strength/2,-0.297],//Point 8
            [-11.459+Additional_Holding_Strength/2,1.422],//Point 9
            [-10.517+Additional_Holding_Strength/2,1.683],//Point 10
            [-10.517+Additional_Holding_Strength/2, 4.725 + (heightMM - 12)],//Point 11
            [-7.688,7.554 + (heightMM - 12)]//Point 12
        ]
        );

//An inside clamping profile alternative
function topProfileInverseHalf(heightMM = 12) =
        let(snapWallThickness = 1, snapCaptureStrength = 0.5)
        back(1.414,//profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions.
        [
            [0,7.554 + (heightMM - 12)],//Point 1 (-0.017 per Katie's diagram. Moved to zero)
            [0,9.554 + (heightMM - 12)],//Point 2
            [-8.517,9.554 + (heightMM - 12)],//Point 3 
            [-12.5,5.554 + (heightMM - 12)],//Point 4
            [-12.5,2], //snap ceiling outer
            [-11.5+snapWallThickness,1.8], //snap ceiling inner
            [-11.5+snapWallThickness,-0.3], //snap lock outer
            [-11.8+snapWallThickness-snapCaptureStrength,-0.6], //snap lock inner
            [-11.8+snapWallThickness-snapCaptureStrength,-1.4], //snap floor outer
            [-10.5+snapWallThickness-snapCaptureStrength,-2], //snap chamfer outer
            [-10.5+snapWallThickness*1.5,-2], //snap floor inner
            [-10.5+snapWallThickness*1.5, 4.725 + (heightMM - 12)],//Point 11
            [-7.688+snapWallThickness*1.5,7.554 + (heightMM - 12)]//Point 12
        ]
        );

function topProfileInverseFull(widthMM = 25, heightMM = 12) =
    union(
        left((widthMM-25)/2, topProfileInverseHalf(heightMM)),
        right((widthMM-25)/2, mirror([1,0], topProfileInverseHalf(heightMM))),
        back(topHeight-1 + heightMM-12 , rect([widthMM-25+0.02,2]))
    );

function baseProfileInverseHalf() = 
    let(snapWallThickness = 1, snapCaptureStrength = 0.5, baseChamfer = 0.5)
    fwd(-7.947, //take Katie's exact measurements for half the profile and use fwd to place flush on the Y axis
        //profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,-4.447], //Point 1
            [-8.5,-4.447], //Point 2
            [-10+snapWallThickness,-3.447],  //Point 3
            [-10+snapWallThickness,-2.4], //snap floor inner
            [-11.8+snapWallThickness-snapCaptureStrength,-2.4], //snap floor outer
            [-11.8+snapWallThickness-snapCaptureStrength,-0.6],//snap lock inner
            [-11.5+snapWallThickness,-0.3],//snap lock outer
            [-11.5+snapWallThickness,1.4-baseChamfer],//snap ceiling inner
            [-11.7,1.683],//snap ceiling chamfer point
            [-12.5,1.683], //snap ceiling outer
            [-12.5,-4.448], //Point 12
            [-10.5,-6.448], //Point 13
            [-10.5,-7.947], //Point 14
            [0,-7.947] //Point 15
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


