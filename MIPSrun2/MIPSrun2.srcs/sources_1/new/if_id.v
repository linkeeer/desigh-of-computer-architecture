`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: if_id
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

module if_id(
    input [`InstAddrBus] if_pc,
    input [`InstBus] if_inst,
    input rst,
    input clk,
    input wire[5:0] stall,
    output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
    );
        // 如果复位的话，传递给下一个阶段的数据要清�?
	always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
	  	end else if (stall[1] == `Stop && stall[2] == `NoStop ) begin
	  	   // id_pc <= `ZeroWord;
	  	    //id_inst <= `ZeroWord;
	    end else if (stall[1] == `NoStop) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
		end
	end
endmodule
