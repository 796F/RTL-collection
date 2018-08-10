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
module AES_MIXCOLUMNS(x, y);

input  [127:0] x;
output [127:0] y;

MIXCOLUMNS mixcolumns0(.x(x[127: 96]), .y(y[127: 96]));
MIXCOLUMNS mixcolumns1(.x(x[ 95: 64]), .y(y[ 95: 64]));
MIXCOLUMNS mixcolumns2(.x(x[ 63: 32]), .y(y[ 63: 32]));
MIXCOLUMNS mixcolumns3(.x(x[ 31:  0]), .y(y[ 31:  0]));

endmodule


module MIXCOLUMNS(x, y);
input  [31:0]  x;
output [31:0]  y;

wire [7:0] a3, a2, a1, a0, b3, b2, b1, b0;

assign a3 = x[31:24]; assign a2 = x[23:16];
assign a1 = x[15: 8]; assign a0 = x[ 7: 0];

assign b3 = a3 ^ a2; assign b2 = a2 ^ a1;
assign b1 = a1 ^ a0; assign b0 = a0 ^ a3;

assign y = {a2[7] ^ b1[7] ^ b3[6],         a2[6] ^ b1[6] ^ b3[5],
            a2[5] ^ b1[5] ^ b3[4],         a2[4] ^ b1[4] ^ b3[3] ^ b3[7],
            a2[3] ^ b1[3] ^ b3[2] ^ b3[7], a2[2] ^ b1[2] ^ b3[1],
            a2[1] ^ b1[1] ^ b3[0] ^ b3[7], a2[0] ^ b1[0] ^ b3[7],
            a3[7] ^ b1[7] ^ b2[6],         a3[6] ^ b1[6] ^ b2[5],
            a3[5] ^ b1[5] ^ b2[4],         a3[4] ^ b1[4] ^ b2[3] ^ b2[7],
            a3[3] ^ b1[3] ^ b2[2] ^ b2[7], a3[2] ^ b1[2] ^ b2[1],
            a3[1] ^ b1[1] ^ b2[0] ^ b2[7], a3[0] ^ b1[0] ^ b2[7],
            a0[7] ^ b3[7] ^ b1[6],         a0[6] ^ b3[6] ^ b1[5],
            a0[5] ^ b3[5] ^ b1[4],         a0[4] ^ b3[4] ^ b1[3] ^ b1[7],
            a0[3] ^ b3[3] ^ b1[2] ^ b1[7], a0[2] ^ b3[2] ^ b1[1],
            a0[1] ^ b3[1] ^ b1[0] ^ b1[7], a0[0] ^ b3[0] ^ b1[7],
            a1[7] ^ b3[7] ^ b0[6],         a1[6] ^ b3[6] ^ b0[5],
            a1[5] ^ b3[5] ^ b0[4],         a1[4] ^ b3[4] ^ b0[3] ^ b0[7],
            a1[3] ^ b3[3] ^ b0[2] ^ b0[7], a1[2] ^ b3[2] ^ b0[1],
            a1[1] ^ b3[1] ^ b0[0] ^ b0[7], a1[0] ^ b3[0] ^ b0[7]};

endmodule

module AES_SUBBYTES (x, y);
input  [127:0] x;
output [127:0] y;

AES_Comp_SboxComp Sbox0(.x(x[127:120]), .y(y[127:120]));
AES_Comp_SboxComp Sbox1(.x(x[119:112]), .y(y[119:112]));
AES_Comp_SboxComp Sbox2(.x(x[111:104]), .y(y[111:104]));
AES_Comp_SboxComp Sbox3(.x(x[103: 96]), .y(y[103: 96]));
AES_Comp_SboxComp Sbox4(.x(x[ 95: 88]), .y(y[ 95: 88]));
AES_Comp_SboxComp Sbox5(.x(x[ 87: 80]), .y(y[ 87: 80]));
AES_Comp_SboxComp Sbox6(.x(x[ 79: 72]), .y(y[ 79: 72]));
AES_Comp_SboxComp Sbox7(.x(x[ 71: 64]), .y(y[ 71: 64]));
AES_Comp_SboxComp Sbox8(.x(x[ 63: 56]), .y(y[ 63: 56]));
AES_Comp_SboxComp Sbox9(.x(x[ 55: 48]), .y(y[ 55: 48]));
AES_Comp_SboxComp Sboxa(.x(x[ 47: 40]), .y(y[ 47: 40]));
AES_Comp_SboxComp Sboxb(.x(x[ 39: 32]), .y(y[ 39: 32]));
AES_Comp_SboxComp Sboxc(.x(x[ 31: 24]), .y(y[ 31: 24]));
AES_Comp_SboxComp Sboxd(.x(x[ 23: 16]), .y(y[ 23: 16]));
AES_Comp_SboxComp Sboxe(.x(x[ 15:  8]), .y(y[ 15:  8]));
AES_Comp_SboxComp Sboxf(.x(x[  7:  0]), .y(y[  7:  0]));
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
