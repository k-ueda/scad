// "tsugite" (joint) -- Okkake Daisen Tsugi
// adapted from the traditional Japanese wood construction technology
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

tw = 4.8; // joint (tsugite) width (y-axis)
tw2 = 4.8; // width of the beam to be connected
td = 4.8; // joint depth (z-axis)
tl = tw*1.75; // slope length (traditional standard: 1.75)
tl2 = 1.5; // end hook length
hh = tw/4-0.1; // end hook height
tx = tl+tl2+1; // minimal joint length / 2 (x-axis)
pw = 3; // plug width
pd = 1.6; // plug depth
ch = max(1.4, tw/4); //center hook height
d = -0.05; // basic slack for contacting faces (larger (towards 0) means tighter); 
         // needs careful adjustment so that the two pieces are joined firmly
         // (possibly with a plyer or a wooden hammer) but not too tightly
         // (in which case the joint might look non-straight)
d1 = -0.02; // center slack (possibly tigher than d)
d2 = -td/20; // center slope (traditional standard: -td/20)
len = 50;  // total joint length

module tsugite_noplug(h) {
  linear_extrude(height=h) 
    offset(delta=d)
    polygon([
      [d2/2,0], [d2/2,-ch/2],           // from center
      [tl,0], [tl+tl2,0], [tl+tl2,hh], // to the right
      [tl,hh], [tl,tw/2-d],            // right hook
      [tx-d,tw/2-d], [tx-d,-tw/2+d],   // top and right edge
      [-tl,-tw/2+d], [-tl,-hh],        // bottom edge
      [-(tl+tl2),-hh], [-(tl+tl2),0],  // left hook
      [-tl,0],[d2/2,ch/2]               // back to the center
    ]);
  // center slope
  translate([-d2/2,ch/2+d,0]) rotate([90,0,0])
  linear_extrude(height=ch)
    polygon([[d1,0],[d2+d,td],[d2+d,0]]);
}

module tsugite_plug(h) {
  difference() {
    tsugite_noplug(h);
    translate([tl/1.6,0,h/2])
    cube([pw,tw,pd],center=true);
    translate([-tl/1.6,0,h/2])
    cube([pw,tw,pd],center=true);
    }
}

module tsugite(len,lr) {  // lr = 1 (right half) or -1 (left half)
  translate([0,0,(1-lr)*td/2])
  rotate([(1-lr)*90,0]) scale([lr,1]) {
    tsugite_plug(td);
    linear_extrude(td)
      polygon([[tx,-tw/2],[len/2,-tw2/2],
               [len/2,tw2/2],[tx,tw/2]]);
  }
}

module plug(a,b,d) {
  cube([pw+a*d,tw+0.15,pd+b*d]);
}

// two halves with non-identical center slope directions
//tsugite(len,1);
//translate([0,10]) // commenting out this line would show the tightness of the joint
//  tsugite(len,-1);

// plugs of different sizes; choose tight ones.
// loose ones would make the joint significantly weaker;
// while too tight ones (in z-axis) would cause delamination
// parameters: p[serial number, x-axis tolerance, z-axis tolerance]
//for (p=[[0,3,4],[1,2,3],[2,1,3]])
//  for(x=[-1,1]) translate([x*tl/1.6-pw/2,-(p[0]+1.5)*(tw+1)])
//    plug(p[1],p[2],-0.05);

// ends for tensile test
$fn=36;
module end() {
  translate([0,0,td/2]) difference() {
    translate([-7,0,0]) cube([36,20,td],center=true);
    cylinder(d=6,h=td,center=true);
    for (i=[-1,1])
    translate([-25,i*(tw/2+12.5)]) cylinder(d=25,h=td,center=true);
  }
}

//translate([50,0]) end();
//translate([-50,10]) scale([-1,1]) end();

