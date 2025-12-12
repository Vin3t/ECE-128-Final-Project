`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2025 04:04:31 PM
// Design Name: 
// Module Name: Top_Matrix_Multiplier_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_Matrix_Multiplier_tb;

    reg clk;
    reg [2:0] sw_in;
    reg btn_next;
    reg [1:0] sel;

    // Internal arrays to store matrix A and B inputs
    reg [3:0] A [0:1][0:1];
    reg [3:0] B [0:1][0:1];

    reg [7:0] C00, C01, C10, C11;
    reg [7:0] C_selected;

    Top_Matrix_Multiplier dut(
        .clk(clk),
        .sw_in(sw_in),
        .btn_next(btn_next),
        .sel(sel)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to input a matrix element and wait one clock
    task input_element(input [3:0] value, output [3:0] target);
        begin
            sw_in = value[2:0]; // 3-bit switches
            btn_next = 1; @(posedge clk);
            btn_next = 0; @(posedge clk);
            target = value;
        end
    endtask

    initial begin
        // Initialize
        sw_in = 0; btn_next = 0; sel = 0;

        // Input matrix A: [1 2;3 4]
        input_element(4'd1, A[0][0]); // a
        input_element(4'd2, A[0][1]); // b
        input_element(4'd3, A[1][0]); // c
        input_element(4'd4, A[1][1]); // d

        // Input matrix B: [1 0;0 1]
        input_element(4'd1, B[0][0]); // e
        input_element(4'd0, B[0][1]); // f
        input_element(4'd0, B[1][0]); // g
        input_element(4'd1, B[1][1]); // h

        // Compute C matrix
        C00 = A[0][0]*B[0][0] + A[0][1]*B[1][0];
        C01 = A[0][0]*B[0][1] + A[0][1]*B[1][1];
        C10 = A[1][0]*B[0][0] + A[1][1]*B[1][0];
        C11 = A[1][0]*B[0][1] + A[1][1]*B[1][1];

        // Cycle through positions
        sel = 2'b00; #50;  // C00
        sel = 2'b01; #50;  // C01
        sel = 2'b10; #50;  // C10
        sel = 2'b11; #50;  // C11

        $finish;
    end

    // Update selected value based on sel
    always @(*) begin
        case(sel)
            2'b00: C_selected = C00;
            2'b01: C_selected = C01;
            2'b10: C_selected = C10;
            2'b11: C_selected = C11;
        endcase
    end

    // Monitor
    initial begin
        $display("Time | sel | C_value");
        $monitor("%4t | %b  | %d", $time, sel, C_selected);
    end

endmodule
