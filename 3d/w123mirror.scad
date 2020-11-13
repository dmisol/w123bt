//RIGHTMIRROR = true;
//DRAWONLY = true;

PLATECOLOR = "lightgray";
RODCOLOR = "orange";
BOLTCOLOR = "yellow";
SERVOCOLOR = "brown";

thickness = 2;
gap = 0.5;
correction = 6; // (degrees), to preserve Servo1 from touching spring 

// to compute where the mirror meets the lever
Xa = 17.3;Ya = 15.8;
Xb = 43.6;Yb = 20.9;
contactAxis = [(Xb+Xa)/2,(Yb+Ya)/2,0];
beta = atan((Yb-Ya)/(Xb-Xa));

// servo1 params
H1 = 22;
D1 = 40;
Rs = 1;

// servo2 params
H2 = 8.5;
D2 = 28;
Rr= 1;


if(DRAWONLY){
    Plate();
    placeServo1vert();
    translate(contactAxis) rotate(180+beta-correction) translate([-(D1-30+16),0,H1])fork();
} else { // printing!
    // plate itself
    if(RIGHTMIRROR) mirror([1,0,0]) translate([-80,-20,0]) Plate();
    else translate([-80,-20,0]) Plate();
    
    // servo mounting
    if(RIGHTMIRROR) mirror([1,0,0]) 
        translate([-15,30,0])rotate(90+beta-correction,[0,0,1]) 
        translate([-50,-20,H1+2.5]) 
            rotate(180,[0,1,0]) translate([-50,-20,-H2]) placeServo1vert();
    else translate([-15,30,0])rotate(90+beta-correction,[0,0,1]) 
        translate([-50,-20,H1+2.5]) 
            rotate(180,[0,1,0]) translate([-50,-20,-H2]) placeServo1vert();
    
    translate([-70,-40,0] )halfFork(false,"lightblue");
    translate([-70,-60,0] )halfFork(true,"darkgray");
}

if(DRAWONLY) 
color("red") translate(contactAxis) {
    cylinder(r=0.2,h=40, $fn=8);
//    rotate(beta,[0,0,1]) cube([300,0.1,20],center=true);    // surface to contain the "ideal" axis
//    rotate(beta - correction,[0,0,1]) cube([300,0.1,20],center=true);   // the "real" axis we have to use
}



// models 
// -----------------------------------------------
module Plate(){
    scale = 0.08;   // ToDO: looks fair, but need to be verified, consts below depend on it
    Xm = 135.3;
    Ym = 40;
    Xc = 114.4;
    Yc = 62.5;
    
    module mirrorPlate(){
        module boltM3(){
            cylinder(r=1.45, h=30, $fn=8);
            cylinder(r1=4, r2=0, h=3);
        }
        
        color(PLATECOLOR) difference(){           
            union(){
                translate([-25,-176,0]) linear_extrude(height=thickness) 
                    scale([scale,scale,scale])
                        import("w123mirror.dxf", center=true);
                //mount4Servo1old();
                // to prevent servo1 from touching the spring
                translate(contactAxis+[0,6,-0.1]) cylinder(r1=10,r2=3,h=6);
            } 
            placeServo1vert(true);
            
            // to prevent servo1 from touching the spring
            translate(contactAxis+[0,6,-0.2]) boltM3();
        }
        placeServo2();
        if(DRAWONLY) {
            //placeServo1old(false);
            color(BOLTCOLOR) translate(contactAxis+[0,6,-0.2]) boltM3();
        }
    }
    
    module mounting(CENTER = 10, DELTA = 3){
        module inner(){
            R = 5;
            cylinder(r=3,h=10);
            translate([0,0,CENTER]) sphere(r=R);            // the ball itself
            translate([0,0,CENTER+DELTA+1]) sphere(r=R);    // to insert it
        } 
        color(PLATECOLOR) translate([Xm,Ym,0]) difference(){
            cylinder(h=(CENTER+DELTA), r1=9, r2=6.5);
            translate([0,0,15]) 
                rotate(-45,[0,0,1])cube([2,20,20],center=true);
            inner();
        }
    }
    
    module corner(){
        R=1.2;      // of a copper wire
        X = 20;
        Y=12;
        $fn=10;
        alpha = 43;
        module fix(){
            module wire(){
                translate([-1.5,X,thickness+0.5+R]) 
                    rotate(-8,[0,0,1])
                        rotate(90,[1,0,0]) cylinder(r=R,h=30);
            }            
            color(PLATECOLOR) difference(){
                translate([-X/2,-Y+7])cube([X,Y,thickness+0.5+2*R+1.5]);
                wire();
                mirror([1,0,0]) wire();
            }
            if(DRAWONLY) color("green") {
                wire();
                mirror([1,0,0]) wire();
            }
        }
        translate([Xc,Yc,0]) {//cylinder(r=1,h=10);
            rotate(alpha,[0,0,1]) {//cube([1,70,20],center=true);
                fix();
            }
        }
    }
    mirrorPlate();       
    mounting();
    corner();
}

module Servo1vert(space = false){
    if(space){
        translate([-7,-17,-5])cube([14,24,20]);
    } else {
        if(DRAWONLY) translate([0,-16,H1])
            rotate(-90,[1,0,0]) 
                servo90raw(false,false);
    
        color(SERVOCOLOR) difference(){
            union(){
                translate([-9,-5, H2]) cube([5,10,H1-H2+11]);
                translate([0,-5, H1+2]) cube([D2,10,9]);
                translate([-9,-5, H1+6]) cube([9+D2,10,5]);
                translate([D2-1.5,-5, H2+4]) cube([5,10,H1-H2+7]);
                translate([-9, 0, H2]) rotate(90,[0,1,0]) cylinder(r=5,h=2.7);
            }
            translate([13,0,H1+2]) rotate(90,[1,0,0]) cylinder(r=6,h=50,center=true);
            translate([D2-8,0,H1+2]) rotate(90,[1,0,0]) cylinder(r=6,h=50,center=true);
            translate([13,-5.2,H1+2]) cube([(D2-8-13),10.4,6]);
            
            translate([0,-16,H1])
                rotate(-90,[1,0,0]) 
                    servo90raw(true, false);   
            translate([32+D2,0,H2]) rotate(-90,[0,1,0]) servo90raw(true,true);
        } 
    }   
}

module placeServo2(){
    WITHGAP = 41.2;
    translate(contactAxis) 
    rotate(90+beta-correction,[0,0,1]) 
    translate([32+D2,-D1,H2]) rotate(-90,[0,1,0]) {
        difference(){
            union() { 
                translate([-H2,-15,12]) cube([H2+4,40,10]);
                translate([-H2,-15,0]) cube([H2-4,40,22]);
                
                translate([-H2, -4, D2+WITHGAP]) cube([H2,8,8]);
                translate([0, 0, D2+WITHGAP]) cylinder(r=4,h=8);
            }
            servo90raw(true,true);
        }
        if(DRAWONLY) servo90raw(true,true);
    }
}

module rod(){
    translate([0,0,-2.5]) cylinder(r=7.5/2,h=5);
    linear_extrude(height=2) polygon(points=[[0,-3],[18,-2.5],[18,2.5],[0,3]]);
}
module servo90raw(screws=true, rod=false){
    X = 12.6;
    A = 6.2;
    
    translate([-X/2,-A,0]){
        color("green"){
            cube([X,23,22.5]);
            translate([X/2,A,0]) {
                cylinder(r=6,h=27);
                cylinder(r=2.5,h=30);
            }
            translate([X/2,12,0]) cylinder(r=3,h=27);
            translate([0,-5,15.5]) cube([X,32.5,2.7]);   
            translate([4,-2,4]) cube([X-8,3,3]);// wires
            if(screws){
                translate([X/2,-3,6]) cylinder(r=1,h=24);// screw
                translate([X/2,-3+28.5,0]) cylinder(r=1,h=30);// screw
            }
        }
        if(DRAWONLY) color(RODCOLOR) translate([X/2,A,-10]) cylinder(r=0.1,h=95);
    }
    if(rod){
        color(RODCOLOR){
            translate([0,0,30]) rod();
            //cylinder(r=7.5/2,h=4.5);
            //translate([0,0,30]) linear_extrude(height=2) polygon(points=[[0,-3],[18,-2.5],[18,2.5],[0,3]]);
        }
        color("green") translate([0,0,30+D2]) cylinder(r=Rs, h=20, $fn=8);
    }
}

module servo2horiz(){
    difference(){
    union(){
        translate([11,0,H1]) rotate(180,[0,0,1]) rotate(90,[0,1,0]) servo90raw(true,false);
        translate([-5,-22,H2]) cube([10,34,(H1-H2)+8]);
        translate([0,-5,H2]) rotate(90,[1,0,0]) cylinder(r=5,h=34,center=true);
    }
    translate([-10,-23+6,0]) cube([20,23,20]);
    translate([11,0,H1-6.3-Rr]) rotate(90,[1,0,0]) cylinder(r=Rr,h=30,center=true);
}
if(DRAWONLY) translate([11,0,H1]) rotate(180,[0,0,1]) rotate(90,[0,1,0]) servo90raw(false,false);
}

module placeServo1vert(space = false){
    translate(contactAxis) 
    rotate(90+(beta-correction),[0,0,1]) 
    translate([0,-D1,0]) Servo1vert(space);
}


module halfFork(sh,col){
    G = 0.1;
    W = 2.6;
    
    color(col) difference(){
        union(){
            translate([-2,-5,0]) cube([5-G,10,10-G]);
            translate([-2,G,0]) cube([10,5-G,10-G]);
            translate([3,G,0]) cube([5,5-G,20]);
            if(sh) translate([3,W/2,0]) cube([D1-22,5-W/2,20]);
            else translate([3,W/2,0]) cube([D1-10,5-W/2,20]);
            
        }
        translate([0,0,10]) rotate(90,[0,1,0]) rod();   
        translate([-5,0,10]) cube([7.5,3.7,20]);
        translate([5,0,5]) rotate(90,[1,0,0]) cylinder(r=1,h=20,center=true,$fn=8);
        translate([5,0,20-5]) rotate(90,[1,0,0]) cylinder(r=1,h=20,center=true,$fn=8);
        translate([D1-30+16,0,10]) rotate(90,[1,0,0]) cylinder(r=1.2,h=20,center=true,$fn=8);  
    }
    if(DRAWONLY){ 
        color(RODCOLOR) translate([0,0,10]) rotate(90,[0,1,0]) rod(); 
        color(BOLTCOLOR) {
            translate([5,0,5]) rotate(90,[1,0,0]) cylinder(r=1,h=12,center=true,$fn=8);
            translate([5,-6,5]) rotate(90,[1,0,0]) cylinder(r=2.5,h=2,center=true,$fn=8);
        }
        if(!sh)
        color(BOLTCOLOR) {
            translate([D1-30+16,2,10]) rotate(90,[1,0,0]) cylinder(r=1.2,h=10,center=true,$fn=8);
            translate([D1-30+16,-2.5,10]) rotate(90,[1,0,0]) cylinder(r=3,h=2,center=true,$fn=16);
        }
    }
}

module fork(){
    translate([0,0,-10]) halfFork(false,"lightblue");
    rotate(180,[1,0,0]) translate([0,0,-10])halfFork(true,"darkgray");

}
