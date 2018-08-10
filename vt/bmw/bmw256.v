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

module bmw256_round(clk,
										rst_n,
										enable,
										finish,
										IV,
										indata,
										outdata,
										//for chipscope debug
										p2_msb,
										p2_lsb,
										p2_state
										);

input           clk;
input           rst_n;
input           enable;
output          finish;//after finish high for 1 clk, the results are ready.
input		[511:0]	IV;
input 	[511:0] indata;
output  [511:0] outdata;
wire		[511:0]	IV;
wire	 	[511:0] indata;
wire    [511:0] outdata;
//reg             finish;
genvar j,k,l,m,n;

//for f0
wire		[31:0]  H[0:15];
wire 		[31:0]  p[0:15];
wire	  [31:0] tp[0:15];
wire		[31:0] p2[0:31];
//for f1
//for f2
wire	[31:0] XL;
wire	[31:0] XH;
wire  [31:0] p2_00;
wire  [31:0] p2_01;
wire  [31:0] p2_02;
wire  [31:0] p2_03;
wire  [31:0] p2_04;
wire  [31:0] p2_05;
wire  [31:0] p2_06;
wire  [31:0] p2_07;
wire  [31:0] p2_08;
wire  [31:0] p2_09;
wire  [31:0] p2_10;
wire  [31:0] p2_11;
wire  [31:0] p2_12;
wire  [31:0] p2_13;
wire  [31:0] p2_14;
wire  [31:0] p2_15;
wire  [31:0] p2_16;
wire  [31:0] p2_17;
wire  [31:0] p2_18;
wire  [31:0] p2_19;
wire  [31:0] p2_20;
wire  [31:0] p2_21;
wire  [31:0] p2_22;
wire  [31:0] p2_23;
wire  [31:0] p2_24;
wire  [31:0] p2_25;
wire  [31:0] p2_26;
wire  [31:0] p2_27;
wire  [31:0] p2_28;
wire  [31:0] p2_29;
wire  [31:0] p2_30;
wire  [31:0] p2_31;

reg 	[31:0] p2_00_reg;
reg 	[31:0] p2_01_reg;
reg 	[31:0] p2_02_reg;
reg 	[31:0] p2_03_reg;
reg 	[31:0] p2_04_reg;
reg 	[31:0] p2_05_reg;
reg 	[31:0] p2_06_reg;
reg 	[31:0] p2_07_reg;
reg 	[31:0] p2_08_reg;
reg 	[31:0] p2_09_reg;
reg 	[31:0] p2_10_reg;
reg 	[31:0] p2_11_reg;
reg 	[31:0] p2_12_reg;
reg 	[31:0] p2_13_reg;
reg 	[31:0] p2_14_reg;
reg 	[31:0] p2_15_reg;
reg 	[31:0] p2_16_reg;
reg 	[31:0] p2_17_reg;
reg 	[31:0] p2_18_reg;
reg 	[31:0] p2_19_reg;
reg 	[31:0] p2_20_reg;
reg 	[31:0] p2_21_reg;
reg 	[31:0] p2_22_reg;
reg 	[31:0] p2_23_reg;
reg 	[31:0] p2_24_reg;
reg 	[31:0] p2_25_reg;
reg 	[31:0] p2_26_reg;
reg 	[31:0] p2_27_reg;
reg 	[31:0] p2_28_reg;
reg 	[31:0] p2_29_reg;
reg 	[31:0] p2_30_reg;
reg 	[31:0] p2_31_reg;

wire	[31:0] p2_00_final;
wire	[31:0] p2_01_final;
wire	[31:0] p2_02_final;
wire	[31:0] p2_03_final;
wire	[31:0] p2_04_final;
wire	[31:0] p2_05_final;
wire	[31:0] p2_06_final;
wire	[31:0] p2_07_final;
wire	[31:0] p2_08_final;
wire	[31:0] p2_09_final;
wire	[31:0] p2_10_final;
wire	[31:0] p2_11_final;
wire	[31:0] p2_12_final;
wire	[31:0] p2_13_final;
wire	[31:0] p2_14_final;
wire	[31:0] p2_15_final;

//for pipeline stages
reg   [ 2:0] c_state;
reg   [ 2:0] n_state;


//--------------------------------------------
//for chipscope debug
output [31:0] p2_msb;
output [31:0] p2_lsb;
output [ 4:0] p2_state;
wire   [31:0] p2_lsb;
wire   [31:0] p2_msb;
assign p2_state = c_state;
assign p2_msb   = 0;
assign p2_lsb   = 0;
//--------------------------------------------

assign outdata[( 0+1)*32-1: 0*32] = p2_00_final; 
assign outdata[( 1+1)*32-1: 1*32] = p2_01_final; 
assign outdata[( 2+1)*32-1: 2*32] = p2_02_final; 
assign outdata[( 3+1)*32-1: 3*32] = p2_03_final; 
assign outdata[( 4+1)*32-1: 4*32] = p2_04_final; 
assign outdata[( 5+1)*32-1: 5*32] = p2_05_final; 
assign outdata[( 6+1)*32-1: 6*32] = p2_06_final; 
assign outdata[( 7+1)*32-1: 7*32] = p2_07_final; 
assign outdata[( 8+1)*32-1: 8*32] = p2_08_final; 
assign outdata[( 9+1)*32-1: 9*32] = p2_09_final; 
assign outdata[(10+1)*32-1:10*32] = p2_10_final; 
assign outdata[(11+1)*32-1:11*32] = p2_11_final; 
assign outdata[(12+1)*32-1:12*32] = p2_12_final; 
assign outdata[(13+1)*32-1:13*32] = p2_13_final; 
assign outdata[(14+1)*32-1:14*32] = p2_14_final; 
assign outdata[(15+1)*32-1:15*32] = p2_15_final; 

generate
for(j=0;j<16;j=j+1) begin: init_H_P
	assign  H[j] = IV[(j+1)*32-1:j*32];
	assign  p[j] = indata[(j+1)*32-1:j*32];
 	assign tp[j] = p[j]^H[j];
end
endgenerate

//-- for f2 --
assign XL =      p2_16_reg^p2_17_reg^p2_18_reg^p2_19_reg^p2_20_reg^p2_21_reg^p2_22_reg^p2_23_reg;
assign XH = XL ^ p2_24    ^p2_25    ^p2_26    ^p2_27    ^p2_28    ^p2_29    ^p2_30    ^p2_31    ;                        

//-------------------------------------------------------
//fully unrolled 

//FSM for pipeline stages
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		c_state <= 0;      
	end
	else begin
		c_state <= n_state;   
	end
end

always @ (c_state, enable)
begin
	case (c_state)
		3'b000:
			begin
				if(enable) begin
					n_state = 3'b001;    
				end
				else begin
					n_state = 3'b000;
				end
			end
		
		3'b001:
			begin
				n_state = 3'b000;
			end	

		default:
			begin
				n_state = 3'b000;
			end
	
	endcase
end

assign finish = (c_state == 3'b001) ? 1 : 0;

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		p2_00_reg <= 0;
		p2_01_reg <= 0;
		p2_02_reg <= 0;
		p2_03_reg <= 0;
		p2_04_reg <= 0;
		p2_05_reg <= 0;
		p2_06_reg <= 0;
		p2_07_reg <= 0;
		p2_08_reg <= 0;
		p2_09_reg <= 0;
		p2_10_reg <= 0;
		p2_11_reg <= 0;
		p2_12_reg <= 0;
		p2_13_reg <= 0;
		p2_14_reg <= 0;
		p2_15_reg <= 0;
		p2_16_reg <= 0;
		p2_17_reg <= 0;
		p2_18_reg <= 0;
		p2_19_reg <= 0;
		p2_20_reg <= 0;
		p2_21_reg <= 0;
		p2_22_reg <= 0;
		p2_23_reg <= 0;
		p2_24_reg <= 0;
		p2_25_reg <= 0;
		p2_26_reg <= 0;
		p2_27_reg <= 0;
		p2_28_reg <= 0;
		p2_29_reg <= 0;
		p2_30_reg <= 0;
		p2_31_reg <= 0;
	end
	else if (c_state == 3'b000) begin
		p2_00_reg <= p2_00_reg;
		p2_01_reg <= p2_01_reg;
		p2_02_reg <= p2_02_reg;
		p2_03_reg <= p2_03_reg;
		p2_04_reg <= p2_04_reg;
		p2_05_reg <= p2_05_reg;
		p2_06_reg <= p2_06_reg;
		p2_07_reg <= p2_07_reg;
		p2_08_reg <= p2_08_reg;
		p2_09_reg <= p2_09_reg;
		p2_10_reg <= p2_10_reg;
		p2_11_reg <= p2_11_reg;
		p2_12_reg <= p2_12_reg;
		p2_13_reg <= p2_13_reg;
		p2_14_reg <= p2_14_reg;
		p2_15_reg <= p2_15_reg;
		p2_16_reg <= p2_16_reg;
		p2_17_reg <= p2_17_reg;
		p2_18_reg <= p2_18_reg;
		p2_19_reg <= p2_19_reg;
		p2_20_reg <= p2_20_reg;
		p2_21_reg <= p2_21_reg;
		p2_22_reg <= p2_22_reg;
		p2_23_reg <= p2_23_reg;
		p2_24_reg <= p2_24_reg;
		p2_25_reg <= p2_25_reg;
		p2_26_reg <= p2_26_reg;
		p2_27_reg <= p2_27_reg;
		p2_28_reg <= p2_28_reg;
		p2_29_reg <= p2_29_reg;
		p2_30_reg <= p2_30_reg;
		p2_31_reg <= p2_31_reg;
	end
	else if (c_state == 3'b001) begin 
		//-- f0 --
		p2_00_reg <= p2_00;
		p2_01_reg <= p2_01;
		p2_02_reg <= p2_02;
		p2_03_reg <= p2_03;
		p2_04_reg <= p2_04;
		p2_05_reg <= p2_05;
		p2_06_reg <= p2_06;
		p2_07_reg <= p2_07;
		p2_08_reg <= p2_08;
		p2_09_reg <= p2_09;
		p2_10_reg <= p2_10;
		p2_11_reg <= p2_11;
		p2_12_reg <= p2_12;
		p2_13_reg <= p2_13;
		p2_14_reg <= p2_14;
		p2_15_reg <= p2_15;
		//-- f1 first half --
		p2_16_reg <= p2_16;
		p2_17_reg <= p2_17;
		p2_18_reg <= p2_18;
		p2_19_reg <= p2_19;
		p2_20_reg <= p2_20;
		p2_21_reg <= p2_21;
		p2_22_reg <= p2_22;
		p2_23_reg <= p2_23;
		//keep value
		p2_24_reg <= p2_24_reg;
		p2_25_reg <= p2_25_reg;
		p2_26_reg <= p2_26_reg;
		p2_27_reg <= p2_27_reg;
		p2_28_reg <= p2_28_reg;
		p2_29_reg <= p2_29_reg;
		p2_30_reg <= p2_30_reg;
		p2_31_reg <= p2_31_reg;
	end
	else begin
		p2_00_reg <= p2_00_reg;
		p2_01_reg <= p2_01_reg;
		p2_02_reg <= p2_02_reg;
		p2_03_reg <= p2_03_reg;
		p2_04_reg <= p2_04_reg;
		p2_05_reg <= p2_05_reg;
		p2_06_reg <= p2_06_reg;
		p2_07_reg <= p2_07_reg;
		p2_08_reg <= p2_08_reg;
		p2_09_reg <= p2_09_reg;
		p2_10_reg <= p2_10_reg;
		p2_11_reg <= p2_11_reg;
		p2_12_reg <= p2_12_reg;
		p2_13_reg <= p2_13_reg;
		p2_14_reg <= p2_14_reg;
		p2_15_reg <= p2_15_reg;
		p2_16_reg <= p2_16_reg;
		p2_17_reg <= p2_17_reg;
		p2_18_reg <= p2_18_reg;
		p2_19_reg <= p2_19_reg;
		p2_20_reg <= p2_20_reg;
		p2_21_reg <= p2_21_reg;
		p2_22_reg <= p2_22_reg;
		p2_23_reg <= p2_23_reg;
		p2_24_reg <= p2_24_reg;
		p2_25_reg <= p2_25_reg;
		p2_26_reg <= p2_26_reg;
		p2_27_reg <= p2_27_reg;
		p2_28_reg <= p2_28_reg;
		p2_29_reg <= p2_29_reg;
		p2_30_reg <= p2_30_reg;
		p2_31_reg <= p2_31_reg;
	end
end

//-- f0 --

assign p2_00 = s_0( tp[ 5]-tp[ 7]+tp[10]+tp[13]+tp[14])+H[ 1];
assign p2_01 = s_1( tp[ 6]-tp[ 8]+tp[11]+tp[14]-tp[15])+H[ 2];
assign p2_02 = s_2( tp[ 0]+tp[ 7]+tp[ 9]-tp[12]+tp[15])+H[ 3];
assign p2_03 = s_3( tp[ 0]-tp[ 1]+tp[ 8]-tp[10]+tp[13])+H[ 4];
assign p2_04 = s_4( tp[ 1]+tp[ 2]+tp[ 9]-tp[11]-tp[14])+H[ 5];
assign p2_05 = s_0( tp[ 3]-tp[ 2]+tp[10]-tp[12]+tp[15])+H[ 6];
assign p2_06 = s_1( tp[ 4]-tp[ 0]-tp[ 3]-tp[11]+tp[13])+H[ 7];
assign p2_07 = s_2( tp[ 1]-tp[ 4]-tp[ 5]-tp[12]-tp[14])+H[ 8];
assign p2_08 = s_3( tp[ 2]-tp[ 5]-tp[ 6]+tp[13]-tp[15])+H[ 9];
assign p2_09 = s_4( tp[ 0]-tp[ 3]+tp[ 6]-tp[ 7]+tp[14])+H[10];
assign p2_10 = s_0( tp[ 8]-tp[ 1]-tp[ 4]-tp[ 7]+tp[15])+H[11];
assign p2_11 = s_1( tp[ 8]-tp[ 0]-tp[ 2]-tp[ 5]+tp[ 9])+H[12];
assign p2_12 = s_2( tp[ 1]+tp[ 3]-tp[ 6]-tp[ 9]+tp[10])+H[13];
assign p2_13 = s_3( tp[ 2]+tp[ 4]+tp[ 7]+tp[10]+tp[11])+H[14];
assign p2_14 = s_4( tp[ 3]-tp[ 5]+tp[ 8]-tp[11]-tp[12])+H[15];
assign p2_15 = s_0( tp[12]-tp[ 4]-tp[ 6]-tp[ 9]+tp[13])+H[ 0];

//-- f1 --
assign p2_16 = s_1(p2_00)+ s_2(p2_01)+s_3(p2_02)+s_0(p2_03)
 					   + s_1(p2_04)+ s_2(p2_05)+s_3(p2_06)+s_0(p2_07)
 					   + s_1(p2_08)+ s_2(p2_09)+s_3(p2_10)+s_0(p2_11)
 					   + s_1(p2_12)+ s_2(p2_13)+s_3(p2_14)+s_0(p2_15)
					   + (( 16*(32'h05555555) 
					   + rotl32(p[ 0],((16-16)%16) +1) 
					   + rotl32(p[ 3],((16-13)%16) +1) 
					   - rotl32(p[10],((16-6)%16)+1) ) 
					   ^ H[(16-16+7)%16]);

assign p2_17 = s_1(p2_01)+ s_2(p2_02)+s_3(p2_03)+s_0(p2_04)
					   + s_1(p2_05)+ s_2(p2_06)+s_3(p2_07)+s_0(p2_08)
					   + s_1(p2_09)+ s_2(p2_10)+s_3(p2_11)+s_0(p2_12)
					   + s_1(p2_13)+ s_2(p2_14)+s_3(p2_15)+s_0(p2_16) 
					   + (( 17*(32'h05555555) 
					   + rotl32(p[ 1],((17-16)%16) +1) 
					   + rotl32(p[ 4],((17-13)%16) +1) 
					   - rotl32(p[11],((17-6)%16)+1) ) 
					   ^ H[(17-16+7)%16]);

assign p2_18 = p2_02 + r_01(p2_03)+p2_04+r_02(p2_05)
 					   + p2_06 + r_03(p2_07)+p2_08+r_04(p2_09)
 					   + p2_10 + r_05(p2_11)+p2_12+r_06(p2_13)
 					   + p2_14 + r_07(p2_15)+s_4(p2_16)+s_5(p2_17)
 					   + (( 18*(32'h05555555) 
 					   + rotl32(p[ 2],((18-16)%16)+1) 
 					   + rotl32(p[ 5],((18-13)%16)+1) 
 					   - rotl32(p[12],((18- 6)%16)+1) ) 
 					   ^ H[(18-16+7)%16]);

assign p2_19 = p2_03 + r_01(p2_04)+p2_05+r_02(p2_06)
 					   + p2_07 + r_03(p2_08)+p2_09+r_04(p2_10)
 					   + p2_11 + r_05(p2_12)+p2_13+r_06(p2_14)
 					   + p2_15 + r_07(p2_16)+s_4(p2_17)+s_5(p2_18) 
 					   + (( 19*(32'h05555555) 
 					   + rotl32(p[ 3],((19-16)%16)+1) 
 					   + rotl32(p[ 6],((19-13)%16)+1) 
 					   - rotl32(p[13],((19- 6)%16)+1) ) 
 					   ^ H[(19-16+7)%16]);

assign p2_20 = p2_04 + r_01(p2_05)+p2_06+r_02(p2_07)
 					   + p2_08 + r_03(p2_09)+p2_10+r_04(p2_11)
 					   + p2_12 + r_05(p2_13)+p2_14+r_06(p2_15)
 					   + p2_16 + r_07(p2_17)+s_4(p2_18)+s_5(p2_19) 
 					   + (( 20*(32'h05555555) 
 					   + rotl32(p[ 4],((20-16)%16)+1) 
 					   + rotl32(p[ 7],((20-13)%16)+1) 
 					   - rotl32(p[14],((20- 6)%16)+1) ) 
 					   ^ H[(20-16+7)%16]);

assign p2_21 = p2_05 + r_01(p2_06)+p2_07+r_02(p2_08)
 					   + p2_09 + r_03(p2_10)+p2_11+r_04(p2_12)
 					   + p2_13 + r_05(p2_14)+p2_15+r_06(p2_16)
 					   + p2_17 + r_07(p2_18)+s_4(p2_19)+s_5(p2_20) 
 					   + (( 21*(32'h05555555) 
 					   + rotl32(p[ 5],((21-16)%16)+1) 
 					   + rotl32(p[ 8],((21-13)%16)+1) 
 					   - rotl32(p[15],((21- 6)%16)+1) ) 
 					   ^ H[(21-16+7)%16]);

assign p2_22 = p2_06 + r_01(p2_07)+p2_08+r_02(p2_09)
 					   + p2_10 + r_03(p2_11)+p2_12+r_04(p2_13)
 					   + p2_14 + r_05(p2_15)+p2_16+r_06(p2_17)
 					   + p2_18 + r_07(p2_19)+s_4(p2_20)+s_5(p2_21)
 					   + (( 22*(32'h05555555) 
 					   + rotl32(p[ 6],((22-16)%16)+1) 
 					   + rotl32(p[ 9],((22-13)%16)+1) 
 					   - rotl32(p[ 0],((22- 6)%16)+1) ) 
 					   ^ H[(22-16+7)%16]);

assign p2_23 = p2_07 + r_01(p2_08)+p2_09+r_02(p2_10)
 					   + p2_11 + r_03(p2_12)+p2_13+r_04(p2_14)
 					   + p2_15 + r_05(p2_16)+p2_17+r_06(p2_18)
 					   + p2_19 + r_07(p2_20)+s_4(p2_21)+s_5(p2_22) 
 					   + (( 23*(32'h05555555) 
 					   + rotl32(p[ 7],((23-16)%16)+1) 
 					   + rotl32(p[10],((23-13)%16)+1) 
 					   - rotl32(p[ 1],((23- 6)%16)+1) ) 
 					   ^ H[(23-16+7)%16]);

//insert pipeline here

assign p2_24 = p2_08_reg + r_01(p2_09_reg)+		 p2_10_reg +r_02(p2_11_reg)
 					   + p2_12_reg + r_03(p2_13_reg)+		 p2_14_reg +r_04(p2_15_reg)
 					   + p2_16_reg + r_05(p2_17_reg)+		 p2_18_reg +r_06(p2_19_reg)
 					   + p2_20_reg + r_07(p2_21_reg)+s_4(p2_22_reg)+ s_5(p2_23_reg) 
 					   + (( 24*(32'h05555555) 
 					   + rotl32(p[ 8],((24-16)%16)+1) 
 					   + rotl32(p[11],((24-13)%16)+1) 
 					   - rotl32(p[ 2],((24- 6)%16)+1) ) 
 					   ^ H[(24-16+7)%16]);

assign p2_25 = p2_09_reg + r_01(p2_10_reg)+    p2_11_reg +r_02(p2_12_reg)
 					   + p2_13_reg + r_03(p2_14_reg)+    p2_15_reg +r_04(p2_16_reg)
 					   + p2_17_reg + r_05(p2_18_reg)+    p2_19_reg +r_06(p2_20_reg)
 					   + p2_21_reg + r_07(p2_22_reg)+s_4(p2_23_reg)+ s_5(p2_24    )
 					   + (( 25*(32'h05555555) 
 					   + rotl32(p[ 9],((25-16)%16)+1) 
 					   + rotl32(p[12],((25-13)%16)+1) 
 					   - rotl32(p[ 3],((25- 6)%16)+1) ) 
 					   ^ H[(25-16+7)%16]);

assign p2_26 = p2_10_reg + r_01(p2_11_reg)+    p2_12_reg +r_02(p2_13_reg)
 					   + p2_14_reg + r_03(p2_15_reg)+    p2_16_reg +r_04(p2_17_reg)
 					   + p2_18_reg + r_05(p2_19_reg)+    p2_20_reg +r_06(p2_21_reg)
 					   + p2_22_reg + r_07(p2_23_reg)+s_4(p2_24    )+ s_5(p2_25    ) 
 					    + (( 26*(32'h05555555) 
 					    + rotl32(p[10],((26-16)%16)+1) 
 					    + rotl32(p[13],((26-13)%16)+1) 
 					    - rotl32(p[ 4],((26- 6)%16)+1) ) 
 					    ^ H[(26-16+7)%16]);

assign p2_27 = p2_11_reg + r_01(p2_12_reg)+    p2_13_reg +r_02(p2_14_reg)
 					   + p2_15_reg + r_03(p2_16_reg)+    p2_17_reg +r_04(p2_18_reg)
 					   + p2_19_reg + r_05(p2_20_reg)+    p2_21_reg +r_06(p2_22_reg)
 					   + p2_23_reg + r_07(p2_24    )+s_4(p2_25    )+ s_5(p2_26    ) 
 					   + (( 27*(32'h05555555) 
 					   + rotl32(p[11],((27-16)%16)+1) 
 					   + rotl32(p[14],((27-13)%16)+1) 
 					   - rotl32(p[ 5], ((27- 6)%16)+1) ) 
 					   ^ H[(27-16+7)%16]);

assign p2_28 = p2_12_reg + r_01(p2_13_reg)+    p2_14_reg +r_02(p2_15_reg)
 					   + p2_16_reg + r_03(p2_17_reg)+    p2_18_reg +r_04(p2_19_reg)
 					   + p2_20_reg + r_05(p2_21_reg)+    p2_22_reg +r_06(p2_23_reg)
 					   + p2_24     + r_07(p2_25    )+s_4(p2_26    )+ s_5(p2_27    ) 
 					   + (( 28*(32'h05555555) 
 					   + rotl32(p[12],((28-16)%16)+1) 
 					   + rotl32(p[15],((28-13)%16)+1) 
 					   - rotl32(p[ 6], ((28- 6)%16)+1) ) 
 					   ^ H[(28-16+7)%16]);

assign p2_29 = p2_13_reg + r_01(p2_14_reg)+    p2_15_reg +r_02(p2_16_reg)
 					   + p2_17_reg + r_03(p2_18_reg)+    p2_19_reg +r_04(p2_20_reg)
 					   + p2_21_reg + r_05(p2_22_reg)+    p2_23_reg +r_06(p2_24    )
 					   + p2_25     + r_07(p2_26    )+s_4(p2_27    )+ s_5(p2_28    )
 					   + (( 29*(32'h05555555) 
 					   + rotl32(p[13],((29-16)%16)+1) 
 					   + rotl32(p[ 0],((29-13)%16)+1) 
 					   - rotl32(p[ 7], ((29- 6)%16)+1) ) 
 					   ^ H[(29-16+7)%16]);

assign p2_30 = p2_14_reg + r_01(p2_15_reg)+    p2_16_reg +r_02(p2_17_reg)
 					   + p2_18_reg + r_03(p2_19_reg)+    p2_20_reg +r_04(p2_21_reg)
 					   + p2_22_reg + r_05(p2_23_reg)+    p2_24     +r_06(p2_25    )
 					   + p2_26     + r_07(p2_27    )+s_4(p2_28    )+ s_5(p2_29    )
 					   + (( 30*(32'h05555555) 
 					   + rotl32(p[14],((30-16)%16)+1) 
 					   + rotl32(p[ 1],((30-13)%16)+1) 
 					   - rotl32(p[ 8], ((30- 6)%16)+1) ) 
 					   ^ H[(30-16+7)%16]);

assign p2_31 = p2_15_reg + r_01(p2_16_reg)+    p2_17_reg +r_02(p2_18_reg)
 					   + p2_19_reg + r_03(p2_20_reg)+    p2_21_reg +r_04(p2_22_reg)
 					   + p2_23_reg + r_05(p2_24    )+    p2_25     +r_06(p2_26    )
 					   + p2_27     + r_07(p2_28    )+s_4(p2_29    )+ s_5(p2_30    )
 					   + (( 31*(32'h05555555) 
 					   + rotl32(p[15],((31-16)%16)+1) 
 					   + rotl32(p[ 2],((31-13)%16)+1) 
 					   - rotl32(p[ 9], ((31- 6)%16)+1) ) 
 					   ^ H[(31-16+7)%16]);
     
//-f2 --
assign	p2_00_final = (shl32(XH, 5) ^ shr32(p2_16_reg,5) ^ p[ 0]) + (XL ^ p2_24     ^ p2_00_reg);//f2-parallel-0
assign	p2_01_final = (shr32(XH, 7) ^ shl32(p2_17_reg,8) ^ p[ 1]) + (XL ^ p2_25     ^ p2_01_reg);//f2-parallel-0
assign	p2_02_final = (shr32(XH, 5) ^ shl32(p2_18_reg,5) ^ p[ 2]) + (XL ^ p2_26     ^ p2_02_reg);//f2-parallel-0
assign	p2_03_final = (shr32(XH, 1) ^ shl32(p2_19_reg,5) ^ p[ 3]) + (XL ^ p2_27     ^ p2_03_reg);//f2-parallel-0
assign	p2_04_final = (shr32(XH, 3) ^       p2_20_reg    ^ p[ 4]) + (XL ^ p2_28     ^ p2_04_reg);//f2-parallel-0
assign	p2_05_final = (shl32(XH, 6) ^ shr32(p2_21_reg,6) ^ p[ 5]) + (XL ^ p2_29     ^ p2_05_reg);//f2-parallel-0
assign	p2_06_final = (shr32(XH, 4) ^ shl32(p2_22_reg,6) ^ p[ 6]) + (XL ^ p2_30     ^ p2_06_reg);//f2-parallel-0
assign	p2_07_final = (shr32(XH,11) ^ shl32(p2_23_reg,2) ^ p[ 7]) + (XL ^ p2_31     ^ p2_07_reg);//f2-parallel-0

assign	p2_08_final = rotl32(p2_04_final, 9) + (XH ^ p2_24     ^ p[ 8]) + (shl32(XL,8) ^ p2_23_reg ^ p2_08_reg);//f2-parallel-1
assign	p2_09_final = rotl32(p2_05_final,10) + (XH ^ p2_25     ^ p[ 9]) + (shr32(XL,6) ^ p2_16_reg ^ p2_09_reg);//f2-parallel-1
assign	p2_10_final = rotl32(p2_06_final,11) + (XH ^ p2_26     ^ p[10]) + (shl32(XL,6) ^ p2_17_reg ^ p2_10_reg);//f2-parallel-1
assign	p2_11_final = rotl32(p2_07_final,12) + (XH ^ p2_27     ^ p[11]) + (shl32(XL,4) ^ p2_18_reg ^ p2_11_reg);//f2-parallel-1
assign	p2_12_final = rotl32(p2_00_final,13) + (XH ^ p2_28     ^ p[12]) + (shr32(XL,3) ^ p2_19_reg ^ p2_12_reg);//f2-parallel-1
assign	p2_13_final = rotl32(p2_01_final,14) + (XH ^ p2_29     ^ p[13]) + (shr32(XL,4) ^ p2_20_reg ^ p2_13_reg);//f2-parallel-1
assign	p2_14_final = rotl32(p2_02_final,15) + (XH ^ p2_30     ^ p[14]) + (shr32(XL,7) ^ p2_21_reg ^ p2_14_reg);//f2-parallel-1
assign	p2_15_final = rotl32(p2_03_final,16) + (XH ^ p2_31     ^ p[15]) + (shr32(XL,2) ^ p2_22_reg ^ p2_15_reg);//f2-parallel-1

//-------------------------------------
//reuse logic functions
//#define rotl32(x,n)   (((x) << (n)) | ((x) >> (32 - (n))))
	function [31:0] rotl32;
		input [31:0] x;
		input [ 4:0] n;//0<n<32
		begin
			rotl32 = ((x) << (n)) | ((x) >> (32 - (n)));
		end
	endfunction
	
//#define rotr32(x,n)   (((x) >> (n)) | ((x) << (32 - (n))))
	function [31:0] rotr32;
		input [31:0] x;
		input [ 4:0] n;//0<n<32
		begin
			rotr32 = ((x) >> (n)) | ((x) << (32 - (n)));
		end
	endfunction
	
//#define shl32(x,n)   ((x) << (n))
	function [31:0] shl32;
		input [31:0] x;
		input [ 4:0] n;//0<n<32
		begin
			shl32 = (x) << (n);
		end
	endfunction
	
//#define shr32(x,n)   ((x) >> (n))
	function [31:0] shr32;
		input [31:0] x;
		input [ 4:0] n;//0<n<32
		begin
			shr32 = (x) >> (n);
		end
	endfunction
	
//#define s_0(x)  (((x)>> 1) ^ ((x)<<  3) ^ rotl32((x),  4) ^ rotl32((x), 19))
	function [31:0] s_0;
		input [31:0] x;
		begin
			s_0 = ((x)>> 1) ^ ((x)<<  3) ^ rotl32((x),  4) ^ rotl32((x), 19);
		end
	endfunction
	
//#define s_1(x)  (((x)>> 1) ^ ((x)<<  2) ^ rotl32((x),  8) ^ rotl32((x), 23))
	function [31:0] s_1;
		input [31:0] x;
		begin
			s_1 = ((x)>> 1) ^ ((x)<<  2) ^ rotl32((x),  8) ^ rotl32((x), 23);
		end
	endfunction
	
//#define s_2(x)  (((x)>> 2) ^ ((x)<<  1) ^ rotl32((x), 12) ^ rotl32((x), 25))
	function [31:0] s_2;
		input [31:0] x;
		begin
			s_2 = ((x)>> 2) ^ ((x)<<  1) ^ rotl32((x), 12) ^ rotl32((x), 25);
		end
	endfunction
	
//#define s_3(x)  (((x)>> 2) ^ ((x)<<  2) ^ rotl32((x), 15) ^ rotl32((x), 29))
	function [31:0] s_3;
		input [31:0] x;
		begin
			s_3 = ((x)>> 2) ^ ((x)<<  2) ^ rotl32((x), 15) ^ rotl32((x), 29);
		end
	endfunction
	
//#define s_4(x)  (((x)>> 1) ^ (x))
	function [31:0] s_4;
		input [31:0] x;
		begin
			s_4 = ((x)>> 1) ^ (x);
		end
	endfunction
	
//#define s_5(x)  (((x)>> 2) ^ (x))
	function [31:0] s_5;
		input [31:0] x;
		begin
			s_5 = ((x)>> 2) ^ (x);
		end
	endfunction
	
//#define r_01(x) rotl32((x),  3)
	function [31:0] r_01;
		input [31:0] x;
		begin
			r_01 = rotl32((x),  3);
		end
	endfunction

//#define r_02(x) rotl32((x),  7)
	function [31:0] r_02;
		input [31:0] x;
		begin
			r_02 = rotl32((x),  7);
		end
	endfunction

//#define r_03(x) rotl32((x), 13)
	function [31:0] r_03;
		input [31:0] x;
		begin
			r_03 = rotl32((x),  13);
		end
	endfunction

//#define r_04(x) rotl32((x), 16)
	function [31:0] r_04;
		input [31:0] x;
		begin
			r_04 = rotl32((x),  16);
		end
	endfunction

//#define r_05(x) rotl32((x), 19)
	function [31:0] r_05;
		input [31:0] x;
		begin
			r_05 = rotl32((x),  19);
		end
	endfunction

//#define r_06(x) rotl32((x), 23)
	function [31:0] r_06;
		input [31:0] x;
		begin
			r_06 = rotl32((x),  23);
		end
	endfunction

//#define r_07(x) rotl32((x), 27)
	function [31:0] r_07;
		input [31:0] x;
		begin
			r_07 = rotl32((x),  27);
		end
	endfunction


endmodule

