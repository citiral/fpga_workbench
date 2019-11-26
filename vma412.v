module vma412(
	input wire clock,
	input wire reset,
	
	inout wire[7:0] data,
	output wire csx,
	output wire resx,
	output wire dcx,
	output wire wrx,
	output wire rdx,
);


wire[16:0] rom;
reg[16:0] pc;
reg[16:0] instruction;
wire[2:0] stage;

parameter STEP0=0, STEP1=1,





always @(posedge clock, negedge reset) begin
	if (reset == 1'b0) begin
		data = 0;
		csx = 0;
		resx = 0;
		dcx = 0;
		wrx = 0;
		rdx = 0;
		instruction = 0;
		stage = STEP0;
	end else begin
		
		
		if (stage == STEP1) begin
		
		end
		
		
	end
end


endmodule