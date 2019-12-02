module vma412(
	input wire clock,
	input wire reset,
	
	output reg[7:0] data,
	output reg csx,
	output reg resx,
	output reg dcx,
	output reg wrx,
	output reg rdx,
	
	output reg[7:0] screen_adr,
	input wire screen_data
);
/*
reg[5:0] clock_count;
reg clock_divided;*/

reg[16:0] rom[0:511];
reg[15:0] pc;
reg[15:0] instruction;
reg[2:0] stage;
reg[12:0] tmp = 0;

parameter STEP1=0, STEP2=1, STEP3=2;

// Initialize ROM of display
initial begin
	$readmemh("vma412.mem", rom);
end
/*

always @(posedge clock, negedge reset) begin
	if (reset == 1'b0) begin
		clock_count = 0;
		clock_divided = 0;
	end 
	else begin 
		clock_count = clock_count + 1;
		if (clock_count == 0) begin
			clock_count = 0;
			clock_divided = !clock_divided;
		end
	end
end*/

always @(posedge clock, negedge reset) begin
	if (reset == 1'b0) begin
		data = 0;
		csx = 1;
		resx = 1;
		dcx = 1;
		wrx = 1;
		rdx = 1;
		instruction = 0;
		pc = 0;
		screen_adr = 0;
		tmp = 0;
		stage = STEP1;
	end
	else begin
		
		if (stage == STEP1) begin
			instruction = rom[pc];
		
			// FFFF = NOP
			if (instruction == 12'hFFFF) begin
			
			end
			
			// C?XX = COMMAND
			else if (instruction[15:12] == 4'hC) begin
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
				tmp = 0;
				screen_adr = 0;
				stage = STEP2;
			end
			
		end
		
		else if (stage == STEP2) begin
			
			// FXXX = fill pixel data XXX
			if (instruction[15:12] == 4'hF) begin
				csx = 0;
				dcx = 1;
				wrx = 0;
				data[7:0] = screen_data;
				tmp = tmp + 1;
				screen_adr = tmp >> 1;
				stage = STEP3;
			end else begin 
				wrx = 1;
				stage = STEP1;
				pc = pc + 1;
			end
			
		end
		
		else if (stage == STEP3) begin
			
			// FXXX = fill pixel data XXX
			if (instruction[15:12] == 4'hF) begin
				wrx = 1;
				if ((tmp >> 1) == instruction[11:0]) begin
					stage = STEP1;
					pc = pc + 1;
				end else begin
					stage = STEP2;
				end
			end else begin 
				wrx = 1;
				stage = STEP1;
				pc = pc + 1;
			end
			
		end
	end
end


endmodule