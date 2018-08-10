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
module SKEIN_INTERFACE(
                       clk, 
                       rst_n, 
                       init,
                       load, 
                       fetch, 
                       idata, 
                       odata, 
                       busy, 
                       start, 
                       ack,
                       m0, 
                       m1, 
                       m2, 
                       m3, 
                       m4, 
                       m5, 
                       m6, 
                       m7,
                       hash0, 
                       hash1, 
                       hash2, 
                       hash3,
                       hash4, 
                       hash5, 
                       hash6, 
                       hash7,
                       Ld_tweak, 
                       Ld_posi
                       );

input        clk;
input        rst_n;
input        load;
input        fetch;
input [15:0] idata;
input        busy;
input        init;
input [31:0] hash0;
input [31:0] hash1;
input [31:0] hash2;
input [31:0] hash3;
input [31:0] hash4;
input [31:0] hash5;
input [31:0] hash6;
input [31:0] hash7;
output [15:0] odata;
output start;
output ack;
output reg [31:0] m0;
output reg [31:0] m1;
output reg [31:0] m2;
output reg [31:0] m3;
output reg [31:0] m4;
output reg [31:0] m5;
output reg [31:0] m6;
output reg [31:0] m7;
output Ld_tweak;
output Ld_posi;

reg [ 5:0] count;
reg [15:0] odata_r;
reg [ 2:0] state;
reg [ 2:0] next_state;
reg        ack_r;
reg        lengthRec;
reg        loadStart;

assign odata = odata_r;                                

always @(posedge clk or negedge rst_n)begin
   if (~rst_n) odata_r <= 16'h0000;                    
   else begin
      if (state == 3'b011) begin                       
         if (count == 'h0) odata_r <= {hash1[07:00],hash1[15:8]}; 
         else if (count == 'h1) odata_r <= {hash1[23:16],hash1[31:24]};
         else if (count == 'h2) odata_r <= {hash0[07:00],hash0[15:8]};
         else if (count == 'h3) odata_r <= {hash0[23:16],hash0[31:24]};
         else if (count == 'h4) odata_r <= {hash3[07:00],hash3[15:08]};
         else if (count == 'h5) odata_r <= {hash3[23:16],hash3[31:24]};
         else if (count == 'h6) odata_r <= {hash2[07:00],hash2[15:8]};
         else if (count == 'h7) odata_r <= {hash2[23:16],hash2[31:24]};
         else if (count == 'h8) odata_r <= {hash5[07:00],hash5[15:8]};
         else if (count == 'h9) odata_r <= {hash5[23:16],hash5[31:24]};
         else if (count == 'ha) odata_r <= {hash4[07:00],hash4[15:8]};
         else if (count == 'hb) odata_r <= {hash4[23:16],hash4[31:24]};
         else if (count == 'hc) odata_r <= {hash7[07:00],hash7[15:8]};
         else if (count == 'hd) odata_r <= {hash7[23:16],hash7[31:24]};
         else if (count == 'he) odata_r <= {hash6[07:00],hash6[15:8]};
         else if (count == 'hf) odata_r <= {hash6[23:16],hash6[31:24]};
      end
      else odata_r <= odata_r;
   end
end

always @(posedge clk or negedge rst_n)
begin
   if (~rst_n)
      lengthRec <= 0;
   else if (fetch|init)
      lengthRec <= 0;
   else if ((count == 6'h3) && (state == 3'b001))
      lengthRec <= 1;
   else
      lengthRec <= lengthRec;
end

always @(posedge clk or negedge rst_n)
begin
   if (~rst_n)
      loadStart <= 0;
   else if (fetch|init)
      loadStart <= 0;
   else if ((lengthRec == 1'h1) && (count == 6'h0))
      loadStart <= 1;
   else
      loadStart <= loadStart;

end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m0 <= 0;
   else if ((state == 3'b001) && ~count[0]) m0 <= m1;
   else m0 <= m0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m1 <= 0;
   else if ((state == 3'b001) && ~count[0]) m1 <= m2;
   else m1 <= m1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m2 <= 0;
   else if ((state == 3'b001) && ~count[0]) m2 <= m3;
   else m2 <= m2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m3 <= 0;
   else if ((state == 3'b001) && ~count[0]) m3 <= m4;
   else m3 <= m3;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m4 <= 0;
   else if ((state == 3'b001) && ~count[0]) m4 <= m5;
   else m4 <= m4;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m5 <= 0;
   else if ((state == 3'b001) && ~count[0]) m5 <= m6;
   else m5 <= m5;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m6 <= 0;
   else if ((state == 3'b001) && ~count[0]) m6 <= m7;
   else m6 <= m6;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) m7 <= 0;
   else if (state == 3'b001) m7 <= {m7[15:0],idata};
   else m7 <= m7;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) count <= 0;
   else if ((state == 3'b100) && (count == 6'hf)) count <= 0;
   else if ((state == 3'b001) && (count == 6'hf)) count <= 0;
   else if ((state == 3'b001) && (lengthRec == 0) && (count == 6'h3)) count <= 0;
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

assign start = ((state == 3'b010) && ack && (count == 7'h00) && (loadStart))? 1:0;


assign Ld_tweak = ((state == 3'b001) && (count == 6'h4))? 1:0;
assign Ld_posi = ((state == 3'b001) && (count <= 6'h3) && (~lengthRec))? 1:0;

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
