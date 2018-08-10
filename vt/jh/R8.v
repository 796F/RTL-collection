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
module R8 (
           round_in, 
		       S_box,
		       state_A_in, 
		       half, 
		       state_A_out
		       );         
		       
input [64*4-1:0]   round_in;
input [16*2*4-1:0] S_box;
input [256*4-1:0]  state_A_in;
input              half;
output [256*4-1:0] state_A_out;

wire [3:0] state_A_in_array [255:0]; //Array for old state A 
wire [3:0] state_A_out_array [255:0]; //Array for new state A 
wire [3:0] LUT_out [255:0]; //correspond to tem
wire [3:0] S_box_in_array [1:0] [15:0];
wire [3:0] L [255:0]; //tem after linear transform
wire [3:0] init_swap [255:0]; //tem after init swap
wire [3:0] perm [255:0]; //tem after perm
wire [3:0] fin_swap [255:0]; //tem after final swap

genvar i;
generate
	for(i=0; i<256; i=i+1)
	begin: IO_Conv
		assign state_A_in_array [i] = state_A_in [i*4+3:i*4];
		assign state_A_out [i*4+3:i*4] = state_A_out_array [i];
	end
	
	for(i=0; i<16; i=i+1)
	begin: S_box0_conv
		assign S_box_in_array [0] [i] = S_box [i*4+3:i*4];
	end

	for(i=0; i<16; i=i+1)
	begin: S_box1_conv
		assign S_box_in_array [1] [i] = S_box [(i+16)*4+3:(i+16)*4];
	end	
	
	for(i=0; i<256; i=i+1)
	begin: LUT
		assign LUT_out [i] = S_box_in_array [round_in [i]] [state_A_in_array [i]];
	end
	
	for(i=0; i<256; i=i+2)
	begin: L_Trans
		assign L[i] = LUT_out [i] ^ {L [i+1][2:0],1'b0} ^ {3'b0,L [i+1][3]} ^ {2'b0,L [i+1][3],1'b0};
		assign L[i+1] = LUT_out [i+1] ^ {LUT_out [i][2:0],1'b0} ^ {3'b0,LUT_out [i][3]} ^ {2'b0,LUT_out [i][3],1'b0};
	end

	for(i=0; i<256; i=i+4)
	begin: initial_swap
		assign init_swap [i] = L [i];
		assign init_swap [i+1] = L [i+1];
		assign init_swap [i+2] = L [i+3];
		assign init_swap [i+3] = L [i+2];
	end
	
	for(i=0; i<128; i=i+1)
	begin: permutation
		assign perm [i] = init_swap [2*i];
		assign perm [i+128] = init_swap [2*i+1];
	end
	
	for(i=0; i<128; i=i+1)
	begin: copy_fin_swap
		assign fin_swap [i] = perm [i];
	end
	
	for(i=128; i<256; i=i+2)
	begin: final_swap
		assign fin_swap [i] = perm [i+1];
		assign fin_swap [i+1] = perm [i];
	end
	
	for(i=0; i<256; i=i+1)
	begin: output_connection
		assign state_A_out_array [i] = (half) ? LUT_out [i] : fin_swap [i];
	end
endgenerate


endmodule 