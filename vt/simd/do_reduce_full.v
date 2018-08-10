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
module do_reduce_full(ai, 
					            ao
					            );
	//input
	input signed [14:0] ai;
	
	//output
	output signed [8:0] ao;
	
	
	wire signed [14:0] reduce_out;
	wire signed [9:0] diff;
	do_reduce full_do_reduce({{2{ai[14]}},ai},reduce_out);
	assign diff = reduce_out - 257;		
	assign ao = (reduce_out <= 128) ? reduce_out : diff;	
endmodule 