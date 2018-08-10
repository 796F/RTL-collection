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
module ECHO_CORE(
                clk, 
                rst_n,
                init, 
                start, 
                busy, 
                Ld_cnt, 
                Ld_msg,
                hash, 
                idata);
input          clk;
input          rst_n;
input          init;
input          start;
input  [ 15:0] idata;
input          Ld_cnt;
input          Ld_msg;
output [255:0] hash;
output         busy;

parameter IV = 128'h00010000_00000000_00000000_00000000;

reg [127:0] hash0;
reg [127:0] hash1;
reg [127:0] hash2;
reg [127:0] hash3;  
reg [127:0] msg0, msg4, msg8 ;
reg [127:0] msg1, msg5, msg9 ;
reg [127:0] msg2, msg6, msg10;
reg [127:0] msg3, msg7, msg11;
reg [127:0] state0 , state4 , state8 , state12;  
reg [127:0] state1 , state5 , state9 , state13;  
reg [127:0] state2 , state6 , state10, state14;  
reg [127:0] state3 , state7 , state11, state15;  
reg [63:0] msg_len;
reg [63:0] tot_len;
reg [4:0] round;
reg [3:0] op_cnt;
reg EN;
reg init_r;
wire [127:0] sbi0, sbi1, sbi2, sbi3;
wire [127:0] sbo0, sbo1, sbo2, sbo3;

//aes_shiftrows
wire [127:0] sr0, sr1, sr2, sr3;
//wire Big_shiftrows   
reg [127:0] big_sr0, big_sr1, big_sr2, big_sr3;
//mixcolumns 
wire [127:0] mxi0, mxi1, mxi2, mxi3;
wire [127:0] mxo0, mxo1, mxo2, mxo3;
//addkey 
wire [63:0] key0, key1, key2, key3;
wire [127:0] k1_0, k1_1, k1_2, k1_3;
wire [127:0] addkey0, addkey1, addkey2, addkey3;
//chain value
wire [127:0] cv0, cv1, cv2, cv3;
//BIG_final
wire [127:0] big_final0, big_final1, big_final2, big_final3;
reg loader;
wire updateMsgLen;
//busy
assign busy = (start | EN)? 1:0;

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) EN <= 0;
   else if (start) EN <= 1;
   else if (round == 5'h8) EN <= 0;
   else EN <= EN;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) op_cnt <= 0;
   else if (EN) begin
      if (op_cnt == 4'hb) op_cnt <= 0;
      else op_cnt <= op_cnt + 1;
   end
   else op_cnt <= 0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) round <= 0;
   else if (round == 5'h8) round <= 0;
   else if (op_cnt == 4'hb) round <= round + 1;
   else round <= round;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) init_r <= 0;
   else init_r <= init;
end

assign sbi0 = ((round == 5'h0) & (~op_cnt[2]))? hash0 : state0; 
assign sbi1 = ((round == 5'h0) & (~op_cnt[2]))? msg0 : state4; 
assign sbi2 = ((round == 5'h0) & (~op_cnt[2]))? msg4 : state8; 
assign sbi3 = ((round == 5'h0) & (~op_cnt[2]))? msg8 : state12; 

//instance AES_SUBBYTES
AES_SUBBYTES aes_subbyte0(.x(sbi0), .y(sbo0));
AES_SUBBYTES aes_subbyte1(.x(sbi1), .y(sbo1));
AES_SUBBYTES aes_subbyte2(.x(sbi2), .y(sbo2));
AES_SUBBYTES aes_subbyte3(.x(sbi3), .y(sbo3));

//assignment AES_shiftrows
assign sr0 = {sbo0[127:120], sbo0[ 87: 80], sbo0[ 47: 40], sbo0[  7:  0],
              sbo0[ 95: 88], sbo0[ 55: 48], sbo0[ 15:  8], sbo0[103: 96],
              sbo0[ 63: 56], sbo0[ 23: 16], sbo0[111:104], sbo0[ 71: 64],
              sbo0[ 31: 24], sbo0[119:112], sbo0[ 79: 72], sbo0[ 39: 32]};
assign sr1 = {sbo1[127:120], sbo1[ 87: 80], sbo1[ 47: 40], sbo1[  7:  0],
              sbo1[ 95: 88], sbo1[ 55: 48], sbo1[ 15:  8], sbo1[103: 96],
              sbo1[ 63: 56], sbo1[ 23: 16], sbo1[111:104], sbo1[ 71: 64],
              sbo1[ 31: 24], sbo1[119:112], sbo1[ 79: 72], sbo1[ 39: 32]};
assign sr2 = {sbo2[127:120], sbo2[ 87: 80], sbo2[ 47: 40], sbo2[  7:  0],
              sbo2[ 95: 88], sbo2[ 55: 48], sbo2[ 15:  8], sbo2[103: 96],
              sbo2[ 63: 56], sbo2[ 23: 16], sbo2[111:104], sbo2[ 71: 64],
              sbo2[ 31: 24], sbo2[119:112], sbo2[ 79: 72], sbo2[ 39: 32]};
assign sr3 = {sbo3[127:120], sbo3[ 87: 80], sbo3[ 47: 40], sbo3[  7:  0],
              sbo3[ 95: 88], sbo3[ 55: 48], sbo3[ 15:  8], sbo3[103: 96],
              sbo3[ 63: 56], sbo3[ 23: 16], sbo3[111:104], sbo3[ 71: 64],
              sbo3[ 31: 24], sbo3[119:112], sbo3[ 79: 72], sbo3[ 39: 32]};

//assignment AES key_gen & addkey
assign key0 = msg_len + {55'h0,round,2'b00,op_cnt[1:0]};
assign key1 = msg_len + {55'h0,round,2'b01,op_cnt[1:0]};
assign key2 = msg_len + {55'h0,round,2'b10,op_cnt[1:0]};
assign key3 = msg_len + {55'h0,round,2'b11,op_cnt[1:0]};
assign k1_0 = {key0[7:0], key0[15:8], key0[23:16], key0[31:24], key0[39:32], key0[47:40], key0[55:48], key0[63:56], 64'h0};
assign k1_1 = {key1[7:0], key1[15:8], key1[23:16], key1[31:24], key1[39:32], key1[47:40], key1[55:48], key1[63:56], 64'h0};
assign k1_2 = {key2[7:0], key2[15:8], key2[23:16], key2[31:24], key2[39:32], key2[47:40], key2[55:48], key2[63:56], 64'h0};
assign k1_3 = {key3[7:0], key3[15:8], key3[23:16], key3[31:24], key3[39:32], key3[47:40], key3[55:48], key3[63:56], 64'h0};
assign addkey0 = (op_cnt[2])? mxo0 : mxo0 ^ k1_0;
assign addkey1 = (op_cnt[2])? mxo1 : mxo1 ^ k1_1;
assign addkey2 = (op_cnt[2])? mxo2 : mxo2 ^ k1_2;
assign addkey3 = (op_cnt[2])? mxo3 : mxo3 ^ k1_3;

//assignment big_shiftrows
always @(addkey0 or addkey1 or addkey2 or addkey3 or op_cnt) begin
   case(op_cnt)
      4'h5  :  begin
         big_sr0 = addkey1;
         big_sr1 = addkey2;
         big_sr2 = addkey3;
         big_sr3 = addkey0;
      end
      4'h6  :  begin
         big_sr0 = addkey2;
         big_sr1 = addkey3;
         big_sr2 = addkey0;
         big_sr3 = addkey1;
      end
      4'h7  :  begin
         big_sr0 = addkey3;
         big_sr1 = addkey0;
         big_sr2 = addkey1;
         big_sr3 = addkey2;
      end
      default  :  begin
         big_sr0 = addkey0;
         big_sr1 = addkey1;
         big_sr2 = addkey2;
         big_sr3 = addkey3;
      end
   endcase
end

//assignment mxi 
assign mxi0 = (~op_cnt[3])? sr0 : 
   {state0[127:120],state1[127:120],state2[127:120],state3[127:120],
    state0[119:112],state1[119:112],state2[119:112],state3[119:112],
    state0[111:104],state1[111:104],state2[111:104],state3[111:104],
    state0[103: 96],state1[103: 96],state2[103: 96],state3[103: 96]};
assign mxi1 = (~op_cnt[3])? sr1 : 
   {state0[ 95: 88],state1[ 95: 88],state2[ 95: 88],state3[ 95: 88],
    state0[ 87: 80],state1[ 87: 80],state2[ 87: 80],state3[ 87: 80],
    state0[ 79: 72],state1[ 79: 72],state2[ 79: 72],state3[ 79: 72],
    state0[ 71: 64],state1[ 71: 64],state2[ 71: 64],state3[ 71: 64]};
assign mxi2 = (~op_cnt[3])? sr2 : 
   {state0[ 63: 56],state1[ 63: 56],state2[ 63: 56],state3[ 63: 56],
    state0[ 55: 48],state1[ 55: 48],state2[ 55: 48],state3[ 55: 48],
    state0[ 47: 40],state1[ 47: 40],state2[ 47: 40],state3[ 47: 40],
    state0[ 39: 32],state1[ 39: 32],state2[ 39: 32],state3[ 39: 32]};
assign mxi3 = (~op_cnt[3])? sr3 : 
   {state0[ 31: 24],state1[ 31: 24],state2[ 31: 24],state3[ 31: 24],
    state0[ 23: 16],state1[ 23: 16],state2[ 23: 16],state3[ 23: 16],
    state0[ 15:  8],state1[ 15:  8],state2[ 15:  8],state3[ 15:  8],
    state0[  7:  0],state1[  7:  0],state2[  7:  0],state3[  7:  0]};

//instance MixColumns
AES_MIXCOLUMNS aes_mixcolumns0(.x(mxi0), .y(mxo0));
AES_MIXCOLUMNS aes_mixcolumns1(.x(mxi1), .y(mxo1));
AES_MIXCOLUMNS aes_mixcolumns2(.x(mxi2), .y(mxo2));
AES_MIXCOLUMNS aes_mixcolumns3(.x(mxi3), .y(mxo3));

//assignment chain value
assign cv0 = (~op_cnt[3])? big_sr0 :
   {mxo0[127:120],mxo0[ 95: 88],mxo0[ 63: 56],mxo0[ 31: 24],
    mxo1[127:120],mxo1[ 95: 88],mxo1[ 63: 56],mxo1[ 31: 24], 
    mxo2[127:120],mxo2[ 95: 88],mxo2[ 63: 56],mxo2[ 31: 24],
    mxo3[127:120],mxo3[ 95: 88],mxo3[ 63: 56],mxo3[ 31: 24]};

assign cv1 = (~op_cnt[3])? big_sr1 :
   {mxo0[119:112],mxo0[ 87: 80],mxo0[ 55: 48],mxo0[ 23: 16],
    mxo1[119:112],mxo1[ 87: 80],mxo1[ 55: 48],mxo1[ 23: 16],
    mxo2[119:112],mxo2[ 87: 80],mxo2[ 55: 48],mxo2[ 23: 16],
    mxo3[119:112],mxo3[ 87: 80],mxo3[ 55: 48],mxo3[ 23: 16]};

assign cv2 = (~op_cnt[3])? big_sr2 :
   {mxo0[111:104],mxo0[ 79: 72],mxo0[ 47: 40],mxo0[ 15:  8],
    mxo1[111:104],mxo1[ 79: 72],mxo1[ 47: 40],mxo1[ 15:  8],
    mxo2[111:104],mxo2[ 79: 72],mxo2[ 47: 40],mxo2[ 15:  8],
    mxo3[111:104],mxo3[ 79: 72],mxo3[ 47: 40],mxo3[ 15:  8]};

assign cv3 = (~op_cnt[3])? big_sr3 :
   {mxo0[103: 96],mxo0[ 71: 64],mxo0[ 39: 32],mxo0[  7:  0],
    mxo1[103: 96],mxo1[ 71: 64],mxo1[ 39: 32],mxo1[  7:  0],
    mxo2[103: 96],mxo2[ 71: 64],mxo2[ 39: 32],mxo2[  7:  0],
    mxo3[103: 96],mxo3[ 71: 64],mxo3[ 39: 32],mxo3[  7:  0]};

//msg
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg0 <= 0;
   else if (Ld_msg) msg0 <= {msg0[111:0],msg1[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg0 <= msg1; 
   else msg0 <= msg0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg1 <= 0;
   else if (Ld_msg) msg1 <= {msg1[111:0],msg2[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg1 <= msg2; 
   else msg1 <= msg1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg2 <= 0;
   else if (Ld_msg) msg2 <= {msg2[111:0],msg3[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg2 <= msg3; 
   else msg2 <= msg2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg3 <= 0;
   else if (Ld_msg) msg3 <= {msg3[111:0],msg4[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg3 <= msg0; 
   else msg3 <= msg3;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg4 <= 0;
   else if (Ld_msg) msg4 <= {msg4[111:0],msg5[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg4 <= msg5; 
   else msg4 <= msg4;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg5 <= 0;
   else if (Ld_msg) msg5 <= {msg5[111:0],msg6[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg5 <= msg6; 
   else msg5 <= msg5;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg6 <= 0;
   else if (Ld_msg) msg6 <= {msg6[111:0],msg7[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg6 <= msg7; 
   else msg6 <= msg6;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg7 <= 0;
   else if (Ld_msg) msg7 <= {msg7[111:0],msg8[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg7 <= msg4; 
   else msg7 <= msg7;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg8 <= 0;
   else if (Ld_msg) msg8 <= {msg8[111:0],msg9[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg8 <= msg9; 
   else msg8 <= msg8;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg9 <= 0;
   else if (Ld_msg) msg9 <= {msg9[111:0],msg10[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg9 <= msg10; 
   else msg9 <= msg9;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg10 <= 0;
   else if (Ld_msg) msg10 <= {msg10[111:0],msg11[127:112]};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg10 <= msg11; 
   else msg10 <= msg10;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg11 <= 0;
   else if (Ld_msg) msg11 <= {msg11[111:0],idata};
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) msg11 <= msg8; 
   else msg11 <= msg11;
end

//hash value
assign hash = {hash0,hash1};

assign big_final0 = state0 ^ state4 ^ state8  ^ state12 ^ hash0 ^ msg0 ^ msg4 ^ msg8 ; 
assign big_final1 = state1 ^ state5 ^ state9  ^ state13 ^ hash1 ^ msg1 ^ msg5 ^ msg9 ; 
assign big_final2 = state2 ^ state6 ^ state10 ^ state14 ^ hash2 ^ msg2 ^ msg6 ^ msg10; 
assign big_final3 = state3 ^ state7 ^ state11 ^ state15 ^ hash3 ^ msg3 ^ msg7 ^ msg11; 

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) hash0 <= 0;
   else if (init_r) hash0 <= IV;
   else if (round == 5'h8) hash0 <= big_final0;
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) hash0 <= hash1; 
   else hash0 <= hash0;
end
   
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) hash1 <= 0;
   else if (init_r) hash1 <= IV;
   else if (round == 5'h8) hash1 <= big_final1;
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) hash1 <= hash2; 
   else hash1 <= hash1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) hash2 <= 0;
   else if (init_r) hash2 <= IV;
   else if (round == 5'h8) hash2 <= big_final2;
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) hash2 <= hash3; 
   else hash2 <= hash2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) hash3 <= 0;
   else if (init_r) hash3 <= IV;
   else if (round == 5'h8) hash3 <= big_final3;
   else if ((round == 5'h0) && (op_cnt[3:2] == 2'h0) && EN) hash3 <= hash0; 
   else hash3 <= hash3;
end

always @(posedge clk or negedge rst_n)
begin
   if (~rst_n)
      loader <= 0;
   else if (init)
      loader <= 0;
   else if (Ld_msg)
      loader <= 1;
   else if (start | busy)
      loader <= 0;
   else
      loader <= loader;
end

assign updateMsgLen = Ld_msg & (~loader);

//msg_len
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) msg_len <= 0;
   else if (updateMsgLen && (tot_len==msg_len))
      msg_len <= 64'h0;
   else if (updateMsgLen && ((tot_len - msg_len) < 64'h600)) 
      msg_len <= tot_len;
   else if (updateMsgLen)
      msg_len <= msg_len + 64'h600;
   else msg_len <= msg_len;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) tot_len <= 0;
   else if (Ld_cnt) begin
      tot_len <= (tot_len << 16) | idata;
   end
   else tot_len <= tot_len;
end

//state
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state0 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state0 <= state4;
      else state0 <= state1;
   end
   else state0 <= state0;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state1 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state1 <= state5;
      else state1 <= state2;
   end
   else state1 <= state1;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state2 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state2 <= state6;
      else state2 <= state3;
   end
   else state2 <= state2;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state3 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state3 <= state7;
      else state3 <= cv0;
   end
   else state3 <= state3;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state4 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state4 <= state8;
      else state4 <= state5;
   end
   else state4 <= state4;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state5 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state5 <= state9;
      else state5 <= state6;
   end
   else state5 <= state5;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state6 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state6 <= state10;
      else state6 <= state7;
   end
   else state6 <= state6;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state7 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state7 <= state11;
      else state7 <= cv1;
   end
   else state7 <= state7;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state8 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state8 <= state12;
      else state8 <= state9;
   end
   else state8 <= state8;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state9 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state9 <= state13;
      else state9 <= state10;
   end
   else state9 <= state9;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state10 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state10 <= state14;
      else state10 <= state11;
   end
   else state10 <= state10;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state11 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state11 <= state15;
      else state11 <= cv2;
   end
   else state11 <= state11;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state12 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state12 <= cv0;
      else state12 <= state13;
   end
   else state12 <= state12;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state13 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state13 <= cv1;
      else state13 <= state14;
   end
   else state13 <= state13;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state14 <= 0;
   else if (EN) begin
      if (op_cnt[3]) state14 <= cv2;
      else state14 <= state15;
   end
   else state14 <= state14;
end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) state15 <= 0;
   else if (EN) state15 <= cv3;
   else state15 <= state15;
end

endmodule
