// parameterized truss unit
//
// Copyright (c) 2022 Kazunori Ueda, All Rights Reserved.
// Released under the MIT license:
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the 
// "Software"), to deal in the Software without restriction, including 
// without limitation the rights to use, copy, modify, merge, publish, 
// distribute, sublicense, and/or sell copies of the Software, and to 
// permit persons to whom the Software is furnished to do so, subject to 
// the following conditions:
//
// The above copyright notice and this permission notice shall be 
// included in all copies or substantial portions of the Software.
//
// HE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

include <tsugite.scad>;
bw=4.8; // beam width
tw=6.0; // joint width (y-axis)
tw2=tw; // width of joint extension
td=4.8; // joint (tsugite) depth (z-axis)
tl=tw*1.75; // slope length (traditional standard: 1.75)
tl2=2; // end hook length
hh=tw/4-0.1; // end hook height
tx=tl+tl2+1; // minimal joint length / 2 (x-axis)
pw=3; // plug width
pd=1.6; // plug depth
ch=max(1.4, tw/4); //center hook height
d=-0.05; // basic slack
d1=-0.02; // center slack (possibly tigher than d)
d2=-td/20; // center slope
len=50; // unit length of truss triangle

// wall for ensuring the right shape of the far ends of joints
module wall() {
  linear_extrude(td) translate([0,-tw/2-2])
  polygon([[-1.6,0.4],[4,0.4],[4,1],[-1,1],
           [-1,1+tw],[4,1+tw],[4,1.6+tw],[-1.6,1.6+tw]]);
}

// joint with pad and optional wall  
module tsugite_pad(len,lr,wall) {
  tsugite(len,lr);
  translate([-lr*tx-4,-(2+lr+tw/2),0]) cube([8,tw+4,0.2]);
  if (wall == 1)
    rotate([0,0,90*(1-lr)]) translate([-tx,0]) wall();
}

module horizon(upside) {
  tsugite_pad(len,1,upside);
  translate([2*len,0])
  tsugite_pad(len,-1,1-upside);
  l = 2*len - 2*tx;
  translate([tx,-0.5*tw+upside*(tw-bw),0])
    cube([l,bw,td]);
  translate([tx,-0.5*tw,0]) cube([len/2-tx,tw,td]);
  translate([1.5*len,-0.5*tw,0]) cube([len/2-tx,tw,td]);
}

module slanted(x,y,angle,lr) {
  translate([x,y])
  rotate([0,0,angle]) translate([-len/2,0]) {
    tsugite_pad(len,lr,0);
  }
}

module slanted_full(x,y,angle) {
  translate([x,y])
    rotate([0,0,angle]) translate([0,-bw/2]) 
      cube([len,bw,td]);
}

// optional plates for additional components
plate_height = bw + sqrt(3)/2*6;
module plate1() {
  translate([-3,0,0]) cube([6,plate_height,td]);
}
module plate2() {
  translate([-3,plate_height-3,td/3]) cube([6,3,td/3]);
}

module truss(plate) {
  horizon(0); // lower horizontal beam
  translate([-len/2,sin(60)*len]) horizon(1); // upper horizontal beam
  slanted(0,sin(60)*len,60,1);  // left slanted joint
  slanted(2*len,sin(60)*len,60,-1);  // right slanted joint
  difference() {
    union() {
      slanted_full(0.5*len,0,120); // left slanted beam
      slanted_full(0.5*len,0,60);  // middle slanted beam
      if (plate==1) translate([0.5*len,0,0]) plate1();
    }
    if (plate==1) translate([0.5*len,0,0]) plate2();
  }
  slanted_full(1.5*len,0,120);     // right slanted beam
}

intersection() {
  truss(0);
//  cube([2*len,2*len,100], center=true); // for the right end
//  translate([2*len,0]) cube([2*len,2*len,100], center=true); // for the left end
}

// plugs (with two extras)
for(x=[1:8]) translate([6*x,-2*tw]) plug(2,3.5,-0.05);
 