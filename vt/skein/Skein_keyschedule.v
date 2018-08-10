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
module SKEIN_KEY_SCHEDULE(k0, 
                          k1, 
                          k2, 
                          k3, 
                          tweak, 
                          s, 
                          sk0, 
                          sk1, 
                          sk2, 
                          sk3);
input  [ 63:0] k0;
input  [ 63:0] k1;
input  [ 63:0] k2;
input  [ 63:0] k3;
input  [127:0] tweak;
input  [  4:0] s;
output [ 63:0] sk0;
output [ 63:0] sk1;
output [ 63:0] sk2;
output [ 63:0] sk3;

assign sk0 = k0;
assign sk1 = k1 + tweak[127:64];
assign sk2 = k2 + tweak[63:0];
assign sk3 = k3 + s;

endmodule



