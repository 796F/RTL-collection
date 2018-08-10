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

module Step(init,
			IA,
			IB,
			IC,
			ID,
			r,
			s,
			rp,
			sp,
			w,
			i,
			F,
			OA,
			OB,
			OC,
			OD

			);

	//input
	input init;
	input [127:0] IA;
	input [127:0] IB;
	input [127:0] IC;
	input [127:0] ID;
	input [4:0] r;
	input [4:0] s;
	input [4:0] rp;
	input [4:0] sp;	
	input [127:0] w;
	input [1:0] i;//modulo taken care of by the upper level
	input F;//F=0 means IF, otherwise MAJ

	//output
	output [127:0] OA;
	output [127:0] OB;
	output [127:0] OC;
	output [127:0] OD;
	
	//wire for temp varibles
	wire [31:0] tmp[0:3];//barrel shifted version of sections of A
	wire [127:0] tmpA;//temporary value when computing A
	
	//wire for constants
	
	wire [1:0] const [0:2][0:3];

	assign tmpA[127:96] = (F==0)?ID[127:96]+w[127:96]+((IA[127:96]&IB[127:96])|(~IA[127:96]&IC[127:96])) : ID[127:96]+w[127:96]+((IC[127:96]&IB[127:96])|(IC[127:96]&IA[127:96])|(IA[127:96]&IB[127:96]));
	assign tmpA[95:64] = (F==0)?ID[95:64]+w[95:64]+((IA[95:64]&IB[95:64])|(~IA[95:64]&IC[95:64])) : ID[95:64]+w[95:64]+((IC[95:64]&IB[95:64])|(IC[95:64]&IA[95:64])|(IA[95:64]&IB[95:64]));
	assign tmpA[63:32] =(F==0)?ID[63:32]+w[63:32]+((IA[63:32]&IB[63:32])|(~IA[63:32]&IC[63:32])) : ID[63:32]+w[63:32]+((IC[63:32]&IB[63:32])|(IC[63:32]&IA[63:32])|(IA[63:32]&IB[63:32]));
	assign tmpA[31:0] =(F==0)?ID[31:0]+w[31:0]+((IA[31:0]&IB[31:0])|(~IA[31:0]&IC[31:0])) : ID[31:0]+w[31:0]+((IC[31:0]&IB[31:0])|(IC[31:0]&IA[31:0])|(IA[31:0]&IB[31:0]));
	assign tmp[3] = (IA[127:96]<<r)|(IA[127:96]>>(rp));
	assign tmp[2] = (IA[95:64]<<r)|(IA[95:64]>>(rp));
	assign tmp[1] = (IA[63:32]<<r)|(IA[63:32]>>(rp));
	assign tmp[0] = (IA[31:0]<<r)|(IA[31:0]>>(rp));

	assign OA[127:96]=(((tmpA[127:96]<<s)|(tmpA[127:96]>>(sp)))+(tmp[const[i][3]]));
	assign OA[95:64]=(((tmpA[95:64]<<s)|(tmpA[95:64]>>(sp)))+(tmp[const[i][2]]));			
	assign OA[63:32]=(((tmpA[63:32]<<s)|(tmpA[63:32]>>(sp)))+(tmp[const[i][1]]));
	assign OA[31:0]=(((tmpA[31:0]<<s)|(tmpA[31:0]>>(sp)))+(tmp[const[i][0]]));
	assign OD=IC;
	assign OC=IB;
	assign OB={tmp[3],tmp[2],tmp[1],tmp[0]};
	
	assign const[0][0] = 3'd1;
	assign const[0][1] = 3'd0;
	assign const[0][2] = 3'd3;
	assign const[0][3] = 3'd2;
	assign const[1][0] = 3'd2;
	assign const[1][1] = 3'd3;
	assign const[1][2] = 3'd0;
	assign const[1][3] = 3'd1;
	assign const[2][0] = 3'd3;
	assign const[2][1] = 3'd2;
	assign const[2][2] = 3'd1;
	assign const[2][3] = 3'd0;

endmodule