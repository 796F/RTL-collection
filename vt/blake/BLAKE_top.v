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

module blake_top(
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

wire [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7;
wire [63:0] counter;
wire [31:0] idata32;
wire        Ld_EN;
wire        busy;
wire        start;

BLAKE_INTERFACE BLAKE_interface(
   .clk(clk), .rst_n(rst_n), .init(init),
   .load(load), .fetch(fetch),
   .idata(idata), .odata(odata), .idata32(idata32), .counter(counter),
   .busy(busy), .start(start), .ack(ack), .Ld_EN(Ld_EN),
   .hash0(hash0), .hash1(hash1), .hash2(hash2), .hash3(hash3),
   .hash4(hash4), .hash5(hash5), .hash6(hash6), .hash7(hash7) 
);

BLAKE_CORE BLAKE_core(
   .clk(clk), .rst_n(rst_n),
   .init(init), .busy(busy), .Ld_EN(Ld_EN), .idata32(idata32), 
   .hash0(hash0), .hash1(hash1), .hash2(hash2), .hash3(hash3),
   .hash4(hash4), .hash5(hash5), .hash6(hash6), .hash7(hash7),
   .counter({counter[31:0],counter[63:32]}), .start(start)
);

endmodule

