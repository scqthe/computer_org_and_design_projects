`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2021 10:18:15 PM
// Design Name: 
// Module Name: rmux
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


module rmux(a, b, sel, out);
  input  [15:0] a, b;
  input sel;
  output reg [15:0] out;
  
  always @(*)
    begin
      
      if (sel == 0)
        begin
          
          out = b;
          
        end
      
      else
        begin
          
          out = a;
          
        end

  
endmodule
