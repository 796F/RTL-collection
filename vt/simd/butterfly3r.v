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

module butterfly3r(ai, 
				   bi, 
				   ao, 
				   bo
				   );
	//input
	input signed [14:0] ai;
	input signed [14:0] bi;	
	
	//output
	output signed [14:0] ao;
	output signed [14:0] bo;
	wire signed [16:0] buffer;	
	assign ao = ai + bi;
	assign buffer = ((ai-bi) << 6);
	do_reduce bufReduce(buffer, bo);
endmodule 
