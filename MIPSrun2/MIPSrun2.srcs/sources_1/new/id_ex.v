`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: id_ex
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
`include "defines.v" 

module id_ex(
	input wire				      clk,
	input wire					  rst,
    
    input wire[5:0]               stall,
	
	// 从ID阶段传�?�过来的信息
	input wire[`AluOpBus]         id_aluop,
	input wire[`RegBus]           id_reg1,
	input wire[`RegBus]           id_reg2,
	input wire[`RegAddrBus]       id_wd,
	input wire                    id_wreg,	
	input wire                    id_mem_ce,
	input wire                    id_mem_we,
	
	// �?要传递到EX阶段的信�?
	output reg[`AluOpBus]         ex_aluop,
	output reg[`RegBus]           ex_reg1,
	output reg[`RegBus]           ex_reg2,
	output reg[`RegAddrBus]       ex_wd,
	output reg                    ex_wreg,
	output reg                    ex_mem_ce,
	output reg                    ex_mem_we
    );
        // 如果重置的话，进行以下操作清空信�?
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_mem_ce <= `ChipDisable;
			ex_mem_we <= `WriteDisable;
            // 如果不重置的话，把ID阶段的结果�?�到EX阶段
		end else if (stall[2] == `Stop && stall[3] == `NoStop ) begin		
		    ex_aluop <= `EXE_NOP_OP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_mem_ce <= `ChipDisable;
			ex_mem_we <= `WriteDisable;
		end else if (stall[2] == `NoStop) begin
			ex_aluop <= id_aluop;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
			ex_mem_ce <= id_mem_ce;
			ex_mem_we <= id_mem_we;				
		end
	end
endmodule
