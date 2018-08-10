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

`timescale 1ns/10ps
`define		WORDSIZE    32
`define		IOSIZE    16
`define		SETUPTIME   3

module tb_sha();

wire   [`IOSIZE-1 : 0]   odata;
wire                       ack;
wire                       err;

// internal nodes
reg                         rst;
reg                         getconfig;
reg                         init;
reg                         load;
reg                         fetch;
reg      [`IOSIZE-1 : 0]  idata;
reg                         clk_unit;
reg                         clk_reg;
reg      [`WORDSIZE-1 : 0]  clk_count;
reg      [`WORDSIZE-1 : 0]  cycle_count;
reg      [`WORDSIZE-1 : 0]  clk_period;
reg      [`WORDSIZE-1 : 0]  command;
reg      [`WORDSIZE-1 : 0]  op1;
reg      [`WORDSIZE-1 : 0]  op2;
reg      [`WORDSIZE-1 : 0]  op3;

integer                     command_file;
integer                     temp;

reg      [`WORDSIZE-1 : 0]  i;
parameter                   RESET     = 1;
parameter                   CLOCK     = 2;
parameter                   INIT      = 3;
parameter                   GETCONFIG = 4;
parameter                   WAITFOR   = 5;
parameter                   LOAD      = 6;
parameter                   FETCH     = 7;


CubeHash_TOP U_cubehash_top(
	.clk(clk),
	.rst_n(!rst),
	.init(init),
	.load(load),
	.fetch(fetch),
	.idata(idata),
	.ack(ack),
	.odata(odata)
	);

//////////////////////////////////////////////////////////////
// clock generation

assign clk = clk_reg;
always begin
    #0.25 clk_unit <= ~clk_unit;
end

// counter for clk for division
always @(posedge clk_unit) begin
    if(clk_count == 2*clk_period - 1) begin
        clk_count <= 0;
    end
    else begin
        clk_count <= clk_count + 1;
    end
end

// clk_reg with frequency = 1/clk_period (GHz)
always @(clk_count) begin
    if(clk_count < clk_period) begin
        clk_reg <= 0;
    end
    else begin
        clk_reg <= 1;
    end
end

// cycle count
always @(posedge clk_reg) begin
    cycle_count <= cycle_count + 1;
end
//////////////////////////////////////////////////////////////
// main process
integer cur_time;
integer start_rep;
integer done_rep;
parameter end_time = 2040;



initial begin
    cycle_count <= 0;
	start_rep = 0;
	done_rep = 0;

    command_file = $fopen("commands.dat", "r");

    clk_reg <= 0;
    clk_count <= 0;
    clk_unit <= 0;
    cycle_count <= 0;
    i <= 0;
    clk_period <= 100;
    init <= 0;
    rst <= 0;
    getconfig <= 0;
    fetch <= 0;
    load <= 0;
    idata <= 0;
end

always begin
    cur_time = $time;
    temp = $fscanf(command_file,"%8x\n", command); // read command
    if(command == 32'hffffffff) begin
        $display("Simulation OK!\n");
        $display("Total cycle count: %d", cycle_count);
	$display("Time %d is %d",$time, cur_time);
	if(end_time == cur_time)
	begin
		$display("comparison worked");
	end
	if(start_rep == 0)
	begin
		$display("start toggle did not trigger");
	end

	if(done_rep == 0)
	begin
		$display("stop toggle did not trigger");
	end

        $fclose(command_file);
	$finish;
    end
    case (command)
        RESET: begin // 'RESET 0Xa' reset for a cycles
            temp = $fscanf(command_file, "%8x\n", op1); // read number of cycles

            //wait(clk_reg);
            $display("%d	RESET   0x%x\n", cycle_count, op1);
            #`SETUPTIME rst = 1;
            i = 0;
            wait(clk_reg);
            for(i=0; i<op1; i=i+1) begin
                wait(!clk_reg);
                wait(clk_reg);
            end
            #`SETUPTIME rst = 0;
        end
        CLOCK: begin // 'CLOCK 0Xa' set clk to 1/a (GHz)
            temp = $fscanf(command_file, "%8x\n", op1); // read period
            clk_period = op1;
            $display("%d	CLOCK   0x%x\n", cycle_count, op1);
        end
        INIT: begin // 'INIT' set init to '1' for 1 cycle
            //wait(clk_reg);
            $display("%d	INIT\n", cycle_count);
            init = 1;
            wait(!clk_reg);
            wait(clk_reg);
            #`SETUPTIME init = 0;
        end
        GETCONFIG: begin // 'GETCONFIG' set getconfig to '1' for 1 cycle
            
            temp = $fscanf(command_file, "%8x\n", op1);
            temp = $fscanf(command_file, "%8x\n", op2);
            $display("%d	GETCONFIG   0x%x   0x%x\n", cycle_count, op1, op2);
            getconfig = 1;
            wait(!clk_reg);
            wait(clk_reg);		
            i = 0;
            if(!ack) begin
                while(i<op2 && !ack) begin
                    i = i+1;
                    wait(!clk_reg);
                    wait(clk_reg);
                end
                if(i == op2) begin // exit because of time out
                    $display("ERROR: Timeout when excuting 'fetch'\n");
                    $fclose(command_file);
                    $stop;
                end
            end

            if(odata != op1) begin
                $display("ERROR: Result incorrect!\n");
                $display("       Expected value: %8x\n", op1);
                $display("       Actual   value: %8x\n", odata);
                $fclose(command_file);
                $stop;
            end
            #`SETUPTIME getconfig = 0;
        end
        LOAD: begin // 'LOAD Op1 Op2 Op3' load Op1 to the module
            temp = $fscanf(command_file, "%8x\n", op1);
            temp = $fscanf(command_file, "%8x\n", op2);
            temp = $fscanf(command_file, "%8x\n", op3);
            if(op3 == 0) begin
                $display("%d	LOAD   0x%x   0x%x   FALSE\n", cycle_count, op1, op2);
            end
            else begin
                $display("%d	LOAD   0x%x   0x%x   TRUE\n", cycle_count, op1, op2);
            end
            load = 1;
            idata = op1;
            wait(!clk_reg);
            wait(clk_reg);
            i = 0;
            if(!ack) begin
                while(i<op2 && !ack) begin
                    i <= i + 1;
                    wait(!clk_reg);
                    wait(clk_reg);
                    //#`SETUPTIME;
                end
                if(i == op2) begin // exit because of time out
                    $display("ERROR: Timeout when excuting 'load'\n");
                    $fclose(command_file);
                    $stop;
                end
            end
            #`SETUPTIME;
            if(op3 == 0) begin
                load = 0;
            end
            else begin
                load = 1;
            end
        end
        FETCH: begin // 'FETCH Op1 Op2 Op3' fetch data from module under test
                     // and compare it with Op1
            temp = $fscanf(command_file, "%8x\n", op1);
            temp = $fscanf(command_file, "%8x\n", op2);
            temp = $fscanf(command_file, "%8x\n", op3);
            if(op3 == 0) begin
                $display("%d	FETCH   0x%x   0x%x   TRUE\n", cycle_count, op1, op2);
            end
            else begin
                $display("%d	FETCH   0x%x   0x%x   TRUE\n", cycle_count, op1, op2);
            end
            fetch = 1;

            wait(!clk_reg);
            wait(clk_reg);		
            i = 0;
            if(!ack) begin
                while(i<op2 && !ack) begin
                    i = i+1;
                    wait(!clk_reg);
                    wait(clk_reg);
                end
                if(i == op2) begin // exit because of time out
                    $display("ERROR: Timeout when excuting 'fetch'\n");
                    $fclose(command_file);
                    $stop;
                end
            end

            if(op1 != odata) begin
                $display("ERROR: Result incorrect!\n");
                $display("       Expected value: %8x\n", op1);
                $display("       Actual   value: %8x\n", odata);
                $fclose(command_file);
                $stop;
            end
            if(op3 == 0) begin
                #`SETUPTIME fetch = 0;
            end
            else begin
                #`SETUPTIME fetch = 1;
            end
        end
        WAITFOR: begin // 'WAIT 0Xa' Wait for 'a' cycles
            temp = $fscanf(command_file, "%8x\n", op1);
            i = 0;
            while(i < op1) begin
                i = i + 1;
                wait(!clk_reg);
                wait(clk_reg);
            end
            #`SETUPTIME;
        end
        default: begin // other commands: error
            $display("ERROR: One line with no commands.");
            $fclose(command_file);
            $stop;
        end
    endcase
end

always @(err) begin
    if(err) begin
        $display("ERROR: SHA module reports an error.");
    end
end
endmodule

