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
module HAMSI_INTERFACE(
	                    clk, 
	                    rst_n, 
	                    EOM,
	                    init, 
	                    load, 
	                    fetch, 
	                    idata,                               
	                    ack, 
	                    odata,                                             
	                    busy, 
	                    hash0, 
	                    hash1, 
	                    hash2, 
	                    hash3, 
	                    hash4, 
	                    hash5, 
	                    hash6, 
	                    hash7, 
	                    init_r, 
	                    EN, 
	                    idata_r,                                    
	                    finAll);  

input         clk;
input         rst_n;
input         init;
input         load;
input         fetch;
input  [15:0] idata;
input	        finAll;
input         EOM;
input         busy;
input  [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7;
output        init_r, EN;
output [31:0] idata_r;
output        ack;
output [15:0] odata;

reg        init_r;
reg        load_r, fetch_r;
reg        ack_r;
reg [31:0] idata_r;
reg [15:0] odata_r;
reg [ 3:0] data_count;
reg [ 2:0] state;
reg [ 2:0] next_state;

assign EN = (((state == 3'b010) && (data_count[0] == 1'b0)) || (EOM && ~finAll))? 1'b1 : 1'b0; /* when hash execution state and input data_count is odd */

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		init_r <= 1'b0;
	end
	else begin
		if (init) begin
			init_r <= 1'b1;
		end
		else begin
			init_r <= 1'b0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		load_r <= 1'b0;
	end
	else begin
		if (load) begin
			load_r <= 1'b1;
		end
		else begin
			load_r <= 1'b0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		fetch_r <= 1'b0;
	end
	else begin
		if (fetch) begin
			fetch_r <= 1'b1;
		end
		else begin
			fetch_r <= 1'b0;
		end
	end
end

assign ack = ack_r;
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) begin
		ack_r <= 1'b0;
	end
	else begin
		if (state == 3'b001 || state == 3'b100) begin /* if load state (3'b001) or fetch state (3'b100) */
			ack_r <= 1'b1;
		end
		else begin
			ack_r <= 1'b0;
		end
	end
end

assign odata = odata_r;
always @(posedge clk or negedge rst_n)begin
	if (~rst_n) begin
		odata_r <= 16'h0;
	end
	else begin
		if (state == 3'b011) begin
			if (data_count == 4'd0) begin
				odata_r <= hash0[31:16];
			end
			else if (data_count == 4'd1) begin
				odata_r <= hash0[15: 0];
			end
			else if (data_count == 4'd2) begin
				odata_r <= hash1[31:16];
			end
			else if (data_count == 4'd3) begin
				odata_r <= hash1[15: 0];
			end
			else if (data_count == 4'd4) begin
				odata_r <= hash2[31:16];
			end
			else if (data_count == 4'd5) begin
				odata_r <= hash2[15: 0];
			end
			else if (data_count == 4'd6) begin
				odata_r <= hash3[31:16];
			end
			else if (data_count == 4'd7) begin
				odata_r <= hash3[15: 0];
			end
			else if (data_count == 4'd8) begin
				odata_r <= hash4[31:16];
			end
			else if (data_count == 4'd9) begin
				odata_r <= hash4[15: 0];
			end
			else if (data_count == 4'd10) begin
				odata_r <= hash5[31:16];
			end
			else if (data_count == 4'd11) begin
				odata_r <= hash5[15: 0];
			end
			else if (data_count == 4'd12) begin
				odata_r <= hash6[31:16];
			end
			else if (data_count == 4'd13) begin
				odata_r <= hash6[15: 0];
			end
			else if (data_count == 4'd14) begin
				odata_r <= hash7[31:16];
			end
			else if (data_count == 4'd15) begin
				odata_r <= hash7[15: 0];
			end
		end
		else begin
			odata_r <= odata_r;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		data_count <= 4'h0;
	end
	else begin
		if (state == 3'b001) begin      /* if load state */
			if (data_count == 4'd1) begin
				if (~busy) begin
					data_count <= 4'h0;
				end
				else begin
					data_count <= data_count;
				end
			end
			else begin
				data_count <= data_count + 1'd1;
			end
		end
		else if (state == 3'b011) begin /* if fetch state */
			if (data_count == 4'd15) begin
				data_count <= 4'h0;
			end
			else begin
				data_count <= data_count + 1'd1;
			end
		end
		else begin
			data_count <= data_count;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		idata_r <= 32'h0;
	end
	else begin
		if (state == 3'b001) begin /* if load state */
			idata_r <= {idata_r[15:0],idata};
		end
		else begin
			idata_r <= idata_r;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state <= 3'b000;
	end
	else begin
		state <= next_state;
	end
end

always @(load_r or fetch_r or EN or busy or state) begin
	case (state)
	3'b000 : begin /* neutral state */
		if (load_r) begin
			next_state <= 3'b001;
		end
		else if (fetch_r && ~busy) begin
			next_state <= 3'b011;
		end
		else begin
			next_state <= 3'b000;
		end
	end
	3'b001 : begin /* load state */
		next_state <= 3'b010;
	end
	3'b010 : begin /* execution state */
		if (busy) begin
			next_state <= 3'b010;
		end
		else begin
			next_state <= 3'b000;
		end
	end
	3'b011 : begin /* fetch state */
		next_state <= 3'b100;
	end
	3'b100 : begin /* output state */
		next_state <= 3'b000;
	end
	default : begin
		next_state <= 3'b000;
	end
        endcase
end

endmodule

