module chip8(
	input wire clock,
	input wire reset,
	
	input wire[15:0] input_in,

	input wire[7:0] ram_data_in,
	output reg[11:0] ram_address_out,
	output reg[7:0] ram_data_out,
	output reg ram_write,
	
	input wire[63:0] vram_data_in,
	output reg[4:0] vram_address_out,
	output reg[63:0] vram_data_out,
	output reg vram_write,

	output wire[7:0] register_0
);

parameter INSTR_FETCH1=0, INSTR_FETCH2=1, INSTR_EXEC1=2, INSTR_EXEC2=3, DELAY=4, HARDFAULT=5;

// Registers of the cpu
reg[7:0] registers_data[0:15];
reg[11:0] register_adr;
reg[11:0] pc;
reg[7:0] chip8_dtimer;
reg[7:0] chip8_stimer;

// Current instruction being executed
reg[15:0] instruction;

// Current stage it is running at
reg[2:0] stage;

// The stage to run after a delay
reg[2:0] stage_delay;
reg[2:0] delay_time;

// Used during calculations
reg[8:0] tmp;

// Used in for loops
integer i;

// Callstack
reg[12:0] stack[0:255];
reg[7:0] stack_size;

// Run an instruction with delay
task delay_stage(input[2:0] next_stage, input[2:0] count);
	begin
		delay_time = count;
		stage_delay = next_stage;
		stage = DELAY;
	end
endtask


// Run every clock cyle or on reset
always @(posedge clock, negedge reset) begin

	// Reset all state on a reset
	if (reset == 1'b0) begin
		ram_write = 0;
		ram_address_out = 0;
		ram_data_out = 0;
		
		vram_write = 0;
		vram_address_out = 0;
		vram_data_out = 0;		
		
		for (i = 0 ; i < 16 ; i = i+1)
			registers_data[i] = 0;
		register_adr = 0;		
		pc = 12'h200;
		
		stack_size = 0;
		
		instruction = 0;
		stage = INSTR_FETCH1;
		
	end else begin	
		// If it is a delay stage, do nothing for delay cycles
		if (stage == DELAY) begin
			delay_time = delay_time - 1;
			if (delay_time == 1'b0)
				stage = stage_delay;
		end
		
		
		// Fetch the instruction, two bytes, one byte per cycle
		else if (stage == INSTR_FETCH1) begin
			ram_write = 0;
			ram_address_out = pc[11:0];
			ram_data_out = 0;
			delay_stage(INSTR_FETCH2, 2);
		end
		
		
		else if (stage == INSTR_FETCH2) begin
			instruction[15:8] = ram_data_in; // Get the first byte of the instruction read in last stage
			ram_address_out = pc[11:0] + 1;
			delay_stage(INSTR_EXEC1, 2);
		end
		
		
		// Execute the instruction
		else if (stage == INSTR_EXEC1) begin

			// Get the second byte of the instruction read in last stage
			instruction[7:0] = ram_data_in;
			
			// 6XNN: Store number NN in register VX
			if (instruction[15:12] == 4'h6) begin
				registers_data[instruction[11:8]] = instruction[7:0];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY0: Store the value of register VY in register VX
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h0) begin
				registers_data[instruction[11:8]] = registers_data[instruction[3:0]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 7XNN: add value NN to register VX
			else if (instruction[15:12] == 4'h7) begin
				registers_data[instruction[11:8]] = registers_data[instruction[11:8]] + instruction[7:0];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//8XY4: Add the value of register VY to register VX
			//      Set VF to 01 if a carry occurs
			//      Set VF to 00 if a carry does not occur
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h4) begin
				tmp = registers_data[instruction[11:8]] + registers_data[instruction[7:4]];
				registers_data[instruction[11:8]] = tmp[7:0];
				registers_data[15] = tmp[8];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY5: Subtract the value of register VY from register VX
			//       Set VF to 00 if a borrow occurs
			//       Set VF to 01 if a borrow does not occur
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h5) begin
				tmp = registers_data[instruction[11:8]] - registers_data[instruction[7:4]];
				registers_data[instruction[11:8]] = tmp[7:0];
				registers_data[15] = !tmp[8];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY7: Set register VX to the value of VY minus VX
			//       Set VF to 00 if a borrow occurs
			//       Set VF to 01 if a borrow does not occur
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h5) begin
				tmp = registers_data[instruction[11:8]] - registers_data[instruction[7:4]];
				registers_data[instruction[7:4]] = tmp[7:0];
				registers_data[15] = !tmp[8];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY2: Set VX to VX AND VY
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h2) begin
				registers_data[instruction[11:8]] = registers_data[instruction[11:8]] & registers_data[instruction[7:4]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY1: Set VX to VX OR VY
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h1) begin
				registers_data[instruction[11:8]] = registers_data[instruction[11:8]] | registers_data[instruction[7:4]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY3: Set VX to VX XOR VY
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h3) begin
				registers_data[instruction[11:8]] = registers_data[instruction[11:8]] ^ registers_data[instruction[7:4]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XY6: Store the value of register VY shifted right one bit in register VX
			//       Set register VF to the least significant bit prior to the shift
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'h6) begin
				registers_data[15] = registers_data[instruction[7:4]][0];
				registers_data[instruction[11:8]] = registers_data[instruction[7:4]] >> 1;
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			// 8XYE: Store the value of register VY shifted left one bit in register VX
			//       Set register VF to the most significant bit prior to the shift
			else if (instruction[15:12] == 4'h8 && instruction[3:0] == 4'hE) begin
				registers_data[15] = registers_data[instruction[7:4]][7];
				registers_data[instruction[11:8]] = registers_data[instruction[7:4]] << 1;
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
						
			//1NNN: Jump to address NNN
			else if (instruction[15:12] == 4'h1) begin
				pc = instruction[11:0];
				stage = INSTR_FETCH1;
			end
			
			//BNNN: Jump to address NNN + V0
			else if (instruction[15:12] == 4'hB) begin
				pc = instruction[11:0] + registers_data[0];
				stage = INSTR_FETCH1;
			end
			
			//2NNN: Execute subroutine starting at address NNN
			else if (instruction[15:12] == 4'h2) begin
				stack[stack_size] = pc;
				stack_size = stack_size + 1;
				pc = instruction[11:0];
				stage = INSTR_FETCH1;
			end
			
			//00EE: Return from a subroutine
			else if (instruction[15:0] == 8'h00EE) begin
				stack[stack_size] = pc;
				stack_size = stack_size + 1;
				pc = instruction[11:0];
				stage = INSTR_FETCH1;
			end
			
			//3XNN: Skip the following instruction if the value of register VX equals NN
			else if (instruction[15:12] == 4'h3) begin
				if (registers_data[instruction[11:8]] == instruction[7:0])
					pc = pc + 4;
				else
					pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//5XY0: Skip the following instruction if the value of register VX is equal to the value of register VY
			else if (instruction[15:12] == 4'h5 && instruction[3:0] == 4'h0) begin
				if (registers_data[instruction[11:8]] == registers_data[instruction[7:4]])
					pc = pc + 4;
				else
					pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//4XNN: Skip the following instruction if the value of register VX is not equal to NN
			else if (instruction[15:12] == 4'h4) begin
				if (registers_data[instruction[11:8]] == instruction[7:0])
					pc = pc + 2;
				else
					pc = pc + 4;
				stage = INSTR_FETCH1;
			end
			
			//9XY0: Skip the following instruction if the value of register VX is not equal to the value of register VY
			else if (instruction[15:12] == 4'h9 && instruction[3:0] == 4'h0) begin
				if (registers_data[instruction[11:8]] == registers_data[instruction[7:4]])
					pc = pc + 2;
				else
					pc = pc + 4;
				stage = INSTR_FETCH1;
			end
			
			//FX15: Set the delay timer to the value of register VX
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 7'h15) begin
				chip8_dtimer = registers_data[instruction[11:7]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//FX07: Store the current value of the delay timer in register VX
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 7'h07) begin
				registers_data[instruction[11:7]] = chip8_dtimer;
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//FX18: Set the sound timer to the value of register VX
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 7'h18) begin
				chip8_stimer = registers_data[instruction[11:7]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//FX0A: Wait for a keypress and store the result in register VX
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h0A) begin
				if (input_in != 0) begin
					casez (input_in)
						16'b???????????????1: registers_data[instruction[11:7]] = 0;
						16'b??????????????1?: registers_data[instruction[11:7]] = 1;
						16'b?????????????1??: registers_data[instruction[11:7]] = 2;
						16'b????????????1???: registers_data[instruction[11:7]] = 3;
						16'b???????????1????: registers_data[instruction[11:7]] = 4;
						16'b??????????1?????: registers_data[instruction[11:7]] = 5;
						16'b?????????1??????: registers_data[instruction[11:7]] = 6;
						16'b????????1???????: registers_data[instruction[11:7]] = 7;
						16'b???????1????????: registers_data[instruction[11:7]] = 8;
						16'b??????1?????????: registers_data[instruction[11:7]] = 9;
						16'b?????1??????????: registers_data[instruction[11:7]] = 10;
						16'b????1???????????: registers_data[instruction[11:7]] = 11;
						16'b???1????????????: registers_data[instruction[11:7]] = 12;
						16'b??1?????????????: registers_data[instruction[11:7]] = 13;
						16'b?1??????????????: registers_data[instruction[11:7]] = 14;
						16'b1???????????????: registers_data[instruction[11:7]] = 15;
					endcase
					pc = pc + 2;
					stage = INSTR_FETCH1;
				end
			end
			
			//EX9E: Skip the following instruction if the key corresponding to the hex value currently stored in register VX is pressed
			else if (instruction[15:12] == 4'hE && instruction[7:0] == 8'h9E) begin
				if (input_in[registers_data[instruction[11:8]]] == 0)
					pc = pc + 2;
				else
					pc = pc + 4;
				stage = INSTR_FETCH1;
			end
			
			//EXA1: Skip the following instruction if the key corresponding to the hex value currently stored in register VX is not pressed
			else if (instruction[15:12] == 4'hE && instruction[7:0] == 8'hA1) begin
				if (input_in[registers_data[instruction[11:8]]] == 0)
					pc = pc + 4;
				else
					pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			
			//ANNN: Store memory address NNN in register I
			else if (instruction[15:12] == 4'hA) begin
				register_adr = instruction[11:0];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//FX1E: Add the value stored in register VX to register I
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h1E) begin
				register_adr = register_adr + registers_data[instruction[11:8]];
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//00E0: Clear the screen
			else if (instruction[15:0] == 16'h00E0) begin
				tmp = 0;
				vram_data_out = 0;
				vram_address_out = 0;
				vram_write = 1;
				stage = INSTR_EXEC2;
			end
			
			//FX29: Set I to the memory address of the sprite data corresponding to the hexadecimal digit stored in register VX
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h29) begin
				// values are stored starting from 0, being 5 bytes per character
				register_adr = instruction[11:8] * 5;
				pc = pc + 2;
				stage = INSTR_FETCH1;
			end
			
			//FX55: Store the values of registers V0 to VX inclusive in memory starting at address I
			//      I is set to I + X + 1 after operation
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h55) begin
				tmp = 0;
				stage= INSTR_EXEC2;
			end
			
			//FX65: Fill registers V0 to VX inclusive with the values stored in memory starting at address I
			//      I is set to I + X + 1 after operation
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h65) begin
				ram_address_out = register_adr;
				tmp = 0;
				delay_stage(INSTR_EXEC2, 2);
			end
			
			//DXYN: Draw a sprite at position VX, VY with N bytes of sprite data starting at the address stored in I
			//      Set VF to 01 if any set pixels are changed to unset, and 00 otherwise
			else if (instruction[15:12] == 4'hD) begin
				registers_data[15] = 0;
				ram_address_out = register_adr;
				vram_address_out = registers_data[instruction[7:4]];
				tmp = 0;
				delay_stage(INSTR_EXEC2, 2);
			end
			
			//FX33: Store the binary-coded decimal equivalent of the value stored in register VX at addresses I, I+1, and I+2
			//0NNN: Execute machine language subroutine at address NNN
			//CXNN: Set VX to a random number with a mask of NN
			
			
			// invalid instruction = hardfault
			else begin
				stage = HARDFAULT;
			end
		end
		
		
		else if (stage == INSTR_EXEC2) begin
		
			//00E0: Clear the screen
			if (instruction[15:0] == 8'h00EE) begin
				if (tmp >= 32) begin
					vram_write = 0;
					pc = pc + 2;
					stage = INSTR_FETCH1;
				end
				
				tmp = tmp + 1;
				vram_address_out = tmp;				
			end
		
			//FX55: Store the values of registers V0 to VX inclusive in memory starting at address I
			//      I is set to I + X + 1 after operation
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h55) begin
				// End the instruction once all bytes have been written
				if (tmp > instruction[11:8]) begin
					ram_write = 0;
					pc = pc + 2;
					delay_stage(INSTR_FETCH1, 1);
				end else begin
					ram_write = 1;
					ram_address_out = register_adr;
					ram_data_out = registers_data[tmp];
					register_adr = register_adr + 1;
					tmp = tmp + 1;
				end
			end
		
			//FX65: Fill registers V0 to VX inclusive with the values stored in memory starting at address I
			//      I is set to I + X + 1 after operation
			else if (instruction[15:12] == 4'hF && instruction[7:0] == 8'h65) begin
				registers_data[tmp] = ram_data_in;
				tmp = tmp + 1;
				register_adr = register_adr + 1;
				
				// End the instruction once all bytes have been read
				if (tmp > instruction[11:8]) begin
					pc = pc + 2;
					stage = INSTR_FETCH1;
				end else begin
					ram_address_out = register_adr;
					delay_stage(INSTR_EXEC2, 2);
				end
			end
			
			//DXYN: Draw a sprite at position VX, VY with N bytes of sprite data starting at the address stored in I
			//      Set VF to 01 if any set pixels are changed to unset, and 00 otherwise
			else if (instruction[15:12] == 4'hD) begin
				// Update the row of pixel data with this byte
				if (vram_write == 0) begin
					vram_data_out = vram_data_in;
					for (i = 0 ; i < 8 ; i = i + 1) begin
						if (vram_data_in[registers_data[instruction[11:8]] + i] & ram_data_in[7 - i]) begin
							registers_data[15] = 1;
						end
						vram_data_out[registers_data[instruction[11:8]] + i] = ram_data_in[7 - i];
					end
					
					vram_write = 1;
					delay_stage(INSTR_EXEC2, 2);
				end
				// End the operation
				else if (tmp + 1 >= instruction[3:0]) begin
					pc = pc + 2;
					stage = INSTR_FETCH1;
				end
				// Get the next row of pixel data
				else begin
					tmp = tmp + 1;
					ram_address_out = register_adr + tmp;
					vram_write = 0;
					vram_address_out = registers_data[instruction[7:4]] + tmp;
					delay_stage(INSTR_EXEC2, 2);
				end
			end
			
		end
	end
end

endmodule