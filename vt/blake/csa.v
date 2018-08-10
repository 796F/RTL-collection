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

module CSA(
          input  [31:0] x,
          input  [31:0] y,
          input  [31:0] z,
          output [31:0] vs,
          output [31:0] vc
);

assign vs = x ^ y ^ z;
assign vc = {((x[30:0] & y[30:0]) | ((x[30:0] ^ y[30:0]) & z[30:0])),1'b0};

endmodule
