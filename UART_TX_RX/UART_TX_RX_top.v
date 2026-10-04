

module UART_top #( parameter Clk_freq = 50000000,
                   parameter Baud_rate = 115200)
                  ( input clk,
                  input reset,
                  input [7:0] tx_data,  // byte to sent
                  input tx_valid,       // pulse high for 1+ cycles when tx_data valid
                  output tx_ready,      // high when TX is IDLE (ready to accept)
                  
                  // Receive interface
                  output [7:0] rx_data,     // receive byte
                  output  rx_valid);        // 1-cycle pulse when rx_data is valid
                  
      // Internal serial loopback wire
      wire serial_line;             // TX serial output -> RX serial input
      
      
      // UART transmitter
      
      UART_tx #(.Clk_freq(Clk_freq),
      .Baud_rate(Baud_rate))
      u_tx( .clk(clk), 
      .reset(reset), 
      .data(tx_data), 
      .valid(tx_valid), 
      . ready(tx_ready), 
      .tx(serial_line));
      
      UART_rx #(.Clk_freq(Clk_freq),
      .Baud_rate(Baud_rate))
      u_rx(.clk(clk), 
      .reset(reset), 
      .rx(serial_line),
      .data_out(rx_data), 
      .data_valid(rx_valid));
      
      
endmodule
