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
module FFT_8(i0,
			 i1,
			 i2,
			 i3,
			 i4,
			 i5,
			 i6,
			 i7,
			 o0,
			 o1,
			 o2,
			 o3,
			 o4,
			 o5,
			 o6,
			 o7
			 );

	//inputs
	input signed [9:0] i0;
	input signed [9:0] i1;
	input signed [9:0] i2;
	input signed [9:0] i3;
	input signed [9:0] i4;
	input signed [9:0] i5;
	input signed [9:0] i6;
	input signed [9:0] i7;
	
	//output
	output signed [8:0] o0;
	output signed [8:0] o1;
	output signed [8:0] o2;
	output signed [8:0] o3;
	output signed [8:0] o4;
	output signed [8:0] o5;
	output signed [8:0] o6;
	output signed [8:0] o7;
	
	//sign extented input
	wire signed [14:0] in0;
	wire signed [14:0] in1;
	wire signed [14:0] in2;
	wire signed [14:0] in3;
	wire signed [14:0] in4;
	wire signed [14:0] in5;
	wire signed [14:0] in6;
	wire signed [14:0] in7;

	//output of layer 1
	wire signed [14:0] out0_layer1;
	wire signed [14:0] out1_layer1;
	wire signed [14:0] out2_layer1;
	wire signed [14:0] out3_layer1;
	wire signed [14:0] out4_layer1;
	wire signed [14:0] out5_layer1;
	wire signed [14:0] out6_layer1;
	wire signed [14:0] out7_layer1;
	
	//output of layer 2
	wire signed [14:0] out0_layer2;
	wire signed [14:0] out1_layer2;
	wire signed [14:0] out2_layer2;
	wire signed [14:0] out3_layer2;
	wire signed [14:0] out4_layer2;
	wire signed [14:0] out5_layer2;
	wire signed [14:0] out6_layer2;
	wire signed [14:0] out7_layer2;
	
	//output of layer 3
	wire signed [14:0] out0_layer3;
	wire signed [14:0] out1_layer3;
	wire signed [14:0] out2_layer3;
	wire signed [14:0] out3_layer3;
	wire signed [14:0] out4_layer3;
	wire signed [14:0] out5_layer3;
	wire signed [14:0] out6_layer3;
	wire signed [14:0] out7_layer3;

	//butterfly in the 1st layer
	butterfly0 butt0_layer1(.ai(in0),
							.bi(in4),
							.ao(out0_layer1),
							.bo(out4_layer1)
							);
	butterfly1 butt1_layer1(.ai(in1),
							.bi(in5),
							.ao(out1_layer1),
							.bo(out5_layer1)
							);
	butterfly2r butt2_layer1(.ai(in2),
							 .bi(in6),
							 .ao(out2_layer1),
							 .bo(out6_layer1)
							 );
	butterfly3r butt3_layer1(.ai(in3),
							 .bi(in7),
							 .ao(out3_layer1),
							 .bo(out7_layer1)
							 );
	
	//butterfly in the 2nd layer
	butterfly0 butt0a_layer2(.ai(out0_layer1), 
							 .bi(out2_layer1), 
							 .ao(out0_layer2), 
							 .bo(out2_layer2)
							 );
	butterfly0 butt0b_layer2(.ai(out4_layer1), 
							 .bi(out6_layer1), 
							 .ao(out4_layer2), 
							 .bo(out6_layer2)
							 );
	butterfly2 butt2_layer2(.ai(out1_layer1), 
							.bi(out3_layer1), 
							.ao(out1_layer2), 
							.bo(out3_layer2)
							);
	butterfly2r butt3_layer2(.ai(out5_layer1), 
							 .bi(out7_layer1), 
							 .ao(out5_layer2), 
							 .bo(out7_layer2)
							 );	
	
	//butterfly in the 3rd layer
	butterfly0 butt0a_layer3(.ai(out0_layer2), 
							 .bi(out1_layer2), 
							 .ao(out0_layer3), 
							 .bo(out1_layer3)
							 );
	butterfly0 butt0b_layer3(.ai(out2_layer2), 
							 .bi(out3_layer2), 
							 .ao(out2_layer3), 
							 .bo(out3_layer3)
							 );
	butterfly0 butt0c_layer3(.ai(out4_layer2), 
							 .bi(out5_layer2), 
							 .ao(out4_layer3), 
							 .bo(out5_layer3)
							 );
	butterfly0 butt0d_layer3(.ai(out6_layer2), 
							 .bi(out7_layer2), 
							 .ao(out6_layer3), 
							 .bo(out7_layer3)
							 );
	
	//final output after full reduce
	do_reduce_full do_reduce_full1(.ai(out0_layer3), 
								   .ao(o0)
								   );
	do_reduce_full do_reduce_full2(.ai(out1_layer3), 
								   .ao(o1)
								   );
	do_reduce_full do_reduce_full3(.ai(out2_layer3), 
								   .ao(o2)
								   );
	do_reduce_full do_reduce_full4(.ai(out3_layer3), 
								   .ao(o3)
								   );
	do_reduce_full do_reduce_full5(.ai(out4_layer3), 
								   .ao(o4)
								   );
	do_reduce_full do_reduce_full6(.ai(out5_layer3), 
								   .ao(o5)
								   );
	do_reduce_full do_reduce_full7(.ai(out6_layer3), 
								   .ao(o6)
								   );
	do_reduce_full do_reduce_full8(.ai(out7_layer3), 
								   .ao(o7)
								   );
	

	assign in0 = i0;
	assign in1 = i1;
	assign in2 = i2;
	assign in3 = i3;
	assign in4 = i4;
	assign in5 = i5;
	assign in6 = i6;
	assign in7 = i7;
	
	
endmodule 

