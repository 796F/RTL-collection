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

module FFT_128(clk,
			   rst_n,
			   init,
			   Final,
			   yi,
			   yo
			   );

	input               clk;			   
	input               rst_n;
	input               init;
	input               Final;
	input  [  64*8-1:0] yi;	
	output [128*10-1:0] yo;
	
	
	reg         [4:0]       state;
	reg signed  [9:0]       yReg128 [127:0];
	reg                     init64;
	reg  signed [64*10-1:0] yo64_1;//change to reg to store the res for the frist half
	wire signed [64*10-1:0] yo64_2;
	wire signed [64*10-1:0] yi64_1;
	wire signed [64*10-1:0] yi64_2;
	wire signed [64*10-1:0] yi64_re;//reuse
	wire signed [64*10-1:0] yo64_re;
	wire signed [15:0] yReg128_125_inter;
	wire signed [15:0] yReg128_127_inter;
	
	
	parameter idle      = 4'd0;
	parameter load      = 4'd1;//for first half of yi to fft64
	parameter waitn     = 4'd2;
	parameter finish    = 4'd3;
	parameter load_ag   = 4'd4;//for first half of yi to reuse fft64
	parameter waitn_ag  = 4'd5;
	parameter finish_ag = 4'd6;
	
	assign yReg128_127_inter = (-(MUL098(yi[511:504]-1)));
	assign yReg128_125_inter = (-(MUL058(yi[495:488]-1)));
	
	FFT_64 myFFT64_reuse(.clk(clk), 
						 .rst_n(rst_n), 						 
						 .init(init64), 
						 .yi(yi64_re), 
						 .yo(yo64_re)
						 );

	genvar i;
	generate
	for(i=0; i<64; i=i+1)
	begin:yi64
		assign yi64_1[i*10+9:i*10] = yReg128[i];
		assign yi64_2[i*10+9:i*10] = yReg128[i+64];
		assign yo[(i+1)*10-1:i*10] = yo64_1[(i+1)*10-1:i*10];
		assign yo[(i+65)*10-1:(i+64)*10] = yo64_re[(i+1)*10-1:i*10];
	end
	endgenerate

  //reuse
  assign yi64_re = (state==load||state == waitn||state == finish)? yi64_1: yi64_2;
  
  //store the res for the first round of fft64
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			yo64_1 <= 0;
		end
		else if (state == finish) begin
			yo64_1 <= yo64_re; 
		end
		else begin
			yo64_1 <= yo64_1; 
		end
	end 
	
	
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			state <= idle;
		else if(init == 1'd1)
			state <= load;		
		else if(state == load)
			state <= waitn;
		else if(state == waitn)
			state <= finish;
		else if(state == finish)
			state <= load_ag;
		else if(state == load_ag)
			state <= waitn_ag;
		else if(state == waitn_ag)
			state <= finish_ag;
		else if(state == finish_ag)
			state <= idle;
		else
			state <= state;	
	end

	//signal the fft 64 module to begin
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			init64 <= 1'd0;
		else if(init||state==finish)
			init64 <= 1'd1;
		else
			init64 <= 1'd0;
	end
	integer j;
	

	
	
	//main function: loading data and initial preparation
	always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			for(j=0; j<128; j=j+1)
			begin
				yReg128[j] <= 0;
			end
		end
		else if(init)
		begin
			yReg128[0] <= yi[7:0];
			yReg128[1] <= yi[15:8];
			yReg128[2] <= yi[23:16];
			yReg128[3] <= yi[31:24];
			yReg128[4] <= yi[39:32];
			yReg128[5] <= yi[47:40];
			yReg128[6] <= yi[55:48];
			yReg128[7] <= yi[63:56];
			yReg128[8] <= yi[71:64];
			yReg128[9] <= yi[79:72];
			yReg128[10] <= yi[87:80];
			yReg128[11] <= yi[95:88];
			yReg128[12] <= yi[103:96];
			yReg128[13] <= yi[111:104];
			yReg128[14] <= yi[119:112];
			yReg128[15] <= yi[127:120];
			yReg128[16] <= yi[135:128];
			yReg128[17] <= yi[143:136];
			yReg128[18] <= yi[151:144];
			yReg128[19] <= yi[159:152];
			yReg128[20] <= yi[167:160];
			yReg128[21] <= yi[175:168];
			yReg128[22] <= yi[183:176];
			yReg128[23] <= yi[191:184];
			yReg128[24] <= yi[199:192];
			yReg128[25] <= yi[207:200];
			yReg128[26] <= yi[215:208];
			yReg128[27] <= yi[223:216];
			yReg128[28] <= yi[231:224];
			yReg128[29] <= yi[239:232];
			yReg128[30] <= yi[247:240];
			yReg128[31] <= yi[255:248];
			yReg128[32] <= yi[263:256];
			yReg128[33] <= yi[271:264];
			yReg128[34] <= yi[279:272];
			yReg128[35] <= yi[287:280];
			yReg128[36] <= yi[295:288];
			yReg128[37] <= yi[303:296];
			yReg128[38] <= yi[311:304];
			yReg128[39] <= yi[319:312];
			yReg128[40] <= yi[327:320];
			yReg128[41] <= yi[335:328];
			yReg128[42] <= yi[343:336];
			yReg128[43] <= yi[351:344];
			yReg128[44] <= yi[359:352];
			yReg128[45] <= yi[367:360];
			yReg128[46] <= yi[375:368];
			yReg128[47] <= yi[383:376];
			yReg128[48] <= yi[391:384];
			yReg128[49] <= yi[399:392];
			yReg128[50] <= yi[407:400];
			yReg128[51] <= yi[415:408];
			yReg128[52] <= yi[423:416];
			yReg128[53] <= yi[431:424];
			yReg128[54] <= yi[439:432];
			yReg128[55] <= yi[447:440];
			yReg128[56] <= yi[455:448];
			yReg128[57] <= yi[463:456];
			yReg128[58] <= yi[471:464];
			yReg128[59] <= yi[479:472];
			yReg128[60] <= yi[487:480];
			yReg128[61] <= (Final == 1) ? ((((yi[495:488] + 1))&255) - (((yi[495:488] + 1)) >>> 8)) : yi[495:488];
			yReg128[62] <= yi[503:496];
			yReg128[63] <= (((yi[511:504] + 1))&255) - (((yi[511:504] + 1)) >>> 8);
			yReg128[64] <= ((yi[7:0])&255) - ((yi[7:0]) >>> 8);
			yReg128[65] <= (-(MUL118(yi[15:8]))&255) - (-(MUL118(yi[15:8])) >>> 8);
			yReg128[66] <= ((MUL046(yi[23:16]))&255) - ((MUL046(yi[23:16])) >>> 8);
			yReg128[67] <= (-(MUL031(yi[31:24]))&255) - (-(MUL031(yi[31:24])) >>> 8);
			yReg128[68] <= ((MUL060(yi[39:32]))&255) - ((MUL060(yi[39:32])) >>> 8);
			yReg128[69] <= ((MUL116(yi[47:40]))&255) - ((MUL116(yi[47:40])) >>> 8);
			yReg128[70] <= (-(MUL067(yi[55:48]))&255) - (-(MUL067(yi[55:48])) >>> 8);
			yReg128[71] <= (-(MUL061(yi[63:56]))&255) - (-(MUL061(yi[63:56])) >>> 8);
			yReg128[72] <= ((MUL002(yi[71:64]))&255) - ((MUL002(yi[71:64])) >>> 8);
			yReg128[73] <= ((MUL021(yi[79:72]))&255) - ((MUL021(yi[79:72])) >>> 8);
			yReg128[74] <= ((MUL092(yi[87:80]))&255) - ((MUL092(yi[87:80])) >>> 8);
			yReg128[75] <= (-(MUL062(yi[95:88]))&255) - (-(MUL062(yi[95:88])) >>> 8);
			yReg128[76] <= ((MUL120(yi[103:96]))&255) - ((MUL120(yi[103:96])) >>> 8);
			yReg128[77] <= (-(MUL025(yi[111:104]))&255) - (-(MUL025(yi[111:104])) >>> 8);
			yReg128[78] <= ((MUL123(yi[119:112]))&255) - ((MUL123(yi[119:112])) >>> 8);
			yReg128[79] <= (-(MUL122(yi[127:120]))&255) - (-(MUL122(yi[127:120])) >>> 8);
			yReg128[80] <= ((MUL004(yi[135:128]))&255) - ((MUL004(yi[135:128])) >>> 8);
			yReg128[81] <= ((MUL042(yi[143:136]))&255) - ((MUL042(yi[143:136])) >>> 8);
			yReg128[82] <= (-(MUL073(yi[151:144]))&255) - (-(MUL073(yi[151:144])) >>> 8);
			yReg128[83] <= (-(MUL124(yi[159:152]))&255) - (-(MUL124(yi[159:152])) >>> 8);
			yReg128[84] <= (-(MUL017(yi[167:160]))&255) - (-(MUL017(yi[167:160])) >>> 8);
			yReg128[85] <= (-(MUL050(yi[175:168]))&255) - (-(MUL050(yi[175:168])) >>> 8);
			yReg128[86] <= (-(MUL011(yi[183:176]))&255) - (-(MUL011(yi[183:176])) >>> 8);
			yReg128[87] <= ((MUL013(yi[191:184]))&255) - ((MUL013(yi[191:184])) >>> 8);
			yReg128[88] <= ((MUL008(yi[199:192]))&255) - ((MUL008(yi[199:192])) >>> 8);
			yReg128[89] <= ((MUL084(yi[207:200]))&255) - ((MUL084(yi[207:200])) >>> 8);
			yReg128[90] <= ((MUL111(yi[215:208]))&255) - ((MUL111(yi[215:208])) >>> 8);
			yReg128[91] <= ((MUL009(yi[223:216]))&255) - ((MUL009(yi[223:216])) >>> 8);
			yReg128[92] <= (-(MUL034(yi[231:224]))&255) - (-(MUL034(yi[231:224])) >>> 8);
			yReg128[93] <= (-(MUL100(yi[239:232]))&255) - (-(MUL100(yi[239:232])) >>> 8);
			yReg128[94] <= (-(MUL022(yi[247:240]))&255) - (-(MUL022(yi[247:240])) >>> 8);
			yReg128[95] <= ((MUL026(yi[255:248]))&255) - ((MUL026(yi[255:248])) >>> 8);
			yReg128[96] <= ((MUL016(yi[263:256]))&255) - ((MUL016(yi[263:256])) >>> 8);
			yReg128[97] <= (-(MUL089(yi[271:264]))&255) - (-(MUL089(yi[271:264])) >>> 8);
			yReg128[98] <= (-(MUL035(yi[279:272]))&255) - (-(MUL035(yi[279:272])) >>> 8);
			yReg128[99] <= ((MUL018(yi[287:280]))&255) - ((MUL018(yi[287:280])) >>> 8);
			yReg128[100] <= (-(MUL068(yi[295:288]))&255) - (-(MUL068(yi[295:288])) >>> 8);
			yReg128[101] <= ((MUL057(yi[303:296]))&255) - ((MUL057(yi[303:296])) >>> 8);
			yReg128[102] <= (-(MUL044(yi[311:304]))&255) - (-(MUL044(yi[311:304])) >>> 8);
			yReg128[103] <= ((MUL052(yi[319:312]))&255) - ((MUL052(yi[319:312])) >>> 8);
			yReg128[104] <= ((MUL032(yi[327:320]))&255) - ((MUL032(yi[327:320])) >>> 8);
			yReg128[105] <= ((MUL079(yi[335:328]))&255) - ((MUL079(yi[335:328])) >>> 8);
			yReg128[106] <= (-(MUL070(yi[343:336]))&255) - (-(MUL070(yi[343:336])) >>> 8);
			yReg128[107] <= ((MUL036(yi[351:344]))&255) - ((MUL036(yi[351:344])) >>> 8);
			yReg128[108] <= ((MUL121(yi[359:352]))&255) - ((MUL121(yi[359:352])) >>> 8);
			yReg128[109] <= ((MUL114(yi[367:360]))&255) - ((MUL114(yi[367:360])) >>> 8);
			yReg128[110] <= (-(MUL088(yi[375:368]))&255) - (-(MUL088(yi[375:368])) >>> 8);
			yReg128[111] <= ((MUL104(yi[383:376]))&255) - ((MUL104(yi[383:376])) >>> 8);
			yReg128[112] <= ((MUL064(yi[391:384]))&255) - ((MUL064(yi[391:384])) >>> 8);
			yReg128[113] <= (-(MUL099(yi[399:392]))&255) - (-(MUL099(yi[399:392])) >>> 8);
			yReg128[114] <= ((MUL117(yi[407:400]))&255) - ((MUL117(yi[407:400])) >>> 8);
			yReg128[115] <= ((MUL072(yi[415:408]))&255) - ((MUL072(yi[415:408])) >>> 8);
			yReg128[116] <= (-(MUL015(yi[423:416]))&255) - (-(MUL015(yi[423:416])) >>> 8);
			yReg128[117] <= (-(MUL029(yi[431:424]))&255) - (-(MUL029(yi[431:424])) >>> 8);
			yReg128[118] <= ((MUL081(yi[439:432]))&255) - ((MUL081(yi[439:432])) >>> 8);
			yReg128[119] <= (-(MUL049(yi[447:440]))&255) - (-(MUL049(yi[447:440])) >>> 8);
			yReg128[120] <= ((MUL128(yi[455:448]))&255) - ((MUL128(yi[455:448])) >>> 8);
			yReg128[121] <= ((MUL059(yi[463:456]))&255) - ((MUL059(yi[463:456])) >>> 8);
			yReg128[122] <= (-(MUL023(yi[471:464]))&255) - (-(MUL023(yi[471:464])) >>> 8);
			yReg128[123] <= (-(MUL113(yi[479:472]))&255) - (-(MUL113(yi[479:472])) >>> 8);
			yReg128[124] <= (-(MUL030(yi[487:480]))&255) - (-(MUL030(yi[487:480])) >>> 8);
			//yReg128[125] <= (Final == 1) ? (((&255) - ((-(MUL058(yi[495:488]-1))) >>> 8)) : ((-(MUL058({1'b0,yi[495:488]}))&255) - (-(MUL058({1'b0,yi[495:488]})) >>> 8));
			yReg128[125] <= (Final == 1) ? {2'b0,yReg128_125_inter[7:0]} - {{2{yReg128_125_inter[15]}},yReg128_125_inter[15:8]} : ((-(MUL058({1'b0,yi[495:488]}))&255) - (-(MUL058({1'b0,yi[495:488]})) >>> 8));			
			yReg128[126] <= (-(MUL095(yi[503:496]))&255) - (-(MUL095(yi[503:496])) >>> 8);
			//yReg128[127] <= ((-(MUL098(yi[511:504]-1)))&255) - ((-(MUL098(yi[511:504]-1))) >>> 8);
			yReg128[127] <= {2'b0,yReg128_127_inter[7:0]} - {{2{yReg128_127_inter[15]}},yReg128_127_inter[15:8]};
			
		end
		else
		begin
			for(j=0; j<128; j=j+1)
			begin
				yReg128[j] <= yReg128[j];
			end
			

		end
	end
	
	
	
	//multiplication function
	function signed [15:0] MUL118;
	  input [7:0] op;
	  begin
		MUL118 = 0 + (op<<1)  + (op<<2)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL046;
	  input [7:0] op;
	  begin
		MUL046 = 0 + (op<<1)  + (op<<2)  + (op<<3)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL031;
	  input [7:0] op;
	  begin
		MUL031 = 0 + op     + (op<<1)  + (op<<2)  + (op<<3)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL060;
	  input [7:0] op;
	  begin
		MUL060 = 0 + (op<<2)  + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL116;
	  input [7:0] op;
	  begin
		MUL116 = 0 + (op<<2)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL067;
	  input [7:0] op;
	  begin
		MUL067 = 0 + op     + (op<<1)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL061;
	  input [7:0] op;
	  begin
		MUL061 = 0 + op     + (op<<2)  + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL002;
	  input [7:0] op;
	  begin
		MUL002 = 0 + (op<<1) ;
	  end
	endfunction

	function signed [15:0] MUL021;
	  input [7:0] op;
	  begin
		MUL021 = 0 + op     + (op<<2)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL092;
	  input [7:0] op;
	  begin
		MUL092 = 0 + (op<<2)  + (op<<3)  + (op<<4)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL062;
	  input [7:0] op;
	  begin
		MUL062 = 0 + (op<<1)  + (op<<2)  + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL120;
	  input [7:0] op;
	  begin
		MUL120 = 0 + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL025;
	  input [7:0] op;
	  begin
		MUL025 = 0 + op     + (op<<3)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL123;
	  input [7:0] op;
	  begin
		MUL123 = 0 + op     + (op<<1)  + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL122;
	  input [7:0] op;
	  begin
		MUL122 = 0 + (op<<1)  + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL004;
	  input [7:0] op;
	  begin
		MUL004 = 0 + (op<<2) ;
	  end
	endfunction

	function signed [15:0] MUL042;
	  input [7:0] op;
	  begin
		MUL042 = 0 + (op<<1)  + (op<<3)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL073;
	  input [7:0] op;
	  begin
		MUL073 = 0 + op     + (op<<3)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL124;
	  input [7:0] op;
	  begin
		MUL124 = 0 + (op<<2)  + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL017;
	  input [7:0] op;
	  begin
		MUL017 = 0 + op     + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL050;
	  input [7:0] op;
	  begin
		MUL050 = 0 + (op<<1)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL011;
	  input [7:0] op;
	  begin
		MUL011 = 0 + op     + (op<<1)  + (op<<3) ;
	  end
	endfunction

	function signed [15:0] MUL013;
	  input [7:0] op;
	  begin
		MUL013 = 0 + op     + (op<<2)  + (op<<3) ;
	  end
	endfunction

	function signed [15:0] MUL008;
	  input [7:0] op;
	  begin
		MUL008 = 0 + (op<<3) ;
	  end
	endfunction

	function signed [15:0] MUL084;
	  input [7:0] op;
	  begin
		MUL084 = 0 + (op<<2)  + (op<<4)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL111;
	  input [7:0] op;
	  begin
		MUL111 = 0 + op     + (op<<1)  + (op<<2)  + (op<<3)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL009;
	  input [7:0] op;
	  begin
		MUL009 = 0 + op     + (op<<3) ;
	  end
	endfunction

	function signed [15:0] MUL034;
	  input [7:0] op;
	  begin
		MUL034 = 0 + (op<<1)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL100;
	  input [7:0] op;
	  begin
		MUL100 = 0 + (op<<2)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL022;
	  input [7:0] op;
	  begin
		MUL022 = 0 + (op<<1)  + (op<<2)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL026;
	  input [7:0] op;
	  begin
		MUL026 = 0 + (op<<1)  + (op<<3)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL016;
	  input [7:0] op;
	  begin
		MUL016 = 0 + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL089;
	  input [7:0] op;
	  begin
		MUL089 = 0 + op     + (op<<3)  + (op<<4)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL035;
	  input [7:0] op;
	  begin
		MUL035 = 0 + op     + (op<<1)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL018;
	  input [7:0] op;
	  begin
		MUL018 = 0 + (op<<1)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL068;
	  input [7:0] op;
	  begin
		MUL068 = 0 + (op<<2)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL057;
	  input [7:0] op;
	  begin
		MUL057 = 0 + op     + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL044;
	  input [7:0] op;
	  begin
		MUL044 = 0 + (op<<2)  + (op<<3)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL052;
	  input [7:0] op;
	  begin
		MUL052 = 0 + (op<<2)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL032;
	  input [7:0] op;
	  begin
		MUL032 = 0 + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL079;
	  input [7:0] op;
	  begin
		MUL079 = 0 + op     + (op<<1)  + (op<<2)  + (op<<3)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL070;
	  input [7:0] op;
	  begin
		MUL070 = 0 + (op<<1)  + (op<<2)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL036;
	  input [7:0] op;
	  begin
		MUL036 = 0 + (op<<2)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL121;
	  input [7:0] op;
	  begin
		MUL121 = 0 + op     + (op<<3)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL114;
	  input [7:0] op;
	  begin
		MUL114 = 0 + (op<<1)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL088;
	  input [7:0] op;
	  begin
		MUL088 = 0 + (op<<3)  + (op<<4)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL104;
	  input [7:0] op;
	  begin
		MUL104 = 0 + (op<<3)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL064;
	  input [7:0] op;
	  begin
		MUL064 = 0 + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL099;
	  input [7:0] op;
	  begin
		MUL099 = 0 + op     + (op<<1)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL117;
	  input [7:0] op;
	  begin
		MUL117 = 0 + op     + (op<<2)  + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL072;
	  input [7:0] op;
	  begin
		MUL072 = 0 + (op<<3)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL015;
	  input [7:0] op;
	  begin
		MUL015 = 0 + op     + (op<<1)  + (op<<2)  + (op<<3) ;
	  end
	endfunction

	function signed [15:0] MUL029;
	  input [7:0] op;
	  begin
		MUL029 = 0 + op     + (op<<2)  + (op<<3)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL081;
	  input [7:0] op;
	  begin
		MUL081 = 0 + op     + (op<<4)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL049;
	  input [7:0] op;
	  begin
		MUL049 = 0 + op     + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL128;
	  input [7:0] op;
	  begin
		MUL128 = 0 + (op<<7) ;
	  end
	endfunction

	function signed [15:0] MUL059;
	  input [7:0] op;
	  begin
		MUL059 = 0 + op     + (op<<1)  + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL023;
	  input [7:0] op;
	  begin
		MUL023 = 0 + op     + (op<<1)  + (op<<2)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL113;
	  input [7:0] op;
	  begin
		MUL113 = 0 + op     + (op<<4)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL030;
	  input [7:0] op;
	  begin
		MUL030 = 0 + (op<<1)  + (op<<2)  + (op<<3)  + (op<<4) ;
	  end
	endfunction

	function signed [15:0] MUL058;
	  input signed [8:0] op;
	  begin
		MUL058 = 0 + (op<<1)  + (op<<3)  + (op<<4)  + (op<<5) ;
	  end
	endfunction

	function signed [15:0] MUL095;
	  input [7:0] op;
	  begin
		MUL095 = 0 + op     + (op<<1)  + (op<<2)  + (op<<3)  + (op<<4)  + (op<<6) ;
	  end
	endfunction

	function signed [15:0] MUL098;
	  input signed [8:0] op;
	  begin
		MUL098 = 0 + (op<<1)  + (op<<5)  + (op<<6) ;
	  end
	endfunction

endmodule