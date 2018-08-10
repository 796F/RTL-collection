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
module MixBytes(
   x00, x08, x10, x18, x20, x28, x30, x38,
   x01, x09, x11, x19, x21, x29, x31, x39,
   x02, x0a, x12, x1a, x22, x2a, x32, x3a,
   x03, x0b, x13, x1b, x23, x2b, x33, x3b,
   x04, x0c, x14, x1c, x24, x2c, x34, x3c,
   x05, x0d, x15, x1d, x25, x2d, x35, x3d,
   x06, x0e, x16, x1e, x26, x2e, x36, x3e,
   x07, x0f, x17, x1f, x27, x2f, x37, x3f,

   y00, y08, y10, y18, y20, y28, y30, y38,
   y01, y09, y11, y19, y21, y29, y31, y39,
   y02, y0a, y12, y1a, y22, y2a, y32, y3a,
   y03, y0b, y13, y1b, y23, y2b, y33, y3b,
   y04, y0c, y14, y1c, y24, y2c, y34, y3c,
   y05, y0d, y15, y1d, y25, y2d, y35, y3d,
   y06, y0e, y16, y1e, y26, y2e, y36, y3e,
   y07, y0f, y17, y1f, y27, y2f, y37, y3f
);

input [7:0] x00, x08, x10, x18, x20, x28, x30, x38;
input [7:0] x01, x09, x11, x19, x21, x29, x31, x39;
input [7:0] x02, x0a, x12, x1a, x22, x2a, x32, x3a;
input [7:0] x03, x0b, x13, x1b, x23, x2b, x33, x3b;
input [7:0] x04, x0c, x14, x1c, x24, x2c, x34, x3c;
input [7:0] x05, x0d, x15, x1d, x25, x2d, x35, x3d;
input [7:0] x06, x0e, x16, x1e, x26, x2e, x36, x3e;
input [7:0] x07, x0f, x17, x1f, x27, x2f, x37, x3f;

output [7:0] y00, y08, y10, y18, y20, y28, y30, y38;
output [7:0] y01, y09, y11, y19, y21, y29, y31, y39;
output [7:0] y02, y0a, y12, y1a, y22, y2a, y32, y3a;
output [7:0] y03, y0b, y13, y1b, y23, y2b, y33, y3b;
output [7:0] y04, y0c, y14, y1c, y24, y2c, y34, y3c;
output [7:0] y05, y0d, y15, y1d, y25, y2d, y35, y3d;
output [7:0] y06, y0e, y16, y1e, y26, y2e, y36, y3e;
output [7:0] y07, y0f, y17, y1f, y27, y2f, y37, y3f;

MixColumns mx00(.x({x00,x01,x02,x03,x04,x05,x06,x07}), .y(y00));
MixColumns mx01(.x({x01,x02,x03,x04,x05,x06,x07,x00}), .y(y01));
MixColumns mx02(.x({x02,x03,x04,x05,x06,x07,x00,x01}), .y(y02));
MixColumns mx03(.x({x03,x04,x05,x06,x07,x00,x01,x02}), .y(y03));
MixColumns mx04(.x({x04,x05,x06,x07,x00,x01,x02,x03}), .y(y04));
MixColumns mx05(.x({x05,x06,x07,x00,x01,x02,x03,x04}), .y(y05));
MixColumns mx06(.x({x06,x07,x00,x01,x02,x03,x04,x05}), .y(y06));
MixColumns mx07(.x({x07,x00,x01,x02,x03,x04,x05,x06}), .y(y07));
MixColumns mx08(.x({x08,x09,x0a,x0b,x0c,x0d,x0e,x0f}), .y(y08));
MixColumns mx09(.x({x09,x0a,x0b,x0c,x0d,x0e,x0f,x08}), .y(y09));
MixColumns mx0a(.x({x0a,x0b,x0c,x0d,x0e,x0f,x08,x09}), .y(y0a));
MixColumns mx0b(.x({x0b,x0c,x0d,x0e,x0f,x08,x09,x0a}), .y(y0b));
MixColumns mx0c(.x({x0c,x0d,x0e,x0f,x08,x09,x0a,x0b}), .y(y0c));
MixColumns mx0d(.x({x0d,x0e,x0f,x08,x09,x0a,x0b,x0c}), .y(y0d));
MixColumns mx0e(.x({x0e,x0f,x08,x09,x0a,x0b,x0c,x0d}), .y(y0e));
MixColumns mx0f(.x({x0f,x08,x09,x0a,x0b,x0c,x0d,x0e}), .y(y0f));
MixColumns mx10(.x({x10,x11,x12,x13,x14,x15,x16,x17}), .y(y10));
MixColumns mx11(.x({x11,x12,x13,x14,x15,x16,x17,x10}), .y(y11));
MixColumns mx12(.x({x12,x13,x14,x15,x16,x17,x10,x11}), .y(y12));
MixColumns mx13(.x({x13,x14,x15,x16,x17,x10,x11,x12}), .y(y13));
MixColumns mx14(.x({x14,x15,x16,x17,x10,x11,x12,x13}), .y(y14));
MixColumns mx15(.x({x15,x16,x17,x10,x11,x12,x13,x14}), .y(y15));
MixColumns mx16(.x({x16,x17,x10,x11,x12,x13,x14,x15}), .y(y16));
MixColumns mx17(.x({x17,x10,x11,x12,x13,x14,x15,x16}), .y(y17));
MixColumns mx18(.x({x18,x19,x1a,x1b,x1c,x1d,x1e,x1f}), .y(y18));
MixColumns mx19(.x({x19,x1a,x1b,x1c,x1d,x1e,x1f,x18}), .y(y19));
MixColumns mx1a(.x({x1a,x1b,x1c,x1d,x1e,x1f,x18,x19}), .y(y1a));
MixColumns mx1b(.x({x1b,x1c,x1d,x1e,x1f,x18,x19,x1a}), .y(y1b));
MixColumns mx1c(.x({x1c,x1d,x1e,x1f,x18,x19,x1a,x1b}), .y(y1c));
MixColumns mx1d(.x({x1d,x1e,x1f,x18,x19,x1a,x1b,x1c}), .y(y1d));
MixColumns mx1e(.x({x1e,x1f,x18,x19,x1a,x1b,x1c,x1d}), .y(y1e));
MixColumns mx1f(.x({x1f,x18,x19,x1a,x1b,x1c,x1d,x1e}), .y(y1f));
MixColumns mx20(.x({x20,x21,x22,x23,x24,x25,x26,x27}), .y(y20));
MixColumns mx21(.x({x21,x22,x23,x24,x25,x26,x27,x20}), .y(y21));
MixColumns mx22(.x({x22,x23,x24,x25,x26,x27,x20,x21}), .y(y22));
MixColumns mx23(.x({x23,x24,x25,x26,x27,x20,x21,x22}), .y(y23));
MixColumns mx24(.x({x24,x25,x26,x27,x20,x21,x22,x23}), .y(y24));
MixColumns mx25(.x({x25,x26,x27,x20,x21,x22,x23,x24}), .y(y25));
MixColumns mx26(.x({x26,x27,x20,x21,x22,x23,x24,x25}), .y(y26));
MixColumns mx27(.x({x27,x20,x21,x22,x23,x24,x25,x26}), .y(y27));
MixColumns mx28(.x({x28,x29,x2a,x2b,x2c,x2d,x2e,x2f}), .y(y28));
MixColumns mx29(.x({x29,x2a,x2b,x2c,x2d,x2e,x2f,x28}), .y(y29));
MixColumns mx2a(.x({x2a,x2b,x2c,x2d,x2e,x2f,x28,x29}), .y(y2a));
MixColumns mx2b(.x({x2b,x2c,x2d,x2e,x2f,x28,x29,x2a}), .y(y2b));
MixColumns mx2c(.x({x2c,x2d,x2e,x2f,x28,x29,x2a,x2b}), .y(y2c));
MixColumns mx2d(.x({x2d,x2e,x2f,x28,x29,x2a,x2b,x2c}), .y(y2d));
MixColumns mx2e(.x({x2e,x2f,x28,x29,x2a,x2b,x2c,x2d}), .y(y2e));
MixColumns mx2f(.x({x2f,x28,x29,x2a,x2b,x2c,x2d,x2e}), .y(y2f));
MixColumns mx30(.x({x30,x31,x32,x33,x34,x35,x36,x37}), .y(y30));
MixColumns mx31(.x({x31,x32,x33,x34,x35,x36,x37,x30}), .y(y31));
MixColumns mx32(.x({x32,x33,x34,x35,x36,x37,x30,x31}), .y(y32));
MixColumns mx33(.x({x33,x34,x35,x36,x37,x30,x31,x32}), .y(y33));
MixColumns mx34(.x({x34,x35,x36,x37,x30,x31,x32,x33}), .y(y34));
MixColumns mx35(.x({x35,x36,x37,x30,x31,x32,x33,x34}), .y(y35));
MixColumns mx36(.x({x36,x37,x30,x31,x32,x33,x34,x35}), .y(y36));
MixColumns mx37(.x({x37,x30,x31,x32,x33,x34,x35,x36}), .y(y37));
MixColumns mx38(.x({x38,x39,x3a,x3b,x3c,x3d,x3e,x3f}), .y(y38));
MixColumns mx39(.x({x39,x3a,x3b,x3c,x3d,x3e,x3f,x38}), .y(y39));
MixColumns mx3a(.x({x3a,x3b,x3c,x3d,x3e,x3f,x38,x39}), .y(y3a));
MixColumns mx3b(.x({x3b,x3c,x3d,x3e,x3f,x38,x39,x3a}), .y(y3b));
MixColumns mx3c(.x({x3c,x3d,x3e,x3f,x38,x39,x3a,x3b}), .y(y3c));
MixColumns mx3d(.x({x3d,x3e,x3f,x38,x39,x3a,x3b,x3c}), .y(y3d));
MixColumns mx3e(.x({x3e,x3f,x38,x39,x3a,x3b,x3c,x3d}), .y(y3e));
MixColumns mx3f(.x({x3f,x38,x39,x3a,x3b,x3c,x3d,x3e}), .y(y3f));

endmodule

module MixColumns(x, y);
input [63:0] x;
output [7:0] y;

wire [7:0] x0, x1, x2, x3, x4, x5, x6, x7;
wire mod0, mod1;

assign x0 = x[63:56];
assign x1 = x[55:48];
assign x2 = x[47:40];
assign x3 = x[39:32];
assign x4 = x[31:24];
assign x5 = x[23:16];
assign x6 = x[15:8];
assign x7 = x[7:0];

assign mod0 = x0[7] ^ x1[7] ^ x2[7] ^ x3[6] ^ x4[6] ^ x5[7] ^ x6[6] ^ x7[6] ^ x7[7];
assign mod1 = x3[7] ^ x4[7] ^ x6[7] ^ x7[7];

assign y = { x0[6] ^ x1[6] ^ x2[6] ^ x2[7] ^ x3[5] ^ x4[5] ^ x4[7] ^ x5[6] ^ x5[7] ^ x6[5] ^ x6[7] ^ x7[5] ^ x7[6] ^ x7[7],
             x0[5] ^ x1[5] ^ x2[5] ^ x2[6] ^ x3[4] ^ x4[4] ^ x4[6] ^ x5[5] ^ x5[6] ^ x6[4] ^ x6[6] ^ x7[4] ^ x7[5] ^ x7[6],
             x0[4] ^ x1[4] ^ x2[4] ^ x2[5] ^ x3[3] ^ x4[3] ^ x4[5] ^ x5[4] ^ x5[5] ^ x6[3] ^ x6[5] ^ x7[3] ^ x7[4] ^ x7[5] ^ mod1,
             x0[3] ^ x1[3] ^ x2[3] ^ x2[4] ^ x3[2] ^ x4[2] ^ x4[4] ^ x5[3] ^ x5[4] ^ x6[2] ^ x6[4] ^ x7[2] ^ x7[3] ^ x7[4] ^ mod0 ^ mod1,
             x0[2] ^ x1[2] ^ x2[2] ^ x2[3] ^ x3[1] ^ x4[1] ^ x4[3] ^ x5[2] ^ x5[3] ^ x6[1] ^ x6[3] ^ x7[1] ^ x7[2] ^ x7[3] ^ mod0,
             x0[1] ^ x1[1] ^ x2[1] ^ x2[2] ^ x3[0] ^ x4[0] ^ x4[2] ^ x5[1] ^ x5[2] ^ x6[0] ^ x6[2] ^ x7[0] ^ x7[1] ^ x7[2] ^ mod1,
             x0[0] ^ x1[0] ^ x2[0] ^ x2[1] ^ x4[1] ^ x5[0] ^ x5[1] ^ x6[1] ^ x7[0] ^ x7[1] ^ mod0 ^ mod1,
             x2[0] ^ x4[0] ^ x5[0] ^ x6[0] ^ x7[0] ^ mod0}; 

endmodule

                        

