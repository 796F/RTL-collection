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

module BMW_Top(
              input  clk,
              input  rst_n,
              input  init,
              input  load,
              input  fetch,
              input  [15:0] idata,
              output ack,
              output [15:0] odata
              );   

parameter W = 16;//IO-size
parameter B = 2;//W/8;//number of bytes
parameter R = 32;//512/W;//number of transfers per 512-bit block

//for FSM
parameter IDLE			= 4'd0, 
					LOAD			= 4'd1, 
					HASH    	= 4'd2, 
					FINAL     = 4'd3,
					FETCH   	= 4'd4,
					WAIT1			= 4'd5,
					WAIT2     = 4'd6;

//acknowledge signals	
reg  fetch_ack_reg;
reg  load_ack_reg;

reg  [W-1:0] odata_reg;
wire [W-1:0] idata_reverse_byte;
reg  [  3:0] c_state;
reg  [  3:0] n_state;
reg  [  6:0] din_cnt;//support IO-size of 8bit

//bmw256 core function instantiation
//interconnections
reg					  ena;
wire					fin;
reg	  [511:0]	IV;
wire  [511:0] IV_wire;
wire 	[511:0] iblock;
wire  [511:0] oblock;
reg   [W-1:0] iarray [0:(R-1)];//used for better representation
wire  [W-1:0] oarray [0:(R-1)];//used for better representation
reg           fetch_del;
reg           fetch_del1;
reg           fin_del1;
wire          fetch_1cyc;
wire          fetch_1cyc_del;
wire  [ 31:0] p2_msb, p2_lsb;
wire  [  4:0] p2_state;

bmw256_round U_bmw256(.clk(clk),
											.rst_n(rst_n),
											.enable(ena),
											.finish(fin),
											.IV(IV),
										  .indata(iblock),
										  .outdata(oblock),
										  //for chipscope debug
										  .p2_msb(p2_msb),
										  .p2_lsb(p2_lsb),
										  .p2_state(p2_state)
										  );

assign ack 					 = fetch_ack_reg|load_ack_reg;//ori master_ack;	

integer i,j;
genvar k;
//endian conversion
generate
	for( k=0; k < B ; k = k + 1) begin: BYTE_REVERSE
		assign idata_reverse_byte[(8*(k+1)-1):(8*k)] = idata[(8*(B-k)-1):(8*(B-k-1))];
		assign odata[(8*(k+1)-1):(8*k)] = odata_reg[(8*(B-k)-1):(8*(B-k-1))];  
	end
endgenerate

//convert iarray to iblock
generate
	for (k=0; k < R; k = k+1) begin: gen_4
		assign iblock[(W*(k+1)-1):(W*k)] = iarray[k];
		assign oarray[k]                 = oblock[(W*(k+1)-1):(W*k)];
	end
endgenerate


//initialize parameters
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		ena <= 0;
		IV  <= 512'd0;
	end
	else if (c_state == IDLE && init) begin
		ena <= 0;
		IV  <= 512'h7c7d7e7f78797a7b74757677707172736c6d6e6f68696a6b64656667606162635c5d5e5f58595a5b54555657505152534c4d4e4f48494a4b4445464740414243;//i256p2 
	end
	else if (c_state == LOAD && din_cnt == 31) begin
		ena <= 1;
		IV  <= IV;
	end
	else if (load && fin_del1) begin
		ena <= 0;
		IV  <= oblock;//add for mul-block
	end
	else if (/*c_state == FETCH &&*/ fetch_1cyc) begin
		ena <= 0;
		IV  <= IV;
	end
	else if (/*c_state == FETCH &&*/ fetch_1cyc_del) begin
		ena <= 1;
		IV  <= 512'haaaaaaafaaaaaaaeaaaaaaadaaaaaaacaaaaaaabaaaaaaaaaaaaaaa9aaaaaaa8aaaaaaa7aaaaaaa6aaaaaaa5aaaaaaa4aaaaaaa3aaaaaaa2aaaaaaa1aaaaaaa0;//CONST32final
	end
	else begin
		ena <= 0;
		IV  <= IV;
	end
end

//generate busy signals for HASH updata and Finalization
wire busy;
reg start2fin;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		start2fin <= 0;
	end
	else if(ena) begin
		start2fin <= 1;
	end
	else if(fin) begin
		start2fin <= 0;
	end
	else begin
		start2fin <= start2fin;
	end
end

assign busy = start2fin | ena;

//generate ack
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		load_ack_reg  <= 0;
		fetch_ack_reg <= 0;
	end
	else if(c_state == LOAD) begin
		load_ack_reg  <= 1;
		fetch_ack_reg <= fetch_ack_reg;
	end
	else if(c_state == /*FETCH*/WAIT1) begin
		load_ack_reg  <= load_ack_reg;
		fetch_ack_reg <= busy? 0 : 1;
	end
	else begin
		load_ack_reg  <= 0;
		fetch_ack_reg <= 0;
	end
end

//count the number of load and fetch
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		din_cnt <= 0;
	end
	else if (c_state == LOAD) begin
			if (din_cnt == 31) begin
				din_cnt <= 0;
			end
			else begin
	  		din_cnt <= busy? din_cnt : din_cnt + 1;//Finalization step during the Fetch
	  	end
	end
	else if (c_state == /*FETCH*/WAIT1) begin
			if (din_cnt == 15) begin
				din_cnt <= 0;
			end
			else begin
	  		din_cnt <= busy? din_cnt : din_cnt + 1;//Finalization step during the Fetch
	  	end
	end
	else begin
			din_cnt <= din_cnt;
	end
end

//fetch output hash
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		odata_reg <= 0;
	end
	else if (c_state == /*FETCH*/WAIT1 && (~busy)) begin
		       if(din_cnt ==  0) odata_reg <= oarray[31];
  		else if(din_cnt ==  1) odata_reg <= oarray[30];
  		else if(din_cnt ==  2) odata_reg <= oarray[29];
  		else if(din_cnt ==  3) odata_reg <= oarray[28];
  		else if(din_cnt ==  4) odata_reg <= oarray[27];
  		else if(din_cnt ==  5) odata_reg <= oarray[26];
  		else if(din_cnt ==  6) odata_reg <= oarray[25];
  		else if(din_cnt ==  7) odata_reg <= oarray[24];
  		else if(din_cnt ==  8) odata_reg <= oarray[23];
  		else if(din_cnt ==  9) odata_reg <= oarray[22];
  		else if(din_cnt == 10) odata_reg <= oarray[21];
  		else if(din_cnt == 11) odata_reg <= oarray[20];
  		else if(din_cnt == 12) odata_reg <= oarray[19];
  		else if(din_cnt == 13) odata_reg <= oarray[18];
  		else if(din_cnt == 14) odata_reg <= oarray[17];
  		else if(din_cnt == 15) odata_reg <= oarray[16];
	end
	else begin
		odata_reg <= odata_reg ;   
	end
end

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
  		else if(din_cnt ==  2) iarray[ 2] <= idata_reverse_byte;
  		else if(din_cnt ==  3) iarray[ 3] <= idata_reverse_byte;
  		else if(din_cnt ==  4) iarray[ 4] <= idata_reverse_byte;
  		else if(din_cnt ==  5) iarray[ 5] <= idata_reverse_byte;
  		else if(din_cnt ==  6) iarray[ 6] <= idata_reverse_byte;
  		else if(din_cnt ==  7) iarray[ 7] <= idata_reverse_byte;
  		else if(din_cnt ==  8) iarray[ 8] <= idata_reverse_byte;
  		else if(din_cnt ==  9) iarray[ 9] <= idata_reverse_byte;
  		else if(din_cnt == 10) iarray[10] <= idata_reverse_byte;
  		else if(din_cnt == 11) iarray[11] <= idata_reverse_byte;
  		else if(din_cnt == 12) iarray[12] <= idata_reverse_byte;
  		else if(din_cnt == 13) iarray[13] <= idata_reverse_byte;
  		else if(din_cnt == 14) iarray[14] <= idata_reverse_byte;
  		else if(din_cnt == 15) iarray[15] <= idata_reverse_byte;
  		else if(din_cnt == 16) iarray[16] <= idata_reverse_byte;
  		else if(din_cnt == 17) iarray[17] <= idata_reverse_byte;
  		else if(din_cnt == 18) iarray[18] <= idata_reverse_byte;
  		else if(din_cnt == 19) iarray[19] <= idata_reverse_byte;
  		else if(din_cnt == 20) iarray[20] <= idata_reverse_byte;
  		else if(din_cnt == 21) iarray[21] <= idata_reverse_byte;
  		else if(din_cnt == 22) iarray[22] <= idata_reverse_byte;
  		else if(din_cnt == 23) iarray[23] <= idata_reverse_byte;
  		else if(din_cnt == 24) iarray[24] <= idata_reverse_byte;
  		else if(din_cnt == 25) iarray[25] <= idata_reverse_byte;
  		else if(din_cnt == 26) iarray[26] <= idata_reverse_byte;
  		else if(din_cnt == 27) iarray[27] <= idata_reverse_byte;
  		else if(din_cnt == 28) iarray[28] <= idata_reverse_byte;
  		else if(din_cnt == 29) iarray[29] <= idata_reverse_byte;
  		else if(din_cnt == 30) iarray[30] <= idata_reverse_byte;
  		else if(din_cnt == 31) iarray[31] <= idata_reverse_byte;    
	end
	else if (c_state == FETCH) begin
			for (i=0; i < R; i = i+1) begin
				iarray[i]   <= fetch_1cyc_del? oarray[i]: iarray[i];//oblock[(W*(i+1)-1):(W*i)];
			end
	end
	else begin
			for (j=0;j<R;j=j+1) begin
				iarray[j]		<= iarray[j];
			end
	end
end


//capature fetch pulse 
assign fetch_1cyc = fetch & (~fetch_del);
assign fetch_1cyc_del = fetch_del & (~fetch_del1);

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		fetch_del <= 0;
		fetch_del1 <= 0;
		fin_del1  <=0;
	end
	else begin
		fetch_del <= fetch;
		fetch_del1 <= fetch_del;
		fin_del1  <= fin;
	end
end


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

always @ (c_state, init, load, fetch, busy)     
begin
	case (c_state)
		IDLE:
			begin
				if ((~busy)&&load) begin
					n_state = LOAD;
				end
				else if ((~busy)&&fetch) begin
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
				if(busy) begin
					n_state = HASH;
				end
				else begin
					n_state = IDLE;
				end
			end	
		
		FETCH:
			begin
				if(busy) begin /*Finalization step*/
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

endmodule	                                                                                                                 
	                                                                                                      