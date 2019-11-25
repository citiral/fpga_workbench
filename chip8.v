module chip8(
	input wire clock,
	input wire reset,

	input wire[7:0] ram_data_in,

	output reg[11:0] ram_address_out,
	output reg[7:0] ram_data_out,
	output reg ram_write,

	output wire[7:0] register_0
);

parameter INSTR_FETCH1=0, INSTR_FETCH2=1, INSTR_EXEC1=2, INSTR_EXEC2=3;

// Registers of the cpu
reg[7:0] registers_data[0:15];
reg[15:0] register_adr;
reg[15:0] pc;

// Current instruction being executed
reg[15:0] instruction;

// Current stage it is running at
reg[2:0] stage;


// Output the first register so it can be used for debugging
assign register_0 = registers_data[0];

// Used in for loops
integer i;

// Run every clock cyle or on reset
always @(posedge clock, negedge reset) begin

	// Reset all state on a reset
	if (reset == 1'b0) begin
		ram_write = 0;
		ram_address_out = 0;
		ram_data_out = 0;
		
		for (i = 0 ; i < 16 ; i = i+1)
			registers_data[i] = 0;
		register_adr = 0;		
		pc = 0;
		
		instruction = 0;
		stage = INSTR_FETCH1;
		
	end else begin
		// Fetch the instruction, two bytes, one byte per cycle
		if (stage == INSTR_FETCH1) begin
			ram_write = 0;
			ram_address_out = pc[11:0];
			ram_data_out = 0;
			stage = INSTR_FETCH2;
		end
		else if (stage == INSTR_FETCH2) begin
			// Get the first byte of the instruction read in last stage
			instruction[15:8] = ram_data_in;
			ram_address_out = pc[11:0] + 1;
			stage = INSTR_EXEC1;	
		end
		
		// Execute the instruction
		else if (stage == INSTR_EXEC1) begin
			// Get the second byte of the instruction read in last stage
			instruction[7:0] = ram_data_in;
			
			registers_data[0] = instruction[15:8];
			registers_data[1] = instruction[7:0];
			pc = pc + 2;
			stage = INSTR_FETCH1;
		end
	end
end

endmodule