 //credit to Evil_K9
 
 module multiboard_push_fit(){
    push_fit_height = 6;
    // Push fit walls are 13.5mm apart at the object, 13.227mm apart after 6mm depth
    rotate([0,0,22.5])
        cylinder(d1=14.317,d2=14.612,h=push_fit_height, $fn=8);
    translate([0,0,-.5])
        // A short slanted cylinder to make the push fit easier to insert
        rotate([0,0,22.5])
            color("blue")
            cylinder(d1=13.205, d2=14.317,h=.5, $fn=8);
}

 module multiboardPushFitBOSL2(){
    cylinder(d1=14.317,d2=14.612,h=6, $fn=8, spin=22.5, anchor=BOTTOM)
            align(BOTTOM) cylinder(d1=13.205, d2=14.317,h=.5, $fn=8);
}

