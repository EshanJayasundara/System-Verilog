module uart_tx_tb;
    `timescale 1ns/1ps

    parameter   CLOCKS_PER_PULSE = 4,
                BITS_PER_WORD    = 8,
                PACKET_SIZE      = BITS_PER_WORD + 5,
                W_OUT            = 16,
                CLOCK_PERIOD     = 10;

    localparam NUM_WORDS = W_OUT/BITS_PER_WORD;

    logic clk = 0, rstn = 0, s_valid, s_ready, tx;
    logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] s_data;
    
    uart_tx #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
        .BITS_PER_WORD(BITS_PER_WORD),
        .PACKET_SIZE(PACKET_SIZE),
        .W_OUT(W_OUT)
    ) dut (.*);

    //clock generation
    initial forever #(CLOCK_PERIOD/2) clk <= !clk;

    initial begin
        $dumpvars(0,dut);
        $dumpfile("dump.vcd");

        #5 rstn <= 1;
        wait(s_ready);
        #5 s_data  <= 'd127; @(posedge clk); #1 s_valid <= 1;
        @(posedge clk); #1 s_valid <= 0;
        wait(s_ready);
        $finish();
    end 
endmodule