module top (
    input clk,
    input rst_n,
    input debug_rx,
    output debug_tx,
    input uart_rx,
    output uart_tx,
    input key,
    output reg[5:0] led
);
wire debug_mem_valid;
wire debug_mem_instr;
wire debug_mem_ready;
wire [31:0] debug_mem_addr;
wire [31:0] debug_mem_wdata;
wire [ 3:0] debug_mem_wstrb;
wire [31:0] debug_mem_rdata;

wire cpu_mem_valid;
wire cpu_mem_instr;
wire cpu_mem_ready;
wire [31:0] cpu_mem_addr;
wire [31:0] cpu_mem_wdata;
wire [ 3:0] cpu_mem_wstrb;
wire [31:0] cpu_mem_rdata;

wire mem_valid_bus;
wire mem_instr_bus;
reg mem_ready_bus;
wire [31:0] mem_addr_bus;
wire [31:0] mem_wdata_bus;
wire [ 3:0] mem_wstrb_bus;
wire [31:0] mem_rdata_bus;

wire halt_debug_mode;
wire debug_halt;
wire debug_halted;
wire debug_step;
wire debug_steped;
wire debug_resume;
wire [31:0] output_pc;
wire [31:0] write_pc;
wire wr_pc;
wire [5:0] reg_addr;
wire reg_wr;
wire [31:0] reg_wr_data;
wire [31:0] reg_rdata;
wire debug_reg_valid;
wire debug_reg_xfer_ready;
wire [31:0] eoi;

reg ext_irq;
wire [31:0] debug_irq;
assign debug_irq[0] = ext_irq;

reg [31:0] irq_delay;
always @(posedge clk ) begin
    if(!rst_n)begin
        irq_delay <= 'd0;
    end
    else begin
        if(eoi[0]) begin
            irq_delay <= 'd0;
        end
        else begin
            irq_delay <= {irq_delay[30:0],~key};
        end
    end
end
always @(posedge clk ) begin
    if(!rst_n) begin
        ext_irq <= 1'b0;
    end
    else begin
        ext_irq <= ext_irq;
        if(eoi[0] ) begin
            ext_irq <= 'b0;
        end
        else begin
            ext_irq <= &irq_delay;
        end
    end
end

wire reset_out;

picorv32 #(
		.PROGADDR_RESET(32'h00000000),
		.PROGADDR_IRQ(32'h0000_0010),
		.ENABLE_MUL(0),
		.ENABLE_DIV(0),
		.ENABLE_IRQ(1),
        .COMPRESSED_ISA(1),
		.ENABLE_IRQ_QREGS(1),
        .HALT_DEBUG(1)
	) picorv32_u0(
    .clk(clk),
    .resetn(rst_n),
	.trap(),

	.mem_valid(cpu_mem_valid),
	.mem_instr(cpu_mem_instr),
	.mem_ready(cpu_mem_ready),

	.mem_addr(cpu_mem_addr),
	.mem_wdata(cpu_mem_wdata),
	.mem_wstrb(cpu_mem_wstrb),
	.mem_rdata(cpu_mem_rdata),

	//debug interface
	.halt_debug_mode(1'b1),
	.halt(debug_halt),
	.halted(debug_halted),
	.step(debug_step),
	.steped(debug_steped),
	.resume(debug_resume),
	.output_pc(output_pc),
	.write_pc(write_pc),
	.wr_pc(wr_pc),
	.reg_addr(reg_addr),
	.reg_wr(reg_wr),
	.reg_wr_data(reg_wr_data),
	.reg_rdata(reg_rdata),
	.reg_valid(debug_reg_valid),
	.reg_xfer_ready(debug_reg_xfer_ready),
    .irq(debug_irq),
    .eoi(eoi)
);

mem_mux mem_mux_u(
    .clk(clk),
    .rst_n(rst_n),

    //master 0
    .mem_valid0(debug_mem_valid),
    .mem_ready0(debug_mem_ready),
    .mem_addr0(debug_mem_addr),
    .mem_wstrb0(debug_mem_wstrb),
    .mem_wdata0(debug_mem_wdata),
    .mem_rdata0(debug_mem_rdata),

    .mem_valid1(cpu_mem_valid),
    .mem_ready1(cpu_mem_ready),
    .mem_addr1(cpu_mem_addr),
    .mem_wstrb1(cpu_mem_wstrb),
    .mem_wdata1(cpu_mem_wdata),
    .mem_rdata1(cpu_mem_rdata),

    //slave 

    .mem_valid_slave(mem_valid_bus),
    .mem_ready_slave(mem_ready_bus),
    .mem_addr_slave(mem_addr_bus),
    .mem_wstrb_slave(mem_wstrb_bus),
    .mem_wdata_slave(mem_wdata_bus),
    .mem_rdata_slave(mem_rdata_bus)
);



wire sram_en;
assign sram_en = ~(mem_addr_bus[31:24] == 'd1);
wire [31:0] SRAM_RDATA;
SRAM0 SRAM0_u0(
        .dout(SRAM_RDATA[7:0]), //output [31:0] dout
        .clk(clk), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~rst_n), //input reset
        .wre(mem_wstrb_bus[0]&sram_en), //input wre
        .ad(mem_addr_bus[13:2]), //input [11:0] ad
        .din(mem_wdata_bus[7:0]) //input [31:0] din
    );
SRAM1 SRAM1_u0(
        .dout(SRAM_RDATA[15:8]), //output [31:0] dout
        .clk(clk), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~rst_n), //input reset
        .wre(mem_wstrb_bus[1]&sram_en), //input wre
        .ad(mem_addr_bus[13:2]), //input [11:0] ad
        .din(mem_wdata_bus[15:8]) //input [31:0] din
    );
SRAM2 SRAM2_u0(
        .dout(SRAM_RDATA[23:16]), //output [31:0] dout
        .clk(clk), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~rst_n), //input reset
        .wre(mem_wstrb_bus[2]&sram_en), //input wre
        .ad(mem_addr_bus[13:2]), //input [11:0] ad
        .din(mem_wdata_bus[23:16]) //input [31:0] din
    );
SRAM3 SRAM3_u0(
        .dout(SRAM_RDATA[31:24]), //output [31:0] dout
        .clk(clk), //input clk
        .oce(1'b1), //input oce
        .ce(1'b1), //input ce
        .reset(~rst_n), //input reset
        .wre(mem_wstrb_bus[3]&sram_en), //input wre
        .ad(mem_addr_bus[13:2]), //input [11:0] ad
        .din(mem_wdata_bus[31:24]) //input [31:0] din
    );
reg [31:0] slave_bus;
assign mem_rdata_bus = (mem_addr_bus[31:24] == 'd1) ? slave_bus : SRAM_RDATA;

always @(posedge clk ) begin
    if(!rst_n)begin
        mem_ready_bus <= 'd0;
        slave_bus <= 'd0;
        led <= 6'd0;
    end
    else begin
        if (mem_valid_bus)
            mem_ready_bus <= 1'b1;
        else
            mem_ready_bus <= 1'b0;
            
        if((!mem_ready_bus)&&mem_valid_bus)begin
            if(mem_wstrb_bus != 'd0)begin
                case(mem_addr_bus[31:24])
                'd1:begin
                    led <= mem_wstrb_bus[0] ? mem_wdata_bus[7:0] : led;
                end
                endcase
            end
            else begin
                case(mem_addr_bus[31:24])
                'd1:begin
                    slave_bus[5:0] <= led;
                end
                default:begin
                    slave_bus <= slave_bus;
                end
                endcase
            end
        end
    end
end

wire [3:0] break_addr;
reg [31:0] break_rdata;
wire [31:0] break_wdata;
wire break_write;

wire hard_halt;
wire breakpoint_halt;
assign debug_halt = hard_halt | breakpoint_halt;
wire breakpoint0_halt;
wire breakpoint1_halt;
reg [31:0] breakpoint0;
reg [31:0] breakpoint1; 

assign breakpoint0_halt = (breakpoint0[31:1] == output_pc[31:1]) & breakpoint0[0];
assign breakpoint1_halt = (breakpoint1[31:1] == output_pc[31:1]) & breakpoint1[0];

assign breakpoint_halt = breakpoint0_halt | breakpoint1_halt;
always @(*) begin
    case(break_addr)
    'd0:begin
        break_rdata = breakpoint0;
    end
    'd1:begin
        break_rdata = breakpoint1;
    end
    endcase
end
always @(posedge clk ) begin
    if(!rst_n)begin
        breakpoint0 <= 'd0;
        breakpoint1 <= 'd0;
    end
    else begin
        breakpoint0 <= breakpoint0;
        breakpoint1 <= breakpoint1;
        if(break_write)begin
            case(break_addr)
            'd0:begin
                breakpoint0 <= break_wdata;
            end
            'd1:begin
                breakpoint1 <= break_wdata;
            end
            endcase
        end
    end
end
uart_debug #(
		.CLK_FREQ(27000000),
		.UART_BPS(115200)
	) uart_debug_u0(
    .clk(clk),
    .resetn(rst_n),
    .reset_out(reset_out),

    .uart_rx(debug_rx),
    .uart_tx(debug_tx),
    .mem_addr(debug_mem_addr),
    .mem_wdata(debug_mem_wdata),
    .mem_wstrb(debug_mem_wstrb),
    .mem_valid(debug_mem_valid),
    .mem_rdata(debug_mem_rdata),
    .mem_ready(debug_mem_ready),
    
    .halt_req(hard_halt),
    .halted(debug_halted),
    .run_req(debug_resume),
    .step_req(debug_step),
    .steped(debug_steped),

    .break_addr(break_addr),
    .break_rdata(break_rdata),
    .break_wdata(break_wdata),
    .break_write(break_write),

    .input_pc(output_pc),
	.write_pc(write_pc),
    .reg_addr(reg_addr),

    .reg_wr_data(reg_wr_data),
    .reg_rdata(reg_rdata),
    .reg_wr(reg_wr),
    .reg_valid(debug_reg_valid),
    .reg_xfer_ready(debug_reg_xfer_ready),
    .wr_pc(wr_pc),
    .wr_pc_ready(1'b1)

);
endmodule