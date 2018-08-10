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
module CubeHash_INTERFACE(clk, 
                          rst_n, 
                          load, 
                          fetch, 
                          idata, 
                          odata, 
                          busy, 
                          start, 
                          ack,
                          msg, 
                          hash);

input          clk;
input          rst_n;
input          load;
input          fetch;
input          busy;
input  [ 15:0] idata;
input  [255:0] hash;
output [ 15:0] odata;
output         start;
output         ack;
output [255:0] msg;

reg [ 5:0] count;
reg [15:0] odata_r;
reg [ 2:0] state;
reg [ 2:0] next_state;
reg [31:0] msg0, msg1, msg2, msg3, msg4, msg5, msg6, msg7;
reg        ack_r;

assign odata = odata_r;                                    
always @(posedge clk or negedge rst_n)begin
   if (~rst_n) odata_r <= 16'h0000;       
   else begin
      if (state == 3'b011) begin          
         if (count == 'h10) odata_r <= {hash[231:224],hash[239:232]}; 
         else if (count == 'h11) odata_r <= {hash[247:240],hash[255:248]};
         else if (count == 'h12) odata_r <= {hash[199:192],hash[207:200]};
         else if (count == 'h13) odata_r <= {hash[215:208],hash[223:216]};
         else if (count == 'h14) odata_r <= {hash[167:160],hash[175:168]};
         else if (count == 'h15) odata_r <= {hash[183:176],hash[191:184]};
         else if (count == 'h16) odata_r <= {hash[135:128],hash[143:136]};
         else if (count == 'h17) odata_r <= {hash[151:144],hash[159:152]};
         else if (count == 'h18) odata_r <= {hash[103:96],hash[111:104]};
         else if (count == 'h19) odata_r <= {hash[119:112],hash[127:120]};
         else if (count == 'h1a) odata_r <= {hash[71:64],hash[79:72]};
         else if (count == 'h1b) odata_r <= {hash[87:80],hash[95:88]};
         else if (count == 'h1c) odata_r <= {hash[39:32],hash[47:40]};
         else if (count == 'h1d) odata_r <= {hash[55:48],hash[63:56]};
         else if (count == 'h1e) odata_r <= {hash[7:0],hash[15:8]};
         else if (count == 'h1f) odata_r <= {hash[23:16],hash[31:24]};
      end
      else odata_r <= odata_r;
   end
end

assign msg = {msg0, msg1, msg2, msg3, msg4, msg5, msg6, msg7};

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg7 <= 0;
   else if (state == 3'b001) msg7 <= {idata[7:0],idata[15:8],msg7[31:16]};
   else msg7 <= msg7;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg6 <= 0;
   else if (state == 3'b001 && ~count[0]) msg6 <= msg7;
   else msg6 <= msg6;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg5 <= 0;
   else if (state == 3'b001 && ~count[0]) msg5 <= msg6;
   else msg5 <= msg5;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg4 <= 0;
   else if (state == 3'b001 && ~count[0]) msg4 <= msg5;
   else msg4 <= msg4;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg3 <= 0;
   else if (state == 3'b001 && ~count[0]) msg3 <= msg4;
   else msg3 <= msg3;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg2 <= 0;
   else if (state == 3'b001 && ~count[0]) msg2 <= msg3;
   else msg2 <= msg2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg1 <= 0;
   else if (state == 3'b001 && ~count[0]) msg1 <= msg2;
   else msg1 <= msg1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg0 <= 0;
   else if (state == 3'b001 && ~count[0]) msg0 <= msg1;
   else msg0 <= msg0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) count <= 0;
   else if ((state == 3'b100) && (count == 6'h1f)) count <= 0;
   else if ((state == 3'b001) && (count == 6'h10)) count <= 1;       
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

assign start = ((state == 3'b010) && ack && (count == 6'h10))? 1:0;

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

