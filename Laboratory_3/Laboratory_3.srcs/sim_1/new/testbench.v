//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University, University Park
// Engineer: Anand Rajan
// 
// Create Date: 03/14/2021 10:04:14 PM
// Design Name: Pipelining CPU
// Module Name: top
// Project Name: Lab 3
// Target Devices: XC7Z010-CLG400-1
// Tool Versions: 
// Description: The project aims to develop a basic CPU through pipelining.
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

    reg clk_tb = 0;

    wire[31:0] IM_sig;
    wire wreg_sig;
    wire m2reg_sig;
    wire wmem_sig;
    wire[3:0] aluc_sig;
    wire aluimm_sig;
    wire[4:0] mux_sig;
    wire [5:0] qa_sig;
    wire [5:0] qb_sig;
    wire [31:0] eimm_sig;
    
    top dut(clk_tb, IM_sig, wreg_sig, m2reg_sig, wmem_sig, aluc_sig, aluimm_sig, mux_sig, qa_sig, qb_sig, eimm_sig); // Initializing an instance of top
  
    always begin
        #5;
        clk_tb = ~clk_tb; // Clock Rule
    end

endmodule
