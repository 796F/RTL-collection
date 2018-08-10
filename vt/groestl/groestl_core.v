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
module GROESTL_CORE(
                   clk, 
                   rst_n,
                   init, 
                   start, 
                   busy, 
                   Ld_msg,
                   hash, 
                   idata, 
                   fetch, 
                   load);

input          clk;
input          rst_n;
input          init;
input          start;
input  [ 15:0] idata;
input          fetch;
input          load;
input          Ld_msg;
output [255:0] hash;
output         busy;

reg  [511:0] stateP;
reg  [511:0] stateQ;
reg  [511:0] hash_r;
reg  [  4:0] round;
reg          EN;
reg          init_r;
reg          finProcess;
wire [511:0] cv;
wire [511:0] pout;
wire [511:0] qout;
wire [511:0] pin;
wire [511:0] qin;

assign busy = (start | EN | (finProcess ^ fetch))? 1:0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		finProcess <= 0;
	else if(init_r)
		finProcess <= 0;
	else if(load)
		finProcess <= 0;
	else if(fetch)
		finProcess <= 1;
	else
		finProcess <= finProcess;

end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) EN <= 0;
   else if (start) EN <= 1;
   else if (fetch ^ finProcess) EN <= 1;
   else if (round == 5'h9 && ~fetch) begin
      EN <= 0;
   end
   else if (round == 5'h19) EN <= 0;
   else EN <= EN;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) round <= 0;
   else if (EN) begin
      if (round == 5'h19) round <= 0;
      else if (round == 5'h9) begin 
        if(fetch)
          round <= 5'h10;
        else
          round <=0;
      end
      else round <= round + 1;
   end
   else if (fetch ^ finProcess ) round <= 5'h10;
   else round <= round;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) init_r <= 0;
   else init_r <= init;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) stateQ <= 0;
   else if (Ld_msg) stateQ <= {stateQ[496:0],idata};
   else if (EN) stateQ <= qout;
   else stateQ <= stateQ;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) stateP <= 0;
   else if (EN) stateP <= pout;
   else stateP <= stateP;
end

assign cv = hash_r ^ pout;
assign hash = hash_r[255:0];

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) hash_r <= 0;
   else if (init_r) hash_r <= {496'h0,16'h0100};
   else if (round == 5'h9) hash_r <= pout ^ qout ^ hash_r;
   else if (round == 5'h19) hash_r <= cv;
   else hash_r <= hash_r;
end
   
assign pin = (round == 5'h0)? hash_r ^ stateQ : 
   (round == 5'h10)? hash_r : stateP;

assign qin = stateQ;

Permute P(pin, pout, {4'h0,round[3:0]},1'b1);
Permute Q(qin, qout, {4'h0,round[3:0]},1'b0);

endmodule
