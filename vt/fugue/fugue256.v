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

module fugue256_round(
											hs_stat_i,
											hs_base_i,
											message_i,
											mod_sel_i,
											hs_stat_o,
											hs_base_o);
input  [959:0] hs_stat_i;
input  [  4:0] hs_base_i;
input  [ 31:0] message_i;
input  [  2:0] mod_sel_i;//UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;					
output [959:0] hs_stat_o;
output [  4:0] hs_base_o;

wire   [  2:0] mod_sel_i;
wire   [959:0] hs_stat_i;
wire   [  4:0] hs_base_i;
wire   [959:0] hs_stat_o;
wire   [  4:0] hs_base_o;

//fugue-256 configuration parameters
parameter n =  8,
					s = 30,
					k =  2,
					r =  5,
					t = 13;

parameter UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;					
//---------------------------------------------
//Process Steps   :  0      1       2      3
//---------------------------------------------
//(mod:0)UPDATEa  : TIX  ->ROR3 ->CMIX ->SMIX
//(mod:6)UPDATEb  : N/A    ROR3 ->CMIX ->SMIX
//(mod:4)FINAL_G1 : N/A    ROR3 ->CMIX ->SMIX
//(mod:1)FINAL_G2a: XOR15->N/A  ->ROR15->SMIX
//(mod:5)FINAL_G2b: XOR16->N/A  ->ROR14->SMIX     
//(mod:2)LAST     : XOR15->N/A  ->N/A  ->N/A     
//(mod:3)DirectOut: N/A  ->N/A  ->N/A  ->N/A     
//---------------------------------------------

wire [959:0] step0_stat,step1_stat,step2_stat,step3_stat;
wire [  4:0] step0_base,step1_base,step2_base,step3_base;

//easy debug
wire [ 31:0] step0_stat_array[0:29];
wire [ 31:0] step1_stat_array[0:29];
wire [ 31:0] step2_stat_array[0:29];
wire [ 31:0] step3_stat_array[0:29];

genvar i;
generate
	for(i=0;i<30;i=i+1) begin : gen_step
		assign step0_stat_array[i] = step0_stat[(i+1)*32-1:i*32];	
		assign step1_stat_array[i] = step1_stat[(i+1)*32-1:i*32];	
		assign step2_stat_array[i] = step2_stat[(i+1)*32-1:i*32];	
		assign step3_stat_array[i] = step3_stat[(i+1)*32-1:i*32];	
	end    
endgenerate

//----------------------------------------------------------------------------
//--                 function modules instantiation
//----------------------------------------------------------------------------
//for update step 0
wire [959:0] TIX;
fugue256_tix U_tix (
								    .Base        (hs_base_i),
								    .state_d_long(hs_stat_i),
								    .sc          (message_i),
								    //output
								    .TIX         (TIX)	
									 );
//for update step 2
wire [959:0] CMIX_0;
fugue256_cmix U0_cmix(
										.Base         (step1_base),
										.state_d_long (step1_stat),
										//output
										.CMIX         (CMIX_0)
										);
//for update step 3					
wire [959:0] SMIX_0;					
fugue256_smix U0_smix(
										.Base        (step2_base),
										.state_d_long(step2_stat),
										//output        
										.SMIX        (SMIX_0)
										);
//for final
wire [959:0] Col_Xor1516_0;
wire [959:0] Col_Xor1516_1;

wire sel_final_g2;//if sel==1, then Col_XOR15, ROR15, otherwire, go through Col_XOR16, ROR14
assign sel_final_g2 = (mod_sel_i == FINAL_G2a|mod_sel_i==LAST) ? 1 : 0;

fugue256_col_xor1516 U0_colxor(
														 .Base        (hs_base_i),
														 .sel         (sel_final_g2),
														 .state_d_long(hs_stat_i),
														 //output
														 .Col_Xor1516 (Col_Xor1516_0)
														 );

//step0: TIX or XOR15-------------------------
	assign step0_stat = mod_sel_i==UPDATEa   ? TIX : 
											mod_sel_i==FINAL_G2a ? Col_Xor1516_0:   
											mod_sel_i==FINAL_G2b ? Col_Xor1516_0:   
										  mod_sel_i==LAST      ? Col_Xor1516_0: 
										  							 		   	 hs_stat_i;	 
																 
	assign step0_base = hs_base_i;
	
//step1: ROR3 -------------------------
	assign step1_stat = step0_stat;
	assign step1_base = (mod_sel_i==UPDATEa|mod_sel_i==UPDATEb|mod_sel_i==FINAL_G1) ? ROTATE(step0_base, 3): step0_base;	
	
//step2: CMIX or ROR15 -------------------------
  assign step2_stat = (mod_sel_i==UPDATEa|mod_sel_i==UPDATEb|mod_sel_i==FINAL_G1) ? CMIX_0 : step1_stat;	
  assign step2_base = mod_sel_i==FINAL_G2a  ? ROTATE(step1_base, 15) : 
  										mod_sel_i==FINAL_G2b  ?	ROTATE(step1_base, 14) : step1_base;

//step3: SMIX -------------------------
  assign step3_stat = (mod_sel_i==UPDATEa|mod_sel_i==UPDATEb|mod_sel_i==FINAL_G2a|mod_sel_i==FINAL_G2b|mod_sel_i==FINAL_G1 )? SMIX_0 : step2_stat;
  assign step3_base = step2_base;
  assign hs_stat_o  = step3_stat;
  assign hs_base_o  = step3_base;


    //COLUMN
   	  function [4:0] COLUMN; //column <30
   	  		input [4:0] Base;
   	  		input [4:0] col;
   	  		//wire  [5:0] temp;
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

endmodule







