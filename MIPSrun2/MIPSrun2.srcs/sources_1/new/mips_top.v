`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/11 22:00:48
// Design Name: 
// Module Name: mips_top
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

module mips_top(
    input wire clk,
    input wire rst
    );
    //连接指令存储�?
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;
    
    
    //连接数据储存�?
    wire[`DataAddrBus] data_addr;
    wire[`DataBus]     ram_data;
    wire ram_we;
    wire ram_ce;  
    wire[`DataBus]  data;
    
    //实例化MIPS
    mainmips mainmips0(
        .rst(rst),
        .clk(clk),
        .rom_data_i(inst),
        .ram_data_i(data),
        .rom_ce_o(rom_ce),
        .rom_addr_o(inst_addr),
        .ram_addr_o(data_addr),
        .ram_data_o(ram_data),
        .ram_we_o(ram_we),
        .ram_ce_o(ram_ce)
    );
    
        //指令存储器实例化
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );
    
    //数据存储器实例化
    data_ram data_ram0(
        .clk(clk),
        .addr(data_addr),
        .data_i(ram_data),
        .we(ram_we),
        .ce(ram_ce),
        .data_o(data)
    );
    
endmodule
