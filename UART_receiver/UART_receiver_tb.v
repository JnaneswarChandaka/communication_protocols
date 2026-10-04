
module UART_Receiver_tb();
localparam Clk_period = 40;
localparam Clks_per_bit = 217;
localparam Bit_time     = Clk_period * Clks_per_bit;


reg clk;
reg rstn;
reg serial_in;

wire [7:0] data_out;
wire data_ready;

integer rx_count;

UART_receiver #(.Clks_per_bit(Clks_per_bit))
                     dut(.clk(clk),
                         .rstn(rstn),
                         .serial_in(serial_in),
                         .data_out(data_out),
                         .data_ready(data_ready));
                         
    // Clock generation
    always #(Clk_period / 2) clk = ~clk;
    
    //UART frame transmitter
    task send_uart_frame(input [7:0] payload);
        integer i;
        begin
        serial_in = 1'b0; #(Bit_time);      // start bit
        for(i=0; i< 8; i = i+1) begin
        serial_in = payload[i];
        #(Bit_time);
        end
        
        serial_in = 1'b1; #(Bit_time);      // STOP bit
        end
    endtask
    
    
    // monitor every received byte
    
    always@(posedge clk) begin
        if(data_ready) begin
        rx_count = rx_count + 1;
        $display("RX[%0d] @ %0t ns = %h", rx_count, $time, data_out);
        end
    end


    initial begin
        clk = 1'b0;
        rstn = 1'b0;
        serial_in = 1'b1;
        rx_count = 0;
        
        
        // Reset
        #(10 * Clk_period);
        rstn = 1'b1;
        #(5 * Clk_period);
        // send two UART frames
        send_uart_frame(8'h3C);
        
        #(Bit_time);
        send_uart_frame(8'h2F);
        
         #(Bit_time);
        send_uart_frame(8'hFF);
        
        // wait for second byte to complete
        #(3 * Bit_time);
        $display("Final data_out = %h", data_out);
        
        if(rx_count == 2)
        $display("PASS: Two bytes received succesfully");
        else
        $display("FAIL: Expected 2 bytes, received %0d", rx_count);
        
        #(5 * Clk_period);
        
        #5000
        $finish;
    end
    
    initial begin
    $dumpfile("UART_Receiver_tb.vcd");
    $dumpvars(0, UART_Receiver_tb);
    end
endmodule
