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

module do_reduce(ai, 
				 ao);
	//input
	input signed [16:0] ai;
	
	//output
	output signed [14:0] ao;
	
	wire signed [9:0] diff;
	wire signed [9:0] High8;
	wire signed [9:0] Low8;
	assign High8 = {ai[16],ai[16:8]};
	assign Low8 = {2'b0, ai[7:0]};
	assign diff = Low8 - High8;
	assign ao = {{5{diff[9]}},diff};
endmodule