// parameterized space truss
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

// parameters for horizontal and diagonal beams and nodes (beam ends) 
bw = 4.8; // beam width (z-axis for diagonal beams)
bw2 = bw/2;
h = 50/sqrt(2);  // unit horizontal length
h2 = h*2;
u = h*sqrt(2); // beam length
eps1 = 0.1; // for combining diagonal beams
eps3 = 0.3; // for combining diagonal and non-diagonal beams
s = 1.4;  // end total thickness scale factor
s2 = 0.8; // end half thickness scale factor
t = 1.8; // thickness of peg
offset = -0.6; // offset of peg
eps4 = 0.06; // for pegs
pad = 0; // 1: print pads for tsugite ends; 0: no pad

include <tsugite.scad>;

// To print a upper/lower grid or diagonal beams, proceed as follows:
// 1. set the flag grid_or_diagonal to 1 or 2,
// 2. comment/uncomment the following assigments (lines 51-54) accordingly,
// 3a. change the for statement for diagonal beams (lines 144-145) , or
// 3b. change and/or comment/uncomment grid, bottom, bottom2, vjoint, hjoint calls
//     (lines 217-220, 233-236).

grid_or_diagonal = 1; // grid: 1; diagonal: 2;
nplugs = 8; // number of tsugite plugs to print
ntenon_plugs = 16; // number of tenon plugs to print

// note: if statement won't work for controlling assignment statements ...
// customization for grids; comment them out when grid_or_diagonal == 1
tw = 6.0; // making tsugite a bit wider (was: 4.8mm)
td = 5.4; // and thicker (was: 4.8mm)
// customization for diagonals; comment it out when grid_or_diagonal == 2
//tw2 = bw/sqrt(2);

// diagonal beam components
module convex_end() {  // outer corner with male joint
  difference() {
    union() {
      linear_extrude(bw)
        polygon([[-bw2,0],[bw2,0],[bw2,s2*bw-eps1],[-bw2,s2*bw-eps1]]); // inner
      linear_extrude(bw)
        polygon([[-bw2,bw],[-bw2,s*bw],[-bw2-(s-0.99)*bw,s*bw]]); // side
      linear_extrude(bw)
        polygon([[bw2,bw],[bw2,s*bw],[bw2+(s-0.99)*bw,s*bw]]);    // side
      linear_extrude(bw) 
       polygon([[-bw2-0.5,0.5],[bw2+0.5,0.5],[bw2+0.5,-bw2],[-bw2-0.5,-bw2]]); // outer
    }
    translate([0,offset]) linear_extrude(bw)
      polygon([[-bw2/2,0],[bw2/2,0],[bw2/2,t],[-bw2/2,t]]);
  }
}

module concave_end() {  // inner corner without joint
  linear_extrude(bw)
    polygon([[-bw2-(s-1)*bw,s*bw],[bw2+(s-1)*bw,s*bw],
             [bw2+(s-1)*bw,s2*bw+eps1],[-bw2-(s-1)*bw,s2*bw+eps1]]);
}

module diagonal() {  // diagonal beam for convex end
  linear_extrude(bw) 
    polygon([[bw2,0],[h-bw2,h-bw],[h-bw2,h],[bw2,bw]]);
}

module diagonal2() {  // diagonal beam for concave end
  linear_extrude(bw) 
    polygon([[bw2,t+offset],[bw2+t,t+offset],[h-bw2,h-bw],
             [h-bw2,h-t-offset],[h-bw2-t,h-t-offset],[bw2,bw]]);
}

module short_diagonal(w,eps) {  // end beam for convex end
  linear_extrude(bw+eps) 
    polygon([[bw2,0],[bw2+w,w],[bw2+w,s*bw],[bw2,s*bw]]);
}

module short_diagonal2(w,eps) {  // end beam for concave end
  linear_extrude(bw+eps) 
    polygon([[bw2,t+offset],[bw2+t,t+offset],[bw2+w,w],[bw2+w,s*bw],[bw2,s*bw]]);
}

module convex_up() { convex_end(); diagonal(); }
module convex_down() { translate([0,h]) scale([1,-1]) convex_up(); }
module convex(start,n,end) {
  if (start==1) { 
    rotate([0,0,-45]) translate([-u/2,0]) tsugite(u-10,1); }
  scale([-1,1]) short_diagonal(bw/2,0); convex_up(); 
  for (i=[1:1:n-1]) translate([i*h,0]) {  // the middle ":1" is to avoid warning for n=1
    if (i%2==0) convex_up(); else convex_down();
  }
  if (n%2==0) {
    translate([n*h,0]) { convex_end(); short_diagonal(bw/2,0); }
  } else {
    if (end==1) {
      translate([n*h,h]) rotate([0,0,-45]) translate([u/2,0]) tsugite(u-10,-1);
    }
    translate([n*h,h]) scale([1,-1]) { convex_end(); short_diagonal(bw/2,0); }
  }
}

module concave_up() { concave_end(); diagonal2(); }
module concave_down() { translate([0,h]) scale([1,-1]) concave_up(); }
module concave(start,n,end) {
  if (start==1) { 
    rotate([0,0,-45]) translate([-u/2,0]) tsugite(u-10,1); }
  scale([-1,1]) short_diagonal2(bw/2,0); concave_up();
  for (i=[1:1:n-1]) translate([i*h,0]) {
    if (i%2==0) concave_up(); else concave_down();
  }
  if (n%2==0) {
    translate([n*h,0]) { concave_end(); short_diagonal2(bw/2,0); }
  } else {
    if (end==1) {
      translate([n*h,h]) rotate([0,0,-45]) translate([u/2,0]) tsugite(u-10,-1);
    }
    translate([n*h,h]) scale([1,-1]) { concave_end(); short_diagonal2(bw/2,0); }
  }
}
// diagonal beam components end

// diagonal beams -- change # of beams and # of units per beam as necessary
ss = 11;
if (grid_or_diagonal == 2) {
// p: [x-offset, y-offset, left joint, # of units, right joint] 
  for (p=[[0,0,0,1,0],[2,0,0,2,0],[0,1,0,3,0],[0,2,0,4,0],
          [0,3,0,1,1],[0,4,0,3,1],[0,5,1,2,0],[0,6,1,3,1]]) 
    translate([h*p[0],2*ss*p[1]]) { 
      convex(p[2],p[3],p[4]); 
      translate([0,ss]) concave(p[2],p[3],p[4]);
    }

}

// upper and lower grid components
module node() {  // node with female joint
  translate([0,0,bw/2]) difference() {
    translate([0,0,t/2/2]) intersection() {            // octagon
//      rotate([0,0,45]) cube([2.635*bw,2.635*bw,bw+t/2], center=true);
      rotate([0,0,45]) cube([2.72*bw,2.72*bw,bw+t/2], center=true);
//      cube([2.72*bw,2.72*bw,bw+t/2],center=true);
      cube([2.85*bw,2.85*bw,bw+t/2],center=true);
    } 
    translate([0,0,0]) rotate([0,0,45])
      cube([bw+1.0+eps3,bw+eps3,bw+t+eps3], center=true); // center hole
    for (i=[0:3]) rotate([0,0,90*i+45])                // slopes
      translate([eps3/2,bw2+eps3/2,-eps3/2]) 
        rotate([90,0,0]) short_diagonal(5,eps3);
    rotate([0,0,45]) translate([0,0,t/2+offset])       // peg hole
      cube([bw2,20*bw,t],center=true);
  }
}

module hbeam() {
  translate([u/2,0,bw/2]) cube([u-2.35*bw,bw,bw],center=true);
}
module hbeam2() {
  translate([u/2,0.1,bw/2]) cube([u+bw,bw,bw],center=true);
}
module hbeam3() {
  translate([(u+2.35*bw+bw)/4,0,bw/2]) cube([(u-2.35*bw+bw)/2,bw,bw],center=true);
}
module hbeam4() {
  translate([u/4+2.35*bw/2,0,bw/2]) cube([u/2+0.1*bw,bw,bw],center=true);
}
//module hbeam_diag() {
//  translate([u/2,-u/2]) rotate([0,0,135])
//  translate([sqrt(2)*u/2,0]) cube([sqrt(2)*u-2*bw,bw,bw],center=true);
//}
//module square() {
//  for (x=[-u/2,u/2], y=[-u/2,u/2]) translate([x,y]) node();
//  for (y=[-u/2,u/2]) translate([-u/2,y]) hbeam();
//  for (x=[-u/2,u/2]) translate([x,-u/2]) rotate([0,0,90]) hbeam(); 
//  }

module grid(m,n,p) {  // p: polarity (use 1 and -1 for the two grids)
  for (j=[0:n], i=[0:m]) translate([i*u,j*u]) scale([p,1]) node();
  for (j=[0:n], i=[0:m-1]) translate([i*u,j*u]) hbeam();
  for (j=[0:n-1], i=[0:m]) translate([i*u,j*u]) rotate([0,0,90]) hbeam();
}

if (grid_or_diagonal == 1) {
  grid(2,2,-1);
//  grid(1,3,1);
}

// grid north and south ends
module bottom(m,n) {
  for (i=[0:m-1]) translate([i*u,n*u+(2.35/2+0.5)*bw]) hbeam2();
//  for (i=[0:m]) translate([i*u,n*u]) rotate([0,0,90]) hbeam3();
}
module bottom2(m,n) {
  for (i=[0:m-1]) translate([i*u,(n+0.5)*u+(2.35/2+0.5)*bw]) hbeam2();
  for (i=[0:m]) translate([i*u,n*u]) rotate([0,0,90]) hbeam4();
}

// optional additional beams on the ends
if (grid_or_diagonal == 1) {
//  translate([0,2*u]) bottom(2,0); // short north
//  scale([1,-1]) bottom(2,0); // short south
//  translate([0,2*u]) bottom2(2,0); // long north
//  scale([1,-1]) bottom2(2,0); // long south
}

// optional additional upward and downward joints 
module tsugite_pad(len,lr) {
  tsugite(len,lr);
  if (pad >= 1) 
    translate([-lr*tx-4,-(2+lr+tw/2),0]) cube([8,tw+4,0.2]);
}
module vjoint(p) { rotate([0,0,90]) tsugite_pad(u-2.35*bw,p); }
module hjoint(p) { tsugite_pad(u-2.35*bw,p); }

if (grid_or_diagonal == 1) {
  for (i=[0:2]) translate([i*u, 2.5*u]) vjoint(-1); // north joint
  for (i=[0:2]) translate([i*u, -0.5*u]) vjoint(1); // south joint
  for (i=[0:2]) translate([2.5*u, i*u]) hjoint(-1); // east joint
  for (i=[0:2]) translate([-0.5*u, i*u]) hjoint(1); // west joint
}

// end connector for long trusses
module end_connector() {
  z = 9.5;
  te = 2;
  translate([-te,0]) cube([te,1+bw,z]);
  translate([bw,0]) cube([te,1+bw,z]);
  translate([h-te,0]) cube([te,3,z]);
  translate([h+bw,0]) cube([te,3,z]);
  translate([-te,-1]) cube([h+bw+te+te,1,z]);
  translate([0,10]) cube([z,bw,2.2]);
  }
//end_connector();

// plugs for tenons; tune size (eps4) for the best firmness
module tenon_plug() {
  rotate([90,0,-90]) linear_extrude(bw2-3*eps4)
  polygon([[0,0],[1.3*bw,0],[1.3*bw,t-4*eps4],
           [0.8,t-4*eps4],[0,t-4*eps4-0.5]]);
}

for(x=[1:1:ntenon_plugs]) translate([6*(x-1)+bw2,-h-5]) tenon_plug();

// plugs for tsugite; carefully tune the first two args of plug!
translate([0,50*(grid_or_diagonal-1)])
  for(x=[1:1:nplugs]) translate([6*(x-1),-2*tw-h-10]) plug(2,3.5,-0.05);