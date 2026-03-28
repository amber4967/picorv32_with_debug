module gw_gao(
    cpu_mem_valid,
    \cpu_mem_addr[31] ,
    \cpu_mem_addr[30] ,
    \cpu_mem_addr[29] ,
    \cpu_mem_addr[28] ,
    \cpu_mem_addr[27] ,
    \cpu_mem_addr[26] ,
    \cpu_mem_addr[25] ,
    \cpu_mem_addr[24] ,
    \cpu_mem_addr[23] ,
    \cpu_mem_addr[22] ,
    \cpu_mem_addr[21] ,
    \cpu_mem_addr[20] ,
    \cpu_mem_addr[19] ,
    \cpu_mem_addr[18] ,
    \cpu_mem_addr[17] ,
    \cpu_mem_addr[16] ,
    \cpu_mem_addr[15] ,
    \cpu_mem_addr[14] ,
    \cpu_mem_addr[13] ,
    \cpu_mem_addr[12] ,
    \cpu_mem_addr[11] ,
    \cpu_mem_addr[10] ,
    \cpu_mem_addr[9] ,
    \cpu_mem_addr[8] ,
    \cpu_mem_addr[7] ,
    \cpu_mem_addr[6] ,
    \cpu_mem_addr[5] ,
    \cpu_mem_addr[4] ,
    \cpu_mem_addr[3] ,
    \cpu_mem_addr[2] ,
    \cpu_mem_addr[1] ,
    \cpu_mem_addr[0] ,
    \cpu_mem_rdata[31] ,
    \cpu_mem_rdata[30] ,
    \cpu_mem_rdata[29] ,
    \cpu_mem_rdata[28] ,
    \cpu_mem_rdata[27] ,
    \cpu_mem_rdata[26] ,
    \cpu_mem_rdata[25] ,
    \cpu_mem_rdata[24] ,
    \cpu_mem_rdata[23] ,
    \cpu_mem_rdata[22] ,
    \cpu_mem_rdata[21] ,
    \cpu_mem_rdata[20] ,
    \cpu_mem_rdata[19] ,
    \cpu_mem_rdata[18] ,
    \cpu_mem_rdata[17] ,
    \cpu_mem_rdata[16] ,
    \cpu_mem_rdata[15] ,
    \cpu_mem_rdata[14] ,
    \cpu_mem_rdata[13] ,
    \cpu_mem_rdata[12] ,
    \cpu_mem_rdata[11] ,
    \cpu_mem_rdata[10] ,
    \cpu_mem_rdata[9] ,
    \cpu_mem_rdata[8] ,
    \cpu_mem_rdata[7] ,
    \cpu_mem_rdata[6] ,
    \cpu_mem_rdata[5] ,
    \cpu_mem_rdata[4] ,
    \cpu_mem_rdata[3] ,
    \cpu_mem_rdata[2] ,
    \cpu_mem_rdata[1] ,
    \cpu_mem_rdata[0] ,
    cpu_mem_ready,
    rst_n,
    clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input cpu_mem_valid;
input \cpu_mem_addr[31] ;
input \cpu_mem_addr[30] ;
input \cpu_mem_addr[29] ;
input \cpu_mem_addr[28] ;
input \cpu_mem_addr[27] ;
input \cpu_mem_addr[26] ;
input \cpu_mem_addr[25] ;
input \cpu_mem_addr[24] ;
input \cpu_mem_addr[23] ;
input \cpu_mem_addr[22] ;
input \cpu_mem_addr[21] ;
input \cpu_mem_addr[20] ;
input \cpu_mem_addr[19] ;
input \cpu_mem_addr[18] ;
input \cpu_mem_addr[17] ;
input \cpu_mem_addr[16] ;
input \cpu_mem_addr[15] ;
input \cpu_mem_addr[14] ;
input \cpu_mem_addr[13] ;
input \cpu_mem_addr[12] ;
input \cpu_mem_addr[11] ;
input \cpu_mem_addr[10] ;
input \cpu_mem_addr[9] ;
input \cpu_mem_addr[8] ;
input \cpu_mem_addr[7] ;
input \cpu_mem_addr[6] ;
input \cpu_mem_addr[5] ;
input \cpu_mem_addr[4] ;
input \cpu_mem_addr[3] ;
input \cpu_mem_addr[2] ;
input \cpu_mem_addr[1] ;
input \cpu_mem_addr[0] ;
input \cpu_mem_rdata[31] ;
input \cpu_mem_rdata[30] ;
input \cpu_mem_rdata[29] ;
input \cpu_mem_rdata[28] ;
input \cpu_mem_rdata[27] ;
input \cpu_mem_rdata[26] ;
input \cpu_mem_rdata[25] ;
input \cpu_mem_rdata[24] ;
input \cpu_mem_rdata[23] ;
input \cpu_mem_rdata[22] ;
input \cpu_mem_rdata[21] ;
input \cpu_mem_rdata[20] ;
input \cpu_mem_rdata[19] ;
input \cpu_mem_rdata[18] ;
input \cpu_mem_rdata[17] ;
input \cpu_mem_rdata[16] ;
input \cpu_mem_rdata[15] ;
input \cpu_mem_rdata[14] ;
input \cpu_mem_rdata[13] ;
input \cpu_mem_rdata[12] ;
input \cpu_mem_rdata[11] ;
input \cpu_mem_rdata[10] ;
input \cpu_mem_rdata[9] ;
input \cpu_mem_rdata[8] ;
input \cpu_mem_rdata[7] ;
input \cpu_mem_rdata[6] ;
input \cpu_mem_rdata[5] ;
input \cpu_mem_rdata[4] ;
input \cpu_mem_rdata[3] ;
input \cpu_mem_rdata[2] ;
input \cpu_mem_rdata[1] ;
input \cpu_mem_rdata[0] ;
input cpu_mem_ready;
input rst_n;
input clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire cpu_mem_valid;
wire \cpu_mem_addr[31] ;
wire \cpu_mem_addr[30] ;
wire \cpu_mem_addr[29] ;
wire \cpu_mem_addr[28] ;
wire \cpu_mem_addr[27] ;
wire \cpu_mem_addr[26] ;
wire \cpu_mem_addr[25] ;
wire \cpu_mem_addr[24] ;
wire \cpu_mem_addr[23] ;
wire \cpu_mem_addr[22] ;
wire \cpu_mem_addr[21] ;
wire \cpu_mem_addr[20] ;
wire \cpu_mem_addr[19] ;
wire \cpu_mem_addr[18] ;
wire \cpu_mem_addr[17] ;
wire \cpu_mem_addr[16] ;
wire \cpu_mem_addr[15] ;
wire \cpu_mem_addr[14] ;
wire \cpu_mem_addr[13] ;
wire \cpu_mem_addr[12] ;
wire \cpu_mem_addr[11] ;
wire \cpu_mem_addr[10] ;
wire \cpu_mem_addr[9] ;
wire \cpu_mem_addr[8] ;
wire \cpu_mem_addr[7] ;
wire \cpu_mem_addr[6] ;
wire \cpu_mem_addr[5] ;
wire \cpu_mem_addr[4] ;
wire \cpu_mem_addr[3] ;
wire \cpu_mem_addr[2] ;
wire \cpu_mem_addr[1] ;
wire \cpu_mem_addr[0] ;
wire \cpu_mem_rdata[31] ;
wire \cpu_mem_rdata[30] ;
wire \cpu_mem_rdata[29] ;
wire \cpu_mem_rdata[28] ;
wire \cpu_mem_rdata[27] ;
wire \cpu_mem_rdata[26] ;
wire \cpu_mem_rdata[25] ;
wire \cpu_mem_rdata[24] ;
wire \cpu_mem_rdata[23] ;
wire \cpu_mem_rdata[22] ;
wire \cpu_mem_rdata[21] ;
wire \cpu_mem_rdata[20] ;
wire \cpu_mem_rdata[19] ;
wire \cpu_mem_rdata[18] ;
wire \cpu_mem_rdata[17] ;
wire \cpu_mem_rdata[16] ;
wire \cpu_mem_rdata[15] ;
wire \cpu_mem_rdata[14] ;
wire \cpu_mem_rdata[13] ;
wire \cpu_mem_rdata[12] ;
wire \cpu_mem_rdata[11] ;
wire \cpu_mem_rdata[10] ;
wire \cpu_mem_rdata[9] ;
wire \cpu_mem_rdata[8] ;
wire \cpu_mem_rdata[7] ;
wire \cpu_mem_rdata[6] ;
wire \cpu_mem_rdata[5] ;
wire \cpu_mem_rdata[4] ;
wire \cpu_mem_rdata[3] ;
wire \cpu_mem_rdata[2] ;
wire \cpu_mem_rdata[1] ;
wire \cpu_mem_rdata[0] ;
wire cpu_mem_ready;
wire rst_n;
wire clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(rst_n),
    .data_i({cpu_mem_valid,\cpu_mem_addr[31] ,\cpu_mem_addr[30] ,\cpu_mem_addr[29] ,\cpu_mem_addr[28] ,\cpu_mem_addr[27] ,\cpu_mem_addr[26] ,\cpu_mem_addr[25] ,\cpu_mem_addr[24] ,\cpu_mem_addr[23] ,\cpu_mem_addr[22] ,\cpu_mem_addr[21] ,\cpu_mem_addr[20] ,\cpu_mem_addr[19] ,\cpu_mem_addr[18] ,\cpu_mem_addr[17] ,\cpu_mem_addr[16] ,\cpu_mem_addr[15] ,\cpu_mem_addr[14] ,\cpu_mem_addr[13] ,\cpu_mem_addr[12] ,\cpu_mem_addr[11] ,\cpu_mem_addr[10] ,\cpu_mem_addr[9] ,\cpu_mem_addr[8] ,\cpu_mem_addr[7] ,\cpu_mem_addr[6] ,\cpu_mem_addr[5] ,\cpu_mem_addr[4] ,\cpu_mem_addr[3] ,\cpu_mem_addr[2] ,\cpu_mem_addr[1] ,\cpu_mem_addr[0] ,\cpu_mem_rdata[31] ,\cpu_mem_rdata[30] ,\cpu_mem_rdata[29] ,\cpu_mem_rdata[28] ,\cpu_mem_rdata[27] ,\cpu_mem_rdata[26] ,\cpu_mem_rdata[25] ,\cpu_mem_rdata[24] ,\cpu_mem_rdata[23] ,\cpu_mem_rdata[22] ,\cpu_mem_rdata[21] ,\cpu_mem_rdata[20] ,\cpu_mem_rdata[19] ,\cpu_mem_rdata[18] ,\cpu_mem_rdata[17] ,\cpu_mem_rdata[16] ,\cpu_mem_rdata[15] ,\cpu_mem_rdata[14] ,\cpu_mem_rdata[13] ,\cpu_mem_rdata[12] ,\cpu_mem_rdata[11] ,\cpu_mem_rdata[10] ,\cpu_mem_rdata[9] ,\cpu_mem_rdata[8] ,\cpu_mem_rdata[7] ,\cpu_mem_rdata[6] ,\cpu_mem_rdata[5] ,\cpu_mem_rdata[4] ,\cpu_mem_rdata[3] ,\cpu_mem_rdata[2] ,\cpu_mem_rdata[1] ,\cpu_mem_rdata[0] ,cpu_mem_ready}),
    .clk_i(clk)
);

endmodule
