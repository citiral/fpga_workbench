
`timescale 1 ps/1 ps  // time-unit = 1 ps, precision = 1 ps

module chip8_tb;

localparam period = 50;

wire[11:0] ram1_address_in_a;
wire[11:0] ram1_address_in_b;
wire[7:0] ram1_data_in_a;
wire[7:0] ram1_data_in_b;
wire[7:0] ram1_data_out_a;
wire[7:0] ram1_data_out_b;
wire ram1_wren_a;
wire ram1_wren_b;

reg CLOCK_50;
reg[1:0] KEY;
wire[7:0] LED;

chip8 cpu(
	CLOCK_50,
	KEY[0],
	ram1_data_out_a,
	ram1_address_in_a,
	ram1_data_in_a,
	ram1_wren_a,
	LED
);

ram1 RAM1 (
	ram1_address_in_a,
	ram1_address_in_b,
	CLOCK_50,
	ram1_data_in_a,
	ram1_data_in_b,
	ram1_wren_a,
	ram1_wren_b,
	ram1_data_out_a,
	ram1_data_out_b
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
	if(LED != 8'h0)
		$display("Reset did not put register_0 to 0");
	
	#period
	#period
	
	if(LED != 88)
		$display("Reset did not put register_0 to 0");
	
	$stop;
	
end

endmodule
