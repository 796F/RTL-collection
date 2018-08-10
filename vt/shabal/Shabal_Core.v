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

module SHABAL_CORE(
	                clk, 
	                rst_n,
	                idata32, 
	                init_r, 
	                fetch, 
	                load, 
	                EN, 
	                busy,
	                hash0, 
	                hash1, 
	                hash2, 
	                hash3, 
	                hash4, 
	                hash5, 
	                hash6, 
	                hash7
                  );

input         clk;
input         rst_n;
input         init_r;
input         fetch;
input         load;
input         EN;
input  [31:0] idata32;
output        busy;
output [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7; 

parameter a0_iv  = 32'h52F84552;
parameter a1_iv  = 32'hE54B7999;
parameter a2_iv  = 32'h2D8EE3EC;
parameter a3_iv  = 32'hB9645191;
parameter a4_iv  = 32'hE0078B86;
parameter a5_iv  = 32'hBB7C44C9;
parameter a6_iv  = 32'hD2B5C1CA;
parameter a7_iv  = 32'hB0D2EB8C;
parameter a8_iv  = 32'h14CE5A45;
parameter a9_iv  = 32'h22AF50DC;
parameter a10_iv = 32'hEFFDBC6B;
parameter a11_iv = 32'hEB21B74A;

parameter b0_iv  = 32'hB555C6EE;
parameter b1_iv  = 32'h3E710596;
parameter b2_iv  = 32'hA72A652F;
parameter b3_iv  = 32'h9301515F;
parameter b4_iv  = 32'hDA28C1FA;
parameter b5_iv  = 32'h696FD868;
parameter b6_iv  = 32'h9CB6BF72;
parameter b7_iv  = 32'h0AFE4002;
parameter b8_iv  = 32'hA6E03615;
parameter b9_iv  = 32'h5138C1D4;
parameter b10_iv = 32'hBE216306;
parameter b11_iv = 32'hB38B8890;
parameter b12_iv = 32'h3EA8B96B;
parameter b13_iv = 32'h3299ACE4;
parameter b14_iv = 32'h30924DD4;
parameter b15_iv = 32'h55CB34A5;

parameter c0_iv  = 32'hB405F031;
parameter c1_iv  = 32'hC4233EBA;
parameter c2_iv  = 32'hB3733979;
parameter c3_iv  = 32'hC0DD9D55;
parameter c4_iv  = 32'hC51C28AE;
parameter c5_iv  = 32'hA327B8E1;
parameter c6_iv  = 32'h56C56167;
parameter c7_iv  = 32'hED614433;
parameter c8_iv  = 32'h88B59D60;
parameter c9_iv  = 32'h60E2CEBA;
parameter c10_iv = 32'h758B4B8B;
parameter c11_iv = 32'h83E82A7F;
parameter c12_iv = 32'hBC968828;
parameter c13_iv = 32'hE6E00BF7;
parameter c14_iv = 32'hBA839E55;
parameter c15_iv = 32'h9B491C60;

reg [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11;
reg [31:0] b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15;
reg [31:0] c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15;
reg [31:0] c0_bk, c1_bk, c2_bk, c3_bk, c4_bk, c5_bk, c6_bk, c7_bk, c8_bk, c9_bk, c10_bk, c11_bk, c12_bk, c13_bk, c14_bk, c15_bk;
reg [31:0] m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;
reg [31:0] w0, w1;
reg [ 5:0] round;
reg [ 1:0] final_round;
reg        finProcess;
reg        finish;
reg        final_round_last_r;

wire [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7; 
wire        busy, final, msg_round_last, final_round_last, xor_counter, add_m, lotate_b, shift, shift_bm, permute, add_c, sub_swap;
wire [31:0] a11_w, b13_w, b15_w;

SHABAL_PERMUTATION shabal_permutation(.a0_in(a0), .a11_in(a11), .b0_in(b0), .b6_in(b6), .b9_in(b9), .b13_in(b13), .c8_in(c8), .m0_in(m0), .a11_out(a11_w), .b15_out(b15_w));

assign hash0 = c8;
assign hash1 = c9;
assign hash2 = c10;
assign hash3 = c11;
assign hash4 = c12;
assign hash5 = c13;
assign hash6 = c14;
assign hash7 = c15;

assign busy = ((EN && ((~final && ((round >= 6'd15) && (round <= 6'd61))) || msg_round_last || (final ^ final_round_last))) || (~EN && fetch && ~final_round_last_r))? 1'b1 : 1'b0;
assign final = (fetch && ((final_round >= 2'd1) && (final_round <= 2'd3)))? 1'b1 : 1'b0;
assign msg_round_last = (fetch && (round == 6'd62))? 1'b1 : 1'b0;
assign final_round_last = ((final_round == 2'd3) && (round == 6'd49))? 1'b1 : 1'b0;

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		final_round_last_r <= 0;
	else if (init_r)
		final_round_last_r <= 0;
	else if (load)
		final_round_last_r <= 0;
	else if(final_round_last)
		final_round_last_r <= 1;
	else
		final_round_last_r <= final_round_last_r;	
end

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		finProcess <= 0;
	else if (init_r)
		finProcess <= 0;
	else if (load)
		finProcess <= 0;
	else if(fetch)
		finProcess <= 1;
	else
		finProcess <= finProcess;	
end

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		finish <= 1;
	else if (init_r || load)
		finish <= 1;
	else if (~fetch)
		finish <= 1;
	else if (fetch && finProcess && ~EN && ~final_round_last_r && ~final_round_last)
		finish <= 0;
	else if(final_round_last || final_round_last_r)
		finish <= 1;
	else
		finish <= finish;	
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		round <= 6'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (round == 6'd62) round <= 6'h0;
			else if (final && (round == 6'd49)) round <= 6'h0;
			else round <= round + 'd1;
		end
		else if (fetch && ~finProcess)
			round <= 6'h0;
		else round <= round;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		final_round <= 2'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (msg_round_last) begin /* fetch round */
				final_round <= final_round + 1'd1;
			end
			else if (final && (round == 6'd49)) begin /* Final rounds */
				if (final_round == 2'd3) final_round <= 2'd0;
				else final_round <= final_round + 1'd1;
			end
			else final_round <= final_round;
		end
		else if (fetch && ~finProcess)
			final_round <= 2'd1;
		else final_round <= final_round;
	end
end

/* xor counter */
assign xor_counter = (round == 6'd0)? 1'b1 : 1'b0;

/* add M to B (and lotate 17 bit) */
assign add_m = (~final && ((round >= 6'd0) && (round <= 6'd15)))? 1'b1 : 1'b0;
assign lotate_b = (final && (round == 6'd0))? 1'b1 : 1'b0;
assign b13_w = (add_m)? (b14 + idata32) : 32'h0;

/* shift A and C */
assign shift = ((~final && ((round >= 6'd14) && (round <= 6'd61))) || (final && ((round >= 6'd1) && (round <= 6'd48))))? 1'b1 : 1'b0;

/* shift B and M */
assign shift_bm = ((~final && ((round >= 6'd0) && (round <= 6'd61))) || (final && ((round >= 6'd1) && (round <= 6'd48))))? 1'b1 : 1'b0;

/* set B */
assign permute = (~final && ((round >= 6'd0) && (round <= 6'd13)))? 1'b1 : 1'b0;

/* add C to A */
assign add_c = ((~final && (round == 6'd62)) || (final && ((round == 6'd49))))? 1'b1 : 1'b0;

/* (subtract M from C while not fetch) and swap B with C */
assign sub_swap = (~final && (round == 6'd62))? 1'b1 : 1'b0;
assign swap = (final && (round == 6'd49))? 1'b1 : 1'b0;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		w0 <= 32'h1;
		w1 <= 32'h0;
	end
	else begin
		if (fetch && ~finProcess && ~EN) begin
			w0 <= (w0 == 32'h0) ? 32'hFFFFFFFF : w0 - 1;
			w1 <= (w0 == 32'h0) ? w1 - 1 : w1;
		end
		else if ((round == 6'd62) && ~fetch) begin
			if (w0 == 32'hFFFFFFFF) begin
				w0 <= 32'h0;
				w1 <= w1 + 'd1;
			end
			else begin
				w0 <= w0 + 'd1;
			end
		end
		else begin
			w0 <= w0;
			w1 <= w1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a0 <= a0_iv;
	end
	else begin
		if (init_r) a0 <= a0_iv;
		else if (EN || ~finish) begin
			if (xor_counter) a0 <= a0 ^ w0;
			else if (shift) a0 <= a1;
			else if (add_c) a0 <= a0 + c3 + c15 + c11;
			else a0 <= a0;
		end
		else a0 <= a0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a1 <= a1_iv;
	end
	else begin
		if (init_r) a1 <= a1_iv;
		else if (EN || ~finish) begin
			if (xor_counter) a1 <= a1 ^ w1;
			else if (shift) a1 <= a2;
			else if (add_c) a1 <= a1 + c4 + c0 + c12;
			else a1 <= a1;
		end
		else a1 <= a1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a2 <= a2_iv;
	end
	else begin
		if (init_r) a2 <= a2_iv;
		else if (EN || ~finish) begin
			if (shift) a2 <= a3;
			else if (add_c) a2 <= a2 + c5 + c1 + c13;
			else a2 <= a2;
		end
		else a2 <= a2;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a3 <= a3_iv;
	end
	else begin
		if (init_r) a3 <= a3_iv;
		else if (EN || ~finish) begin
			if (shift) a3 <= a4;
			else if (add_c) a3 <= a3 + c6 + c2 + c14;
			else a3 <= a3;
		end
		else a3 <= a3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a4 <= a4_iv;
	end
	else begin
		if (init_r) a4 <= a4_iv;
		else if (EN || ~finish) begin
			if (shift) a4 <= a5;
			else if (add_c) a4 <= a4 + c7 + c3 + c15;
			else a4 <= a4;
		end
		else a4 <= a4;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a5 <= a5_iv;
	end
	else begin
		if (init_r) a5 <= a5_iv;
		else if (EN || ~finish) begin
			if (shift) a5 <= a6;
			else if (add_c) a5 <= a5 + c8 + c4 + c0;
			else a5 <= a5;
		end
		else a5 <= a5;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a6 <= a6_iv;
	end
	else begin
		if (init_r) a6 <= a6_iv;
		else if (EN || ~finish) begin
			if (shift) a6 <= a7;
			else if (add_c) a6 <= a6 + c9 + c5 + c1;
			else a6 <= a6;
		end
		else a6 <= a6;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a7 <= a7_iv;
	end
	else begin
		if (init_r) a7 <= a7_iv;
		else if (EN || ~finish) begin
			if (shift) a7 <= a8;
			else if (add_c) a7 <= a7 + c10 + c6 + c2;
			else a7 <= a7;
		end
		else a7 <= a7;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a8 <= a8_iv;
	end
	else begin
		if (init_r) a8 <= a8_iv;
		else if (EN || ~finish) begin
			if (shift) a8 <= a9;
			else if (add_c) a8 <= a8 + c11 + c7 + c3;
			else a8 <= a8;
		end
		else a8 <= a8;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a9 <= a9_iv;
	end
	else begin
		if (init_r) a9 <= a9_iv;
		else if (EN || ~finish) begin
			if (shift) a9 <= a10;
			else if (add_c) a9 <= a9 + c12 + c8 + c4;
			else a9 <= a9;
		end
		else a9 <= a9;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a10 <= a10_iv;
	end
	else begin
		if (init_r) a10 <= a10_iv;
		else if (EN || ~finish) begin
			if (shift) a10 <= a11;
			else if (add_c) a10 <= a10 + c13 + c9 + c5;
			else a10 <= a10;
		end
		else a10 <= a10;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		a11 <= a11_iv;
	end
	else begin
		if (init_r) a11 <= a11_iv;
		else if (EN || ~finish) begin
			if (shift) a11 <= a11_w;
			else if (add_c) a11 <= a11 + c14 + c10 + c6;
			else a11 <= a11;
		end
		else a11 <= a11;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b0 <= b2_iv;
	end
	else begin
		if (init_r) b0 <= b2_iv;
		else if (~EN && fetch && ~finProcess) 
			b0 <= c0_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b0 <= b1;
			else if (sub_swap) begin
				if (fetch) b0 <= c0;
				else b0 <= c2 - m2;
			end
			else if (swap) b0 <= c0;
			else if (lotate_b) b0 <= {b0[14:0],b0[31:15]};
			else b0 <= b0;
		end
		else b0 <= b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b1 <= b3_iv;
	end
	else begin
		if (init_r) b1 <= b3_iv;
		else if (~EN && fetch && ~finProcess) 
			b1 <= c1_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b1 <= b2;
			else if (sub_swap) begin
				if (fetch) b1 <= c1;
				else b1 <= c3 - m3;
			end
			else if (swap) b1 <= c1;
			else if (lotate_b) b1 <= {b1[14:0],b1[31:15]};
			else b1 <= b1;
		end
		else b1 <= b1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b2 <= b4_iv;
	end
	else begin
		if (init_r) b2 <= b4_iv;
		else if (~EN && fetch && ~finProcess) 
			b2 <= c2_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b2 <= b3;
			else if (sub_swap) begin
				if (fetch) b2 <= c2;
				else b2 <= c4 - m4;
			end
			else if (swap) b2 <= c2;
			else if (lotate_b) b2 <= {b2[14:0],b2[31:15]};
			else b2 <= b2;
		end
		else b2 <= b2;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b3 <= b5_iv;
	end
	else begin
		if (init_r) b3 <= b5_iv;
		else if (~EN && fetch && ~finProcess) 
			b3 <= c3_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b3 <= b4;
			else if (sub_swap) begin
				if (fetch) b3 <= c3;
				else b3 <= c5 - m5;
			end
			else if (swap) b3 <= c3;
			else if (lotate_b) b3 <= {b3[14:0],b3[31:15]};
			else b3 <= b3;
		end
		else b3 <= b3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b4 <= b6_iv;
	end
	else begin
		if (init_r) b4 <= b6_iv;
		else if (~EN && fetch && ~finProcess) 
			b4 <= c4_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b4 <= b5;
			else if (sub_swap) begin
				if (fetch) b4 <= c4;
				else b4 <= c6 - m6;
			end
			else if (swap) b4 <= c4;
			else if (lotate_b) b4 <= {b4[14:0],b4[31:15]};
			else b4 <= b4;
		end
		else b4 <= b4;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b5 <= b7_iv;
	end
	else begin
		if (init_r) b5 <= b7_iv;
		else if (~EN && fetch && ~finProcess) 
			b5 <= c5_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b5 <= b6;
			else if (sub_swap) begin
				if (fetch) b5 <= c5;
				else b5 <= c7 -m7;
			end
			else if (swap) b5 <= c5;
			else if (lotate_b) b5 <= {b5[14:0],b5[31:15]};
			else b5 <= b5;
		end
		else b5 <= b5;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b6 <= b8_iv;
	end
	else begin
		if (init_r) b6 <= b8_iv;
		else if (~EN && fetch && ~finProcess) 
			b6 <= c6_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b6 <= b7;
			else if (sub_swap) begin
				if (fetch) b6 <= c6;
				else b6 <= c8 -m8;
			end
			else if (swap) b6 <= c6;
			else if (lotate_b) b6 <= {b6[14:0],b6[31:15]};
			else b6 <= b6;
		end
		else b6 <= b6;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b7 <= b9_iv;
	end
	else begin
		if (init_r) b7 <= b9_iv;
		else if (~EN && fetch && ~finProcess) 
			b7 <= c7_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b7 <= b8;
			else if (sub_swap) begin
				if (fetch) b7 <= c7;
				else b7 <= c9 -m9;
			end
			else if (swap) b7 <= c7;
			else if (lotate_b) b7 <= {b7[14:0],b7[31:15]};
			else b7 <= b7;
		end
		else b7 <= b7;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b8 <= b10_iv;
	end
	else begin
		if (init_r) b8 <= b10_iv;
		else if (~EN && fetch && ~finProcess) 
			b8 <= c8_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b8 <= b9;
			else if (sub_swap) begin
				if (fetch) b8 <= c8;
				else b8 <= c10 - m10;
			end
			else if (swap) b8 <= c8;
			else if (lotate_b) b8 <= {b8[14:0],b8[31:15]};
			else b8 <= b8;
		end
		else b8 <= b8;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b9 <= b11_iv;
	end
	else begin
		if (init_r) b9 <= b11_iv;
		else if (~EN && fetch && ~finProcess) 
			b9 <= c9_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b9 <= b10;
			else if (sub_swap) begin
				if (fetch) b9 <= c9;
				else b9 <= c11 - m11;
			end
			else if (swap) b9 <= c9;
			else if (lotate_b) b9 <= {b9[14:0],b9[31:15]};
			else b9 <= b9;
		end
		else b9 <= b9;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b10 <= b12_iv;
	end
	else begin
		if (init_r) b10 <= b12_iv;
		else if (~EN && fetch && ~finProcess) 
			b10 <= c10_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b10 <= b11;
			else if (sub_swap) begin
				if (fetch) b10 <= c10;
				else b10 <= c12 - m12;
			end
			else if (swap) b10 <= c10;
			else if (lotate_b) b10 <= {b10[14:0],b10[31:15]};
			else b10 <= b10;
		end
		else b10 <= b10;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b11 <= b13_iv;
	end
	else begin
		if (init_r) b11 <= b13_iv;
		else if (~EN && fetch && ~finProcess) 
			b11 <= c11_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b11 <= b12;
			else if (sub_swap) begin
				if (fetch) b11 <= c11;
				else b11 <= c13 - m13;
			end
			else if (swap) b11 <= c11;
			else if (lotate_b) b11 <= {b11[14:0],b11[31:15]};
			else b11 <= b11;
		end
		else b11 <= b11;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b12 <= b14_iv;
	end
	else begin
		if (init_r) b12 <= b14_iv;
		else if (~EN && fetch && ~finProcess) 
			b12 <= c12_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b12 <= b13;
			else if (sub_swap)begin
				if (fetch) b12 <= c12;
				else b12 <= c14 - m14;
			end
			else if (swap) b12 <= c12;
			else if (lotate_b) b12 <= {b12[14:0],b12[31:15]};
			else b12 <= b12;
		end
		else b12 <= b12;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b13 <= b15_iv;
	end
	else begin
		if (init_r) b13 <= b15_iv;
		else if (~EN && fetch && ~finProcess) 
			b13 <= c13_bk;
		else if (EN || ~finish) begin
			if (add_m) b13 <= {b13_w[14:0],b13_w[31:15]};
			else if (shift_bm) b13 <= b14;
			else if (sub_swap) begin
				if (fetch) b13 <= c13;
				else b13 <= c15 - m15;
			end
			else if (swap) b13 <= c13;
			else if (lotate_b) b13 <= {b13[14:0],b13[31:15]};
			else b13 <= b13;
		end
		else b13 <= b13;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b14 <= b0_iv;
	end
	else begin
		if (init_r) b14 <= b0_iv;
		else if (~EN && fetch && ~finProcess) 
			b14 <= c14_bk;
		else if (EN || ~finish) begin
			if (shift_bm) b14 <= b15;
			else if (sub_swap) begin
				if (fetch) b14 <= c14;
				else b14 <= c0 - m0;
			end
			else if (swap) b14 <= c14;
			else if (lotate_b) b14 <= {b14[14:0],b14[31:15]};
			else b14 <= b14;
		end
		else b14 <= b14;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		b15 <= b1_iv;
	end
	else begin
		if (init_r) b15 <= b1_iv;
		else if (~EN && fetch && ~finProcess) 
			b15 <= c15_bk;
		else if (EN || ~finish) begin
			if (permute) b15 <= b0;
			else if (shift_bm) b15 <= b15_w;
			else if (sub_swap) begin
				if (fetch) b15 <= c15;
				else b15 <= c1 - m1;
			end
			else if (swap) b15 <= c15;
			else if (lotate_b) b15 <= {b15[14:0],b15[31:15]};
			else b15 <= b15;
		end
		else b15 <= b15;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c0 <= c0_iv;
	end
	else begin
		if (init_r) c0 <= c0_iv;
		else if (EN || ~finish) begin
			if (shift) c0 <= c15;
			else if (sub_swap) c0 <= b0;
			else if (swap) c0 <= b0;
			else c0 <= c0;
		end
		else c0 <= c0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c1 <= c1_iv;
	end
	else begin
		if (init_r) c1 <= c1_iv;
		else if (EN || ~finish) begin
			if (shift) c1 <= c0;
			else if (sub_swap) c1 <= b1;
			else if (swap) c1 <= b1;
			else c1 <= c1;
		end
		else c1 <= c1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c2 <= c2_iv;
	end
	else begin
		if (init_r) c2 <= c2_iv;
		else if (EN || ~finish) begin
			if (shift) c2 <= c1;
			else if (sub_swap) c2 <= b2;
			else if (swap) c2 <= b2;
			else c2 <= c2;
		end
		else c2 <= c2;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c3 <= c3_iv;
	end
	else begin
		if (init_r) c3 <= c3_iv;
		else if (EN || ~finish) begin
			if (shift) c3 <= c2;
			else if (sub_swap) c3 <= b3;
			else if (swap) c3 <= b3;
			else c3 <= c3;
		end
		else c3 <= c3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c4 <= c4_iv;
	end
	else begin
		if (init_r) c4 <= c4_iv;
		else if (EN || ~finish) begin
			if (shift) c4 <= c3;
			else if (sub_swap) c4 <= b4;
			else if (swap) c4 <= b4;
			else c4 <= c4;
		end
		else c4 <= c4;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c5 <= c5_iv;
	end
	else begin
		if (init_r) c5 <= c5_iv;
		else if (EN || ~finish) begin
			if (shift) c5 <= c4;
			else if (sub_swap) c5 <= b5;
			else if (swap) c5 <= b5;
			else c5 <= c5;
		end
		else c5 <= c5;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c6 <= c6_iv;
	end
	else begin
		if (init_r) c6 <= c6_iv;
		else if (EN || ~finish) begin
			if (shift) c6 <= c5;
			else if (sub_swap) c6 <= b6;
			else if (swap) c6 <= b6;
			else c6 <= c6;
		end
		else c6 <= c6;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c7 <= c7_iv;
	end
	else begin
		if (init_r) c7 <= c7_iv;
		else if (EN || ~finish) begin
			if (shift) c7 <= c6;
			else if (sub_swap) c7 <= b7;
			else if (swap) c7 <= b7;
			else c7 <= c7;
		end
		else c7 <= c7;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c8 <= c8_iv;
	end
	else begin
		if (init_r) c8 <= c8_iv;
		else if (EN || ~finish) begin
			if (shift) c8 <= c7;
			else if (sub_swap) c8 <= b8;
			else if (swap) c8 <= b8;
			else c8 <= c8;
		end
		else c8 <= c8;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c9 <= c9_iv;
	end
	else begin
		if (init_r) c9 <= c9_iv;
		else if (EN || ~finish) begin
			if (shift) c9 <= c8;
			else if (sub_swap) c9 <= b9;
			else if (swap) c9 <= b9;
			else c9 <= c9;
		end
		else c9 <= c9;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c10 <= c10_iv;
	end
	else begin
		if (init_r) c10 <= c10_iv;
		else if (EN || ~finish) begin
			if (shift) c10 <= c9;
			else if (sub_swap) c10 <= b10;
			else if (swap) c10 <= b10;
			else c10 <= c10;
		end
		else c10 <= c10;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c11 <= c11_iv;
	end
	else begin
		if (init_r) c11 <= c11_iv;
		else if (EN || ~finish) begin
			if (shift) c11 <= c10;
			else if (sub_swap) c11 <= b11;
			else if (swap) c11 <= b11;
			else c11 <= c11;
		end
		else c11 <= c11;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c12 <= c12_iv;
	end
	else begin
		if (init_r) c12 <= c12_iv;
		else if (EN || ~finish) begin
			if (shift) c12 <= c11;
			else if (sub_swap) c12 <= b12;
			else if (swap) c12 <= b12;
			else c12 <= c12;
		end
		else c12 <= c12;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c13 <= c13_iv;
	end
	else begin
		if (init_r) c13 <= c13_iv;
		else if (EN || ~finish) begin
			if (shift) c13 <= c12;
			else if (sub_swap) c13 <= b13;
			else if (swap) c13 <= b13;
			else c13 <= c13;
		end
		else c13 <= c13;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c14 <= c14_iv;
	end
	else begin
		if (init_r) c14 <= c14_iv;
		else if (EN || ~finish) begin
			if (shift) c14 <= c13;
			else if (sub_swap) c14 <= b14;
			else if (swap) c14 <= b14;
			else c14 <= c14;
		end
		else c14 <= c14;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c15 <= c15_iv;
	end
	else begin
		if (init_r) c15 <= c15_iv;
		else if (EN || ~finish) begin
			if (shift) c15 <= c14;
			else if (sub_swap) c15 <= b15;
			else if (swap) c15 <= b15;
			else c15 <= c15;
		end
		else c15 <= c15;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m0 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m0 <= m1;
			else m0 <= m0;
		end
		else m0 <= m0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m1 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m1 <= m2;
			else m1 <= m1;
		end
		else m1 <= m1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m2 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m2 <= m3;
			else m2 <= m2;
		end
		else m2 <= m2;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m3 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m3 <= m4;
			else m3 <= m3;
		end
		else m3 <= m3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m4 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m4 <= m5;
			else m4 <= m4;
		end
		else m4 <= m4;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m5 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m5 <= m6;
			else m5 <= m5;
		end
		else m5 <= m5;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m6 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m6 <= m7;
			else m6 <= m6;
		end
		else m6 <= m6;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m7 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m7 <= m8;
			else m7 <= m7;
		end
		else m7 <= m7;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m8 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m8 <= m9;
			else m8 <= m8;
		end
		else m8 <= m8;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m9 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m9 <= m10;
			else m9 <= m9;
		end
		else m9 <= m9;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m10 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m10 <= m11;
			else m10 <= m10;
		end
		else m10 <= m10;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m11 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m11 <= m12;
			else m11 <= m11;
		end
		else m11 <= m11;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m12 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m12 <= m13;
			else m12 <= m12;
		end
		else m12 <= m12;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m13 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) begin
				if (add_m) m13 <= idata32;
				else  m13 <= m14;
			end
			else m13 <= m13;
		end
		else m13 <= m13;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m14 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m14 <= m15;
			else m14 <= m14;
		end
		else m14 <= m14;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m15 <= 32'h0;
	end
	else begin
		if (EN || ~finish) begin
			if (shift_bm) m15 <= m0;
			else m15 <= m15;
		end
		else m15 <= m15;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		c0_bk  <= 0;
		c1_bk  <= 0;
		c2_bk  <= 0;
		c3_bk  <= 0;
		c4_bk  <= 0;
		c5_bk  <= 0;
		c6_bk  <= 0;
		c7_bk  <= 0;
		c8_bk  <= 0;
		c9_bk  <= 0;
		c10_bk <= 0;
		c11_bk <= 0;
		c12_bk <= 0;
		c13_bk <= 0;
		c14_bk <= 0;
		c15_bk <= 0;
	end
	else if (sub_swap) begin
		c0_bk  <= c0;
		c1_bk  <= c1;
		c2_bk  <= c2;
		c3_bk  <= c3;
		c4_bk  <= c4;
		c5_bk  <= c5;
		c6_bk  <= c6;
		c7_bk  <= c7;
		c8_bk  <= c8;
		c9_bk  <= c9;
		c10_bk <= c10;
		c11_bk <= c11;
		c12_bk <= c12;
		c13_bk <= c13;
		c14_bk <= c14;
		c15_bk <= c15;
	end
	else begin
		c0_bk  <= c0_bk;
		c1_bk  <= c1_bk;
		c2_bk  <= c2_bk;
		c3_bk  <= c3_bk;
		c4_bk  <= c4_bk;
		c5_bk  <= c5_bk;
		c6_bk  <= c6_bk;
		c7_bk  <= c7_bk;
		c8_bk  <= c8_bk;
		c9_bk  <= c9_bk;
		c10_bk <= c10_bk;
		c11_bk <= c11_bk;
		c12_bk <= c12_bk;
		c13_bk <= c13_bk;
		c14_bk <= c14_bk;
		c15_bk <= c15_bk;
	end
end
endmodule


