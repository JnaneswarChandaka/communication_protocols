
module UART_tx #( parameter Clk_freq = 50000000,
                  parameter Baud_rate = 115200)
                 ( input clk,
                   input reset,
                   input [7:0] data,
                   input valid,
                   output ready,
                   output reg tx);
                   
   // Baud rate clock divider  
          
    localparam integer Clks_per_bit = Clk_freq / Baud_rate;
    
    
    // FSM states
    
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
                
      // internal registers
      
      reg [1:0] state;
      reg [$clog2(Clks_per_bit):0] clk_cnt;
      reg [2:0] bit_cnt;
      reg [7:0] shift_reg;
      
      
      assign ready = (state == IDLE);
      
      
      // UART transmitter FSM
      
      always@(posedge clk or posedge reset) begin
        if(reset) begin
            state     <= IDLE;
            clk_cnt   <= 0;
            bit_cnt   <= 0;
            shift_reg <= 8'h00;
            tx        <= 1'b1;      // UART IDLE = HIGH
        end
        else begin
        case(state)
            IDLE: begin
                tx <= 1'b1;
                if(valid) begin
                    shift_reg <= data;
                    clk_cnt <= 0;
                    state <= START;
                end
            end
            
            START: begin
                tx <= 1'b0;
                if(clk_cnt == Clks_per_bit - 1) begin
                    clk_cnt <= 0;
                    bit_cnt <= 0;
                    state <= DATA;
                end
                else begin
                    clk_cnt <= clk_cnt + 1;
                 end
            end
            
            
            DATA: begin
                tx <= shift_reg[0];
                if(clk_cnt == Clks_per_bit - 1) begin
                    clk_cnt <= 0;
                    shift_reg <= {1'b0, shift_reg[7:1]};
                    if(bit_cnt == 7)begin
                        state <= STOP;
                    end
                    else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
            
            STOP: begin
                tx <= 1'b1;
                if(clk_cnt == Clks_per_bit - 1) begin
                   clk_cnt <= 0;
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
