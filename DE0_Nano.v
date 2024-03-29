
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE0_Nano(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// SDRAM //////////
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_DQM,
	DRAM_RAS_N,
	DRAM_WE_N,

	//////////// EPCS //////////
	EPCS_ASDO,
	EPCS_DATA0,
	EPCS_DCLK,
	EPCS_NCSO,

	//////////// Accelerometer and EEPROM //////////
	G_SENSOR_CS_N,
	G_SENSOR_INT,
	I2C_SCLK,
	I2C_SDAT,

	//////////// ADC //////////
	ADC_CS_N,
	ADC_SADDR,
	ADC_SCLK,
	ADC_SDAT,

	//////////// 2x13 GPIO Header //////////
	GPIO_2,
	GPIO_2_IN,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	GPIO_0,
	GPIO_0_IN,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	GPIO_1,
	GPIO_1_IN
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

`define CLOCK
`define LED
`define KEY
`define SW
`define SDRAM
`define EPCS
`define AE
`define ADC
`define GPIOH
`define GPIO0
`define GPIO1


//////////// CLOCK //////////
//3.3-V LVTTL//
`ifdef CLOCK
input 		          		CLOCK_50;
`endif

//////////// LED //////////
//3.3-V LVTTL//
`ifdef LED
output		     [7:0]		LED;
`endif

//////////// KEY //////////
//3.3-V LVTTL//
`ifdef KEY
input 		     [1:0]		KEY;
`endif

//////////// SW //////////
//3.3-V LVTTL//
`ifdef SW
input 		     [3:0]		SW;
`endif

//////////// SDRAM //////////
//3.3-V LVTTL//
`ifdef SDRAM
output		    [12:0]		DRAM_ADDR;
output		     [1:0]		DRAM_BA;
output		          		DRAM_CAS_N;
output		          		DRAM_CKE;
output		          		DRAM_CLK;
output		          		DRAM_CS_N;
inout 		    [15:0]		DRAM_DQ;
output		     [1:0]		DRAM_DQM;
output		          		DRAM_RAS_N;
output		          		DRAM_WE_N;
`endif

//////////// EPCS //////////
//3.3-V LVTTL//
`ifdef EPCS
output		          		EPCS_ASDO;
input 		          		EPCS_DATA0;
output		          		EPCS_DCLK;
output		          		EPCS_NCSO;
`endif

//////////// Accelerometer and EEPROM //////////
//3.3-V LVTTL//
`ifdef AE
output		          		G_SENSOR_CS_N;
input 		          		G_SENSOR_INT;
output		          		I2C_SCLK;
inout 		          		I2C_SDAT;
`endif

//////////// ADC //////////
//3.3-V LVTTL//
`ifdef ADC
output		          		ADC_CS_N;
output		          		ADC_SADDR;
output		          		ADC_SCLK;
input 		          		ADC_SDAT;
`endif

//////////// 2x13 GPIO Header //////////
//3.3-V LVTTL//
`ifdef GPIOH
inout 		    [12:0]		GPIO_2;
input 		     [2:0]		GPIO_2_IN;
`endif

//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
//3.3-V LVTTL//
`ifdef GPIO0
inout 		    [33:0]		GPIO_0;
input 		     [1:0]		GPIO_0_IN;
`endif

//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
//3.3-V LVTTL//
`ifdef GPIO1
inout 		    [33:0]		GPIO_1;
input 		     [1:0]		GPIO_1_IN;
`endif

//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================
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
	
	LED[7:0]
);

ram2 RAM1 (
	ram1_address_in_a,
	CLOCK_50,
	ram1_data_in_a,
	ram1_wren_a,
	ram1_data_out_a
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


endmodule
