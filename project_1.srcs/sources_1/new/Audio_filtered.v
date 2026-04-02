`timescale 1ns / 1ps


module Audio_filtered(
    input         CLK100MHZ,    // System Clock
    input         CPU_RESETN,   // Active Low Reset
    
    // Microphone Signals
    output reg    M_CLK,        // Mic Clock (approx 2.4 MHz)
    input         M_DATA,       // Mic Data (PDM)
    output        M_LRSEL,      // Left/Right Select (Set to 0)

    // Audio Output Signals
    output reg    AUD_PWM,      // PWM Output to Audio Jack
    output        AUD_SD        // Shutdown Control (1 = Active)
    );

    // =========================================================================
    // 1. System Parameters
    // =========================================================================
    parameter CLK_DIV_MAX = 20;       // For 2.4 MHz M_CLK
    parameter DECIMATION_RATE = 64;   // Yields ~37.5 kHz Sample Rate
    
    wire reset = ~CPU_RESETN;   
    assign M_LRSEL = 1'b0;        
    assign AUD_SD = 1'b1;         

    // =========================================================================
    // 2. Clock Generation & Edge Detection
    // =========================================================================
    reg [5:0] clk_cnt = 0;
    reg m_clk_old = 0;
    wire m_clk_rising = (m_clk_old == 0 && M_CLK == 1);

    always @(posedge CLK100MHZ) begin
        if (reset) begin
            clk_cnt <= 0;
            M_CLK <= 0;
            m_clk_old <= 0;
        end else begin
            m_clk_old <= M_CLK;
            if (clk_cnt >= CLK_DIV_MAX) begin
                clk_cnt <= 0;
                M_CLK <= ~M_CLK;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end

    // =========================================================================
    // 3. 3rd-Order CIC Filter (Bit Growth: 1 + 3 * log2(64) = 19 bits)
    // =========================================================================
    // Convert PDM 0/1 to Signed -1/+1 to naturally kill DC offset
    wire signed [1:0] pdm_val = M_DATA ? 2'sd1 : -2'sd1;

    // Integrator Registers (Running at 2.4 MHz)
    reg signed [18:0] int1=0, int2=0, int3=0;
    
    // Comb Registers (Running at 37.5 kHz)
    reg signed [18:0] int3_d=0, comb1=0, comb1_d=0, comb2=0, comb2_d=0, comb3=0;
    
    reg [5:0] dec_cnt = 0;
    reg sample_valid = 0;
    reg signed [15:0] pcm_sample = 0; // Truncated high-res output

    always @(posedge CLK100MHZ) begin
        if (reset) begin
            int1 <= 0; int2 <= 0; int3 <= 0;
            int3_d <= 0; comb1 <= 0; comb1_d <= 0; comb2 <= 0; comb2_d <= 0; comb3 <= 0;
            dec_cnt <= 0;
            sample_valid <= 0;
            pcm_sample <= 0;
        end else begin
            sample_valid <= 1'b0; // Default state
            
            if (m_clk_rising) begin
                // --- INTEGRATOR STAGES ---
                int1 <= int1 + pdm_val;
                int2 <= int2 + int1;
                int3 <= int3 + int2;
                
                // --- DECIMATION ---
                dec_cnt <= dec_cnt + 1;
                if (dec_cnt == DECIMATION_RATE - 1) begin
                    dec_cnt <= 0;
                    
                    // --- COMB STAGES ---
                    int3_d <= int3;
                    comb1 <= int3 - int3_d;
                    
                    comb1_d <= comb1;
                    comb2 <= comb1 - comb1_d;
                    
                    comb2_d <= comb2;
                    comb3 <= comb2 - comb2_d;
                    
                    // Truncate the 19-bit CIC output down to standard 16-bit signed audio
                    // We drop the lowest 3 noise bits (shift right by 3)
                    pcm_sample <= comb3[18:3];
                    sample_valid <= 1'b1;
                end
            end
        end
    end

    // =========================================================================
    // 4. 32-Tap FIR Filter (Placeholder for your MATLAB coefficients)
    // =========================================================================
    reg signed [15:0] delay_line [0:31];
    reg signed [15:0] filtered_pcm = 0;
    integer i;

    // A simple 32-tap unweighted moving average for the baseline.
    // Replace this block with your weighted MATLAB coefficients!
    always @(posedge CLK100MHZ) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                delay_line[i] <= 0;
            end
            filtered_pcm <= 0;
        end else if (sample_valid) begin
            delay_line[0] <= pcm_sample;
            for (i = 1; i < 32; i = i + 1) begin
                delay_line[i] <= delay_line[i-1];
            end
            
            // Temporary Boxcar FIR: Summing 32 samples and dividing by 32 (shift right 5)
            filtered_pcm <= (
            (pcm_sample *2 ) +
                (delay_line[0] * 0) + 
(delay_line[1] * 0) + 
(delay_line[2] * -1) + 
(delay_line[3] * -1) + 
(delay_line[4] * 1) + 
(delay_line[5] * 2) + 
(delay_line[6] * 0) + 
(delay_line[7] * -4) + 
(delay_line[8] * -3) + 
(delay_line[9] * 6) + 
(delay_line[10] * 9) + 
(delay_line[11] * -5) + 
(delay_line[12] * -21) + 
(delay_line[13] * -5) + 
(delay_line[14] * 49) + 
(delay_line[15] * 102) + 
(delay_line[16] * 100) + 
(delay_line[17] * 49) + 
(delay_line[18] * -5) + 
(delay_line[19] * -21) + 
(delay_line[20] * -5) + 
(delay_line[21] * 9) + 
(delay_line[22] * 6) + 
(delay_line[23] * -3) + 
(delay_line[24] * -4) + 
(delay_line[25] * 0) + 
(delay_line[26] * 2) + 
(delay_line[27] * 1) + 
(delay_line[28] * -1) + 
(delay_line[29] * -1) + 
(delay_line[30] * 0) + 
(delay_line[31] * 0)
)>>> 8;

        end
    end

    // =========================================================================
    // 5. 10-Bit High-Res PWM Audio Output
    // =========================================================================
    // Using 10 bits gives us 1024 levels of volume (vastly better than 128)
    // PWM Frequency = 100MHz / 1024 = 97.6 kHz
    reg [9:0] pwm_cnt = 0;
    wire [9:0] unsigned_audio;

    // Convert the 16-bit SIGNED filtered audio into a 10-bit UNSIGNED value for PWM
    // Take the top 10 bits and flip the Most Significant Bit (MSB) to center it at 512
    assign unsigned_audio = { ~filtered_pcm[15], filtered_pcm[12:4] };

    always @(posedge CLK100MHZ) begin
        if (reset) begin
            pwm_cnt <= 0;
            AUD_PWM <= 0;
        end else begin
            pwm_cnt <= pwm_cnt + 1;
            
            if (pwm_cnt < unsigned_audio) 
                AUD_PWM <= 1'b1;
            else 
                AUD_PWM <= 1'b0;
        end
    end

endmodule

