`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/11 21:14:23
// Design Name: 
// Module Name: data_rom
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

module data_ram(
    input wire clk,
    input wire ce,
    input wire we,
    input wire[`RegBus]       device_i,
	output reg[`RegBus]       device_o, 
    input wire[`DataAddrBus] addr,
    input wire[`DataBus] data_i,
    output reg[`DataBus] data_o
    );
    reg[`ByteWidth] data_mem[0:`DataMemNum-1];
    initial begin
        data_mem[128]<= 100;
    end
    //Ð´²Ù×÷
    always @ (posedge clk) begin
        
        if (ce==`ChipDisable) begin
            data_o<=`ZeroWord;
        end else if (we==`WriteEnable) begin
            data_mem[addr[`DataMemNumLog2-1:0]]<=data_i;
        end
    end
    
    //¶Á²Ù×÷
    always @ (*) begin
        if (ce==`ChipDisable) begin
            data_o<=`ZeroWord;
        end else if (we==`WriteDisable) begin
            data_o<=data_mem[addr[`DataMemNumLog2-1:0]];
        end else begin
            data_o<=`ZeroWord;
        end
    end
endmodule
