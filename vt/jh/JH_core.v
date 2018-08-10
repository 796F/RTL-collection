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
module JH_core(
	            input  clk,	
	            input  rst_n,
	            input  EN,	
              input  init,
	            input  [511:0] idata,
	            output [511:0] odata,
              output fin);
	
wire [1023:0] state_H;

F8 F8(.clk(clk), 
		  .rst_n(rst_n), 
		  .enable(EN), 
		  .buffer(idata), 
		  .init(init),
		  .state_H_O(state_H),
		  .done(fin)
		  );

assign odata = state_H [1023:512];

endmodule 