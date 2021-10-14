`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University, University Park
// Engineer: Anand Rajan
// 
// Create Date: 04/25/2021 08:09:09 PM
// Design Name: 
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


module top(input clk, output wwreg_sig, output [4:0] rs_sig, output [4:0] rt_sig, output [4:0] wn_sig, output [31:0] d_sig);

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
    wire [5:0]qa_to_fmu;
    wire [5:0]qb_to_fmu;
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
    wire [31:0] mux_to_alu;
    wire [31:0] aluout;
    wire [31:0] fmu_to_idexe;
    wire [31:0] fmu2_to_idexe;
    
    // Block 4: MEM stage
    wire mwreg;
    wire mm2reg;
    wire mwmem;
    wire [4:0] mmuxout;
    wire [31:0] maluout;
    wire [5:0] mqb;
    wire [31:0] dm_to_memwb;
    
    // Block 5: WB stage
    wire wwreg;
    wire wm2reg;
    wire [4:0] wmuxout;
    wire [31:0] waluout;
    wire [31:0] wdo;
    wire [31:0] wbmuxout;
    wire [1:0] forwardA;
    wire [1:0] forwardB;

    // Module Instantiations
    PC pc(clk, adder_to_pc, pc_out);
    Adder adder(pc_out, adder_to_pc);   
    IM im(pc_out, im_to_ifid);
    IFID ifid(clk, im_to_ifid, ifid_out);
    CU cu(ifid_out[31:26], ifid_out[5:0], ifid_out[25:21], ifid_out[20:16],
            mmuxout, mm2reg, mwreg, emuxout, em2reg, ewreg,
             wreg_to_idexe, m2reg_to_idexe, wmem_to_idexe, aluc_to_idexe, aluimm_to_idexe, RegDst, forwardA, forwardB);
    Mux mux(ifid_out[15:11], ifid_out[20:16], RegDst, mux_to_idexe);
        
    forwardingMux fmu(qa_to_fmu, aluout, maluout, dm_to_memwb, forwardA, fmu_to_idexe);
    forwardingMux fmu2(qb_to_fmu, aluout, maluout, dm_to_memwb, forwardB, fmu2_to_idexe);
    
    Signext ext(ifid_out[15:0], eimm_to_idexe);
    IDEXE idexe(clk, wreg_to_idexe, m2reg_to_idexe, wmem_to_idexe, aluc_to_idexe, 
                aluimm_to_idexe, mux_to_idexe, fmu_to_idexe, fmu2_to_idexe, eimm_to_idexe,
                ewreg, em2reg, ewmem, ealuc, ealuimm, emuxout, eqa, eqb, eeimm);
    Mux2 mux2(eqb, eeimm, ealuimm, mux_to_alu);
    
    ALU alu(eqa, mux_to_alu, ealuc, aluout);
    EXEMEM exemem(clk, ewreg, em2reg, ewmem, emuxout, aluout, eqb,
                    mwreg, mm2reg, mwmem, mmuxout, maluout, mqb);
    DataMem dm(maluout, mqb, mwmem, dm_to_memwb);
    MEMWB memwb(clk, mwreg, mm2reg, mmuxout, maluout, dm_to_memwb,
                    wwreg, wm2reg, wmuxout, waluout, wdo);
    WBMux wbmux(waluout, wdo, wm2reg, wbmuxout);
    Regfile regfile(!clk, ifid_out[25:21], ifid_out[20:16], wmuxout, wbmuxout, wwreg, qa_to_fmu, qb_to_fmu);
    
//    assign mwreg_sig = mwreg;
//    assign mm2reg_sig = mm2reg;
//    assign mmuxout_sig = mmuxout;
//    assign maluout_sig = maluout;
//    assign do_sig = dm_to_memwb;
    
//    assign wwreg_sig = wwreg;
//    assign wm2reg_sig = wm2reg;
//    assign wmuxout_sig = wmuxout;
//    assign waluout_sig = waluout;
//    assign wdo_sig = wdo;

    assign wwreg_sig = wwreg;
    assign rs_sig = ifid_out[25:21];
    assign rt_sig = ifid_out[20:16];
    assign wn_sig = wmuxout;
    assign d_sig = wbmuxout;
   

    
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
            IM[108] = 32'b10001100001001000000000000001000;
            IM[112] = 32'b10001100001001010000000000001100;
            IM[116] = 32'b00000000110000100101000000100000;
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
             input [4:0] rs, input [4:0] rt, input [4:0] mmuxout, input mm2reg, input mwreg, input [4:0] emuxout, input em2reg, input ewreg,
            output reg wreg, output reg m2reg, output reg wmem, output reg[3:0] aluc, output reg aluimm, output reg regrt,
            output reg [1:0] fwda, output reg [1:0] fwdb);
            
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
        
        // Forwarding Unit
        
        fwda <= 2'b00;
        fwdb <= 2'b00;
        
        if ((ewreg == 1) && (emuxout != 0) && (emuxout == rs)) begin // dest reg of exemem is same as source reg of prev instr
            fwda <= 2'b01;
        end else if ((ewreg == 1) && (emuxout != 0) && (emuxout == rt)) begin // dest reg of exemem is same as target reg of prev instr
            fwdb <= 2'b01;
        end else if ((mwreg == 1) && (mmuxout != 0) && (mmuxout == rs)) begin // same as above for memwb
            if (emuxout != rs) begin
                fwda <= 2'b10;
            end else if (ewreg == 0) begin
                fwda <= 2'b10;
            end
        end else if ((mwreg == 1) && (mmuxout != 0) && (mmuxout == rt)) begin // same as above for memwb
            if (emuxout != rt) begin
                fwdb <= 2'b10;
            end else if (ewreg == 0) begin
                fwdb <= 2'b10;
            end     
        end     
        // the case of 11 would be in a load word dependency but this never arises in this case 
        
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

module Regfile(input clk, input [4:0]rs, input [4:0]rt, input [5:0] wn, input [31:0] d, input we, output reg [5:0]qa, output reg [5:0]qb);
    reg [31:0] regfile [0:31];
    
    integer a;
    integer b;
    integer c;
    always @(posedge clk) begin
    
        c = wn;
    
        // if we is 1, write back is enabled
        if (we)
            regfile[c] <= d;
            
        // qa outputs for rs and qb outputs for rt
        a = rs; // this is to integer-cast the binary input
        b = rt;
        
        qa <= regfile[a];
        qb <= regfile[b];
        
    end
    // asked to initialize all values in the regfile to 0
    integer i;
    initial begin
        regfile[0] = 'h00000000;
        regfile[1] = 'hA00000AA;
        regfile[2] = 'h10000011;
        regfile[3] = 'h20000022;
        regfile[4] = 'h30000033;
        regfile[5] = 'h40000044;
        regfile[6] = 'h50000055;
        regfile[7] = 'h60000066;
        regfile[8] = 'h70000077;
        regfile[9] = 'h80000088;
        regfile[10] = 'h90000099;
        for (i=11; i<32; i=i+1) begin
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

module Mux2(input [5:0] a, input [31:0] b, input sel, output reg [31:0] q);
    // Not dependent on clock; chooses 0 or 1 based on ealuimm
    always @(*) begin
        if (sel) // select eeimm if RegDst is 1
            q <= b;
        else // select eqb if RegDst is 0
            q <= a;
    end

endmodule

module ALU(input [5:0] a, input [31:0] b, input [3:0] aluc, output reg [31:0] r);
    // Not dependent on clock; performs different ops based on aluc

    always @(*) begin
        case(aluc) // Determination of these values depends on the aluc
            4'b0000: // AND
                begin
                    r <= a && b;              
                end
            
            4'b0001: // OR
                begin
                    r <= a || b;
                end
                
            4'b0010: // add
                begin
                    r <= a + b;
                end
                
            4'b0010: // subtract
                begin
                    r <= a - b;
                end
                
            4'b0010: // set on less than
                begin
                    if (a < b) begin
                        r <= 32'b1;
                    end else begin
                        r <= 32'b0;
                    end
                end
                
            4'b0010: // NOR
                begin
                    r <= ~(a || b);
                end                                            
                
        endcase
    end

endmodule

module EXEMEM(input clk, input ewreg, input em2reg, input ewmem, input [4:0]emuxout, input [31:0] aluout, input [5:0]eqb,
            output reg mwreg, output reg mm2reg, output reg mwmem, output reg [4:0]mmuxout, output reg [31:0] maluout, output reg [5:0] mqb);
    // Nothing but a clock-dependent output-input setter
    always @(posedge clk)
        begin
            mwreg <= ewreg;
            mm2reg <= em2reg;
            mwmem <= ewmem;
            mmuxout <= emuxout;
            maluout <= aluout;
            mqb <= eqb;
        end
endmodule

module DataMem(input [31:0] a, input [5:0] di, input we, output reg [31:0] do);
    // Not dependent on clock; array
    reg [31:0] dmem [0:31];
    
    integer x;
    integer y;
    always @(*) begin
        if (!we) // if we is 0, read
            // do outputs value at address a
            x = a; // this is to integer-cast the binary input
            //b = rt;
            do <= dmem[x];
        // if we is 1, write, but this lab doesn't cover that
        // input di seems relatively useless - function not specified in TB, lecture, or hints video
    end
    // asked to initialize all values in the dmem to those provided
    integer i;
    initial begin
    
        for (i=0; i<32; i=i+1) begin
            dmem[i] = 0;
        end
    
        dmem[0] = 'hA00000AA;
        dmem[1] = 'h10000011;
        dmem[2] = 'h20000022;
        dmem[3] = 'h30000033;
        dmem[4] = 'h40000044;
        dmem[5] = 'h50000055;
        dmem[6] = 'h60000066;
        dmem[7] = 'h70000077;
        dmem[8] = 'h80000088;
        dmem[9] = 'h90000099;
    end  
endmodule

module MEMWB(input clk, input mwreg, input mm2reg, input [4:0] mmuxout, input [31:0] maluout, input [31:0] do,
            output reg wwreg, output reg wm2reg, output reg [4:0] wmuxout, output reg [31:0] waluout, output reg [31:0] wdo);
    // Nothing but a clock-dependent output-input setter
    always @(posedge clk)
        begin
            wwreg <= mwreg;
            wm2reg <= mm2reg;
            wmuxout <= mmuxout;
            waluout <= maluout;
            wdo <= do;
        end
endmodule

module WBMux(input [31:0] a, input [31:0] b, input sel, output reg [31:0] q);
    // Not dependent on clock; chooses 0 or 1 based on selector
    always @(*) begin
        if (sel) // select wdo if wm2reg is 1
            q <= b;
        else // select waluout if wm2reg is 0
            q <= a;
    end

endmodule       
        
module forwardingMux(input [5:0] a, input [31:0] b, input [31:0] c, input [31:0] d, input [1:0] sel, output reg [31:0] q);

    always @(*) begin
        if (sel == 2'b00)
            q <= a;
        else if (sel == 2'b01)
            q <= b;
        else if (sel == 2'b10)
            q <= c;
        else if (sel == 2'b11)
            q <= d;
    end

endmodule
