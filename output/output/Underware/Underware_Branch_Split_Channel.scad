/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model from Hands on Katie (https://handsonkatie.com/)
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

Change Log:
- 2024-12-06 
    - Initial release
- 2024-12-09
    - Fix to threading of snap connector by adding flare and new slop parameter
- 2024-12-29
    - New branch channel

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @cosmicdust on MakerWorld and @freakadings_1408562 on Printables for the idea of diagonals (forward and turn)
    @siyrahfall+1155967 on Printables for the idea of top exit holes
    @Lyric on Printables for the flush connector idea
    @fawix on GitHub for her contributions on parameter descriptors

*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Choose Part]*/
Base_Top_or_Both = "Both"; // [Base, Top, Both]

/*[Channel Shape]*/
//Width of straight channel in units (default unit is 25mm)
Straight_Channel_Width_in_Units = 1;
//Distance of straight section of channel (in units)
Straight_Section_Length_in_Units = 4;
//Width of branchg channel in units (default unit is 25mm)
Branch_Channel_Width_in_Units = 1;
//Height (Z axis) inside the channel (in mm)
Channel_Internal_Height = 12; //[12:6:72]
//Grid units to move over (X axis). Both sides will move over and away from the center by this amount
Branch_Units_Out = 1; //[1:1:10]
//Grid units to move up (Y axis)
Branch_Units_Up = 1;//[1:1:10]
//Grid units to move up (Y axis)
Branch_Units_Extra_Length = 0;//[0:1:10]




/*[Mounting Options]*/
//How do you intend to mount the channels to a surface such as Honeycomb Storage Wall or Multiboard? See options at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/
Mounting_Method = "Threaded Snap Connector"; //[Threaded Snap Connector, Direct Multiboard Screw, Magnet, Wood Screw, Flat]
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
//Slop in thread. Increase to make threading easier. Decrease to make threading harder.
Slop = 0.075;

/*[Hidden]*/
channelWidth = Straight_Channel_Width_in_Units * Grid_Size;
baseHeight = 9.63;
topHeight = 10.968;
interlockOverlap = 3.09; //distance that the top and base overlap each other
interlockFromFloor = 6.533; //distance from the bottom of the base to the bottom of the top when interlocked
partSeparation = 10;

//Disabling until further work
//Channel bifurcation ends with same direction when set to Forward or at 90 degrees angle if set to Turn
Y_Output_Direction = "Forward"; //[Forward, Turn]
//Straight distance on all 3 edges of the bifurcation. Unexpected behavior on wider channels may be resolved by changing this slider
Y_Straight_Distance = 12.5; //[12.5:12.5:100]

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

/*

***BEGIN DISPLAYS***

*/


if(Base_Top_or_Both != "Top")
    color_this(Global_Color)
        back(Straight_Section_Length_in_Units*Grid_Size/2)
            branchSplitChannelBase(widthMM = channelWidth, unitsOver = Branch_Units_Out, unitsUp = Branch_Units_Up, outputDirection = Y_Output_Direction, straightDistance = Y_Straight_Distance, anchor=BOT);

if(Base_Top_or_Both != "Base")
    color_this(Global_Color)
        fwd(Straight_Section_Length_in_Units*Grid_Size/2)
        zrot(180)            
            yChannelTop(widthMM = channelWidth, unitsOver = Branch_Units_Out, unitsUp = Branch_Units_Up, heightMM = Channel_Internal_Height, outputDirection = Y_Output_Direction, straightDistance = Y_Straight_Distance, anchor=TOP+RIGHT, orient=BOT);


/*

***BEGIN MODULES***

*/

module mountPoint(style = "Threaded Snap Connector"){
    if(Mounting_Method == "Direct Multiboard Screw") up(Base_Screw_Hole_Inner_Depth) cyl(h=8, d=Base_Screw_Hole_Inner_Diameter, $fn=25, anchor=TOP) attach(TOP, BOT, overlap=0.01) cyl(h=3, d=Base_Screw_Hole_Outer_Diameter, $fn=25);
    else if(Mounting_Method == "Magnet") up(Magnet_Thickness+Magnet_Tolerance-0.01) cyl(h=Magnet_Thickness+Magnet_Tolerance, d=Magnet_Diameter+Magnet_Tolerance, $fn=50, anchor=TOP);
    else if(Mounting_Method == "Wood Screw") up(3.5 - Wood_Screw_Head_Height) cyl(h=3.5 - Wood_Screw_Head_Height+0.05, d=Wood_Screw_Thread_Diameter, $fn=25, anchor=TOP)
        //wood screw head
        attach(TOP, BOT, overlap=0.01) cyl(h=Wood_Screw_Head_Height+0.05, d1=Wood_Screw_Thread_Diameter, d2=Wood_Screw_Head_Diameter, $fn=25);
    else if(Mounting_Method == "Flat") ; //do nothing
    //Default is Threaded Snap Connector
    else up(5.99) trapezoidal_threaded_rod(d=Outer_Diameter_Sm, l=6, pitch=Pitch_Sm, flank_angle = Flank_Angle_Sm, thread_depth = Thread_Depth_Sm, $fn=50, internal=true, bevel2 = true, blunt_start=false, anchor=TOP, $slop=Slop);
}

//Branch Split Channel Base
module branchSplitChannelBase(unitsOver = 1, unitsUp=3, outputDirection = "Forward", straightDistance = Grid_Size, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[unitsOver*Grid_Size*2+channelWidth,unitsUp*Grid_Size+straightDistance*2, baseHeight]){
        
        endPositionX = unitsOver * Grid_Size * Straight_Channel_Width_in_Units / 2 + Branch_Channel_Width_in_Units * Grid_Size/2;
        endPositionY = unitsUp*Grid_Size+Grid_Size+(Branch_Channel_Width_in_Units*Grid_Size-Grid_Size)+Branch_Units_Extra_Length*Grid_Size;
        fwd(unitsUp*Grid_Size/2+straightDistance)
        down(baseHeight/2)
            diff("holes channel_clear"){
                 //straight section
                 path_sweep(baseProfile(widthMM = widthMM), turtle(["ymove", Straight_Section_Length_in_Units*Grid_Size]));
                 //straight section clear
                 tag("channel_clear") fwd(0.01)path_sweep(baseDeleteProfile(widthMM = widthMM), turtle(["ymove", Straight_Section_Length_in_Units*Grid_Size+0.02]));
                 
                {
                    //branch channel
                    right_half(s=max(unitsUp*Grid_Size*4,unitsOver*Grid_Size*4)) {//s should be a number larger than twice the size of the object's largest axis. Thew some random numbers in here for now. If mirror issues surface, this is likely the culprit. 
                        path_sweep2d(baseProfile(widthMM = Branch_Channel_Width_in_Units*Grid_Size), 
                            path= outputDirection == "Forward" ? [
                                [0,0], //start
                                [0,straightDistance+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [endPositionX, endPositionY-straightDistance-Branch_Units_Extra_Length*Grid_Size+0.1], //movement to position before last straight
                                [endPositionX, endPositionY] //last position either out the angle or straight out
                            ] :
                            [ //90 degree path
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver * Grid_Size + Grid_Size / 2 - straightDistance, unitsUp * Grid_Size + Grid_Size / 2], //movement to position before last straight
                                [unitsOver*Grid_Size+Grid_Size/2,unitsUp*Grid_Size+Grid_Size/2] //last position either out the angle or straight out
                            ]
                            );
                    }
                    //branch channel clear
                    tag("channel_clear")
                        right_half(s=max(unitsUp*Grid_Size*4,unitsOver*Grid_Size*4)) {//s should be a number larger than twice the size of the object's largest axis. Thew some random numbers in here for now. If mirror issues surface, this is likely the culprit. 
                        path_sweep2d(baseDeleteProfile(widthMM = Branch_Channel_Width_in_Units*Grid_Size), 
                            path= outputDirection == "Forward" ? [
                                [0,-0.01], //start
                                [0,straightDistance+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [endPositionX, endPositionY-straightDistance-Branch_Units_Extra_Length*Grid_Size], //movement to position before last straight
                                [endPositionX, endPositionY] //last position either out the angle or straight out
                            ] :
                            [ //90 degree path
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver*Grid_Size+Grid_Size/2-straightDistance,unitsUp*Grid_Size+Grid_Size/2], //movement to position before last straight
                                [unitsOver*Grid_Size+Grid_Size/2,unitsUp*Grid_Size+Grid_Size/2] //last position either out the angle or straight out
                            ]
                            );
                    }}
                            //straight section holes
                            tag("holes") back(Grid_Size*Straight_Section_Length_in_Units*sign(unitsUp)/2)  grid_copies(spacing=Grid_Size, inside=rect([Grid_Size*Straight_Channel_Width_in_Units-1,Straight_Section_Length_in_Units*Grid_Size-1]))  down(0.01) 
                            mountPoint(Mounting_Method);
                            //outside holes forward option (right side)
                            tag("holes") 
                                if(outputDirection == "Forward")
                                    move_copies([
                                        [endPositionX, endPositionY-Grid_Size/2,-0.01],//right side
                                        [endPositionX*-1, endPositionY-Grid_Size/2,-0.01]
                                        ])
                                        xcopies(spacing = Grid_Size, n = Branch_Channel_Width_in_Units) //back(Units_Up*Grid_Size+Grid_Size*sign(unitsUp)-Grid_Size/2*sign(unitsUp)) //right(unitsOver*Grid_Size)down(0.01) 
                                            mountPoint(Mounting_Method);
                            //outside holes turn option 
                            tag("holes") 
                                if(outputDirection == "Turn") 
                                    move_copies([
                                        [unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp),-0.01],
                                        [-unitsOver*Grid_Size,unitsUp*Grid_Size+Grid_Size/2*sign(unitsUp),-0.01]
                                        ])
                                        ycopies(spacing = Grid_Size, n = Straight_Channel_Width_in_Units)// back(Units_Up*Grid_Size+Grid_Size/2*sign(unitsUp)) //right(unitsOver*Grid_Size)down(0.01) 
                                            mountPoint(Mounting_Method);
            if(Debug_Show_Grid)
                #back(12.5) back(12.5*Straight_Channel_Width_in_Units-12.5) grid_copies(spacing=Grid_Size, inside=rect([200,200]))cyl(h=8, d=7, $fn=25);//temporary 
            }
        children();
    }
}

module yChannelTop(unitsOver = 1, unitsUp=3, heightMM = 12, outputDirection = "Forward", straightDistance = Grid_Size, widthMM, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[unitsOver*Grid_Size*2+channelWidth,unitsUp*Grid_Size+straightDistance*2, topHeight + (heightMM-12)]){
        endPositionX = unitsOver * Grid_Size * Straight_Channel_Width_in_Units / 2 + Branch_Channel_Width_in_Units * Grid_Size/2;
        endPositionY = unitsUp*Grid_Size+Grid_Size+(Branch_Channel_Width_in_Units*Grid_Size-Grid_Size)+Branch_Units_Extra_Length*Grid_Size;

        fwd(unitsUp*Grid_Size/2+straightDistance)
        down((topHeight + (heightMM-12))/2)
            diff("holes channel_clear"){
                //straight section
                path_sweep(topProfile(widthMM = widthMM), turtle(["ymove", Straight_Section_Length_in_Units*Grid_Size]));
                //straight section clear
                tag("channel_clear") fwd(0.01)path_sweep(topDeleteProfile(widthMM = widthMM), turtle(["ymove", Straight_Section_Length_in_Units*Grid_Size+0.02]));
                {
                    //branch channel
                    right_half(s=max(unitsUp*Grid_Size*4,unitsOver*Grid_Size*4)) {//s should be a number larger than twice the size of the object's largest axis. Thew some random numbers in here for now. If mirror issues surface, this is likely the culprit. 
                        path_sweep2d(topProfile(widthMM = Branch_Channel_Width_in_Units*Grid_Size), 
                            path= outputDirection == "Forward" ? [
                                [0,0], //start
                                [0,straightDistance+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [endPositionX, endPositionY-straightDistance-Branch_Units_Extra_Length*Grid_Size+0.1], //movement to position before last straight
                                [endPositionX, endPositionY] //last position either out the angle or straight out
                            ] :
                            [ //90 degree path
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver * Grid_Size + Grid_Size / 2 - straightDistance, unitsUp * Grid_Size + Grid_Size / 2], //movement to position before last straight
                                [unitsOver*Grid_Size+Grid_Size/2,unitsUp*Grid_Size+Grid_Size/2] //last position either out the angle or straight out
                            ]
                        );
                    }
                    //branch channel delete
                    tag("channel_clear") 
                    right_half(s=max(unitsUp*Grid_Size*4,unitsOver*Grid_Size*4)) {//s should be a number larger than twice the size of the object's largest axis. Thew some random numbers in here for now. If mirror issues surface, this is likely the culprit. 
                        path_sweep2d(topDeleteProfile(widthMM = Branch_Channel_Width_in_Units*Grid_Size), 
                            path= outputDirection == "Forward" ? [
                                [0,0], //start
                                [0,straightDistance+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [endPositionX, endPositionY-straightDistance-Branch_Units_Extra_Length*Grid_Size+0.1], //movement to position before last straight
                                [endPositionX, endPositionY] //last position either out the angle or straight out
                            ] :
                            [ //90 degree path
                                [0,0], //start
                                [0,straightDistance*sign(unitsUp)+0.1], //distance forward or back. 0.05 is a subtle cheat that allows for a perfect side shift without a bad polygon
                                [unitsOver * Grid_Size + Grid_Size / 2 - straightDistance, unitsUp * Grid_Size + Grid_Size / 2], //movement to position before last straight
                                [unitsOver*Grid_Size+Grid_Size/2,unitsUp*Grid_Size+Grid_Size/2] //last position either out the angle or straight out
                            ]
                        );
                    }

                }

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




