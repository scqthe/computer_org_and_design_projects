//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University, University Park
// Engineer: Anand Rajan
// 
// Create Date: 02/04/2021 10:04:14 PM
// Design Name: Restoring Division Algorithm
// Module Name: top
// Project Name: Lab 1
// Target Devices: XC7Z010--1CLG400C
// Tool Versions: 
// Description: The project aims to perform unsigned binary division by implementing a restoring division algorithm.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module testbench();

    reg clrn_tb;
    reg clk_tb;
    reg start_tb; // Hardcoded signals
    
    wire busy_tb;
    wire ready_tb;
    wire[5:0] count_tb; // Derived signals
    
    reg [31:0] a_tb;
    reg [15:0] b_tb;
    wire [31:0] qout_tb;
    wire [15:0] r_tb; // All input/outputs
    
    top dut(clk_tb, clrn_tb, start_tb, a_tb, b_tb, qout_tb, r_tb, busy_tb, ready_tb, count_tb); // Initializing an instance of top
    
    initial begin
        clrn_tb = 0;
        start_tb = 0;     
        clk_tb = 1;
        
        // Fix the values of the inputs
        a_tb <= 32'b01001100011111110010001010001010;
        b_tb <= 16'b0110101000001110;
         
         
         // Signals take value
        #5 clrn_tb = 1;
        #0 start_tb = 1;
        #10 start_tb = 0;
        
        
        // CLRN shuts off to reset circuit
        #335 clrn_tb = 0;
        #0 start_tb = 0;
        
        // New values for inputs are provided while CLRN is disabled
        a_tb <= 32'b00000000111111111111111100000000;
        b_tb <= 16'b0000000000000100;
        
        // CLRN starts up again, and division can recontinue - note that CLRN and start must begin before clk posedge
        #5 clrn_tb = 1;
        #0 start_tb = 1;
        #10 start_tb = 0;
    end   
    always begin
        #5;
        clk_tb = ~clk_tb; // Clock Rule
    end

endmodule
