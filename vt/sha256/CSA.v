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
`timescale 1ns/1ns  

module CSA( 
            X,   
            Y,   
            Z,   
            VS,  
            VC   
            );
input  [31:0] X;
input  [31:0] Y;
input  [31:0] Z;
output [31:0] VS;
output [31:0] VC;

assign VS = X ^ Y ^ Z;
assign VC = {((X[30:0] & Y[30:0]) | ((X[30:0] ^ Y[30:0]) & Z[30:0])),1'b0};

endmodule
