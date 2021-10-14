//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University, University Park
// Engineer: Anand Rajan
// 
// Create Date: 04/04/2021 08:10:14 PM
// Design Name: Pipelining CPU
// Module Name: top
// Project Name: Lab 4
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

    wire mwreg_sig;
    wire mm2reg_sig;
    wire mwmem_sig;
    wire[4:0] mmuxout_sig;
    wire [31:0] maluout_sig;
    wire[31:0] dm_sig;
    wire ealuimm_sig;
    wire [4:0] mux_sig;
    
    top dut(clk_tb, mwreg_sig, mm2reg_sig, mwmem_sig, mmuxout_sig, maluout_sig, dm_sig, ealuimm_sig, mux_sig); // Initializing an instance of top
  
    always begin
        #5;
        clk_tb = ~clk_tb; // Clock Rule
    end

endmodule
