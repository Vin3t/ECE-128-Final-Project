`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lehigh University
// Engineer: Vincent Langford
// 
// Create Date: 12/08/2025 01:54:50 PM
// Design Name: Matrix Multiplier
// Module Name: Top_Matrix_Multiplier
// Project Name: Matrix Multiplier
// Target Devices: 
// Tool Versions: 
// Description: 
// 2x2 Matrix multiplier with robust button debounce, stage LEDs, and seven-seg display
//////////////////////////////////////////////////////////////////////////////////

module Top_Matrix_Multiplier(
    input clk,

    // Select C[i][j] to display
    input [1:0] sel,

    // 3-bit input switches for matrix element
    input  [2:0] sw_in,
    
    // Button to move to next matrix element
    input  btn_next,
    
    output [6:0] seg,
    output [3:0] an,

    // LEDs showing current stage (0-7)
    output [2:0] stage_led,

    // LED lights for 1 clock when debounce pulse occurs
    output debounce_led
);

    // Matrix elements
    reg [3:0] a,b,c,d,e,f,g,h;

    // Debounce logic using counter
    wire btn_clean;

    Debounce #(.COUNT_MAX(2_000_000)) db1 (
        .clk(clk),
        .noisy(btn_next),
        .clean(btn_clean)
    );

    reg btn_prev;
    wire btn_next_edge;

    always @(posedge clk)
        btn_prev <= btn_clean;

    assign btn_next_edge = btn_clean & ~btn_prev;
    assign debounce_led = btn_next_edge;

    // Track current matrix element
    reg [2:0] current_element;

    always @(posedge clk) begin
        if(btn_next_edge) begin
            case(current_element)
                3'd0: a <= sw_in;
                3'd1: b <= sw_in;
                3'd2: c <= sw_in;
                3'd3: d <= sw_in;
                3'd4: e <= sw_in;
                3'd5: f <= sw_in;
                3'd6: g <= sw_in;
                3'd7: h <= sw_in;
            endcase

            if(current_element == 3'd7)
                current_element <= 3'd0;
            else
                current_element <= current_element + 1;
        end
    end

    assign stage_led = current_element;

    // Multipliers
    wire [7:0] ae, bg, af, bh, ce, dg, cf, dh;

    Comb_Multi_wrapper mul_ae(.A_0(a), .B_0(e), .P_0(ae));
    Comb_Multi_wrapper mul_bg(.A_0(b), .B_0(g), .P_0(bg));
    Comb_Multi_wrapper mul_af(.A_0(a), .B_0(f), .P_0(af));
    Comb_Multi_wrapper mul_bh(.A_0(b), .B_0(h), .P_0(bh));

    Comb_Multi_wrapper mul_ce(.A_0(c), .B_0(e), .P_0(ce));
    Comb_Multi_wrapper mul_dg(.A_0(d), .B_0(g), .P_0(dg));
    Comb_Multi_wrapper mul_cf(.A_0(c), .B_0(f), .P_0(cf));
    Comb_Multi_wrapper mul_dh(.A_0(d), .B_0(h), .P_0(dh));

    // Matrix C computations
    wire [7:0] C00 = ae + bg;
    wire [7:0] C01 = af + bh;
    wire [7:0] C10 = ce + dg;
    wire [7:0] C11 = cf + dh;

    // Select output for display
    reg [7:0] selected;

    always @(*) begin
        case (sel)
            2'b00: selected = C00;
            2'b01: selected = C01;
            2'b10: selected = C10;
            2'b11: selected = C11;
        endcase
    end

    // Clamp values > 9 for display
    wire [3:0] digit = (selected > 9) ? 4'd9 : selected[3:0];

    Seven_segment_display dut(.clk(clk), .value(digit), .seg(seg), .an(an));

endmodule

// Debounce module
module Debounce(
    input clk,
    input noisy,        // raw button input
    output reg clean    // debounced output
);
    parameter COUNT_MAX = 2_000_000; // ~20 ms at 100 MHz

    reg [21:0] count = 0;
    reg state = 0;

    always @(posedge clk) begin
        if (noisy == state) begin
            count <= 0;      // no change detected
        end else begin
            count <= count + 1;
            if (count >= COUNT_MAX) begin
                state <= noisy;  // accept new value
                count <= 0;
            end
        end
        clean <= state;
    end
endmodule
