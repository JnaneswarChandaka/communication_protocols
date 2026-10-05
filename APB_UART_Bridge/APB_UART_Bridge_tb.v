`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 08:04:31
// Design Name: 
// Module Name: APB_UART_bridge_tb
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


module APB_UART_bridge_tb();

reg clk = 0;
reg rstn;
reg [31:0] PADDR;
reg [31:0] PWDATA;
reg PWRITE;
reg PSEL;
reg PENABLE;
wire [31:0] PRDATA;
wire PREADY;


APB_UART_top dut( .clk(clk),
                      .rstn(rstn),
                      .PADDR(PADDR),
                      .PWDATA(PWDATA),
                      .PWRITE(PWRITE),
                      .PSEL(PSEL),
                      .PENABLE(PENABLE),
                      .PRDATA(PRDATA),
                      .PREADY(PREADY) );
                      
always #10 clk = ~clk;

initial begin
    rstn = 0;
    PADDR = 0;
    PWDATA = 0;
    PWRITE = 0;
    PSEL = 0;
    PENABLE = 0;

    #100
    rstn = 1;
    
    // write Tx_register
    apb_write(32'h00, 32'hA5);
    
    // Read Rx_data
    apb_read(32'h04);
    
    // Read STATUS register
    apb_read(32'h08);
    
    // Second transfer
    apb_write(32'h00, 32'h3C);
    apb_read(32'h04);
    apb_read(32'h08);
    
    #100;
    $finish;
end

task apb_write(input [31:0] addr, input [31:0] data);
begin
    @(posedge clk);
    PADDR   = addr;
    PWDATA  = data;
    PWRITE  = 1;
    PSEL    = 1;
    PENABLE = 0;
    
    @(posedge clk);
    PENABLE = 1;
    @(posedge clk);
    PSEL = 0;
    PENABLE = 0;
    $display("APB WRITE : ADDR = %h, DATA = %h", addr, data);
end
endtask


task apb_read(input [31:0] addr);
begin
    @(posedge clk);
    PADDR = addr;
    PWRITE = 0;
    PSEL = 1;
    PENABLE = 0;
    
    @(posedge clk);
    PENABLE = 1;
    repeat(2) @(posedge clk);
    
    $display("APB READ : ADDR = %h DATA = %h", addr, PRDATA);
    
    PSEL = 0;
    PENABLE = 0;
end
endtask

initial begin
$dumpfile("APB_UART_dump.vcd");
$dumpvars();
end
endmodule
