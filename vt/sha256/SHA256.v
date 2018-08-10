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
`timescale 1ns/1ns  

module SHA256(
             clk,
             rst_n,
             init,
             load,
             fetch,
             idata, 
             ack,
             odata
//eric             odata,
//eric             led,
//eric             debug
             );   

input         clk;
input         rst_n;
input         init;
input         load;
input         fetch;
input  [15:0] idata; 
output        ack;
output [15:0] odata;
//output [ 7:0] led;
//output [15:0] debug;

wire   [31:0] Hash0;
wire   [31:0] Hash1;
wire   [31:0] Hash2;
wire   [31:0] Hash3;
wire   [31:0] Hash4;
wire   [31:0] Hash5;
wire   [31:0] Hash6;
wire   [31:0] Hash7;
wire          busy;
wire          EN;
wire   [31:0] idata32;                     
wire          busy_hash;

SHA256_INTERFACE_rev1 SHA256_INTERFACE(
                                      .clk       (clk       ), 
                                      .rst_n     (rst_n     ),
                                      .load      (load      ), 
                                      .fetch     (fetch     ),
                                      .odata     (odata     ),
                                      .ack       (ack       ), 
                                      .busy      (busy      ),
                                      .EN        (EN        ),
                                      .Hash0     (Hash0     ), 
                                      .Hash1     (Hash1     ), 
                                      .Hash2     (Hash2     ), 
                                      .Hash3     (Hash3     ),
                                      .Hash4     (Hash4     ), 
                                      .Hash5     (Hash5     ), 
                                      .Hash6     (Hash6     ), 
                                      .Hash7     (Hash7     ),
                                      .idata     (idata     ), 
                                      .idata32   (idata32   ), 
                                      .busy_valid(busy_hash)
                                      );

SHA256_CORE_rev1 SHA256_CORE(
                            .clk  (clk    ), 
                            .rst_n(rst_n  ),
                            .busy (busy   ), 
                            .EN   (EN     ),
                            .init (init   ), 
                            .Hash0(Hash0  ), 
                            .Hash1(Hash1  ), 
                            .Hash2(Hash2  ), 
                            .Hash3(Hash3  ),
                            .Hash4(Hash4  ), 
                            .Hash5(Hash5  ), 
                            .Hash6(Hash6  ), 
                            .Hash7(Hash7  ),
                            .idata(idata32)
                            );

/*
//------------------------------------------------------------------------------------------------
//       For Testing Pins on Board Debug begin
//------------------------------------------------------------------------------------------------
assign led = 8'hFF;
assign debug[0] = busy_hash; 
assign debug[1] = 0;//clk;
assign debug[2] = 0;//ack;
assign debug[3] = 0;//ena;
assign debug[4] = 0;//fin;
assign debug[5] = 0;//busy;
assign debug[15:6] = 0;//unused
//------------------------------------------------------------------------------------------------
//       For Testing Pins on Board Debug end
//------------------------------------------------------------------------------------------------
*/
endmodule
