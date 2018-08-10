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
module HAMSI_CORE(
	               clk, 
	               rst_n, 
	               load,                                            
	               init_r, 
	               EOM_r, 
	               EN, 
	               idata_r,                                  
	               busy, 
	               hash0, 
	               hash1, 
	               hash2, 
	               hash3, 
	               hash4, 
	               hash5, 
	               hash6, 
	               hash7,
	               finAll);

input         clk;
input         rst_n;
input         load;
input         init_r;
input         EOM_r;
input         EN;
input  [31:0] idata_r;
output        busy;
output [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7;
output        finAll;

reg finProcess;
/* hash : Preserve "Initial Value" or "Message Digest". */
reg [31:0] hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7;
/* status : Preserve status of "Non-linear Permutation P/Pf". */
reg [31:0] status0, status1,  status2,  status3,  status4,  status5,  status6,  status7;
reg [31:0] status8, status9, status10, status11, status12, status13, status14, status15;
/* count : Preserve number that "Non-linear Permutation P/Pf" has run. */
reg  [2:0] count;
/* start : Preserve state of "Concatenation has been done or not. */
reg        start;
/* finish : input "digest" to hash. */
wire        finish, busy;
/* msg : Character of "Expanded Message". */
wire [31:0] msg0, msg1, msg2, msg3, msg4, msg5, msg6, msg7;
/* concate : Character of value after "Concatenation". */
wire [31:0] concate0, concate1,  concate2,  concate3,  concate4,  concate5,  concate6,  concate7;
wire [31:0] concate8, concate9, concate10, concate11, concate12, concate13, concate14, concate15;
/* const : Preserve 2 types (EOM or not) of "Constant Value". */
wire [31:0] const0, const1,  const2,  const3,  const4,  const5,  const6,  const7;
wire [31:0] const8, const9, const10, const11, const12, const13, const14, const15;
/* add_out : Character of value after "Addition". */
wire [31:0] add_out0, add_out1,  add_out2,  add_out3,  add_out4,  add_out5,  add_out6,  add_out7;
wire [31:0] add_out8, add_out9, add_out10, add_out11, add_out12, add_out13, add_out14, add_out15;
/* sub_out : Character of value after "Substitution". */
wire [31:0] sub_out0, sub_out1,  sub_out2,  sub_out3,  sub_out4,  sub_out5,  sub_out6,  sub_out7;
wire [31:0] sub_out8, sub_out9, sub_out10, sub_out11, sub_out12, sub_out13, sub_out14, sub_out15;
/* diff_out : Character of value after "Diffusion". */
wire [31:0] diff_out0, diff_out1,  diff_out2,  diff_out3,  diff_out4,  diff_out5,  diff_out6,  diff_out7;
wire [31:0] diff_out8, diff_out9, diff_out10, diff_out11, diff_out12, diff_out13, diff_out14, diff_out15;
/* trunc_out : Character of value after "Truncation". */
wire [31:0] trunc_out0, trunc_out1, trunc_out2, trunc_out3, trunc_out4, trunc_out5, trunc_out6, trunc_out7;
/* digest : Character of value after 'Update Hash Value". */
wire [31:0] digest0, digest1, digest2, digest3, digest4, digest5, digest6, digest7;

EXPANSION expansion(.message(idata_r), .exp_out0(msg0), .exp_out1(msg1), .exp_out2(msg2), .exp_out3(msg3), .exp_out4(msg4), .exp_out5(msg5), .exp_out6(msg6), .exp_out7(msg7));

CONCATENATION  concatenation0( .concate_in(msg0),  .concate_out(concate0));
CONCATENATION  concatenation1( .concate_in(msg1),  .concate_out(concate1));
CONCATENATION  concatenation2(.concate_in(hash0),  .concate_out(concate2));
CONCATENATION  concatenation3(.concate_in(hash1),  .concate_out(concate3));
CONCATENATION  concatenation4(.concate_in(hash2),  .concate_out(concate4));
CONCATENATION  concatenation5(.concate_in(hash3),  .concate_out(concate5));
CONCATENATION  concatenation6( .concate_in(msg2),  .concate_out(concate6));
CONCATENATION  concatenation7( .concate_in(msg3),  .concate_out(concate7));
CONCATENATION  concatenation8( .concate_in(msg4),  .concate_out(concate8));
CONCATENATION  concatenation9( .concate_in(msg5),  .concate_out(concate9));
CONCATENATION concatenation10(.concate_in(hash4), .concate_out(concate10));
CONCATENATION concatenation11(.concate_in(hash5), .concate_out(concate11));
CONCATENATION concatenation12(.concate_in(hash6), .concate_out(concate12));
CONCATENATION concatenation13(.concate_in(hash7), .concate_out(concate13));
CONCATENATION concatenation14( .concate_in(msg6), .concate_out(concate14));
CONCATENATION concatenation15( .concate_in(msg7), .concate_out(concate15));

//Non-linear Permutation : P/Pf 
//Addition of Constants and Counter
ADDITION_TYPE0  addition0( .status_in(status0),  .const_in(const0),  .add_out(add_out0));
ADDITION_TYPE1  addition1( .status_in(status1),  .const_in(const1), .count_in(count), .add_out(add_out1));
ADDITION_TYPE0  addition2( .status_in(status2),  .const_in(const2),  .add_out(add_out2));
ADDITION_TYPE0  addition3( .status_in(status3),  .const_in(const3),  .add_out(add_out3));
ADDITION_TYPE0  addition4( .status_in(status4),  .const_in(const4),  .add_out(add_out4));
ADDITION_TYPE0  addition5( .status_in(status5),  .const_in(const5),  .add_out(add_out5));
ADDITION_TYPE0  addition6( .status_in(status6),  .const_in(const6),  .add_out(add_out6));
ADDITION_TYPE0  addition7( .status_in(status7),  .const_in(const7),  .add_out(add_out7));
ADDITION_TYPE0  addition8( .status_in(status8),  .const_in(const8),  .add_out(add_out8));
ADDITION_TYPE0  addition9( .status_in(status9),  .const_in(const9),  .add_out(add_out9));
ADDITION_TYPE0 addition10(.status_in(status10), .const_in(const10), .add_out(add_out10));
ADDITION_TYPE0 addition11(.status_in(status11), .const_in(const11), .add_out(add_out11));
ADDITION_TYPE0 addition12(.status_in(status12), .const_in(const12), .add_out(add_out12));
ADDITION_TYPE0 addition13(.status_in(status13), .const_in(const13), .add_out(add_out13));
ADDITION_TYPE0 addition14(.status_in(status14), .const_in(const14), .add_out(add_out14));
ADDITION_TYPE0 addition15(.status_in(status15), .const_in(const15), .add_out(add_out15));
//Substitution Layer : S
SUBSTITUTION  substitution0( .add_in0(add_out0), .add_in1(add_out4),  .add_in2(add_out8),  .add_in3(add_out12), .sub_out0(sub_out0), .sub_out1(sub_out4),  .sub_out2(sub_out8), .sub_out3(sub_out12));
SUBSTITUTION  substitution1( .add_in0(add_out1), .add_in1(add_out5),  .add_in2(add_out9),  .add_in3(add_out13), .sub_out0(sub_out1), .sub_out1(sub_out5),  .sub_out2(sub_out9), .sub_out3(sub_out13));
SUBSTITUTION  substitution2( .add_in0(add_out2), .add_in1(add_out6), .add_in2(add_out10),  .add_in3(add_out14), .sub_out0(sub_out2), .sub_out1(sub_out6), .sub_out2(sub_out10), .sub_out3(sub_out14));
SUBSTITUTION  substitution3( .add_in0(add_out3), .add_in1(add_out7), .add_in2(add_out11),  .add_in3(add_out15), .sub_out0(sub_out3), .sub_out1(sub_out7), .sub_out2(sub_out11), .sub_out3(sub_out15));
//Diffusion Layer : L
DIFFUSION diffusion0(.sub_in0(sub_out0), .sub_in1(sub_out5), .sub_in2(sub_out10), .sub_in3(sub_out15), .diff_out0(diff_out0), .diff_out1(diff_out5), .diff_out2(diff_out10), .diff_out3(diff_out15));
DIFFUSION diffusion1(.sub_in0(sub_out1), .sub_in1(sub_out6), .sub_in2(sub_out11), .sub_in3(sub_out12), .diff_out0(diff_out1), .diff_out1(diff_out6), .diff_out2(diff_out11), .diff_out3(diff_out12));
DIFFUSION diffusion2(.sub_in0(sub_out2), .sub_in1(sub_out7),  .sub_in2(sub_out8), .sub_in3(sub_out13), .diff_out0(diff_out2), .diff_out1(diff_out7),  .diff_out2(diff_out8), .diff_out3(diff_out13));
DIFFUSION diffusion3(.sub_in0(sub_out3), .sub_in1(sub_out4),  .sub_in2(sub_out9), .sub_in3(sub_out14), .diff_out0(diff_out3), .diff_out1(diff_out4),  .diff_out2(diff_out9), .diff_out3(diff_out14));
//Truncation : T 
TRUNCATION truncation0( .diff_in(diff_out0), .trunc_out(trunc_out0));
TRUNCATION truncation1( .diff_in(diff_out1), .trunc_out(trunc_out1));
TRUNCATION truncation2( .diff_in(diff_out2), .trunc_out(trunc_out2));
TRUNCATION truncation3( .diff_in(diff_out3), .trunc_out(trunc_out3));
TRUNCATION truncation4( .diff_in(diff_out8), .trunc_out(trunc_out4));
TRUNCATION truncation5( .diff_in(diff_out9), .trunc_out(trunc_out5));
TRUNCATION truncation6(.diff_in(diff_out10), .trunc_out(trunc_out6));
TRUNCATION truncation7(.diff_in(diff_out11), .trunc_out(trunc_out7));
//Update Hash Value
UPDATE update0(.hash_in(hash0), .trunc_in(trunc_out0), .update_out(digest0));
UPDATE update1(.hash_in(hash1), .trunc_in(trunc_out1), .update_out(digest1));
UPDATE update2(.hash_in(hash2), .trunc_in(trunc_out2), .update_out(digest2));
UPDATE update3(.hash_in(hash3), .trunc_in(trunc_out3), .update_out(digest3));
UPDATE update4(.hash_in(hash4), .trunc_in(trunc_out4), .update_out(digest4));
UPDATE update5(.hash_in(hash5), .trunc_in(trunc_out5), .update_out(digest5));
UPDATE update6(.hash_in(hash6), .trunc_in(trunc_out6), .update_out(digest6));
UPDATE update7(.hash_in(hash7), .trunc_in(trunc_out7), .update_out(digest7));

reg finish_r;
assign busy = ((EN && ~finish) || (EOM_r && (~finish_r) && (~finish)))? 1'b1 : 1'b0;
assign finAll = finish | finish_r;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		start <= 1'b1;
	end
	else begin
		if (busy) begin
			start <= 1'b0;
		end
		else if (finish) begin
			start <= 1'b1;
		end
		else begin
			start <= start;
		end
	end
end

assign finish = ((EN && ~EOM_r && (count == 3'd2)) || (EOM_r && (count == 3'd7 /*3'd5*/)))? 1'b1: 1'b0; /* do P for 3 times or Pf for 6 times. Eric: 2nd round 6->8*/

always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    finish_r <= 0;
  else if (init_r || load)
    finish_r <= 0;
  else if (finish && EOM_r)
    finish_r <= 1;
  else
    finish_r <= finish_r;
  
end

assign const0  = (EOM_r)? 32'hCAF9639C : 32'hFF00F0F0; 
assign const1  = (EOM_r)? 32'h0FF0F9C0 : 32'hCCCCAAAA; 
assign const2  = (EOM_r)? 32'h639C0FF0 : 32'hF0F0CCCC; 
assign const3  = (EOM_r)? 32'hCAF9F9C0 : 32'hFF00AAAA;
assign const4  = (EOM_r)? 32'h639C0FF0 : 32'hF0F0CCCC; 
assign const5  = (EOM_r)? 32'hF9C0CAF9 : 32'hAAAAFF00;
assign const6  = (EOM_r)? 32'h0FF0CAF9 : 32'hCCCCFF00;
assign const7  = (EOM_r)? 32'hF9C0639C : 32'hAAAAF0F0;
assign const8  = (EOM_r)? 32'h0FF0F9C0 : 32'hCCCCAAAA;
assign const9  = (EOM_r)? 32'hCAF9639C : 32'hFF00F0F0;
assign const10 = (EOM_r)? 32'hCAF9F9C0 : 32'hFF00AAAA;
assign const11 = (EOM_r)? 32'h639C0FF0 : 32'hF0F0CCCC;
assign const12 = (EOM_r)? 32'hF9C0CAF9 : 32'hAAAAFF00;
assign const13 = (EOM_r)? 32'h639C0FF0 : 32'hF0F0CCCC;
assign const14 = (EOM_r)? 32'hF9C0639C : 32'hAAAAF0F0;
assign const15 = (EOM_r)? 32'h0FF0CAF9 : 32'hCCCCFF00;

//main 
//hash : # need finish signal 
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash0 <= 32'h76657273;
	end
	else begin
		if (init_r) begin
			hash0 <= 32'h76657273;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash0 <= digest0;
		end
		else begin
			hash0 <= hash0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash1 <= 32'h69746569;
	end
	else begin
		if (init_r) begin
			hash1 <= 32'h69746569;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash1 <= digest1;
		end
		else begin
			hash1 <= hash1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash2 <= 32'h74204c65;
	end
	else begin
		if (init_r) begin
			hash2 <= 32'h74204c65;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash2 <= digest2;
		end
		else begin
			hash2 <= hash2;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash3 <= 32'h7576656e;
	end
	else begin
		if (init_r) begin
			hash3 <= 32'h7576656e;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash3 <= digest3;
		end
		else begin
			hash3 <= hash3;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash4 <= 32'h2c204465;
	end
	else begin
		if (init_r) begin
			hash4 <= 32'h2c204465;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash4 <= digest4;
		end
		else begin
			hash4 <= hash4;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash5 <= 32'h70617274;
	end
	else begin
		if (init_r) begin
			hash5 <= 32'h70617274;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash5 <= digest5;
		end
		else begin
			hash5 <= hash5;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash6 <= 32'h656d656e;
	end
	else begin
		if (init_r) begin
			hash6 <= 32'h656d656e;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash6 <= digest6;
		end
		else begin
			hash6 <= hash6;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hash7 <= 32'h7420456c;
	end
	else begin
		if (init_r) begin
			hash7 <= 32'h7420456c;
		end
		else if ((load && finish) || (finProcess && finish)) begin
			hash7 <= digest7;
		end
		else begin
			hash7 <= hash7;
		end
	end
end

//status : # need start signal 
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status0 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status0 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status0 <= concate0;
		else if (EN) begin
			if (start) begin
				status0 <= concate0;
			end
			else begin
				status0 <= diff_out0;
			end
		end
		else begin
			status0 <= status0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status1 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status1 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status1 <= concate1;
		else if (EN) begin
			if (start) begin
				status1 <= concate1;
			end
			else begin
				status1 <= diff_out1;
			end
		end
		else begin
			status1 <= status1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status2 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status2 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status2 <= concate2;
		else if (EN) begin
			if (start) begin
				status2 <= concate2;
			end
			else begin
				status2 <= diff_out2;
			end
		end
		else begin
			status2 <= status2;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status3 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status3 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status3 <= concate3;
		else if (EN) begin
			if (start) begin
				status3 <= concate3;
			end
			else begin
				status3 <= diff_out3;
			end
		end
		else begin
			status3 <= status3;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status4 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status4 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status4 <= concate4;
		else if (EN) begin
			if (start) begin
				status4 <= concate4;
			end
			else begin
				status4 <= diff_out4;
			end
		end
		else begin
			status4 <= status4;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status5 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status5 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status5 <= concate5;
		else if (EN) begin
			if (start) begin
				status5 <= concate5;
			end
			else begin
				status5 <= diff_out5;
			end
		end
		else begin
			status5 <= status5;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status6 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status6 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status6 <= concate6;
		else if (EN) begin
			if (start) begin
				status6 <= concate6;
			end
			else begin
				status6 <= diff_out6;
			end
		end
		else begin
			status6 <= status6;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status7 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status7 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status7 <= concate7;
		else if (EN) begin
			if (start) begin
				status7 <= concate7;
			end
			else begin
				status7 <= diff_out7;
			end
		end
		else begin
			status7 <= status7;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status8 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status8 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status8 <= concate8;
		else if (EN) begin
			if (start) begin
				status8 <= concate8;
			end
			else begin
				status8 <= diff_out8;
			end
		end
		else begin
			status8 <= status8;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status9 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status9 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status9 <= concate9;
		else if (EN) begin
			if (start) begin
				status9 <= concate9;
			end
			else begin
				status9 <= diff_out9;
			end
		end
		else begin
			status9 <= status9;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status10 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status10 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status10 <= concate10;
		else if (EN) begin
			if (start) begin
				status10 <= concate10;
			end
			else begin
				status10 <= diff_out10;
			end
		end
		else begin
			status10 <= status10;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status11 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status11 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status11 <= concate11;
		else if (EN) begin
			if (start) begin
				status11 <= concate11;
			end
			else begin
				status11 <= diff_out11;
			end
		end
		else begin
			status11 <= status11;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status12 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status12 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status12 <= concate12;
		else if (EN) begin
			if (start) begin
				status12 <= concate12;
			end
			else begin
				status12 <= diff_out12;
			end
		end
		else begin
			status12 <= status12;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status13 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status13 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status13 <= concate13;
		else if (EN) begin
			if (start) begin
				status13 <= concate13;
			end
			else begin
				status13 <= diff_out13;
			end
		end
		else begin
			status13 <= status13;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status14 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status14 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status14 <= concate14;
		else if (EN) begin
			if (start) begin
				status14 <= concate14;
			end
			else begin
				status14 <= diff_out14;
			end
		end
		else begin
			status14 <= status14;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		status15 <= 32'h0;
	end
	else begin
		if (init_r) begin
			status15 <= 32'h0;
		end
		else if (EOM_r && ~finProcess)
			status15 <= concate15;
		else if (EN) begin
			if (start) begin
				status15 <= concate15;
			end
			else begin
				status15 <= diff_out15;
			end
		end
		else begin
			status15 <= status15;
		end
	end
end

//{{{/* count : # need finish signal */
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		count <= 3'd0;
	end
	else begin
		if (EOM_r ^ finProcess)
			count <= 3'd0;	
		else if (EN || (EOM_r && finProcess && ~finish_r)) begin
			if (finish) begin
				count <= 3'd0;
			end
			else if (~start) begin
				count <= count + 1'd1;
			end
			else begin
				count <= count;
			end
		end
		else begin
			count <= count;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n) 
		finProcess <= 0;
	else if (load || init_r || finish_r)
		finProcess <= 0;
	else if (EOM_r)
		finProcess <= 1;	
	else
		finProcess <= finProcess;
end		

endmodule


