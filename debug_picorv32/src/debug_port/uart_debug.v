module uart_debug (
    input clk,
    input resetn,
    output reg reset_out,

    input uart_rx,
    output uart_tx,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    output reg [ 3:0] mem_wstrb,
    output reg        mem_valid,
    input [31:0]      mem_rdata,
    input             mem_ready,
    output reg        halt_req,
    input             halted,
    output reg        run_req,
    output reg        step_req,
    input             steped,
    output reg [3:0] break_addr,
    input      [31:0] break_rdata,
    output reg [31:0] break_wdata,
    output reg break_write,

    input [31:0] input_pc,
	output reg	[31:0] write_pc,
    output reg [5:0] reg_addr,

    output reg [31:0] reg_wr_data,
    input [31:0] reg_rdata,

    output reg reg_wr,
    output reg reg_valid,
    input reg_xfer_ready,
    output reg wr_pc,
    input wr_pc_ready
);
parameter CLK_FREQ=5000000;	//系统时钟频率
parameter UART_BPS=9600;		//波特率

wire [7:0] uart_rdata;
reg [7:0] uart_wdata;
reg uart_start;
wire uart_rxdone;
wire uart_txdone;
uart_recv
#(
	.CLK_FREQ	(CLK_FREQ),
	.UART_BPS	(UART_BPS)
)
u_uart_recv(
	.clk			(clk),
	.rst_n		(resetn),
	
	.uart_rxd	(uart_rx),
	.uart_data	(uart_rdata),
	.uart_done	(uart_rxdone)
);
uart_txd
#(
	.CLK_FREQ	(CLK_FREQ),
	.UART_BPS	(UART_BPS)
)
u_uart_txd(
	.clk			(clk),
	.rst_n		(resetn),

	.uart_txd	(uart_tx),
	.uart_en		(uart_start),

	.uart_data	(uart_wdata),
    .uart_tx_done (uart_txdone)
	);
reg uart_rxdone_r0;
wire uart_rxdone_pos;
always @(posedge clk) begin
    uart_rxdone_r0 <= uart_rxdone;
end
assign uart_rxdone_pos = uart_rxdone &(~uart_rxdone_r0);

reg [1:0] uart_state;
reg [3:0] uart_cnt;
reg uart_send_state;
parameter uart_send = 1'b0;
parameter uart_tx_wait = 1'b1;

parameter uart_idle = 2'b00;
parameter uart_parse = 2'b01;
parameter uart_work = 2'b10;
parameter uart_resp = 2'b11;


reg [7:0] control;
reg [31:0] response_data;

reg [31:0] mem_access_ctl;
reg [15:0] timeout_cnt;

always@(posedge clk or negedge resetn) begin
    if(!resetn) begin
        reset_out <= 1'b0;
        uart_wdata <= 8'h0;
        uart_state <= uart_idle;
        uart_cnt <= 4'h0;
        uart_start <= 1'b0;
        uart_send_state <= uart_send;
        halt_req <= 1'b0;
        run_req <= 1'b0;
        step_req <= 1'b0;
        reset_out <= 1'b1;
        mem_access_ctl <= 'd0;
        mem_addr <= 'd0;
        reg_addr <= 'd0;
        wr_pc <= 'd0;
        reg_valid <= 'b0;
        reg_wr <= 'b0;
        timeout_cnt <= 'd1;
        break_addr  <= 'd0;
        break_wdata <= 'd0;
        break_write <= 'd0;
        mem_wstrb <= 'b0;
    end
    else begin
        break_write <= 'd0;
        reset_out <= 1'b1;
        wr_pc <= wr_pc;
        mem_access_ctl <= mem_access_ctl;
        mem_addr <= mem_addr;
        halt_req <= halt_req;
        step_req <= step_req;
        reg_wr <= reg_wr;
        reg_valid <= reg_valid;
        if(halted) begin
            halt_req <= 1'b0;
        end
        step_req <= step_req&(!steped);
        if(wr_pc_ready) begin
            wr_pc <= 1'b0;
        end
        if(reg_xfer_ready) begin
            reg_valid <= 1'b0;
            reg_wr <= 'b0;
        end
        
        mem_wdata <= mem_wdata;
        case(uart_state)
        uart_idle:begin
            timeout_cnt <= 'd1;
            reset_out <= 1'b1;
            uart_cnt <= 4'h0;
            uart_start <= 1'b0;
            run_req <= 1'b0;
            mem_valid <= 1'b0;
            mem_wstrb <= 4'b0;
            if(uart_rxdone_pos) begin
                
                control <= uart_rdata;//
                uart_state <= uart_parse;
            end
        end
        uart_parse:begin
            casex(control)
            8'h68:begin//查询cpu状态
                uart_cnt <= 'd0;
                uart_state <= uart_resp;
                uart_send_state <= uart_tx_wait;
                uart_start <= 1'b1;
                uart_wdata <= control;
            end
            8'h69:begin
                if(halted) begin
                    step_req <= 1'b1;
                end
                uart_state <= uart_resp;
                uart_send_state <= uart_tx_wait;
                uart_start <= 1'b1;
                uart_wdata <= 8'h69;
            end
            8'h70:begin
                halt_req <= 1'b1;
                step_req <= 'b0;
                run_req <= 'b0;
                uart_state <= uart_resp;
                uart_send_state <= uart_tx_wait;
                uart_start <= 1'b1;
                uart_wdata <= 8'h70;
            end
            8'h71:begin
                run_req <= 1'b1;
                uart_state <= uart_resp;
                uart_send_state <= uart_tx_wait;
                uart_start <= 1'b1;
                uart_wdata <= 8'h71;
            end
            8'h72:begin//读cpu 通用寄存器
                uart_cnt <= 4'h0;
                if(uart_rxdone_pos) begin
                    reg_addr <= uart_rdata;
                    uart_state <= uart_work;
                    uart_cnt <= 4'h0;  
                end
                else begin
                    uart_state <= uart_parse;
                end
            end
            8'h73:begin//写cpu 通用寄存器
                if(uart_cnt == (4'd5)) begin
                    uart_state <= uart_work;
                end
                else begin
                    uart_state <= uart_parse;
                end
                if(uart_rxdone_pos) begin
                    if(uart_cnt == 4'd0) begin
                        reg_addr <= uart_rdata;
                    end
                    else begin
                        reg_wr_data <= {reg_wr_data[23:0],uart_rdata};
                        write_pc <= {write_pc[23:0],uart_rdata};
                    end
                    uart_cnt <= uart_cnt + 1'b1;  
                end
                else begin
                    uart_cnt <= uart_cnt;
                    reg_wr_data <= reg_wr_data;
                end
            end
            8'h74:begin//写ctl寄存器
                if(uart_cnt == (4'd4)) begin
                    uart_cnt <= 4'd0;
                    uart_state <= uart_resp;
                    uart_start <= 1'b1;
                    uart_wdata <= 8'h74;
                    uart_send_state <= uart_tx_wait;
                end
                else begin
                    uart_state <= uart_parse;
                end
                uart_cnt <= uart_rxdone_pos ? (uart_cnt + 1'b1) : uart_cnt;
                mem_access_ctl <= uart_rxdone_pos ? {mem_access_ctl[23:0],uart_rdata[7:0]}: mem_access_ctl;
            end
            8'h75:begin//读mem access ctl寄存器
                uart_state <= uart_resp;
                uart_send_state <= uart_tx_wait;
                uart_start <= 1'b1;
                response_data <= mem_access_ctl;
                uart_wdata <= 8'h75;
                uart_cnt <= 'd0;
            end
            8'h76:begin//write address register
                if(uart_cnt == (4'd4)) begin
                    uart_state <= uart_resp;
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                    uart_wdata <= 8'h76;
                end
                else begin
                    uart_state <= uart_parse;
                end
                if(uart_rxdone_pos) begin
                    mem_addr <= {mem_addr[23:0],uart_rdata};
                    uart_cnt <= uart_cnt + 1'b1;  
                end
            end
            8'h77:begin//read address register
                uart_state <= uart_resp;
                uart_send_state <= uart_tx_wait;
                response_data <= mem_addr;
                uart_start <= 1'b1;
                uart_wdata <= control;
                uart_cnt <= 'd0;
            end
            8'h78:begin//read breakpoint
                uart_cnt <= 4'h0;
                if(uart_rxdone_pos) begin
                    break_addr <= uart_rdata;
                    uart_state <= uart_work;
                    uart_cnt <= 4'h0;  
                end
                else begin
                    uart_state <= uart_parse;
                end

            end
            8'h79:begin//write breakpoint
                if(uart_cnt == (4'd5)) begin
                    uart_state <= uart_work;
                end
                else begin
                    uart_state <= uart_parse;
                end
                if(uart_rxdone_pos) begin
                    if(uart_cnt == 4'd0) begin
                        break_addr <= uart_rdata;
                    end
                    else begin
                        break_wdata <= {break_wdata[23:0],uart_rdata};
                    end
                    uart_cnt <= uart_cnt + 1'b1;  
                end
                else begin
                    uart_cnt <= uart_cnt;
                    break_wdata <= break_wdata;
                end
            end
            8'hfe:begin//状态机复位
                uart_cnt <= 'd0;
                uart_state <= uart_idle;
            end
            8'hf0:begin//外设复位
                uart_wdata <= 8'hf0;
                uart_start <= 1'b1;
                reset_out <= 1'b0;
                uart_cnt <= uart_cnt + 1'b1;
                uart_state <= uart_idle;
                reset_out <= 1'b0;
                if(uart_cnt == 4'h4) begin
                    uart_state <= uart_idle;
                end
                else begin
                    uart_state <= uart_state;
                end
            end
            8'h8x:begin//read mem
                mem_addr <= {mem_addr[31:2],2'b00};
                uart_state <= uart_work;
            end
            8'h9x:begin//write mem
                mem_addr <= {mem_addr[31:2],2'b00};
                if(uart_cnt == (4'd4)) begin
                    uart_state <= uart_work;
                end
                else begin
                    uart_state <= uart_parse;
                end
                if(uart_rxdone_pos) begin
                    mem_wdata <= {mem_wdata[23:0],uart_rdata};
                    uart_cnt <= uart_cnt + 1'b1;  
                end
            end
            default:uart_state <= uart_idle;
            endcase
        end
        uart_work:begin
            uart_cnt <= 'd0;
            casex(control)
            8'h72:begin//读cpu 通用寄存器
                uart_wdata <= 8'h72;
                uart_start <= 1'b1;
                uart_send_state <= uart_tx_wait;
                uart_state <= uart_resp;
                if(reg_addr == 6'h3f)begin
                    response_data <= input_pc;
                end
                else begin
                    response_data <= reg_rdata;
                end
            end
            8'h73:begin//写CPU通用寄存器
                uart_send_state <= uart_tx_wait;
                if(reg_addr == 6'h3f)begin
                    wr_pc <= 1'b1;
                end
                else begin
                    reg_wr <= 1'b1;
                    reg_valid <= 'b1;
                end
                uart_state <= uart_resp;
                uart_wdata <= 8'h73;
                uart_start <= 1'b1;
            end

            8'h78:begin//read breakpoint
                uart_wdata <= control;
                uart_start <= 1'b1;
                uart_send_state <= uart_tx_wait;
                uart_state <= uart_resp;
                response_data <= break_rdata;
            end
            8'h79:begin//write breakpoint
                uart_send_state <= uart_tx_wait;
                break_write <= 'd1;
                uart_state <= uart_resp;
                uart_wdata <= control;
                uart_start <= 1'b1;
            end
            8'h8x:begin//read mem
                timeout_cnt <= timeout_cnt + 1'b1;
                mem_valid <= 1'b1;
                mem_wstrb <= 4'b0;
                if(timeout_cnt == mem_access_ctl[31:16]) begin
                    mem_valid <= 1'b0;
                    mem_wstrb <= 4'b0;
                    uart_state <= uart_resp;
                    response_data <= 'd0;
                    uart_send_state <= uart_tx_wait;
                    uart_wdata <= 'hff;
                    uart_start <= 1'b1;
                end
                if(mem_ready)begin
                    mem_valid <= 1'b0;
                    mem_wstrb <= 4'b0;
                    uart_state <= uart_resp;
                    response_data <= mem_rdata;
                    uart_send_state <= uart_tx_wait;
                    mem_addr <= mem_access_ctl[0] ? (mem_addr + 'd4) : mem_addr;

                    uart_wdata <= control;
                    uart_start <= 1'b1;
                end
                else begin
                    uart_state <= uart_state;
                end
            end
            8'h9x:begin//write mem
                timeout_cnt <= timeout_cnt + 1'b1;
                mem_wstrb <= control[3:0];
                mem_valid <= 1'b1;
                if(timeout_cnt == mem_access_ctl[31:16]) begin
                    mem_valid <= 1'b0;
                    mem_wstrb <= 4'b0;
                    uart_state <= uart_resp;
                    response_data <= 'd0;
                    uart_send_state <= uart_tx_wait;
                    uart_wdata <= 'hff;
                    uart_start <= 1'b1;
                end
                if(mem_ready)begin
                    uart_wdata <= control;
                    uart_start <= 1'b1;
                    mem_valid <= 1'b0;
                    mem_wstrb <= 4'b0;
                    uart_state <= uart_resp;
                    uart_send_state <= uart_tx_wait;
                    mem_addr <= mem_access_ctl[0] ? (mem_addr + 'd4) : mem_addr;
                end
            end
            default:uart_state <= uart_idle;
            endcase
            
        end
        uart_resp:begin
            casex(control)
            8'h68:begin//查询cpu状态
                uart_start <= 1'b0;
                case(uart_send_state)
                uart_send:begin
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                end
                uart_tx_wait:begin
                    if(uart_txdone)begin
                        uart_send_state <= uart_send;
                        uart_wdata <= {2'd0,wr_pc_ready,reg_xfer_ready,wr_pc,reg_wr,reg_valid,halted};
                        uart_state <= (uart_cnt == 'd1) ? uart_idle : uart_resp;
                        uart_cnt <= uart_cnt + 1'b1;
                    end
                end
                endcase
            end
            8'h69:begin
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                    uart_cnt <= 4'h0;
                end
            end
            8'h70:begin
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                    uart_cnt <= 4'h0;
                end
            end
            8'h71:begin
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                    uart_cnt <= 4'h0;
                end
            end
            
            8'h72:begin
                uart_start <= 1'b0;
                uart_state <= uart_state;
                case(uart_send_state)
                uart_send:begin
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                end
                uart_tx_wait:begin
                    if(uart_txdone)begin
                        uart_wdata <= response_data[31:24];
                        response_data <= {response_data[23:0],8'h0};
                        uart_send_state <= uart_send;
                        uart_cnt <= uart_cnt + 1'b1;
                        if(uart_cnt == 'd4)begin
                            uart_state <= uart_idle;
                        end
                    end
                end
                endcase
            end
            8'h73:begin
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                    uart_cnt <= 4'h0;
                end
            end
            8'h74:begin//write ctl reg
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                end
            end
            8'h75:begin
                uart_start <= 1'b0;
                uart_state <= uart_state;
                case(uart_send_state)
                uart_send:begin
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                end
                uart_tx_wait:begin
                    if(uart_txdone)begin
                        uart_wdata <= response_data[31:24];
                        response_data <= {response_data[23:0],8'h0};
                        uart_send_state <= uart_send;
                        uart_cnt <= uart_cnt + 1'b1;
                        if(uart_cnt == 'd4)begin
                            uart_state <= uart_idle;
                        end
                    end
                end
                endcase
            end
            8'h76:begin
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                end
            end
            8'h77:begin
                uart_start <= 1'b0;
                uart_state <= uart_state;
                case(uart_send_state)
                uart_send:begin
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                end
                uart_tx_wait:begin
                    if(uart_txdone)begin
                        uart_send_state <= uart_send;
                        uart_wdata <= response_data[31:24];
                        response_data <= {response_data[23:0],8'd0};
                        uart_cnt <= uart_cnt + 1'b1;
                        if(uart_cnt == 'd4)begin
                            uart_state <= uart_idle;
                            uart_cnt <= 'd0;
                        end
                    end
                end
                endcase
            end

            8'h78:begin//read breakpoint
                uart_start <= 1'b0;
                uart_state <= uart_state;
                case(uart_send_state)
                uart_send:begin
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                end
                uart_tx_wait:begin
                    if(uart_txdone)begin
                        uart_wdata <= response_data[31:24];
                        response_data <= {response_data[23:0],8'h0};
                        uart_send_state <= uart_send;
                        uart_cnt <= uart_cnt + 1'b1;
                        if(uart_cnt == 'd4)begin
                            uart_state <= uart_idle;
                        end
                    end
                end
                endcase
            end
            8'h79:begin//write breakpoint
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                end
            end

            8'h8x:begin
                uart_state <= uart_state;
                uart_start <= 1'b0;
                case(uart_send_state)
                uart_send:begin
                    uart_send_state <= uart_tx_wait;
                    uart_start <= 1'b1;
                end
                uart_tx_wait:begin
                    if(uart_txdone)begin
                        uart_wdata <= response_data[31:24];
                        response_data <= {response_data[23:0],8'h0};
                        uart_send_state <= uart_send;
                        uart_cnt <= uart_cnt + 1'b1;
                        if(uart_cnt == 'd4)begin
                            uart_state <= uart_idle;
                        end
                    end
                end
                endcase
            end
            8'h9x:begin
                uart_start <= 1'b0;
                if(uart_txdone)begin
                    uart_state <= uart_idle;
                end
            end
            default:begin
                uart_state <= uart_idle;
            end
            endcase
        end
        endcase
    end
end    

endmodule