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

module SHABAL_PERMUTATION(
	                       a0_in, 
	                       a11_in, 
	                       b0_in, 
	                       b6_in, 
	                       b9_in, 
	                       b13_in, 
	                       c8_in, 
	                       m0_in,
	                       a11_out, 
	                       b15_out
                         );

input  [31:0] a0_in, a11_in, b0_in, b6_in, b9_in, b13_in, c8_in, m0_in;
output [31:0] a11_out, b15_out;

wire [31:0] a11_lotate15, V_answer, U_answer, b0_lotate1, b_group_out;

assign a11_lotate15 = {a11_in[16:0],a11_in[31:17]};
assign V_answer = {a11_lotate15[29:0],2'h0} + a11_lotate15;
assign U_answer = {(V_answer[30:0] ^ a0_in[30:0] ^ c8_in[30:0]),1'h0} + (V_answer ^ a0_in ^ c8_in);
assign b0_lotate1 = {b0_in[30:0],b0_in[31]};
assign b_group_out = (~b6_in & b9_in) ^ b13_in;
assign a11_out = U_answer ^ m0_in ^ b_group_out;
assign b15_out = ~a11_out ^ b0_lotate1;

endmodule
