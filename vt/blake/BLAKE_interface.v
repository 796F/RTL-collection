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

module BLAKE_INTERFACE(
                       clk, 
                       rst_n, 
                       init,
                       load, 
                       fetch, 
                       idata, 
                       odata, 
                       idata32, 
                       counter, 
                       busy, 
                       start, 
                       ack, 
                       Ld_EN,
                       hash0, 
                       hash1, 
                       hash2, 
                       hash3, 
                       hash4, 
                       hash5, 
                       hash6, 
                       hash7);

input clk;
input rst_n;
input load;
input fetch;
input busy;
input init;
input  [15:0] idata;
input  [31:0] hash0;
input  [31:0] hash1;
input  [31:0] hash2;
input  [31:0] hash3;
input  [31:0] hash4;
input  [31:0] hash5;
input  [31:0] hash6;
input  [31:0] hash7;
output [15:0] odata;
output start;
output ack;
output Ld_EN;
output reg [63:0] counter;
output [31:0] idata32;

reg [ 5:0] count;
reg [15:0] odata_r;
reg [ 2:0] state;
reg [ 2:0] next_state;
reg        ack_r;
reg [15:0] idata_r;
reg        lengthFin; //finish loading length information
reg [63:0] length;
reg        loadStart;

assign odata = odata_r;

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) odata_r <= 16'h0000;                     //reset
   else begin
      if (state == 3'b011) begin                     
         if (count == 'h0) odata_r <= hash0[31:16]; 
         else if (count == 'h1) odata_r <= hash0[15:0];
         else if (count == 'h2) odata_r <= hash1[31:16];
         else if (count == 'h3) odata_r <= hash1[15:0];
         else if (count == 'h4) odata_r <= hash2[31:16];
         else if (count == 'h5) odata_r <= hash2[15:0];
         else if (count == 'h6) odata_r <= hash3[31:16];
         else if (count == 'h7) odata_r <= hash3[15:0];
         else if (count == 'h8) odata_r <= hash4[31:16];
         else if (count == 'h9) odata_r <= hash4[15:0];
         else if (count == 'ha) odata_r <= hash5[31:16];
         else if (count == 'hb) odata_r <= hash5[15:0];
         else if (count == 'hc) odata_r <= hash6[31:16];
         else if (count == 'hd) odata_r <= hash6[15:0];
         else if (count == 'he) odata_r <= hash7[31:16];
         else if (count == 'hf) odata_r <= hash7[15:0];
      end
      else odata_r <= odata_r;
   end
end

assign idata32 = {idata_r,idata};

always @(posedge clk or negedge rst_n) 
begin
   if (~rst_n)  
      loadStart <= 1'h0;
   else if (fetch|init)
      loadStart <= 1'h0;
   else if ((lengthFin == 1) && (count == 1))
      loadStart <= 1'h1;
   else
      loadStart <= loadStart;
end

always @(posedge clk or negedge rst_n) 
begin
   if (~rst_n)  
      lengthFin <= 1'h0;
   else if (fetch|init)
      lengthFin <= 1'h0;
   else if ((state == 3'b001) && (count == 3))
      lengthFin <= 1'h1;
   else
      lengthFin <= lengthFin;
end

always @(posedge clk or negedge rst_n) 
begin
   if (~rst_n)  
      length <= 64'h0;
   else if ((state == 3'b001) && (lengthFin == 1'h0))
      length <= (length<<16) | {48'h0,idata};

   else
      length <= length;

end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) counter <= 0;

   else if (count == 6'h10 && state == 3'b001) //count should be set to anything less than total # of load buit greater than # of load to get length
       counter <= ((counter + 512) > length)? ((counter == length)? 0:length) : (counter + 512);
   else counter <= counter;
end


always @(posedge clk or negedge rst_n) begin
   if (~rst_n) idata_r <= 0;
   else if (state == 3'b001 && ~count[0]) idata_r <= idata;
   else idata_r <= idata_r;
end

assign Ld_EN = ((state == 3'b001) && (lengthFin==1'h1) && count[0])? 1:0; 


always @(posedge clk or negedge rst_n) begin
   if (~rst_n) count <= 0;
   else if ((state == 3'b100) && (count == 6'hf)) count <= 0;
   else if ((state == 3'b001) && (count == 6'h1f)) count <= 0;
   else if ((state == 3'b001) && (lengthFin == 0) && (count == 6'h3)) count <= 0;
   else if ((state == 3'b001) || (state == 3'b100)) count <= count + 1;  
   else count <= count;
end

assign ack = ack_r;
always @(posedge clk or negedge rst_n)begin
   if (~rst_n) ack_r <= 0;                      
   else begin
      if (state == 3'b011) ack_r <= 1;          
      else if (state == 3'b001) ack_r <= 1;     
      else ack_r <= 0;
   end
end

assign start = ((state == 3'b010) && ack && (count == 6'h00) && (loadStart))? 1:0;

always @(posedge clk or negedge rst_n)begin
	if (~rst_n) state <= 3'b000;
   else state <= next_state;
end

always @(load or fetch or state or busy) begin  
   case (state)
      3'b000      : begin                       
         if (load) next_state <= 3'b001;                     
         else if (fetch) next_state <= 3'b011;              
         else next_state <= 3'b000;
      end

      3'b001  : next_state <= 3'b010;           

      3'b010  : begin                           
         if (~busy) next_state <= 3'b000;       
         else next_state <= 3'b010;
      end
      
      3'b011 : next_state <= 3'b100;            
      
      3'b100  : next_state <= 3'b000;           

      default: next_state <= 3'b000;
   endcase
end

endmodule 

