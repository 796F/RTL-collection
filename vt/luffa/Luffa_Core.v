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
module LUFFA_CORE(
	               clk, 
	               rst_n,
	               idata256, 
	               init_r, 
	               EN, 
	               busy, 
	               fetch, 
	               load,
	               hash0, 
	               hash1, 
	               hash2, 
	               hash3, 
	               hash4, 
	               hash5, 
	               hash6, 
	               hash7);

input         clk;
input         rst_n;
input         init_r;
input         EN;
input [255:0] idata256;
input         load;
input         fetch;
output        busy;
output [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7; 

//{{{/* parameter */
parameter V_00 = 32'h6d251e69;
parameter V_01 = 32'h44b051e0;
parameter V_02 = 32'h4eaa6fb4;
parameter V_03 = 32'hdbf78465;
parameter V_04 = 32'h6e292011;
parameter V_05 = 32'h90152df4;
parameter V_06 = 32'hee058139;
parameter V_07 = 32'hdef610bb;

parameter V_10 = 32'hc3b44b95;
parameter V_11 = 32'hd9d2f256;
parameter V_12 = 32'h70eee9a0;
parameter V_13 = 32'hde099fa3;
parameter V_14 = 32'h5d9b0557;
parameter V_15 = 32'h8fc944b3;
parameter V_16 = 32'hcf1ccf0e;
parameter V_17 = 32'h746cd581;

parameter V_20 = 32'hf7efc89d;
parameter V_21 = 32'h5dba5781;
parameter V_22 = 32'h04016ce5;
parameter V_23 = 32'had659c05;
parameter V_24 = 32'h0306194f;
parameter V_25 = 32'h666d1836;
parameter V_26 = 32'h24aa230a;
parameter V_27 = 32'h8b264ae7;

parameter C_0L = 32'h181cca53;
parameter C_0R = 32'h380cde06;
parameter C_1L = 32'h5b6f0876;
parameter C_1R = 32'hf16f8594;
parameter C_2L = 32'h7e106ce9;
parameter C_2R = 32'h38979cb0;

reg [31:0] state_00, state_01, state_02, state_03, state_04, state_05, state_06, state_07;
reg [31:0] state_10, state_11, state_12, state_13, state_14, state_15, state_16, state_17;
reg [31:0] state_20, state_21, state_22, state_23, state_24, state_25, state_26, state_27;

reg [31:0] state_00_bk, state_01_bk, state_02_bk, state_03_bk, state_04_bk, state_05_bk, state_06_bk, state_07_bk;
reg [31:0] state_10_bk, state_11_bk, state_12_bk, state_13_bk, state_14_bk, state_15_bk, state_16_bk, state_17_bk;
reg [31:0] state_20_bk, state_21_bk, state_22_bk, state_23_bk, state_24_bk, state_25_bk, state_26_bk, state_27_bk;

reg [31:0] const_0L, const_0R, const_1L, const_1R, const_2L, const_2R;
reg [31:0] const_00_reg, const_04_reg, const_10_reg, const_14_reg, const_20_reg, const_24_reg;

reg [31:0] const_0L_bk, const_0R_bk, const_1L_bk, const_1R_bk, const_2L_bk, const_2R_bk;
reg [31:0] const_00_reg_bk, const_04_reg_bk, const_10_reg_bk, const_14_reg_bk, const_20_reg_bk, const_24_reg_bk;


reg  [3:0] round;
reg        final_reg;
reg        final_rd;

wire [255:0] MI_in;
wire  [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7;
wire  [31:0] mi_00, mi_01, mi_02, mi_03, mi_04, mi_05, mi_06, mi_07;
wire  [31:0] mi_10, mi_11, mi_12, mi_13, mi_14, mi_15, mi_16, mi_17;
wire  [31:0] mi_20, mi_21, mi_22, mi_23, mi_24, mi_25, mi_26, mi_27;
wire  [31:0] h_00, h_01, h_02, h_03, h_04, h_05, h_06, h_07;
wire  [31:0] h_10, h_11, h_12, h_13, h_14, h_15, h_16, h_17;
wire  [31:0] h_20, h_21, h_22, h_23, h_24, h_25, h_26, h_27;
wire  [31:0] new_state_00, new_state_01, new_state_02, new_state_03, new_state_04, new_state_05, new_state_06, new_state_07;
wire  [31:0] new_state_10, new_state_11, new_state_12, new_state_13, new_state_14, new_state_15, new_state_16, new_state_17;
wire  [31:0] new_state_20, new_state_21, new_state_22, new_state_23, new_state_24, new_state_25, new_state_26, new_state_27;
wire  [31:0] const_00, const_04, gen_0L, gen_0R;
wire  [31:0] const_10, const_14, gen_1L, gen_1R;
wire  [31:0] const_20, const_24, gen_2L, gen_2R;
wire  [31:0] new_const_0L, new_const_0R, new_const_1L, new_const_1R, new_const_2L, new_const_2R;
wire         busy, final, Rd_const;

reg finProcess;

MESSAGE_INJECTION message_injection(
	.msg(MI_in),
	.state_00(state_00), .state_01(state_01), .state_02(state_02), .state_03(state_03), .state_04(state_04), .state_05(state_05), .state_06(state_06), .state_07(state_07),
	.state_10(state_10), .state_11(state_11), .state_12(state_12), .state_13(state_13), .state_14(state_14), .state_15(state_15), .state_16(state_16), .state_17(state_17),
	.state_20(state_20), .state_21(state_21), .state_22(state_22), .state_23(state_23), .state_24(state_24), .state_25(state_25), .state_26(state_26), .state_27(state_27),
	.mi_00(mi_00), .mi_01(mi_01), .mi_02(mi_02), .mi_03(mi_03), .mi_04(mi_04), .mi_05(mi_05), .mi_06(mi_06), .mi_07(mi_07),
	.mi_10(mi_10), .mi_11(mi_11), .mi_12(mi_12), .mi_13(mi_13), .mi_14(mi_14), .mi_15(mi_15), .mi_16(mi_16), .mi_17(mi_17),
	.mi_20(mi_20), .mi_21(mi_21), .mi_22(mi_22), .mi_23(mi_23), .mi_24(mi_24), .mi_25(mi_25), .mi_26(mi_26), .mi_27(mi_27)
);

//permutation Q[0-2]
PERMUTATION_Q permutation_Q0(
	.mi_0(state_00), .mi_1(state_01), .mi_2(state_02), .mi_3(state_03), .mi_4(state_04), .mi_5(state_05), .mi_6(state_06), .mi_7(state_07), 
	.const_0(const_00_reg), .const_4(const_04_reg),
	.h_0(h_00), .h_1(h_01), .h_2(h_02), .h_3(h_03), .h_4(h_04), .h_5(h_05), .h_6(h_06), .h_7(h_07)
);

PERMUTATION_Q permutation_Q1(
	.mi_0(state_10), .mi_1(state_11), .mi_2(state_12), .mi_3(state_13), .mi_4(state_14), .mi_5(state_15), .mi_6(state_16), .mi_7(state_17), 
	.const_0(const_10_reg), .const_4(const_14_reg),
	.h_0(h_10), .h_1(h_11), .h_2(h_12), .h_3(h_13), .h_4(h_14), .h_5(h_15), .h_6(h_16), .h_7(h_17)
);

PERMUTATION_Q permutation_Q2(
	.mi_0(state_20), .mi_1(state_21), .mi_2(state_22), .mi_3(state_23), .mi_4(state_24), .mi_5(state_25), .mi_6(state_26), .mi_7(state_27), 
	.const_0(const_20_reg), .const_4(const_24_reg),
	.h_0(h_20), .h_1(h_21), .h_2(h_22), .h_3(h_23), .h_4(h_24), .h_5(h_25), .h_6(h_26), .h_7(h_27)
);

//Generate Const [0-2]
GEN_CONST gen_const0(
	.tl(const_0L), .tr(const_0R),
	.const_0(const_00), .const_4(const_04), .new_tl(gen_0L), .new_tr(gen_0R)
);

GEN_CONST gen_const1(
	.tl(const_1L), .tr(const_1R),
	.const_0(const_10), .const_4(const_14), .new_tl(gen_1L), .new_tr(gen_1R)
);

GEN_CONST gen_const2(
	.tl(const_2L), .tr(const_2R),
	.const_0(const_20), .const_4(const_24), .new_tl(gen_2L), .new_tr(gen_2R)
);

assign hash0 = state_00 ^ state_10 ^ state_20;
assign hash1 = state_01 ^ state_11 ^ state_21;
assign hash2 = state_02 ^ state_12 ^ state_22;
assign hash3 = state_03 ^ state_13 ^ state_23;
assign hash4 = state_04 ^ state_14 ^ state_24;
assign hash5 = state_05 ^ state_15 ^ state_25;
assign hash6 = state_06 ^ state_16 ^ state_26;
assign hash7 = state_07 ^ state_17 ^ state_27;

assign MI_in = (~final)? idata256 : 256'h0;

assign busy = ((EN && (round <= 4'd7) && ~fetch) || (fetch && ((round != 4'd0 || final_rd != 1'b1) || final)))? 1'b1 : 1'b0;

assign final = final_reg;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
		finProcess <= 0;
	else if(init_r)
		finProcess <= 0;
	else if(fetch)
		finProcess <= 1;
	else if(load)
		finProcess <= 0;
	else
		finProcess <= finProcess;
end

always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    final_rd <= 0;
  else if (init_r || load)
    final_rd <= 0;
  else if (final && (round == 1))
    final_rd <= 1;
  else
    final_rd <= final_rd;
end
  

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		final_reg <= 1'b0;
	end
	else begin
		if ((EN || (fetch && busy)) && (round == 4'd7)) begin
			if (final) begin
				final_reg <= 1'b0;
			end
			else if (fetch) begin
				final_reg <= 1'b1;
			end
			else begin
				final_reg <= final_reg;
			end
		end
		else begin
			final_reg <= final_reg;
		end
	end
end

assign new_state_00 = (round == 4'd0)? mi_00 : h_00;
assign new_state_01 = (round == 4'd0)? mi_01 : h_01;
assign new_state_02 = (round == 4'd0)? mi_02 : h_02;
assign new_state_03 = (round == 4'd0)? mi_03 : h_03;
assign new_state_04 = (round == 4'd0)? mi_04 : h_04;
assign new_state_05 = (round == 4'd0)? mi_05 : h_05;
assign new_state_06 = (round == 4'd0)? mi_06 : h_06;
assign new_state_07 = (round == 4'd0)? mi_07 : h_07;

assign new_state_10 = (round == 4'd0)? mi_10 : h_10;
assign new_state_11 = (round == 4'd0)? mi_11 : h_11;
assign new_state_12 = (round == 4'd0)? mi_12 : h_12;
assign new_state_13 = (round == 4'd0)? mi_13 : h_13;
assign new_state_14 = (round == 4'd0)? mi_14 : h_14;
assign new_state_15 = (round == 4'd0)? mi_15 : h_15;
assign new_state_16 = (round == 4'd0)? mi_16 : h_16;
assign new_state_17 = (round == 4'd0)? mi_17 : h_17;

assign new_state_20 = (round == 4'd0)? mi_20 : h_20;
assign new_state_21 = (round == 4'd0)? mi_21 : h_21;
assign new_state_22 = (round == 4'd0)? mi_22 : h_22;
assign new_state_23 = (round == 4'd0)? mi_23 : h_23;
assign new_state_24 = (round == 4'd0)? mi_24 : h_24;
assign new_state_25 = (round == 4'd0)? mi_25 : h_25;
assign new_state_26 = (round == 4'd0)? mi_26 : h_26;
assign new_state_27 = (round == 4'd0)? mi_27 : h_27;

assign new_const_0L = (round == 4'd7)? C_0L : gen_0L;
assign new_const_0R = (round == 4'd7)? C_0R : gen_0R;
assign new_const_1L = (round == 4'd7)? C_1L : gen_1L;
assign new_const_1R = (round == 4'd7)? C_1R : gen_1R;
assign new_const_2L = (round == 4'd7)? C_2L : gen_2L;
assign new_const_2R = (round == 4'd7)? C_2R : gen_2R;

assign Rd_const = ((EN || (fetch && busy)) && (round <= 4'd7))? 1'b1 : 1'b0;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		round <= 4'h0;
	end
	else begin
		if ((fetch && ~(finProcess)))
			round <= 4'd0;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			if (round == 4'd8) begin
				round <= 4'h0;
			end
			else begin
				round <= round + 'd1;
			end
		end
		else begin
			round <= round;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		state_00_bk <= 0;
		state_01_bk <= 0;
		state_02_bk <= 0;
		state_03_bk <= 0;
		state_04_bk <= 0;
		state_05_bk <= 0;
		state_06_bk <= 0;
		state_07_bk <= 0;

		state_10_bk <= 0;
		state_11_bk <= 0;
		state_12_bk <= 0;
		state_13_bk <= 0;
		state_14_bk <= 0;
		state_15_bk <= 0;
		state_16_bk <= 0;
		state_17_bk <= 0;

		state_20_bk <= 0;
		state_21_bk <= 0;
		state_22_bk <= 0;
		state_23_bk <= 0;
		state_24_bk <= 0;
		state_25_bk <= 0;
		state_26_bk <= 0;
		state_27_bk <= 0;
		
		const_0L_bk <= 0;
		const_0R_bk <= 0;
		const_1L_bk <= 0;
		const_1R_bk <= 0;
		const_2L_bk <= 0;
		const_2R_bk <= 0;
		
		const_00_reg_bk <= 0;
		const_04_reg_bk <= 0;
		const_10_reg_bk <= 0;
		const_14_reg_bk <= 0;
		const_20_reg_bk <= 0;
		const_24_reg_bk <= 0;
		
	end
	else if(init_r)
	begin
		state_00_bk <= V_00;
		state_01_bk <= V_01;
		state_02_bk <= V_02;
		state_03_bk <= V_03;
		state_04_bk <= V_04;
		state_05_bk <= V_05;
		state_06_bk <= V_06;
		state_07_bk <= V_07;

		state_10_bk <= V_10;
		state_11_bk <= V_11;
		state_12_bk <= V_12;
		state_13_bk <= V_13;
		state_14_bk <= V_14;
		state_15_bk <= V_15;
		state_16_bk <= V_16;
		state_17_bk <= V_17;

		state_20_bk <= V_20;
		state_21_bk <= V_21;
		state_22_bk <= V_22;
		state_23_bk <= V_23;
		state_24_bk <= V_24;
		state_25_bk <= V_25;
		state_26_bk <= V_26;
		state_27_bk <= V_27;
		
		const_0L_bk <= C_0L;
		const_0R_bk <= C_0R;
		const_1L_bk <= C_1L;
		const_1R_bk <= C_1R;
		const_2L_bk <= C_2L;
		const_2R_bk <= C_2R;
		
		const_00_reg_bk <= 0;
		const_04_reg_bk <= 0;
		const_10_reg_bk <= 0;
		const_14_reg_bk <= 0;
		const_20_reg_bk <= 0;
		const_24_reg_bk <= 0;		
	end
	else if(load)
	begin
		state_00_bk <= state_00;
		state_01_bk <= state_01;
		state_02_bk <= state_02;
		state_03_bk <= state_03;
		state_04_bk <= state_04;
		state_05_bk <= state_05;
		state_06_bk <= state_06;
		state_07_bk <= state_07;

		state_10_bk <= state_10;
		state_11_bk <= state_11;
		state_12_bk <= state_12;
		state_13_bk <= state_13;
		state_14_bk <= state_14;
		state_15_bk <= state_15;
		state_16_bk <= state_16;
		state_17_bk <= state_17;

		state_20_bk <= state_20;
		state_21_bk <= state_21;
		state_22_bk <= state_22;
		state_23_bk <= state_23;
		state_24_bk <= state_24;
		state_25_bk <= state_25;
		state_26_bk <= state_26;
		state_27_bk <= state_27;
		
		const_0L_bk <= const_0L;
		const_0R_bk <= const_0R;
		const_1L_bk <= const_1L;
		const_1R_bk <= const_1R;
		const_2L_bk <= const_2L;
		const_2R_bk <= const_2R;
		
		const_00_reg_bk <= const_00_reg;
		const_04_reg_bk <= const_04_reg;
		const_10_reg_bk <= const_10_reg;
		const_14_reg_bk <= const_14_reg;
		const_20_reg_bk <= const_20_reg;
		const_24_reg_bk <= const_24_reg;		
	end
	else
	begin
		state_00_bk <= state_00_bk;
		state_01_bk <= state_01_bk;
		state_02_bk <= state_02_bk;
		state_03_bk <= state_03_bk;
		state_04_bk <= state_04_bk;
		state_05_bk <= state_05_bk;
		state_06_bk <= state_06_bk;
		state_07_bk <= state_07_bk;

		state_10_bk <= state_10_bk;
		state_11_bk <= state_11_bk;
		state_12_bk <= state_12_bk;
		state_13_bk <= state_13_bk;
		state_14_bk <= state_14_bk;
		state_15_bk <= state_15_bk;
		state_16_bk <= state_16_bk;
		state_17_bk <= state_17_bk;

		state_20_bk <= state_20_bk;
		state_21_bk <= state_21_bk;
		state_22_bk <= state_22_bk;
		state_23_bk <= state_23_bk;
		state_24_bk <= state_24_bk;
		state_25_bk <= state_25_bk;
		state_26_bk <= state_26_bk;
		state_27_bk <= state_27_bk;
		
		const_0L_bk <= const_0L_bk;
		const_0R_bk <= const_0R_bk;
		const_1L_bk <= const_1L_bk;
		const_1R_bk <= const_1R_bk;
		const_2L_bk <= const_2L_bk;
		const_2R_bk <= const_2R_bk;
		
		const_00_reg_bk <= const_00_reg_bk;
		const_04_reg_bk <= const_04_reg_bk;
		const_10_reg_bk <= const_10_reg_bk;
		const_14_reg_bk <= const_14_reg_bk;
		const_20_reg_bk <= const_20_reg_bk;
		const_24_reg_bk <= const_24_reg_bk;			
	end
end
		
//register: state 
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_00 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_00 <= V_00;
		end
		else if (fetch && ~(finProcess))
			state_00 <= state_00_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_00 <= new_state_00;
		end
		else begin
			state_00 <= state_00;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_01 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_01 <= V_01;
		end
		else if (fetch && ~(finProcess))
			state_01 <= state_01_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_01 <= new_state_01;
		end
		else begin
			state_01 <= state_01;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_02 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_02 <= V_02;
		end
		else if (fetch && ~(finProcess))
			state_02 <= state_02_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_02 <= new_state_02;
		end
		else begin
			state_02 <= state_02;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_03 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_03 <= V_03;
		end
		else if (fetch && ~(finProcess))
			state_03 <= state_03_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_03 <= new_state_03;
		end
		else begin
			state_03 <= state_03;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_04 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_04 <= V_04;
		end
		else if (fetch && ~(finProcess))
			state_04 <= state_04_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_04 <= new_state_04;
		end
		else begin
			state_04 <= state_04;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_05 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_05 <= V_05;
		end
		else if (fetch && ~(finProcess))
			state_05 <= state_05_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_05 <= new_state_05;
		end
		else begin
			state_05 <= state_05;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_06 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_06 <= V_06;
		end
		else if (fetch && ~(finProcess))
			state_06 <= state_06_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_06 <= new_state_06;
		end
		else begin
			state_06 <= state_06;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_07 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_07 <= V_07;
		end
		else if (fetch && ~(finProcess))
			state_07 <= state_07_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_07 <= new_state_07;
		end
		else begin
			state_07 <= state_07;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_10 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_10 <= V_10;
		end
		else if (fetch && ~(finProcess))
			state_10 <= state_10_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_10 <= new_state_10;
		end
		else begin
			state_10 <= state_10;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_11 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_11 <= V_11;
		end
		else if (fetch && ~(finProcess))
			state_11 <= state_11_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_11 <= new_state_11;
		end
		else begin
			state_11 <= state_11;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_12 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_12 <= V_12;
		end
		else if (fetch && ~(finProcess))
			state_12 <= state_12_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_12 <= new_state_12;
		end
		else begin
			state_12 <= state_12;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_13 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_13 <= V_13;
		end
		else if (fetch && ~(finProcess))
			state_13 <= state_13_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_13 <= new_state_13;
		end
		else begin
			state_13 <= state_13;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_14 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_14 <= V_14;
		end
		else if (fetch && ~(finProcess))
			state_14 <= state_14_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_14 <= new_state_14;
		end
		else begin
			state_14 <= state_14;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_15 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_15 <= V_15;
		end
		else if (fetch && ~(finProcess))
			state_15 <= state_15_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_15 <= new_state_15;
		end
		else begin
			state_15 <= state_15;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_16 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_16 <= V_16;
		end
		else if (fetch && ~(finProcess))
			state_16 <= state_16_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_16 <= new_state_16;
		end
		else begin
			state_16 <= state_16;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_17 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_17 <= V_17;
		end
		else if (fetch && ~(finProcess))
			state_17 <= state_17_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_17 <= new_state_17;
		end
		else begin
			state_17 <= state_17;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_20 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_20 <= V_20;
		end
		else if (fetch && ~(finProcess))
			state_20 <= state_20_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_20 <= new_state_20;
		end
		else begin
			state_20 <= state_20;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_21 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_21 <= V_21;
		end
		else if (fetch && ~(finProcess))
			state_21 <= state_21_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_21 <= new_state_21;
		end
		else begin
			state_21 <= state_21;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_22 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_22 <= V_22;
		end
		else if (fetch && ~(finProcess))
			state_22 <= state_22_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_22 <= new_state_22;
		end
		else begin
			state_22 <= state_22;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_23 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_23 <= V_23;
		end
		else if (fetch && ~(finProcess))
			state_23 <= state_23_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_23 <= new_state_23;
		end
		else begin
			state_23 <= state_23;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_24 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_24 <= V_24;
		end
		else if (fetch && ~(finProcess))
			state_24 <= state_24_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_24 <= new_state_24;
		end
		else begin
			state_24 <= state_24;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_25 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_25 <= V_25;
		end
		else if (fetch && ~(finProcess))
			state_25 <= state_25_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_25 <= new_state_25;
		end
		else begin
			state_25 <= state_25;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_26 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_26 <= V_26;
		end
		else if (fetch && ~(finProcess))
			state_26 <= state_26_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_26 <= new_state_26;
		end
		else begin
			state_26 <= state_26;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_27 <= 32'h0;
	end
	else begin
		if (init_r) begin
			state_27 <= V_27;
		end
		else if (fetch && ~(finProcess))
			state_27 <= state_27_bk;
		else if ((EN && ~fetch) | (fetch && busy)) begin
			state_27 <= new_state_27;
		end
		else begin
			state_27 <= state_27;
		end
	end
end

//register: const
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_0L <= 32'h0;
	end
	else begin
		if (init_r) begin
			const_0L <= C_0L;
		end
		else if (fetch && ~(finProcess))
		  const_0L <= const_0L_bk;
		else if (Rd_const) begin
			const_0L <= new_const_0L;
		end
		else begin
			const_0L <= const_0L;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_0R <= 32'h0;
	end
	else begin
		if (init_r) begin
			const_0R <= C_0R;
		end
		else if (fetch && ~(finProcess))
		  const_0R <= const_0R_bk;		
		else if (Rd_const) begin
			const_0R <= new_const_0R;
		end
		else begin
			const_0R <= const_0R;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_1L <= 32'h0;
	end
	else begin
		if (init_r) begin
			const_1L <= C_1L;
		end
		else if (fetch && ~(finProcess))
		  const_1L <= const_1L_bk;		
		else if (Rd_const) begin
			const_1L <= new_const_1L;
		end
		else begin
			const_1L <= const_1L;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_1R <= 32'h0;
	end
	else begin
		if (init_r) begin
			const_1R <= C_1R;
		end
		else if (fetch && ~(finProcess))
		  const_1R <= const_1R_bk;		
		else if (Rd_const) begin
			const_1R <= new_const_1R;
		end
		else begin
			const_1R <= const_1R;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_2L <= 32'h0;
	end
	else begin
		if (init_r) begin
			const_2L <= C_2L;
		end
		else if (fetch && ~(finProcess))
		  const_2L <= const_2L_bk;		
		else if (Rd_const) begin
			const_2L <= new_const_2L;
		end
		else begin
			const_2L <= const_2L;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_2R <= 32'h0;
	end
	else begin
		if (init_r) begin
			const_2R <= C_2R;
		end
		else if (fetch && ~(finProcess))
		  const_2R <= const_2R_bk;		
		else if (Rd_const) begin
			const_2R <= new_const_2R;
		end
		else begin
			const_2R <= const_2R;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_00_reg <= 32'h0;
	end
	else begin
		if (fetch && ~(finProcess)) begin
		  const_00_reg <= const_00_reg_bk;
		end	  
		else if (Rd_const) begin
			const_00_reg <= const_00;
		end
		else begin
			const_00_reg <= const_00_reg;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_04_reg <= 32'h0;
	end
	else begin
		if (fetch && ~(finProcess)) begin
		  const_04_reg <= const_04_reg_bk;
		end	  	  
		else if (Rd_const) begin
			const_04_reg <= const_04;
		end
		else begin
			const_04_reg <= const_04_reg;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_10_reg <= 32'h0;
	end
	else begin
		if (fetch && ~(finProcess)) begin
		  const_10_reg <= const_10_reg_bk;
		end	  	  
		else if (Rd_const) begin
			const_10_reg <= const_10;
		end
		else begin
			const_10_reg <= const_10_reg;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_14_reg <= 32'h0;
	end
	else begin
		if (fetch && ~(finProcess)) begin
		  const_14_reg <= const_14_reg_bk;
		end	  	  
		else if (Rd_const) begin
			const_14_reg <= const_14;
		end
		else begin
			const_14_reg <= const_14_reg;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_20_reg <= 32'h0;
	end
	else begin
		if (fetch && ~(finProcess)) begin
		  const_20_reg <= const_20_reg_bk;
		end	  	  
		else if (Rd_const) begin
			const_20_reg <= const_20;
		end
		else begin
			const_20_reg <= const_20_reg;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		const_24_reg <= 32'h0;
	end
	else begin
		if (fetch && ~(finProcess)) begin
		  const_24_reg <= const_24_reg_bk;
		end	  	  
		else if (Rd_const) begin
			const_24_reg <= const_24;
		end
		else begin
			const_24_reg <= const_24_reg;
		end
	end
end


endmodule


