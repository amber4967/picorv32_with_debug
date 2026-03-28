module uart_recv(
		input clk,
		input rst_n,
		
		input uart_rxd,
		output reg [7:0]	uart_data,
		output reg uart_done
	);
	
parameter CLK_FREQ=5000000;	//系统时钟频率
parameter UART_BPS=9600;		//波特率
localparam BPS_CNT=CLK_FREQ/UART_BPS;	//对系统时钟计数BPS_CNT次

wire start_flag;

reg [0:0] 	uart_data_0;
reg [0:0] 	uart_data_1;
reg [15:0]	cnt_clk;	//系统时钟计数器
reg [3:0]	state;	//接收数据计数器
reg [0:0]	rx_flag;
//reg [7:0]	rx_data;

assign start_flag	=	uart_data_1&(~uart_data_0);

//对UART接收端口的数据延迟两个时钟周期的脉冲信号
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		uart_data_0	<=	1'b0;
		uart_data_1	<=	1'b0;
	end
	else begin
		uart_data_0	<= uart_rxd;
		uart_data_1	<=	uart_data_0;
	end
end

//当脉冲信号start_flag到达时，进入接收过程
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rx_flag <= 1'b0;
	else begin
		if(start_flag)
			rx_flag	<=	1'b1;
		else if((state == 4'd9)&&(cnt_clk == BPS_CNT/2))
			rx_flag	<=	1'b0;
		else
			rx_flag	<=	rx_flag;
	end
end

//进入接收过程后，启动系统时钟计数器和接收数据计数器
always@(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		cnt_clk	<=	16'd0;
		state	<=	4'd0;
	end
	else if(rx_flag) begin
			if(cnt_clk < BPS_CNT -1'b1) begin
				cnt_clk	<=	cnt_clk + 1'b1;
				state		<=	state;
				end
			else begin
				state <=	state + 1'b1;
				cnt_clk <=	16'b0;
				end
		end
	else begin
		cnt_clk	<=	16'b0;
		state <=	4'b0;
	end
		
end

//接收数据具体过程
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		uart_data <=	8'b0;
	else if(rx_flag)
			if(cnt_clk == BPS_CNT/2) begin
//				case(state)
//					4'd1:uart_data[0]	<=	uart_rxd;
//					4'd2:uart_data[1]	<=	uart_rxd;
//					4'd3:uart_data[2]	<=	uart_rxd;
//					4'd4:uart_data[3]	<=	uart_rxd;
//					4'd5:uart_data[4]	<=	uart_rxd;
//					4'd6:uart_data[5]	<=	uart_rxd;
//					4'd7:uart_data[6]	<=	uart_rxd;
//					4'd8:uart_data[7]	<=	uart_rxd;
//					default:;
//				endcase
				if((state>0)&&(state<9)) begin
					uart_data	<=	{uart_rxd,uart_data[7:1]};
				end
				else
					uart_data	<=	uart_data;
			end
			else
				uart_data	<=	uart_data;
	else begin
		uart_data	<=	8'd0;
	end
end
//数据接收完成，准备发送标志位
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		uart_done	<=	1'b0;
		//uart_data	<=	8'd0;
	end
	else if(state==4'd9) begin
		uart_done	<=	1'b1;
	//	uart_data	<=	rx_data;
	end
	else begin
		//uart_data	<=	8'd0;
		uart_done	<=	1'b0;
	end
end
endmodule