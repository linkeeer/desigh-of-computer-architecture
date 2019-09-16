`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/11 20:37:14
// Design Name: 
// Module Name: inst_rom
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


module inst_rom(
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
    );
    reg[`InstBus] inst_mem[0:`InstMemNum-1];
    initial $readmemh ("ins_mem.mem",inst_mem);
    
    always @ (*) begin
        if (ce==`ChipDisable) begin
            inst<=`ZeroWord;
        end else begin
            inst<=inst_mem[addr[`InstMemNum2-1:0]];
        end
    end
endmodule
