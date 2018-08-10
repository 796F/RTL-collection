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

module HAMSI_TOP(
	              clk, 
	              rst_n,               
	              init, 
	              load, 
	              fetch, 
	              idata, 
	              ack, 
	              odata);   

input         clk, rst_n;
input         init, load, fetch;
input  [15:0] idata;
output        ack;
output [15:0] odata;

wire [15:0] debug;
wire        init_r, EOM_r, EN;
wire [31:0] idata_r;
wire        busy;
wire [31:0] hash0;
wire [31:0] hash1;
wire [31:0] hash2;
wire [31:0] hash3;
wire [31:0] hash4;
wire [31:0] hash5;
wire [31:0] hash6;
wire [31:0] hash7;
wire        finAll;
reg         EOM;
wire [7:0] led;

always @(posedge clk or negedge rst_n) 
begin
   if(!rst_n)
	EOM <= 0;
   else if(load || init)
	EOM <= 0;
   else if(fetch)
	EOM <= 1;
   else
	EOM <= EOM;
end

/* instance */
HAMSI_INTERFACE hamsi_interface(
   .clk(clk), .rst_n(rst_n), .EOM(EOM),
   .init(init), .load(load), .fetch(fetch), .idata(idata),
   .ack(ack), .odata(odata),
   .busy(busy), .hash0(hash0), .hash1(hash1), .hash2(hash2), .hash3(hash3), .hash4(hash4), .hash5(hash5), .hash6(hash6), .hash7(hash7),
   .init_r(init_r), .EN(EN), .idata_r(idata_r), .finAll(finAll)
);

HAMSI_CORE hamsi_core(
   .clk(clk), .rst_n(rst_n), .load(load),
   .init_r(init_r), .EOM_r(EOM), .EN(EN), .idata_r(idata_r),
   .busy(busy), .hash0(hash0), .hash1(hash1), .hash2(hash2), .hash3(hash3), .hash4(hash4), .hash5(hash5), .hash6(hash6), .hash7(hash7),
   .finAll(finAll)
);

endmodule











