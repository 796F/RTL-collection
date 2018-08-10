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

module ROM(
           clk, 
           K, 
           RD, 
           addr
           );

input         clk;
input         RD;
input  [ 5:0] addr;
output [31:0] K;

reg    [31:0] K;
   
always @(posedge clk) begin
	if (RD) begin
		case (addr)
		    6'd0    : K <= 32'h428a2f98; 
		    6'd1    : K <= 32'h71374491; 
		    6'd2    : K <= 32'hb5c0fbcf; 
		    6'd3    : K <= 32'he9b5dba5; 
		    6'd4    : K <= 32'h3956c25b; 
		    6'd5    : K <= 32'h59f111f1; 
		    6'd6    : K <= 32'h923f82a4; 
		    6'd7    : K <= 32'hab1c5ed5; 
		    6'd8    : K <= 32'hd807aa98; 
		    6'd9    : K <= 32'h12835b01; 
		    6'd10   : K <= 32'h243185be;
		    6'd11   : K <= 32'h550c7dc3;
		    6'd12   : K <= 32'h72be5d74;
		    6'd13   : K <= 32'h80deb1fe;
		    6'd14   : K <= 32'h9bdc06a7;
		    6'd15   : K <= 32'hc19bf174;
		    6'd16   : K <= 32'he49b69c1;
		    6'd17   : K <= 32'hefbe4786;
		    6'd18   : K <= 32'h0fc19dc6;
		    6'd19   : K <= 32'h240ca1cc;
		    6'd20   : K <= 32'h2de92c6f;
		    6'd21   : K <= 32'h4a7484aa;
		    6'd22   : K <= 32'h5cb0a9dc;
		    6'd23   : K <= 32'h76f988da;
		    6'd24   : K <= 32'h983e5152;
		    6'd25   : K <= 32'ha831c66d;
		    6'd26   : K <= 32'hb00327c8;
		    6'd27   : K <= 32'hbf597fc7;
		    6'd28   : K <= 32'hc6e00bf3;
		    6'd29   : K <= 32'hd5a79147;
		    6'd30   : K <= 32'h06ca6351;
		    6'd31   : K <= 32'h14292967;
		    6'd32   : K <= 32'h27b70a85;
		    6'd33   : K <= 32'h2e1b2138;
		    6'd34   : K <= 32'h4d2c6dfc;
		    6'd35   : K <= 32'h53380d13;
		    6'd36   : K <= 32'h650a7354;
		    6'd37   : K <= 32'h766a0abb;
		    6'd38   : K <= 32'h81c2c92e;
		    6'd39   : K <= 32'h92722c85;
		    6'd40   : K <= 32'ha2bfe8a1;
		    6'd41   : K <= 32'ha81a664b;
		    6'd42   : K <= 32'hc24b8b70;
		    6'd43   : K <= 32'hc76c51a3;
		    6'd44   : K <= 32'hd192e819;
		    6'd45   : K <= 32'hd6990624;
		    6'd46   : K <= 32'hf40e3585;
		    6'd47   : K <= 32'h106aa070;
		    6'd48   : K <= 32'h19a4c116;
		    6'd49   : K <= 32'h1e376c08;
		    6'd50   : K <= 32'h2748774c;
		    6'd51   : K <= 32'h34b0bcb5;
		    6'd52   : K <= 32'h391c0cb3;
		    6'd53   : K <= 32'h4ed8aa4a;
		    6'd54   : K <= 32'h5b9cca4f;
		    6'd55   : K <= 32'h682e6ff3;
		    6'd56   : K <= 32'h748f82ee;
		    6'd57   : K <= 32'h78a5636f;
		    6'd58   : K <= 32'h84c87814;
		    6'd59   : K <= 32'h8cc70208;
		    6'd60   : K <= 32'h90befffa;
		    6'd61   : K <= 32'ha4506ceb;
		    6'd62   : K <= 32'hbef9a3f7;
		    6'd63   : K <= 32'hc67178f2;
		    default : K <= 32'h00000000;
	    	endcase
    	end
end

endmodule

