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
module SubBytes (
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

AES_Comp_SboxComp Sbox00(.x(x00), .y(y00));
AES_Comp_SboxComp Sbox01(.x(x01), .y(y01));
AES_Comp_SboxComp Sbox02(.x(x02), .y(y02));
AES_Comp_SboxComp Sbox03(.x(x03), .y(y03));
AES_Comp_SboxComp Sbox04(.x(x04), .y(y04));
AES_Comp_SboxComp Sbox05(.x(x05), .y(y05));
AES_Comp_SboxComp Sbox06(.x(x06), .y(y06));
AES_Comp_SboxComp Sbox07(.x(x07), .y(y07));
AES_Comp_SboxComp Sbox08(.x(x08), .y(y08));
AES_Comp_SboxComp Sbox09(.x(x09), .y(y09));
AES_Comp_SboxComp Sbox0a(.x(x0a), .y(y0a));
AES_Comp_SboxComp Sbox0b(.x(x0b), .y(y0b));
AES_Comp_SboxComp Sbox0c(.x(x0c), .y(y0c));
AES_Comp_SboxComp Sbox0d(.x(x0d), .y(y0d));
AES_Comp_SboxComp Sbox0e(.x(x0e), .y(y0e));
AES_Comp_SboxComp Sbox0f(.x(x0f), .y(y0f));
AES_Comp_SboxComp Sbox10(.x(x10), .y(y10));
AES_Comp_SboxComp Sbox11(.x(x11), .y(y11));
AES_Comp_SboxComp Sbox12(.x(x12), .y(y12));
AES_Comp_SboxComp Sbox13(.x(x13), .y(y13));
AES_Comp_SboxComp Sbox14(.x(x14), .y(y14));
AES_Comp_SboxComp Sbox15(.x(x15), .y(y15));
AES_Comp_SboxComp Sbox16(.x(x16), .y(y16));
AES_Comp_SboxComp Sbox17(.x(x17), .y(y17));
AES_Comp_SboxComp Sbox18(.x(x18), .y(y18));
AES_Comp_SboxComp Sbox19(.x(x19), .y(y19));
AES_Comp_SboxComp Sbox1a(.x(x1a), .y(y1a));
AES_Comp_SboxComp Sbox1b(.x(x1b), .y(y1b));
AES_Comp_SboxComp Sbox1c(.x(x1c), .y(y1c));
AES_Comp_SboxComp Sbox1d(.x(x1d), .y(y1d));
AES_Comp_SboxComp Sbox1e(.x(x1e), .y(y1e));
AES_Comp_SboxComp Sbox1f(.x(x1f), .y(y1f));
AES_Comp_SboxComp Sbox20(.x(x20), .y(y20));
AES_Comp_SboxComp Sbox21(.x(x21), .y(y21));
AES_Comp_SboxComp Sbox22(.x(x22), .y(y22));
AES_Comp_SboxComp Sbox23(.x(x23), .y(y23));
AES_Comp_SboxComp Sbox24(.x(x24), .y(y24));
AES_Comp_SboxComp Sbox25(.x(x25), .y(y25));
AES_Comp_SboxComp Sbox26(.x(x26), .y(y26));
AES_Comp_SboxComp Sbox27(.x(x27), .y(y27));
AES_Comp_SboxComp Sbox28(.x(x28), .y(y28));
AES_Comp_SboxComp Sbox29(.x(x29), .y(y29));
AES_Comp_SboxComp Sbox2a(.x(x2a), .y(y2a));
AES_Comp_SboxComp Sbox2b(.x(x2b), .y(y2b));
AES_Comp_SboxComp Sbox2c(.x(x2c), .y(y2c));
AES_Comp_SboxComp Sbox2d(.x(x2d), .y(y2d));
AES_Comp_SboxComp Sbox2e(.x(x2e), .y(y2e));
AES_Comp_SboxComp Sbox2f(.x(x2f), .y(y2f));
AES_Comp_SboxComp Sbox30(.x(x30), .y(y30));
AES_Comp_SboxComp Sbox31(.x(x31), .y(y31));
AES_Comp_SboxComp Sbox32(.x(x32), .y(y32));
AES_Comp_SboxComp Sbox33(.x(x33), .y(y33));
AES_Comp_SboxComp Sbox34(.x(x34), .y(y34));
AES_Comp_SboxComp Sbox35(.x(x35), .y(y35));
AES_Comp_SboxComp Sbox36(.x(x36), .y(y36));
AES_Comp_SboxComp Sbox37(.x(x37), .y(y37));
AES_Comp_SboxComp Sbox38(.x(x38), .y(y38));
AES_Comp_SboxComp Sbox39(.x(x39), .y(y39));
AES_Comp_SboxComp Sbox3a(.x(x3a), .y(y3a));
AES_Comp_SboxComp Sbox3b(.x(x3b), .y(y3b));
AES_Comp_SboxComp Sbox3c(.x(x3c), .y(y3c));
AES_Comp_SboxComp Sbox3d(.x(x3d), .y(y3d));
AES_Comp_SboxComp Sbox3e(.x(x3e), .y(y3e));
AES_Comp_SboxComp Sbox3f(.x(x3f), .y(y3f));

endmodule

module AES_Comp_GFinvComp(x, y);
  input  [7:0] x;
  output [7:0] y;

  wire [8:0] da, db, dx, dy, va, tp, tn;
  wire [3:0] u, v;
  wire [4:0] mx;
  wire [5:0] my;

  assign da ={x[3], x[2]^x[3], x[2], x[1]^x[3], x[0]^x[1]^x[2]^x[3], x[0]^x[2], x[1], x[0]^x[1], x[0]};
  assign db ={x[7], x[6]^x[7], x[6], x[5]^x[7], x[4]^x[5]^x[6]^x[7], x[4]^x[6], x[5], x[4]^x[5], x[4]};
  assign va ={v[3], v[2]^v[3], v[2], v[1]^v[3], v[0]^v[1]^v[2]^v[3], v[0]^v[2], v[1], v[0]^v[1], v[0]};
  assign dx = da ^ db;
  assign dy = da & dx;
  assign tp = va & dx;
  assign tn = va & db;

  assign u = {dy[0] ^ dy[1] ^ dy[3] ^ dy[4] ^ x[4] ^ x[5] ^ x[6],
              dy[0] ^ dy[2] ^ dy[3] ^ dy[5] ^ x[4] ^ x[7],
              dy[0] ^ dy[1] ^ dy[7] ^ dy[8] ^ x[7],
              dy[0] ^ dy[2] ^ dy[6] ^ dy[7] ^ x[6] ^ x[7]};

  assign y = {tn[0] ^ tn[1] ^ tn[3] ^ tn[4], tn[0] ^ tn[2] ^ tn[3] ^ tn[5],
              tn[0] ^ tn[1] ^ tn[7] ^ tn[8], tn[0] ^ tn[2] ^ tn[6] ^ tn[7],
              tp[0] ^ tp[1] ^ tp[3] ^ tp[4], tp[0] ^ tp[2] ^ tp[3] ^ tp[5],
              tp[0] ^ tp[1] ^ tp[7] ^ tp[8], tp[0] ^ tp[2] ^ tp[6] ^ tp[7]};

  ////////////////////////
  // GF(2^2^2) Inverter //
  ////////////////////////
    assign mx = {mx[0] ^ mx[1] ^ u[2],
                 mx[0] ^ mx[2] ^ u[3],
                 u[1] & (u[1] ^ u[3]),
                 (u[0] ^ u[1]) & (u[0] ^ u[1]  ^ u[2] ^ u[3]),
                 u[0] & (u[0] ^ u[2])};

    assign my = {~(mx[4] & u[3]),
                 ~(mx[3] & (u[2] ^ u[3])),
                 ~((mx[3] ^ mx[4]) & u[2]),
                 ~(mx[4] & (u[1] ^ u[3])),
                 ~(mx[3] & (u[0] ^ u[1]  ^ u[2] ^ u[3])),
                 ~((mx[3] ^ mx[4]) & (u[0] ^ u[2]))};

    assign v = {my[3]^my[4], my[3]^my[5], my[0]^my[1], my[0]^my[2]};
endmodule


module AES_Comp_SboxComp(x, y);
  input  [7:0] x;
  output [7:0] y;

  wire [7:0] a, b;

  assign a = {x[5] ^ x[7],
              x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[6] ^ x[7],
              x[2] ^ x[3] ^ x[5] ^ x[7],
              x[1] ^ x[2] ^ x[3] ^ x[5] ^ x[7],
              x[1] ^ x[2] ^ x[6] ^ x[7],
              x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[7],
              x[1] ^ x[4] ^ x[6],
              x[0] ^ x[1] ^ x[6]};

  AES_Comp_GFinvComp AES_Comp_GFinvComp(.x(a), .y(b));

  assign y = { b[2] ^ b[3] ^ b[7],
              ~b[4] ^ b[5] ^ b[6] ^ b[7],
              ~b[2] ^ b[7],
               b[0] ^ b[1] ^ b[4] ^ b[7],
               b[0] ^ b[1] ^ b[2],
               b[0] ^ b[2] ^ b[3] ^ b[4] ^ b[5] ^ b[6],
              ~b[0] ^ b[7],
              ~b[0] ^ b[1] ^ b[2] ^ b[6] ^ b[7]};
endmodule

