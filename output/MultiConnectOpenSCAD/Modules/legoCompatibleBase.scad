include <BOSL2/std.scad>

/*[Base Parameters]*/
studsWide = 3;
studsDeep = 5;
//Diameter of each stud (in mm). Standard is 4.8mm
studDiameter = 4.8;
baseThickness = 2;
/*[Hidden]*/
studHeight = 1.8;
distanceBetweenStuds = 8;
studToSide = 7.9;

baseX = (studsWide-2)*distanceBetweenStuds+studToSide*2;
baseY = (studsDeep-2)*distanceBetweenStuds+studToSide*2;

cube([baseX,baseY,baseThickness]){
    position(TOP) grid_copies(n=[studsWide,studsDeep], spacing = 8) cylinder(h = studHeight, r = studDiameter/2, $fn=50);
attach(BOTTOM, TOP) 
        multiboardPushFit();
}

 module multiboardPushFit(){
    cylinder(d1=14.317,d2=14.612,h=6, $fn=8, spin=22.5, anchor=BOTTOM)
            align(BOTTOM) cylinder(d1=13.205, d2=14.317,h=.5, $fn=8);
}
