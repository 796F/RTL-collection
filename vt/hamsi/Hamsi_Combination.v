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
module EXPANSION(
	               message,
	               exp_out0, 
	               exp_out1, 
	               exp_out2, 
	               exp_out3, 
	               exp_out4, 
	               exp_out5, 
	               exp_out6, 
	               exp_out7);
/* expansion */
input  [31:0] message;
output [31:0] exp_out0, exp_out1, exp_out2, exp_out3, exp_out4, exp_out5, exp_out6, exp_out7;

wire [31:0]  table_out0,  table_out1,  table_out2,  table_out3,  table_out4,  table_out5,  table_out6,  table_out7;
wire [31:0]  table_out8,  table_out9, table_out10, table_out11, table_out12, table_out13, table_out14, table_out15;
wire [31:0] table_out16, table_out17, table_out18, table_out19, table_out20, table_out21, table_out22, table_out23;
wire [31:0] table_out24, table_out25, table_out26, table_out27, table_out28, table_out29, table_out30, table_out31;

TABLE0   table0(.byte_in(message[ 7: 0]), .table_out(table_out0 ));
TABLE1   table1(.byte_in(message[15: 8]), .table_out(table_out1 ));
TABLE2   table2(.byte_in(message[23:16]), .table_out(table_out2 ));
TABLE3   table3(.byte_in(message[31:24]), .table_out(table_out3 ));
TABLE4   table4(.byte_in(message[ 7: 0]), .table_out(table_out4 ));
TABLE5   table5(.byte_in(message[15: 8]), .table_out(table_out5 ));
TABLE6   table6(.byte_in(message[23:16]), .table_out(table_out6 ));
TABLE7   table7(.byte_in(message[31:24]), .table_out(table_out7 ));
TABLE8   table8(.byte_in(message[ 7: 0]), .table_out(table_out8 ));
TABLE9   table9(.byte_in(message[15: 8]), .table_out(table_out9 ));
TABLE10 table10(.byte_in(message[23:16]), .table_out(table_out10));
TABLE11 table11(.byte_in(message[31:24]), .table_out(table_out11));
TABLE12 table12(.byte_in(message[ 7: 0]), .table_out(table_out12));
TABLE13 table13(.byte_in(message[15: 8]), .table_out(table_out13));
TABLE14 table14(.byte_in(message[23:16]), .table_out(table_out14));
TABLE15 table15(.byte_in(message[31:24]), .table_out(table_out15));
TABLE16 table16(.byte_in(message[ 7: 0]), .table_out(table_out16));
TABLE17 table17(.byte_in(message[15: 8]), .table_out(table_out17));
TABLE18 table18(.byte_in(message[23:16]), .table_out(table_out18));
TABLE19 table19(.byte_in(message[31:24]), .table_out(table_out19));
TABLE20 table20(.byte_in(message[ 7: 0]), .table_out(table_out20));
TABLE21 table21(.byte_in(message[15: 8]), .table_out(table_out21));
TABLE22 table22(.byte_in(message[23:16]), .table_out(table_out22));
TABLE23 table23(.byte_in(message[31:24]), .table_out(table_out23));
TABLE24 table24(.byte_in(message[ 7: 0]), .table_out(table_out24));
TABLE25 table25(.byte_in(message[15: 8]), .table_out(table_out25));
TABLE26 table26(.byte_in(message[23:16]), .table_out(table_out26));
TABLE27 table27(.byte_in(message[31:24]), .table_out(table_out27));
TABLE28 table28(.byte_in(message[ 7: 0]), .table_out(table_out28));
TABLE29 table29(.byte_in(message[15: 8]), .table_out(table_out29));
TABLE30 table30(.byte_in(message[23:16]), .table_out(table_out30));
TABLE31 table31(.byte_in(message[31:24]), .table_out(table_out31));

assign exp_out0 =  table_out0 ^  table_out1 ^  table_out2 ^  table_out3;
assign exp_out1 =  table_out4 ^  table_out5 ^  table_out6 ^  table_out7;
assign exp_out2 =  table_out8 ^  table_out9 ^ table_out10 ^ table_out11;
assign exp_out3 = table_out12 ^ table_out13 ^ table_out14 ^ table_out15;
assign exp_out4 = table_out16 ^ table_out17 ^ table_out18 ^ table_out19;
assign exp_out5 = table_out20 ^ table_out21 ^ table_out22 ^ table_out23;
assign exp_out6 = table_out24 ^ table_out25 ^ table_out26 ^ table_out27;
assign exp_out7 = table_out28 ^ table_out29 ^ table_out30 ^ table_out31;

endmodule


module CONCATENATION(
	                  concate_in,
	                  concate_out);

input  [31:0] concate_in;
output [31:0] concate_out;

assign concate_out = concate_in;

endmodule

module ADDITION_TYPE0(
	                   status_in, 
	                   const_in,
	                   add_out);

input  [31:0] status_in, const_in;
output [31:0] add_out;

assign add_out = status_in ^ const_in;

endmodule

module ADDITION_TYPE1(
	                    status_in, 
	                    const_in,
	                    count_in,
	                    add_out);

input [31:0] status_in, const_in;
input [2:0] count_in;
output [31:0] add_out;

assign add_out = status_in ^ const_in ^ {29'h0,count_in};

endmodule

module SUBSTITUTION(
	                 add_in0, 
	                 add_in1, 
	                 add_in2, 
	                 add_in3,
	                 sub_out0, 
	                 sub_out1, 
	                 sub_out2, 
	                 sub_out3);

input  [31:0] add_in0, add_in1, add_in2, add_in3;
output [31:0] sub_out0, sub_out1, sub_out2, sub_out3;

wire [31:0] r0_0, r1_0, r2_0, r3_0; /* Prime Value */
wire [31:0] r0_1, r0_2, r0_3;       /* Updated Value of r0 */
wire [31:0] r1_1, r1_2, r1_3;       /* Updated Value of r1 */
wire [31:0] r2_1, r2_2;             /* Updated Value of r2 */
wire [31:0] r3_1, r3_2, r3_3, r3_4; /* Updated Value of r3 */
wire [31:0] r4_0, r4_1, r4_2, r4_3; /* Updated Value of r4 */

assign r0_0 = add_in0;
assign r1_0 = add_in1;
assign r2_0 = add_in2;
assign r3_0 = add_in3;
assign r4_0 = r0_0;        /* r4  = r0; */
assign r0_1 = r0_0 & r2_0; /* r0 &= r2; */
assign r0_2 = r0_1 ^ r3_0; /* r0 ^= r3; */
assign r2_1 = r2_0 ^ r1_0; /* r2 ^= r1; */
assign r2_2 = r2_1 ^ r0_2; /* r2 ^= r0; */
assign r3_1 = r3_0 | r4_0; /* r3 |= r4; */
assign r3_2 = r3_1 ^ r1_0; /* r3 ^= r1; */
assign r4_1 = r4_0 ^ r2_2; /* r4 ^= r2; */
assign r1_1 = r3_2;        /* r1  = r3; */
assign r3_3 = r3_2 | r4_1; /* r3 |= r4; */
assign r3_4 = r3_3 ^ r0_2; /* r3 ^= r0; */
assign r0_3 = r0_2 & r1_1; /* r0 &= r1; */
assign r4_2 = r4_1 ^ r0_3; /* r4 ^= r0; */
assign r1_2 = r1_1 ^ r3_4; /* r1 ^= r3; */
assign r1_3 = r1_2 ^ r4_2; /* r1 ^= r4; */
assign r4_3 = ~r4_2;       /* r4 = ~r4; */
assign sub_out0 = r2_2; /* output r2 */
assign sub_out1 = r3_4; /* output r3 */
assign sub_out2 = r1_3; /* output r1 */
assign sub_out3 = r4_3; /* output r4 */

endmodule

module DIFFUSION(
	              sub_in0, 
	              sub_in1, 
	              sub_in2, 
	              sub_in3,
	              diff_out0, 
	              diff_out1, 
	              diff_out2, 
	              diff_out3);

input  [31:0] sub_in0, sub_in1, sub_in2, sub_in3;
output [31:0] diff_out0, diff_out1, diff_out2, diff_out3;

wire [31:0] a_0, b_0, c_0, d_0; /* Prime Value */
wire [31:0] a_1, a_2, a_3;      /* Updated Value of a */
wire [31:0] b_1, b_2;           /* Updated Value of b */
wire [31:0] c_1, c_2, c_3;      /* Updated Value of c */
wire [31:0] d_1, d_2;           /* Updated Value of d */

assign a_0 = sub_in0;
assign b_0 = sub_in1;
assign c_0 = sub_in2;
assign d_0 = sub_in3;

assign a_1 = {a_0[18:0],a_0[31:19]}; /* a <<< 13; */
assign c_1 = {c_0[28:0],c_0[31:29]}; /* c <<< 3; */
assign b_1 = b_0 ^ a_1 ^ c_1;        /* b ^= (a ^ c); */
assign d_1 = d_0 ^ c_1 ^ (a_1 << 3);   /* d ^= (c ^ (a << 3)); */
assign b_2 = {b_1[30:0],b_1[31]};    /* b <<< 1; */
assign d_2 = {d_1[24:0],d_1[31:25]}; /* d <<< 7; */
assign a_2 = a_1 ^ b_2 ^ d_2;        /* a ^= (b ^ d); */
assign c_2 = c_1 ^ d_2 ^ (b_2 << 7);   /* c ^= (d ^ (b << 7)); */
assign a_3 = {a_2[26:0],a_2[31:27]}; /* a <<< 5; */
assign c_3 = {c_2[9:0],c_2[31:10]};  /* c <<< 22; */

assign diff_out0 = a_3; /* output a */
assign diff_out1 = b_2; /* output b */
assign diff_out2 = c_3; /* output c */
assign diff_out3 = d_2; /* output d */

endmodule


module TRUNCATION(
	               diff_in,
	               trunc_out);

input  [31:0] diff_in;
output [31:0] trunc_out;

assign trunc_out = diff_in;

endmodule

module UPDATE(
	           hash_in, 
	           trunc_in,
	           update_out);

input  [31:0] hash_in, trunc_in;
output [31:0] update_out;

assign update_out = hash_in ^ trunc_in;

endmodule



