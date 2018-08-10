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

module simd_top(
   input         clk,
   input         rst_n,
   input         init,
   input         load,
   input         fetch,
   input  [15:0] idata,
   output        ack,
   output [15:0] odata
);   

parameter W = 16;//IO-size
parameter B =  2;//W/8;//number of bytes
parameter R = 32;//512/W;//number of transfers per 512-bit block

//acknowledge signals	
reg  fetch_ack_reg;
reg  load_ack_reg;

reg  [W-1:0] odata_reg;
wire [W-1:0] idata_reverse_byte;
reg  [  3:0] c_state;
reg  [  3:0] n_state;
reg  [  6:0] din_cnt;//support IO-size of 8bit

//for FSM
parameter IDLE			= 4'd0, 
					LOAD			= 4'd1, 
					HASH    	= 4'd2, 
					FETCH   	= 4'd3,
					WAIT1			= 4'd4;

//simd256 core function instantiation
//interconnections
reg					  ena;
wire					fin;
reg   [511:0]	data_i;
wire  [511:0] iblock;
wire  [511:0] oblock;
reg 	[511:0] stat_i;
wire 	[511:0] stat_o;
reg           mode_i;//1->final compression, 0->normal compression
reg   [W-1:0] iarray [0:(R-1)];//used for better representation
wire  [7:0] oarray [0:(R-1)];//used for better representation
wire  [7:0]output_array [31:0];
reg	normal_busy;
reg	final_busy;


simd256_round U_simd256(.clk   (clk   ), 
										    .rst_n (rst_n ), 
										    .init  (init  ),
										    .ena   (ena   ),
										    .mode_i(mode_i),
										    .data_i(data_i),
										    .stat_i(stat_i),
										    //output
										    .stat_o(stat_o),
										    .fin   (fin   )
										    );

reg  fetch_del;
wire fetch_1cyc;

assign odata = odata_reg;
assign ack = fetch_ack_reg|load_ack_reg;


integer i,j;
genvar k;

 //endian conversion
 generate
 	for( k=0; k < B ; k = k + 1) begin: BYTE_REVERSE
 		assign idata_reverse_byte[(8*(k+1)-1):(8*k)] = idata[(8*(B-k)-1):(8*(B-k-1))];
// 		assign odata[(8*(k+1)-1):(8*k)] = /*getconfig? 32'h0ea7f00d : */odata_reg[(8*(B-k)-1):(8*(B-k-1))];  
 	end
 endgenerate
 
//convert iarray to data_i
generate
	for (k=0; k < R; k = k+1) begin: gen_io_array
		assign iblock[(W*(k+1)-1):(W*k)] = iarray[k];
		assign oarray[k]                 = stat_o[k];
	end
endgenerate

generate 
	for(k=0; k<16; k=k+1)
	begin:out
		assign output_array [k] = stat_o[384+k*8+7:384+k*8];
	end
endgenerate
generate 
	for(k=0; k<16; k=k+1)
	begin:new_out
		assign output_array [k+16] = stat_o[256+k*8+7:256+k*8];
	end
endgenerate
//initialize parameters
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		ena    <= 0;
		mode_i <= 0;
		data_i <= 0;
		stat_i <= 0;
	end
	else if ((c_state == IDLE) && init) begin
		ena    <= 0;
		mode_i <= 0;
		data_i <= 0;
		stat_i <= {/*IA*/32'h39d726e9,32'h8474577b,32'h07190ba9 ,32'h4d567983,
							 /*IB*/32'hc96006d3,32'hafd5e751,32'h3ee20b03,32'haaf3d925,
							 /*IC*/32'h668626c9,32'hf67caf46,32'h49b3bcb4,32'hc2c2ba14,
							 /*ID*/32'h55693de1,32'hd0c661a5 ,32'h1ff47833,32'he2eaa8d2 };
	end
	else if ((c_state == HASH) && (din_cnt == 32)) begin
		ena    <= 1;
		mode_i <= 0;
		data_i <= iblock;
		stat_i <= stat_o;
	end
	else if (fetch_1cyc) begin
		ena    <= 1;
		mode_i <= 1;
		data_i <= iblock;
		stat_i <= stat_i;
	end
	else begin
		ena    <= 0;
		mode_i <= mode_i;
		data_i <= iblock;
		stat_i <= stat_i;
	end
end


//generate hash_busy signals for HASH updata and Finalization
wire hash_busy;
wire init_busy;
reg start2fin_init;
reg start2fin_hash;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		start2fin_init <= 0;
		start2fin_hash <= 0;
	end
	else if(init) begin
		start2fin_init <= 1;
		start2fin_hash <= 0;
	end
	else if(ena) begin
		start2fin_init <= 0;
		start2fin_hash <= 1;
	end
	else if(fin) begin
		start2fin_init <= 0;
		start2fin_hash <= 0;
	end
	else begin
		start2fin_init <= start2fin_init;
		start2fin_hash <= start2fin_hash;
	end
end

assign init_busy = start2fin_init;
assign hash_busy = start2fin_hash | ena;

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
	else if(c_state == FETCH) begin
		load_ack_reg  <= load_ack_reg;
		fetch_ack_reg <= hash_busy? 0 : 1;
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
	else if (c_state == LOAD|c_state == FETCH) begin
	  	din_cnt <= hash_busy? din_cnt : din_cnt + 1;//Finalization step during the Fetch
	end
	else if (din_cnt == 32) begin
	  	din_cnt <= 0;
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
	else if (c_state == FETCH && (~hash_busy)) begin
		       if(din_cnt ==  0) odata_reg <= {output_array[30],output_array[31]};
  		else if(din_cnt ==  1) odata_reg <= {output_array[28],output_array[29]};
  		else if(din_cnt ==  2) odata_reg <= {output_array[26],output_array[27]};
  		else if(din_cnt ==  3) odata_reg <= {output_array[24],output_array[25]};
  		else if(din_cnt ==  4) odata_reg <= {output_array[22],output_array[23]};
  		else if(din_cnt ==  5) odata_reg <= {output_array[20],output_array[21]};
  		else if(din_cnt ==  6) odata_reg <= {output_array[18],output_array[19]};
  		else if(din_cnt ==  7) odata_reg <= {output_array[16],output_array[17]};
  		else if(din_cnt ==  8) odata_reg <= {output_array[14],output_array[15]};
  		else if(din_cnt ==  9) odata_reg <= {output_array[12],output_array[13]};
  		else if(din_cnt == 10) odata_reg <= {output_array[10],output_array[11]};
  		else if(din_cnt == 11) odata_reg <= {output_array[8],output_array[9]};
  		else if(din_cnt == 12) odata_reg <= {output_array[6],output_array[7]};
  		else if(din_cnt == 13) odata_reg <= {output_array[4],output_array[5]};
  		else if(din_cnt == 14) odata_reg <= {output_array[2],output_array[3]};
  		else if(din_cnt == 15) odata_reg <= {output_array[0],output_array[1]};
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
	else if (c_state == FETCH && hash_busy==0) begin
			for (i=0; i < R; i = i+1) begin
				iarray[i]   <= oarray[i];//stat_o[(W*(i+1)-1):(W*i)];
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
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
	end
	else begin
		fetch_del <= fetch;
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

always @ (c_state, init, load, fetch, hash_busy, init_busy)     
begin
	case (c_state)
		IDLE:
			begin
				if (((~hash_busy)&&(~init_busy))&&load) begin
					n_state = LOAD;
				end
				else if ((~hash_busy)&&fetch) begin
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
				if(hash_busy) begin
					n_state = HASH;
				end
				else begin
					n_state = IDLE;
				end
			end	
		
		FETCH:
			begin
				if(hash_busy) begin /*Finalization step*/
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

//Busy Signal
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		normal_busy <= 0;
	end
	else
	begin
		normal_busy <= (ena==1)? ~mode_i : ((fin==1)? 0 : normal_busy);
	end
end

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		final_busy <= 0;
	end
	else
	begin
		final_busy <= (ena==1)? mode_i : ((fin==1)? 0 : final_busy);
	end
end

endmodule	                                                                                                                 
	                                                                                                      