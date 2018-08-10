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
`timescale 1ns/1ns  

module SHA256_CORE_rev1(  
                       clk,	
                       rst_n,
                       EN,	 
                       init,
                       idata,
                       Hash0,
                       Hash1,
                       Hash2,
                       Hash3,
                       Hash4,
                       Hash5,
                       Hash6,
                       Hash7,
                       busy
                       );
input         clk;	
input         rst_n;
input         EN;	
input         init;
input  [31:0] idata;
output [31:0] Hash0;
output [31:0] Hash1;
output [31:0] Hash2;
output [31:0] Hash3;
output [31:0] Hash4;
output [31:0] Hash5;
output [31:0] Hash6;
output [31:0] Hash7;
output        busy;

reg  [31:0] Hash0_r;
reg  [31:0] Hash1_r;
reg  [31:0] Hash2_r;
reg  [31:0] Hash3_r;
reg  [31:0] Hash4_r;
reg  [31:0] Hash5_r;
reg  [31:0] Hash6_r;
reg  [31:0] Hash7_r;
reg         busy_r;	
reg  [31:0] a,b,c,e,f,g,r7,r8,r9,r10;
reg  [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14 ;
reg  [31:0] w16,w15;
reg  [ 7:0] round;	
wire [31:0] ch,sig0,sig1,maj,wire2,wire3,wire4;
wire [31:0] vs1,vc1,vc2,vs2,vc3,vs3,vs4,vc4,plus;
wire [31:0] wt,vc_w1,vs_w1,sig_w0,sig_w1,vs_w2,vc_w2; 
wire [31:0] k;
wire [ 5:0] addr;
wire        rd;

ROM    rom(.clk(clk), .K(    k), .RD(   rd), .addr(addr));   
CSA   CSA1(.X(   r7), .Y(  maj), .Z(  sig0), .VS(   vs1), .VC(  vc1));
CSA   CSA2(.X(  r10), .Y( sig1), .Z(    ch), .VS(   vs2), .VC(  vc2));
CSA   CSA3(.X(    k), .Y(   wt), .Z( wire4), .VS(   vs3), .VC(  vc3));
CSA   CSA4(.X(   r8), .Y(   ch), .Z(  sig1), .VS(   vs4), .VC(  vc4));
CSA CSA_w1(.X(   w0), .Y(   w9), .Z(sig_w0), .VS( vs_w1), .VC(vc_w1));
CSA CSA_w2(.X(vs_w1), .Y(vc_w1), .Z(sig_w1), .VS( vs_w2), .VC(vc_w2));

assign rd   = (init || EN) ? 1'b1 : 1'b0;  
assign addr = (init || (round > 'd63))? 'd0 : round[5:0] + 'd1;      

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n) 
	  round <= 0;
  else if (init) 
    round <= 0;
  else if (EN) begin
    if (round < 'd67) 
      round <= round + 1;
    else if (round == 'd67) 
      round <= 0;
    else 
      round <= round;
  end
  else 
    round <= round;
end

assign busy = (EN && ((round >= 'd15) && (round <= 'd66)))? 1:0; 

assign Hash0 = Hash0_r;
assign Hash1 = Hash1_r;
assign Hash2 = Hash2_r;
assign Hash3 = Hash3_r;
assign Hash4 = Hash4_r;
assign Hash5 = Hash5_r;
assign Hash6 = Hash6_r;
assign Hash7 = Hash7_r;

//Hash0
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash0_r <= 0;
   else begin
      if (init) Hash0_r <= 32'h6a09e667;                         
      else if (round == 67) Hash0_r <= a + Hash0_r;
      else Hash0_r <= Hash0_r;
   end
end

//Hash1
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash1_r <= 0;
   else begin
      if (init) Hash1_r <= 32'hbb67ae85;     
      else if (round == 66) Hash1_r <= a + Hash1_r;
      else Hash1_r <= Hash1_r;
   end
end

//Hash2
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash2_r <= 0;
   else begin
      if (init) Hash2_r <= 32'h3c6ef372;       
      else if (round == 65) Hash2_r <= a + Hash2_r;
      else Hash2_r <= Hash2_r;
   end
end

//Hash3
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash3_r <= 0;
   else begin
      if (init) Hash3_r <= 32'ha54ff53a;       
      else if (round == 64) Hash3_r <= a + Hash3_r;
      else Hash3_r <= Hash3_r;
   end
end

//Hash4
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash4_r <= 0;
   else begin
      if (init) Hash4_r <= 32'h510e527f;    
      else if (round == 66) Hash4_r <= e + Hash4_r;
      else Hash4_r <= Hash4_r;
   end
end

//Hash5
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash5_r <= 0;
   else begin
      if (init) Hash5_r <= 32'h9b05688c;    
      else if (round == 65) Hash5_r <= e + Hash5_r;
      else Hash5_r <= Hash5_r;
   end
end

//Hash6
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash6_r <= 0;
   else begin
      if (init) Hash6_r <= 32'h1f83d9ab;    
      else if (round == 64) Hash6_r <= e + Hash6_r;
      else Hash6_r <= Hash6_r;
   end
end

//Hash7
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) Hash7_r <= 0;
   else begin
      if (init) Hash7_r <= 32'h5be0cd19; 
      else if (round == 63) Hash7_r <= e + Hash7_r;
      else Hash7_r <= Hash7_r;
   end
end



//plus
assign plus = wire2 + r9;

//maj
assign maj = (a & b) ^ (a & c) ^ (b & c);

//ch
assign ch = (e & f) ^ (~e & g);

//sigma0
assign sig0 = {a[1:0],a[31:2]} ^ {a[12:0],a[31:13]} ^ {a[21:0],a[31:22]};

//sigma1
assign sig1 = {e[5:0],e[31:6]} ^ {e[10:0],e[31:11]} ^ {e[24:0],e[31:25]};

assign wire4 = (round == 'd0)? Hash7 : f;
assign wire3 = (round == 'd1)? Hash5 : e;
assign wire2 = (round == 'd1)? Hash3 : b;

//main logic FF
//a
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) a <= 0;
   else if (EN) begin
      if (round == 'd2) a <= Hash0;
      else if (round <= 67) a <= vs1 + vc1;
      else a <= a;
   end
   else a <= a;
end

//b
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) b <= 0; 
   else if (EN) begin
	   if (round == 'd1) b <= Hash2; 
      else if (round == 'd2) b <= Hash1;
	   else if (round <= 67) b <= a;
      else b <= b;
   end
   else b <= b;
end

//c
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) c <= 0;
   else if (EN) begin
      if (round <= 67) c <= b;
	   else c <= c;
   end
   else c <= c;
end

//e
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) e <= 0;
   else if (EN) begin
	   if (round == 'd1) e <= Hash4;
      else if (round <= 67) e <= vs2 + vc2;
      else e <= e;
   end
   else e <= e;
end

//f
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) f <= 0;
   else if (EN) begin
      if (round == 'd0) f <= Hash6;
      else if (round <= 67) f <= wire3;
      else f <= f;
   end
   else f <= f;
end

//g
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) g <= 0;
   else if (EN) begin
      if (round <= 67) g <= f;
      else g <= g;
   end
   else g <= g;
end

//r7
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) r7 <= 0;
   else if (EN) begin
      if (round <= 67) r7 <= vs4 + vc4;
	   else r7 <= r7;
   end
   else r7 <= r7;
end

//r8
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) r8 <= 0;
   else if (EN) begin
      if (round <= 67) r8 <= r9;
	   else r8 <= r8;
   end
   else r8 <= r8;
end

//r9
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) r9 <= 0;
   else if (EN) begin
      if (round <= 67) r9 <= vs3 + vc3;
      else r9 <= r9;
   end
   else r9 <= r9;
end

//r10
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) r10 <= 0;
   else if (EN) begin
      if (round <= 67) r10 <= plus;
      else r10 <= r10;
   end
   else r10 <= r10;
end

//w schedule
//w FF
//w0
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w0 <= 0;
   else begin
      if (init) w0 <= 0;
      else if (EN) w0 <= w1;
      else w0 <= w0;
   end
end

//w1
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w1 <= 0;
   else begin
      if (init) w1 <= 0;
      else if (EN) w1 <= w2;
      else w1 <= w1;
   end
end

//w2
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w2 <= 0;
   else begin
      if (init) w2 <= 0;
      else if (EN) w2 <= w3;
      else w2 <= w2;
   end
end

//w3
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w3 <= 0;
   else begin
      if (init) w3 <= 0;
      else if (EN) w3 <= w4;
      else w3 <= w3;
   end
end

//w4
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w4 <= 0;
   else begin
      if (init) w4 <= 0;
      else if (EN) w4 <= w5;
      else w4 <= w4;
   end
end

//w5
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w5 <= 0;
   else begin
      if (init) w5 <= 0;
      else if (EN) w5 <= w6;
      else w5 <= w5;
   end
end

//w6
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w6 <= 0;
   else begin
      if (init) w6 <= 0;
      else if (EN) w6 <= w7;
      else w6 <= w6;
   end
end

//w7
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) w7 <= 0;
   else begin
      if (init) w7 <= 0;
	   else if (EN) w7 <= w8;
	   else w7 <= w7;
   end
end

//w8
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w8 <= 0;
   else begin
      if (init) w8 <= 0;
      else if (EN) w8 <= w9;
      else w8 <= w8;
   end
end

//w9
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w9 <= 0;
   else begin
      if (init) w9 <= 0;
      else if (EN) w9 <= w10;
      else w9 <= w9;
   end
end

//w10
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w10 <= 0;
   else begin
      if (init) w10 <= 0;
      else if (EN) w10 <= w11;
      else w10 <= w10;
   end
end

//w11
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w11 <= 0;
   else begin
      if (init) w11 <= 0;
      else if (EN) w11 <= w12;
      else w11 <= w11;
   end
end

//w12
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w12 <= 0;
   else begin
      if (init) w12 <= 0;
      else if (EN) w12 <= w13;
      else w12 <= w12;
   end
end

//w13
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w13 <= 0;
   else begin
      if (init) w13 <= 0;
      else if (EN) w13 <= wt;
      else w13 <= w13;
   end
end

//w14
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w14 <= 0;
   else begin
      if (init) w14 <= 0;
      else if (EN) w14 <= w15 + w16;
      else w14 <= w14;
   end
end

//w15
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w15 <= 0;
   else begin
      if (init) w15 <= 0;
      else if (EN) w15 <= vs_w2; 
      else w15 <= w15;
   end
end

//w16
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) w16 <= 0;
   else begin
      if (init) w16 <= 0;
      else if (EN) w16 <= vc_w2; 
      else w16 <= w16; 
   end
end

//sig_w0
assign sig_w0 = {w1[6:0],w1[31:7]} ^ {w1[17:0],w1[31:18]} ^ {3'b000,w1[31:3]};

//sig_w1
assign sig_w1 = {wt[16:0],wt[31:17]} ^ {wt[18:0],wt[31:19]} ^ {10'b00_0000_0000,wt[31:10]};

assign wt = (round <= 15) ? idata : w14;

endmodule
