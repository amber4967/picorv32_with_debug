//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.11.01 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Sun Mar 15 18:47:12 2026

module SRAM2 (dout, clk, oce, ce, reset, wre, ad, din);

output [7:0] dout;
input clk;
input oce;
input ce;
input reset;
input wre;
input [11:0] ad;
input [7:0] din;

wire [27:0] sp_inst_0_dout_w;
wire [27:0] sp_inst_1_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

SP sp_inst_0 (
    .DO({sp_inst_0_dout_w[27:0],dout[3:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[11:0],gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[3:0]})
);

defparam sp_inst_0.READ_MODE = 1'b0;
defparam sp_inst_0.WRITE_MODE = 2'b00;
defparam sp_inst_0.BIT_WIDTH = 4;
defparam sp_inst_0.BLK_SEL = 3'b000;
defparam sp_inst_0.RESET_MODE = "SYNC";
defparam sp_inst_0.INIT_RAM_00 = 256'h000F667777776077107000000100000000000000000000000000000000000000;

SP sp_inst_1 (
    .DO({sp_inst_1_dout_w[27:0],dout[7:4]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[11:0],gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7:4]})
);

defparam sp_inst_1.READ_MODE = 1'b0;
defparam sp_inst_1.WRITE_MODE = 2'b00;
defparam sp_inst_1.BIT_WIDTH = 4;
defparam sp_inst_1.BLK_SEL = 3'b000;
defparam sp_inst_1.RESET_MODE = "SYNC";
defparam sp_inst_1.INIT_RAM_00 = 256'h000D1FFF151F00DE00E100000C08000000000000000000000000000000000004;

endmodule //SRAM2
