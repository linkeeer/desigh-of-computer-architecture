`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: regfile
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


module regfile(
	// 写端口
	input wire					 we,
    input wire[`RegAddrBus]		 waddr,
    input wire[`RegBus]			 wdata,
	
	// 读端口 1
	input wire					 re1,
    input wire[`RegAddrBus]		 raddr1,
    output reg[`RegBus]          rdata1,
	
	// 读端口 2
	input wire					 re2,
    input wire[`RegAddrBus]		 raddr2,
    output reg[`RegBus]          rdata2,
    input rst,
    input clk
    );
        // 定义8个8位寄存器
    reg[`RegBus]  regs[0:`RegNum-1];

    // 写操作
	always @ (posedge clk) begin
		if (rst == `RstDisable) begin
            // 如果 写使能 而且 我们没有向0号寄存器写入东西的时候，我们才向寄存器里面写入
            // 因为 0 号寄存器只读而且永远读出 32'h0
            if(we == `WriteEnable) begin
				regs[waddr] <= wdata;
			end
		end
	end
	    // 读端口1 的读操作
	always @ (*) begin
       // 如果重置则读出 32'h0
	  if(rst == `RstEnable) begin
          rdata1 <= `ZeroWord;
       // 当读地址与写地址相同，且写使能，且端口1读使能，则要把写入的数据直接读出来
       //   数据前推的实现，后面会提及
	  end else if((raddr1 == waddr) && (we == `WriteEnable) 
            && (re1 == `ReadEnable)) begin // 注意此部分！理解！
	  	  rdata1 <= wdata;
       // 否则读取相应寄存器单元
	  end else if(re1 == `ReadEnable) begin
	      rdata1 <= regs[raddr1];
       // 如果第一个读端口不能使用时，输出0
	  end else begin
	      rdata1 <= `ZeroWord;
	  end
	end

    // 读端口2 的读操作
    // 和读端口1 类似
	always @ (*) begin
		if(rst == `RstEnable) begin
            rdata2 <= `ZeroWord;
	  end else if(raddr2 == `RegNum'h0) begin
	  		rdata2 <= `ZeroWord;
	  end else if((raddr2 == waddr) && (we == `WriteEnable) 
                  && (re2 == `ReadEnable)) begin // 注意此部分！理解！
	  	  rdata2 <= wdata;
	  end else if(re2 == `ReadEnable) begin
	      rdata2 <= regs[raddr2];
	  end else begin
	      rdata2 <= `ZeroWord;
	  end
	end

endmodule
