module mem_mux(
    input clk,
    input rst_n,

    //master 0
    input mem_valid0,
    output mem_ready0,
    input mem_instr0,
    input [31:0] mem_addr0,
    input [3:0] mem_wstrb0,
    input [31:0] mem_wdata0,
    output [31:0] mem_rdata0,

    input mem_valid1,
    output mem_ready1,
    input mem_instr1,
    input [31:0] mem_addr1,
    input [3:0] mem_wstrb1,
    input [31:0] mem_wdata1,
    output [31:0] mem_rdata1,

    //slave 

    output mem_valid_slave,
    input mem_ready_slave,
    output mem_instr_slave,
    output [31:0] mem_addr_slave,
    output [3:0] mem_wstrb_slave,
    output [31:0] mem_wdata_slave,
    input [31:0] mem_rdata_slave

);

reg [1:0] select;
assign mem_valid_slave = (select[1:0] == 'b01) ? mem_valid0 :
                            (select[1:0] == 'b10) ? mem_valid1 : 'b0;

assign mem_instr_slave = (select[1:0] == 'b01) ? mem_instr0 :
                            (select[1:0] == 'b10) ? mem_instr1 : 'b0;

assign mem_wdata_slave = (select[1:0] == 'b01) ? mem_wdata0 :
                            (select[1:0] == 'b10) ? mem_wdata1 : 'h0000_0000_0000_0000;
assign mem_wstrb_slave = (select[1:0] == 'b01) ? mem_wstrb0 :
                            (select[1:0] == 'b10) ? mem_wstrb1 : 'b0000;
assign mem_addr_slave = (select[1:0] == 'b01) ? mem_addr0 :
                            (select[1:0] == 'b10) ? mem_addr1 : 'h0000_0000_0000_0000;
assign mem_ready0 = select[0] ? mem_ready_slave : 'b0;
assign mem_ready1 = select[1] ? mem_ready_slave : 'b0;
assign mem_rdata0 = select[0] ? mem_rdata_slave : 'h0000_0000_0000_0000;
assign mem_rdata1 = select[1] ? mem_rdata_slave : 'h0000_0000_0000_0000;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        select <= 'b00;
    end
    else begin
        if(select == 'b00)begin
            if(mem_valid0)begin
                select <= 'b01;
            end
            else if(mem_valid1&(~mem_valid0)) begin
                select <= 'b10;
            end
            else begin
                select <= 'b00;
            end
        end
        else begin
            if(mem_valid_slave&mem_ready_slave) begin
                select <= 'b00;
            end
            // 新增：如果当前选中的 master 已不再有效，立即释放（避免死锁）
            else if((select == 'b01 && !mem_valid0) || (select == 'b10 && !mem_valid1)) begin
                select <= 'b00;
            end
            else begin
                select <= select;
            end
        end
    end
end
endmodule