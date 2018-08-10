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
module SKEIN_MIX_FUNCTION(
                          x0, 
                          x1, 
                          Rj, 
                          Rd, 
                          y0, 
                          y1);
input  [63:0] x0;
input  [63:0] x1;
input         Rj;
input  [ 2:0] Rd;
output [63:0] y0;
output [63:0] y1;

reg [63:0] rotate;  //wire

always @(x1, Rd, Rj) begin
   if (~Rj) begin
      case(Rd)
         3'h0  :  rotate = {x1[49:0],x1[63:50]};
         3'h1  :  rotate = {x1[11:0],x1[63:12]};
         3'h2  :  rotate = {x1[40:0],x1[63:41]};
         3'h3  :  rotate = {x1[58:0],x1[63:59]};
         3'h4  :  rotate = {x1[38:0],x1[63:39]};
         3'h5  :  rotate = {x1[17:0],x1[63:18]};
         3'h6  :  rotate = {x1[ 5:0],x1[63:06]};
         3'h7  :  rotate = {x1[31:0],x1[63:32]};
         default  :  rotate = 0;
      endcase
   end
   else begin
      case(Rd)
         3'h0  :  rotate = {x1[47:0],x1[63:48]};
         3'h1  :  rotate = {x1[06:0],x1[63:07]};
         3'h2  :  rotate = {x1[23:0],x1[63:24]};
         3'h3  :  rotate = {x1[26:0],x1[63:27]};
         3'h4  :  rotate = {x1[30:0],x1[63:31]};
         3'h5  :  rotate = {x1[51:0],x1[63:52]};
         3'h6  :  rotate = {x1[41:0],x1[63:42]};
         3'h7  :  rotate = {x1[31:0],x1[63:32]};
         default  :  rotate = 0;
      endcase
   end
end

assign y0 = x0 + x1;
assign y1 = y0 ^ rotate;


endmodule


