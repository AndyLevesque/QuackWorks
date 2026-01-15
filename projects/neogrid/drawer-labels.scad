/*Created by BlackjackDuck (Andy) and Hands on Katie.
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Documentation available at https://handsonkatie.com/

Change Log:
- 2025-05-22 - Initial Release

Credit to 
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/*[Mounting]*/
Mount_Type = "Hook"; //[Hook, Double-Sided Tape]
//Thickness (mm) of the drawer
Drawer_Thickness = 16; //0.1
//If supporting with double-sided tape or 3M strips, this is the recess depth (recommend no more than half of the tape thickness)
Double_Sided_Tape_Recess = 0; //0.1

/*[Dimensions]*/

//The height (mm) of the label itself.
Label_Height = 25;
//The total width (mm) of the label holder (actual visible amount of label will be less the borders)
Label_Holder_Width = 80; 
//The thickness (mm) of the space available for the label to slide in.
Label_Thickness = 1; //0.1

/*[Style and Borders]*/
//Total visible border above and below the label (mm).
Top_and_Bottom_Border_Height = 6.5; //[3 : 0.1 : 20]
Left_and_Right_Border_Width = 3; //[1 : 0.1 : 20]
Top_and_Bottom_Chamfers = true;
Label_Holder_Color = "#dadada"; // color

View_Window_Style = "Chamfered"; //[Squared, Chamfered, Rounded]
View_Window_Chamfer_or_Rounding_Amount = 2;

/*[Drawer Handle (Optional)]*/
Drawer_Handle_Style = "None"; //[None, Squared]
//If drawer handle is used, drop the label by this amount (mm) so the label may still be seen.
Additional_Label__Drop = 10;
Drawer_Handle_Thickness = 2;
Drawer_Handle_Depth = 15;
Drawer_Handle_Lip_Height = 6;

/*[Printed Label (Optional)]*/
Add_Printed_Label = false;
textFont="Monsterrat:style=Bold"; // font
Line_1_Text = "Example";
Line_1_Text_Height = 6;
Line_1_Color = "#000000"; // color
//Remove to center text for line 1
Line_2_Text = "";
Line_2_Text_Height = 8;
Line_2_Color = "#000000"; // color
Label_Background_Color = "#ffffff"; // color

/*[Screw Mounting (Optional)]*/
Screw_Mounting_Location = "None";// [None, Behind Label, Back of Hook]
//Distance (mm) between the center of the screw holes. Set to zero for a single screw hole.
Distance_Between_Screws_Center_to_Center = 60;
Screw_Outer_Thread_Diameter = 4.1;
Screw_Head_Diameter = 7.2;
//Depth before hole starts to chamfer in. Recommend zero as most all of these parts are very thin and there's no room to chamfer.
Screw_Head_Inset = 0;

/*[Advanced]*/
//Thickness (mm) for all sections of the label holder unless otherwise defined. This will also be the thickness in front of and behind the inserted label.
Holder_General_Thickness = 1; //0.1
Holder_Back_Thickness = 1.2; //0.1
//Additional height (mm) added to the label height for easier insertion
Label_Buffer_Height = 1; //0.1
//The top and bottom border padding (mm) that helps hold the label in. 
Label_Vertical_Capture = 1;
//Height (mm) that the back of the holder drops down into the drawer
Drawer_Back_Dropdown_Height = 20;

/*[Debug]*/
Print_Orientation = true;
Disable_Colors = false;

/*[Hidden]*/
//The chamfer on the right of the label insert used to ease inserting the label
Label_Insert_Chamfer = 0.5; //0.1

labelAdditionalDropCalculated = Drawer_Handle_Style == "None" ? 0 : Additional_Label__Drop;

Thickness_in_Front_of_Label = Holder_General_Thickness;
Thickness_Behind_Label= Holder_General_Thickness;

Mount_Outer_Chamfers = 1;

viewWindowWidth = Label_Holder_Width - Left_and_Right_Border_Width * 2;
viewWindowHeight = Label_Height - Label_Vertical_Capture * 2;

totalFrontHeight = viewWindowHeight + Top_and_Bottom_Border_Height*2 + labelAdditionalDropCalculated;
totalFrontThickness = Thickness_in_Front_of_Label + Thickness_Behind_Label + Label_Thickness + (Mount_Type == "Double-Sided Tape" ? Double_Sided_Tape_Recess : 0);

totalHolderDepth = totalFrontThickness + Drawer_Thickness + Holder_Back_Thickness + (Drawer_Handle_Style == "Squared" ? Drawer_Handle_Depth : 0);

echo(str("Total Front Thickness: ", totalFrontThickness));
echo(str("Total Front Height: ", totalFrontHeight));
echo(str("Total Holder Depth: ", totalHolderDepth));


drawerLabelHolder();

if(Add_Printed_Label && Print_Orientation)
    fwd(Drawer_Handle_Depth + Label_Height / 2 + 5)
        printedLabel(anchor=BOT);


//BEGIN MODULES

module drawerLabelHolder(){
    //main drawer label holder
    recolor(Disable_Colors ? undef : Label_Holder_Color)
    diff()
        //holder (front/main) section
        cuboid([Label_Holder_Width, totalFrontThickness, totalFrontHeight], chamfer=Top_and_Bottom_Chamfers ? Mount_Outer_Chamfers : 0, edges = Drawer_Handle_Style == "None" ? [TOP+FRONT, BOT+FRONT] : BOT+FRONT, anchor=Print_Orientation ? LEFT : BOT, orient=Print_Orientation ? LEFT : UP){
            //mount top section
            if(Mount_Type == "Hook")
            attach(BACK, FRONT, align=TOP, overlap = 0.01)
                cuboid([Label_Holder_Width, Drawer_Thickness + Holder_Back_Thickness + Double_Sided_Tape_Recess, Holder_General_Thickness], chamfer=Mount_Outer_Chamfers, edges=TOP+BACK)
                    //mount back section
                    attach(BOT, TOP, align=BACK, overlap=0.01)
                        cuboid([Label_Holder_Width, Holder_Back_Thickness + Double_Sided_Tape_Recess, Drawer_Back_Dropdown_Height]){
                            //screw mounts
                            if(Screw_Mounting_Location == "Back of Hook")
                                xcopies(spacing = Distance_Between_Screws_Center_to_Center)
                                    attach(BACK, TOP, inside=true, shiftout=0.02)
                                        screwHole(depth = Thickness_Behind_Label);
                            if(Double_Sided_Tape_Recess > 0)
                                attach(FRONT, FRONT, inside=true, shiftout = 0.01)
                                    cuboid([Label_Holder_Width - 5, Double_Sided_Tape_Recess, Drawer_Back_Dropdown_Height - 5]);
                        }
            //Holder view window
            down(labelAdditionalDropCalculated/2)
            attach(FRONT, FRONT, inside=true, shiftout=0.01)
                cuboid([viewWindowWidth, Thickness_in_Front_of_Label + 0.02, viewWindowHeight], chamfer = View_Window_Style == "Chamfered" ? View_Window_Chamfer_or_Rounding_Amount : 0, rounding = View_Window_Style == "Rounded" ? View_Window_Chamfer_or_Rounding_Amount : 0, except_edges = [FRONT, BACK], $fn = 30);
            //Label Insert
            down(labelAdditionalDropCalculated/2) right(Holder_General_Thickness) fwd(-Thickness_in_Front_of_Label)
                attach(FRONT, FRONT, inside=true, align=LEFT)
                    cuboid([Label_Holder_Width - Holder_General_Thickness + 0.01, Label_Thickness, Label_Height + Label_Buffer_Height]){
                        //label insert chamfer
                        color(Disable_Colors ? undef : Label_Holder_Color)
                        edge_profile_asym([RIGHT], flip=true, corner_type="sharp")
                            xflip() mask2d_chamfer(Label_Insert_Chamfer);
                        if(Screw_Mounting_Location == "Behind Label"){
                            xcopies(spacing = Distance_Between_Screws_Center_to_Center)
                                attach(BACK, TOP, overlap=0.01)
                                    screwHole(depth = Thickness_Behind_Label);
                        }
                        if(!Print_Orientation){
                            tag("keep")
                                rot([90,0,180])
                                printedLabel();
                        }
                    }
            //Front part Double-sided tape recess
            if(Double_Sided_Tape_Recess > 0 && Mount_Type == "Double-Sided Tape")
                attach(BACK, FRONT, inside=true, shiftout = 0.01)
                    cuboid([Label_Holder_Width - 5, Double_Sided_Tape_Recess, totalFrontHeight - 5]);
            //Drawer Handle
            if(Drawer_Handle_Style == "Squared")
                attach(FRONT, BACK, align=TOP, overlap=0.01)
                    drawerHandle();
        }
    }

module drawerHandle(anchor=CENTER,spin=0,orient=UP){
    //top part that mounts to the label holder
    cuboid([Label_Holder_Width, Drawer_Handle_Depth, Drawer_Handle_Thickness], chamfer=2, edges=FRONT+TOP)
        attach(BOT, TOP, align=FRONT, overlap=0.01)
            //drop section
            cuboid([Label_Holder_Width, Drawer_Handle_Thickness, Drawer_Handle_Lip_Height], rounding = Drawer_Handle_Thickness/2, edges=[BOT+FRONT, BOT+BACK], $fn=30)
                //inside chamfer front strength
                tag("keep")
                edge_profile_asym([TOP+BACK], corner_type="sharp")
                    xflip() mask2d_chamfer(2);
}

module screwHole(depth = Holder_General_Thickness, anchor=CENTER,spin=0,orient=UP){
    $fn = 30;
    //head
    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset > 0 ? Screw_Head_Inset : 0.01, anchor=anchor, spin=spin, orient=orient){
        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Outer_Thread_Diameter, h=Screw_Head_Diameter == Screw_Outer_Thread_Diameter ? 0.01 : sqrt((Screw_Head_Diameter/2-Screw_Outer_Thread_Diameter/2)^2))
            attach(BOT, TOP) cyl(d=Screw_Outer_Thread_Diameter, h=depth+0.02);
        children();
    }
}

module printedLabel(textLine1 = Line_1_Text, textLine2 = Line_2_Text, anchor=CENTER,spin=0,orient=UP){
    printedLabelThickness = Label_Thickness - 0.2;
    color_this(Disable_Colors ? undef : Label_Background_Color)
    cuboid([Label_Holder_Width - Holder_General_Thickness * 2, Label_Height - 0.4, printedLabelThickness], chamfer = 0.2, edges=[BOT, LEFT, RIGHT], anchor=anchor, spin=spin, orient=orient){
        children();
        if(textLine2 == "")
            //line 1
            color_this(Disable_Colors ? undef : Line_1_Color)
            down(0.01)
            mirror([1,0,0])
            text3d(textLine1, size=Line_1_Text_Height, font=textFont, h=printedLabelThickness+0.03, anchor=CENTER, atype="ycenter");
        else
            color_this(Disable_Colors ? undef : Line_2_Color)
            down(0.01)
            mirror([1,0,0])
            ydistribute(sizes = [Line_1_Text_Height, Line_2_Text_Height], spacing = 1){
                text3d(textLine2, size=Line_2_Text_Height, font=textFont, h=printedLabelThickness+0.03, anchor=CENTER, atype="ycenter");
                text3d(textLine1, size=Line_1_Text_Height, font=textFont, h=printedLabelThickness+0.03, anchor=CENTER, atype="ycenter");
                
            }
    }

}