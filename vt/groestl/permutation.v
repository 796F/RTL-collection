//////////////////////////////////////////////////////////////////////////
//2010 CESCA @ Virginia Tech
//////////////////////////////////////////////////////////////////////////
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//////////////////////////////////////////////////////////////////////////
module Permute(
               x, 
               y, 
               round,
               mode);

input  [511:0] x;
output [511:0] y;
input          mode;
input  [  7:0] round;

wire [7:0] x00, x08, x10, x18, x20, x28, x30, x38;
wire [7:0] x01, x09, x11, x19, x21, x29, x31, x39;
wire [7:0] x02, x0a, x12, x1a, x22, x2a, x32, x3a;
wire [7:0] x03, x0b, x13, x1b, x23, x2b, x33, x3b;
wire [7:0] x04, x0c, x14, x1c, x24, x2c, x34, x3c;
wire [7:0] x05, x0d, x15, x1d, x25, x2d, x35, x3d;
wire [7:0] x06, x0e, x16, x1e, x26, x2e, x36, x3e;
wire [7:0] x07, x0f, x17, x1f, x27, x2f, x37, x3f;

wire [7:0] sr00, sr08, sr10, sr18, sr20, sr28, sr30, sr38;
wire [7:0] sr01, sr09, sr11, sr19, sr21, sr29, sr31, sr39;
wire [7:0] sr02, sr0a, sr12, sr1a, sr22, sr2a, sr32, sr3a;
wire [7:0] sr03, sr0b, sr13, sr1b, sr23, sr2b, sr33, sr3b;
wire [7:0] sr04, sr0c, sr14, sr1c, sr24, sr2c, sr34, sr3c;
wire [7:0] sr05, sr0d, sr15, sr1d, sr25, sr2d, sr35, sr3d;
wire [7:0] sr06, sr0e, sr16, sr1e, sr26, sr2e, sr36, sr3e;
wire [7:0] sr07, sr0f, sr17, sr1f, sr27, sr2f, sr37, sr3f;

wire [7:0] sb00, sb08, sb10, sb18, sb20, sb28, sb30, sb38;
wire [7:0] sb01, sb09, sb11, sb19, sb21, sb29, sb31, sb39;
wire [7:0] sb02, sb0a, sb12, sb1a, sb22, sb2a, sb32, sb3a;
wire [7:0] sb03, sb0b, sb13, sb1b, sb23, sb2b, sb33, sb3b;
wire [7:0] sb04, sb0c, sb14, sb1c, sb24, sb2c, sb34, sb3c;
wire [7:0] sb05, sb0d, sb15, sb1d, sb25, sb2d, sb35, sb3d;
wire [7:0] sb06, sb0e, sb16, sb1e, sb26, sb2e, sb36, sb3e;
wire [7:0] sb07, sb0f, sb17, sb1f, sb27, sb2f, sb37, sb3f;

wire [7:0] y00, y08, y10, y18, y20, y28, y30, y38;
wire [7:0] y01, y09, y11, y19, y21, y29, y31, y39;
wire [7:0] y02, y0a, y12, y1a, y22, y2a, y32, y3a;
wire [7:0] y03, y0b, y13, y1b, y23, y2b, y33, y3b;
wire [7:0] y04, y0c, y14, y1c, y24, y2c, y34, y3c;
wire [7:0] y05, y0d, y15, y1d, y25, y2d, y35, y3d;
wire [7:0] y06, y0e, y16, y1e, y26, y2e, y36, y3e;
wire [7:0] y07, y0f, y17, y1f, y27, y2f, y37, y3f;

//assignment x00-3f
assign x00 = x[511:504];
assign x01 = x[503:496];
assign x02 = x[495:488];
assign x03 = x[487:480];
assign x04 = x[479:472];
assign x05 = x[471:464];
assign x06 = x[463:456];
assign x07 = x[455:448];
assign x08 = x[447:440];
assign x09 = x[439:432];
assign x0a = x[431:424];
assign x0b = x[423:416];
assign x0c = x[415:408];
assign x0d = x[407:400];
assign x0e = x[399:392];
assign x0f = x[391:384];
assign x10 = x[383:376];
assign x11 = x[375:368];
assign x12 = x[367:360];
assign x13 = x[359:352];
assign x14 = x[351:344];
assign x15 = x[343:336];
assign x16 = x[335:328];
assign x17 = x[327:320];
assign x18 = x[319:312];
assign x19 = x[311:304];
assign x1a = x[303:296];
assign x1b = x[295:288];
assign x1c = x[287:280];
assign x1d = x[279:272];
assign x1e = x[271:264];
assign x1f = x[263:256];
assign x20 = x[255:248];
assign x21 = x[247:240];
assign x22 = x[239:232];
assign x23 = x[231:224];
assign x24 = x[223:216];
assign x25 = x[215:208];
assign x26 = x[207:200];
assign x27 = x[199:192];
assign x28 = x[191:184];
assign x29 = x[183:176];
assign x2a = x[175:168];
assign x2b = x[167:160];
assign x2c = x[159:152];
assign x2d = x[151:144];
assign x2e = x[143:136];
assign x2f = x[135:128];
assign x30 = x[127:120];
assign x31 = x[119:112];
assign x32 = x[111:104];
assign x33 = x[103: 96];
assign x34 = x[ 95: 88];
assign x35 = x[ 87: 80];
assign x36 = x[ 79: 72];
assign x37 = x[ 71: 64];
assign x38 = x[ 63: 56];
assign x39 = x[ 55: 48];
assign x3a = x[ 47: 40];
assign x3b = x[ 39: 32];
assign x3c = x[ 31: 24];
assign x3d = x[ 23: 16];
assign x3e = x[ 15:  8];
assign x3f = x[  7:  0];

//assignment y
assign y = { y00, y01, y02, y03, y04, y05, y06, y07,
             y08, y09, y0a, y0b, y0c, y0d, y0e, y0f,
             y10, y11, y12, y13, y14, y15, y16, y17,
             y18, y19, y1a, y1b, y1c, y1d, y1e, y1f,
             y20, y21, y22, y23, y24, y25, y26, y27,
             y28, y29, y2a, y2b, y2c, y2d, y2e, y2f,
             y30, y31, y32, y33, y34, y35, y36, y37,
             y38, y39, y3a, y3b, y3c, y3d, y3e, y3f};

wire [7:0] addconst00, addconst07;
assign addconst00 = (mode)? x00 ^ round : x00;
assign addconst07 = (mode)? x07 : ~(x07 ^ round);

//subbyte
SubBytes subbytes(addconst00, x08, x10, x18, x20, x28, x30, x38,
                         x01, x09, x11, x19, x21, x29, x31, x39,
                         x02, x0a, x12, x1a, x22, x2a, x32, x3a,
                         x03, x0b, x13, x1b, x23, x2b, x33, x3b,
                         x04, x0c, x14, x1c, x24, x2c, x34, x3c,
                         x05, x0d, x15, x1d, x25, x2d, x35, x3d,
                         x06, x0e, x16, x1e, x26, x2e, x36, x3e,
                  addconst07, x0f, x17, x1f, x27, x2f, x37, x3f,
                  sb00, sb08, sb10, sb18, sb20, sb28, sb30, sb38,
                  sb01, sb09, sb11, sb19, sb21, sb29, sb31, sb39,
                  sb02, sb0a, sb12, sb1a, sb22, sb2a, sb32, sb3a,
                  sb03, sb0b, sb13, sb1b, sb23, sb2b, sb33, sb3b,
                  sb04, sb0c, sb14, sb1c, sb24, sb2c, sb34, sb3c,
                  sb05, sb0d, sb15, sb1d, sb25, sb2d, sb35, sb3d,
                  sb06, sb0e, sb16, sb1e, sb26, sb2e, sb36, sb3e,
                  sb07, sb0f, sb17, sb1f, sb27, sb2f, sb37, sb3f);
//shiftrow
assign sr00 = sb00;
assign sr01 = sb09;
assign sr02 = sb12;
assign sr03 = sb1b;
assign sr04 = sb24;
assign sr05 = sb2d;
assign sr06 = sb36;
assign sr07 = sb3f;
assign sr08 = sb08;
assign sr09 = sb11;
assign sr0a = sb1a;
assign sr0b = sb23;
assign sr0c = sb2c;
assign sr0d = sb35;
assign sr0e = sb3e;
assign sr0f = sb07;
assign sr10 = sb10;
assign sr11 = sb19;
assign sr12 = sb22;
assign sr13 = sb2b;
assign sr14 = sb34;
assign sr15 = sb3d;
assign sr16 = sb06;
assign sr17 = sb0f;
assign sr18 = sb18;
assign sr19 = sb21;
assign sr1a = sb2a;
assign sr1b = sb33;
assign sr1c = sb3c;
assign sr1d = sb05;
assign sr1e = sb0e;
assign sr1f = sb17;
assign sr20 = sb20;
assign sr21 = sb29;
assign sr22 = sb32;
assign sr23 = sb3b;
assign sr24 = sb04;
assign sr25 = sb0d;
assign sr26 = sb16;
assign sr27 = sb1f;
assign sr28 = sb28;
assign sr29 = sb31;
assign sr2a = sb3a;
assign sr2b = sb03;
assign sr2c = sb0c;
assign sr2d = sb15;
assign sr2e = sb1e;
assign sr2f = sb27;
assign sr30 = sb30;
assign sr31 = sb39;
assign sr32 = sb02;
assign sr33 = sb0b;
assign sr34 = sb14;
assign sr35 = sb1d;
assign sr36 = sb26;
assign sr37 = sb2f;
assign sr38 = sb38;
assign sr39 = sb01;
assign sr3a = sb0a;
assign sr3b = sb13;
assign sr3c = sb1c;
assign sr3d = sb25;
assign sr3e = sb2e;
assign sr3f = sb37;

//mixcolumns
MixBytes mixbytes(sr00, sr08, sr10, sr18, sr20, sr28, sr30, sr38,
                  sr01, sr09, sr11, sr19, sr21, sr29, sr31, sr39,
                  sr02, sr0a, sr12, sr1a, sr22, sr2a, sr32, sr3a,
                  sr03, sr0b, sr13, sr1b, sr23, sr2b, sr33, sr3b,
                  sr04, sr0c, sr14, sr1c, sr24, sr2c, sr34, sr3c,
                  sr05, sr0d, sr15, sr1d, sr25, sr2d, sr35, sr3d,
                  sr06, sr0e, sr16, sr1e, sr26, sr2e, sr36, sr3e,
                  sr07, sr0f, sr17, sr1f, sr27, sr2f, sr37, sr3f,
                  y00, y08, y10, y18, y20, y28, y30, y38,
                  y01, y09, y11, y19, y21, y29, y31, y39,
                  y02, y0a, y12, y1a, y22, y2a, y32, y3a,
                  y03, y0b, y13, y1b, y23, y2b, y33, y3b,
                  y04, y0c, y14, y1c, y24, y2c, y34, y3c,
                  y05, y0d, y15, y1d, y25, y2d, y35, y3d,
                  y06, y0e, y16, y1e, y26, y2e, y36, y3e,
                  y07, y0f, y17, y1f, y27, y2f, y37, y3f);


endmodule






























