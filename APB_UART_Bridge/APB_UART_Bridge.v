`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 08:04:07
// Design Name: 
// Module Name: APB_UART_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////





module APB_UART_bridge(input clk,
                          input rstn,
                          input [31:0] PADDR,
                          input [31:0] PWDATA,
                          input PWRITE,
                          input PSEL,
                          input PENABLE,
                          output reg [31:0] PRDATA,
                          output reg PREADY);
 
reg [7:0] tx_data;
reg tx_write;
wire [7:0] rx_data;
wire tx_busy;
wire rx_ready;

UART uart_inst(.clk(clk),
                .rstn(rstn),
                .tx_data(tx_data),
                .tx_write(tx_write),
                .rx_data(rx_data),
                .rx_ready(rx_ready),
                .tx_busy(tx_busy));
                
always@(posedge clk or negedge rstn)begin
    if(!rstn) begin
        PREADY <= 1'b0;
        PRDATA <= 32'h0;
        tx_data <= 8'h0;
        tx_write <= 1'b0;
    end
    
    else begin
        PREADY <= 1'b0;
        tx_write <= 1'b0;
        if(PSEL && PENABLE) begin
            PREADY <= 1'b1;
            if(PWRITE) begin
                case(PADDR[7:0])
                    8'h00: begin
                    tx_data <= PWDATA[7:0];
                    tx_write <= 1'b1;
                    end
                endcase
            end
            else begin
                case(PADDR[7:0])
                    8'h04: PRDATA <= {24'h0, rx_data};  // RX data
                    8'h08: PRDATA <= {30'h0, tx_busy, rx_ready};
                    default: PRDATA <= 32'h0;
                endcase
            end
        end
    end
end
endmodule
