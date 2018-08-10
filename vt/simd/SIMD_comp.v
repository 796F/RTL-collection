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
module SIMD_Compress(clk,
					rst_n,
					init,
					enable,
					Final,
					M, 
					IA, 
					IB, 
					IC, 
					ID, 
					OA, 
					OB, 
					OC, 
					OD
					);
	
	//input
	input          clk;
	input          rst_n;
	input          init;
	input          enable;
	input          Final;	
	input  [511:0] M;	
	input  [127:0] IA;
	input  [127:0] IB;
	input  [127:0] IC;
	input  [127:0] ID;
	
	//output
	output [127:0] OA;
	output [127:0] OB;
	output [127:0] OC;
	output [127:0] OD;

	parameter idle = 4'd0;
	parameter step1 = 4'd1;
	parameter rounds = 4'd2;
	
	//output from round module
	wire   [127:0] ORA;
	wire   [127:0] ORB;
	wire   [127:0] ORC;
	wire   [127:0] ORD;
	
	//output from fft128
	wire   [128*10-1:0] yw;
	
	//register for the state
	reg    [  3:0] state;
	
	//counter to keep when to switch states
	reg    [  5:0] counter;
	
	//register for round
	reg    [128*10-1:0] y;
    
	
	
	//register for intermediate hash values
	reg    [127:0] SA;
	reg    [127:0] SB;
	reg    [127:0] SC;
	reg    [127:0] SD;
	reg            enableRound;
	
  FFT_128 myFFT128(.clk(clk),
				   .rst_n(rst_n),				   
				   .init(enable),
				   .Final(Final),
				   .yi(M),
				   .yo(yw)
					
				   );
	Round myRound(.clk(clk),
				  .rst_n(rst_n),				  
				  .init(enableRound),
				  .IA(SA),
				  .IB(SB),
				  .IC(SC),
				  .ID(SD),
				  .y(y), 
				  .IV0(IA), 
				  .IV1(IB), 
				  .IV2(IC), 
				  .IV3(ID),
				  .OA(ORA),
				  .OB(ORB),
				  .OC(ORC),
				  .OD(ORD)				  
				  );

	assign OA = SA;
	assign OB = SB;
	assign OC = SC;
	assign OD = SD;

	
	//state machine
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			state <= idle;
		else if(init == 1'b1)
			state <= idle;
		else if(enable == 1'b1)
			state <= step1;
		else if(state == step1 && counter == 6'd6)
			state <= rounds;
		else if(state == rounds && counter == 6'h23)
			state <= idle;
		else
			state <= state;
	end	
	
	//counter to do indicate when to switch state
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			counter <= 6'd0;
		else if(init == 1'b1)
			counter <= 6'd0;
		else if(state == idle || enable == 1'b1)
			counter <= 6'd0;
		else if(state == step1 && counter == 6'd6) 
			counter <= 6'd0;
		else
			counter <= counter + 1;
	end
	
	//signal to start the round function
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			enableRound <= 1'd0;
		else if(state == step1 && counter==4'd5)
			enableRound <= 1'd1;
		else
			enableRound <= 1'd0;
	end

	//operations on intermediate hash values
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			SA <= 128'd0;
			SB <= 128'd0;
			SC <= 128'd0;
			SD <= 128'd0;		
		end
		else if(enable)
		begin
			SA <= IA ^ M[127:0];
			SB <= IB ^ M[255:128];
			SC <= IC ^ M[383:256];
			SD <= ID ^ M[511:384];

			
		end
		else if(state == rounds)
		begin
			SA <= ORA;
			SB <= ORB;
			SC <= ORC;
			SD <= ORD;
		end
		else
		begin
			SA <= SA;
			SB <= SB;
			SC <= SC;
			SD <= SD;		
		end
	end
	
	//vector to array
	wire [9:0] y_wire_vector [127:0];
	genvar g;
	generate 
	for(g=0; g<128;g=g+1)
	begin:gen_g
		assign y_wire_vector [g] = yw[(g+1)*10-1:g*10];
		
	end
	endgenerate 	
	
	//register for the processed msg
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			y <= 0;
		else if(state == step1 && counter==4'd5)
			y <=yw;

		else
			y <= y;
	end
	

endmodule