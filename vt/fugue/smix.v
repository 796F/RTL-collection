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

module fugue256_smix(
										Base,
										state_d_long,
										//output
										SMIX
										);
input  [  4:0] Base;	       
input  [959:0] state_d_long;
output [959:0] SMIX;

wire [ 31:0] SMIX_array_b0[0:29];
wire [ 31:0] SMIX_array_b1[0:29];
wire [ 31:0] SMIX_array_b2[0:29];
wire [ 31:0] SMIX_array_b3[0:29];
wire [ 31:0] state_d_array_b0[0:29];
wire [ 31:0] state_d_array_b1[0:29];
wire [ 31:0] state_d_array_b2[0:29];
wire [ 31:0] state_d_array_b3[0:29];
wire [ 31:0] state_d_array[0:29];          
wire [ 31:0] U0 [3:0];
wire [ 31:0] U1 [3:0];
wire [ 31:0] U2 [3:0];
wire [ 31:0] U3 [3:0];
wire [ 31:0] W0 [3:0];
wire [ 31:0] W1 [3:0];
wire [ 31:0] W2 [3:0];
wire [ 31:0] W3 [3:0];
wire [ 31:0] st0_d;//each d has 4-bytes, b3_b2_b1_b0
wire [ 31:0] st1_d;
wire [ 31:0] st2_d;
wire [ 31:0] st3_d;

wire [ 31:0] SMIX_array_b0_00[0:29], SMIX_array_b1_00[0:29], SMIX_array_b2_00[0:29], SMIX_array_b3_00[0:29];
wire [ 31:0] SMIX_array_b0_01[0:29], SMIX_array_b1_01[0:29], SMIX_array_b2_01[0:29], SMIX_array_b3_01[0:29];
wire [ 31:0] SMIX_array_b0_02[0:29], SMIX_array_b1_02[0:29], SMIX_array_b2_02[0:29], SMIX_array_b3_02[0:29];
wire [ 31:0] SMIX_array_b0_03[0:29], SMIX_array_b1_03[0:29], SMIX_array_b2_03[0:29], SMIX_array_b3_03[0:29];
wire [ 31:0] SMIX_array_b0_04[0:29], SMIX_array_b1_04[0:29], SMIX_array_b2_04[0:29], SMIX_array_b3_04[0:29];
wire [ 31:0] SMIX_array_b0_05[0:29], SMIX_array_b1_05[0:29], SMIX_array_b2_05[0:29], SMIX_array_b3_05[0:29];
wire [ 31:0] SMIX_array_b0_06[0:29], SMIX_array_b1_06[0:29], SMIX_array_b2_06[0:29], SMIX_array_b3_06[0:29];
wire [ 31:0] SMIX_array_b0_07[0:29], SMIX_array_b1_07[0:29], SMIX_array_b2_07[0:29], SMIX_array_b3_07[0:29];
wire [ 31:0] SMIX_array_b0_08[0:29], SMIX_array_b1_08[0:29], SMIX_array_b2_08[0:29], SMIX_array_b3_08[0:29];
wire [ 31:0] SMIX_array_b0_09[0:29], SMIX_array_b1_09[0:29], SMIX_array_b2_09[0:29], SMIX_array_b3_09[0:29];
wire [ 31:0] SMIX_array_b0_10[0:29], SMIX_array_b1_10[0:29], SMIX_array_b2_10[0:29], SMIX_array_b3_10[0:29];
wire [ 31:0] SMIX_array_b0_11[0:29], SMIX_array_b1_11[0:29], SMIX_array_b2_11[0:29], SMIX_array_b3_11[0:29];
wire [ 31:0] SMIX_array_b0_12[0:29], SMIX_array_b1_12[0:29], SMIX_array_b2_12[0:29], SMIX_array_b3_12[0:29];
wire [ 31:0] SMIX_array_b0_13[0:29], SMIX_array_b1_13[0:29], SMIX_array_b2_13[0:29], SMIX_array_b3_13[0:29];
wire [ 31:0] SMIX_array_b0_14[0:29], SMIX_array_b1_14[0:29], SMIX_array_b2_14[0:29], SMIX_array_b3_14[0:29];
wire [ 31:0] SMIX_array_b0_15[0:29], SMIX_array_b1_15[0:29], SMIX_array_b2_15[0:29], SMIX_array_b3_15[0:29];
wire [ 31:0] SMIX_array_b0_16[0:29], SMIX_array_b1_16[0:29], SMIX_array_b2_16[0:29], SMIX_array_b3_16[0:29];
wire [ 31:0] SMIX_array_b0_17[0:29], SMIX_array_b1_17[0:29], SMIX_array_b2_17[0:29], SMIX_array_b3_17[0:29];
wire [ 31:0] SMIX_array_b0_18[0:29], SMIX_array_b1_18[0:29], SMIX_array_b2_18[0:29], SMIX_array_b3_18[0:29];
wire [ 31:0] SMIX_array_b0_19[0:29], SMIX_array_b1_19[0:29], SMIX_array_b2_19[0:29], SMIX_array_b3_19[0:29];
wire [ 31:0] SMIX_array_b0_20[0:29], SMIX_array_b1_20[0:29], SMIX_array_b2_20[0:29], SMIX_array_b3_20[0:29];
wire [ 31:0] SMIX_array_b0_21[0:29], SMIX_array_b1_21[0:29], SMIX_array_b2_21[0:29], SMIX_array_b3_21[0:29];
wire [ 31:0] SMIX_array_b0_22[0:29], SMIX_array_b1_22[0:29], SMIX_array_b2_22[0:29], SMIX_array_b3_22[0:29];
wire [ 31:0] SMIX_array_b0_23[0:29], SMIX_array_b1_23[0:29], SMIX_array_b2_23[0:29], SMIX_array_b3_23[0:29];
wire [ 31:0] SMIX_array_b0_24[0:29], SMIX_array_b1_24[0:29], SMIX_array_b2_24[0:29], SMIX_array_b3_24[0:29];
wire [ 31:0] SMIX_array_b0_25[0:29], SMIX_array_b1_25[0:29], SMIX_array_b2_25[0:29], SMIX_array_b3_25[0:29];
wire [ 31:0] SMIX_array_b0_26[0:29], SMIX_array_b1_26[0:29], SMIX_array_b2_26[0:29], SMIX_array_b3_26[0:29];
wire [ 31:0] SMIX_array_b0_27[0:29], SMIX_array_b1_27[0:29], SMIX_array_b2_27[0:29], SMIX_array_b3_27[0:29];
wire [ 31:0] SMIX_array_b0_28[0:29], SMIX_array_b1_28[0:29], SMIX_array_b2_28[0:29], SMIX_array_b3_28[0:29];
wire [ 31:0] SMIX_array_b0_29[0:29], SMIX_array_b1_29[0:29], SMIX_array_b2_29[0:29], SMIX_array_b3_29[0:29];

wire [959:0] SMIX_00;
wire [959:0] SMIX_01;
wire [959:0] SMIX_02;
wire [959:0] SMIX_03;
wire [959:0] SMIX_04;
wire [959:0] SMIX_05;
wire [959:0] SMIX_06;
wire [959:0] SMIX_07;
wire [959:0] SMIX_08;
wire [959:0] SMIX_09;
wire [959:0] SMIX_10;
wire [959:0] SMIX_11;
wire [959:0] SMIX_12;
wire [959:0] SMIX_13;
wire [959:0] SMIX_14;
wire [959:0] SMIX_15;
wire [959:0] SMIX_16;
wire [959:0] SMIX_17;
wire [959:0] SMIX_18;
wire [959:0] SMIX_19;
wire [959:0] SMIX_20;
wire [959:0] SMIX_21;
wire [959:0] SMIX_22;
wire [959:0] SMIX_23;
wire [959:0] SMIX_24;
wire [959:0] SMIX_25;
wire [959:0] SMIX_26;
wire [959:0] SMIX_27;
wire [959:0] SMIX_28;
wire [959:0] SMIX_29;

genvar i;

generate
	for (i=0;i<30;i=i+1) begin: gen_State_in
		assign state_d_array[i]    = state_d_long[(i+1)*32-1:i*32];
		assign state_d_array_b0[i] = state_d_long[(i*4  +1)* 8-1:(i*4  )*8];
		assign state_d_array_b1[i] = state_d_long[(i*4+1+1)* 8-1:(i*4+1)*8];
		assign state_d_array_b2[i] = state_d_long[(i*4+2+1)* 8-1:(i*4+2)*8];
		assign state_d_array_b3[i] = state_d_long[(i*4+3+1)* 8-1:(i*4+3)*8];
	end
endgenerate

generate 
		for (i=0;i<30;i=i+1) begin: gen_SMIX_out
			assign SMIX[(i*4  +1)*8-1:(i*4  )*8] = (Base ==  0)? SMIX_array_b0_00[i] :
			 																			 (Base ==  1)? SMIX_array_b0_01[i] :
			 																			 (Base ==  2)? SMIX_array_b0_02[i] :
			 																			 (Base ==  3)? SMIX_array_b0_03[i] :
			 																			 (Base ==  4)? SMIX_array_b0_04[i] :
			 																			 (Base ==  5)? SMIX_array_b0_05[i] :
			 																			 (Base ==  6)? SMIX_array_b0_06[i] :
			 																			 (Base ==  7)? SMIX_array_b0_07[i] :
			 																			 (Base ==  8)? SMIX_array_b0_08[i] :
			 																			 (Base ==  9)? SMIX_array_b0_09[i] :
			 																			 (Base == 10)? SMIX_array_b0_10[i] :
			 																			 (Base == 11)? SMIX_array_b0_11[i] :
			 																			 (Base == 12)? SMIX_array_b0_12[i] :
			 																			 (Base == 13)? SMIX_array_b0_13[i] :
			 																			 (Base == 14)? SMIX_array_b0_14[i] :
			 																			 (Base == 15)? SMIX_array_b0_15[i] :
			 																			 (Base == 16)? SMIX_array_b0_16[i] :
			 																			 (Base == 17)? SMIX_array_b0_17[i] :
			 																			 (Base == 18)? SMIX_array_b0_18[i] :
			 																			 (Base == 19)? SMIX_array_b0_19[i] :
			 																			 (Base == 20)? SMIX_array_b0_20[i] :
			 																			 (Base == 21)? SMIX_array_b0_21[i] :
			 																			 (Base == 22)? SMIX_array_b0_22[i] :
			 																			 (Base == 23)? SMIX_array_b0_23[i] :
			 																			 (Base == 24)? SMIX_array_b0_24[i] :
			 																			 (Base == 25)? SMIX_array_b0_25[i] :
			 																			 (Base == 26)? SMIX_array_b0_26[i] :
			 																			 (Base == 27)? SMIX_array_b0_27[i] :
			 																			 (Base == 28)? SMIX_array_b0_28[i] : SMIX_array_b0_29[i];//(Base == 29)

			assign SMIX[(i*4+1+1)*8-1:(i*4+1)*8] = (Base ==  0)? SMIX_array_b1_00[i] :
			 																			 (Base ==  1)? SMIX_array_b1_01[i] :
			 																			 (Base ==  2)? SMIX_array_b1_02[i] :
			 																			 (Base ==  3)? SMIX_array_b1_03[i] :
			 																			 (Base ==  4)? SMIX_array_b1_04[i] :
			 																			 (Base ==  5)? SMIX_array_b1_05[i] :
			 																			 (Base ==  6)? SMIX_array_b1_06[i] :
			 																			 (Base ==  7)? SMIX_array_b1_07[i] :
			 																			 (Base ==  8)? SMIX_array_b1_08[i] :
			 																			 (Base ==  9)? SMIX_array_b1_09[i] :
			 																			 (Base == 10)? SMIX_array_b1_10[i] :
			 																			 (Base == 11)? SMIX_array_b1_11[i] :
			 																			 (Base == 12)? SMIX_array_b1_12[i] :
			 																			 (Base == 13)? SMIX_array_b1_13[i] :
			 																			 (Base == 14)? SMIX_array_b1_14[i] :
			 																			 (Base == 15)? SMIX_array_b1_15[i] :
			 																			 (Base == 16)? SMIX_array_b1_16[i] :
			 																			 (Base == 17)? SMIX_array_b1_17[i] :
			 																			 (Base == 18)? SMIX_array_b1_18[i] :
			 																			 (Base == 19)? SMIX_array_b1_19[i] :
			 																			 (Base == 20)? SMIX_array_b1_20[i] :
			 																			 (Base == 21)? SMIX_array_b1_21[i] :
			 																			 (Base == 22)? SMIX_array_b1_22[i] :
			 																			 (Base == 23)? SMIX_array_b1_23[i] :
			 																			 (Base == 24)? SMIX_array_b1_24[i] :
			 																			 (Base == 25)? SMIX_array_b1_25[i] :
			 																			 (Base == 26)? SMIX_array_b1_26[i] :
			 																			 (Base == 27)? SMIX_array_b1_27[i] :
			 																			 (Base == 28)? SMIX_array_b1_28[i] : SMIX_array_b1_29[i];//(Base == 29)
			
			assign SMIX[(i*4+2+1)*8-1:(i*4+2)*8] = (Base ==  0)? SMIX_array_b2_00[i] :
			 																			 (Base ==  1)? SMIX_array_b2_01[i] :
			 																			 (Base ==  2)? SMIX_array_b2_02[i] :
			 																			 (Base ==  3)? SMIX_array_b2_03[i] :
			 																			 (Base ==  4)? SMIX_array_b2_04[i] :
			 																			 (Base ==  5)? SMIX_array_b2_05[i] :
			 																			 (Base ==  6)? SMIX_array_b2_06[i] :
			 																			 (Base ==  7)? SMIX_array_b2_07[i] :
			 																			 (Base ==  8)? SMIX_array_b2_08[i] :
			 																			 (Base ==  9)? SMIX_array_b2_09[i] :
			 																			 (Base == 10)? SMIX_array_b2_10[i] :
			 																			 (Base == 11)? SMIX_array_b2_11[i] :
			 																			 (Base == 12)? SMIX_array_b2_12[i] :
			 																			 (Base == 13)? SMIX_array_b2_13[i] :
			 																			 (Base == 14)? SMIX_array_b2_14[i] :
			 																			 (Base == 15)? SMIX_array_b2_15[i] :
			 																			 (Base == 16)? SMIX_array_b2_16[i] :
			 																			 (Base == 17)? SMIX_array_b2_17[i] :
			 																			 (Base == 18)? SMIX_array_b2_18[i] :
			 																			 (Base == 19)? SMIX_array_b2_19[i] :
			 																			 (Base == 20)? SMIX_array_b2_20[i] :
			 																			 (Base == 21)? SMIX_array_b2_21[i] :
			 																			 (Base == 22)? SMIX_array_b2_22[i] :
			 																			 (Base == 23)? SMIX_array_b2_23[i] :
			 																			 (Base == 24)? SMIX_array_b2_24[i] :
			 																			 (Base == 25)? SMIX_array_b2_25[i] :
			 																			 (Base == 26)? SMIX_array_b2_26[i] :
			 																			 (Base == 27)? SMIX_array_b2_27[i] :
			 																			 (Base == 28)? SMIX_array_b2_28[i] : SMIX_array_b2_29[i];//(Base == 29)
			
			assign SMIX[(i*4+3+1)*8-1:(i*4+3)*8] = (Base ==  0)? SMIX_array_b3_00[i] :
			 																			 (Base ==  1)? SMIX_array_b3_01[i] :
			 																			 (Base ==  2)? SMIX_array_b3_02[i] :
			 																			 (Base ==  3)? SMIX_array_b3_03[i] :
			 																			 (Base ==  4)? SMIX_array_b3_04[i] :
			 																			 (Base ==  5)? SMIX_array_b3_05[i] :
			 																			 (Base ==  6)? SMIX_array_b3_06[i] :
			 																			 (Base ==  7)? SMIX_array_b3_07[i] :
			 																			 (Base ==  8)? SMIX_array_b3_08[i] :
			 																			 (Base ==  9)? SMIX_array_b3_09[i] :
			 																			 (Base == 10)? SMIX_array_b3_10[i] :
			 																			 (Base == 11)? SMIX_array_b3_11[i] :
			 																			 (Base == 12)? SMIX_array_b3_12[i] :
			 																			 (Base == 13)? SMIX_array_b3_13[i] :
			 																			 (Base == 14)? SMIX_array_b3_14[i] :
			 																			 (Base == 15)? SMIX_array_b3_15[i] :
			 																			 (Base == 16)? SMIX_array_b3_16[i] :
			 																			 (Base == 17)? SMIX_array_b3_17[i] :
			 																			 (Base == 18)? SMIX_array_b3_18[i] :
			 																			 (Base == 19)? SMIX_array_b3_19[i] :
			 																			 (Base == 20)? SMIX_array_b3_20[i] :
			 																			 (Base == 21)? SMIX_array_b3_21[i] :
			 																			 (Base == 22)? SMIX_array_b3_22[i] :
			 																			 (Base == 23)? SMIX_array_b3_23[i] :
			 																			 (Base == 24)? SMIX_array_b3_24[i] :
			 																			 (Base == 25)? SMIX_array_b3_25[i] :
			 																			 (Base == 26)? SMIX_array_b3_26[i] :
			 																			 (Base == 27)? SMIX_array_b3_27[i] :
			 																			 (Base == 28)? SMIX_array_b3_28[i] : SMIX_array_b3_29[i];//(Base == 29)
			 																			 
		end                                               
endgenerate                                           
                                                      
//1.AES SBox
//for (r=0; r<4; r++) for (c=0; c<4; c++) ENTRY (U, r, c) = aessub[BYTES(hs, r, c)];
//ori assign st0_d  = state_d_array[COLUMN(Base,0)];//st0_d  = state_d_long[((COLUMN(Base,0)+1)*32-1):COLUMN(Base,0)*32];
//ori assign st1_d  = state_d_array[COLUMN(Base,1)];//st1_d  = state_d_long[((COLUMN(Base,1)+1)*32-1):COLUMN(Base,1)*32];
//ori assign st2_d  = state_d_array[COLUMN(Base,2)];//st2_d  = state_d_long[((COLUMN(Base,2)+1)*32-1):COLUMN(Base,2)*32];
//ori assign st3_d  = state_d_array[COLUMN(Base,3)];//st3_d  = state_d_long[((COLUMN(Base,3)+1)*32-1):COLUMN(Base,3)*32];


assign st0_d  = state_d_array[Base];

assign st1_d  = (Base == 0) ? state_d_array[ 1] :
                (Base == 1) ? state_d_array[ 2] :   
                (Base == 2) ? state_d_array[ 3] :   
                (Base == 3) ? state_d_array[ 4] :   
                (Base == 4) ? state_d_array[ 5] :   
                (Base == 5) ? state_d_array[ 6] :   
                (Base == 6) ? state_d_array[ 7] :   
                (Base == 7) ? state_d_array[ 8] :   
                (Base == 8) ? state_d_array[ 9] :   
                (Base == 9) ? state_d_array[10] :   
                (Base ==10) ? state_d_array[11] :   
                (Base ==11) ? state_d_array[12] :   
                (Base ==12) ? state_d_array[13] :   
                (Base ==13) ? state_d_array[14] :   
                (Base ==14) ? state_d_array[15] :   
                (Base ==15) ? state_d_array[16] :   
                (Base ==16) ? state_d_array[17] :   
                (Base ==17) ? state_d_array[18] :   
                (Base ==18) ? state_d_array[19] :   
                (Base ==19) ? state_d_array[20] :   
                (Base ==20) ? state_d_array[21] :   
                (Base ==21) ? state_d_array[22] :   
                (Base ==22) ? state_d_array[23] :   
                (Base ==23) ? state_d_array[24] :   
                (Base ==24) ? state_d_array[25] :   
                (Base ==25) ? state_d_array[26] :   
                (Base ==26) ? state_d_array[27] :   
                (Base ==27) ? state_d_array[28] :   
                (Base ==28) ? state_d_array[29] : state_d_array[ 0];//(Base ==29)  

assign st2_d  = (Base == 0) ? state_d_array[ 2] :
                (Base == 1) ? state_d_array[ 3] :   
                (Base == 2) ? state_d_array[ 4] :   
                (Base == 3) ? state_d_array[ 5] :   
                (Base == 4) ? state_d_array[ 6] :   
                (Base == 5) ? state_d_array[ 7] :   
                (Base == 6) ? state_d_array[ 8] :   
                (Base == 7) ? state_d_array[ 9] :   
                (Base == 8) ? state_d_array[10] :   
                (Base == 9) ? state_d_array[11] :   
                (Base ==10) ? state_d_array[12] :   
                (Base ==11) ? state_d_array[13] :   
                (Base ==12) ? state_d_array[14] :   
                (Base ==13) ? state_d_array[15] :   
                (Base ==14) ? state_d_array[16] :   
                (Base ==15) ? state_d_array[17] :   
                (Base ==16) ? state_d_array[18] :   
                (Base ==17) ? state_d_array[19] :   
                (Base ==18) ? state_d_array[20] :   
                (Base ==19) ? state_d_array[21] :   
                (Base ==20) ? state_d_array[22] :   
                (Base ==21) ? state_d_array[23] :   
                (Base ==22) ? state_d_array[24] :   
                (Base ==23) ? state_d_array[25] :   
                (Base ==24) ? state_d_array[26] :   
                (Base ==25) ? state_d_array[27] :   
                (Base ==26) ? state_d_array[28] :   
                (Base ==27) ? state_d_array[29] :   
                (Base ==28) ? state_d_array[ 0] : state_d_array[ 1];//(Base ==29)  

assign st3_d  = (Base == 0) ? state_d_array[ 3] :
                (Base == 1) ? state_d_array[ 4] :   
                (Base == 2) ? state_d_array[ 5] :   
                (Base == 3) ? state_d_array[ 6] :   
                (Base == 4) ? state_d_array[ 7] :   
                (Base == 5) ? state_d_array[ 8] :   
                (Base == 6) ? state_d_array[ 9] :   
                (Base == 7) ? state_d_array[10] :   
                (Base == 8) ? state_d_array[11] :   
                (Base == 9) ? state_d_array[12] :   
                (Base ==10) ? state_d_array[13] :   
                (Base ==11) ? state_d_array[14] :   
                (Base ==12) ? state_d_array[15] :   
                (Base ==13) ? state_d_array[16] :   
                (Base ==14) ? state_d_array[17] :   
                (Base ==15) ? state_d_array[18] :   
                (Base ==16) ? state_d_array[19] :   
                (Base ==17) ? state_d_array[20] :   
                (Base ==18) ? state_d_array[21] :   
                (Base ==19) ? state_d_array[22] :   
                (Base ==20) ? state_d_array[23] :   
                (Base ==21) ? state_d_array[24] :   
                (Base ==22) ? state_d_array[25] :   
                (Base ==23) ? state_d_array[26] :   
                (Base ==24) ? state_d_array[27] :   
                (Base ==25) ? state_d_array[28] :   
                (Base ==26) ? state_d_array[29] :   
                (Base ==27) ? state_d_array[ 0] :   
                (Base ==28) ? state_d_array[ 1] : state_d_array[ 2];//(Base ==29)  
            
assign U0[0]	= AES_SUB(st0_d[ 7: 0]);//AES_SUB(BYTES(hs, 0, 0))	
assign U1[0]	= AES_SUB(st1_d[ 7: 0]);//AES_SUB(BYTES(hs, 0, 1))		
assign U2[0]	= AES_SUB(st2_d[ 7: 0]);//AES_SUB(BYTES(hs, 0, 2))		
assign U3[0]	= AES_SUB(st3_d[ 7: 0]);//AES_SUB(BYTES(hs, 0, 3))		

assign U0[1]	= AES_SUB(st0_d[15: 8]);//AES_SUB(BYTES(hs, 1, 0))	
assign U1[1]	= AES_SUB(st1_d[15: 8]);//AES_SUB(BYTES(hs, 1, 1))		
assign U2[1]	= AES_SUB(st2_d[15: 8]);//AES_SUB(BYTES(hs, 1, 2))		
assign U3[1]	= AES_SUB(st3_d[15: 8]);//AES_SUB(BYTES(hs, 1, 3))		

assign U0[2]	= AES_SUB(st0_d[23:16]);//AES_SUB(BYTES(hs, 2, 0))	
assign U1[2]	= AES_SUB(st1_d[23:16]);//AES_SUB(BYTES(hs, 2, 1))		
assign U2[2]	= AES_SUB(st2_d[23:16]);//AES_SUB(BYTES(hs, 2, 2))		
assign U3[2]	= AES_SUB(st3_d[23:16]);//AES_SUB(BYTES(hs, 2, 3))		

assign U0[3]	= AES_SUB(st0_d[31:24]);//AES_SUB(BYTES(hs, 3, 0))	
assign U1[3]	= AES_SUB(st1_d[31:24]);//AES_SUB(BYTES(hs, 3, 1))		
assign U2[3]	= AES_SUB(st2_d[31:24]);//AES_SUB(BYTES(hs, 3, 2))		
assign U3[3]	= AES_SUB(st3_d[31:24]);//AES_SUB(BYTES(hs, 3, 3))		

//2.Matrix MUL with SMIX_LUT 
//N_SMIX[256]= {1, 4, 7, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
//							0, 1, 0, 0, 1, 1, 4, 7, 0, 1, 0, 0, 0, 1, 0, 0,
//							0, 0, 1, 0, 0, 0, 1, 0, 7, 1, 1, 4, 0, 0, 1, 0,
//							0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 4, 7, 1, 1,
//							0, 0, 0, 0, 0, 4, 7, 1, 1, 0, 0, 0, 1, 0, 0, 0,
//							0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 4, 7, 0, 1, 0, 0,
//							0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 7, 1, 0, 4,
//							4, 7, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0,
//							0, 0, 0, 0, 7, 0, 0, 0, 6, 4, 7, 1, 7, 0, 0, 0,
//							0, 7, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 1, 6, 4, 7,
//							7, 1, 6, 4, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 7, 0,
//							0, 0, 0, 7, 4, 7, 1, 6, 0, 0, 0, 7, 0, 0, 0, 0,
//							0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 5, 4, 7, 1,
//							1, 5, 4, 7, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0,
//							0, 0, 4, 0, 7, 1, 5, 4, 0, 0, 0, 0, 0, 0, 4, 0,
//							0, 0, 0, 4, 0, 0, 0, 4, 4, 7, 1, 5, 0, 0, 0, 0 };        
   
//() * N_SMIX R0                     
assign W0[0]	= gf_1(U0[0])	 /*gf2mul[U0[0]].b[1] */
       				^ gf_4(U0[1])  /*gf2mul[U0[1]].b[4] */
       				^ gf_7(U0[2])  /*gf2mul[U0[2]].b[7] */
       				^ gf_1(U0[3])  /*gf2mul[U0[3]].b[1] */
       				^ gf_1(U1[0])  /*gf2mul[U1[0]].b[1] */
       				^ 0					   /*gf2mul[U1[1]].b[0] */
       				^ 0					   /*gf2mul[U1[2]].b[0] */
       				^ 0					   /*gf2mul[U1[3]].b[0] */
       				^ gf_1(U2[0])  /*gf2mul[U2[0]].b[1] */
       				^ 0					   /*gf2mul[U2[1]].b[0] */
       				^ 0					   /*gf2mul[U2[2]].b[0] */
       				^ 0					   /*gf2mul[U2[3]].b[0] */
       				^ gf_1(U3[0])  /*gf2mul[U3[0]].b[1] */
       				^ 0 				   /*gf2mul[U3[1]].b[0] */
       				^ 0 				   /*gf2mul[U3[2]].b[0] */
       				^ 0; 				   /*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R1                     
assign W1[0]	= 0						 /*gf2mul[U0[0]].b[0] */
							^ gf_1(U0[1])	 /*gf2mul[U0[1]].b[1] */
							^ 0  					 /*gf2mul[U0[2]].b[0] */
							^ 0  					 /*gf2mul[U0[3]].b[0] */
							^ gf_1(U1[0])  /*gf2mul[U1[0]].b[1] */
							^ gf_1(U1[1])  /*gf2mul[U1[1]].b[1] */
							^ gf_4(U1[2])  /*gf2mul[U1[2]].b[4] */
							^ gf_7(U1[3])  /*gf2mul[U1[3]].b[7] */
							^ 0					   /*gf2mul[U2[0]].b[0] */
							^ gf_1(U2[1])  /*gf2mul[U2[1]].b[1] */
							^ 0						 /*gf2mul[U2[2]].b[0] */
							^ 0						 /*gf2mul[U2[3]].b[0] */
							^ 0						 /*gf2mul[U3[0]].b[0] */
							^ gf_1(U3[1])  /*gf2mul[U3[1]].b[1] */
							^ 0  					 /*gf2mul[U3[2]].b[0] */
							^ 0; 					 /*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R2                     
assign W2[0]	= 0					   /*gf2mul[U0[0]].b[0] */
							^ 0					   /*gf2mul[U0[1]].b[0] */
							^ gf_1(U0[2])  /*gf2mul[U0[2]].b[1] */
							^ 0					   /*gf2mul[U0[3]].b[0] */
							^ 0					   /*gf2mul[U1[0]].b[0] */
							^ 0					   /*gf2mul[U1[1]].b[0] */
							^ gf_1(U1[2])  /*gf2mul[U1[2]].b[1] */
							^ 0					   /*gf2mul[U1[3]].b[0] */
							^ gf_7(U2[0])  /*gf2mul[U2[0]].b[7] */
							^ gf_1(U2[1])  /*gf2mul[U2[1]].b[1] */
							^ gf_1(U2[2])  /*gf2mul[U2[2]].b[1] */
							^ gf_4(U2[3])  /*gf2mul[U2[3]].b[4] */
							^ 0						 /*gf2mul[U3[0]].b[0] */
							^ 0						 /*gf2mul[U3[1]].b[0] */
							^ gf_1(U3[2])  /*gf2mul[U3[2]].b[1] */
							^ 0;					 /*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R3          
assign W3[0]	= 0						 /*gf2mul[U0[0]].b[0] */
							^ 0						 /*gf2mul[U0[1]].b[0] */
							^ 0						 /*gf2mul[U0[2]].b[0] */
							^ gf_1(U0[3])  /*gf2mul[U0[3]].b[1] */
							^ 0						 /*gf2mul[U1[0]].b[0] */
							^ 0					   /*gf2mul[U1[1]].b[0] */
							^ 0					   /*gf2mul[U1[2]].b[0] */
							^ gf_1(U1[3])  /*gf2mul[U1[3]].b[1] */
							^ 0						 /*gf2mul[U2[0]].b[0] */
							^ 0						 /*gf2mul[U2[1]].b[0] */
							^ 0						 /*gf2mul[U2[2]].b[0] */
							^ gf_1(U2[3])  /*gf2mul[U2[3]].b[1] */
							^ gf_4(U3[0])  /*gf2mul[U3[0]].b[4] */
							^ gf_7(U3[1])  /*gf2mul[U3[1]].b[7] */
							^ gf_1(U3[2])  /*gf2mul[U3[2]].b[1] */
							^ gf_1(U3[3]); /*gf2mul[U3[3]].b[1];*/
//() * N_SMIX R4          
assign W0[1]	= 0						 /*gf2mul[U0[0]].b[0] */
							^ 0						 /*gf2mul[U0[1]].b[0] */
							^ 0						 /*gf2mul[U0[2]].b[0] */
							^ 0						 /*gf2mul[U0[3]].b[0] */
							^ 0						 /*gf2mul[U1[0]].b[0] */
							^ gf_4(U1[1])  /*gf2mul[U1[1]].b[4] */
							^ gf_7(U1[2])  /*gf2mul[U1[2]].b[7] */
							^ gf_1(U1[3])  /*gf2mul[U1[3]].b[1] */
							^ gf_1(U2[0])  /*gf2mul[U2[0]].b[1] */
							^ 0						 /*gf2mul[U2[1]].b[0] */
							^ 0						 /*gf2mul[U2[2]].b[0] */
							^ 0						 /*gf2mul[U2[3]].b[0] */
							^ gf_1(U3[0])  /*gf2mul[U3[0]].b[1] */
							^ 0 					 /*gf2mul[U3[1]].b[0] */
							^ 0 					 /*gf2mul[U3[2]].b[0] */
							^ 0;					 /*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R5          
assign W1[1]	= 0 				  /*gf2mul[U0[0]].b[0] */
							^ gf_1(U0[1]) /*gf2mul[U0[1]].b[1] */
							^ 0					  /*gf2mul[U0[2]].b[0] */
							^ 0					  /*gf2mul[U0[3]].b[0] */
							^ 0					  /*gf2mul[U1[0]].b[0] */
							^ 0					  /*gf2mul[U1[1]].b[0] */
							^ 0					  /*gf2mul[U1[2]].b[0] */
							^ 0					  /*gf2mul[U1[3]].b[0] */
							^ gf_1(U2[0]) /*gf2mul[U2[0]].b[1] */
							^ 0						/*gf2mul[U2[1]].b[0] */
							^ gf_4(U2[2]) /*gf2mul[U2[2]].b[4] */
							^ gf_7(U2[3]) /*gf2mul[U2[3]].b[7] */
							^ 0 				  /*gf2mul[U3[0]].b[0] */
							^ gf_1(U3[1]) /*gf2mul[U3[1]].b[1] */
							^ 0 					/*gf2mul[U3[2]].b[0] */
							^ 0;					/*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R6          
assign W2[1]	= 0					   /*gf2mul[U0[0]].b[0] */
							^ 0					   /*gf2mul[U0[1]].b[0] */
							^ gf_1(U0[2])  /*gf2mul[U0[2]].b[1] */
							^ 0					   /*gf2mul[U0[3]].b[0] */
							^ 0					   /*gf2mul[U1[0]].b[0] */
							^ 0					   /*gf2mul[U1[1]].b[0] */
							^ gf_1(U1[2])  /*gf2mul[U1[2]].b[1] */
							^ 0					   /*gf2mul[U1[3]].b[0] */
							^ 0					   /*gf2mul[U2[0]].b[0] */
							^ 0					   /*gf2mul[U2[1]].b[0] */
							^ 0					   /*gf2mul[U2[2]].b[0] */
							^ 0					   /*gf2mul[U2[3]].b[0] */
							^ gf_7(U3[0])  /*gf2mul[U3[0]].b[7] */
							^ gf_1(U3[1])  /*gf2mul[U3[1]].b[1] */
							^ 0					   /*gf2mul[U3[2]].b[0] */
							^ gf_4(U3[3]); /*gf2mul[U3[3]].b[4];*/
//() * N_SMIX R7          
assign W3[1]	= gf_4(U0[0])  /*gf2mul[U0[0]].b[4] */
							^ gf_7(U0[1])  /*gf2mul[U0[1]].b[7] */
							^ gf_1(U0[2])  /*gf2mul[U0[2]].b[1] */
							^ 0					   /*gf2mul[U0[3]].b[0] */
							^ 0					   /*gf2mul[U1[0]].b[0] */
							^ 0					   /*gf2mul[U1[1]].b[0] */
							^ 0					   /*gf2mul[U1[2]].b[0] */
							^ gf_1(U1[3])  /*gf2mul[U1[3]].b[1] */
							^ 0					   /*gf2mul[U2[0]].b[0] */
							^ 0					   /*gf2mul[U2[1]].b[0] */
							^ 0					   /*gf2mul[U2[2]].b[0] */
							^ gf_1(U2[3])  /*gf2mul[U2[3]].b[1] */
							^ 0  					 /*gf2mul[U3[0]].b[0] */
							^ 0  					 /*gf2mul[U3[1]].b[0] */
							^ 0  					 /*gf2mul[U3[2]].b[0] */
							^ 0; 					 /*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R8          
assign W0[2]	= 0  					 /*gf2mul[U0[0]].b[0] */
							^ 0  					 /*gf2mul[U0[1]].b[0] */
							^ 0  					 /*gf2mul[U0[2]].b[0] */
							^ 0  					 /*gf2mul[U0[3]].b[0] */
							^ gf_7(U1[0])  /*gf2mul[U1[0]].b[7] */
							^ 0  					 /*gf2mul[U1[1]].b[0] */
							^ 0  					 /*gf2mul[U1[2]].b[0] */
							^ 0  					 /*gf2mul[U1[3]].b[0] */
							^ gf_6(U2[0])  /*gf2mul[U2[0]].b[6] */
							^ gf_4(U2[1])  /*gf2mul[U2[1]].b[4] */
							^ gf_7(U2[2])  /*gf2mul[U2[2]].b[7] */
							^ gf_1(U2[3])  /*gf2mul[U2[3]].b[1] */
							^ gf_7(U3[0])  /*gf2mul[U3[0]].b[7] */
							^ 0  					 /*gf2mul[U3[1]].b[0] */
							^ 0  					 /*gf2mul[U3[2]].b[0] */
							^ 0; 					 /*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R9          
assign W1[2]	= 0					  /*gf2mul[U0[0]].b[0] */
							^ gf_7(U0[1]) /*gf2mul[U0[1]].b[7] */
							^ 0					  /*gf2mul[U0[2]].b[0] */
							^ 0					  /*gf2mul[U0[3]].b[0] */
							^ 0					  /*gf2mul[U1[0]].b[0] */
							^ 0					  /*gf2mul[U1[1]].b[0] */
							^ 0					  /*gf2mul[U1[2]].b[0] */
							^ 0					  /*gf2mul[U1[3]].b[0] */
							^ 0					  /*gf2mul[U2[0]].b[0] */
							^ gf_7(U2[1]) /*gf2mul[U2[1]].b[7] */
							^ 0					  /*gf2mul[U2[2]].b[0] */
							^ 0					  /*gf2mul[U2[3]].b[0] */
							^ gf_1(U3[0]) /*gf2mul[U3[0]].b[1] */
							^ gf_6(U3[1]) /*gf2mul[U3[1]].b[6] */
							^ gf_4(U3[2]) /*gf2mul[U3[2]].b[4] */
							^ gf_7(U3[3]);/*gf2mul[U3[3]].b[7];*/
//() * N_SMIX R10          
assign W2[2]	= gf_7(U0[0]) /*gf2mul[U0[0]].b[7] */
							^ gf_1(U0[1]) /*gf2mul[U0[1]].b[1] */
							^ gf_6(U0[2]) /*gf2mul[U0[2]].b[6] */
							^ gf_4(U0[3]) /*gf2mul[U0[3]].b[4] */
							^ 0					  /*gf2mul[U1[0]].b[0] */
							^ 0					  /*gf2mul[U1[1]].b[0] */
							^ gf_7(U1[2]) /*gf2mul[U1[2]].b[7] */
							^ 0					  /*gf2mul[U1[3]].b[0] */
							^ 0					  /*gf2mul[U2[0]].b[0] */
							^ 0					  /*gf2mul[U2[1]].b[0] */
							^ 0					  /*gf2mul[U2[2]].b[0] */
							^ 0					  /*gf2mul[U2[3]].b[0] */
							^ 0					  /*gf2mul[U3[0]].b[0] */
							^ 0					  /*gf2mul[U3[1]].b[0] */
							^ gf_7(U3[2]) /*gf2mul[U3[2]].b[7] */
							^ 0;					/*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R11          
assign W3[2]	= 0					  /*gf2mul[U0[0]].b[0] */
							^ 0					  /*gf2mul[U0[1]].b[0] */
							^ 0					  /*gf2mul[U0[2]].b[0] */
							^ gf_7(U0[3]) /*gf2mul[U0[3]].b[7] */
							^ gf_4(U1[0]) /*gf2mul[U1[0]].b[4] */
							^ gf_7(U1[1]) /*gf2mul[U1[1]].b[7] */
							^ gf_1(U1[2]) /*gf2mul[U1[2]].b[1] */
							^ gf_6(U1[3]) /*gf2mul[U1[3]].b[6] */
							^ 0					  /*gf2mul[U2[0]].b[0] */
							^ 0					  /*gf2mul[U2[1]].b[0] */
							^ 0					  /*gf2mul[U2[2]].b[0] */
							^ gf_7(U2[3]) /*gf2mul[U2[3]].b[7] */
							^ 0					  /*gf2mul[U3[0]].b[0] */
							^ 0 					/*gf2mul[U3[1]].b[0] */
							^ 0 					/*gf2mul[U3[2]].b[0] */
							^ 0;					/*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R12          
assign W0[3]	= 0					  /*gf2mul[U0[0]].b[0] */
							^ 0					  /*gf2mul[U0[1]].b[0] */
							^ 0					  /*gf2mul[U0[2]].b[0] */
							^ 0					  /*gf2mul[U0[3]].b[0] */
							^ gf_4(U1[0]) /*gf2mul[U1[0]].b[4] */
							^ 0					  /*gf2mul[U1[1]].b[0] */
							^ 0					  /*gf2mul[U1[2]].b[0] */
							^ 0					  /*gf2mul[U1[3]].b[0] */
							^ gf_4(U2[0]) /*gf2mul[U2[0]].b[4] */
							^ 0					  /*gf2mul[U2[1]].b[0] */
							^ 0					  /*gf2mul[U2[2]].b[0] */
							^ 0					  /*gf2mul[U2[3]].b[0] */
							^ gf_5(U3[0]) /*gf2mul[U3[0]].b[5] */
							^ gf_4(U3[1]) /*gf2mul[U3[1]].b[4] */
							^ gf_7(U3[2]) /*gf2mul[U3[2]].b[7] */
							^ gf_1(U3[3]);/*gf2mul[U3[3]].b[1];*/
//() * N_SMIX R13          
assign W1[3]	= gf_1(U0[0]) /*gf2mul[U0[0]].b[1] */
							^ gf_5(U0[1]) /*gf2mul[U0[1]].b[5] */
							^ gf_4(U0[2]) /*gf2mul[U0[2]].b[4] */
							^ gf_7(U0[3]) /*gf2mul[U0[3]].b[7] */
							^ 0					  /*gf2mul[U1[0]].b[0] */
							^ 0					  /*gf2mul[U1[1]].b[0] */
							^ 0					  /*gf2mul[U1[2]].b[0] */
							^ 0					  /*gf2mul[U1[3]].b[0] */
							^ 0					  /*gf2mul[U2[0]].b[0] */
							^ gf_4(U2[1]) /*gf2mul[U2[1]].b[4] */
							^ 0					  /*gf2mul[U2[2]].b[0] */
							^ 0					  /*gf2mul[U2[3]].b[0] */
							^ 0					  /*gf2mul[U3[0]].b[0] */
							^ gf_4(U3[1]) /*gf2mul[U3[1]].b[4] */
							^ 0 					/*gf2mul[U3[2]].b[0] */
							^ 0;					/*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R14          
assign W2[3]	= 0					  /*gf2mul[U0[0]].b[0] */
							^ 0					  /*gf2mul[U0[1]].b[0] */
							^ gf_4(U0[2]) /*gf2mul[U0[2]].b[4] */
							^ 0					  /*gf2mul[U0[3]].b[0] */
							^ gf_7(U1[0]) /*gf2mul[U1[0]].b[7] */
							^ gf_1(U1[1]) /*gf2mul[U1[1]].b[1] */
							^ gf_5(U1[2]) /*gf2mul[U1[2]].b[5] */
							^ gf_4(U1[3]) /*gf2mul[U1[3]].b[4] */
							^ 0					  /*gf2mul[U2[0]].b[0] */
							^ 0					  /*gf2mul[U2[1]].b[0] */
							^ 0					  /*gf2mul[U2[2]].b[0] */
							^ 0					  /*gf2mul[U2[3]].b[0] */
							^ 0					  /*gf2mul[U3[0]].b[0] */
							^ 0					  /*gf2mul[U3[1]].b[0] */
							^ gf_4(U3[2]) /*gf2mul[U3[2]].b[4] */
							^ 0;					/*gf2mul[U3[3]].b[0];*/
//() * N_SMIX R15          
assign W3[3]	= 0 					/*gf2mul[U0[0]].b[0] */
							^ 0 					/*gf2mul[U0[1]].b[0] */
							^ 0 					/*gf2mul[U0[2]].b[0] */
							^ gf_4(U0[3]) /*gf2mul[U0[3]].b[4] */
							^ 0					  /*gf2mul[U1[0]].b[0] */
							^ 0					  /*gf2mul[U1[1]].b[0] */
							^ 0					  /*gf2mul[U1[2]].b[0] */
							^ gf_4(U1[3]) /*gf2mul[U1[3]].b[4] */
							^ gf_4(U2[0]) /*gf2mul[U2[0]].b[4] */
							^ gf_7(U2[1]) /*gf2mul[U2[1]].b[7] */
							^ gf_1(U2[2]) /*gf2mul[U2[2]].b[1] */
							^ gf_5(U2[3]) /*gf2mul[U2[3]].b[5] */
							^ 0 					/*gf2mul[U3[0]].b[0] */
							^ 0 					/*gf2mul[U3[1]].b[0] */
							^ 0 					/*gf2mul[U3[2]].b[0] */
							^ 0;					/*gf2mul[U3[3]].b[0];*/


//-----------------------------------------------------
/*
assign SMIX_array_b0[COLUMN(Base,0)]= W0[0];
assign SMIX_array_b0[COLUMN(Base,1)]= W0[1];
assign SMIX_array_b0[COLUMN(Base,2)]= W0[2];
assign SMIX_array_b0[COLUMN(Base,3)]= W0[3];
assign SMIX_array_b1[COLUMN(Base,0)]= W1[0];
assign SMIX_array_b1[COLUMN(Base,1)]= W1[1];
assign SMIX_array_b1[COLUMN(Base,2)]= W1[2];
assign SMIX_array_b1[COLUMN(Base,3)]= W1[3];
assign SMIX_array_b2[COLUMN(Base,0)]= W2[0];
assign SMIX_array_b2[COLUMN(Base,1)]= W2[1];
assign SMIX_array_b2[COLUMN(Base,2)]= W2[2];
assign SMIX_array_b2[COLUMN(Base,3)]= W2[3];
assign SMIX_array_b3[COLUMN(Base,0)]= W3[0];
assign SMIX_array_b3[COLUMN(Base,1)]= W3[1];
assign SMIX_array_b3[COLUMN(Base,2)]= W3[2];
assign SMIX_array_b3[COLUMN(Base,3)]= W3[3];
*/
//-----------------------------------------------------

//-- Base: 00 -----------------------------------------------------------------------------
		assign SMIX_array_b0_00[ 0]= W0[0];
		assign SMIX_array_b1_00[ 0]= W1[0];
		assign SMIX_array_b2_00[ 0]= W2[0];
		assign SMIX_array_b3_00[ 0]= W3[0];
		assign SMIX_array_b0_00[ 1]= W0[1];
		assign SMIX_array_b1_00[ 1]= W1[1];
		assign SMIX_array_b2_00[ 1]= W2[1];
		assign SMIX_array_b3_00[ 1]= W3[1];
		assign SMIX_array_b0_00[ 2]= W0[2];
		assign SMIX_array_b1_00[ 2]= W1[2];
		assign SMIX_array_b2_00[ 2]= W2[2];
		assign SMIX_array_b3_00[ 2]= W3[2];
		assign SMIX_array_b0_00[ 3]= W0[3];
		assign SMIX_array_b1_00[ 3]= W1[3];
		assign SMIX_array_b2_00[ 3]= W2[3];
		assign SMIX_array_b3_00[ 3]= W3[3];
		
		generate 
			for (i=4;i<30;i=i+1) begin : gen_base_00
				assign SMIX_array_b0_00[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_00[i] = state_d_array_b1[i];
				assign SMIX_array_b2_00[i] = state_d_array_b2[i];
				assign SMIX_array_b3_00[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 01 -----------------------------------------------------------------------------
		assign SMIX_array_b0_01[ 1]= W0[0];
		assign SMIX_array_b1_01[ 1]= W1[0];
		assign SMIX_array_b2_01[ 1]= W2[0];
		assign SMIX_array_b3_01[ 1]= W3[0];
		assign SMIX_array_b0_01[ 2]= W0[1];
		assign SMIX_array_b1_01[ 2]= W1[1];
		assign SMIX_array_b2_01[ 2]= W2[1];
		assign SMIX_array_b3_01[ 2]= W3[1];
		assign SMIX_array_b0_01[ 3]= W0[2];
		assign SMIX_array_b1_01[ 3]= W1[2];
		assign SMIX_array_b2_01[ 3]= W2[2];
		assign SMIX_array_b3_01[ 3]= W3[2];
		assign SMIX_array_b0_01[ 4]= W0[3];
		assign SMIX_array_b1_01[ 4]= W1[3];
		assign SMIX_array_b2_01[ 4]= W2[3];
		assign SMIX_array_b3_01[ 4]= W3[3];
		generate 
			for (i=5;i<30;i=i+1) begin : gen_base_01_a
				assign SMIX_array_b0_01[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_01[i] = state_d_array_b1[i];
				assign SMIX_array_b2_01[i] = state_d_array_b2[i];
				assign SMIX_array_b3_01[i] = state_d_array_b3[i];
			end
			for (i=0;i< 1;i=i+1) begin : gen_base_01_b
				assign SMIX_array_b0_01[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_01[i] = state_d_array_b1[i];
				assign SMIX_array_b2_01[i] = state_d_array_b2[i];
				assign SMIX_array_b3_01[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 02 -----------------------------------------------------------------------------
		assign SMIX_array_b0_02[ 2]= W0[0];
		assign SMIX_array_b1_02[ 2]= W1[0];
		assign SMIX_array_b2_02[ 2]= W2[0];
		assign SMIX_array_b3_02[ 2]= W3[0];
		assign SMIX_array_b0_02[ 3]= W0[1];
		assign SMIX_array_b1_02[ 3]= W1[1];
		assign SMIX_array_b2_02[ 3]= W2[1];
		assign SMIX_array_b3_02[ 3]= W3[1];
		assign SMIX_array_b0_02[ 4]= W0[2];
		assign SMIX_array_b1_02[ 4]= W1[2];
		assign SMIX_array_b2_02[ 4]= W2[2];
		assign SMIX_array_b3_02[ 4]= W3[2];
		assign SMIX_array_b0_02[ 5]= W0[3];
		assign SMIX_array_b1_02[ 5]= W1[3];
		assign SMIX_array_b2_02[ 5]= W2[3];
		assign SMIX_array_b3_02[ 5]= W3[3];
		generate 
			for (i=6;i<30;i=i+1) begin : gen_base_02_a
				assign SMIX_array_b0_02[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_02[i] = state_d_array_b1[i];
				assign SMIX_array_b2_02[i] = state_d_array_b2[i];
				assign SMIX_array_b3_02[i] = state_d_array_b3[i];
			end 
			for (i=0;i<2;i=i+1) begin : gen_base_02_b
				assign SMIX_array_b0_02[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_02[i] = state_d_array_b1[i];
				assign SMIX_array_b2_02[i] = state_d_array_b2[i];
				assign SMIX_array_b3_02[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 03 -----------------------------------------------------------------------------
		assign SMIX_array_b0_03[ 3]= W0[0];
		assign SMIX_array_b1_03[ 3]= W1[0];
		assign SMIX_array_b2_03[ 3]= W2[0];
		assign SMIX_array_b3_03[ 3]= W3[0];
		assign SMIX_array_b0_03[ 4]= W0[1];
		assign SMIX_array_b1_03[ 4]= W1[1];
		assign SMIX_array_b2_03[ 4]= W2[1];
		assign SMIX_array_b3_03[ 4]= W3[1];
		assign SMIX_array_b0_03[ 5]= W0[2];
		assign SMIX_array_b1_03[ 5]= W1[2];
		assign SMIX_array_b2_03[ 5]= W2[2];
		assign SMIX_array_b3_03[ 5]= W3[2];
		assign SMIX_array_b0_03[ 6]= W0[3];
		assign SMIX_array_b1_03[ 6]= W1[3];
		assign SMIX_array_b2_03[ 6]= W2[3];
		assign SMIX_array_b3_03[ 6]= W3[3];
		generate 
			for (i=7;i<30;i=i+1) begin : gen_base_03_a
				assign SMIX_array_b0_03[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_03[i] = state_d_array_b1[i];
				assign SMIX_array_b2_03[i] = state_d_array_b2[i];
				assign SMIX_array_b3_03[i] = state_d_array_b3[i];
			end
			for (i=0;i< 3;i=i+1) begin : gen_base_03_b
				assign SMIX_array_b0_03[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_03[i] = state_d_array_b1[i];
				assign SMIX_array_b2_03[i] = state_d_array_b2[i];
				assign SMIX_array_b3_03[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 04 -----------------------------------------------------------------------------
		assign SMIX_array_b0_04[ 4]= W0[0];
		assign SMIX_array_b1_04[ 4]= W1[0];
		assign SMIX_array_b2_04[ 4]= W2[0];
		assign SMIX_array_b3_04[ 4]= W3[0];
		assign SMIX_array_b0_04[ 5]= W0[1];
		assign SMIX_array_b1_04[ 5]= W1[1];
		assign SMIX_array_b2_04[ 5]= W2[1];
		assign SMIX_array_b3_04[ 5]= W3[1];
		assign SMIX_array_b0_04[ 6]= W0[2];
		assign SMIX_array_b1_04[ 6]= W1[2];
		assign SMIX_array_b2_04[ 6]= W2[2];
		assign SMIX_array_b3_04[ 6]= W3[2];
		assign SMIX_array_b0_04[ 7]= W0[3];
		assign SMIX_array_b1_04[ 7]= W1[3];
		assign SMIX_array_b2_04[ 7]= W2[3];
		assign SMIX_array_b3_04[ 7]= W3[3];
		generate 
			for (i=8;i<30;i=i+1) begin : gen_base_04_a
				assign SMIX_array_b0_04[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_04[i] = state_d_array_b1[i];
				assign SMIX_array_b2_04[i] = state_d_array_b2[i];
				assign SMIX_array_b3_04[i] = state_d_array_b3[i];
			end
			for (i=0;i<4;i=i+1) begin : gen_base_04_b
				assign SMIX_array_b0_04[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_04[i] = state_d_array_b1[i];
				assign SMIX_array_b2_04[i] = state_d_array_b2[i];
				assign SMIX_array_b3_04[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 05 -----------------------------------------------------------------------------
		assign SMIX_array_b0_05[ 5]= W0[0];
		assign SMIX_array_b1_05[ 5]= W1[0];
		assign SMIX_array_b2_05[ 5]= W2[0];
		assign SMIX_array_b3_05[ 5]= W3[0];
		assign SMIX_array_b0_05[ 6]= W0[1];
		assign SMIX_array_b1_05[ 6]= W1[1];
		assign SMIX_array_b2_05[ 6]= W2[1];
		assign SMIX_array_b3_05[ 6]= W3[1];
		assign SMIX_array_b0_05[ 7]= W0[2];
		assign SMIX_array_b1_05[ 7]= W1[2];
		assign SMIX_array_b2_05[ 7]= W2[2];
		assign SMIX_array_b3_05[ 7]= W3[2];
		assign SMIX_array_b0_05[ 8]= W0[3];
		assign SMIX_array_b1_05[ 8]= W1[3];
		assign SMIX_array_b2_05[ 8]= W2[3];
		assign SMIX_array_b3_05[ 8]= W3[3];
		generate 
			for (i=9;i<30;i=i+1) begin : gen_base_05_a
				assign SMIX_array_b0_05[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_05[i] = state_d_array_b1[i];
				assign SMIX_array_b2_05[i] = state_d_array_b2[i];
				assign SMIX_array_b3_05[i] = state_d_array_b3[i];
			end
			for (i=0;i<5;i=i+1) begin : gen_base_05_b
				assign SMIX_array_b0_05[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_05[i] = state_d_array_b1[i];
				assign SMIX_array_b2_05[i] = state_d_array_b2[i];
				assign SMIX_array_b3_05[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 06 -----------------------------------------------------------------------------
		assign SMIX_array_b0_06[ 6]= W0[0];
		assign SMIX_array_b1_06[ 6]= W1[0];
		assign SMIX_array_b2_06[ 6]= W2[0];
		assign SMIX_array_b3_06[ 6]= W3[0];
		assign SMIX_array_b0_06[ 7]= W0[1];
		assign SMIX_array_b1_06[ 7]= W1[1];
		assign SMIX_array_b2_06[ 7]= W2[1];
		assign SMIX_array_b3_06[ 7]= W3[1];
		assign SMIX_array_b0_06[ 8]= W0[2];
		assign SMIX_array_b1_06[ 8]= W1[2];
		assign SMIX_array_b2_06[ 8]= W2[2];
		assign SMIX_array_b3_06[ 8]= W3[2];
		assign SMIX_array_b0_06[ 9]= W0[3];
		assign SMIX_array_b1_06[ 9]= W1[3];
		assign SMIX_array_b2_06[ 9]= W2[3];
		assign SMIX_array_b3_06[ 9]= W3[3];
		generate 
			for (i=10;i<30;i=i+1) begin : gen_base_06_a
				assign SMIX_array_b0_06[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_06[i] = state_d_array_b1[i];
				assign SMIX_array_b2_06[i] = state_d_array_b2[i];
				assign SMIX_array_b3_06[i] = state_d_array_b3[i];
			end
			for (i=0;i<6;i=i+1) begin : gen_base_06_b
				assign SMIX_array_b0_06[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_06[i] = state_d_array_b1[i];
				assign SMIX_array_b2_06[i] = state_d_array_b2[i];
				assign SMIX_array_b3_06[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 07 -----------------------------------------------------------------------------
		assign SMIX_array_b0_07[ 7]= W0[0];
		assign SMIX_array_b1_07[ 7]= W1[0];
		assign SMIX_array_b2_07[ 7]= W2[0];
		assign SMIX_array_b3_07[ 7]= W3[0];
		assign SMIX_array_b0_07[ 8]= W0[1];
		assign SMIX_array_b1_07[ 8]= W1[1];
		assign SMIX_array_b2_07[ 8]= W2[1];
		assign SMIX_array_b3_07[ 8]= W3[1];
		assign SMIX_array_b0_07[ 9]= W0[2];
		assign SMIX_array_b1_07[ 9]= W1[2];
		assign SMIX_array_b2_07[ 9]= W2[2];
		assign SMIX_array_b3_07[ 9]= W3[2];
		assign SMIX_array_b0_07[10]= W0[3];
		assign SMIX_array_b1_07[10]= W1[3];
		assign SMIX_array_b2_07[10]= W2[3];
		assign SMIX_array_b3_07[10]= W3[3];
		generate 
			for (i=11;i<30;i=i+1) begin : gen_base_07_a
				assign SMIX_array_b0_07[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_07[i] = state_d_array_b1[i];
				assign SMIX_array_b2_07[i] = state_d_array_b2[i];
				assign SMIX_array_b3_07[i] = state_d_array_b3[i];
			end
			for (i=0;i<7;i=i+1) begin : gen_base_07_b
				assign SMIX_array_b0_07[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_07[i] = state_d_array_b1[i];
				assign SMIX_array_b2_07[i] = state_d_array_b2[i];
				assign SMIX_array_b3_07[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 08 -----------------------------------------------------------------------------
		assign SMIX_array_b0_08[ 8]= W0[0];
		assign SMIX_array_b1_08[ 8]= W1[0];
		assign SMIX_array_b2_08[ 8]= W2[0];
		assign SMIX_array_b3_08[ 8]= W3[0];
		assign SMIX_array_b0_08[ 9]= W0[1];
		assign SMIX_array_b1_08[ 9]= W1[1];
		assign SMIX_array_b2_08[ 9]= W2[1];
		assign SMIX_array_b3_08[ 9]= W3[1];
		assign SMIX_array_b0_08[10]= W0[2];
		assign SMIX_array_b1_08[10]= W1[2];
		assign SMIX_array_b2_08[10]= W2[2];
		assign SMIX_array_b3_08[10]= W3[2];
		assign SMIX_array_b0_08[11]= W0[3];
		assign SMIX_array_b1_08[11]= W1[3];
		assign SMIX_array_b2_08[11]= W2[3];
		assign SMIX_array_b3_08[11]= W3[3];
		generate 
			for (i=12;i<30;i=i+1) begin : gen_base_08_a
				assign SMIX_array_b0_08[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_08[i] = state_d_array_b1[i];
				assign SMIX_array_b2_08[i] = state_d_array_b2[i];
				assign SMIX_array_b3_08[i] = state_d_array_b3[i];
			end
			for (i=0;i<8;i=i+1) begin : gen_base_08_b
				assign SMIX_array_b0_08[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_08[i] = state_d_array_b1[i];
				assign SMIX_array_b2_08[i] = state_d_array_b2[i];
				assign SMIX_array_b3_08[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 09 -----------------------------------------------------------------------------
		assign SMIX_array_b0_09[ 9]= W0[0];
		assign SMIX_array_b1_09[ 9]= W1[0];
		assign SMIX_array_b2_09[ 9]= W2[0];
		assign SMIX_array_b3_09[ 9]= W3[0];
		assign SMIX_array_b0_09[10]= W0[1];
		assign SMIX_array_b1_09[10]= W1[1];
		assign SMIX_array_b2_09[10]= W2[1];
		assign SMIX_array_b3_09[10]= W3[1];
		assign SMIX_array_b0_09[11]= W0[2];
		assign SMIX_array_b1_09[11]= W1[2];
		assign SMIX_array_b2_09[11]= W2[2];
		assign SMIX_array_b3_09[11]= W3[2];
		assign SMIX_array_b0_09[12]= W0[3];
		assign SMIX_array_b1_09[12]= W1[3];
		assign SMIX_array_b2_09[12]= W2[3];
		assign SMIX_array_b3_09[12]= W3[3];
		generate 
			for (i=13;i<30;i=i+1) begin : gen_base_09_a
				assign SMIX_array_b0_09[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_09[i] = state_d_array_b1[i];
				assign SMIX_array_b2_09[i] = state_d_array_b2[i];
				assign SMIX_array_b3_09[i] = state_d_array_b3[i];
			end
			for (i=0;i<9;i=i+1) begin : gen_base_09_b
				assign SMIX_array_b0_09[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_09[i] = state_d_array_b1[i];
				assign SMIX_array_b2_09[i] = state_d_array_b2[i];
				assign SMIX_array_b3_09[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 10 -----------------------------------------------------------------------------
		assign SMIX_array_b0_10[10]= W0[0];
		assign SMIX_array_b1_10[10]= W1[0];
		assign SMIX_array_b2_10[10]= W2[0];
		assign SMIX_array_b3_10[10]= W3[0];
		assign SMIX_array_b0_10[11]= W0[1];
		assign SMIX_array_b1_10[11]= W1[1];
		assign SMIX_array_b2_10[11]= W2[1];
		assign SMIX_array_b3_10[11]= W3[1];
		assign SMIX_array_b0_10[12]= W0[2];
		assign SMIX_array_b1_10[12]= W1[2];
		assign SMIX_array_b2_10[12]= W2[2];
		assign SMIX_array_b3_10[12]= W3[2];
		assign SMIX_array_b0_10[13]= W0[3];
		assign SMIX_array_b1_10[13]= W1[3];
		assign SMIX_array_b2_10[13]= W2[3];
		assign SMIX_array_b3_10[13]= W3[3];
		generate 
			for (i=14;i<30;i=i+1) begin : gen_base_10_a
				assign SMIX_array_b0_10[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_10[i] = state_d_array_b1[i];
				assign SMIX_array_b2_10[i] = state_d_array_b2[i];
				assign SMIX_array_b3_10[i] = state_d_array_b3[i];
			end
			for (i=0;i<10;i=i+1) begin : gen_base_10_b
				assign SMIX_array_b0_10[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_10[i] = state_d_array_b1[i];
				assign SMIX_array_b2_10[i] = state_d_array_b2[i];
				assign SMIX_array_b3_10[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 11 -----------------------------------------------------------------------------
		assign SMIX_array_b0_11[11]= W0[0];
		assign SMIX_array_b1_11[11]= W1[0];
		assign SMIX_array_b2_11[11]= W2[0];
		assign SMIX_array_b3_11[11]= W3[0];
		assign SMIX_array_b0_11[12]= W0[1];
		assign SMIX_array_b1_11[12]= W1[1];
		assign SMIX_array_b2_11[12]= W2[1];
		assign SMIX_array_b3_11[12]= W3[1];
		assign SMIX_array_b0_11[13]= W0[2];
		assign SMIX_array_b1_11[13]= W1[2];
		assign SMIX_array_b2_11[13]= W2[2];
		assign SMIX_array_b3_11[13]= W3[2];
		assign SMIX_array_b0_11[14]= W0[3];
		assign SMIX_array_b1_11[14]= W1[3];
		assign SMIX_array_b2_11[14]= W2[3];
		assign SMIX_array_b3_11[14]= W3[3];
		generate 
			for (i=15;i<30;i=i+1) begin : gen_base_11_a
				assign SMIX_array_b0_11[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_11[i] = state_d_array_b1[i];
				assign SMIX_array_b2_11[i] = state_d_array_b2[i];
				assign SMIX_array_b3_11[i] = state_d_array_b3[i];
			end
			for (i=0;i<11;i=i+1) begin : gen_base_11_b
				assign SMIX_array_b0_11[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_11[i] = state_d_array_b1[i];
				assign SMIX_array_b2_11[i] = state_d_array_b2[i];
				assign SMIX_array_b3_11[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 12 -----------------------------------------------------------------------------
		assign SMIX_array_b0_12[12]= W0[0];
		assign SMIX_array_b1_12[12]= W1[0];
		assign SMIX_array_b2_12[12]= W2[0];
		assign SMIX_array_b3_12[12]= W3[0];
		assign SMIX_array_b0_12[13]= W0[1];
		assign SMIX_array_b1_12[13]= W1[1];
		assign SMIX_array_b2_12[13]= W2[1];
		assign SMIX_array_b3_12[13]= W3[1];
		assign SMIX_array_b0_12[14]= W0[2];
		assign SMIX_array_b1_12[14]= W1[2];
		assign SMIX_array_b2_12[14]= W2[2];
		assign SMIX_array_b3_12[14]= W3[2];
		assign SMIX_array_b0_12[15]= W0[3];
		assign SMIX_array_b1_12[15]= W1[3];
		assign SMIX_array_b2_12[15]= W2[3];
		assign SMIX_array_b3_12[15]= W3[3];
		generate 
			for (i=16;i<30;i=i+1) begin : gen_base_12_a
				assign SMIX_array_b0_12[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_12[i] = state_d_array_b1[i];
				assign SMIX_array_b2_12[i] = state_d_array_b2[i];
				assign SMIX_array_b3_12[i] = state_d_array_b3[i];
			end
			for (i=0;i<12;i=i+1) begin : gen_base_12_b
				assign SMIX_array_b0_12[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_12[i] = state_d_array_b1[i];
				assign SMIX_array_b2_12[i] = state_d_array_b2[i];
				assign SMIX_array_b3_12[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 13 -----------------------------------------------------------------------------
		assign SMIX_array_b0_13[13]= W0[0];
		assign SMIX_array_b1_13[13]= W1[0];
		assign SMIX_array_b2_13[13]= W2[0];
		assign SMIX_array_b3_13[13]= W3[0];
		assign SMIX_array_b0_13[14]= W0[1];
		assign SMIX_array_b1_13[14]= W1[1];
		assign SMIX_array_b2_13[14]= W2[1];
		assign SMIX_array_b3_13[14]= W3[1];
		assign SMIX_array_b0_13[15]= W0[2];
		assign SMIX_array_b1_13[15]= W1[2];
		assign SMIX_array_b2_13[15]= W2[2];
		assign SMIX_array_b3_13[15]= W3[2];
		assign SMIX_array_b0_13[16]= W0[3];
		assign SMIX_array_b1_13[16]= W1[3];
		assign SMIX_array_b2_13[16]= W2[3];
		assign SMIX_array_b3_13[16]= W3[3];
		generate 
			for (i=17;i<30;i=i+1) begin : gen_base_13_a
				assign SMIX_array_b0_13[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_13[i] = state_d_array_b1[i];
				assign SMIX_array_b2_13[i] = state_d_array_b2[i];
				assign SMIX_array_b3_13[i] = state_d_array_b3[i];
			end
			for (i=0;i<13;i=i+1) begin : gen_base_13_b
				assign SMIX_array_b0_13[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_13[i] = state_d_array_b1[i];
				assign SMIX_array_b2_13[i] = state_d_array_b2[i];
				assign SMIX_array_b3_13[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 14 -----------------------------------------------------------------------------
		assign SMIX_array_b0_14[14]= W0[0];
		assign SMIX_array_b1_14[14]= W1[0];
		assign SMIX_array_b2_14[14]= W2[0];
		assign SMIX_array_b3_14[14]= W3[0];
		assign SMIX_array_b0_14[15]= W0[1];
		assign SMIX_array_b1_14[15]= W1[1];
		assign SMIX_array_b2_14[15]= W2[1];
		assign SMIX_array_b3_14[15]= W3[1];
		assign SMIX_array_b0_14[16]= W0[2];
		assign SMIX_array_b1_14[16]= W1[2];
		assign SMIX_array_b2_14[16]= W2[2];
		assign SMIX_array_b3_14[16]= W3[2];
		assign SMIX_array_b0_14[17]= W0[3];
		assign SMIX_array_b1_14[17]= W1[3];
		assign SMIX_array_b2_14[17]= W2[3];
		assign SMIX_array_b3_14[17]= W3[3];
		generate 
			for (i=18;i<30;i=i+1) begin : gen_base_14_a
				assign SMIX_array_b0_14[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_14[i] = state_d_array_b1[i];
				assign SMIX_array_b2_14[i] = state_d_array_b2[i];
				assign SMIX_array_b3_14[i] = state_d_array_b3[i];
			end
			for (i=0;i<14;i=i+1) begin : gen_base_14_b
				assign SMIX_array_b0_14[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_14[i] = state_d_array_b1[i];
				assign SMIX_array_b2_14[i] = state_d_array_b2[i];
				assign SMIX_array_b3_14[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 15 -----------------------------------------------------------------------------
		assign SMIX_array_b0_15[15]= W0[0];
		assign SMIX_array_b1_15[15]= W1[0];
		assign SMIX_array_b2_15[15]= W2[0];
		assign SMIX_array_b3_15[15]= W3[0];
		assign SMIX_array_b0_15[16]= W0[1];
		assign SMIX_array_b1_15[16]= W1[1];
		assign SMIX_array_b2_15[16]= W2[1];
		assign SMIX_array_b3_15[16]= W3[1];
		assign SMIX_array_b0_15[17]= W0[2];
		assign SMIX_array_b1_15[17]= W1[2];
		assign SMIX_array_b2_15[17]= W2[2];
		assign SMIX_array_b3_15[17]= W3[2];
		assign SMIX_array_b0_15[18]= W0[3];
		assign SMIX_array_b1_15[18]= W1[3];
		assign SMIX_array_b2_15[18]= W2[3];
		assign SMIX_array_b3_15[18]= W3[3];
		generate 
			for (i=19;i<30;i=i+1) begin : gen_base_15_a
				assign SMIX_array_b0_15[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_15[i] = state_d_array_b1[i];
				assign SMIX_array_b2_15[i] = state_d_array_b2[i];
				assign SMIX_array_b3_15[i] = state_d_array_b3[i];
			end
			for (i=0;i<15;i=i+1) begin : gen_base_15_b
				assign SMIX_array_b0_15[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_15[i] = state_d_array_b1[i];
				assign SMIX_array_b2_15[i] = state_d_array_b2[i];
				assign SMIX_array_b3_15[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 16 -----------------------------------------------------------------------------
		assign SMIX_array_b0_16[16]= W0[0];
		assign SMIX_array_b1_16[16]= W1[0];
		assign SMIX_array_b2_16[16]= W2[0];
		assign SMIX_array_b3_16[16]= W3[0];
		assign SMIX_array_b0_16[17]= W0[1];
		assign SMIX_array_b1_16[17]= W1[1];
		assign SMIX_array_b2_16[17]= W2[1];
		assign SMIX_array_b3_16[17]= W3[1];
		assign SMIX_array_b0_16[18]= W0[2];
		assign SMIX_array_b1_16[18]= W1[2];
		assign SMIX_array_b2_16[18]= W2[2];
		assign SMIX_array_b3_16[18]= W3[2];
		assign SMIX_array_b0_16[19]= W0[3];
		assign SMIX_array_b1_16[19]= W1[3];
		assign SMIX_array_b2_16[19]= W2[3];
		assign SMIX_array_b3_16[19]= W3[3];
		generate 
			for (i=20;i<30;i=i+1) begin : gen_base_16_a
				assign SMIX_array_b0_16[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_16[i] = state_d_array_b1[i];
				assign SMIX_array_b2_16[i] = state_d_array_b2[i];
				assign SMIX_array_b3_16[i] = state_d_array_b3[i];
			end
			for (i=0;i<16;i=i+1) begin : gen_base_16_b
				assign SMIX_array_b0_16[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_16[i] = state_d_array_b1[i];
				assign SMIX_array_b2_16[i] = state_d_array_b2[i];
				assign SMIX_array_b3_16[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 17 -----------------------------------------------------------------------------
		assign SMIX_array_b0_17[17]= W0[0];
		assign SMIX_array_b1_17[17]= W1[0];
		assign SMIX_array_b2_17[17]= W2[0];
		assign SMIX_array_b3_17[17]= W3[0];
		assign SMIX_array_b0_17[18]= W0[1];
		assign SMIX_array_b1_17[18]= W1[1];
		assign SMIX_array_b2_17[18]= W2[1];
		assign SMIX_array_b3_17[18]= W3[1];
		assign SMIX_array_b0_17[19]= W0[2];
		assign SMIX_array_b1_17[19]= W1[2];
		assign SMIX_array_b2_17[19]= W2[2];
		assign SMIX_array_b3_17[19]= W3[2];
		assign SMIX_array_b0_17[20]= W0[3];
		assign SMIX_array_b1_17[20]= W1[3];
		assign SMIX_array_b2_17[20]= W2[3];
		assign SMIX_array_b3_17[20]= W3[3];
		generate 
			for (i=21;i<30;i=i+1) begin : gen_base_17_a
				assign SMIX_array_b0_17[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_17[i] = state_d_array_b1[i];
				assign SMIX_array_b2_17[i] = state_d_array_b2[i];
				assign SMIX_array_b3_17[i] = state_d_array_b3[i];
			end
			for (i=0;i<17;i=i+1) begin : gen_base_17_b
				assign SMIX_array_b0_17[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_17[i] = state_d_array_b1[i];
				assign SMIX_array_b2_17[i] = state_d_array_b2[i];
				assign SMIX_array_b3_17[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 18 -----------------------------------------------------------------------------
		assign SMIX_array_b0_18[18]= W0[0];
		assign SMIX_array_b1_18[18]= W1[0];
		assign SMIX_array_b2_18[18]= W2[0];
		assign SMIX_array_b3_18[18]= W3[0];
		assign SMIX_array_b0_18[19]= W0[1];
		assign SMIX_array_b1_18[19]= W1[1];
		assign SMIX_array_b2_18[19]= W2[1];
		assign SMIX_array_b3_18[19]= W3[1];
		assign SMIX_array_b0_18[20]= W0[2];
		assign SMIX_array_b1_18[20]= W1[2];
		assign SMIX_array_b2_18[20]= W2[2];
		assign SMIX_array_b3_18[20]= W3[2];
		assign SMIX_array_b0_18[21]= W0[3];
		assign SMIX_array_b1_18[21]= W1[3];
		assign SMIX_array_b2_18[21]= W2[3];
		assign SMIX_array_b3_18[21]= W3[3];
		generate 
			for (i=22;i<30;i=i+1) begin : gen_base_18_a
				assign SMIX_array_b0_18[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_18[i] = state_d_array_b1[i];
				assign SMIX_array_b2_18[i] = state_d_array_b2[i];
				assign SMIX_array_b3_18[i] = state_d_array_b3[i];
			end
			for (i=0;i<18;i=i+1) begin : gen_base_18_b
				assign SMIX_array_b0_18[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_18[i] = state_d_array_b1[i];
				assign SMIX_array_b2_18[i] = state_d_array_b2[i];
				assign SMIX_array_b3_18[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 19 -----------------------------------------------------------------------------
		assign SMIX_array_b0_19[19]= W0[0];
		assign SMIX_array_b1_19[19]= W1[0];
		assign SMIX_array_b2_19[19]= W2[0];
		assign SMIX_array_b3_19[19]= W3[0];
		assign SMIX_array_b0_19[20]= W0[1];
		assign SMIX_array_b1_19[20]= W1[1];
		assign SMIX_array_b2_19[20]= W2[1];
		assign SMIX_array_b3_19[20]= W3[1];
		assign SMIX_array_b0_19[21]= W0[2];
		assign SMIX_array_b1_19[21]= W1[2];
		assign SMIX_array_b2_19[21]= W2[2];
		assign SMIX_array_b3_19[21]= W3[2];
		assign SMIX_array_b0_19[22]= W0[3];
		assign SMIX_array_b1_19[22]= W1[3];
		assign SMIX_array_b2_19[22]= W2[3];
		assign SMIX_array_b3_19[22]= W3[3];
		generate 
			for (i=23;i<30 ;i=i+1) begin : gen_base_19_a
				assign SMIX_array_b0_19[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_19[i] = state_d_array_b1[i];
				assign SMIX_array_b2_19[i] = state_d_array_b2[i];
				assign SMIX_array_b3_19[i] = state_d_array_b3[i];
			end
			for (i=0;i<19 ;i=i+1) begin : gen_base_19_b
				assign SMIX_array_b0_19[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_19[i] = state_d_array_b1[i];
				assign SMIX_array_b2_19[i] = state_d_array_b2[i];
				assign SMIX_array_b3_19[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 20 -----------------------------------------------------------------------------
		assign SMIX_array_b0_20[20]= W0[0];
		assign SMIX_array_b1_20[20]= W1[0];
		assign SMIX_array_b2_20[20]= W2[0];
		assign SMIX_array_b3_20[20]= W3[0];
		assign SMIX_array_b0_20[21]= W0[1];
		assign SMIX_array_b1_20[21]= W1[1];
		assign SMIX_array_b2_20[21]= W2[1];
		assign SMIX_array_b3_20[21]= W3[1];
		assign SMIX_array_b0_20[22]= W0[2];
		assign SMIX_array_b1_20[22]= W1[2];
		assign SMIX_array_b2_20[22]= W2[2];
		assign SMIX_array_b3_20[22]= W3[2];
		assign SMIX_array_b0_20[23]= W0[3];
		assign SMIX_array_b1_20[23]= W1[3];
		assign SMIX_array_b2_20[23]= W2[3];
		assign SMIX_array_b3_20[23]= W3[3];
		generate 
			for (i=24;i<30;i=i+1) begin : gen_base_20_a
				assign SMIX_array_b0_20[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_20[i] = state_d_array_b1[i];
				assign SMIX_array_b2_20[i] = state_d_array_b2[i];
				assign SMIX_array_b3_20[i] = state_d_array_b3[i];
			end
			for (i=0;i<20;i=i+1) begin : gen_base_20_b
				assign SMIX_array_b0_20[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_20[i] = state_d_array_b1[i];
				assign SMIX_array_b2_20[i] = state_d_array_b2[i];
				assign SMIX_array_b3_20[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 21 -----------------------------------------------------------------------------
		assign SMIX_array_b0_21[21]= W0[0];
		assign SMIX_array_b1_21[21]= W1[0];
		assign SMIX_array_b2_21[21]= W2[0];
		assign SMIX_array_b3_21[21]= W3[0];
		assign SMIX_array_b0_21[22]= W0[1];
		assign SMIX_array_b1_21[22]= W1[1];
		assign SMIX_array_b2_21[22]= W2[1];
		assign SMIX_array_b3_21[22]= W3[1];
		assign SMIX_array_b0_21[23]= W0[2];
		assign SMIX_array_b1_21[23]= W1[2];
		assign SMIX_array_b2_21[23]= W2[2];
		assign SMIX_array_b3_21[23]= W3[2];
		assign SMIX_array_b0_21[24]= W0[3];
		assign SMIX_array_b1_21[24]= W1[3];
		assign SMIX_array_b2_21[24]= W2[3];
		assign SMIX_array_b3_21[24]= W3[3];
		generate 
			for (i=25;i<30;i=i+1) begin : gen_base_21_a
				assign SMIX_array_b0_21[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_21[i] = state_d_array_b1[i];
				assign SMIX_array_b2_21[i] = state_d_array_b2[i];
				assign SMIX_array_b3_21[i] = state_d_array_b3[i];
			end
			for (i=0;i<21;i=i+1) begin : gen_base_21_b
				assign SMIX_array_b0_21[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_21[i] = state_d_array_b1[i];
				assign SMIX_array_b2_21[i] = state_d_array_b2[i];
				assign SMIX_array_b3_21[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 22 -----------------------------------------------------------------------------
		assign SMIX_array_b0_22[22]= W0[0];
		assign SMIX_array_b1_22[22]= W1[0];
		assign SMIX_array_b2_22[22]= W2[0];
		assign SMIX_array_b3_22[22]= W3[0];
		assign SMIX_array_b0_22[23]= W0[1];
		assign SMIX_array_b1_22[23]= W1[1];
		assign SMIX_array_b2_22[23]= W2[1];
		assign SMIX_array_b3_22[23]= W3[1];
		assign SMIX_array_b0_22[24]= W0[2];
		assign SMIX_array_b1_22[24]= W1[2];
		assign SMIX_array_b2_22[24]= W2[2];
		assign SMIX_array_b3_22[24]= W3[2];
		assign SMIX_array_b0_22[25]= W0[3];
		assign SMIX_array_b1_22[25]= W1[3];
		assign SMIX_array_b2_22[25]= W2[3];
		assign SMIX_array_b3_22[25]= W3[3];
		generate 
			for (i=26;i<30;i=i+1) begin : gen_base_22_a
				assign SMIX_array_b0_22[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_22[i] = state_d_array_b1[i];
				assign SMIX_array_b2_22[i] = state_d_array_b2[i];
				assign SMIX_array_b3_22[i] = state_d_array_b3[i];
			end
			for (i=0;i<22;i=i+1) begin : gen_base_22_b
				assign SMIX_array_b0_22[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_22[i] = state_d_array_b1[i];
				assign SMIX_array_b2_22[i] = state_d_array_b2[i];
				assign SMIX_array_b3_22[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 23 -----------------------------------------------------------------------------
		assign SMIX_array_b0_23[23]= W0[0];
		assign SMIX_array_b1_23[23]= W1[0];
		assign SMIX_array_b2_23[23]= W2[0];
		assign SMIX_array_b3_23[23]= W3[0];
		assign SMIX_array_b0_23[24]= W0[1];
		assign SMIX_array_b1_23[24]= W1[1];
		assign SMIX_array_b2_23[24]= W2[1];
		assign SMIX_array_b3_23[24]= W3[1];
		assign SMIX_array_b0_23[25]= W0[2];
		assign SMIX_array_b1_23[25]= W1[2];
		assign SMIX_array_b2_23[25]= W2[2];
		assign SMIX_array_b3_23[25]= W3[2];
		assign SMIX_array_b0_23[26]= W0[3];
		assign SMIX_array_b1_23[26]= W1[3];
		assign SMIX_array_b2_23[26]= W2[3];
		assign SMIX_array_b3_23[26]= W3[3];
		generate 
			for (i=27;i<30;i=i+1) begin : gen_base_23_a
				assign SMIX_array_b0_23[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_23[i] = state_d_array_b1[i];
				assign SMIX_array_b2_23[i] = state_d_array_b2[i];
				assign SMIX_array_b3_23[i] = state_d_array_b3[i];
			end
			for (i=0;i<23;i=i+1) begin : gen_base_23_b
				assign SMIX_array_b0_23[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_23[i] = state_d_array_b1[i];
				assign SMIX_array_b2_23[i] = state_d_array_b2[i];
				assign SMIX_array_b3_23[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 24 -----------------------------------------------------------------------------
		assign SMIX_array_b0_24[24]= W0[0];
		assign SMIX_array_b1_24[24]= W1[0];
		assign SMIX_array_b2_24[24]= W2[0];
		assign SMIX_array_b3_24[24]= W3[0];
		assign SMIX_array_b0_24[25]= W0[1];
		assign SMIX_array_b1_24[25]= W1[1];
		assign SMIX_array_b2_24[25]= W2[1];
		assign SMIX_array_b3_24[25]= W3[1];
		assign SMIX_array_b0_24[26]= W0[2];
		assign SMIX_array_b1_24[26]= W1[2];
		assign SMIX_array_b2_24[26]= W2[2];
		assign SMIX_array_b3_24[26]= W3[2];
		assign SMIX_array_b0_24[27]= W0[3];
		assign SMIX_array_b1_24[27]= W1[3];
		assign SMIX_array_b2_24[27]= W2[3];
		assign SMIX_array_b3_24[27]= W3[3];
		generate 
			for (i=28;i<30;i=i+1) begin : gen_base_24_a
				assign SMIX_array_b0_24[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_24[i] = state_d_array_b1[i];
				assign SMIX_array_b2_24[i] = state_d_array_b2[i];
				assign SMIX_array_b3_24[i] = state_d_array_b3[i];
			end
			for (i=0;i<24;i=i+1) begin : gen_base_24_b
				assign SMIX_array_b0_24[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_24[i] = state_d_array_b1[i];
				assign SMIX_array_b2_24[i] = state_d_array_b2[i];
				assign SMIX_array_b3_24[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 25 -----------------------------------------------------------------------------
		assign SMIX_array_b0_25[25]= W0[0];
		assign SMIX_array_b1_25[25]= W1[0];
		assign SMIX_array_b2_25[25]= W2[0];
		assign SMIX_array_b3_25[25]= W3[0];
		assign SMIX_array_b0_25[26]= W0[1];
		assign SMIX_array_b1_25[26]= W1[1];
		assign SMIX_array_b2_25[26]= W2[1];
		assign SMIX_array_b3_25[26]= W3[1];
		assign SMIX_array_b0_25[27]= W0[2];
		assign SMIX_array_b1_25[27]= W1[2];
		assign SMIX_array_b2_25[27]= W2[2];
		assign SMIX_array_b3_25[27]= W3[2];
		assign SMIX_array_b0_25[28]= W0[3];
		assign SMIX_array_b1_25[28]= W1[3];
		assign SMIX_array_b2_25[28]= W2[3];
		assign SMIX_array_b3_25[28]= W3[3];
		generate 
			for (i=29;i<30;i=i+1) begin : gen_base_25_a
				assign SMIX_array_b0_25[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_25[i] = state_d_array_b1[i];
				assign SMIX_array_b2_25[i] = state_d_array_b2[i];
				assign SMIX_array_b3_25[i] = state_d_array_b3[i];
			end
			for (i=0;i<25;i=i+1) begin : gen_base_25_b
				assign SMIX_array_b0_25[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_25[i] = state_d_array_b1[i];
				assign SMIX_array_b2_25[i] = state_d_array_b2[i];
				assign SMIX_array_b3_25[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 26 -----------------------------------------------------------------------------
		assign SMIX_array_b0_26[26]= W0[0];
		assign SMIX_array_b1_26[26]= W1[0];
		assign SMIX_array_b2_26[26]= W2[0];
		assign SMIX_array_b3_26[26]= W3[0];
		assign SMIX_array_b0_26[27]= W0[1];
		assign SMIX_array_b1_26[27]= W1[1];
		assign SMIX_array_b2_26[27]= W2[1];
		assign SMIX_array_b3_26[27]= W3[1];
		assign SMIX_array_b0_26[28]= W0[2];
		assign SMIX_array_b1_26[28]= W1[2];
		assign SMIX_array_b2_26[28]= W2[2];
		assign SMIX_array_b3_26[28]= W3[2];
		assign SMIX_array_b0_26[29]= W0[3];
		assign SMIX_array_b1_26[29]= W1[3];
		assign SMIX_array_b2_26[29]= W2[3];
		assign SMIX_array_b3_26[29]= W3[3];
		generate 
			for (i=0;i<26;i=i+1) begin : gen_base_26
				assign SMIX_array_b0_26[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_26[i] = state_d_array_b1[i];
				assign SMIX_array_b2_26[i] = state_d_array_b2[i];
				assign SMIX_array_b3_26[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 27 -----------------------------------------------------------------------------
		assign SMIX_array_b0_27[27]= W0[0];
		assign SMIX_array_b1_27[27]= W1[0];
		assign SMIX_array_b2_27[27]= W2[0];
		assign SMIX_array_b3_27[27]= W3[0];
		assign SMIX_array_b0_27[28]= W0[1];
		assign SMIX_array_b1_27[28]= W1[1];
		assign SMIX_array_b2_27[28]= W2[1];
		assign SMIX_array_b3_27[28]= W3[1];
		assign SMIX_array_b0_27[29]= W0[2];
		assign SMIX_array_b1_27[29]= W1[2];
		assign SMIX_array_b2_27[29]= W2[2];
		assign SMIX_array_b3_27[29]= W3[2];
		assign SMIX_array_b0_27[ 0]= W0[3];
		assign SMIX_array_b1_27[ 0]= W1[3];
		assign SMIX_array_b2_27[ 0]= W2[3];
		assign SMIX_array_b3_27[ 0]= W3[3];
		generate 
			for (i=1;i<27;i=i+1) begin : gen_base_27
				assign SMIX_array_b0_27[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_27[i] = state_d_array_b1[i];
				assign SMIX_array_b2_27[i] = state_d_array_b2[i];
				assign SMIX_array_b3_27[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 28 -----------------------------------------------------------------------------
		assign SMIX_array_b0_28[28]= W0[0];
		assign SMIX_array_b1_28[28]= W1[0];
		assign SMIX_array_b2_28[28]= W2[0];
		assign SMIX_array_b3_28[28]= W3[0];
		assign SMIX_array_b0_28[29]= W0[1];
		assign SMIX_array_b1_28[29]= W1[1];
		assign SMIX_array_b2_28[29]= W2[1];
		assign SMIX_array_b3_28[29]= W3[1];
		assign SMIX_array_b0_28[ 0]= W0[2];
		assign SMIX_array_b1_28[ 0]= W1[2];
		assign SMIX_array_b2_28[ 0]= W2[2];
		assign SMIX_array_b3_28[ 0]= W3[2];
		assign SMIX_array_b0_28[ 1]= W0[3];
		assign SMIX_array_b1_28[ 1]= W1[3];
		assign SMIX_array_b2_28[ 1]= W2[3];
		assign SMIX_array_b3_28[ 1]= W3[3];
		generate 
			for (i=2;i<28;i=i+1) begin : gen_base_28
				assign SMIX_array_b0_28[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_28[i] = state_d_array_b1[i];
				assign SMIX_array_b2_28[i] = state_d_array_b2[i];
				assign SMIX_array_b3_28[i] = state_d_array_b3[i];
			end
		endgenerate
//-- Base: 29 -----------------------------------------------------------------------------
		assign SMIX_array_b0_29[29]= W0[0];
		assign SMIX_array_b1_29[29]= W1[0];
		assign SMIX_array_b2_29[29]= W2[0];
		assign SMIX_array_b3_29[29]= W3[0];
		assign SMIX_array_b0_29[ 0]= W0[1];
		assign SMIX_array_b1_29[ 0]= W1[1];
		assign SMIX_array_b2_29[ 0]= W2[1];
		assign SMIX_array_b3_29[ 0]= W3[1];
		assign SMIX_array_b0_29[ 1]= W0[2];
		assign SMIX_array_b1_29[ 1]= W1[2];
		assign SMIX_array_b2_29[ 1]= W2[2];
		assign SMIX_array_b3_29[ 1]= W3[2];
		assign SMIX_array_b0_29[ 2]= W0[3];
		assign SMIX_array_b1_29[ 2]= W1[3];
		assign SMIX_array_b2_29[ 2]= W2[3];
		assign SMIX_array_b3_29[ 2]= W3[3];
		generate 
			for (i=3;i<29;i=i+1) begin : gen_base_29
				assign SMIX_array_b0_29[i] = state_d_array_b0[i]; 
				assign SMIX_array_b1_29[i] = state_d_array_b1[i];
				assign SMIX_array_b2_29[i] = state_d_array_b2[i];
				assign SMIX_array_b3_29[i] = state_d_array_b3[i];
			end
		endgenerate

//--------------------------------------------------
//basic operations: 
//COLUMN, ROTATE, AES_SUB, gf_2, gf_3, gf_4, gf_5, gf_6, gf_7
//--------------------------------------------------
//COLUMN
		// uint32 COLUMN (hashState* hs, uint32 col)
		//{
		//    uint32 x = hs->Base+col;
		//    return (x<hs->Cfg->s ? x : x-hs->Cfg->s);
		//}
	  function [4:0] COLUMN; //column <30
	  		input [4:0] Base;
	  		input [4:0] col;
	  		integer temp;
	  		begin
	  			temp   = Base + col;
	  			COLUMN = (temp < 30) ? temp : (temp-30); 
	  		end
	  endfunction
	
//ROTATE
		//#define ROTATE(_s,_r)    _s->Base = COLUMN(_s,_s->Cfg->s-_r)
		function [4:0] ROTATE;
				input [4:0] Base;
				input [3:0] r;
				begin
					ROTATE = COLUMN(Base, 30-r);
				end
		endfunction

//AES_SUB
		//SBox LUT
		function	[7:0] AES_SUB;
				input [7:0] din;
				begin
					case(din)		
					   8'h00: AES_SUB=8'h63;
					   8'h01: AES_SUB=8'h7c;
					   8'h02: AES_SUB=8'h77;
					   8'h03: AES_SUB=8'h7b;
					   8'h04: AES_SUB=8'hf2;
					   8'h05: AES_SUB=8'h6b;
					   8'h06: AES_SUB=8'h6f;
					   8'h07: AES_SUB=8'hc5;
					   8'h08: AES_SUB=8'h30;
					   8'h09: AES_SUB=8'h01;
					   8'h0a: AES_SUB=8'h67;
					   8'h0b: AES_SUB=8'h2b;
					   8'h0c: AES_SUB=8'hfe;
					   8'h0d: AES_SUB=8'hd7;
					   8'h0e: AES_SUB=8'hab;
					   8'h0f: AES_SUB=8'h76;
					   8'h10: AES_SUB=8'hca;
					   8'h11: AES_SUB=8'h82;
					   8'h12: AES_SUB=8'hc9;
					   8'h13: AES_SUB=8'h7d;
					   8'h14: AES_SUB=8'hfa;
					   8'h15: AES_SUB=8'h59;
					   8'h16: AES_SUB=8'h47;
					   8'h17: AES_SUB=8'hf0;
					   8'h18: AES_SUB=8'had;
					   8'h19: AES_SUB=8'hd4;
					   8'h1a: AES_SUB=8'ha2;
					   8'h1b: AES_SUB=8'haf;
					   8'h1c: AES_SUB=8'h9c;
					   8'h1d: AES_SUB=8'ha4;
					   8'h1e: AES_SUB=8'h72;
					   8'h1f: AES_SUB=8'hc0;
					   8'h20: AES_SUB=8'hb7;
					   8'h21: AES_SUB=8'hfd;
					   8'h22: AES_SUB=8'h93;
					   8'h23: AES_SUB=8'h26;
					   8'h24: AES_SUB=8'h36;
					   8'h25: AES_SUB=8'h3f;
					   8'h26: AES_SUB=8'hf7;
					   8'h27: AES_SUB=8'hcc;
					   8'h28: AES_SUB=8'h34;
					   8'h29: AES_SUB=8'ha5;
					   8'h2a: AES_SUB=8'he5;
					   8'h2b: AES_SUB=8'hf1;
					   8'h2c: AES_SUB=8'h71;
					   8'h2d: AES_SUB=8'hd8;
					   8'h2e: AES_SUB=8'h31;
					   8'h2f: AES_SUB=8'h15;
					   8'h30: AES_SUB=8'h04;
					   8'h31: AES_SUB=8'hc7;
					   8'h32: AES_SUB=8'h23;
					   8'h33: AES_SUB=8'hc3;
					   8'h34: AES_SUB=8'h18;
					   8'h35: AES_SUB=8'h96;
					   8'h36: AES_SUB=8'h05;
					   8'h37: AES_SUB=8'h9a;
					   8'h38: AES_SUB=8'h07;
					   8'h39: AES_SUB=8'h12;
					   8'h3a: AES_SUB=8'h80;
					   8'h3b: AES_SUB=8'he2;
					   8'h3c: AES_SUB=8'heb;
					   8'h3d: AES_SUB=8'h27;
					   8'h3e: AES_SUB=8'hb2;
					   8'h3f: AES_SUB=8'h75;
					   8'h40: AES_SUB=8'h09;
					   8'h41: AES_SUB=8'h83;
					   8'h42: AES_SUB=8'h2c;
					   8'h43: AES_SUB=8'h1a;
					   8'h44: AES_SUB=8'h1b;
					   8'h45: AES_SUB=8'h6e;
					   8'h46: AES_SUB=8'h5a;
					   8'h47: AES_SUB=8'ha0;
					   8'h48: AES_SUB=8'h52;
					   8'h49: AES_SUB=8'h3b;
					   8'h4a: AES_SUB=8'hd6;
					   8'h4b: AES_SUB=8'hb3;
					   8'h4c: AES_SUB=8'h29;
					   8'h4d: AES_SUB=8'he3;
					   8'h4e: AES_SUB=8'h2f;
					   8'h4f: AES_SUB=8'h84;
					   8'h50: AES_SUB=8'h53;
					   8'h51: AES_SUB=8'hd1;
					   8'h52: AES_SUB=8'h00;
					   8'h53: AES_SUB=8'hed;
					   8'h54: AES_SUB=8'h20;
					   8'h55: AES_SUB=8'hfc;
					   8'h56: AES_SUB=8'hb1;
					   8'h57: AES_SUB=8'h5b;
					   8'h58: AES_SUB=8'h6a;
					   8'h59: AES_SUB=8'hcb;
					   8'h5a: AES_SUB=8'hbe;
					   8'h5b: AES_SUB=8'h39;
					   8'h5c: AES_SUB=8'h4a;
					   8'h5d: AES_SUB=8'h4c;
					   8'h5e: AES_SUB=8'h58;
					   8'h5f: AES_SUB=8'hcf;
					   8'h60: AES_SUB=8'hd0;
					   8'h61: AES_SUB=8'hef;
					   8'h62: AES_SUB=8'haa;
					   8'h63: AES_SUB=8'hfb;
					   8'h64: AES_SUB=8'h43;
					   8'h65: AES_SUB=8'h4d;
					   8'h66: AES_SUB=8'h33;
					   8'h67: AES_SUB=8'h85;
					   8'h68: AES_SUB=8'h45;
					   8'h69: AES_SUB=8'hf9;
					   8'h6a: AES_SUB=8'h02;
					   8'h6b: AES_SUB=8'h7f;
					   8'h6c: AES_SUB=8'h50;
					   8'h6d: AES_SUB=8'h3c;
					   8'h6e: AES_SUB=8'h9f;
					   8'h6f: AES_SUB=8'ha8;
					   8'h70: AES_SUB=8'h51;
					   8'h71: AES_SUB=8'ha3;
					   8'h72: AES_SUB=8'h40;
					   8'h73: AES_SUB=8'h8f;
					   8'h74: AES_SUB=8'h92;
					   8'h75: AES_SUB=8'h9d;
					   8'h76: AES_SUB=8'h38;
					   8'h77: AES_SUB=8'hf5;
					   8'h78: AES_SUB=8'hbc;
					   8'h79: AES_SUB=8'hb6;
					   8'h7a: AES_SUB=8'hda;
					   8'h7b: AES_SUB=8'h21;
					   8'h7c: AES_SUB=8'h10;
					   8'h7d: AES_SUB=8'hff;
					   8'h7e: AES_SUB=8'hf3;
					   8'h7f: AES_SUB=8'hd2;
					   8'h80: AES_SUB=8'hcd;
					   8'h81: AES_SUB=8'h0c;
					   8'h82: AES_SUB=8'h13;
					   8'h83: AES_SUB=8'hec;
					   8'h84: AES_SUB=8'h5f;
					   8'h85: AES_SUB=8'h97;
					   8'h86: AES_SUB=8'h44;
					   8'h87: AES_SUB=8'h17;
					   8'h88: AES_SUB=8'hc4;
					   8'h89: AES_SUB=8'ha7;
					   8'h8a: AES_SUB=8'h7e;
					   8'h8b: AES_SUB=8'h3d;
					   8'h8c: AES_SUB=8'h64;
					   8'h8d: AES_SUB=8'h5d;
					   8'h8e: AES_SUB=8'h19;
					   8'h8f: AES_SUB=8'h73;
					   8'h90: AES_SUB=8'h60;
					   8'h91: AES_SUB=8'h81;
					   8'h92: AES_SUB=8'h4f;
					   8'h93: AES_SUB=8'hdc;
					   8'h94: AES_SUB=8'h22;
					   8'h95: AES_SUB=8'h2a;
					   8'h96: AES_SUB=8'h90;
					   8'h97: AES_SUB=8'h88;
					   8'h98: AES_SUB=8'h46;
					   8'h99: AES_SUB=8'hee;
					   8'h9a: AES_SUB=8'hb8;
					   8'h9b: AES_SUB=8'h14;
					   8'h9c: AES_SUB=8'hde;
					   8'h9d: AES_SUB=8'h5e;
					   8'h9e: AES_SUB=8'h0b;
					   8'h9f: AES_SUB=8'hdb;
					   8'ha0: AES_SUB=8'he0;
					   8'ha1: AES_SUB=8'h32;
					   8'ha2: AES_SUB=8'h3a;
					   8'ha3: AES_SUB=8'h0a;
					   8'ha4: AES_SUB=8'h49;
					   8'ha5: AES_SUB=8'h06;
					   8'ha6: AES_SUB=8'h24;
					   8'ha7: AES_SUB=8'h5c;
					   8'ha8: AES_SUB=8'hc2;
					   8'ha9: AES_SUB=8'hd3;
					   8'haa: AES_SUB=8'hac;
					   8'hab: AES_SUB=8'h62;
					   8'hac: AES_SUB=8'h91;
					   8'had: AES_SUB=8'h95;
					   8'hae: AES_SUB=8'he4;
					   8'haf: AES_SUB=8'h79;
					   8'hb0: AES_SUB=8'he7;
					   8'hb1: AES_SUB=8'hc8;
					   8'hb2: AES_SUB=8'h37;
					   8'hb3: AES_SUB=8'h6d;
					   8'hb4: AES_SUB=8'h8d;
					   8'hb5: AES_SUB=8'hd5;
					   8'hb6: AES_SUB=8'h4e;
					   8'hb7: AES_SUB=8'ha9;
					   8'hb8: AES_SUB=8'h6c;
					   8'hb9: AES_SUB=8'h56;
					   8'hba: AES_SUB=8'hf4;
					   8'hbb: AES_SUB=8'hea;
					   8'hbc: AES_SUB=8'h65;
					   8'hbd: AES_SUB=8'h7a;
					   8'hbe: AES_SUB=8'hae;
					   8'hbf: AES_SUB=8'h08;
					   8'hc0: AES_SUB=8'hba;
					   8'hc1: AES_SUB=8'h78;
					   8'hc2: AES_SUB=8'h25;
					   8'hc3: AES_SUB=8'h2e;
					   8'hc4: AES_SUB=8'h1c;
					   8'hc5: AES_SUB=8'ha6;
					   8'hc6: AES_SUB=8'hb4;
					   8'hc7: AES_SUB=8'hc6;
					   8'hc8: AES_SUB=8'he8;
					   8'hc9: AES_SUB=8'hdd;
					   8'hca: AES_SUB=8'h74;
					   8'hcb: AES_SUB=8'h1f;
					   8'hcc: AES_SUB=8'h4b;
					   8'hcd: AES_SUB=8'hbd;
					   8'hce: AES_SUB=8'h8b;
					   8'hcf: AES_SUB=8'h8a;
					   8'hd0: AES_SUB=8'h70;
					   8'hd1: AES_SUB=8'h3e;
					   8'hd2: AES_SUB=8'hb5;
					   8'hd3: AES_SUB=8'h66;
					   8'hd4: AES_SUB=8'h48;
					   8'hd5: AES_SUB=8'h03;
					   8'hd6: AES_SUB=8'hf6;
					   8'hd7: AES_SUB=8'h0e;
					   8'hd8: AES_SUB=8'h61;
					   8'hd9: AES_SUB=8'h35;
					   8'hda: AES_SUB=8'h57;
					   8'hdb: AES_SUB=8'hb9;
					   8'hdc: AES_SUB=8'h86;
					   8'hdd: AES_SUB=8'hc1;
					   8'hde: AES_SUB=8'h1d;
					   8'hdf: AES_SUB=8'h9e;
					   8'he0: AES_SUB=8'he1;
					   8'he1: AES_SUB=8'hf8;
					   8'he2: AES_SUB=8'h98;
					   8'he3: AES_SUB=8'h11;
					   8'he4: AES_SUB=8'h69;
					   8'he5: AES_SUB=8'hd9;
					   8'he6: AES_SUB=8'h8e;
					   8'he7: AES_SUB=8'h94;
					   8'he8: AES_SUB=8'h9b;
					   8'he9: AES_SUB=8'h1e;
					   8'hea: AES_SUB=8'h87;
					   8'heb: AES_SUB=8'he9;
					   8'hec: AES_SUB=8'hce;
					   8'hed: AES_SUB=8'h55;
					   8'hee: AES_SUB=8'h28;
					   8'hef: AES_SUB=8'hdf;
					   8'hf0: AES_SUB=8'h8c;
					   8'hf1: AES_SUB=8'ha1;
					   8'hf2: AES_SUB=8'h89;
					   8'hf3: AES_SUB=8'h0d;
					   8'hf4: AES_SUB=8'hbf;
					   8'hf5: AES_SUB=8'he6;
					   8'hf6: AES_SUB=8'h42;
					   8'hf7: AES_SUB=8'h68;
					   8'hf8: AES_SUB=8'h41;
					   8'hf9: AES_SUB=8'h99;
					   8'hfa: AES_SUB=8'h2d;
					   8'hfb: AES_SUB=8'h0f;
					   8'hfc: AES_SUB=8'hb0;
					   8'hfd: AES_SUB=8'h54;
					   8'hfe: AES_SUB=8'hbb;
					   8'hff: AES_SUB=8'h16;
					endcase
				end
		endfunction

//gf_1(x)
		//#define gf_1(x)   (x)           
    function [7:0] gf_1;
  		input [7:0] x;
  		begin
  			gf_1 = x;
  		end
  	endfunction
  	
//gf_2(x)
		//#define gf_2(x)   ((x<<1) ^ (((x>>7) & 1) * POLY))
		function [7:0] gf_2;
			input [7:0] x;
			begin
				gf_2 = x[7]? ((x<<1) ^ 9'b100011011) : (x<<1);
			end
		endfunction

//gf_3(x)
		//#define gf_3(x)   (gf_2(x) ^ gf_1(x))
		function [7:0] gf_3;
			input [7:0] x;
			integer gf_2_value; 
			begin
        gf_2_value = x[7]? ((x<<1) ^ 9'b100011011) : (x<<1);
      	gf_3       = gf_2_value^x;
			end
		endfunction
	
//gf_4(x)
		//#define gf_4(x)   (gf_2(gf_2(x)))
		function [7:0] gf_4;
			input [7:0] x;
			integer gf_2_value;
			begin
	      gf_2_value = x[7]? ((x<<1) ^ 9'b100011011) : (x<<1);
	      gf_4       = gf_2_value[7]? (gf_2_value<<1) ^ 9'b100011011 : (gf_2_value<<1);
			end
		endfunction

//gf_5(x)
		//#define gf_5(x)   (gf_4(x) ^ gf_1(x))
		function [7:0] gf_5;
			input [7:0] x;
			integer gf_4_value, gf_2_value;
			begin
				gf_2_value = x[7]? ((x<<1) ^ 9'b100011011) : (x<<1);
				gf_4_value = gf_2_value[7]? (gf_2_value<<1) ^ 9'b100011011 : (gf_2_value<<1);
				gf_5       = gf_4_value ^ x;
			end
		endfunction
		
//gf_6(x)
		//#define gf_6(x)   (gf_4(x) ^ gf_2(x))
		function [7:0] gf_6;
			input [7:0] x;
			integer gf_4_value, gf_2_value;
			begin
				gf_2_value = x[7]? ((x<<1) ^ 9'b100011011) : (x<<1);
				gf_4_value = gf_2_value[7]? (gf_2_value<<1) ^ 9'b100011011 : (gf_2_value<<1);
				gf_6       = gf_4_value ^ gf_2_value;
			end
		endfunction		
		
//gf_7(x)
		//(gf_4(x) ^ gf_2(x) ^ gf_1(x))
		function [7:0] gf_7;
			input [7:0] x;
			integer gf_4_value, gf_2_value;
			begin
				gf_2_value = x[7]? ((x<<1) ^ 9'b100011011) : (x<<1);
				gf_4_value = gf_2_value[7]? (gf_2_value<<1) ^ 9'b100011011 : (gf_2_value<<1);
				gf_7       =  gf_4_value ^ gf_2_value ^ x;
			end
		endfunction		
 
 
endmodule