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
module SKEIN_CORE(
                  clk, 
                  rst_n,
                  Ld_tweak, 
                  Ld_posi, 
                  idata, 
                  msg0, 
                  msg1, 
                  msg2, 
                  msg3,
                  hash0, 
                  hash1, 
                  hash2, 
                  hash3,
                  start, 
                  busy, 
                  init);

parameter const = 64'h5555555555555555;
parameter outputvalue = 128'h00000000_00000008_FF000000_00000000;
parameter IV0 = 64'h164290a9d4eeef1d;
parameter IV1 = 64'h8e7eaf44b1b0cd15;
parameter IV2 = 64'ha8ba0822f69d09ae;
parameter IV3 = 64'h0af25c5e364a6468;

input         clk;
input         rst_n;
input         Ld_tweak;
input         Ld_posi;
input         start;
input         init;
input  [15:0] idata;
input  [63:0] msg0;
input  [63:0] msg1;
input  [63:0] msg2;
input  [63:0] msg3;
output [63:0] hash0;
output [63:0] hash1;
output [63:0] hash2;
output [63:0] hash3;
output        busy;

wire [63:0] y0_0, y1_0, y2_0, y3_0;
wire [63:0] y0_1, y1_1, y2_1, y3_1;
wire [63:0] y0_2, y1_2, y2_2, y3_2;
wire [63:0] y0, y1, y2, y3;
wire        final;
wire        first;
reg [ 63:0] k0, k1, k2, k3; 
reg [  5:0] round;
reg [ 63:0] state0, state1, state2, state3;
reg [127:0] tweak;
reg         EN;
wire [60:0] position;
reg  [63:0] posi_bits;
reg         EOM;
wire [63:0] k4;
wire [63:0] sk0, sk1, sk2, sk3;
wire [63:0] chain0, chain1, chain2, chain3;
wire [63:0] sum;
wire        partial;

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) EN <= 0;
   else if (start) EN <= 1;
   else if (round == 6'b010011) begin
      EN <= 0;
   end
   else EN <= EN;
end

assign busy = (start | EN)? 1:0;

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) round <= 0;
   else if (EN) begin
      if (round == 6'b110011) round <= 0;
      else if (round == 6'b010011) begin 
         if (EOM) round <= 6'b100000;
         else round <= 0;
      end
      else round <= round + 1;
   end
   else round <= round;
end

assign sum = tweak[63:0] + 64'h20;
always @(posedge clk or negedge rst_n)
begin
   if (~rst_n)
        EOM <= 0;
   else if (init)
        EOM <= 0;
   else if (Ld_tweak && (tweak[60:0] == position))
        EOM <= 1;
   else
        EOM <= EOM;
end
always @(posedge clk or negedge rst_n)
begin
   if (~rst_n)
	tweak <= 128'h0;
   else if (Ld_tweak && (tweak[60:0] == position))
        tweak <= 128'h8ff00000000000000;
   else if (Ld_tweak && (tweak == 128'h0) && (position < 61'h20) && partial) //first and last block
	tweak <= {position,64'hf080000000000000};
   else if (Ld_tweak && (tweak == 128'h0) && (position < 61'h20)) //first and last block
	tweak <= {position,64'hf000000000000000};
   else if (Ld_tweak && (tweak == 128'h0)) //first block
        tweak <= {64'h20,64'h7000000000000000};
   else if (Ld_tweak && ((position-tweak[63:0]) < 61'h20) && partial) //last block
        tweak <= {position,64'hb080000000000000};
   else if (Ld_tweak && ((position-tweak[63:0]) < 61'h20)) //last block
        tweak <= {position,64'hb000000000000000};
   else if (Ld_tweak) 
        tweak <= {sum, 64'h3000000000000000};
   else if (round == 6'b010011) begin
      if (EOM) tweak <= outputvalue;
      else   tweak <= {tweak[127:64],tweak[127:64]^tweak[63:0]};
   end
   else if (EN) tweak <= {tweak[63:0],(tweak[127:64]^tweak[63:0])};
   else
        tweak <= tweak;

end

assign position = posi_bits[63:3]+{60'h0,partial};
assign partial = (posi_bits[0] | posi_bits[1] | posi_bits[2]);
always @(posedge clk or negedge rst_n)
begin
   if (~rst_n)
	posi_bits <= 64'h0;
   else if (Ld_posi)
	posi_bits <= ((posi_bits << 16) | idata);
   else
        posi_bits <= posi_bits;
end

SKEIN_KEY_SCHEDULE skein_key_schedule(
   .k0(k0), .k1(k1), .k2(k2), .k3(k3),
   .tweak(tweak), .s(round[4:0]),
   .sk0(sk0), .sk1(sk1), .sk2(sk2), .sk3(sk3));

SKEIN_MIX_FUNCTION skein_mix_function0_0(
   .x0(state0), .x1(state1),
   .y0(y0_0), .y1(y3_0), .Rj(1'b0), .Rd({~round[0],2'b00}));
SKEIN_MIX_FUNCTION skein_mix_function0_1(
   .x0(state2), .x1(state3),
   .y0(y2_0), .y1(y1_0), .Rj(1'b1), .Rd({~round[0],2'b00}));

SKEIN_MIX_FUNCTION skein_mix_function1_0(
   .x0(y0_0), .x1(y1_0),
   .y0(y0_1), .y1(y3_1), .Rj(1'b0), .Rd({~round[0],2'b01}));
SKEIN_MIX_FUNCTION skein_mix_function1_1(
   .x0(y2_0), .x1(y3_0),
   .y0(y2_1), .y1(y1_1), .Rj(1'b1), .Rd({~round[0],2'b01}));

SKEIN_MIX_FUNCTION skein_mix_function2_0(
   .x0(y0_1), .x1(y1_1),
   .y0(y0_2), .y1(y3_2), .Rj(1'b0), .Rd({~round[0],2'b10}));
SKEIN_MIX_FUNCTION skein_mix_function2_1(
   .x0(y2_1), .x1(y3_1),
   .y0(y2_2), .y1(y1_2), .Rj(1'b1), .Rd({~round[0],2'b10}));

SKEIN_MIX_FUNCTION skein_mix_function3_0(
   .x0(y0_2), .x1(y1_2),
   .y0(y0), .y1(y3), .Rj(1'b0), .Rd({~round[0],2'b11}));
SKEIN_MIX_FUNCTION skein_mix_function3_1(
   .x0(y2_2), .x1(y3_2),
   .y0(y2), .y1(y1), .Rj(1'b1), .Rd({~round[0],2'b11}));

assign k4 = k0 ^ k1 ^ k2 ^ k3 ^ const;
assign chain0 = y0 + sk0;  
assign chain1 = y1 + sk1;  
assign chain2 = y2 + sk2;  
assign chain3 = y3 + sk3;  

//ctx->X
assign hash0 = (EOM)? state0 : state0 ^ msg0;
assign hash1 = (EOM)? state1 : state1 ^ msg1;
assign hash2 = (EOM)? state2 : state2 ^ msg2;
assign hash3 = (EOM)? state3 : state3 ^ msg3;

//state = X0, X1, X2 and X3
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state0 <= 0;
   else if (EN) begin
      if (round[4:0] == 'd19) state0 <= state0;
      else if (round == 0) state0 <= msg0 + sk0;
      else if (round == 6'h20) state0 <= sk0;
      else state0 <= chain0;
   end
   else state0 <= state0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state1 <= 0;
   else if (EN) begin
      if (round[4:0] == 'd19) state1 <= state1;
      else if (round == 0) state1 <= msg1 + sk1;
      else if (round == 6'h20) state1 <= sk1;
      else state1 <= chain1;
   end
   else state1 <= state1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state2 <= 0;
   else if (EN) begin
      if (round[4:0] == 'd19) state2 <= state2;
      else if (round == 0) state2 <= msg2 + sk2;
      else if (round == 6'h20) state2 <= sk2;
      else state2 <= chain2;
   end
   else state2 <= state2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state3 <= 0;
   else if (EN) begin
      if (round[4:0] == 'd19) state3 <= state3;
      else if (round == 0) state3 <= msg3 + sk3;
      else if (round == 6'h20) state3 <= sk3;
      else state3 <= chain3;
   end
   else state3 <= state3;
end

//key reg = Ks
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) k0 <= 0;
   else if (init) k0 <= IV0;
   else if (EN) begin
      if (round[4:0] == 'd19) k0 <= state0 ^ msg0;
      else k0 <= k1;
   end
   else k0 <= k0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) k1 <= 0;
   else if (init) k1 <= IV1;
   else if (EN) begin
      if (round[4:0] == 'd19) k1 <= state1 ^ msg1;
      else k1 <= k2;
   end
   else k1 <= k1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) k2 <= 0;
   else if (init) k2 <= IV2;
   else if (EN) begin
      if (round[4:0] == 'd19) k2 <= state2 ^ msg2;
      else k2 <= k3;
   end
   else k2 <= k2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) k3 <= 0;
   else if (init) k3 <= IV3;
   else if (EN) begin
      if (round[4:0] == 'd19) k3 <= state3 ^ msg3;
      else k3 <= k4;
   end
   else k3 <= k3;
end

endmodule

