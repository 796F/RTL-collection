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
module CubeHash_TOP(
                   clk, 
                   rst_n,
                   init, 
                   load, 
                   fetch,
                   idata, 
                   odata,
                   ack);
input         clk;
input         rst_n;
input         init;
input         load;
input         fetch;
input  [15:0] idata;
output        ack;
output [15:0] odata;

wire [255:0] msg;
wire [255:0] hash;
wire         busy;
wire         start;

CubeHash_INTERFACE CubeHash_interface(
   .clk(clk), 
   .rst_n(rst_n),
   .load(load), 
   .fetch(fetch),
   .idata(idata), 
   .odata(odata),
   .busy(busy), 
   .start(start), 
   .ack(ack),
   .msg(msg), 
   .hash(hash));

CubeHash_CORE CubeHash_core(
   .clk(clk), 
   .rst_n(rst_n),
   .init(init), 
   .busy(busy), 
   .start(start), 
   .msg(msg), 
   .hash(hash), 
   .fetch(fetch), 
   .load(load));

endmodule


