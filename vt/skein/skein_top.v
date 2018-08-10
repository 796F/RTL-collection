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
module skein_top(
                clk, 
                rst_n,
                init, 
                load, 
                fetch,
                idata, 
                odata,
                ack
                );
                
input         clk;
input         rst_n;
input         init;
input         load;
input         fetch;
input  [15:0] idata;
output        ack;
output [15:0] odata;

wire [31:0] m0, m1, m2, m3, m4, m5, m6, m7;
wire [63:0] hash0, hash1, hash2, hash3;
wire        Ld_tweak;
wire        Ld_posi;
wire        busy;
wire        start;

SKEIN_INTERFACE skein_interface(
   .clk(clk), 
   .rst_n(rst_n), 
   .init(init),
   .load(load), 
   .fetch(fetch),
   .idata(idata), 
   .odata(odata),
   .busy(busy), 
   .start(start), 
   .ack(ack),
   .m0(m0), 
   .m1(m1), 
   .m2(m2), 
   .m3(m3), 
   .m4(m4), 
   .m5(m5), 
   .m6(m6), 
   .m7(m7),
   .hash0(hash0[63:32]), .hash1(hash0[31:0]), .hash2(hash1[63:32]), .hash3(hash1[31:0]),
   .hash4(hash2[63:32]), .hash5(hash2[31:0]), .hash6(hash3[63:32]), .hash7(hash3[31:0]), 
   .Ld_tweak(Ld_tweak), 
   .Ld_posi(Ld_posi));

SKEIN_CORE skein_core(
   .clk(clk), 
   .rst_n(rst_n),
   .init(init), 
   .busy(busy), 
   .start(start),
   .msg0({m1[7:0],m1[15:8],m1[23:16],m1[31:24],m0[7:0],m0[15:8],m0[23:16],m0[31:24]}),
   .msg1({m3[7:0],m3[15:8],m3[23:16],m3[31:24],m2[7:0],m2[15:8],m2[23:16],m2[31:24]}),
   .msg2({m5[7:0],m5[15:8],m5[23:16],m5[31:24],m4[7:0],m4[15:8],m4[23:16],m4[31:24]}),
   .msg3({m7[7:0],m7[15:8],m7[23:16],m7[31:24],m6[7:0],m6[15:8],m6[23:16],m6[31:24]}),
   .hash0(hash0), 
   .hash1(hash1), 
   .hash2(hash2), 
   .hash3(hash3),
   .Ld_tweak(Ld_tweak), 
   .idata(idata), 
   .Ld_posi(Ld_posi)
   );

endmodule

