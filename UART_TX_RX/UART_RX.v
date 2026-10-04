
module UART_rx #( parameter Clk_freq = 50000000,
                  parameter Baud_rate = 115200)
                  (input clk,
                  input reset,
                  input rx,
                  output reg [7:0] data_out,
                  output reg data_valid);
                  
  // baud rate timing constants
  
  localparam integer clks_per_bit = Clk_freq / Baud_rate;
  localparam integer clks_half_bit = clks_per_bit / 2;
  
  
  // FSM states
  
  localparam IDLE = 2'b00;
  localparam START = 2'b01;
  localparam DATA = 2'b10;
  localparam STOP = 2'b11;
  
  
  // 2  - stage synchronization
  reg rx_sync0;
  reg rx_sync1;
  
  always@(posedge clk or posedge reset) begin
    if (reset) begin
        rx_sync0 <= 1'b1; // IDLE = HIGH
        rx_sync1 <= rx_sync0;
    end
    end 
                     
    wire rx_s = rx_sync1;
    
    
    // Receiver registers - No inline initilizers
    
    reg [1:0] state;
    reg [$clog2(clks_per_bit):0] clk_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    
    
    // UART receiver FSM
    
    always@(posedge clk or posedge reset) begin
        if(reset) begin
        state <= IDLE;
        clk_cnt <= 0;
        bit_cnt <= 0;
        shift_reg <= 8'b00;
        data_out <= 8'b00;
        data_valid <= 1'b0;
        end
        else begin
        data_valid <= 1'b0;     // default: pulse low
        case(state)
            IDLE: begin
                if (!rx_s)begin
                    clk_cnt <= 0;
                    state <= START;
                end
            end
                
               START: begin
                if(clk_cnt == clks_half_bit - 1) begin
                    if(!rx_s) begin
                        clk_cnt <= 0;
                        bit_cnt <= 0;
                        state <= DATA;
                    end
                    else begin
                        state <= IDLE;      // false glitch
                    end
                  end
                  else begin
                    clk_cnt <= clk_cnt + 1;
                  end
               end 
               
              
              DATA: begin
                if(clk_cnt == clks_per_bit - 1) begin
                   clk_cnt <= 0;
                shift_reg <= {rx_s, shift_reg[7:1]};
                    if(bit_cnt == 7) 
                      state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1;
                end
              end 
              
              
              STOP: begin
                if(clk_cnt == clks_per_bit - 1) begin
                    clk_cnt <= 0;
                    if (rx_s) begin
                        data_out <= shift_reg;
                        data_valid <= 1'b1;
                    end
                    state <= IDLE;
                end
              else begin
                clk_cnt <= clk_cnt + 1;
              end
            end
              
              
              default: state <= IDLE;
         endcase
        end
    end
endmodule
