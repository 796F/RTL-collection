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

module SHA256_INTERFACE_rev1(
	                           clk,              
	                           rst_n,            
	                           load,              
	                           fetch,            
                             busy,         
                             Hash0,    
                             Hash1,
                             Hash2,
                             Hash3,
                             Hash4,
                             Hash5,
                             Hash6,
                             Hash7,
                             idata, 
                             idata32,
                             odata,   
                             EN,             
                             ack,
                             busy_valid         
                             );  
//IO 
input         clk;              
input         rst_n;            
input         load;              
input         fetch;            
input         busy;         
input  [31:0] Hash0;  
input  [31:0] Hash1;
input  [31:0] Hash2;
input  [31:0] Hash3;
input  [31:0] Hash4;
input  [31:0] Hash5;
input  [31:0] Hash6;
input  [31:0] Hash7;
input  [15:0] idata; 
output [31:0] idata32;
output [15:0] odata;   
output        EN;             
output        ack;         
output        busy_valid;//output valid busy signal for power measurement trigger

//signals
reg         ack;
reg [ 15:0] odata_r;
reg [  2:0] state;
reg [  2:0] next_state;
reg [  4:0] Dnum;
reg [511:0] idata_r;
reg         busy_del;
reg         busy_high;//busy period from busy_st and busy_end 
wire        busy_st;//1 pulse signal to identify the enable of core 
wire        busy_end;//1 pulse signal to identify the end of busy from core
wire        busy_valid;//generate the valid busy signal for core function (68 cycles)

//acknowledge signals for LOAD and FETCH
always @(posedge clk or negedge rst_n)
begin
   if (~rst_n) 
     ack <= 0;                      
   else if (state == 3'b011) //fetch ack
     ack <= 1;          
   else if (state == 3'b001) //load ack
     ack <= 1;     
   else 
     ack <= 0;
end

//count the number of loads and fetches
always @(posedge clk or negedge rst_n) 
begin
   if (~rst_n) 
     Dnum <= 5'd0;                       
   else if ((state == 3'b001) || (state == 3'b100)) 
     Dnum <= Dnum + 1;  
   else if (Dnum == 'd32) 
     Dnum <= 5'd0;
	 else 
	   Dnum <= Dnum;
end

//output hash from the last state
assign odata = odata_r;     
always @(posedge clk or negedge rst_n)
begin
   if (~rst_n) begin
     odata_r <= 16'h0000; 
   end
   else if (state == 3'b011) begin    
     if      (Dnum ==  0) odata_r <= Hash0[31:16]; 
     else if (Dnum ==  1) odata_r <= Hash0[15: 0];
     else if (Dnum ==  2) odata_r <= Hash1[31:16];
     else if (Dnum ==  3) odata_r <= Hash1[15: 0];
     else if (Dnum ==  4) odata_r <= Hash2[31:16];
     else if (Dnum ==  5) odata_r <= Hash2[15: 0];
     else if (Dnum ==  6) odata_r <= Hash3[31:16];
     else if (Dnum ==  7) odata_r <= Hash3[15: 0];
	   else if (Dnum ==  8) odata_r <= Hash4[31:16];
	   else if (Dnum ==  9) odata_r <= Hash4[15: 0];
	   else if (Dnum == 10) odata_r <= Hash5[31:16];
	   else if (Dnum == 11) odata_r <= Hash5[15: 0];
	   else if (Dnum == 12) odata_r <= Hash6[31:16];
	   else if (Dnum == 13) odata_r <= Hash6[15: 0];
	   else if (Dnum == 14) odata_r <= Hash7[31:16];
	   else if (Dnum == 15) odata_r <= Hash7[15: 0];
   end
   else begin
   	 odata_r <= odata_r;
   end
end

//generate the index of 32bits msg data block for message expansion
reg [4:0] index_cnt;
always @(posedge clk or negedge rst_n) 
begin
   if (~rst_n) 
     index_cnt <= 5'd0;       
   else if ((state == 3'b010) & (Dnum ==31)) 
     index_cnt <= 0;//clear when loading is complete                        
   else if ((state == 3'b010) & (Dnum == 0)) 
   		if (index_cnt == 16) 
   		  index_cnt <= index_cnt;
   		else 
   		  index_cnt <= index_cnt + 1;  //send out 32bit block input msg 
	 else 
	   index_cnt <= index_cnt;
end

//output 32bits data block from the 256 bits msg to the core function
assign idata32 = index_cnt== 1? idata_r[16*32-1:15*32]:
								 index_cnt== 2? idata_r[15*32-1:14*32]:
								 index_cnt== 3? idata_r[14*32-1:13*32]:
								 index_cnt== 4? idata_r[13*32-1:12*32]:
								 index_cnt== 5? idata_r[12*32-1:11*32]:
								 index_cnt== 6? idata_r[11*32-1:10*32]:
								 index_cnt== 7? idata_r[10*32-1: 9*32]:
								 index_cnt== 8? idata_r[ 9*32-1: 8*32]:
								 index_cnt== 9? idata_r[ 8*32-1: 7*32]:
								 index_cnt==10? idata_r[ 7*32-1: 6*32]:
								 index_cnt==11? idata_r[ 6*32-1: 5*32]:
								 index_cnt==12? idata_r[ 5*32-1: 4*32]:
								 index_cnt==13? idata_r[ 4*32-1: 3*32]:
								 index_cnt==14? idata_r[ 3*32-1: 2*32]:
								 index_cnt==15? idata_r[ 2*32-1: 1*32]:
								 								idata_r[ 1*32-1: 0*32];

//generate the enable signal for the round function in core
assign EN = ((state == 3'b010) && (index_cnt>0))? busy_high : 1'b0;

//serial-16bits input to parallel-256bits message using shift registers
always @(posedge clk or negedge rst_n) 
begin
	if (~rst_n) 
			idata_r <= 32'h00000000;
	else if (state == 3'b001) //loading
			idata_r <= {idata_r[31*16-1:30*16],
									idata_r[30*16-1:29*16],
									idata_r[29*16-1:28*16],
									idata_r[28*16-1:27*16],
									idata_r[27*16-1:26*16],
									idata_r[26*16-1:25*16],
									idata_r[25*16-1:24*16],
									idata_r[24*16-1:23*16],
									idata_r[23*16-1:22*16],
									idata_r[22*16-1:21*16],
									idata_r[21*16-1:20*16],
									idata_r[20*16-1:19*16],
									idata_r[19*16-1:18*16],
									idata_r[18*16-1:17*16],
									idata_r[17*16-1:16*16],
									idata_r[16*16-1:15*16],
									idata_r[15*16-1:14*16],
									idata_r[14*16-1:13*16],
									idata_r[13*16-1:12*16],
									idata_r[12*16-1:11*16],
									idata_r[11*16-1:10*16],
									idata_r[10*16-1: 9*16],
									idata_r[ 9*16-1: 8*16],
									idata_r[ 8*16-1: 7*16],
									idata_r[ 7*16-1: 6*16],
									idata_r[ 6*16-1: 5*16],
									idata_r[ 5*16-1: 4*16],
									idata_r[ 4*16-1: 3*16],
									idata_r[ 3*16-1: 2*16],
									idata_r[ 2*16-1: 1*16],
									idata_r[ 1*16-1: 0*16],
									idata};
	else 
	  idata_r <= idata_r;
end

//generate the 1 pulse signal to identify the enable of the core function
assign busy_st = (state==1&&Dnum==31)?1:0;

//generate the 1 pulse signal to identify the end of the core function
assign busy_end = ~busy & busy_del;
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n) begin
		busy_del <=0;
	end
	else begin
		busy_del <=busy;
	end
end

//busy period for core function
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n) begin
		busy_high <=0;
	end
	else if (busy_st) begin
		busy_high <=1;
	end
	else if (busy_end) begin
		busy_high  <=0;
	end
	else begin
		busy_high <=busy_high;
	end
end

//generate the valid busy signal for core function
assign busy_valid = busy_high && (~busy_end);

//FSMs
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n) 
	  state <= 3'b000;
  else 
    state <= next_state;
end

always @(load or fetch or state or busy_high) 
begin    
   case (state)
      3'b000://IDLE 
      begin
         if (load) 
           next_state <= 3'b001;                     
         else if (fetch) 
           next_state <= 3'b011;              
         else 
           next_state <= 3'b000;
      end

      3'b001://LOAD
      begin
      	next_state <= 3'b010;          
      end 

      3'b010://UDPATE
      begin                          
        if (~busy_high) 
          next_state <= 3'b000;
        else 
          next_state <= 3'b010;
      end
      
      3'b011://FETCH
      begin
      	next_state <= 3'b100;           
      end
      
      3'b100://WAIT
      begin
      	next_state <= 3'b000;          
      end

      default: 
      begin
      	next_state <= 3'b000;
      end
      
   endcase
end

endmodule
