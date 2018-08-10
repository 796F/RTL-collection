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
`define	Y_WIDTH 32

module FFT_64(clk,
			  rst_n,			  
			  init,
			  yi,
			  yo
			  );
	
	//input
	input clk;
	input rst_n;
	input init;
	input [64*10-1:0] yi;

	//output
	output [64*10-1:0] yo;

	//state machine
	reg [3:0] state;
	
	//counter to keep the record
	reg [3:0] counter;


	//bit vector to array
	wire signed [ 9:0] yi_array[63:0];
	wire signed [14:0] yo_array[63:0];
	
	//input to 8 fft 8
	reg signed  [ 9:0] FFT8_N1 [7:0];
	reg signed  [ 9:0] FFT8_N2 [7:0];
	reg signed  [ 9:0] FFT8_N3 [7:0];
	reg signed  [ 9:0] FFT8_N4 [7:0];
	reg signed  [ 9:0] FFT8_N5 [7:0];
	reg signed  [ 9:0] FFT8_N6 [7:0];
	reg signed  [ 9:0] FFT8_N7 [7:0];
	reg signed  [ 9:0] FFT8_N8 [7:0];
	
	//output from 8 fft 8
	wire signed [ 8:0] FFT8_O1 [7:0];
	wire signed [ 8:0] FFT8_O2 [7:0];
	wire signed [ 8:0] FFT8_O3 [7:0];
	wire signed [ 8:0] FFT8_O4 [7:0];
	wire signed [ 8:0] FFT8_O5 [7:0];
	wire signed [ 8:0] FFT8_O6 [7:0];
	wire signed [ 8:0] FFT8_O7 [7:0];
	wire signed [ 8:0] FFT8_O8 [7:0];
	wire signed [15:0] product [48:0];
	wire signed [ 9:0] diff[48:0];

	parameter idle  = 4'd0;
	parameter load  = 4'd1;
	parameter step1 = 4'd2;
	parameter step2 = 4'd3;
	parameter step3 = 4'd4;
	integer j;
	
	//8 instances of fft 8
	FFT_8 FFT8_1(.i0(FFT8_N1[0]),
				 .i1(FFT8_N1[1]),
				 .i2(FFT8_N1[2]),
				 .i3(FFT8_N1[3]),
				 .i4(FFT8_N1[4]),
				 .i5(FFT8_N1[5]),
				 .i6(FFT8_N1[6]),
				 .i7(FFT8_N1[7]),
				 .o0(FFT8_O1[0]),
				 .o1(FFT8_O1[1]),
				 .o2(FFT8_O1[2]),
				 .o3(FFT8_O1[3]),
				 .o4(FFT8_O1[4]),
				 .o5(FFT8_O1[5]),
				 .o6(FFT8_O1[6]),
				 .o7(FFT8_O1[7])
				 );
	FFT_8 FFT8_2(.i0(FFT8_N2[0]),
				 .i1(FFT8_N2[1]),
				 .i2(FFT8_N2[2]),
				 .i3(FFT8_N2[3]),
				 .i4(FFT8_N2[4]),
				 .i5(FFT8_N2[5]),
				 .i6(FFT8_N2[6]),
				 .i7(FFT8_N2[7]),
				 .o0(FFT8_O2[0]),
				 .o1(FFT8_O2[1]),
				 .o2(FFT8_O2[2]),
				 .o3(FFT8_O2[3]),
				 .o4(FFT8_O2[4]),
				 .o5(FFT8_O2[5]),
				 .o6(FFT8_O2[6]),
				 .o7(FFT8_O2[7])
				 );
	FFT_8 FFT8_3(.i0(FFT8_N3[0]),
				 .i1(FFT8_N3[1]),
				 .i2(FFT8_N3[2]),
				 .i3(FFT8_N3[3]),
				 .i4(FFT8_N3[4]),
				 .i5(FFT8_N3[5]),
				 .i6(FFT8_N3[6]),
				 .i7(FFT8_N3[7]),
				 .o0(FFT8_O3[0]),
				 .o1(FFT8_O3[1]),
				 .o2(FFT8_O3[2]),
				 .o3(FFT8_O3[3]),
				 .o4(FFT8_O3[4]),
				 .o5(FFT8_O3[5]),
				 .o6(FFT8_O3[6]),
				 .o7(FFT8_O3[7])
				 );
	FFT_8 FFT8_4(.i0(FFT8_N4[0]),
				 .i1(FFT8_N4[1]),
				 .i2(FFT8_N4[2]),
				 .i3(FFT8_N4[3]),
				 .i4(FFT8_N4[4]),
				 .i5(FFT8_N4[5]),
				 .i6(FFT8_N4[6]),
				 .i7(FFT8_N4[7]),
				 .o0(FFT8_O4[0]),
				 .o1(FFT8_O4[1]),
				 .o2(FFT8_O4[2]),
				 .o3(FFT8_O4[3]),
				 .o4(FFT8_O4[4]),
				 .o5(FFT8_O4[5]),
				 .o6(FFT8_O4[6]),
				 .o7(FFT8_O4[7])
				 );
	FFT_8 FFT8_5(.i0(FFT8_N5[0]),
				 .i1(FFT8_N5[1]),
				 .i2(FFT8_N5[2]),
				 .i3(FFT8_N5[3]),
				 .i4(FFT8_N5[4]),
				 .i5(FFT8_N5[5]),
				 .i6(FFT8_N5[6]),
				 .i7(FFT8_N5[7]),
				 .o0(FFT8_O5[0]),
				 .o1(FFT8_O5[1]),
				 .o2(FFT8_O5[2]),
				 .o3(FFT8_O5[3]),
				 .o4(FFT8_O5[4]),
				 .o5(FFT8_O5[5]),
				 .o6(FFT8_O5[6]),
				 .o7(FFT8_O5[7])
				 );
	FFT_8 FFT8_6(.i0(FFT8_N6[0]),
				 .i1(FFT8_N6[1]),
				 .i2(FFT8_N6[2]),
				 .i3(FFT8_N6[3]),
				 .i4(FFT8_N6[4]),
				 .i5(FFT8_N6[5]),
				 .i6(FFT8_N6[6]),
				 .i7(FFT8_N6[7]),
				 .o0(FFT8_O6[0]),
				 .o1(FFT8_O6[1]),
				 .o2(FFT8_O6[2]),
				 .o3(FFT8_O6[3]),
				 .o4(FFT8_O6[4]),
				 .o5(FFT8_O6[5]),
				 .o6(FFT8_O6[6]),
				 .o7(FFT8_O6[7])
				 );
	FFT_8 FFT8_7(.i0(FFT8_N7[0]),
				 .i1(FFT8_N7[1]),
				 .i2(FFT8_N7[2]),
				 .i3(FFT8_N7[3]),
				 .i4(FFT8_N7[4]),
				 .i5(FFT8_N7[5]),
				 .i6(FFT8_N7[6]),
				 .i7(FFT8_N7[7]),
				 .o0(FFT8_O7[0]),
				 .o1(FFT8_O7[1]),
				 .o2(FFT8_O7[2]),
				 .o3(FFT8_O7[3]),
				 .o4(FFT8_O7[4]),
				 .o5(FFT8_O7[5]),
				 .o6(FFT8_O7[6]),
				 .o7(FFT8_O7[7])
				 );
	FFT_8 FFT8_8(.i0(FFT8_N8[0]),
				 .i1(FFT8_N8[1]),
				 .i2(FFT8_N8[2]),
				 .i3(FFT8_N8[3]),
				 .i4(FFT8_N8[4]),
				 .i5(FFT8_N8[5]),
				 .i6(FFT8_N8[6]),
				 .i7(FFT8_N8[7]),
				 .o0(FFT8_O8[0]),
				 .o1(FFT8_O8[1]),
				 .o2(FFT8_O8[2]),
				 .o3(FFT8_O8[3]),
				 .o4(FFT8_O8[4]),
				 .o5(FFT8_O8[5]),
				 .o6(FFT8_O8[6]),
				 .o7(FFT8_O8[7])
				 );
	
	//products of the 8x8 multiplier
	assign product[ 0] = MUL002(FFT8_O2[1]);
	assign product[ 1] = MUL004(FFT8_O3[1]);
	assign product[ 2] = MUL008(FFT8_O4[1]);
	assign product[ 3] = MUL016(FFT8_O5[1]);
	assign product[ 4] = MUL032(FFT8_O6[1]);
	assign product[ 5] = MUL064(FFT8_O7[1]);
	assign product[ 6] = MUL128(FFT8_O8[1]);
	assign product[ 7] = MUL060(FFT8_O2[2]);
	assign product[ 8] = MUL002(FFT8_O3[2]);
	assign product[ 9] = MUL120(FFT8_O4[2]);
	assign product[10] = MUL004(FFT8_O5[2]);
	assign product[11] = -MUL017(FFT8_O6[2]);
	assign product[12] = MUL008(FFT8_O7[2]);
	assign product[13] = -MUL034(FFT8_O8[2]);
	assign product[14] = MUL120(FFT8_O2[3]);
	assign product[15] = MUL008(FFT8_O3[3]);
	assign product[16] = -MUL068(FFT8_O4[3]);
	assign product[17] = MUL064(FFT8_O5[3]);
	assign product[18] = -MUL030(FFT8_O6[3]);
	assign product[19] = -MUL002(FFT8_O7[3]);
	assign product[20] = MUL017(FFT8_O8[3]);
	assign product[21] = MUL046(FFT8_O2[4]);
	assign product[22] = MUL060(FFT8_O3[4]);
	assign product[23] = -MUL067(FFT8_O4[4]);
	assign product[24] = MUL002(FFT8_O5[4]);
	assign product[25] = MUL092(FFT8_O6[4]);
	assign product[26] = MUL120(FFT8_O7[4]);
	assign product[27] = MUL123(FFT8_O8[4]);	
	assign product[28] = MUL092(FFT8_O2[5]);
	assign product[29] = -MUL017(FFT8_O3[5]);
	assign product[30] = -MUL022(FFT8_O4[5]);
	assign product[31] = MUL032(FFT8_O5[5]);
	assign product[32] = MUL117(FFT8_O6[5]);
	assign product[33] = -MUL030(FFT8_O7[5]);
	assign product[34] = MUL067(FFT8_O8[5]);
	assign product[35] = -MUL067(FFT8_O2[6]);
	assign product[36] = MUL120(FFT8_O3[6]);
	assign product[37] = -MUL073(FFT8_O4[6]);
	assign product[38] = MUL008(FFT8_O5[6]);
	assign product[39] = -MUL022(FFT8_O6[6]);
	assign product[40] = -MUL068(FFT8_O7[6]);
	assign product[41] = -MUL070(FFT8_O8[6]);
	assign product[42] = MUL123(FFT8_O2[7]);
	assign product[43] = -MUL034(FFT8_O3[7]);
	assign product[44] = -MUL070(FFT8_O4[7]);
	assign product[45] = MUL128(FFT8_O5[7]);
	assign product[46] = MUL067(FFT8_O6[7]);
	assign product[47] = MUL017(FFT8_O7[7]);
	assign product[48] = MUL035(FFT8_O8[7]);
	
	
	//make I/O arrays
	genvar i;
	generate
	for(i=0; i<64; i=i+1)
	begin:vect_to_array
		assign yi_array[i] = yi[i*10+9:i*10];		
		assign yo[(i+1)*10-1:10*i] = yo_array[i];
	end
	endgenerate
	
	generate
	for(i=0; i<8; i=i+1)
	begin:vector_to_yo
		assign yo_array[i] = FFT8_O1[i];
		assign yo_array[i+8] = FFT8_O2[i];
		assign yo_array[i+16] = FFT8_O3[i];
		assign yo_array[i+24] = FFT8_O4[i];
		assign yo_array[i+32] = FFT8_O5[i];
		assign yo_array[i+40] = FFT8_O6[i];
		assign yo_array[i+48] = FFT8_O7[i];
		assign yo_array[i+56] = FFT8_O8[i];
	end
	
	//Low 8-bits - High 8-bits
	for(i=0; i<49; i=i+1)
	begin: reduce_fft
		assign diff [i] = {2'b0,product[i][7:0]} - {{2{product[i][15]}},product[i][15:8]};
	end
	endgenerate
	
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			state <= idle;
		else if(init == 1'd1)
			state <= step1;
		else if(state == step1)
			state <= step2; //Multiply by twiddle factors
		else if(state == step2)
			state <= idle;
		else
			state <= state;	
	end
	
	//Main function: performing fft 8 in 3 steps
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			for(j=0; j<8; j=j+1)
			begin:FFT8_rst
				FFT8_N1[j] <= 0;
				FFT8_N2[j] <= 0;
				FFT8_N3[j] <= 0;
				FFT8_N4[j] <= 0;
				FFT8_N5[j] <= 0;
				FFT8_N6[j] <= 0;
				FFT8_N7[j] <= 0;
				FFT8_N8[j] <= 0;
			end
		end
		else if(init)
		begin
			for(j=0; j<8; j=j+1)
			begin:FFT8_1load
				FFT8_N1[j] <= yi_array[(j*8)];
				FFT8_N2[j] <= yi_array[(j*8)+1];
				FFT8_N3[j] <= yi_array[(j*8)+2];
				FFT8_N4[j] <= yi_array[(j*8)+3];
				FFT8_N5[j] <= yi_array[(j*8)+4];
				FFT8_N6[j] <= yi_array[(j*8)+5];
				FFT8_N7[j] <= yi_array[(j*8)+6];
				FFT8_N8[j] <= yi_array[(j*8)+7];
			end
		end
		else if(state == step1)
		begin
				FFT8_N1[0] <= FFT8_O1[0];
				FFT8_N1[1] <= FFT8_O2[0];
				FFT8_N1[2] <= FFT8_O3[0];
				FFT8_N1[3] <= FFT8_O4[0];
				FFT8_N1[4] <= FFT8_O5[0];
				FFT8_N1[5] <= FFT8_O6[0];
				FFT8_N1[6] <= FFT8_O7[0];
				FFT8_N1[7] <= FFT8_O8[0];

				FFT8_N2[0] <= FFT8_O1[1];
				FFT8_N2[1] <= diff[0];
				FFT8_N2[2] <= diff[1];
				FFT8_N2[3] <= diff[2];
				FFT8_N2[4] <= diff[3];
				FFT8_N2[5] <= diff[4];
				FFT8_N2[6] <= diff[5];
				FFT8_N2[7] <= diff[6];

				FFT8_N3[0] <= FFT8_O1[2];
				FFT8_N3[1] <= diff[7];
				FFT8_N3[2] <= diff[8];
				FFT8_N3[3] <= diff[9];
				FFT8_N3[4] <= diff[10];
				FFT8_N3[5] <= diff[11];
				FFT8_N3[6] <= diff[12];
				FFT8_N3[7] <= diff[13];

				FFT8_N4[0] <= FFT8_O1[3];
				FFT8_N4[1] <= diff[14];
				FFT8_N4[2] <= diff[15];
				FFT8_N4[3] <= diff[16];
				FFT8_N4[4] <= diff[17];
				FFT8_N4[5] <= diff[18];
				FFT8_N4[6] <= diff[19];
				FFT8_N4[7] <= diff[20];				
				
				FFT8_N5[0] <= FFT8_O1[4];
				FFT8_N5[1] <= diff[21];	
				FFT8_N5[2] <= diff[22];	
				FFT8_N5[3] <= diff[23];	
				FFT8_N5[4] <= diff[24];	
				FFT8_N5[5] <= diff[25];	
				FFT8_N5[6] <= diff[26];	
				FFT8_N5[7] <= diff[27];	

				FFT8_N6[0] <= FFT8_O1[5];
				FFT8_N6[1] <= diff[28];	
				FFT8_N6[2] <= diff[29];	
				FFT8_N6[3] <= diff[30];	
				FFT8_N6[4] <= diff[31];	
				FFT8_N6[5] <= diff[32];	
				FFT8_N6[6] <= diff[33];	
				FFT8_N6[7] <= diff[34];	

				FFT8_N7[0] <= FFT8_O1[6];
				FFT8_N7[1] <= diff[35];	
				FFT8_N7[2] <= diff[36];	
				FFT8_N7[3] <= diff[37];	
				FFT8_N7[4] <= diff[38];	
				FFT8_N7[5] <= diff[39];	
				FFT8_N7[6] <= diff[40];	
				FFT8_N7[7] <= diff[41];	

				FFT8_N8[0] <= FFT8_O1[7];
				FFT8_N8[1] <= diff[42];	
				FFT8_N8[2] <= diff[43];	
				FFT8_N8[3] <= diff[44];	
				FFT8_N8[4] <= diff[45];	
				FFT8_N8[5] <= diff[46];	
				FFT8_N8[6] <= diff[47];	
				FFT8_N8[7] <= diff[48];					
		end
		else
		begin
			for(j=0; j<8; j=j+1)
			begin
				FFT8_N1[j] <= FFT8_N1[j];
				FFT8_N2[j] <= FFT8_N2[j];
				FFT8_N3[j] <= FFT8_N3[j];
				FFT8_N4[j] <= FFT8_N4[j];
				FFT8_N5[j] <= FFT8_N5[j];
				FFT8_N6[j] <= FFT8_N6[j];
				FFT8_N7[j] <= FFT8_N7[j];
				FFT8_N8[j] <= FFT8_N8[j];
			end
		end
	end
	
	//multiplication function
	function signed  [15:0] MUL002;
	  input signed [8:0] op;
	  begin
		MUL002 = 0 + (op<<1) ;
	  end
	endfunction  

	function signed  [15:0] MUL004;
	  input signed [8:0] op;
	  begin
		MUL004 = 0 + (op<<2) ;
	  end
	endfunction  

	function signed  [15:0] MUL008;
	  input signed [8:0] op;
	  begin
		MUL008 = 0 + (op<<3) ;
	  end
	endfunction  

	function signed  [15:0] MUL016;
	  input signed [8:0] op;
	  begin
		MUL016 = 0 + (op<<4) ;
	  end
	endfunction  

	function signed  [15:0] MUL032;
	  input signed [8:0] op;
	  begin
		MUL032 = 0 + (op<<5) ;
	  end
	endfunction  

	function signed  [15:0] MUL064;
	  input signed [8:0] op;
	  begin
		MUL064 = 0 + (op<<6) ;
	  end
	endfunction  

	function signed  [15:0] MUL128;
	  input signed [8:0] op;
	  begin
		MUL128 = 0 + (op<<7) ;
	  end
	endfunction  

	function signed  [15:0] MUL060;
	  input signed [8:0] op;
	  begin
		MUL060 = 0 + (op<<2)  + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction  



	function signed  [15:0] MUL120;
	  input signed [8:0] op;
	  begin
		MUL120 = 0 + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction  



	function signed  [15:0] MUL017;
	  input signed [8:0] op;
	  begin
		MUL017 = 0 + op     + (op<<4) ;
	  end
	endfunction  



	function signed  [15:0] MUL034;
	  input signed [8:0] op;
	  begin
		MUL034 = 0 + (op<<1)  + (op<<5) ;
	  end
	endfunction  




	function signed  [15:0] MUL068;
	  input signed [8:0] op;
	  begin
		MUL068 = 0 + (op<<2)  + (op<<6) ;
	  end
	endfunction  



	function signed  [15:0] MUL030;
	  input signed [8:0] op;
	  begin
		MUL030 = 0 + (op<<1)  + (op<<2)  + (op<<3)  + (op<<4) ;
	  end
	endfunction  





	function signed  [15:0] MUL046;
	  input signed [8:0] op;
	  begin
		MUL046 = 0 + (op<<1)  + (op<<2)  + (op<<3)  + (op<<5) ;
	  end
	endfunction  


	function signed  [15:0] MUL067;
	  input signed [8:0] op;
	  begin
		MUL067 = 0 + op     + (op<<1)  + (op<<6) ;
	  end
	endfunction  



	function signed  [15:0] MUL092;
	  input signed [8:0] op;
	  begin
		MUL092 = 0 + (op<<2)  + (op<<3)  + (op<<4)  + (op<<6) ;
	  end
	endfunction  



	function signed  [15:0] MUL123;
	  input signed [8:0] op;
	  begin
		MUL123 = 0 + op     + (op<<1)  + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction  





	function signed  [15:0] MUL022;
	  input signed [8:0] op;
	  begin
		MUL022 = 0 + (op<<1)  + (op<<2)  + (op<<4) ;
	  end
	endfunction  



	function signed  [15:0] MUL117;
	  input signed [8:0] op;
	  begin
		MUL117 = 0 + op     + (op<<2)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction  







	function signed  [15:0] MUL073;
	  input signed [8:0] op;
	  begin
		MUL073 = 0 + op     + (op<<3)  + (op<<6) ;
	  end
	endfunction  






	function signed  [15:0] MUL070;
	  input signed [8:0] op;
	  begin
		MUL070 = 0 + (op<<1)  + (op<<2)  + (op<<6) ;
	  end
	endfunction  




	function signed  [15:0] MUL035;
	  input signed [8:0] op;
	  begin
		MUL035 = 0 + op     + (op<<1)  + (op<<5) ;
	  end
	endfunction  


endmodule 