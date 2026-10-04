
module UART_receiver #(parameter integer Clks_per_bit = 217)
                       (input clk,
                       input rstn,
                       input serial_in,
                       output reg [7:0] data_out,
                       output reg data_ready);

// FSM states

localparam IDLE = 2'd0;
localparam START = 2'd1;
localparam RECV = 2'd2;
localparam STOP = 2'd3;


reg [1:0] state;
reg [7:0] clk_cnt;
reg [2:0] bit_index;
reg [7:0] data_buf;


reg rx_meta;
reg rx_sync;

// 2 - stage synchronization
// this makes the data to delay for 2 clk cycles as they act as D flipflops by shifting
always@(posedge clk) begin
    rx_meta <= serial_in;
    rx_sync <= rx_meta;
end


// UART receiver FSM

always@(posedge clk) begin
    if(!rstn) begin
        state     <= IDLE;
        clk_cnt   <= 8'd0;
        bit_index <= 3'd0;
        data_buf  <= 8'd0;
        data_out  <= 8'd0;
        data_ready <= 1'b0;
    end
    else begin
    data_ready <= 1'b0;
        case(state)
            IDLE: begin
                clk_cnt <= 8'd0;
                bit_index <= 3'd0;
                
                if(rx_sync == 1'b0)
                state <= START;
            end
            
            START: begin
                if(clk_cnt == (Clks_per_bit >> 1)) begin
                clk_cnt <= 8'd0;
                
                    if(rx_sync == 1'b0)
                    state <= RECV;
                    else
                    state <= IDLE;
                end
                
                else 
                clk_cnt <= clk_cnt + 1'b1;
            end
            
            RECV: begin
                if(clk_cnt == Clks_per_bit -1) begin
                clk_cnt <= 8'd0;
                
                // UART sends LSB first
                data_buf[bit_index] <= rx_sync;
                    if(bit_index == 3'd7) begin
                    bit_index <= 3'd0;
                    state <= STOP;
                    end
                    
                    else begin
                    bit_index <= bit_index + 1'b1;
                    end
                end
                
                else 
                clk_cnt <= clk_cnt + 1'b1; 
            end
            
            STOP: begin
                if(clk_cnt == Clks_per_bit - 1) begin
                    clk_cnt <= 8'd0;
                    data_out <= data_buf;
                    data_ready <= 1'b1;
                    state <= IDLE;
                end   
                         
                else
                clk_cnt <= clk_cnt + 1'b1;
            end
            
            default: 
            state <= IDLE;
        endcase
    end
end
endmodule
