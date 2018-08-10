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

module simd256_round(clk, 
										rst_n, 
										init,
										ena,
										mode_i,
										data_i,
										stat_i,
										stat_o,
										fin
										);

input						clk;
input						rst_n;
input           init;
input						ena;
input 					mode_i;
input		[511:0]	data_i;
input 	[511:0] stat_i;
output  [511:0] stat_o;
output          fin;



wire	 	[511:0] data_i;//ignored for wrapper testing
wire	 	[511:0] stat_i;//ignored for wrapper testing
reg	    [511:0] stat_o;
reg             fin;

parameter del_cyc = 44;//60;//delay outputs

wire [127:0]IA;
wire [127:0]IB;
wire [127:0]IC;
wire [127:0]ID;

wire [127:0]OA;
wire [127:0]OB;
wire [127:0]OC;
wire [127:0]OD;

assign IA = stat_i[511:511-127];
assign IB = stat_i[511-127-1:511-2*127-1];
assign IC = stat_i[511-2*127-2:511-3*127-2];
assign ID = stat_i[511-3*127-3:0];

reg ena_buf;
reg init_buf;

//------------------------------------------------------
//for empty core test

//capture the 1 clk pulse ena
reg ena_st;
wire		[511:0]	idata_reverse_byte;
wire		[511:0] idata_reverse_bit;
parameter B =  64;//W/8;//number of bytes
integer i,j;
genvar k;
 //endian conversion
 generate
 	for( k=0; k < B ; k = k + 1) begin: BYTE_REVERSE
 		assign idata_reverse_byte[(8*(k+1)-1):(8*k)] = data_i[(8*(B-k)-1):(8*(B-k-1))];
// 		assign odata[(8*(k+1)-1):(8*k)] = /*getconfig? 32'h0ea7f00d : */odata_reg[(8*(B-k)-1):(8*(B-k-1))];  
 	end
	for( k=0; k<512; k=k+1) begin: BIT_REVERSE
		assign idata_reverse_bit[k] = idata_reverse_byte[511-k];
	end
	
 endgenerate

//debug
wire [127:0]OA_re;
wire [127:0]OB_re;
wire [127:0]OC_re;
wire [127:0]OD_re;
SIMD_Compress mySIMDComp(.clk(clk),
						 .rst_n(rst_n),
						 .init(init_buf),						 
						 .enable(ena_buf),
						 .Final(mode_i),
						 .M(data_i), 
						 .IA(IA), 
						 .IB(IB), 
						 .IC(IC), 
						 .ID(ID), 
						 .OA(OA), 
						 .OB(OB), 
						 .OC(OC), 
						 .OD(OD)
						 );


always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n) 
	begin
		ena_buf  <=0;
		init_buf <=0;
	end
	else
	begin
		ena_buf <= ena;
		init_buf <= init;
	end

end
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
		ena_st  <=0;
	end
	else if (init) begin
		ena_st  <=0;
	end
	else if (ena) begin
		ena_st  <=1;
	end
	else begin
		ena_st  <= ena_st;
	end
end

//delay the output
reg [5:0] proc_cnt;
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
		proc_cnt <= 0;
	end
	else if (ena) begin
		proc_cnt <= 0;
	end
	else if (ena_st) begin
		if (proc_cnt == 6'd63) begin
			proc_cnt <= proc_cnt;
		end
		else begin
			proc_cnt <= proc_cnt + 1;
		end
	end
	else begin
		proc_cnt <= proc_cnt;
	end
end

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
		stat_o <= 0;
		fin    <= 0;
	end
	else if(init_buf) begin
		stat_o	<= stat_i;
		fin		<= 1;
	end
	else if (proc_cnt == del_cyc) begin
		stat_o <= {OA,OB,OC,OD};
		fin    <= 1;
	end
	else begin
		stat_o <= stat_o;
		fin    <= 0;
	end
end

endmodule

