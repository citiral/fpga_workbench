
`timescale 1 ps/1 ps  // time-unit = 1 ps, precision = 1 ps

module vma412_tb;

localparam period = 50;

reg CLOCK_50;
reg[1:0] KEY;
wire[7:0] LED;
wire csx;
wire resx;
wire dcx;
wire wrx;
wire rdx;

vma412 lcd(
	CLOCK_50,
	KEY[0],	
	LED,
	csx,
	resx,
	dcx,
	wrx,
	rdx
);

// Generate the clock for the test bench
always begin
	CLOCK_50 = 1'b1;
	#50;
	CLOCK_50 = 1'b0;
	#50;
end

// run the tests
initial @(posedge CLOCK_50) begin
	// Reset the chip8
	KEY[0] = 1'b0;
	#period;
	KEY[0] = 1'b1;
	
	$stop;
end

endmodule
