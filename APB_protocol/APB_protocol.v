//

module APB_design(pclk, prst, psel, penable, pwrite, pwdata, paddr, pready, pslverr, prdata, temp);
input pclk;
input prst;               // active LOW reset
input psel;               
input penable;
input pwrite;           // peripheral write
input [31:0] pwdata;    // 32 - bit input data
input [5:0] paddr;      // 6 - bit address

// 5 - bits are enough for the address but if a 6 - bit address is assigned it triggers a error

output reg pready;              // peripheral ready signal
output reg pslverr;             // error signal
output reg [31:0] prdata;          // peripheral 32-bit output read data
output reg [31:0] temp;         // used to show which value is being stored at that instant of time


// create a memory to store the data
reg [31:0] memory [31:0];

// these are used to represent the states in the FSM

parameter [1:0] idle = 2'b00;
parameter [1:0] setup = 2'b01;
parameter [1:0] access = 2'b10;


// store the present and the next state of the FSM

reg [1:0] present_state, next_state;


// we are using asynchronous  negative edge reset here

always@(posedge pclk or negedge prst) begin
if(!prst) begin
present_state <= idle;
next_state <= present_state;
end
else present_state <= next_state;
end


// FSM states logic

always@(*) begin
case(present_state)

// IDLE state
idle: begin
    next_state <= setup;
    end

// SETUP state
setup: begin
    if(psel) begin
        next_state <= access;
        end
        else begin
        next_state <= idle;
        end
    end


access: 
begin
    pready = 1;
    if(penable & pwrite)            // WRITE operation condition
    
    // if both penable and the pwrite are logic 1
    // penable HIGH is used to represent that WRITE operation is in process
    begin
        if(paddr > 31)        // checking the address value
            pslverr <= 1;      // if the address exceeds 32 bits it would raise an error
        else
            begin  
                // the desired data is written in the memory of the given address
                memory[paddr] <= pwdata;
                // the same data is stored in the temporary memory created
                temp <= memory[paddr];
                pslverr <= 0;
            end
    end
    
    // Penable LOW represents that the WRITE operation is completed 
    // READ openration is in process
    else if(penable & !pwrite)          
    begin
    // READ the data in the memory address
        prdata <= memory[paddr];
    end
    
    else if(!penable) begin
    next_state <= setup;
     //pready <= 0;
    end
end
endcase

end
endmodule
