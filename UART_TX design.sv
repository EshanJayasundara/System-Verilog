module uart_tx #(
    parameter   CLOCKS_PER_PULSE = 4,
                BITS_PER_WORD    = 8,
                PACKET_SIZE      = BITS_PER_WORD + 5,
                W_OUT            = 16,

    localparam NUM_WORDS = W_OUT/BITS_PER_WORD
)(
    input  logic clk, rstn, s_valid,
    input  logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] s_data,
    output logic tx, s_ready   
);
    localparam END_BITS = PACKET_SIZE - BITS_PER_WORD - 1;
    logic [NUM_WORDS-1:0][PACKET_SIZE-1:0]      s_packets;
    logic [NUM_WORDS*PACKET_SIZE     -1:0]      m_packets;

    genvar n;
    for (n=0; n<NUM_WORDS; n++)
        assign s_packets[n] = {~(END_BITS'(0)), s_data[n], 1'b0}; // what is the meaning of ~ / is it negation

    assign tx = m_packets[0];

    logic [$clog2(NUM_WORDS*PACKET_SIZE)-1:0] c_pulses;
    logic [$clog2(CLOCKS_PER_PULSE)     -1:0] c_clocks;

    enum {IDLE, SEND} state; // state machine

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state     <= IDLE;
            m_packets <= '1;
            {c_pulses, c_clocks} <= 0;
        end else begin
            case (state)
                IDLE :  if (s_valid) begin
                            state     <= SEND;
                            m_packets <= s_packets;
                        end
                SEND :  if (c_clocks == CLOCKS_PER_PULSE-1) begin
                            c_clocks <= 0;
                            if (c_pulses == NUM_WORDS*PACKET_SIZE-1) begin
                                m_packets <= '1;
                                c_pulses  <= 0;
                                state     <= IDLE;
                            end else begin
                                c_pulses  <= c_pulses + 1;
                                m_packets <= (m_packets >> 1);
                            end
                        end else c_clocks <= c_clocks + 1;
            endcase
        end
    end
    assign s_ready = (state == IDLE);
endmodule