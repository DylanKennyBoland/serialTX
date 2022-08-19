`timescale 1ns / 1ns
// Author: Dylan Boland (Student)
//
// A basic Verilog testbench for the serialTX module.
//
//
module TB_serialTX;
	
	// ==== Define the testbench stimulus signals - these connect to the device under test (dut) ====
	reg clk, reset, send; // all inputs to the dut, and all 1-bit signals by default
	reg [7:0] data; // 8-bit wide data vector signal
	wire txOut, busy; // 1-bit wide output signals - these will be driven by o/ps of the dut
	
	// ==== Instantiate the Design Module ====
	// Module name: serialTX, Instance name: dut
	serialTX #(.INCR(4000000))
		dut (.clk(clk),
			.reset(reset),
			.send(send),
			.data(data),
			.busy(busy),
			.txOut(txOut)
			);
	
	// ==== Generate the Clock (clk) Signal ====
	// 50 MHz clock should have a period of 20 ns, meaning the value
	// should change every 10 ns:
	initial
		begin
			clk = 1'b0; // clk starts at 0
			forever
				#10 clk = ~clk; // invert clk's value every 10 ns
		end
	
	// ==== Define the Initial Signal Values ====
	// note: we only impose initial values on input signals to the dut - not output signals
	initial
		begin
			reset = 1'b0;
			send = 1'b0;
			data = 8'h0;
			
			// ==== Generate Stimulus Signals to the DUT ===
			#15 reset = 1'b1; // reset goes high
			#20 reset = 1'b0; // wait 20 ns (1 clk cycle) and set reset low again
			@(posedge clk); // wait for a rising clock edge
			#1 data = 8'h35; // set up data just after the clock edge; on waveforms it will be easier to read hex, than read binary and convert to decimal etc.
			#20 send = 1'b1; // 20 ns later, set send high
			#20 send = 1'b0; // 20 ns (1 clk cycle) set send low again
			wait (busy == 1'b0); // wait until no longer busy (i.e., busy == 0)
			#25; // do nothing for 25 ns
			@(posedge clk); // wait for the next rising edge of the clock
			#1 data = 8'h61; // 1 hex code maps to 4 bits, so two hex codes maps to an 8-bit sequence
			#20 send = 1'b1;
			#20 send = 1'b0;
			repeat (3) // generate 3 pulses
				begin
					#600 send = 1'b1;
					#20 send = 1'b0;
				end
			@(negedge busy); // wait for busy signal makes a high-to-low (1->0) transition
			#300; // wait 300 ns (15 clk cycles)
			$stop;
		end
end
	
	
				