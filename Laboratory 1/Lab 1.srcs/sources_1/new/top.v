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
module top(input clk, input clrn, input start, input [31:0] a, input [15:0] b,
          output [31:0] qout, output [15:0] r, output reg busy, output reg ready, output[5:0] count
          );

    reg[16:0] sub_output = 17'b0;
    reg[16:0] lhs, rhs;
    reg[15:0] rmux_output = 16'b0;
    reg[15:0] reg_r, reg_b;
    reg[31:0] reg_q;
    reg [31:0] qin = 32'b0;
    reg [5:0] counter;
    
    assign r = reg_r;
    assign qout = reg_q;
    
    always @(posedge clk or negedge clrn)
        begin
      
            if (clrn == 0) begin // Nothing has been activated
                busy <= 0;
      	        ready <= 0;
            end else if (start == 1) begin // Division is now initialized
                reg_q <= a;
                reg_b <= b;
                reg_r <= 16'b0;
                lhs <= 17'b0;
                rhs <= 17'b0;
                busy <= 1;
                counter <= 'd0;
                ready <= 0;
            end else if (busy == 1) begin // Division has begun
                if (count == 5'd31) begin // 32 left-shifts must be completed, where the first left-shift starts at count = 1
                    busy <= 0;
                    ready <= 1;
                    reg_q <= qin;
                end // Division is still ongoing
                lhs = {reg_r, reg_q[31]};
                rhs = {1'b0, reg_b};
                sub_output = (lhs - rhs); // Output of the subtractor
                    
                    // Restoring Mux Logic
                if (sub_output[16] == 0) begin // If the result was non-negative, retain subtraction and make new LSB of result 1
                    rmux_output = sub_output[15:0];
                    qin[0] = 1'b1;
                end else begin //  If result was negative, restore the r reg value and set LSB to zero
                    rmux_output = lhs[15:0];
                    qin[0] = 1'b0;
                end
                    
                qin = (qin<<1); // Left shifts the input q value to account for the incoming LSB                    
                reg_r = rmux_output; // R reg value now becomes whatever the mux outputs
                reg_q = reg_q<<1; // Q reg input is left-shifted to remove the MSB that was already used in calculations
                counter = counter + 'd1;            
            end
    end
    assign count = counter;

endmodule
