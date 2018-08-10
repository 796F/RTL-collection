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
module echo_top(clk, 
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

wire [255:0] hash;
wire         Ld_msg;
wire         Ld_cnt;
wire         busy;
wire         start;

ECHO_INTERFACE echo_interface(
                             .clk(clk), 
                             .rst_n(rst_n),
                             .load(load), 
                             .fetch(fetch),
                             .odata(odata), 
                             .Ld_cnt(Ld_cnt),
                             .busy(busy), 
                             .start(start), 
                             .ack(ack), 
                             .Ld_msg(Ld_msg),
                             .hash(hash));

ECHO_CORE echo_core(
                   .clk(clk), 
                   .rst_n(rst_n),
                   .init(init), 
                   .busy(busy), 
                   .Ld_msg(Ld_msg), 
                   .idata(idata), 
                   .hash(hash),
                   .Ld_cnt(Ld_cnt), 
                   .start(start));

endmodule


