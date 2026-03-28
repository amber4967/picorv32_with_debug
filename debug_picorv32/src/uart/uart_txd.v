module uart_txd(
					input clk,
					input rst_n,
					
					output reg [0:0] uart_txd,
					input uart_en,
					
					input [7:0] uart_data,
					output uart_tx_done
					);
parameter CLK_FREQ=5000000;	//系统时钟频率
parameter UART_BPS=9600;		//波特率
localparam BPS_CNT=CLK_FREQ/UART_BPS;	//对系统时钟计数BPS_CNT次

wire start_flag;

reg [0:0] uart_data_0;
reg [0:0] uart_data_1;
reg [0:0] tx_flag;
reg [15:0] cnt_clk;
reg [3:0] state;
reg [7:0] uart_temp;
wire start;
assign start = (~uart_data_1)&uart_data_0;
assign uart_tx_done = ~(tx_flag|uart_en|uart_data_0|uart_data_1);
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		uart_data_0	<=	1'b0;
		uart_data_1	<=	1'b0;
	end
	else begin
		uart_data_0	<=	uart_en;
		uart_data_1	<=	uart_data_0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		tx_flag	<=	1'b0;
	else if(start) begin
					uart_temp	<=	uart_data;
					tx_flag	<=	1'b1;
			end
			else
				if((state == 4'd9)&&(cnt_clk == BPS_CNT - 1))
					begin
						tx_flag	<=	1'b0;
						uart_temp	<=	8'd0;
					end
	else begin
		tx_flag	<=	tx_flag;
		uart_temp	<=	uart_temp;
		end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state	<=	4'b0;
		cnt_clk	<=	16'b0;
		end
	else if(tx_flag) begin
		if(cnt_clk < BPS_CNT -1) begin
			cnt_clk	<=	cnt_clk + 1'b1;
			state	<=	state;
			end
		else begin
			cnt_clk	<=	16'b0;
			state	<=	state	+ 1'b1;
			end
		end
	else begin
		cnt_clk	<=	16'b0;
		state	<=	4'b0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		uart_txd	<=	1'b1;
	end
	else if(tx_flag) begin
		case(state)
			4'd0:uart_txd	<=	1'b0;
			4'd1:uart_txd	<=	uart_temp[0];
			4'd2:uart_txd	<=	uart_temp[1];
			4'd3:uart_txd	<=	uart_temp[2];
			4'd4:uart_txd	<=	uart_temp[3];
			4'd5:uart_txd	<=	uart_temp[4];
			4'd6:uart_txd	<=	uart_temp[5];
			4'd7:uart_txd	<=	uart_temp[6];
			4'd8:uart_txd	<=	uart_temp[7];
			4'd9:uart_txd	<=	1'b1;
			default:;
		endcase
	end
	else
		uart_txd	<=	1'b1;
end
endmodule