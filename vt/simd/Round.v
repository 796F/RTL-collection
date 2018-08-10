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

module Round(clk,
			 rst_n,
			 init,
			 IA,
			 IB,
			 IC,
			 ID,
			 y, 
			 IV0, 
			 IV1, 
			 IV2, 
			 IV3,
			 OA,
			 OB,
			 OC,
			 OD
			 );

	//input
	input clk;
	input rst_n;
	input init;
	input [127:0] IA;
	input [127:0] IB;
	input [127:0] IC;
	input [127:0] ID;
	input signed [128*10-1:0] y;	
	input [127:0] IV0;
	input [127:0] IV1;
	input [127:0] IV2;
	input [127:0] IV3;	
	
	//outputs
	output [127:0] OA;
	output [127:0] OB;
	output [127:0] OC;
	output [127:0] OD;	

	reg F;//F=0 means IF, otherwise MAJ


	
	parameter idle = 5'd 0;
	parameter round1 = 5'd1;
	parameter round2 = 5'd2;
	parameter round3 = 5'd3;
	parameter round4 = 5'd4;
	parameter stepF = 5'd5;
	
	//state machine and indices
	reg [4:0] state;
	reg [3:0] counter;
	reg [4:0] w_index;
	reg [1:0] i;
	
	//shift amount
	reg [4:0] r;
	reg [4:0] t;
	reg [4:0] s;
	reg [4:0] u;
	
	//computed values for barrel shift
	reg [4:0] rp;
	reg [4:0] tp;
	reg [4:0] sp;
	reg [4:0] up;
	
	//storing the P and Q values
	wire [6:0] P4 [31:0][3:0];
	wire [6:0] Q4 [31:0][3:0];
	
	//signal wires for expanded message
	wire signed [9:0] yArry [127:0];
	wire [31:0] w [3:0];
	wire signed [15:0] w_low [3:0];
	wire signed [15:0] w_high [3:0];

	Step myStep(.init(init),
				.IA(IA),
				.IB(IB),
				.IC(IC),
				.ID(ID),
				.r(r),
				.s(s),
				.rp(rp),
				.sp(sp),
				.w({w[3],w[2],w[1],w[0]}),
				.i(i),
				.F(F),
				.OA(OA),
				.OB(OB),
				.OC(OC),
				.OD(OD)
				);	

	//high signal for expanded msg
	assign w_high[3] = (state<round3) ? 0 + yArry[Q4[w_index][3]]     + (yArry[Q4[w_index][3]]<<3)  + (yArry[Q4[w_index][3]]<<4)  + (yArry[Q4[w_index][3]]<<5)  + (yArry[Q4[w_index][3]]<<7) : 0 + yArry[Q4[w_index][3]]     + (yArry[Q4[w_index][3]]<<3)  + (yArry[Q4[w_index][3]]<<5)  + (yArry[Q4[w_index][3]]<<6)  + (yArry[Q4[w_index][3]]<<7);
	assign w_high[2] = (state<round3) ? 0 + yArry[Q4[w_index][2]]     + (yArry[Q4[w_index][2]]<<3)  + (yArry[Q4[w_index][2]]<<4)  + (yArry[Q4[w_index][2]]<<5)  + (yArry[Q4[w_index][2]]<<7)  : 0 + yArry[Q4[w_index][2]]     + (yArry[Q4[w_index][2]]<<3)  + (yArry[Q4[w_index][2]]<<5)  + (yArry[Q4[w_index][2]]<<6)  + (yArry[Q4[w_index][2]]<<7);
	assign w_high[1] = (state<round3) ? 0 + yArry[Q4[w_index][1]]     + (yArry[Q4[w_index][1]]<<3)  + (yArry[Q4[w_index][1]]<<4)  + (yArry[Q4[w_index][1]]<<5)  + (yArry[Q4[w_index][1]]<<7)  : 0 + yArry[Q4[w_index][1]]     + (yArry[Q4[w_index][1]]<<3)  + (yArry[Q4[w_index][1]]<<5)  + (yArry[Q4[w_index][1]]<<6)  + (yArry[Q4[w_index][1]]<<7);
	assign w_high[0] = (state<round3) ? 0 + yArry[Q4[w_index][0]]     + (yArry[Q4[w_index][0]]<<3)  + (yArry[Q4[w_index][0]]<<4)  + (yArry[Q4[w_index][0]]<<5)  + (yArry[Q4[w_index][0]]<<7)   : 0 + yArry[Q4[w_index][0]]     + (yArry[Q4[w_index][0]]<<3)  + (yArry[Q4[w_index][0]]<<5)  + (yArry[Q4[w_index][0]]<<6)  + (yArry[Q4[w_index][0]]<<7);
	
	//low signal for expanded msg
	assign w_low[3]  = (state<round3) ? 0 + yArry[P4[w_index][3]]     + (yArry[P4[w_index][3]]<<3)  + (yArry[P4[w_index][3]]<<4)  + (yArry[P4[w_index][3]]<<5)  + (yArry[P4[w_index][3]]<<7) : 0 + yArry[P4[w_index][3]]     + (yArry[P4[w_index][3]]<<3)  + (yArry[P4[w_index][3]]<<5)  + (yArry[P4[w_index][3]]<<6)  + (yArry[P4[w_index][3]]<<7) ;
	assign w_low[2]  = (state<round3) ? 0 + yArry[P4[w_index][2]]     + (yArry[P4[w_index][2]]<<3)  + (yArry[P4[w_index][2]]<<4)  + (yArry[P4[w_index][2]]<<5)  + (yArry[P4[w_index][2]]<<7)  : 0 + yArry[P4[w_index][2]]     + (yArry[P4[w_index][2]]<<3)  + (yArry[P4[w_index][2]]<<5)  + (yArry[P4[w_index][2]]<<6)  + (yArry[P4[w_index][2]]<<7);
	assign w_low[1]  = (state<round3) ? 0 + yArry[P4[w_index][1]]     + (yArry[P4[w_index][1]]<<3)  + (yArry[P4[w_index][1]]<<4)  + (yArry[P4[w_index][1]]<<5)  + (yArry[P4[w_index][1]]<<7) : 0 + yArry[P4[w_index][1]]     + (yArry[P4[w_index][1]]<<3)  + (yArry[P4[w_index][1]]<<5)  + (yArry[P4[w_index][1]]<<6)  + (yArry[P4[w_index][1]]<<7);
	assign w_low[0]  = (state<round3) ? 0 + yArry[P4[w_index][0]]     + (yArry[P4[w_index][0]]<<3)  + (yArry[P4[w_index][0]]<<4)  + (yArry[P4[w_index][0]]<<5)  + (yArry[P4[w_index][0]]<<7) : 0 + yArry[P4[w_index][0]]   + (yArry[P4[w_index][0]]<<3)  + (yArry[P4[w_index][0]]<<5)  + (yArry[P4[w_index][0]]<<6)  + (yArry[P4[w_index][0]]<<7);
	
	//signal wires for expanded msg
	assign w[3] = (state!=5'd5) ? {w_high[3], w_low[3]}:(counter==4'd0)?IV0[127:96] :(counter==4'd1)?IV1[127:96]: (counter==4'd2)?IV2[127:96]:IV3[127:96];
	assign w[2] = (state!=5'd5) ? {w_high[2], w_low[2]}:(counter==4'd0)?IV0[95:64] :(counter==4'd1)?IV1[95:64]: (counter==4'd2)?IV2[95:64]:IV3[95:64];
	assign w[1] = (state!=5'd5) ? {w_high[1], w_low[1]}:(counter==4'd0)?IV0[63:32] :(counter==4'd1)?IV1[63:32]: (counter==4'd2)?IV2[63:32]:IV3[63:32];
	assign w[0] = (state!=5'd5) ? {w_high[0], w_low[0]}:(counter==4'd0)?IV0[31:0] :(counter==4'd1)?IV1[31:0]: (counter==4'd2)?IV2[31:0]:IV3[31:0];

	
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			state <= idle;
		else if(init == 1'b1)
			state <= round1;
		else if(state == round1 && counter == 4'd7)
			state <= round2;
		else if(state == round2 && counter == 4'd7)
			state <= round3;
		else if(state == round3 && counter == 4'd7)
			state <= round4;
		else if(state == round4 && counter == 4'd7)
			state <= stepF;
		else if(state == stepF && counter == 4'd3)
			state <= idle;
		else
			state <= state;
	end
	
	//keep track of the indices
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			w_index <= 5'd0;
		else if(init == 1'b1)
			w_index <= 5'd0;
		else if(state != idle)
			w_index <= w_index+1;
		else
			w_index <= w_index;
	end
	


	
	always @(posedge clk or posedge init or negedge rst_n)
	begin
		if(~rst_n)
			counter <= 4'd0;
		else if(init == 1'b1)
			counter <= 4'd0;
		else if(state == idle)
			counter <= 4'd0;
		else if(state == round1 && counter == 4'd7)
			counter <= 4'd0;
		else if(state == round2 && counter == 4'd7)
			counter <= 4'd0;
		else if(state == round3 && counter == 4'd7)
			counter <= 4'd0;
		else if(state == round4 && counter == 4'd7)
			counter <= 4'd0;
		else if(state == stepF && counter == 4'd3)
			counter <= 4'd0;
		else
			counter <= counter+1;
	end
	
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			i <= 2'd0;
		else if(init == 1'b1)
			i <= 2'd0;
		else if(state == idle)
			i <= 2'd0;
		else
			i <= (i==2'd2)?0:i+1;	
	end

	//shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			r <= 5'd0;
		else if(init == 1'b1)
			r <= 5'd3;
		else if(state == idle )
			r <= 5'd3;
		else if(state == round1 && counter == 4'd7)
			r <= 5'd28;
		else if(state == round2 && counter == 4'd7)
			r <= 5'd29;
		else if(state == round3 && counter == 4'd7)
			r <= 5'd4;
		else
			r <= s;
	end

	//complemented shift amount = 32 - shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			rp <= 5'd0;
		else if(init == 1'b1)
			rp <= 5'd29;
		else if(state == idle )
			rp <= 5'd29;
		else if(state == round1 && counter == 4'd7)
			rp <= 5'd4;
		else if(state == round2 && counter == 4'd7)
			rp <= 5'd3;
		else if(state == round3 && counter == 4'd7)
			rp <= 5'd28;
		else
			rp <= sp;
	end
	
	//shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			s <= 5'd0;
		else if(init == 1'b1)
			s <= 5'd23;
		else if(state == idle )
			s <= 5'd23;
		else if(state == round1 && counter == 4'd7)
			s <= 5'd19;
		else if(state == round2 && counter == 4'd7)
			s <= 5'd9;
		else if(state == round3 && counter == 4'd7)
			s <= 5'd13;
		else
			s <= t;
	end
	
	//complemented shift amount = 32 - shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			sp <= 5'd0;
		else if(init == 1'b1)
			sp <= 5'd9;
		else if(state == idle )
			sp <= 5'd9;
		else if(state == round1 && counter == 4'd7)
			sp <= 5'd13;
		else if(state == round2 && counter == 4'd7)
			sp <= 5'd23;
		else if(state == round3 && counter == 4'd7)
			sp <= 5'd19;
		else
			sp <= tp;
	end
	
	//shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			t <= 5'd0;
		else if(init == 1'b1)
			t <= 5'd17;
		else if(state == idle )
			t <= 5'd17;
		else if(state == round1 && counter == 4'd7)
			t <= 5'd22;
		else if(state == round2 && counter == 4'd7)
			t <= 5'd15;
		else if(state == round3 && counter == 4'd7)
			t <= 5'd10;
		else
			t <= u;
	end
	
	//complemented shift amount = 32 - shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			tp <= 5'd0;
		else if(init == 1'b1)
			tp <= 5'd15;
		else if(state == idle )
			tp <= 5'd15;
		else if(state == round1 && counter == 4'd7)
			tp <= 5'd10;
		else if(state == round2 && counter == 4'd7)
			tp <= 5'd17;
		else if(state == round3 && counter == 4'd7)
			tp <= 5'd22;
		else
			tp <= up;
	end
	
	//shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			u <= 5'd0;
		else if(init == 1'b1)
			u <= 5'd27;
		else if(state == idle )
			u <= 5'd27;
		else if(state == round1 && counter == 4'd7)
			u <= 5'd7;
		else if(state == round2 && counter == 4'd7)
			u <= 5'd5;
		else if(state == round3 && counter == 4'd7)
			u <= 5'd25;
		else
			u <= r;
	end
	
	//complemented shift amount = 32 - shift amount
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			up <= 5'd0;
		else if(init == 1'b1)
			up <= 5'd5;
		else if(state == idle )
			up <= 5'd5;
		else if(state == round1 && counter == 4'd7)
			up <= 5'd25;
		else if(state == round2 && counter == 4'd7)
			up <= 5'd27;
		else if(state == round3 && counter == 4'd7)
			up <= 5'd7;
		else
			up <= rp;
	end
	
	//indicate if this is the final msg
	always @ (posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			F <= 1'd0;
		else if(init == 1'b1)
			F <= 1'd0;
		else
			F <= (counter < 4'd3 || counter == 4'd7)? 0:1;
	end
	
	genvar g;
	generate
	for(g=0;g<128;g=g+1)
	begin:yArry_assign
		assign yArry[g] = y[(g+1)*10-1:g*10];
	end
	endgenerate
	
	//Constants P and Q values
	assign P4[0][0] = 7'd2;
	assign Q4[0][0] = 7'd66;
	assign P4[0][1] = 7'd34;
	assign Q4[0][1] = 7'd98;
	assign P4[0][2] = 7'd18;
	assign Q4[0][2] = 7'd82;
	assign P4[0][3] = 7'd50;
	assign Q4[0][3] = 7'd114;
	assign P4[1][0] = 7'd6;
	assign Q4[1][0] = 7'd70;
	assign P4[1][1] = 7'd38;
	assign Q4[1][1] = 7'd102;
	assign P4[1][2] = 7'd22;
	assign Q4[1][2] = 7'd86;
	assign P4[1][3] = 7'd54;
	assign Q4[1][3] = 7'd118;
	assign P4[2][0] = 7'd0;
	assign Q4[2][0] = 7'd64;
	assign P4[2][1] = 7'd32;
	assign Q4[2][1] = 7'd96;
	assign P4[2][2] = 7'd16;
	assign Q4[2][2] = 7'd80;
	assign P4[2][3] = 7'd48;
	assign Q4[2][3] = 7'd112;
	assign P4[3][0] = 7'd4;
	assign Q4[3][0] = 7'd68;
	assign P4[3][1] = 7'd36;
	assign Q4[3][1] = 7'd100;
	assign P4[3][2] = 7'd20;
	assign Q4[3][2] = 7'd84;
	assign P4[3][3] = 7'd52;
	assign Q4[3][3] = 7'd116;
	assign P4[4][0] = 7'd14;
	assign Q4[4][0] = 7'd78;
	assign P4[4][1] = 7'd46;
	assign Q4[4][1] = 7'd110;
	assign P4[4][2] = 7'd30;
	assign Q4[4][2] = 7'd94;
	assign P4[4][3] = 7'd62;
	assign Q4[4][3] = 7'd126;
	assign P4[5][0] = 7'd10;
	assign Q4[5][0] = 7'd74;
	assign P4[5][1] = 7'd42;
	assign Q4[5][1] = 7'd106;
	assign P4[5][2] = 7'd26;
	assign Q4[5][2] = 7'd90;
	assign P4[5][3] = 7'd58;
	assign Q4[5][3] = 7'd122;
	assign P4[6][0] = 7'd12;
	assign Q4[6][0] = 7'd76;
	assign P4[6][1] = 7'd44;
	assign Q4[6][1] = 7'd108;
	assign P4[6][2] = 7'd28;
	assign Q4[6][2] = 7'd92;
	assign P4[6][3] = 7'd60;
	assign Q4[6][3] = 7'd124;
	assign P4[7][0] = 7'd8;
	assign Q4[7][0] = 7'd72;
	assign P4[7][1] = 7'd40;
	assign Q4[7][1] = 7'd104;
	assign P4[7][2] = 7'd24;
	assign Q4[7][2] = 7'd88;
	assign P4[7][3] = 7'd56;
	assign Q4[7][3] = 7'd120;
	assign P4[8][0] = 7'd15;
	assign Q4[8][0] = 7'd79;
	assign P4[8][1] = 7'd47;
	assign Q4[8][1] = 7'd111;
	assign P4[8][2] = 7'd31;
	assign Q4[8][2] = 7'd95;
	assign P4[8][3] = 7'd63;
	assign Q4[8][3] = 7'd127;
	assign P4[9][0] = 7'd13;
	assign Q4[9][0] = 7'd77;
	assign P4[9][1] = 7'd45;
	assign Q4[9][1] = 7'd109;
	assign P4[9][2] = 7'd29;
	assign Q4[9][2] = 7'd93;
	assign P4[9][3] = 7'd61;
	assign Q4[9][3] = 7'd125;
	assign P4[10][0] = 7'd3;
	assign Q4[10][0] = 7'd67;
	assign P4[10][1] = 7'd35;
	assign Q4[10][1] = 7'd99;
	assign P4[10][2] = 7'd19;
	assign Q4[10][2] = 7'd83;
	assign P4[10][3] = 7'd51;
	assign Q4[10][3] = 7'd115;
	assign P4[11][0] = 7'd1;
	assign Q4[11][0] = 7'd65;
	assign P4[11][1] = 7'd33;
	assign Q4[11][1] = 7'd97;
	assign P4[11][2] = 7'd17;
	assign Q4[11][2] = 7'd81;
	assign P4[11][3] = 7'd49;
	assign Q4[11][3] = 7'd113;
	assign P4[12][0] = 7'd9;
	assign Q4[12][0] = 7'd73;
	assign P4[12][1] = 7'd41;
	assign Q4[12][1] = 7'd105;
	assign P4[12][2] = 7'd25;
	assign Q4[12][2] = 7'd89;
	assign P4[12][3] = 7'd57;
	assign Q4[12][3] = 7'd121;
	assign P4[13][0] = 7'd11;
	assign Q4[13][0] = 7'd75;
	assign P4[13][1] = 7'd43;
	assign Q4[13][1] = 7'd107;
	assign P4[13][2] = 7'd27;
	assign Q4[13][2] = 7'd91;
	assign P4[13][3] = 7'd59;
	assign Q4[13][3] = 7'd123;
	assign P4[14][0] = 7'd5;
	assign Q4[14][0] = 7'd69;
	assign P4[14][1] = 7'd37;
	assign Q4[14][1] = 7'd101;
	assign P4[14][2] = 7'd21;
	assign Q4[14][2] = 7'd85;
	assign P4[14][3] = 7'd53;
	assign Q4[14][3] = 7'd117;
	assign P4[15][0] = 7'd7;
	assign Q4[15][0] = 7'd71;
	assign P4[15][1] = 7'd39;
	assign Q4[15][1] = 7'd103;
	assign P4[15][2] = 7'd23;
	assign Q4[15][2] = 7'd87;
	assign P4[15][3] = 7'd55;
	assign Q4[15][3] = 7'd119;
	assign P4[16][0] = 7'd8;
	assign Q4[16][0] = 7'd9;
	assign P4[16][1] = 7'd40;
	assign Q4[16][1] = 7'd41;
	assign P4[16][2] = 7'd24;
	assign Q4[16][2] = 7'd25;
	assign P4[16][3] = 7'd56;
	assign Q4[16][3] = 7'd57;
	assign P4[17][0] = 7'd4;
	assign Q4[17][0] = 7'd5;
	assign P4[17][1] = 7'd36;
	assign Q4[17][1] = 7'd37;
	assign P4[17][2] = 7'd20;
	assign Q4[17][2] = 7'd21;
	assign P4[17][3] = 7'd52;
	assign Q4[17][3] = 7'd53;
	assign P4[18][0] = 7'd14;
	assign Q4[18][0] = 7'd15;
	assign P4[18][1] = 7'd46;
	assign Q4[18][1] = 7'd47;
	assign P4[18][2] = 7'd30;
	assign Q4[18][2] = 7'd31;
	assign P4[18][3] = 7'd62;
	assign Q4[18][3] = 7'd63;
	assign P4[19][0] = 7'd2;
	assign Q4[19][0] = 7'd3;
	assign P4[19][1] = 7'd34;
	assign Q4[19][1] = 7'd35;
	assign P4[19][2] = 7'd18;
	assign Q4[19][2] = 7'd19;
	assign P4[19][3] = 7'd50;
	assign Q4[19][3] = 7'd51;
	assign P4[20][0] = 7'd6;
	assign Q4[20][0] = 7'd7;
	assign P4[20][1] = 7'd38;
	assign Q4[20][1] = 7'd39;
	assign P4[20][2] = 7'd22;
	assign Q4[20][2] = 7'd23;
	assign P4[20][3] = 7'd54;
	assign Q4[20][3] = 7'd55;
	assign P4[21][0] = 7'd10;
	assign Q4[21][0] = 7'd11;
	assign P4[21][1] = 7'd42;
	assign Q4[21][1] = 7'd43;
	assign P4[21][2] = 7'd26;
	assign Q4[21][2] = 7'd27;
	assign P4[21][3] = 7'd58;
	assign Q4[21][3] = 7'd59;
	assign P4[22][0] = 7'd0;
	assign Q4[22][0] = 7'd1;
	assign P4[22][1] = 7'd32;
	assign Q4[22][1] = 7'd33;
	assign P4[22][2] = 7'd16;
	assign Q4[22][2] = 7'd17;
	assign P4[22][3] = 7'd48;
	assign Q4[22][3] = 7'd49;
	assign P4[23][0] = 7'd12;
	assign Q4[23][0] = 7'd13;
	assign P4[23][1] = 7'd44;
	assign Q4[23][1] = 7'd45;
	assign P4[23][2] = 7'd28;
	assign Q4[23][2] = 7'd29;
	assign P4[23][3] = 7'd60;
	assign Q4[23][3] = 7'd61;
	assign P4[24][0] = 7'd70;
	assign Q4[24][0] = 7'd71;
	assign P4[24][1] = 7'd102;
	assign Q4[24][1] = 7'd103;
	assign P4[24][2] = 7'd86;
	assign Q4[24][2] = 7'd87;
	assign P4[24][3] = 7'd118;
	assign Q4[24][3] = 7'd119;
	assign P4[25][0] = 7'd64;
	assign Q4[25][0] = 7'd65;
	assign P4[25][1] = 7'd96;
	assign Q4[25][1] = 7'd97;
	assign P4[25][2] = 7'd80;
	assign Q4[25][2] = 7'd81;
	assign P4[25][3] = 7'd112;
	assign Q4[25][3] = 7'd113;
	assign P4[26][0] = 7'd72;
	assign Q4[26][0] = 7'd73;
	assign P4[26][1] = 7'd104;
	assign Q4[26][1] = 7'd105;
	assign P4[26][2] = 7'd88;
	assign Q4[26][2] = 7'd89;
	assign P4[26][3] = 7'd120;
	assign Q4[26][3] = 7'd121;
	assign P4[27][0] = 7'd78;
	assign Q4[27][0] = 7'd79;
	assign P4[27][1] = 7'd110;
	assign Q4[27][1] = 7'd111;
	assign P4[27][2] = 7'd94;
	assign Q4[27][2] = 7'd95;
	assign P4[27][3] = 7'd126;
	assign Q4[27][3] = 7'd127;
	assign P4[28][0] = 7'd76;
	assign Q4[28][0] = 7'd77;
	assign P4[28][1] = 7'd108;
	assign Q4[28][1] = 7'd109;
	assign P4[28][2] = 7'd92;
	assign Q4[28][2] = 7'd93;
	assign P4[28][3] = 7'd124;
	assign Q4[28][3] = 7'd125;
	assign P4[29][0] = 7'd74;
	assign Q4[29][0] = 7'd75;
	assign P4[29][1] = 7'd106;
	assign Q4[29][1] = 7'd107;
	assign P4[29][2] = 7'd90;
	assign Q4[29][2] = 7'd91;
	assign P4[29][3] = 7'd122;
	assign Q4[29][3] = 7'd123;
	assign P4[30][0] = 7'd66;
	assign Q4[30][0] = 7'd67;
	assign P4[30][1] = 7'd98;
	assign Q4[30][1] = 7'd99;
	assign P4[30][2] = 7'd82;
	assign Q4[30][2] = 7'd83;
	assign P4[30][3] = 7'd114;
	assign Q4[30][3] = 7'd115;
	assign P4[31][0] = 7'd68;
	assign Q4[31][0] = 7'd69;
	assign P4[31][1] = 7'd100;
	assign Q4[31][1] = 7'd101;
	assign P4[31][2] = 7'd84;
	assign Q4[31][2] = 7'd85;
	assign P4[31][3] = 7'd116;
	assign Q4[31][3] = 7'd117;
	
	
endmodule 