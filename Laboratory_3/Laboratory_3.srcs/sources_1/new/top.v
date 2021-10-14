`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University, University Park
// Engineer: Anand Rajan
// 
// Create Date: 03/12/2021 11:33:07 AM
// Design Name: 
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


module top(input clk, output[31:0] IM_sig, output wreg_sig, output m2reg_sig, output wmem_sig,
            output[3:0] aluc_sig, output aluimm_sig, output[4:0] mux_sig, output [5:0] qa_sig,
            output [5:0] qb_sig, output [31:0] eimm_sig);

    // Block 1: IF stage
    wire[7:0] adder_to_pc; // Output from adder
    wire[7:0] pc_out; // Output from PC register
    wire[31:0] im_to_ifid; // Output from instruction memory
    
    // Block 2: ID stage
    wire[31:0] ifid_out;
    // Outputs from the Control Unit
    wire wreg_to_idexe;
    wire m2reg_to_idexe;
    wire wmem_to_idexe;
    wire[3:0] aluc_to_idexe;
    wire aluimm_to_idexe;
    wire RegDst;
    // Output from Mux
    wire [4:0]mux_to_idexe;
    // Output from Register File
    wire [5:0]qa_to_idexe;
    wire [5:0]qb_to_idexe;
    // Output from Sign Extender
    wire[31:0] eimm_to_idexe;
    
    // Block 3: EXE stage (next lab)
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire[3:0] ealuc;
    wire ealuimm;
    wire [4:0] emuxout;
    wire [5:0] eqa;
    wire [5:0] eqb;
    wire [31:0] eeimm;

    // Module Instantiations
    PC pc(clk, adder_to_pc, pc_out);
    Adder adder(pc_out, adder_to_pc);   
    IM im(pc_out, im_to_ifid);
    IFID ifid(clk, im_to_ifid, ifid_out);
    CU cu(ifid_out[31:26], ifid_out[5:0], wreg_to_idexe, m2reg_to_idexe, wmem_to_idexe, aluc_to_idexe, aluimm_to_idexe, RegDst);
    Mux mux(ifid_out[15:11], ifid_out[20:16], RegDst, mux_to_idexe);
    Regfile regfile(ifid_out[25:21], ifid_out[20:16], qa_to_idexe, qb_to_idexe);
    Signext ext(ifid_out[15:0], eimm_to_idexe);
    IDEXE idexe(clk, wreg_to_idexe, m2reg_to_idexe, wmem_to_idexe, aluc_to_idexe, 
                aluimm_to_idexe, mux_to_idexe, qa_to_idexe, qb_to_idexe, eimm_to_idexe,
                ewreg, em2reg, ewmem, ealuc, ealuimm, emuxout, eqa, eqb, eeimm);


    // Since the instructions ask for signals written INTO each register and not from, the following are outputs:
    assign IM_sig = im_to_ifid;
    assign wreg_sig = wreg_to_idexe;
    assign m2reg_sig = m2reg_to_idexe;
    assign wmem_sig = wmem_to_idexe;
    assign aluc_sig = aluc_to_idexe;
    assign aluimm_sig = aluimm_to_idexe;
    assign mux_sig = mux_to_idexe;
    assign qa_sig = qa_to_idexe;
    assign qb_sig = qb_to_idexe;
    assign eimm_sig = eimm_to_idexe;
    
endmodule

module PC(input clk, input[7:0] a, output reg[7:0] q);
    // Wire to set the value of PC to its next value; PC is a register effectively
    always @(posedge clk)
        begin
            q <= a;
        end
        
    initial begin
        q = 8'd100;
        end

endmodule

module Adder(input [7:0]a, output reg[7:0] q);
    // This module is not clock-dependent. It adds the input from PC register to the constant 4 and returns it.
    // PC register should take this value to set as new value.
    wire[7:0] to_add = 8'd4;
    
    always @(*)
        begin
             q <= (a + to_add);
        end
        
endmodule

module IM(input[7:0] addr, output reg [31:0] do);
    reg [31:0] IM [0:511]; // Array of registers
    
    integer a;
    
    always @(*)
        begin
            a = addr; // integer-cast
            do = IM[a];
        end
        
    initial // Hardcoded based on the examples provided to be done
        begin
            IM[100] = 32'b10001100001000100000000000000000;
            IM[104] = 32'b10001100001000110000000000000100;
        end
endmodule

module IFID(input clk, input [31:0]a, output reg[31:0] q);
    // This is also clock-dependent. Outputs whatever it's inputted at pos clock edge.
    always @(posedge clk)
        begin
            q <= a;
        end
endmodule

module CU(input [5:0] op, input [5:0] func, 
            output reg wreg, output reg m2reg, output reg wmem, output reg[3:0] aluc, output reg aluimm, output reg regrt);
            
    always @(*) begin
        case(op) // Determination of these values depends on the opcode, and func for R-format
            6'b000000: // R-format instruction
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                regrt = 1'b1;
                aluimm = 1'b0;
                
                case(func) // Using truth table in Zybooks
                    6'b100000: // add
                        aluc = 4'b0010;
                    6'b100010: // subtract
                        aluc = 4'b0110;
                    6'b100100: // AND
                        aluc = 4'b0000;
                    6'b100101: // OR
                        aluc = 4'b0001;
                    6'b100110: // XOR
                        aluc = 4'b0010;
                    6'b000000: // shift left
                        aluc = 4'b0010;
                    6'b000010: // logical shift right
                        aluc = 4'b0110;
                        // Not in truth table
//                    6'b000011: // arithmetic shift right
//                        aluc = 4'b0010;
//                    6'b001000: // register jump
//                        aluc = 4'b0010;
                endcase
                
            end
            
            // Commented cases remain to be done in second part of lab - only necessary cases done
            
//            6'b001000: // addi
//            6'b001100: // andi
//            6'b001101: // ori
//            6'b001110: // xori
            6'b100011: // lw
                begin
                    wreg = 1'b1;
                    m2reg = 1'b1;
                    wmem = 1'b0;
                    regrt = 1'b0;
                    aluimm = 1'b1;
                    aluc = 4'b0010;
                end
            6'b101011: // sw
                begin
                    wreg = 1'b0;
                    m2reg = 1'bX;
                    wmem = 1'b1;
                    regrt = 1'bX;
                    aluimm = 1'b1;
                    aluc = 4'b0010;
                end
//            6'b000100: // beq
//            6'b000101: // bne
//            6'b001111: // lui
//            6'b000010: // j
//            6'b000011: // jal   
        endcase
    end
    
endmodule

module Mux(input [4:0]rd, input [4:0]rt, input regrt, output reg [4:0]muxout);
    always @(*) begin
        if (regrt) // select rd if RegDst is 1
            muxout <= rd;
        else // select rt if RegDst is 0
            muxout <= rt;
    end
endmodule

module Regfile(input [4:0]rs, input [4:0]rt, output reg [5:0]qa, output reg [5:0]qb);
    reg [31:0] regfile [0:31];
    
    integer a;
    integer b;
    always @(*) begin
        // qa outputs for rs and qb outputs for rt
        a = rs; // this is to integer-cast the binary input
        b = rt;
        
        qa <= regfile[a];
        qb <= regfile[b];
        
    end
    // asked to initialize all values in the regfile to 0
    integer i;
    initial begin
        for (i=0; i<32; i=i+1) begin
            regfile[i] = 0;
        end
    end    
endmodule

module Signext(input [15:0]imm, output reg [31:0]eimm);
    // converts 16 bit imm to 32 bits
    always @(*) begin
        eimm[31:0] <= { {16{imm[15]}}, imm[15:0] };
    end
endmodule

module IDEXE(input clk, input wreg, input m2reg, input wmem, input [3:0]aluc, input aluimm, input [4:0]muxout, input [5:0]qa, input [5:0]qb, input [31:0]eimm,
            output reg ewreg, output reg em2reg, output reg ewmem, output reg [3:0]ealuc, output reg ealuimm, output reg [4:0]emuxout,
            output reg [5:0]eqa, output reg [5:0]eqb, output reg[31:0] eeimm);
    // Nothing but a clock-dependent output-input setter
    always @(posedge clk)
        begin
            ewreg <= wreg;
            em2reg <= m2reg;
            ewmem <= wmem;
            ealuc <= aluc;
            ealuimm <= aluimm;
            emuxout <= muxout;
            eqa <= qa;
            eqb <= qb;
            eeimm <= eimm;
        end
endmodule

