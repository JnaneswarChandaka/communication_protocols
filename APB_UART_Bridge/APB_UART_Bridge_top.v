`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 08:27:16
// Design Name: 
// Module Name: APB_UART_top
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


module APB_UART_top( input clk,
                     input rstn,
                     input [31:0] PADDR,
                     input [31:0] PWDATA,
                     input PWRITE,
                     input PSEL,
                     input PENABLE,
                     output [31:0] PRDATA,
                     output PREADY);
                     
APB_UART_bridge dut( .clk(clk),
                      .rstn(rstn),
                      .PADDR(PADDR),
                      .PWDATA(PWDATA),
                      .PWRITE(PWRITE),
                      .PSEL(PSEL),
                      .PENABLE(PENABLE),
                      .PRDATA(PRDATA),
                      .PREADY(PREADY) );
endmodule
