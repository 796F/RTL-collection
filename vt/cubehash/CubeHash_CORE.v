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
module CubeHash_CORE(clk, 
                     rst_n, 
                     init, 
                     msg, 
                     start, 
                     busy, 
                     hash, 
                     fetch, 
                     load);


input          clk;
input          rst_n;
input          fetch;
input          init;
input  [255:0] msg;
input          load;
input          start;
output         busy;
output [255:0] hash;

parameter r = 16;
parameter h = 256;
parameter b = 31;
parameter IV = 1024'hea2bd4b4_ccd6f29f_63117e71_35481eae_22512d5b_e5d94e63_7e624131_f4cc12be_c2d0b696_42af2070_d0720c35_3361da8c_28cceca4_8ef8ad83_4680ac00_40e5fbab_d89041c3_6107fbd5_6c859d41_f0b26679_09392549_5fa25603_65c892fd_93cb6285_2af2b5ae_9e4b4e60_774abfdd_85254725_15815aeb_4ab6aad6_9cdaf8af_d6032c0a;

wire [1023:0] Rin;
wire [1023:0] Rout;
wire [1023:0] chain;
wire          busy;
reg  [1023:0] state;
reg  [   4:0] round;
reg  [   3:0] finalize_count;
reg           init_r;
reg           finalProcess;

always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
 	  finalProcess <= 0;
	else if(load)
	  finalProcess <= 0;
	else if(fetch)
	  finalProcess <= 1;
	else
	  finalProcess <= finalProcess;
end 

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) init_r <= 0;
   else init_r <= init;
end
   
assign hash = state[1023:768];

CubeHash_ROUND cubehash_round(.Rin(Rin), .Rout(Rout));

assign Rin = (((round == r) && (finalize_count == 1)) || (fetch && ~finalProcess && (round == 0)))? {state[1023:1],state[0]^1'b1} :
   (start)? {state[1023:768]^msg,state[767:0]} : state;

assign chain = (init_r)? IV : Rout;

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state <= 0;
   else if (start | init_r | busy) state <= chain;
   else state <= state;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) round <= 0;
   else if (start) round <= 1;
   else if ((fetch) && (~finalProcess) && (round == 0)) round <= 1;
   else if (busy) begin
      if (round == r-1) begin
         if (~fetch) round <= 0;
         else if (finalize_count == 4'ha) round <= 0;
         else round <= round + 1;
      end
      else if (round == r) round <= 1; 
      else round <= round + 1;
   end

   else round <= round;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) finalize_count <= 0;
   else if (round == (r-1'b1)) begin
      if (finalize_count == 4'ha) finalize_count <= 0;
      else if (fetch) finalize_count <= finalize_count + 1;
   end
   else if ((fetch) && (~finalProcess) && (round == 0)) finalize_count <= 1;
   else finalize_count <= finalize_count;
end
     
assign busy = (~start && (round == 0) && ~(finalProcess ^ fetch))? 0 : 1;

endmodule
   

