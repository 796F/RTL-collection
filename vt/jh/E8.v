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

module E8 (round_in, 
		       S_box, 
		       state_A_in, 
		       state_H_in, 
		       half, 
		       start, 
		       state_A_out, 
		       state_H_out, 
		       round_out
		       );

input [64*4-1:0] round_in;
input [16*2*4-1:0] S_box;
input [256*4-1:0] state_A_in;
input [128*8-1:0] state_H_in;
input half;
input start;

output [256*4-1:0] state_A_out;
output [128*8-1:0] state_H_out;
output [64*4-1:0] round_out;

wire [3:0] init_group [255:0]; //refering to tem
wire [3:0] stat_A_mod [255:0]; //stat_A coming out of R8
wire [3:0] R8_stat_A_in_array [255:0];
wire [256*4-1:0] R8_stat_A_in; //stat_A going into R8
wire [64*4-1:0] updated_round;
wire [64*4-1:0] round_in_rev;
wire [3:0] state_A_out_arr [255:0];
wire [3:0] degrouped [255:0]; //refering to tem after degrouping stage

R8 myR8 (.round_in(round_in_rev), 
		     .S_box(S_box), 
		     .state_A_in(R8_stat_A_in), 
		     .half(half), 
		     .state_A_out(state_A_out)
		     ); 
		 
update_roundconst myUpdate (.round_in(round_in), 
							              .S_box(S_box [63:0]), 
							              .round_out(round_out)
							              );

genvar i;
generate
	for(i=0; i<256; i=i+4)
	begin: rnd_rev
		assign round_in_rev [i] = round_in [i+3];
		assign round_in_rev [i+1] = round_in [i+2];
		assign round_in_rev [i+2] = round_in [i+1];
		assign round_in_rev [i+3] = round_in [i];
	end		
	
	for(i=0; i<256; i=i+1)
	begin: init_grouping
		assign init_group [i] = {state_H_in [7 + (i >> 3) * 8 - (i & 7)], state_H_in [7 + ((i + 256) >> 3) * 8 - (i & 7)], state_H_in [7 + ((i + 512) >> 3) * 8 - (i & 7)], state_H_in [7 + ((i + 768) >> 3) * 8 - (i & 7)]};
	end
	
	for(i=0; i<128; i=i+1)
	begin: split1
		assign stat_A_mod [i << 1] = init_group [i];
		assign stat_A_mod [(i << 1) + 1] = init_group [i+128];
	end
	
	for(i=0; i<256; i=i+1)
	begin: choose_stat_A
		assign R8_stat_A_in_array [i] = (start) ? stat_A_mod [i] : state_A_in [i*4+3:i*4];
	end
	
	for(i=0; i<256; i=i+1)
	begin: state_A_conv
		assign R8_stat_A_in [i*4+3:i*4] = R8_stat_A_in_array [i];
	end

	for(i=0; i<256; i=i+1)
	begin: state_A_out_array
		assign state_A_out_arr [i] = state_A_out [i*4+3:i*4];
	end
	
	for(i=0; i<128; i=i+1)
	begin: debgrouping
		assign degrouped [i] = state_A_out_arr [i << 1];
		assign degrouped [i+128] = state_A_out_arr [(i << 1) + 1];
	end
	
	for(i=0; i < 256; i=i+1)
	begin: state_H
		assign state_H_out [7 + (i >> 3) * 8 - (i & 7)] = degrouped [i] [3];
		assign state_H_out [7 + ((i + 256) >> 3) * 8 - (i & 7)] = degrouped [i] [2];
		assign state_H_out [7 + ((i + 512) >> 3) * 8 - (i & 7)] = degrouped [i] [1];
		assign state_H_out [7 + ((i + 768) >> 3) * 8 - (i & 7)] = degrouped [i] [0];
	end
endgenerate	

endmodule 