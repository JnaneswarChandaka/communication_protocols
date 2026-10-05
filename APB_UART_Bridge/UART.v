`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 08:04:07
// Design Name: 
// Module Name: UART_tx
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


module UART(input clk, 
               input rstn,
               input [7:0] tx_data,
               input tx_write,
               output reg [7:0] rx_data,
               output reg rx_ready,
               output reg tx_busy);
reg [7:0] tx_reg;

always@(posedge clk or negedge rstn) begin
    if(!rstn)begin
        tx_reg <= 8'h0;
        rx_data <= 8'h0;
        rx_ready <= 1'b0;
        tx_busy <= 1'b0;
    end
       
    else begin
        rx_ready <= 1'b0;
        if(tx_write)begin
            tx_reg <= tx_data;
            tx_busy <= 1'b1;
            rx_data <= tx_data;
            rx_ready <= 1'b1;
            tx_busy <= 1'b0;
        end
    end
end
endmodule
