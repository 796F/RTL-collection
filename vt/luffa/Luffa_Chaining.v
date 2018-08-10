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

module MESSAGE_INJECTION(
	                      msg,
	                      state_00, state_01, state_02, state_03, state_04, state_05, state_06, state_07,
	                      state_10, state_11, state_12, state_13, state_14, state_15, state_16, state_17,
	                      state_20, state_21, state_22, state_23, state_24, state_25, state_26, state_27,
	                      mi_00, mi_01, mi_02, mi_03, mi_04, mi_05, mi_06, mi_07,
	                      mi_10, mi_11, mi_12, mi_13, mi_14, mi_15, mi_16, mi_17,
	                      mi_20, mi_21, mi_22, mi_23, mi_24, mi_25, mi_26, mi_27
                        );

input  [255:0] msg;
input  [ 31:0] state_00, state_01, state_02, state_03, state_04, state_05, state_06, state_07;
input  [ 31:0] state_10, state_11, state_12, state_13, state_14, state_15, state_16, state_17;
input  [ 31:0] state_20, state_21, state_22, state_23, state_24, state_25, state_26, state_27;
output [ 31:0] mi_00, mi_01, mi_02, mi_03, mi_04, mi_05, mi_06, mi_07;
output [ 31:0] mi_10, mi_11, mi_12, mi_13, mi_14, mi_15, mi_16, mi_17;
output [ 31:0] mi_20, mi_21, mi_22, mi_23, mi_24, mi_25, mi_26, mi_27;

wire [31:0] xor_all_state0, xor_all_state1, xor_all_state2, xor_all_state3, xor_all_state4, xor_all_state5, xor_all_state6, xor_all_state7;
wire [31:0] mul_xas0, mul_xas1, mul_xas2, mul_xas3, mul_xas4, mul_xas5, mul_xas6, mul_xas7;
wire [31:0] mul_msg0, mul_msg1, mul_msg2, mul_msg3, mul_msg4, mul_msg5, mul_msg6, mul_msg7;
wire [31:0] mul2_msg0, mul2_msg1, mul2_msg2, mul2_msg3, mul2_msg4, mul2_msg5, mul2_msg6, mul2_msg7;
wire [31:0] mi_14_bt, mi_15_bt, mi_16_bt, mi_17_bt, mi_24_bt, mi_25_bt, mi_26_bt, mi_27_bt; /* Before Tweak */

MULTIPLY_TWO multiply_two0(.in0(xor_all_state0), .in1(xor_all_state1), .in2(xor_all_state2), .in3(xor_all_state3), .in4(xor_all_state4), .in5(xor_all_state5), .in6(xor_all_state6), .in7(xor_all_state7), .out0(mul_xas0), .out1(mul_xas1), .out2(mul_xas2), .out3(mul_xas3), .out4(mul_xas4), .out5(mul_xas5), .out6(mul_xas6), .out7(mul_xas7));
MULTIPLY_TWO multiply_two1(.in0(msg[255:224]), .in1(msg[223:192]), .in2(msg[191:160]), .in3(msg[159:128]), .in4(msg[127:96]), .in5(msg[95:64]), .in6(msg[63:32]), .in7(msg[31:0]), .out0(mul_msg0), .out1(mul_msg1), .out2(mul_msg2), .out3(mul_msg3), .out4(mul_msg4), .out5(mul_msg5), .out6(mul_msg6), .out7(mul_msg7));
MULTIPLY_TWO multiply_two2(.in0(mul_msg0), .in1(mul_msg1), .in2(mul_msg2), .in3(mul_msg3), .in4(mul_msg4), .in5(mul_msg5), .in6(mul_msg6), .in7(mul_msg7), .out0(mul2_msg0), .out1(mul2_msg1), .out2(mul2_msg2), .out3(mul2_msg3), .out4(mul2_msg4), .out5(mul2_msg5), .out6(mul2_msg6), .out7(mul2_msg7));

//XOR All State 
assign xor_all_state0 = state_00 ^ state_10 ^ state_20;
assign xor_all_state1 = state_01 ^ state_11 ^ state_21;
assign xor_all_state2 = state_02 ^ state_12 ^ state_22;
assign xor_all_state3 = state_03 ^ state_13 ^ state_23;
assign xor_all_state4 = state_04 ^ state_14 ^ state_24;
assign xor_all_state5 = state_05 ^ state_15 ^ state_25;
assign xor_all_state6 = state_06 ^ state_16 ^ state_26;
assign xor_all_state7 = state_07 ^ state_17 ^ state_27;
//Finish Message Injection
assign mi_00 = state_00 ^ msg[255:224] ^ mul_xas0;
assign mi_01 = state_01 ^ msg[223:192] ^ mul_xas1;
assign mi_02 = state_02 ^ msg[191:160] ^ mul_xas2;
assign mi_03 = state_03 ^ msg[159:128] ^ mul_xas3;
assign mi_04 = state_04 ^ msg[127: 96] ^ mul_xas4;
assign mi_05 = state_05 ^ msg[ 95: 64] ^ mul_xas5;
assign mi_06 = state_06 ^ msg[ 63: 32] ^ mul_xas6;
assign mi_07 = state_07 ^ msg[ 31:  0] ^ mul_xas7;
assign mi_10 = state_10 ^ mul_msg0 ^ mul_xas0;
assign mi_11 = state_11 ^ mul_msg1 ^ mul_xas1;
assign mi_12 = state_12 ^ mul_msg2 ^ mul_xas2;
assign mi_13 = state_13 ^ mul_msg3 ^ mul_xas3;
assign mi_14_bt = state_14 ^ mul_msg4 ^ mul_xas4;
assign mi_15_bt = state_15 ^ mul_msg5 ^ mul_xas5;
assign mi_16_bt = state_16 ^ mul_msg6 ^ mul_xas6;
assign mi_17_bt = state_17 ^ mul_msg7 ^ mul_xas7;
assign mi_20 = state_20 ^ mul2_msg0 ^ mul_xas0;
assign mi_21 = state_21 ^ mul2_msg1 ^ mul_xas1;
assign mi_22 = state_22 ^ mul2_msg2 ^ mul_xas2;
assign mi_23 = state_23 ^ mul2_msg3 ^ mul_xas3;
assign mi_24_bt = state_24 ^ mul2_msg4 ^ mul_xas4;
assign mi_25_bt = state_25 ^ mul2_msg5 ^ mul_xas5;
assign mi_26_bt = state_26 ^ mul2_msg6 ^ mul_xas6;
assign mi_27_bt = state_27 ^ mul2_msg7 ^ mul_xas7;
//Tweak
assign mi_14 = {mi_14_bt[30:0],mi_14_bt[31]};
assign mi_15 = {mi_15_bt[30:0],mi_15_bt[31]};
assign mi_16 = {mi_16_bt[30:0],mi_16_bt[31]};
assign mi_17 = {mi_17_bt[30:0],mi_17_bt[31]};
assign mi_24 = {mi_24_bt[29:0],mi_24_bt[31:30]};
assign mi_25 = {mi_25_bt[29:0],mi_25_bt[31:30]};
assign mi_26 = {mi_26_bt[29:0],mi_26_bt[31:30]};
assign mi_27 = {mi_27_bt[29:0],mi_27_bt[31:30]};

endmodule

//{{{/* module: Multiply Two */
module MULTIPLY_TWO(
	in0, in1, in2, in3, in4, in5, in6, in7,
	out0, out1, out2, out3, out4, out5, out6, out7
);

input  [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
output [31:0] out0, out1, out2, out3, out4, out5, out6, out7;

assign out0 = in7;
assign out1 = in0 ^ in7;
assign out2 = in1;
assign out3 = in2 ^ in7;
assign out4 = in3 ^ in7;
assign out5 = in4;
assign out6 = in5;
assign out7 = in6;

endmodule
//}}}

module PERMUTATION_Q(
	mi_0, mi_1, mi_2, mi_3, mi_4, mi_5, mi_6, mi_7,
	const_0, const_4,
	h_0, h_1, h_2, h_3, h_4, h_5, h_6, h_7
);

input  [31:0] mi_0, mi_1, mi_2, mi_3, mi_4, mi_5, mi_6, mi_7;
input  [31:0] const_0, const_4;
output [31:0] h_0, h_1, h_2, h_3, h_4, h_5, h_6, h_7;

wire [31:0] sub_0, sub_1, sub_2, sub_3, sub_4, sub_5, sub_6, sub_7;
wire [31:0] mix_0, mix_1, mix_2, mix_3, mix_4, mix_5, mix_6, mix_7;

//{{{/* permutation Q 
SUB_CRUMB sub_crumb0(.in0(mi_0), .in1(mi_1), .in2(mi_2), .in3(mi_3), .out0(sub_0), .out1(sub_1), .out2(sub_2), .out3(sub_3));
SUB_CRUMB sub_crumb1(.in0(mi_5), .in1(mi_6), .in2(mi_7), .in3(mi_4), .out0(sub_5), .out1(sub_6), .out2(sub_7), .out3(sub_4));
MIXWORD  mixword0(.in0(sub_0), .in1(sub_4), .out0(mix_0), .out1(mix_4));
MIXWORD  mixword1(.in0(sub_1), .in1(sub_5), .out0(mix_1), .out1(mix_5));
MIXWORD  mixword2(.in0(sub_2), .in1(sub_6), .out0(mix_2), .out1(mix_6));
MIXWORD  mixword3(.in0(sub_3), .in1(sub_7), .out0(mix_3), .out1(mix_7));

assign h_0 = mix_0 ^ const_0;
assign h_1 = mix_1;
assign h_2 = mix_2;
assign h_3 = mix_3;
assign h_4 = mix_4 ^ const_4;
assign h_5 = mix_5;
assign h_6 = mix_6;
assign h_7 = mix_7;

endmodule
//}}}

//{{{/* module: SubCrumb */
module SUB_CRUMB(
	in0, in1, in2, in3,
	out0, out1, out2, out3
);

input  [31:0] in0, in1, in2, in3;
output [31:0] out0, out1, out2, out3;

wire [31:0] r4_0, r0_0, r2_0, r1_0, r0_1, r3_0, r1_1, r3_1, r2_1, r0_2, r2_2, r1_2;

assign r4_0 = in0;
assign r0_0 = in0 | in1;
assign r2_0 = in2 ^ in3;
assign r1_0 = ~in1;
assign r0_1 = r0_0 ^ in3;
assign r3_0 = in3 & r4_0;
assign r1_1 = r1_0 ^ r3_0;
assign r3_1 = r3_0 ^ r2_0;
assign r2_1 = r2_0 & r0_1;
assign r0_2 = ~r0_1;
assign r2_2 = r2_1 ^ r1_1;
assign r1_2 = r1_1 | r3_1;
assign out0 = r4_0 ^ r1_2;
assign out3 = r3_1 ^ r2_2;
assign out2 = r2_2 & r1_2;
assign out1 = r1_2 ^ r0_2;

endmodule
//}}}

//{{{/* module: MixWord */
module MIXWORD(
	in0, in1,
	out0, out1
);

input  [31:0] in0, in1;
output [31:0] out0, out1;

wire [31:0] xr_0, xl_0, xr_1;

assign xr_0 = in0 ^ in1;
assign xl_0 = {in0[29:0],in0[31:30]} ^ xr_0;
assign xr_1 = xl_0 ^ {xr_0[17:0],xr_0[31:18]};
assign out0 = {xl_0[21:0],xl_0[31:22]} ^ xr_1;
assign out1 = {xr_1[30:0],xr_1[31]};

endmodule
//}}}

module GEN_CONST(
	tl, tr,
	const_0, const_4, new_tl, new_tr
);

input  [31:0] tl, tr;
output [31:0] const_0, const_4, new_tl, new_tr;

parameter GL = 32'hc4d6496c;
parameter GR = 32'h55c61c8d;

wire [31:0] tl_0, tr_0, mid_tl, mid_tr, tl_1, tr_1;
wire        c0, c1;

//{{{/* Generate Constant */
assign c0 = tl[31];
assign tl_0 = {tl[30:0],1'h0} | {31'h0,tr[31]};
assign tr_0 = {tr[30:0],1'h0};
assign mid_tl = (c0 == 1'b1)? (tr_0 ^ GR) : tr_0;
assign mid_tr = (c0 == 1'b1)? (tl_0 ^ GL) : tl_0;
assign const_0 = mid_tr;
assign c1 = mid_tl[31];
assign tl_1 = {mid_tl[30:0],1'h0} | {31'h0,mid_tr[31]};
assign tr_1 = {mid_tr[30:0],1'h0};
assign new_tl = (c1 == 1'b1)? (tr_1 ^ GR) : tr_1;
assign new_tr = (c1 == 1'b1)? (tl_1 ^ GL) : tl_1;
assign const_4 = new_tr;

endmodule
//}}}

// vim:fdm=marker
