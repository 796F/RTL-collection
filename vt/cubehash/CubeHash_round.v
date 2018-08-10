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
module CubeHash_ROUND(Rin, 
                      Rout);

input  [1023:0] Rin;
output [1023:0] Rout;

wire [31:0] Rin0, Rin1, Rin2, Rin3, Rin4, Rin5, Rin6, Rin7; 
wire [31:0] Rin8, Rin9, Rin10, Rin11, Rin12, Rin13, Rin14, Rin15;
wire [31:0] Rin16, Rin17, Rin18, Rin19, Rin20, Rin21, Rin22, Rin23;
wire [31:0] Rin24, Rin25, Rin26, Rin27, Rin28, Rin29, Rin30, Rin31;
wire [31:0] rot7_0, rot7_1, rot7_2, rot7_3, rot7_4, rot7_5, rot7_6, rot7_7; 
wire [31:0] rot7_8, rot7_9, rot7_10, rot7_11, rot7_12, rot7_13, rot7_14, rot7_15;
wire [31:0] add0_16, add0_17, add0_18, add0_19, add0_20, add0_21, add0_22, add0_23;
wire [31:0] add0_24, add0_25, add0_26, add0_27, add0_28, add0_29, add0_30, add0_31;
wire [31:0] add1_16, add1_17, add1_18, add1_19, add1_20, add1_21, add1_22, add1_23;
wire [31:0] add1_24, add1_25, add1_26, add1_27, add1_28, add1_29, add1_30, add1_31;
wire [31:0] rot11_0, rot11_1, rot11_2, rot11_3, rot11_4, rot11_5, rot11_6, rot11_7; 
wire [31:0] rot11_8, rot11_9, rot11_10, rot11_11, rot11_12, rot11_13, rot11_14, rot11_15;
wire [31:0] swap0_0, swap0_1, swap0_2, swap0_3, swap0_4, swap0_5, swap0_6, swap0_7; 
wire [31:0] swap0_8, swap0_9, swap0_10, swap0_11, swap0_12, swap0_13, swap0_14, swap0_15;
wire [31:0] swap1_16, swap1_17, swap1_18, swap1_19, swap1_20, swap1_21, swap1_22, swap1_23;
wire [31:0] swap1_24, swap1_25, swap1_26, swap1_27, swap1_28, swap1_29, swap1_30, swap1_31;
wire [31:0] swap2_0, swap2_1, swap2_2, swap2_3, swap2_4, swap2_5, swap2_6, swap2_7; 
wire [31:0] swap2_8, swap2_9, swap2_10, swap2_11, swap2_12, swap2_13, swap2_14, swap2_15;
wire [31:0] swap3_16, swap3_17, swap3_18, swap3_19, swap3_20, swap3_21, swap3_22, swap3_23;
wire [31:0] swap3_24, swap3_25, swap3_26, swap3_27, swap3_28, swap3_29, swap3_30, swap3_31;
wire [31:0] Xor0_0, Xor0_1, Xor0_2, Xor0_3, Xor0_4, Xor0_5, Xor0_6, Xor0_7; 
wire [31:0] Xor0_8, Xor0_9, Xor0_10, Xor0_11, Xor0_12, Xor0_13, Xor0_14, Xor0_15;
wire [31:0] Xor1_0, Xor1_1, Xor1_2, Xor1_3, Xor1_4, Xor1_5, Xor1_6, Xor1_7; 
wire [31:0] Xor1_8, Xor1_9, Xor1_10, Xor1_11, Xor1_12, Xor1_13, Xor1_14, Xor1_15;

assign Rin0 = Rin[1023:992];
assign Rin1 = Rin[991:960];
assign Rin2 = Rin[959:928];
assign Rin3 = Rin[927:896];
assign Rin4 = Rin[895:864];
assign Rin5 = Rin[863:832];
assign Rin6 = Rin[831:800];
assign Rin7 = Rin[799:768];
assign Rin8 = Rin[767:736];
assign Rin9 = Rin[735:704];
assign Rin10 = Rin[703:672];
assign Rin11 = Rin[671:640];
assign Rin12 = Rin[639:608];
assign Rin13 = Rin[607:576];
assign Rin14 = Rin[575:544];
assign Rin15 = Rin[543:512];
assign Rin16 = Rin[511:480];
assign Rin17 = Rin[479:448];
assign Rin18 = Rin[447:416];
assign Rin19 = Rin[415:384];
assign Rin20 = Rin[383:352];
assign Rin21 = Rin[351:320];
assign Rin22 = Rin[319:288];
assign Rin23 = Rin[287:256];
assign Rin24 = Rin[255:224];
assign Rin25 = Rin[223:192];
assign Rin26 = Rin[191:160];
assign Rin27 = Rin[159:128];
assign Rin28 = Rin[127:96];
assign Rin29 = Rin[95:64];
assign Rin30 = Rin[63:32];
assign Rin31 = Rin[31:0];

assign Rout = {Xor1_0, Xor1_1, Xor1_2, Xor1_3, Xor1_4, Xor1_5, Xor1_6, Xor1_7,
   Xor1_8, Xor1_9, Xor1_10, Xor1_11, Xor1_12, Xor1_13, Xor1_14, Xor1_15,
   swap3_16, swap3_17, swap3_18, swap3_19, swap3_20, swap3_21, swap3_22, swap3_23, swap3_24,
   swap3_25, swap3_26, swap3_27, swap3_28, swap3_29, swap3_30, swap3_31};

assign add0_16 = Rin0 + Rin16;
assign add0_17 = Rin1 + Rin17;
assign add0_18 = Rin2 + Rin18;
assign add0_19 = Rin3 + Rin19;
assign add0_20 = Rin4 + Rin20;
assign add0_21 = Rin5 + Rin21;
assign add0_22 = Rin6 + Rin22;
assign add0_23 = Rin7 + Rin23;
assign add0_24 = Rin8 + Rin24;
assign add0_25 = Rin9 + Rin25;
assign add0_26 = Rin10 + Rin26;
assign add0_27 = Rin11 + Rin27;
assign add0_28 = Rin12 + Rin28;
assign add0_29 = Rin13 + Rin29;
assign add0_30 = Rin14 + Rin30;
assign add0_31 = Rin15 + Rin31;

assign rot7_0 = {Rin0[24:0],Rin0[31:25]};
assign rot7_1 = {Rin1[24:0],Rin1[31:25]};
assign rot7_2 = {Rin2[24:0],Rin2[31:25]};
assign rot7_3 = {Rin3[24:0],Rin3[31:25]};
assign rot7_4 = {Rin4[24:0],Rin4[31:25]};
assign rot7_5 = {Rin5[24:0],Rin5[31:25]};
assign rot7_6 = {Rin6[24:0],Rin6[31:25]};
assign rot7_7 = {Rin7[24:0],Rin7[31:25]};
assign rot7_8 = {Rin8[24:0],Rin8[31:25]};
assign rot7_9 = {Rin9[24:0],Rin9[31:25]};
assign rot7_10 = {Rin10[24:0],Rin10[31:25]};
assign rot7_11 = {Rin11[24:0],Rin11[31:25]};
assign rot7_12 = {Rin12[24:0],Rin12[31:25]};
assign rot7_13 = {Rin13[24:0],Rin13[31:25]};
assign rot7_14 = {Rin14[24:0],Rin14[31:25]};
assign rot7_15 = {Rin15[24:0],Rin15[31:25]};

assign swap0_0 = rot7_8;
assign swap0_1 = rot7_9;
assign swap0_2 = rot7_10;
assign swap0_3 = rot7_11;
assign swap0_4 = rot7_12;
assign swap0_5 = rot7_13;
assign swap0_6 = rot7_14;
assign swap0_7 = rot7_15;
assign swap0_8 = rot7_0;
assign swap0_9 = rot7_1;
assign swap0_10 = rot7_2;
assign swap0_11 = rot7_3;
assign swap0_12 = rot7_4;
assign swap0_13 = rot7_5;
assign swap0_14 = rot7_6;
assign swap0_15 = rot7_7;

assign Xor0_0 = swap0_0 ^ add0_16; 
assign Xor0_1 = swap0_1 ^ add0_17; 
assign Xor0_2 = swap0_2 ^ add0_18; 
assign Xor0_3 = swap0_3 ^ add0_19; 
assign Xor0_4 = swap0_4 ^ add0_20; 
assign Xor0_5 = swap0_5 ^ add0_21; 
assign Xor0_6 = swap0_6 ^ add0_22; 
assign Xor0_7 = swap0_7 ^ add0_23; 
assign Xor0_8 = swap0_8 ^ add0_24; 
assign Xor0_9 = swap0_9 ^ add0_25; 
assign Xor0_10 = swap0_10 ^ add0_26; 
assign Xor0_11 = swap0_11 ^ add0_27; 
assign Xor0_12 = swap0_12 ^ add0_28; 
assign Xor0_13 = swap0_13 ^ add0_29; 
assign Xor0_14 = swap0_14 ^ add0_30; 
assign Xor0_15 = swap0_15 ^ add0_31; 

assign swap1_16 = add0_18;
assign swap1_17 = add0_19;
assign swap1_18 = add0_16;
assign swap1_19 = add0_17;
assign swap1_20 = add0_22;
assign swap1_21 = add0_23;
assign swap1_22 = add0_20;
assign swap1_23 = add0_21;
assign swap1_24 = add0_26;
assign swap1_25 = add0_27;
assign swap1_26 = add0_24;
assign swap1_27 = add0_25;
assign swap1_28 = add0_30;
assign swap1_29 = add0_31;
assign swap1_30 = add0_28;
assign swap1_31 = add0_29;

assign add1_16 = Xor0_0 + swap1_16;
assign add1_17 = Xor0_1 + swap1_17;
assign add1_18 = Xor0_2 + swap1_18;
assign add1_19 = Xor0_3 + swap1_19;
assign add1_20 = Xor0_4 + swap1_20;
assign add1_21 = Xor0_5 + swap1_21;
assign add1_22 = Xor0_6 + swap1_22;
assign add1_23 = Xor0_7 + swap1_23;
assign add1_24 = Xor0_8 + swap1_24;
assign add1_25 = Xor0_9 + swap1_25;
assign add1_26 = Xor0_10 + swap1_26;
assign add1_27 = Xor0_11 + swap1_27;
assign add1_28 = Xor0_12 + swap1_28;
assign add1_29 = Xor0_13 + swap1_29;
assign add1_30 = Xor0_14 + swap1_30;
assign add1_31 = Xor0_15 + swap1_31;

assign rot11_0 = {Xor0_0[20:0],Xor0_0[31:21]};
assign rot11_1 = {Xor0_1[20:0],Xor0_1[31:21]};
assign rot11_2 = {Xor0_2[20:0],Xor0_2[31:21]};
assign rot11_3 = {Xor0_3[20:0],Xor0_3[31:21]};
assign rot11_4 = {Xor0_4[20:0],Xor0_4[31:21]};
assign rot11_5 = {Xor0_5[20:0],Xor0_5[31:21]};
assign rot11_6 = {Xor0_6[20:0],Xor0_6[31:21]};
assign rot11_7 = {Xor0_7[20:0],Xor0_7[31:21]};
assign rot11_8 = {Xor0_8[20:0],Xor0_8[31:21]};
assign rot11_9 = {Xor0_9[20:0],Xor0_9[31:21]};
assign rot11_10 = {Xor0_10[20:0],Xor0_10[31:21]};
assign rot11_11 = {Xor0_11[20:0],Xor0_11[31:21]};
assign rot11_12 = {Xor0_12[20:0],Xor0_12[31:21]};
assign rot11_13 = {Xor0_13[20:0],Xor0_13[31:21]};
assign rot11_14 = {Xor0_14[20:0],Xor0_14[31:21]};
assign rot11_15 = {Xor0_15[20:0],Xor0_15[31:21]};

assign swap2_0 = rot11_4;
assign swap2_1 = rot11_5;
assign swap2_2 = rot11_6;
assign swap2_3 = rot11_7;
assign swap2_4 = rot11_0;
assign swap2_5 = rot11_1;
assign swap2_6 = rot11_2;
assign swap2_7 = rot11_3;
assign swap2_8 = rot11_12;
assign swap2_9 = rot11_13;
assign swap2_10 = rot11_14;
assign swap2_11 = rot11_15;
assign swap2_12 = rot11_8;
assign swap2_13 = rot11_9;
assign swap2_14 = rot11_10;
assign swap2_15 = rot11_11;

assign Xor1_0 = swap2_0 ^ add1_16; 
assign Xor1_1 = swap2_1 ^ add1_17; 
assign Xor1_2 = swap2_2 ^ add1_18; 
assign Xor1_3 = swap2_3 ^ add1_19; 
assign Xor1_4 = swap2_4 ^ add1_20; 
assign Xor1_5 = swap2_5 ^ add1_21; 
assign Xor1_6 = swap2_6 ^ add1_22; 
assign Xor1_7 = swap2_7 ^ add1_23; 
assign Xor1_8 = swap2_8 ^ add1_24; 
assign Xor1_9 = swap2_9 ^ add1_25; 
assign Xor1_10 = swap2_10 ^ add1_26; 
assign Xor1_11 = swap2_11 ^ add1_27; 
assign Xor1_12 = swap2_12 ^ add1_28; 
assign Xor1_13 = swap2_13 ^ add1_29; 
assign Xor1_14 = swap2_14 ^ add1_30; 
assign Xor1_15 = swap2_15 ^ add1_31; 

assign swap3_16 = add1_17;
assign swap3_17 = add1_16;
assign swap3_18 = add1_19;
assign swap3_19 = add1_18;
assign swap3_20 = add1_21;
assign swap3_21 = add1_20;
assign swap3_22 = add1_23;
assign swap3_23 = add1_22;
assign swap3_24 = add1_25;
assign swap3_25 = add1_24;
assign swap3_26 = add1_27;
assign swap3_27 = add1_26;
assign swap3_28 = add1_29;
assign swap3_29 = add1_28;
assign swap3_30 = add1_31;
assign swap3_31 = add1_30;

endmodule


