module vma412(
	input wire clock,
	input wire reset,
	
	output reg[7:0] data,
	output reg csx,
	output reg resx,
	output reg dcx,
	output reg wrx,
	output reg rdx,
	
	input wire[63:0] vram_data_in,
	output reg[4:0] vram_address_out,
	output reg vram_write
);
/*
reg[5:0] clock_count;
reg clock_divided;*/

reg[16:0] rom[0:511];
reg[15:0] pc;
reg[15:0] instruction;
reg[2:0] stage;
reg[7:0] tmpx = 0;
reg[7:0] tmpy = 0;
reg[63:0] vram_data_buffer;

reg[11:0] clock_counter;
reg clock_divided;

parameter STEP1=0, STEP2=1, STEP3=2;

// Initialize ROM of display
initial begin
	$readmemh("vma412.mem", rom);
end

always @(posedge clock, negedge reset) begin
	if (reset == 1'b0) begin
		clock_divided = 0;
		clock_counter = 0;
	end else begin
		clock_counter = clock_counter + 1;
		if (clock_counter == 4000) begin
			clock_divided = !clock_divided;
			clock_counter = 0;
		end
	end
end

always @(posedge clock_divided, negedge reset) begin
	if (reset == 1'b0) begin
		data = 0;
		csx = 1;
		resx = 0;
		dcx = 1;
		wrx = 1;
		rdx = 1;
		instruction = 0;
		pc = 0;
		tmpx = 0;
		tmpy = 0;
		vram_address_out = 0;
		vram_write = 0;
		stage = STEP1;
	end
	else begin
	
		if (resx == 0) begin
			resx = 1;
		end
		
		else if (stage == STEP1) begin
			instruction = rom[pc];
			
			// C?XX = COMMAND
			if (instruction[15:12] == 4'hC) begin
				csx = 0;
				dcx = 0;
				wrx = 0;
				data = instruction[7:0];
				stage = STEP2;
			end
			
			// D?XX = DATA
			else if (instruction[15:12] == 4'hD) begin
				csx = 0;
				dcx = 1;
				wrx = 0;
				data = instruction[7:0];
				stage = STEP2;
			end
			
			// P?XX = DATA
			else if (instruction[15:12] == 4'hD) begin
				csx = 0;
				dcx = 1;
				wrx = 0;
				data = instruction[7:0];
				stage = STEP2;
			end
			
			// BXXX = BACK XXX
			else if (instruction[15:12] == 4'hB) begin
				pc = pc - instruction[11:0];
			end
			
			// FXXX = fill pixel data XXX
			else if (instruction[15:12] == 4'hF) begin
				tmpx = 0;
				tmpy = 0;
				vram_address_out = 0;
				stage = STEP2;
			end
			
			// AXXX = Sleep XXX ticks
			else if (instruction[15:12] == 4'hA) begin
				stage = STEP2;
			end
			
		end
		
		else if (stage == STEP2) begin
			
			// FXXX = fill pixel data XXX
			if (instruction[15:12] == 4'hF) begin
				
				if (tmpx == 0) begin
					vram_data_buffer = vram_data_in;
				end
			
				csx = 0;
				dcx = 1;
				wrx = 0;
				if (vram_data_buffer[tmpx >> 1] == 1)
					data[7:0] = 8'hFF;
				else
					data[7:0] = 8'h00;
				
				tmpx = tmpx + 1;
				if (tmpx == 128) begin
					tmpx = 0;
					tmpy = tmpy + 1;
					vram_address_out = tmpy;
				end
				stage = STEP3;
			end
			
			// AXXX = Sleep XXX ticks
			else if (instruction[15:12] == 4'hA) begin
				if (instruction[11:0] == 0) begin
					pc = pc + 1;
					stage = STEP1;
				end else begin
					instruction[11:0] = instruction[11:0] - 1;
				end
			end
			
			// Any other instruction
			else begin 
				wrx = 1;
				stage = STEP1;
				pc = pc + 1;
			end
			
		end
		
		else if (stage == STEP3) begin
			
			// FXXX = fill pixel data XXX
			if (instruction[15:12] == 4'hF) begin
				if (wrx == 0) begin
					wrx = 1;
				end else begin
					if (tmpy == 32) begin
						stage = STEP1;
						pc = pc + 1;
					end else begin
						stage = STEP2;
					end
				end
			end
			
			// Any other instruction
			else begin 
				wrx = 1;
				stage = STEP1;
				pc = pc + 1;
			end
			
		end
	end
end


endmodule