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

module fugue_top(
   input clk,
   input rst_n,
   input init,
   input load,
   input fetch,
   input [15:0] idata, 
   output ack,
   output [15:0] odata
);   

parameter W = 16;//IO-size
parameter B = W/8;//number of bytes
parameter R = 32/W;//number of transfers per 32-bit block
                                            
//for FSM                                   
parameter IDLE			= 4'd0,                 
					LOAD			= 4'd1,                 
					HASH     	= 4'd2,                 
					FINAL     = 4'd3,                 
					FETCH   	= 4'd4,
					WAIT1			= 4'd5;

parameter UPDATEa   = 3'd0, 
					FINAL_G2a = 3'd1, 
					LAST      = 3'd2, 
					DIRECT    = 3'd3, 
					FINAL_G1  = 3'd4, 
					FINAL_G2b = 3'd5, 
					UPDATEb   = 3'd6;					

wire         fetch_ack;                             
wire         load_ack;                              
reg          fetch_ack_reg;                         
reg          load_ack_reg;                          
reg  [W-1:0] odata_reg;                     
wire [W-1:0] idata_reverse_byte;
reg  [  3:0] c_state;                         
reg  [  3:0] n_state;                         
reg  [  6:0] din_cnt;//support IO-size of 8bit
//fugue256 core function instantiation
//interconnections
reg  [959:0] hs_stat_i;
reg  [  4:0] hs_base_i;
wire [ 31:0] iblock;
reg  [  2:0] mod_sel_i;//UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;					     
wire [959:0] hs_stat_o;
wire [  4:0] hs_base_o;
reg  [W-1:0] iarray [0:(R-1)];//used for better representation
wire [W-1:0] oarray [0:(960/W-1)];//used for better representation

reg          fetch_del;
reg          fetch_del1;
wire         fetch_1cyc;
wire         fetch_1cyc_del;
wire         busy_final;//busy during the finalization stage
reg          start2fin;//from FETCH first high to the end of finalization
reg  [5:0]   cnt_busy;//the finalization stage can be done in 37 cycles (10*1<G1>+26*1<G2>+1<Last_step>)

fugue256_round U_fugue256_round(
																.hs_stat_i(hs_stat_i),
																.hs_base_i(hs_base_i),
																.message_i(iblock),
																.mod_sel_i(mod_sel_i),
																.hs_stat_o(hs_stat_o),
																.hs_base_o(hs_base_o)
																);

assign ack 					 = fetch_ack_reg|load_ack_reg;//ori master_ack;	

integer i,j;
genvar k;
generate
	for( k=0; k < B ; k = k + 1) begin: BYTE_REVERSE
		assign idata_reverse_byte[(8*(k+1)-1):(8*k)] = idata[(8*(B-k)-1):(8*(B-k-1))];
		assign odata[(8*(k+1)-1):(8*k)] = odata_reg[(8*(B-k)-1):(8*(B-k-1))];  
	end
endgenerate

//convert iarray to iblock
generate
	for (k=0; k < R; k = k+1) begin: gen_iblock
		assign iblock[(W*(k+1)-1):(W*k)] = iarray[k];
	end
endgenerate

generate
	for (k=0; k < 960/W; k = k+1) begin: gen_oarray
		assign oarray[k] = hs_stat_o[(W*(k+1)-1):(W*k)];
	end
endgenerate

//-------------------------------------------------------------------------
//count the number of load and fetch
always @ (posedge clk or negedge rst_n)
begin
	if (~rst_n) begin
		din_cnt <= 0;
	end
	else if (c_state == LOAD) begin
		if(din_cnt == (R-1)) begin//R=2 if W= 16 for 32 bit block data;
			din_cnt <= 0;
		end
		else begin
			din_cnt <= busy_final? din_cnt : din_cnt + 1;
		end
	end
	else if (c_state == /*FETCH*/WAIT1) begin
		if (din_cnt == 15) begin
			din_cnt <= 0;
		end
		else begin
			din_cnt <= busy_final? din_cnt : din_cnt + 1;
		end
	end
	else begin
		din_cnt <= din_cnt;
	end
end

//-------------------------------------------------------------------------
//generate FETCH and LOAD ACK signals
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		load_ack_reg  <= 0;
		fetch_ack_reg <= 0;
	end
	else if(c_state == LOAD) begin
		load_ack_reg  <= busy_final? 0 : 1;
		fetch_ack_reg <= fetch_ack_reg;
	end
	else if(c_state == /*FETCH*/WAIT1) begin
		load_ack_reg  <= load_ack_reg;
		fetch_ack_reg <= busy_final? 0 : 1;
	end
	else begin
		load_ack_reg  <= 0;
		fetch_ack_reg <= 0;
	end
end

//-------------------------------------------------------------------------
//generate finalization busy signal

assign fetch_1cyc     = fetch     & (~fetch_del );
assign fetch_1cyc_del = fetch_del & (~fetch_del1);
//capature fetch pulse 
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		fetch_del <= 0;
		fetch_del1 <= 0;
	end
	else begin
		fetch_del <= fetch;
		fetch_del1 <= fetch_del;
	end
end

//counter for finalization stage
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		cnt_busy <= 0;
	end
	else if (init) begin /*reset this counter for each time of hashing*/
		cnt_busy <= 0;
	end
	else if (fetch) begin
		if (cnt_busy == 45) begin /* 37 should be the Min. time for finalization*/
			cnt_busy <= 45;//keep value after reaching 30
		end
		else begin
			cnt_busy <= cnt_busy + 1;
		end
	end
	else begin
		cnt_busy <= cnt_busy;
	end
end

//generate the busy signal for the finalization
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		start2fin <= 0;
	end
	else if(fetch_1cyc) begin
		start2fin <= 1;
	end
	else if(cnt_busy == 37) begin
		start2fin <= 0;
	end
	else begin
		start2fin <= start2fin;
	end
end

assign busy_final = start2fin |fetch_1cyc;

//-------------------------------------------------------------------------
//load input msg
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
			for (j=0;j<R;j=j+1) begin
				iarray[j]		<= 0;
			end
	end
	else if (c_state == LOAD ) begin
		       if(din_cnt ==  0) iarray[ 0] <= idata_reverse_byte;
  		else if(din_cnt ==  1) iarray[ 1] <= idata_reverse_byte;
	end
	else begin
			for (j=0;j<R;j=j+1) begin
				iarray[j]		<= iarray[j];
			end
	end
end

//-------------------------------------------------------------------------
//fetch output digest
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		odata_reg <= 0;
	end
	else if (c_state == /*FETCH*/WAIT1 && (~busy_final)) begin
		       if(din_cnt ==  0) odata_reg <= (hs_base_o== 0)? oarray[ 1*2+0] :
		       															  (hs_base_o== 1)? oarray[ 2*2+0] :
		       															  (hs_base_o== 2)? oarray[ 3*2+0] :
		       															  (hs_base_o== 3)? oarray[ 4*2+0] :
		       															  (hs_base_o== 4)? oarray[ 5*2+0] :
		       															  (hs_base_o== 5)? oarray[ 6*2+0] :
		       															  (hs_base_o== 6)? oarray[ 7*2+0] :
		       															  (hs_base_o== 7)? oarray[ 8*2+0] :
		       															  (hs_base_o== 8)? oarray[ 9*2+0] :
		       															  (hs_base_o== 9)? oarray[10*2+0] :
		       															  (hs_base_o==10)? oarray[11*2+0] :
		       															  (hs_base_o==11)? oarray[12*2+0] :
		       															  (hs_base_o==12)? oarray[13*2+0] :
		       															  (hs_base_o==13)? oarray[14*2+0] :
		       															  (hs_base_o==14)? oarray[15*2+0] :
		       															  (hs_base_o==15)? oarray[16*2+0] :
		       															  (hs_base_o==16)? oarray[17*2+0] :
		       															  (hs_base_o==17)? oarray[18*2+0] :
		       															  (hs_base_o==18)? oarray[19*2+0] :
		       															  (hs_base_o==19)? oarray[20*2+0] :
		       															  (hs_base_o==20)? oarray[21*2+0] :
		       															  (hs_base_o==21)? oarray[22*2+0] :
		       															  (hs_base_o==22)? oarray[23*2+0] :
		       															  (hs_base_o==23)? oarray[24*2+0] :
		       															  (hs_base_o==24)? oarray[25*2+0] :
		       															  (hs_base_o==25)? oarray[26*2+0] :
		       															  (hs_base_o==26)? oarray[27*2+0] :
		       															  (hs_base_o==27)? oarray[28*2+0] :
		       															  (hs_base_o==28)? oarray[29*2+0] :
		                                      (hs_base_o==29)? oarray[ 0*2+0] :  0;   
		  
		  else if(din_cnt ==  1) odata_reg <= (hs_base_o== 0)? oarray[ 1*2+1] :
		       															  (hs_base_o== 1)? oarray[ 2*2+1] :
		       															  (hs_base_o== 2)? oarray[ 3*2+1] :
		       															  (hs_base_o== 3)? oarray[ 4*2+1] :
		       															  (hs_base_o== 4)? oarray[ 5*2+1] :
		       															  (hs_base_o== 5)? oarray[ 6*2+1] :
		       															  (hs_base_o== 6)? oarray[ 7*2+1] :
		       															  (hs_base_o== 7)? oarray[ 8*2+1] :
		       															  (hs_base_o== 8)? oarray[ 9*2+1] :
		       															  (hs_base_o== 9)? oarray[10*2+1] :
		       															  (hs_base_o==10)? oarray[11*2+1] :
		       															  (hs_base_o==11)? oarray[12*2+1] :
		       															  (hs_base_o==12)? oarray[13*2+1] :
		       															  (hs_base_o==13)? oarray[14*2+1] :
		       															  (hs_base_o==14)? oarray[15*2+1] :
		       															  (hs_base_o==15)? oarray[16*2+1] :
		       															  (hs_base_o==16)? oarray[17*2+1] :
		       															  (hs_base_o==17)? oarray[18*2+1] :
		       															  (hs_base_o==18)? oarray[19*2+1] :
		       															  (hs_base_o==19)? oarray[20*2+1] :
		       															  (hs_base_o==20)? oarray[21*2+1] :
		       															  (hs_base_o==21)? oarray[22*2+1] :
		       															  (hs_base_o==22)? oarray[23*2+1] :
		       															  (hs_base_o==23)? oarray[24*2+1] :
		       															  (hs_base_o==24)? oarray[25*2+1] :
		       															  (hs_base_o==25)? oarray[26*2+1] :
		       															  (hs_base_o==26)? oarray[27*2+1] :
		       															  (hs_base_o==27)? oarray[28*2+1] :
		       															  (hs_base_o==28)? oarray[29*2+1] :
		                                      (hs_base_o==29)? oarray[ 0*2+1] :  0;                                   
  		
  		
  		else if(din_cnt ==  2) odata_reg <= (hs_base_o== 0)? oarray[ 2*2+0] :
		       															  (hs_base_o== 1)? oarray[ 3*2+0] :
		       															  (hs_base_o== 2)? oarray[ 4*2+0] :
		       															  (hs_base_o== 3)? oarray[ 5*2+0] :
		       															  (hs_base_o== 4)? oarray[ 6*2+0] :
		       															  (hs_base_o== 5)? oarray[ 7*2+0] :
		       															  (hs_base_o== 6)? oarray[ 8*2+0] :
		       															  (hs_base_o== 7)? oarray[ 9*2+0] :
		       															  (hs_base_o== 8)? oarray[10*2+0] :
		       															  (hs_base_o== 9)? oarray[11*2+0] :
		       															  (hs_base_o==10)? oarray[12*2+0] :
		       															  (hs_base_o==11)? oarray[13*2+0] :
		       															  (hs_base_o==12)? oarray[14*2+0] :
		       															  (hs_base_o==13)? oarray[15*2+0] :
		       															  (hs_base_o==14)? oarray[16*2+0] :
		       															  (hs_base_o==15)? oarray[17*2+0] :
		       															  (hs_base_o==16)? oarray[18*2+0] :
		       															  (hs_base_o==17)? oarray[19*2+0] :
		       															  (hs_base_o==18)? oarray[20*2+0] :
		       															  (hs_base_o==19)? oarray[21*2+0] :
		       															  (hs_base_o==20)? oarray[22*2+0] :
		       															  (hs_base_o==21)? oarray[23*2+0] :
		       															  (hs_base_o==22)? oarray[24*2+0] :
		       															  (hs_base_o==23)? oarray[25*2+0] :
		       															  (hs_base_o==24)? oarray[26*2+0] :
		       															  (hs_base_o==25)? oarray[27*2+0] :
		       															  (hs_base_o==26)? oarray[28*2+0] :
		       															  (hs_base_o==27)? oarray[29*2+0] :
		       															  (hs_base_o==28)? oarray[ 0*2+0] :
		                                      (hs_base_o==29)? oarray[ 1*2+0] :  0;        
  		
  		
  		
  		else if(din_cnt ==  3) odata_reg <= (hs_base_o== 0)? oarray[ 2*2+1] :
		       															  (hs_base_o== 1)? oarray[ 3*2+1] :
		       															  (hs_base_o== 2)? oarray[ 4*2+1] :
		       															  (hs_base_o== 3)? oarray[ 5*2+1] :
		       															  (hs_base_o== 4)? oarray[ 6*2+1] :
		       															  (hs_base_o== 5)? oarray[ 7*2+1] :
		       															  (hs_base_o== 6)? oarray[ 8*2+1] :
		       															  (hs_base_o== 7)? oarray[ 9*2+1] :
		       															  (hs_base_o== 8)? oarray[10*2+1] :
		       															  (hs_base_o== 9)? oarray[11*2+1] :
		       															  (hs_base_o==10)? oarray[12*2+1] :
		       															  (hs_base_o==11)? oarray[13*2+1] :
		       															  (hs_base_o==12)? oarray[14*2+1] :
		       															  (hs_base_o==13)? oarray[15*2+1] :
		       															  (hs_base_o==14)? oarray[16*2+1] :
		       															  (hs_base_o==15)? oarray[17*2+1] :
		       															  (hs_base_o==16)? oarray[18*2+1] :
		       															  (hs_base_o==17)? oarray[19*2+1] :
		       															  (hs_base_o==18)? oarray[20*2+1] :
		       															  (hs_base_o==19)? oarray[21*2+1] :
		       															  (hs_base_o==20)? oarray[22*2+1] :
		       															  (hs_base_o==21)? oarray[23*2+1] :
		       															  (hs_base_o==22)? oarray[24*2+1] :
		       															  (hs_base_o==23)? oarray[25*2+1] :
		       															  (hs_base_o==24)? oarray[26*2+1] :
		       															  (hs_base_o==25)? oarray[27*2+1] :
		       															  (hs_base_o==26)? oarray[28*2+1] :
		       															  (hs_base_o==27)? oarray[29*2+1] :
		       															  (hs_base_o==28)? oarray[ 0*2+1] :
		                                      (hs_base_o==29)? oarray[ 1*2+1] :  0;
		                                            
  		else if(din_cnt ==  4) odata_reg <= (hs_base_o== 0)? oarray[ 3*2+0] :
		       															  (hs_base_o== 1)? oarray[ 4*2+0] :
		       															  (hs_base_o== 2)? oarray[ 5*2+0] :
		       															  (hs_base_o== 3)? oarray[ 6*2+0] :
		       															  (hs_base_o== 4)? oarray[ 7*2+0] :
		       															  (hs_base_o== 5)? oarray[ 8*2+0] :
		       															  (hs_base_o== 6)? oarray[ 9*2+0] :
		       															  (hs_base_o== 7)? oarray[10*2+0] :
		       															  (hs_base_o== 8)? oarray[11*2+0] :
		       															  (hs_base_o== 9)? oarray[12*2+0] :
		       															  (hs_base_o==10)? oarray[13*2+0] :
		       															  (hs_base_o==11)? oarray[14*2+0] :
		       															  (hs_base_o==12)? oarray[15*2+0] :
		       															  (hs_base_o==13)? oarray[16*2+0] :
		       															  (hs_base_o==14)? oarray[17*2+0] :
		       															  (hs_base_o==15)? oarray[18*2+0] :
		       															  (hs_base_o==16)? oarray[19*2+0] :
		       															  (hs_base_o==17)? oarray[20*2+0] :
		       															  (hs_base_o==18)? oarray[21*2+0] :
		       															  (hs_base_o==19)? oarray[22*2+0] :
		       															  (hs_base_o==20)? oarray[23*2+0] :
		       															  (hs_base_o==21)? oarray[24*2+0] :
		       															  (hs_base_o==22)? oarray[25*2+0] :
		       															  (hs_base_o==23)? oarray[26*2+0] :
		       															  (hs_base_o==24)? oarray[27*2+0] :
		       															  (hs_base_o==25)? oarray[28*2+0] :
		       															  (hs_base_o==26)? oarray[29*2+0] :
		       															  (hs_base_o==27)? oarray[ 0*2+0] :
		       															  (hs_base_o==28)? oarray[ 1*2+0] :
		                                      (hs_base_o==29)? oarray[ 2*2+0] :  0;
		                                            
  		else if(din_cnt ==  5) odata_reg <= (hs_base_o== 0)? oarray[ 3*2+1] :
		       															  (hs_base_o== 1)? oarray[ 4*2+1] :
		       															  (hs_base_o== 2)? oarray[ 5*2+1] :
		       															  (hs_base_o== 3)? oarray[ 6*2+1] :
		       															  (hs_base_o== 4)? oarray[ 7*2+1] :
		       															  (hs_base_o== 5)? oarray[ 8*2+1] :
		       															  (hs_base_o== 6)? oarray[ 9*2+1] :
		       															  (hs_base_o== 7)? oarray[10*2+1] :
		       															  (hs_base_o== 8)? oarray[11*2+1] :
		       															  (hs_base_o== 9)? oarray[12*2+1] :
		       															  (hs_base_o==10)? oarray[13*2+1] :
		       															  (hs_base_o==11)? oarray[14*2+1] :
		       															  (hs_base_o==12)? oarray[15*2+1] :
		       															  (hs_base_o==13)? oarray[16*2+1] :
		       															  (hs_base_o==14)? oarray[17*2+1] :
		       															  (hs_base_o==15)? oarray[18*2+1] :
		       															  (hs_base_o==16)? oarray[19*2+1] :
		       															  (hs_base_o==17)? oarray[20*2+1] :
		       															  (hs_base_o==18)? oarray[21*2+1] :
		       															  (hs_base_o==19)? oarray[22*2+1] :
		       															  (hs_base_o==20)? oarray[23*2+1] :
		       															  (hs_base_o==21)? oarray[24*2+1] :
		       															  (hs_base_o==22)? oarray[25*2+1] :
		       															  (hs_base_o==23)? oarray[26*2+1] :
		       															  (hs_base_o==24)? oarray[27*2+1] :
		       															  (hs_base_o==25)? oarray[28*2+1] :
		       															  (hs_base_o==26)? oarray[29*2+1] :
		       															  (hs_base_o==27)? oarray[ 0*2+1] :
		       															  (hs_base_o==28)? oarray[ 1*2+1] :
		                                      (hs_base_o==29)? oarray[ 2*2+1] :  0;      
		                                      
  		else if(din_cnt ==  6) odata_reg <= (hs_base_o== 0)? oarray[ 4*2+0] :
		       															  (hs_base_o== 1)? oarray[ 5*2+0] :
		       															  (hs_base_o== 2)? oarray[ 6*2+0] :
		       															  (hs_base_o== 3)? oarray[ 7*2+0] :
		       															  (hs_base_o== 4)? oarray[ 8*2+0] :
		       															  (hs_base_o== 5)? oarray[ 9*2+0] :
		       															  (hs_base_o== 6)? oarray[10*2+0] :
		       															  (hs_base_o== 7)? oarray[11*2+0] :
		       															  (hs_base_o== 8)? oarray[12*2+0] :
		       															  (hs_base_o== 9)? oarray[13*2+0] :
		       															  (hs_base_o==10)? oarray[14*2+0] :
		       															  (hs_base_o==11)? oarray[15*2+0] :
		       															  (hs_base_o==12)? oarray[16*2+0] :
		       															  (hs_base_o==13)? oarray[17*2+0] :
		       															  (hs_base_o==14)? oarray[18*2+0] :
		       															  (hs_base_o==15)? oarray[19*2+0] :
		       															  (hs_base_o==16)? oarray[20*2+0] :
		       															  (hs_base_o==17)? oarray[21*2+0] :
		       															  (hs_base_o==18)? oarray[22*2+0] :
		       															  (hs_base_o==19)? oarray[23*2+0] :
		       															  (hs_base_o==20)? oarray[24*2+0] :
		       															  (hs_base_o==21)? oarray[25*2+0] :
		       															  (hs_base_o==22)? oarray[26*2+0] :
		       															  (hs_base_o==23)? oarray[27*2+0] :
		       															  (hs_base_o==24)? oarray[28*2+0] :
		       															  (hs_base_o==25)? oarray[29*2+0] :
		       															  (hs_base_o==26)? oarray[ 0*2+0] :
		       															  (hs_base_o==27)? oarray[ 1*2+0] :
		       															  (hs_base_o==28)? oarray[ 2*2+0] :
		                                      (hs_base_o==29)? oarray[ 3*2+0] :  0;
		                                            
  		else if(din_cnt ==  7) odata_reg <= (hs_base_o== 0)? oarray[ 4*2+1] :
		       															  (hs_base_o== 1)? oarray[ 5*2+1] :
		       															  (hs_base_o== 2)? oarray[ 6*2+1] :
		       															  (hs_base_o== 3)? oarray[ 7*2+1] :
		       															  (hs_base_o== 4)? oarray[ 8*2+1] :
		       															  (hs_base_o== 5)? oarray[ 9*2+1] :
		       															  (hs_base_o== 6)? oarray[10*2+1] :
		       															  (hs_base_o== 7)? oarray[11*2+1] :
		       															  (hs_base_o== 8)? oarray[12*2+1] :
		       															  (hs_base_o== 9)? oarray[13*2+1] :
		       															  (hs_base_o==10)? oarray[14*2+1] :
		       															  (hs_base_o==11)? oarray[15*2+1] :
		       															  (hs_base_o==12)? oarray[16*2+1] :
		       															  (hs_base_o==13)? oarray[17*2+1] :
		       															  (hs_base_o==14)? oarray[18*2+1] :
		       															  (hs_base_o==15)? oarray[19*2+1] :
		       															  (hs_base_o==16)? oarray[20*2+1] :
		       															  (hs_base_o==17)? oarray[21*2+1] :
		       															  (hs_base_o==18)? oarray[22*2+1] :
		       															  (hs_base_o==19)? oarray[23*2+1] :
		       															  (hs_base_o==20)? oarray[24*2+1] :
		       															  (hs_base_o==21)? oarray[25*2+1] :
		       															  (hs_base_o==22)? oarray[26*2+1] :
		       															  (hs_base_o==23)? oarray[27*2+1] :
		       															  (hs_base_o==24)? oarray[28*2+1] :
		       															  (hs_base_o==25)? oarray[29*2+1] :
		       															  (hs_base_o==26)? oarray[ 0*2+1] :
		       															  (hs_base_o==27)? oarray[ 1*2+1] :
		       															  (hs_base_o==28)? oarray[ 2*2+1] :
		                                      (hs_base_o==29)? oarray[ 3*2+1] :  0;    
		                                        
  		else if(din_cnt ==  8) odata_reg <= (hs_base_o== 0)? oarray[15*2+0] :
		       															  (hs_base_o== 1)? oarray[16*2+0] :
		       															  (hs_base_o== 2)? oarray[17*2+0] :
		       															  (hs_base_o== 3)? oarray[18*2+0] :
		       															  (hs_base_o== 4)? oarray[19*2+0] :
		       															  (hs_base_o== 5)? oarray[20*2+0] :
		       															  (hs_base_o== 6)? oarray[21*2+0] :
		       															  (hs_base_o== 7)? oarray[22*2+0] :
		       															  (hs_base_o== 8)? oarray[23*2+0] :
		       															  (hs_base_o== 9)? oarray[24*2+0] :
		       															  (hs_base_o==10)? oarray[25*2+0] :
		       															  (hs_base_o==11)? oarray[26*2+0] :
		       															  (hs_base_o==12)? oarray[27*2+0] :
		       															  (hs_base_o==13)? oarray[28*2+0] :
		       															  (hs_base_o==14)? oarray[29*2+0] :
		       															  (hs_base_o==15)? oarray[ 0*2+0] :
		       															  (hs_base_o==16)? oarray[ 1*2+0] :
		       															  (hs_base_o==17)? oarray[ 2*2+0] :
		       															  (hs_base_o==18)? oarray[ 3*2+0] :
		       															  (hs_base_o==19)? oarray[ 4*2+0] :
		       															  (hs_base_o==20)? oarray[ 5*2+0] :
		       															  (hs_base_o==21)? oarray[ 6*2+0] :
		       															  (hs_base_o==22)? oarray[ 7*2+0] :
		       															  (hs_base_o==23)? oarray[ 8*2+0] :
		       															  (hs_base_o==24)? oarray[ 9*2+0] :
		       															  (hs_base_o==25)? oarray[10*2+0] :
		       															  (hs_base_o==26)? oarray[11*2+0] :
		       															  (hs_base_o==27)? oarray[12*2+0] :
		       															  (hs_base_o==28)? oarray[13*2+0] :
		                                      (hs_base_o==29)? oarray[14*2+0] :  0;
		                                            
  		else if(din_cnt ==  9) odata_reg <= (hs_base_o== 0)? oarray[15*2+1] :
		       															  (hs_base_o== 1)? oarray[16*2+1] :
		       															  (hs_base_o== 2)? oarray[17*2+1] :
		       															  (hs_base_o== 3)? oarray[18*2+1] :
		       															  (hs_base_o== 4)? oarray[19*2+1] :
		       															  (hs_base_o== 5)? oarray[20*2+1] :
		       															  (hs_base_o== 6)? oarray[21*2+1] :
		       															  (hs_base_o== 7)? oarray[22*2+1] :
		       															  (hs_base_o== 8)? oarray[23*2+1] :
		       															  (hs_base_o== 9)? oarray[24*2+1] :
		       															  (hs_base_o==10)? oarray[25*2+1] :
		       															  (hs_base_o==11)? oarray[26*2+1] :
		       															  (hs_base_o==12)? oarray[27*2+1] :
		       															  (hs_base_o==13)? oarray[28*2+1] :
		       															  (hs_base_o==14)? oarray[29*2+1] :
		       															  (hs_base_o==15)? oarray[ 0*2+1] :
		       															  (hs_base_o==16)? oarray[ 1*2+1] :
		       															  (hs_base_o==17)? oarray[ 2*2+1] :
		       															  (hs_base_o==18)? oarray[ 3*2+1] :
		       															  (hs_base_o==19)? oarray[ 4*2+1] :
		       															  (hs_base_o==20)? oarray[ 5*2+1] :
		       															  (hs_base_o==21)? oarray[ 6*2+1] :
		       															  (hs_base_o==22)? oarray[ 7*2+1] :
		       															  (hs_base_o==23)? oarray[ 8*2+1] :
		       															  (hs_base_o==24)? oarray[ 9*2+1] :
		       															  (hs_base_o==25)? oarray[10*2+1] :
		       															  (hs_base_o==26)? oarray[11*2+1] :
		       															  (hs_base_o==27)? oarray[12*2+1] :
		       															  (hs_base_o==28)? oarray[13*2+1] :
		                                      (hs_base_o==29)? oarray[14*2+1] :  0;
		                                            
  		else if(din_cnt == 10) odata_reg <= (hs_base_o== 0)? oarray[16*2+0] :
		       															  (hs_base_o== 1)? oarray[17*2+0] :
		       															  (hs_base_o== 2)? oarray[18*2+0] :
		       															  (hs_base_o== 3)? oarray[19*2+0] :
		       															  (hs_base_o== 4)? oarray[20*2+0] :
		       															  (hs_base_o== 5)? oarray[21*2+0] :
		       															  (hs_base_o== 6)? oarray[22*2+0] :
		       															  (hs_base_o== 7)? oarray[23*2+0] :
		       															  (hs_base_o== 8)? oarray[24*2+0] :
		       															  (hs_base_o== 9)? oarray[25*2+0] :
		       															  (hs_base_o==10)? oarray[26*2+0] :
		       															  (hs_base_o==11)? oarray[27*2+0] :
		       															  (hs_base_o==12)? oarray[28*2+0] :
		       															  (hs_base_o==13)? oarray[29*2+0] :
		       															  (hs_base_o==14)? oarray[ 0*2+0] :
		       															  (hs_base_o==15)? oarray[ 1*2+0] :
		       															  (hs_base_o==16)? oarray[ 2*2+0] :
		       															  (hs_base_o==17)? oarray[ 3*2+0] :
		       															  (hs_base_o==18)? oarray[ 4*2+0] :
		       															  (hs_base_o==19)? oarray[ 5*2+0] :
		       															  (hs_base_o==20)? oarray[ 6*2+0] :
		       															  (hs_base_o==21)? oarray[ 7*2+0] :
		       															  (hs_base_o==22)? oarray[ 8*2+0] :
		       															  (hs_base_o==23)? oarray[ 9*2+0] :
		       															  (hs_base_o==24)? oarray[10*2+0] :
		       															  (hs_base_o==25)? oarray[11*2+0] :
		       															  (hs_base_o==26)? oarray[12*2+0] :
		       															  (hs_base_o==27)? oarray[13*2+0] :
		       															  (hs_base_o==28)? oarray[14*2+0] :
		                                      (hs_base_o==29)? oarray[15*2+0] :  0;
		                                            
  		else if(din_cnt == 11) odata_reg <= (hs_base_o== 0)? oarray[16*2+1] :
		       															  (hs_base_o== 1)? oarray[17*2+1] :
		       															  (hs_base_o== 2)? oarray[18*2+1] :
		       															  (hs_base_o== 3)? oarray[19*2+1] :
		       															  (hs_base_o== 4)? oarray[20*2+1] :
		       															  (hs_base_o== 5)? oarray[21*2+1] :
		       															  (hs_base_o== 6)? oarray[22*2+1] :
		       															  (hs_base_o== 7)? oarray[23*2+1] :
		       															  (hs_base_o== 8)? oarray[24*2+1] :
		       															  (hs_base_o== 9)? oarray[25*2+1] :
		       															  (hs_base_o==10)? oarray[26*2+1] :
		       															  (hs_base_o==11)? oarray[27*2+1] :
		       															  (hs_base_o==12)? oarray[28*2+1] :
		       															  (hs_base_o==13)? oarray[29*2+1] :
		       															  (hs_base_o==14)? oarray[ 0*2+1] :
		       															  (hs_base_o==15)? oarray[ 1*2+1] :
		       															  (hs_base_o==16)? oarray[ 2*2+1] :
		       															  (hs_base_o==17)? oarray[ 3*2+1] :
		       															  (hs_base_o==18)? oarray[ 4*2+1] :
		       															  (hs_base_o==19)? oarray[ 5*2+1] :
		       															  (hs_base_o==20)? oarray[ 6*2+1] :
		       															  (hs_base_o==21)? oarray[ 7*2+1] :
		       															  (hs_base_o==22)? oarray[ 8*2+1] :
		       															  (hs_base_o==23)? oarray[ 9*2+1] :
		       															  (hs_base_o==24)? oarray[10*2+1] :
		       															  (hs_base_o==25)? oarray[11*2+1] :
		       															  (hs_base_o==26)? oarray[12*2+1] :
		       															  (hs_base_o==27)? oarray[13*2+1] :
		       															  (hs_base_o==28)? oarray[14*2+1] :
		                                      (hs_base_o==29)? oarray[15*2+1] :  0;
		                                            
  		else if(din_cnt == 12) odata_reg <= (hs_base_o== 0)? oarray[17*2+0] :
		       															  (hs_base_o== 1)? oarray[18*2+0] :
		       															  (hs_base_o== 2)? oarray[19*2+0] :
		       															  (hs_base_o== 3)? oarray[20*2+0] :
		       															  (hs_base_o== 4)? oarray[21*2+0] :
		       															  (hs_base_o== 5)? oarray[22*2+0] :
		       															  (hs_base_o== 6)? oarray[23*2+0] :
		       															  (hs_base_o== 7)? oarray[24*2+0] :
		       															  (hs_base_o== 8)? oarray[25*2+0] :
		       															  (hs_base_o== 9)? oarray[26*2+0] :
		       															  (hs_base_o==10)? oarray[27*2+0] :
		       															  (hs_base_o==11)? oarray[28*2+0] :
		       															  (hs_base_o==12)? oarray[29*2+0] :
		       															  (hs_base_o==13)? oarray[ 0*2+0] :
		       															  (hs_base_o==14)? oarray[ 1*2+0] :
		       															  (hs_base_o==15)? oarray[ 2*2+0] :
		       															  (hs_base_o==16)? oarray[ 3*2+0] :
		       															  (hs_base_o==17)? oarray[ 4*2+0] :
		       															  (hs_base_o==18)? oarray[ 5*2+0] :
		       															  (hs_base_o==19)? oarray[ 6*2+0] :
		       															  (hs_base_o==20)? oarray[ 7*2+0] :
		       															  (hs_base_o==21)? oarray[ 8*2+0] :
		       															  (hs_base_o==22)? oarray[ 9*2+0] :
		       															  (hs_base_o==23)? oarray[10*2+0] :
		       															  (hs_base_o==24)? oarray[11*2+0] :
		       															  (hs_base_o==25)? oarray[12*2+0] :
		       															  (hs_base_o==26)? oarray[13*2+0] :
		       															  (hs_base_o==27)? oarray[14*2+0] :
		       															  (hs_base_o==28)? oarray[15*2+0] :
		                                      (hs_base_o==29)? oarray[16*2+0] :  0;
		                                            
  		else if(din_cnt == 13) odata_reg <= (hs_base_o== 0)? oarray[17*2+1] :
		       															  (hs_base_o== 1)? oarray[18*2+1] :
		       															  (hs_base_o== 2)? oarray[19*2+1] :
		       															  (hs_base_o== 3)? oarray[20*2+1] :
		       															  (hs_base_o== 4)? oarray[21*2+1] :
		       															  (hs_base_o== 5)? oarray[22*2+1] :
		       															  (hs_base_o== 6)? oarray[23*2+1] :
		       															  (hs_base_o== 7)? oarray[24*2+1] :
		       															  (hs_base_o== 8)? oarray[25*2+1] :
		       															  (hs_base_o== 9)? oarray[26*2+1] :
		       															  (hs_base_o==10)? oarray[27*2+1] :
		       															  (hs_base_o==11)? oarray[28*2+1] :
		       															  (hs_base_o==12)? oarray[29*2+1] :
		       															  (hs_base_o==13)? oarray[ 0*2+1] :
		       															  (hs_base_o==14)? oarray[ 1*2+1] :
		       															  (hs_base_o==15)? oarray[ 2*2+1] :
		       															  (hs_base_o==16)? oarray[ 3*2+1] :
		       															  (hs_base_o==17)? oarray[ 4*2+1] :
		       															  (hs_base_o==18)? oarray[ 5*2+1] :
		       															  (hs_base_o==19)? oarray[ 6*2+1] :
		       															  (hs_base_o==20)? oarray[ 7*2+1] :
		       															  (hs_base_o==21)? oarray[ 8*2+1] :
		       															  (hs_base_o==22)? oarray[ 9*2+1] :
		       															  (hs_base_o==23)? oarray[10*2+1] :
		       															  (hs_base_o==24)? oarray[11*2+1] :
		       															  (hs_base_o==25)? oarray[12*2+1] :
		       															  (hs_base_o==26)? oarray[13*2+1] :
		       															  (hs_base_o==27)? oarray[14*2+1] :
		       															  (hs_base_o==28)? oarray[15*2+1] :
		                                      (hs_base_o==29)? oarray[16*2+1] :  0;        
		                                      
  		else if(din_cnt == 14) odata_reg <= (hs_base_o== 0)? oarray[18*2+0] :
		       															  (hs_base_o== 1)? oarray[19*2+0] :
		       															  (hs_base_o== 2)? oarray[20*2+0] :
		       															  (hs_base_o== 3)? oarray[21*2+0] :
		       															  (hs_base_o== 4)? oarray[22*2+0] :
		       															  (hs_base_o== 5)? oarray[23*2+0] :
		       															  (hs_base_o== 6)? oarray[24*2+0] :
		       															  (hs_base_o== 7)? oarray[25*2+0] :
		       															  (hs_base_o== 8)? oarray[26*2+0] :
		       															  (hs_base_o== 9)? oarray[27*2+0] :
		       															  (hs_base_o==10)? oarray[28*2+0] :
		       															  (hs_base_o==11)? oarray[29*2+0] :
		       															  (hs_base_o==12)? oarray[ 0*2+0] :
		       															  (hs_base_o==13)? oarray[ 1*2+0] :
		       															  (hs_base_o==14)? oarray[ 2*2+0] :
		       															  (hs_base_o==15)? oarray[ 3*2+0] :
		       															  (hs_base_o==16)? oarray[ 4*2+0] :
		       															  (hs_base_o==17)? oarray[ 5*2+0] :
		       															  (hs_base_o==18)? oarray[ 6*2+0] :
		       															  (hs_base_o==19)? oarray[ 7*2+0] :
		       															  (hs_base_o==20)? oarray[ 8*2+0] :
		       															  (hs_base_o==21)? oarray[ 9*2+0] :
		       															  (hs_base_o==22)? oarray[10*2+0] :
		       															  (hs_base_o==23)? oarray[11*2+0] :
		       															  (hs_base_o==24)? oarray[12*2+0] :
		       															  (hs_base_o==25)? oarray[13*2+0] :
		       															  (hs_base_o==26)? oarray[14*2+0] :
		       															  (hs_base_o==27)? oarray[15*2+0] :
		       															  (hs_base_o==28)? oarray[16*2+0] :
		                                      (hs_base_o==29)? oarray[17*2+0] :  0;
		                                            
  		else if(din_cnt == 15) odata_reg <= (hs_base_o== 0)? oarray[18*2+1] :
		       															  (hs_base_o== 1)? oarray[19*2+1] :
		       															  (hs_base_o== 2)? oarray[20*2+1] :
		       															  (hs_base_o== 3)? oarray[21*2+1] :
		       															  (hs_base_o== 4)? oarray[22*2+1] :
		       															  (hs_base_o== 5)? oarray[23*2+1] :
		       															  (hs_base_o== 6)? oarray[24*2+1] :
		       															  (hs_base_o== 7)? oarray[25*2+1] :
		       															  (hs_base_o== 8)? oarray[26*2+1] :
		       															  (hs_base_o== 9)? oarray[27*2+1] :
		       															  (hs_base_o==10)? oarray[28*2+1] :
		       															  (hs_base_o==11)? oarray[29*2+1] :
		       															  (hs_base_o==12)? oarray[ 0*2+1] :
		       															  (hs_base_o==13)? oarray[ 1*2+1] :
		       															  (hs_base_o==14)? oarray[ 2*2+1] :
		       															  (hs_base_o==15)? oarray[ 3*2+1] :
		       															  (hs_base_o==16)? oarray[ 4*2+1] :
		       															  (hs_base_o==17)? oarray[ 5*2+1] :
		       															  (hs_base_o==18)? oarray[ 6*2+1] :
		       															  (hs_base_o==19)? oarray[ 7*2+1] :
		       															  (hs_base_o==20)? oarray[ 8*2+1] :
		       															  (hs_base_o==21)? oarray[ 9*2+1] :
		       															  (hs_base_o==22)? oarray[10*2+1] :
		       															  (hs_base_o==23)? oarray[11*2+1] :
		       															  (hs_base_o==24)? oarray[12*2+1] :
		       															  (hs_base_o==25)? oarray[13*2+1] :
		       															  (hs_base_o==26)? oarray[14*2+1] :
		       															  (hs_base_o==27)? oarray[15*2+1] :
		       															  (hs_base_o==28)? oarray[16*2+1] :
		                                      (hs_base_o==29)? oarray[17*2+1] :  0;     
	end
	else begin
		odata_reg <= odata_reg ;   
	end
end

//generate 2 cycles identification signal for the compression process
wire hash_busy;
wire compress_st;
assign compress_st = mod_sel_i==0? 1 : 0;

reg  compress_st_del;
always @ (posedge clk or negedge rst_n)
begin
	if (~rst_n) begin
		compress_st_del <=0;
	end
	else begin
		compress_st_del <= compress_st;
	end
end

assign hash_busy = compress_st | compress_st_del;

reg [1:0] cnt_hash;//each 32bit block needs 2 cycles for compression
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
		cnt_hash <= 0;
	end 
	else if (hash_busy) begin
		cnt_hash <= cnt_hash + 1;
	end
	else if (c_state != HASH) begin
		cnt_hash <= 0;
	end
	else begin
		cnt_hash <= 0;
	end
end

//-------------------------------------------------------------------------
//generate states and core function mode signals
always @ (posedge clk or negedge rst_n)
begin
	if (~rst_n) begin
		hs_stat_i  <= 0;
		hs_base_i  <= 0;
		mod_sel_i  <= DIRECT;//mod_sel_i:UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;					
	end
	else if (c_state == IDLE && init) begin
		hs_stat_i  <= {32'h48C2F834,32'h99E84991,32'hDE29F9FB,32'h1D626CF9,32'h94B5B0D2,32'h68F6D4E0,32'h5F137166,32'hDEBD52E9,704'h0};
		hs_base_i  <= 0;
		mod_sel_i  <= DIRECT;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;       
	end
	else if (c_state == LOAD && din_cnt == (R-1)) begin  
		hs_stat_i  <= hs_stat_o;
		hs_base_i  <= hs_base_o;
		mod_sel_i  <= DIRECT;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;      
	end
	else if (c_state == HASH && din_cnt == 0 && cnt_hash == 0) begin  
		hs_stat_i  <= hs_stat_o; 
		hs_base_i  <= hs_base_o; 
		mod_sel_i  <= UPDATEa;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
	end
	else if (/*c_state == HASH && din_cnt == 0*/hash_busy  && cnt_hash == 0) begin  
		hs_stat_i  <= hs_stat_o; 
		hs_base_i  <= hs_base_o; 
		mod_sel_i  <= UPDATEb;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
	end
	else if (busy_final) begin
		if(cnt_busy<10) begin
			hs_stat_i  <= hs_stat_o; 
			hs_base_i  <= hs_base_o; 
			mod_sel_i  <= FINAL_G1;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
		end
		else if (cnt_busy >=10 && cnt_busy <36) begin
			hs_stat_i  <= hs_stat_o; 
			hs_base_i  <= hs_base_o; 
			mod_sel_i  <= cnt_busy[0]==0? FINAL_G2a : FINAL_G2b;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
		end
		else if (cnt_busy == 36) begin
			hs_stat_i  <= hs_stat_o; 
			hs_base_i  <= hs_base_o; 
			mod_sel_i  <= LAST;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
		end
		else begin
			hs_stat_i  <= hs_stat_o; 
			hs_base_i  <= hs_base_o; 
			mod_sel_i  <= DIRECT;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
		end
	end
	else begin
		hs_stat_i  <= hs_stat_o; 
		hs_base_i  <= hs_base_o; 
		mod_sel_i  <= DIRECT;//mod_sel_i: UPDATEa = 0, FINAL_G2a = 1, LAST = 2, DIRECT = 3, FINAL_G1 = 4, FINAL_G2b = 5, UPDATEb = 6;               
	end
end

//------------------FSM state transitions----------------------------------
//Mealy FSM state transition
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		c_state <= 0;
	end
	else begin
		c_state <= n_state;
	end
end  

always @ (c_state, init, load, fetch, busy_final)     
begin 
	case (c_state)
		IDLE:
			begin
				if ((~busy_final)&&load) begin
					n_state = LOAD;
				end
				else if ((~busy_final)&&fetch) begin
					n_state = FETCH;
				end
				else begin
					n_state = IDLE;
				end
			end
		
		LOAD:
			begin
				n_state = HASH;
			end	
		
		HASH:
			begin
				if(busy_final|hash_busy) begin
					n_state = HASH;
				end
				else begin
					n_state = IDLE;
				end
			end	
		
		FETCH:
			begin
				if(busy_final) begin /*Finalization step*/
					n_state = FETCH;
				end
				else begin
					n_state = WAIT1;
				end
			end	
		
		WAIT1:
			begin
				n_state = IDLE;
			end	
		
		default: n_state = IDLE;	
	endcase
end                                          


//COLUMN
  function [4:0] COLUMN; //column <30
  		input [4:0] Base;
  		input [4:0] col;
  		integer temp;
  		begin
  			temp   = Base + col;
  			COLUMN = (temp < 30) ? temp : (temp-30); 
  		end
  endfunction


endmodule

