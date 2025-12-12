`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2025 05:14:18 PM
// Design Name: 
// Module Name: Combinational_multi
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


module Combinational_multi(
    input [3:0] A,
    input [3:0] B,
    output [7:0] P
);
    assign P = A * B;  
endmodule

