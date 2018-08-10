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

module BLAKE_CORE(clk, 
                  rst_n, 
                  init, 
                  Ld_EN, 
                  counter, 
                  start, 
                  busy, 
                  hash0, 
                  hash1, 
                  hash2, 
                  hash3, 
                  hash4, 
                  hash5, 
                  hash6, 
                  hash7, 
                  idata32);

input        clk;
input        rst_n;
input        init;
input        Ld_EN;
input [63:0] counter;
input        start;
input [31:0] idata32;
output       busy;
output reg [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7;

parameter IV0 = 32'h6a09e667;
parameter IV1 = 32'hbb67ae85;
parameter IV2 = 32'h3c6ef372;
parameter IV3 = 32'ha54ff53a;
parameter IV4 = 32'h510e527f;
parameter IV5 = 32'h9b05688c;
parameter IV6 = 32'h1f83d9ab;
parameter IV7 = 32'h5be0cd19;
parameter C0 = 32'h243F6A88; 
parameter C1 = 32'h85A308D3;
parameter C2 = 32'h13198A2E; 
parameter C3 = 32'h03707344;
parameter C4 = 32'hA4093822; 
parameter C5 = 32'h299F31D0;
parameter C6 = 32'h082EFA98; 
parameter C7 = 32'hEC4E6C89;
parameter C8 = 32'h452821E6; 
parameter C9 = 32'h38D01377;
parameter C10 = 32'hBE5466CF;  
parameter C11 = 32'h34E90C6C; 
parameter C12 = 32'hC0AC29B7;  
parameter C13 = 32'hC97C50DD; 
parameter C14 = 32'h3F84D5B5;  
parameter C15 = 32'hB5470917; 

wire [31:0] msg04_i, msg04_ip;
wire [31:0] msg15_i, msg15_ip;
wire [31:0] msg26_i, msg26_ip;
wire [31:0] msg37_i, msg37_ip;
wire [31:0] chain0, chain1, chain2, chain3, chain4, chain5, chain6, chain7;
wire [31:0] chain8, chain9, chain10, chain11, chain12, chain13, chain14, chain15;
wire [31:0] gf0_i, gf1_i, gf2_i, gf3_i, gf4_i, gf5_i, gf6_i, gf7_i;
wire [31:0] gf8_i, gf9_i, gf10_i, gf11_i, gf12_i, gf13_i, gf14_i, gf15_i;
wire [31:0] gf0_o, gf1_o, gf2_o, gf3_o, gf4_o, gf5_o, gf6_o, gf7_o;
wire [31:0] gf8_o, gf9_o, gf10_o, gf11_o, gf12_o, gf13_o, gf14_o, gf15_o;
wire [ 3:0] round_w;
reg  [31:0] state0, state1, state2, state3;
reg  [31:0] state4, state5, state6, state7; 
reg  [31:0] state8, state9, state10, state11;
reg  [31:0] state12, state13, state14, state15;
reg  [31:0] msg0, msg1, msg2, msg3, msg4, msg5, msg6, msg7;
reg  [31:0] msg8, msg9, msg10, msg11, msg12, msg13, msg14, msg15;
reg  [ 4:0] round;
reg         EN;
reg  [31:0] sigma0, sigma1, sigma2, sigma3, sigma4, sigma5, sigma6, sigma7;
reg  [31:0] sigma8, sigma9, sigma10, sigma11, sigma12, sigma13, sigma14, sigma15;

assign busy = (start | EN)? 1:0;

reg init_r;
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) init_r <= 0;
   else init_r <= init;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) EN <= 0;
   else if (start) EN <= 1;
   else if (round == 5'h14) EN <= 0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) round <= 0;
   else if (EN) begin
      if (round == 5'h14) round <= 0;
      else round <= round + 1;
   end
   else round <= round;
end

assign round_w = round[4:1];

always @(round_w or sigma0 or sigma1 or sigma2 or sigma3 or sigma4 or sigma5 or sigma6 or sigma7 or sigma8 or sigma9 or sigma10 or sigma11 or sigma12 or sigma13 or sigma14 or sigma15 or msg0 or msg1 or msg2 or msg3 or msg4 or msg5 or msg6 or msg7 or msg8 or msg9 or msg10 or msg11 or msg12 or msg13 or msg14 or msg15) begin
   case(round_w)
      4'h0  :  begin
         sigma0  = msg14 ^ C15 ^ C10;         
         sigma1  = msg10 ^ C11 ^ C14;         
         sigma2  = msg4  ^ C5  ^ C8 ;          
         sigma3  = msg8  ^ C9  ^ C4 ;
         sigma4  = msg9  ^ C8  ^ C15;
         sigma5  = msg15 ^ C14 ^ C9 ;
         sigma6  = msg13 ^ C12 ^ C6 ;
         sigma7  = msg6  ^ C7  ^ C13;
         sigma8  = msg1  ^ C0  ^ C12;
         sigma9  = msg12 ^ C13 ^ C1 ;
         sigma10 = msg0  ^ C1  ^ C2 ;
         sigma11 = msg2  ^ C3  ^ C0 ;
         sigma12 = msg11 ^ C10 ^ C7 ;
         sigma13 = msg7  ^ C6  ^ C11;
         sigma14 = msg5  ^ C4  ^ C3 ;
         sigma15 = msg3  ^ C2  ^ C5 ;
      end                    
                             
      4'h1  :  begin         
         sigma0  = msg12 ^ C7  ^ C8 ;
         sigma1  = msg3  ^ C4  ^ C11;
         sigma2  = msg9  ^ C1  ^ C0 ;
         sigma3  = msg10 ^ C2  ^ C12; 
         sigma4  = msg14 ^ C3  ^ C2 ;
         sigma5  = msg11 ^ C0  ^ C5 ;
         sigma6  = msg5  ^ C9  ^ C13;
         sigma7  = msg6  ^ C6  ^ C15;
         sigma8  = msg1  ^ C14 ^ C14;
         sigma9  = msg0  ^ C10 ^ C10;
         sigma10 = msg15 ^ C5  ^ C6 ;
         sigma11 = msg7  ^ C13 ^ C3 ;
         sigma12 = msg13 ^ C11 ^ C1 ;
         sigma13 = msg8  ^ C12 ^ C7 ;
         sigma14 = msg4  ^ C15 ^ C4 ;
         sigma15 = msg2  ^ C8  ^ C9 ;
      end                       
                                 
      4'h2  :  begin          
         sigma0  = msg12 ^ C1  ^ C9 ;
         sigma1  = msg14 ^ C4  ^ C7 ;
         sigma2  = msg10 ^ C6  ^ C1 ;
         sigma3  = msg13 ^ C7  ^ C3 ;
         sigma4  = msg7  ^ C15 ^ C12;
         sigma5  = msg2  ^ C0  ^ C13;
         sigma6  = msg0  ^ C8  ^ C14;
         sigma7  = msg9  ^ C10 ^ C11;
         sigma8  = msg5  ^ C5  ^ C6 ;
         sigma9  = msg11 ^ C3  ^ C2 ;
         sigma10 = msg4  ^ C2  ^ C10;
         sigma11 = msg8  ^ C14 ^ C5 ;
         sigma12 = msg15 ^ C9  ^ C0 ;
         sigma13 = msg3  ^ C12 ^ C4 ;
         sigma14 = msg6  ^ C13 ^ C8 ;
         sigma15 = msg1  ^ C11 ^ C15;
      end                        
                                 
      4'h3  :  begin          
         sigma0  = msg1  ^ C7  ^ C0 ;
         sigma1  = msg13 ^ C4  ^ C9 ;
         sigma2  = msg10 ^ C10 ^ C7 ;
         sigma3  = msg0  ^ C9  ^ C5 ;
         sigma4  = msg8  ^ C6  ^ C4 ;
         sigma5  = msg12 ^ C0  ^ C2 ;
         sigma6  = msg11 ^ C5  ^ C15;
         sigma7  = msg14 ^ C8  ^ C10;
         sigma8  = msg7  ^ C11 ^ C1 ;
         sigma9  = msg3  ^ C3  ^ C14;
         sigma10 = msg6  ^ C14 ^ C12;
         sigma11 = msg5  ^ C13 ^ C11;
         sigma12 = msg9  ^ C2  ^ C8 ;
         sigma13 = msg15 ^ C15 ^ C6 ;
         sigma14 = msg2  ^ C1  ^ C13;
         sigma15 = msg4  ^ C12 ^ C3 ;
      end                        
                                 
      4'h4  :  begin          
         sigma0  = msg4  ^ C4  ^ C12;
         sigma1  = msg11 ^ C11 ^ C2 ;
         sigma2  = msg12 ^ C8  ^ C10;
         sigma3  = msg6  ^ C15 ^ C6 ;
         sigma4  = msg1  ^ C9  ^ C11;
         sigma5  = msg10 ^ C12 ^ C0 ;
         sigma6  = msg13 ^ C6  ^ C3 ;
         sigma7  = msg14 ^ C13 ^ C8 ;
         sigma8  = msg5  ^ C2  ^ C13;
         sigma9  = msg15 ^ C3  ^ C4 ;
         sigma10 = msg3  ^ C5  ^ C5 ;
         sigma11 = msg2  ^ C7  ^ C7 ;
         sigma12 = msg7  ^ C10 ^ C14;
         sigma13 = msg8  ^ C1  ^ C15;
         sigma14 = msg9  ^ C14 ^ C9 ;
         sigma15 = msg0  ^ C0  ^ C1 ;
      end                        
                                 
      4'h5  :  begin          
         sigma0  = msg1  ^ C2  ^ C5 ;
         sigma1  = msg11 ^ C7  ^ C12;
         sigma2  = msg14 ^ C9  ^ C15;
         sigma3  = msg12 ^ C14 ^ C1 ;
         sigma4  = msg13 ^ C15 ^ C13;
         sigma5  = msg9  ^ C4  ^ C14;
         sigma6  = msg8  ^ C13 ^ C10;
         sigma7  = msg3  ^ C6  ^ C4 ;
         sigma8  = msg4  ^ C11 ^ C7 ;
         sigma9  = msg10 ^ C5  ^ C0 ;
         sigma10 = msg2  ^ C10 ^ C3 ;
         sigma11 = msg7  ^ C8  ^ C6 ;
         sigma12 = msg15 ^ C1  ^ C2 ;
         sigma13 = msg0  ^ C12 ^ C9 ;
         sigma14 = msg6  ^ C3  ^ C11;
         sigma15 = msg5  ^ C0  ^ C8 ;
      end                        
                                 
      4'h6  :  begin          
         sigma0  = msg5  ^ C14 ^ C11;
         sigma1  = msg15 ^ C8  ^ C13;
         sigma2  = msg9  ^ C0  ^ C14;
         sigma3  = msg4  ^ C13 ^ C7 ;
         sigma4  = msg0  ^ C5  ^ C1 ;
         sigma5  = msg2  ^ C15 ^ C12;
         sigma6  = msg11 ^ C6  ^ C9 ;
         sigma7  = msg12 ^ C2  ^ C3 ;
         sigma8  = msg1  ^ C12 ^ C0 ;
         sigma9  = msg8  ^ C7  ^ C5 ;
         sigma10 = msg3  ^ C1  ^ C4 ;
         sigma11 = msg6  ^ C10 ^ C15;
         sigma12 = msg14 ^ C11 ^ C6 ;
         sigma13 = msg10 ^ C3  ^ C8 ;
         sigma14 = msg13 ^ C9  ^ C10;
         sigma15 = msg7  ^ C4  ^ C2 ;
      end                        
                                 
      4'h7  :  begin          
         sigma0  = msg13 ^ C8  ^ C15;
         sigma1  = msg10 ^ C4  ^ C6 ;
         sigma2  = msg3  ^ C7  ^ C9 ;
         sigma3  = msg7  ^ C3  ^ C14;
         sigma4  = msg1  ^ C13 ^ C3 ;
         sigma5  = msg6  ^ C9  ^ C11;
         sigma6  = msg9  ^ C5  ^ C8 ;
         sigma7  = msg12 ^ C6  ^ C0 ;
         sigma8  = msg4  ^ C1  ^ C2 ;
         sigma9  = msg14 ^ C10 ^ C12;
         sigma10 = msg0  ^ C11 ^ C7 ;
         sigma11 = msg2  ^ C14 ^ C13;
         sigma12 = msg5  ^ C12 ^ C4 ;
         sigma13 = msg11 ^ C15 ^ C1 ;
         sigma14 = msg15 ^ C2  ^ C5 ;
         sigma15 = msg8  ^ C0  ^ C10;
      end                        
                                 
      4'h8  :  begin          
         sigma0  = msg14 ^ C5  ^ C2 ;
         sigma1  = msg9  ^ C12 ^ C10;
         sigma2  = msg7  ^ C0  ^ C4 ;
         sigma3  = msg13 ^ C1  ^ C8 ;
         sigma4  = msg11 ^ C13 ^ C6 ;
         sigma5  = msg0  ^ C15 ^ C7 ;
         sigma6  = msg12 ^ C4  ^ C5 ;
         sigma7  = msg15 ^ C10 ^ C1 ;
         sigma8  = msg1  ^ C6  ^ C11;
         sigma9  = msg4  ^ C3  ^ C15;
         sigma10 = msg3  ^ C14 ^ C14;
         sigma11 = msg2  ^ C9  ^ C9 ;
         sigma12 = msg5  ^ C11 ^ C12;
         sigma13 = msg8  ^ C2  ^ C3 ;
         sigma14 = msg10 ^ C7  ^ C0 ;
         sigma15 = msg6  ^ C8  ^ C13;
      end                    
                             
      default : begin        
         sigma0  = 0;     
         sigma1  = 0;     
         sigma2  = 0;     
         sigma3  = 0;     
         sigma4  = 0;     
         sigma5  = 0;     
         sigma6  = 0;     
         sigma7  = 0;     
         sigma8  = 0;     
         sigma9  = 0;     
         sigma10 = 0;     
         sigma11 = 0;     
         sigma12 = 0;     
         sigma13 = 0;     
         sigma14 = 0;     
         sigma15 = 0;     
      end
   endcase
end

assign gf0_i = state0;
assign gf1_i = (~round[0])? state4 : state5;
assign gf2_i = (~round[0])? state8 : state10;
assign gf3_i = (~round[0])? state12 : state15;

assign gf4_i = state1;
assign gf5_i = (~round[0])? state5 : state6;
assign gf6_i = (~round[0])? state9 : state11;
assign gf7_i = (~round[0])? state13 : state12;

assign gf8_i = state2;
assign gf9_i = (~round[0])? state6 : state7;
assign gf10_i = (~round[0])? state10 : state8;
assign gf11_i = (~round[0])? state14 : state13;

assign gf12_i = state3;
assign gf13_i = (~round[0])? state7 : state4;
assign gf14_i = (~round[0])? state11 : state9;
assign gf15_i = (~round[0])? state15 : state14;

assign msg04_i = (~round[0])? msg0 : msg8;
assign msg04_ip = (~round[0])? msg1 : msg9;

assign msg15_i = (~round[0])? msg2 : msg10;
assign msg15_ip = (~round[0])? msg3 : msg11;

assign msg26_i = (~round[0])? msg4 : msg12;
assign msg26_ip = (~round[0])? msg5 : msg13;

assign msg37_i = (~round[0])? msg6 : msg14;
assign msg37_ip = (~round[0])? msg7 : msg15;

assign chain0 = gf0_o;
assign chain1 = gf4_o;
assign chain2 = gf8_o;
assign chain3 = gf12_o;

assign chain4 = (~round[0])? gf1_o : gf13_o;
assign chain5 = (~round[0])? gf5_o : gf1_o;
assign chain6 = (~round[0])? gf9_o : gf5_o;
assign chain7 = (~round[0])? gf13_o : gf9_o;

assign chain8 = (~round[0])? gf2_o : gf10_o;
assign chain9 = (~round[0])? gf6_o : gf14_o;
assign chain10 = (~round[0])? gf10_o : gf2_o;
assign chain11 = (~round[0])? gf14_o : gf6_o;

assign chain12 = (~round[0])? gf3_o : gf7_o;
assign chain13 = (~round[0])? gf7_o : gf11_o;
assign chain14 = (~round[0])? gf11_o : gf15_o;
assign chain15 = (~round[0])? gf15_o : gf3_o;

BLAKE_G_FUNCTION blake_g04_function(
   .a(gf0_i), .b(gf1_i), .c(gf2_i), .d(gf3_i),
   .msg_i(msg04_i), .msg_ip(msg04_ip),
   .a_out(gf0_o), .b_out(gf1_o), .c_out(gf2_o), .d_out(gf3_o));

BLAKE_G_FUNCTION blake_g15_function(
   .a(gf4_i), .b(gf5_i), .c(gf6_i), .d(gf7_i),
   .msg_i(msg15_i), .msg_ip(msg15_ip),
   .a_out(gf4_o), .b_out(gf5_o), .c_out(gf6_o), .d_out(gf7_o));

BLAKE_G_FUNCTION blake_g26_function(
   .a(gf8_i), .b(gf9_i), .c(gf10_i), .d(gf11_i),
   .msg_i(msg26_i), .msg_ip(msg26_ip),
   .a_out(gf8_o), .b_out(gf9_o), .c_out(gf10_o), .d_out(gf11_o));

BLAKE_G_FUNCTION blake_g37_function(
   .a(gf12_i), .b(gf13_i), .c(gf14_i), .d(gf15_i),
   .msg_i(msg37_i), .msg_ip(msg37_ip),
   .a_out(gf12_o), .b_out(gf13_o), .c_out(gf14_o), .d_out(gf15_o));

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg0 <= 0;
   else if (Ld_EN) msg0 <= msg1;
   else if (start) msg0 <= msg0 ^ C1;
   else if (round[0]) msg0 <= sigma0;
   else msg0 <= msg0;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg1 <= 0;
   else if (Ld_EN) msg1 <= msg2;
   else if (start) msg1 <= msg1 ^ C0;
   else if (round[0]) msg1 <= sigma1;
   else msg1 <= msg1;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg2 <= 0;
   else if (Ld_EN) msg2 <= msg3;
   else if (start) msg2 <= msg2 ^ C3;
   else if (round[0]) msg2 <= sigma2;
   else msg2 <= msg2;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg3 <= 0;
   else if (Ld_EN) msg3 <= msg4;
   else if (start) msg3 <= msg3 ^ C2;
   else if (round[0]) msg3 <= sigma3;
   else msg3 <= msg3;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg4 <= 0;
   else if (Ld_EN) msg4 <= msg5;
   else if (start) msg4 <= msg4 ^ C5;
   else if (round[0]) msg4 <= sigma4;
   else msg4 <= msg4;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg5 <= 0;
   else if (Ld_EN) msg5 <= msg6;
   else if (start) msg5 <= msg5 ^ C4;
   else if (round[0]) msg5 <= sigma5;
   else msg5 <= msg5; 
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg6 <= 0;
   else if (Ld_EN) msg6 <= msg7;
   else if (start) msg6 <= msg6 ^ C7;
   else if (round[0]) msg6 <= sigma6;
   else msg6 <= msg6;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg7 <= 0;
   else if (Ld_EN) msg7 <= msg8;
   else if (start) msg7 <= msg7 ^ C6;
   else if (round[0]) msg7 <= sigma7;
   else msg7 <= msg7;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg8 <= 0;
   else if (Ld_EN) msg8 <= msg9;
   else if (start) msg8 <= msg8 ^ C9;
   else if (round[0]) msg8 <= sigma8;
   else msg8 <= msg8;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg9 <= 0;
   else if (Ld_EN) msg9 <= msg10;
   else if (start) msg9 <= msg9 ^ C8;
   else if (round[0]) msg9 <= sigma9;
   else msg9 <= msg9;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg10 <= 0;
   else if (Ld_EN) msg10 <= msg11;
   else if (start) msg10 <= msg10 ^ C11;
   else if (round[0]) msg10 <= sigma10;
   else msg10 <= msg10;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg11 <= 0;
   else if (Ld_EN) msg11 <= msg12;
   else if (start) msg11 <= msg11 ^ C10;
   else if (round[0]) msg11 <= sigma11;
   else msg11 <= msg11;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg12 <= 0;
   else if (Ld_EN) msg12 <= msg13;
   else if (start) msg12 <= msg12 ^ C13;
   else if (round[0]) msg12 <= sigma12;
   else msg12 <= msg12;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg13 <= 0;
   else if (Ld_EN) msg13 <= msg14;
   else if (start) msg13 <= msg13 ^ C12;
   else if (round[0]) msg13 <= sigma13;
   else msg13 <= msg13;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg14 <= 0;
   else if (Ld_EN) msg14 <= msg15;
   else if (start) msg14 <= msg14 ^ C15;
   else if (round[0]) msg14 <= sigma14;
   else msg14 <= msg14;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) msg15 <= 0;
   else if (Ld_EN) msg15 <= idata32;
   else if (start) msg15 <= msg15 ^ C14;
   else if (round[0]) msg15 <= sigma15;
   else msg15 <= msg15;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state0 <= 0;
   else if (start) state0 <= hash0;
   else if (EN) state0 <= chain0;
   else state0 <= state0;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state1 <= 0;
   else if (start) state1 <= hash1;
   else if (EN) state1 <= chain1;
   else state1 <= state1;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state2 <= 0;
   else if (start) state2 <= hash2;
   else if (EN) state2 <= chain2;
   else state2 <= state2;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state3 <= 0;
   else if (start) state3 <= hash3;
   else if (EN) state3 <= chain3;
   else state3 <= state3;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state4 <= 0;
   else if (start) state4 <= hash4;
   else if (EN) state4 <= chain4;
   else state4 <= state4;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state5 <= 0;
   else if (start) state5 <= hash5;
   else if (EN) state5 <= chain5;
   else state5 <= state5;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state6 <= 0;
   else if (start) state6 <= hash6;
   else if (EN) state6 <= chain6;
   else state6 <= state6;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state7 <= 0;
   else if (start) state7 <= hash7;
   else if (EN) state7 <= chain7;
   else state7 <= state7;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state8 <= 0;
   else if (start) state8 <= C0;
   else if (EN) state8 <= chain8;
   else state8 <= state8;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state9 <= 0;
   else if (start) state9 <= C1;
   else if (EN) state9 <= chain9;
   else state9 <= state9;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state10 <= 0;
   else if (start) state10 <= C2;
   else if (EN) state10 <= chain10;
   else state10 <= state10;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state11 <= 0;
   else if (start) state11 <= C3;
   else if (EN) state11 <= chain11;
   else state11 <= state11;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state12 <= 0;
   else if (start) state12 <= C4 ^ counter[63:32];
   else if (EN) state12 <= chain12;
   else state12 <= state12;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state13 <= 0;
   else if (start) state13 <= C5 ^ counter[63:32];
   else if (EN) state13 <= chain13;
   else state13 <= state13;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state14 <= 0;
   else if (start) state14 <= C6 ^ counter[31:0];
   else if (EN) state14 <= chain14;
   else state14 <= state14;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) state15 <= 0;
   else if (start) state15 <= C7 ^ counter[31:0];
   else if (EN) state15 <= chain15;
   else state15 <= state15;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash0 <= 0;
   else if (init_r) hash0 <= IV0;
   else if (round == 5'h14) hash0 <= hash0 ^ state0 ^ state8;
   else hash0 <= hash0;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash1 <= 0;
   else if (init_r) hash1 <= IV1;
   else if (round == 5'h14) hash1 <= hash1 ^ state1 ^ state9;
   else hash1 <= hash1;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash2 <= 0;
   else if (init_r) hash2 <= IV2;
   else if (round == 5'h14) hash2 <= hash2 ^ state2 ^ state10;
   else hash2 <= hash2;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash3 <= 0;
   else if (init_r) hash3 <= IV3;
   else if (round == 5'h14) hash3 <= hash3 ^ state3 ^ state11;
   else hash3 <= hash3;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash4 <= 0;
   else if (init_r) hash4 <= IV4;
   else if (round == 5'h14) hash4 <= hash4 ^ state4 ^ state12;
   else hash4 <= hash4;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash5 <= 0;
   else if (init_r) hash5 <= IV5;
   else if (round == 5'h14) hash5 <= hash5 ^ state5 ^ state13;
   else hash5 <= hash5;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash6 <= 0;
   else if (init_r) hash6 <= IV6;
   else if (round == 5'h14) hash6 <= hash6 ^ state6 ^ state14;
   else hash6 <= hash6;
end

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) hash7 <= 0;
   else if (init_r) hash7 <= IV7;
   else if (round == 5'h14) hash7 <= hash7 ^ state7 ^ state15;
   else hash7 <= hash7;
end

endmodule


