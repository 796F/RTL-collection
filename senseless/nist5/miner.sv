/*
 * Copyright (c) 2016 Sprocket
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License with
 * additional permissions to the one published by the Free Software
 * Foundation, either version 3 of the License, or (at your option)
 * any later version. For more information see LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

module miner # (
	parameter CORES = 32'd1
) (
	input clk,
	input reset,
	input [639:0] inblock,
	input [31:0] nonce_start,
	output reg nonce_found,
	output reg [31:0] nonce_out,
	output reg [31:0] hash_out
);

	localparam OFFSET = 32'd274;

	wire [639:0] msg;
	wire [511:0] hash1;
	//wire [255:0] hash2;
	wire [31:0] hash3;
	
	reg [607:0] data;
	reg [31:0] target;
	reg [31:0] nonce;
	reg [31:0] hash;
	reg reset1;
	
	// Here is where the input block is split between data and nonce.
	// Currently the nonce is the least significant word of the input block
	assign msg = {data, nonce};
	// Here is where the computed hash is extracted to check for validity.
	// Currently the check is done on the least significant word of the computed hash.
	assign hash3 = hash1[31:0];
	
	db_nist5 nist5_core ( clk, msg, hash1 );

	always @ ( posedge clk ) begin
	
		//hash_out <= 32'hFFFFFFFF;
        hash_out <= hash;

		data <= inblock[639:32];
		target <= inblock[31:0];

		if ( reset1 ) begin

			nonce <= nonce_start;
			nonce_out <= nonce_start - (CORES * OFFSET);

		end
		else begin
		
			nonce <= nonce + CORES;
			nonce_out <= nonce_out + CORES;
			
		end
		
		hash <= { hash3[7:0], hash3[15:8], hash3[23:16], hash3[31:24] };

		if ( hash <= target )
			nonce_found <= 1'b1;
		else
			nonce_found <= 1'b0;
		reset1 = reset;
		
//		$display ("Hash1 : %x", hash1);
//		$display ("Hash2 : %x", hash2);
//		$display ("Hash3 : %x", hash3);
		$display("Nonce: %x, Hash: %x, Found: %d", nonce_out, hash_out, nonce_found );
		
	end

endmodule
