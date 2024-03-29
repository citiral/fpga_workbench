
`timescale 1 ps/1 ps  // time-unit = 1 ps, precision = 1 ps

module chip8_tb;

localparam period = 50;

wire[11:0] ram1_address_in_a;
wire[7:0] ram1_data_in_a;
wire[7:0] ram1_data_out_a;
wire ram1_wren_a;

wire[4:0] vram_address_in_a;
wire[4:0] vram_address_in_b;
wire[63:0] vram_data_in_a;
wire[63:0] vram_data_in_b;
wire[63:0] vram_data_out_a;
wire[63:0] vram_data_out_b;
wire vram_wren_a;
wire vram_wren_b;


reg CLOCK_50;
reg[1:0] KEY;
wire[7:0] LED;
wire[12:0] GPIO_1;

chip8 cpu(
	CLOCK_50,
	KEY[0],
	KEY[1],
	
	ram1_data_out_a,
	ram1_address_in_a,
	ram1_data_in_a,
	ram1_wren_a,

	vram_data_out_a,
	vram_address_in_a,
	vram_data_in_a,
	vram_wren_a,
	
	LED
);

ram2 RAM1 (
	ram1_address_in_a,
	CLOCK_50,
	ram1_data_in_a,
	ram1_wren_a,
	ram1_data_out_a
);


vma412 lcd (
	CLOCK_50,
	KEY[0],
	GPIO_1[7:0],
	GPIO_1[9],
	GPIO_1[8],
	GPIO_1[10],
	GPIO_1[11],
	GPIO_1[12],
	vram_data_out_b,
	vram_address_in_b,
	vram_wren_b
);

ram1 VRAM (
	vram_address_in_a,
	vram_address_in_b,
	CLOCK_50,
	vram_data_in_a,
	vram_data_in_b,
	vram_wren_a,
	vram_wren_b,
	vram_data_out_a,
	vram_data_out_b
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
