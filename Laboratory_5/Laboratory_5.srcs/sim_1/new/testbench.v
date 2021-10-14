//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University, University Park
// Engineer: Anand Rajan
// 
// Create Date: 04/25/2021 08:09:09 PM
// Design Name: Pipelining CPU
// Module Name: top
// Project Name: Final Lab
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
    
//    wire mwreg_sig;
//    wire mm2reg_sig;
//    wire [4:0] mmuxout_sig;
//    wire [31:0] maluout_sig;
//    wire [31:0] do_sig;

//    wire wwreg_sig;
//    wire wm2reg_sig;
//    wire [4:0] wmuxout_sig;
//    wire [31:0] waluout_sig;
//    wire [31:0] wdo_sig;

    wire wwreg_sig;
    wire [4:0] rs_sig;
    wire [4:0] rt_sig;
    wire [4:0] wn_sig;
    wire [31:0] d_sig;

    
    top dut(clk_tb, wwreg_sig, rs_sig, rt_sig, wn_sig, d_sig); // Initializing an instance of top
  
    always begin
        #5;
        clk_tb = ~clk_tb; // Clock Rule
    end

endmodule
