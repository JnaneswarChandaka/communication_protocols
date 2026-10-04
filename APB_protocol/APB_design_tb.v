
module APB_memory_tb();
reg pclk;
reg prst;
reg [5:0] paddr;
reg psel;
reg penable;
reg pwrite;
reg [31:0] pwdata;

wire pready;
wire [31:0] prdata;
wire pslverr;

APB_design dut(.pclk(pclk), .prst(prst), .paddr(paddr), .psel(psel), 
    .penable(penable), .pwrite(pwrite), .pwdata(pwdata), .pready(pready), 
    .pslverr(pslverr), .prdata(prdata));
    
    always #10 pclk = ~pclk;    // clock frequency of 100Mhz
    
initial begin
     pclk = 0;      
end

// declaring a task to reset the memory

task reset_and_initialization();
    begin
    #5 prst = 0;
    @(posedge pclk)     // at the next positive clk edge
    prst = 1;
    psel = 1'b0;
    penable = 1'bx;
    pwrite = 1'bx;
    paddr = 'bx;
    end
endtask


// declaring a task to WRITE the data

task write();
    begin
    psel = 1;
    pwrite = 1;
    //penable = 1;
    pwdata = $random;           // used to assign random values as input data
    paddr = $random;            // used to assign random values of address
    @(posedge pclk);
    penable = 1'b1;
    wait (pready == 1)
    @(posedge pclk);
    penable = 1'b0;
    $strobe("writing data into memory  data_written = %0d, address_rd = %0d", pwdata, paddr);
    end
endtask



// declaring a task to READ the data
task read();
begin
psel = 1;
pwrite =0;
@(posedge pclk);
penable = 1;

@(posedge pclk);
penable = 0;
psel = 0;
$strobe("reading data from memory data_rd = %0d, address_rd = %0d", prdata, paddr);
end
endtask

// declaring a task to WRITE and READ the DATA

task write_read();
begin
    repeat(5)           // used to repeat the same task for 5 times
    begin
    write();        // calling the task to WRITE the data
    read();         // calling the task to READ the written data
    end
end
endtask

initial begin
reset_and_initialization;       // calling the task to reset the memory 
write_read();               // calling the function to WRITE and READ the data
#80;
$finish;
$dumpfile("dump.vcd");
$dumpvars;
end

endmodule
