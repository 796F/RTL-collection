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

module F8 (clk, 
		       rst_n, 
		       enable, 
		       buffer, 
		       init, 
		       state_H_O, 
		       done
		       );

parameter idle = 0;
parameter busy = 1;

input              clk;
input              rst_n;
input              enable;
input  [511:0]     buffer;
input              init;
output [128*8-1:0] state_H_O;
output             done;

wire start;
wire half;
reg  [ 64*4-1:0] round;
reg  [256*4-1:0] state_A;
reg  [128*8-1:0] state_H;
reg  [5:0]       counter;
reg              state;
wire [256*4-1:0] state_A_new;
wire [128*8-1:0] state_H_out;
wire [ 64*4-1:0] round_new;
wire [16*2*4-1:0] S_box; 
wire [128*8-1:0] state_H_in;
wire [128*8-1:0] state_H_new;

E8 myE8 (.round_in(round), 
		     .S_box(S_box), 
		     .state_A_in(state_A), 
		     .state_H_in(state_H_in), 
		     .half(half), 
		     .start(start), 
		     .state_A_out(state_A_new), 
		     .state_H_out(state_H_out), 
		     .round_out(round_new)
		     );

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
		state <= 0;
	else if((state == idle) && enable)
		state <= busy;
	else if((state == busy) && (counter == 6'd35))
		state <= idle;
	else
		state <= state;
	
end

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
		counter <= 0;
	else if(init)
		counter <= 0;
	else if((state == idle) && enable)
		counter <= counter + 1;
	else if((state == busy) && (counter == 6'd35))
		counter <= 0;
	else if(state == busy)
		counter <= counter + 1;
	else
		counter <= counter;
end

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
		round <= 256'd0;
	else if(init)
		round <= 256'ha2237660b095f2ad99057721571ceda3e3d759ae6631bf2b809ccb3f766e90a6;
	else if(half)
		round <= 256'ha2237660b095f2ad99057721571ceda3e3d759ae6631bf2b809ccb3f766e90a6;
	else if(state == busy | enable)
		round <= round_new;
	else
		round <= 256'ha2237660b095f2ad99057721571ceda3e3d759ae6631bf2b809ccb3f766e90a6;
end

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
		state_A <= 0;
	else
		state_A <= state_A_new;
end

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
		state_H <= 0;
	else if(init)
		state_H <= 1024'h90ac69e764c08fe2177f905f3efa701638b2f52534b6b8f0a504d15f7972579f785102e2ec00a81b10e55d071e32ce4c717252905400e7b00431316dba8c3e145faca78e6305b2d3df5d1b90cabe2062d6a2c58ce14c2bc4e22919b9c191297b0122a9067861c72f7a1f7106d9b74561e5e67a1def457e426e593ac5e2b868c9;
	else if(counter == 6'd35)
		state_H <= state_H_new;
	else
		state_H <= state_H;
end

assign S_box = 128'h8eab402f9175d6c3e85762a1f3cdb409;
assign state_H_in [511:0] = state_H [511:0] ^ buffer;
assign state_H_in [1023:512] = state_H [1023:512];
assign state_H_new [511:0] = state_H_out [511:0];
assign state_H_new [1023:512] = state_H_out [1023:512] ^ buffer;
assign state_H_O = state_H;
assign start = (counter == 0) ? 1 : 0;
assign half = (counter == 35) ? 1 : 0;
assign done = (counter ==0 && state == idle) ? 1 : 0;

endmodule 