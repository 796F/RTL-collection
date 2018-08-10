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
module GROESTL_INTERFACE(
                        clk, 
                        rst_n, 
                        load, 
                        fetch, 
                        odata,  
                        busy, 
                        start, 
                        ack, 
                        Ld_msg, 
                        hash);

input          clk;
input          rst_n;
input          load;
input          fetch;
input          busy;
input  [255:0] hash;
output [ 15:0] odata;
output         start;
output         ack;
output         Ld_msg;

reg [ 6:0] count;
reg [15:0] odata_r;
reg [ 2:0] state;
reg [ 2:0] next_state;
reg        ack_r;

assign odata = odata_r;                                     

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) odata_r <= 16'h0000;                    
   else begin
      if (state == 3'b011) begin                       
         if (count == 'h0) odata_r <= hash[255:240]; 
         else if (count == 'h1) odata_r <= hash[239:224];
         else if (count == 'h2) odata_r <= hash[223:208];
         else if (count == 'h3) odata_r <= hash[207:192];
         else if (count == 'h4) odata_r <= hash[191:176];
         else if (count == 'h5) odata_r <= hash[175:160];
         else if (count == 'h6) odata_r <= hash[159:144];
         else if (count == 'h7) odata_r <= hash[143:128];
         else if (count == 'h8) odata_r <= hash[127:112];
         else if (count == 'h9) odata_r <= hash[111: 96];
         else if (count == 'ha) odata_r <= hash[ 95: 80];
         else if (count == 'hb) odata_r <= hash[ 89: 64];
         else if (count == 'hc) odata_r <= hash[ 63: 48];
         else if (count == 'hd) odata_r <= hash[ 47: 32];
         else if (count == 'he) odata_r <= hash[ 31: 16];
         else if (count == 'hf) odata_r <= hash[ 15:  0];
      end
      else odata_r <= odata_r;
   end
end

assign Ld_msg = ((state == 3'b001))? 1:0; 

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) count <= 0;
   else if ((state == 3'b100) && (count == 7'hf)) count <= 0;
   else if ((state == 3'b001) && (count == 7'h1f)) count <= 0;
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

assign start = ((state == 3'b010) && ack && (count == 7'h00))? 1:0;

always @(posedge clk or negedge rst_n)begin
	if (~rst_n) state <= 3'b000;
   else state <= next_state;
end

always @(load or fetch or state or busy) begin    
   case (state)
      3'b000      : begin                         
         if (load) next_state <= 3'b001;                     
         else if (fetch && ~busy) next_state <= 3'b011;              
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

