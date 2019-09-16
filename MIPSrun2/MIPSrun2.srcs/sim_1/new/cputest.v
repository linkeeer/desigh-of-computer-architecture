`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/12 19:00:04
// Design Name: 
// Module Name: cputest
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


module cputest(

    );
    reg clk;
    reg rst;
    mips_top mips_top0(
        .clk(clk),
        .rst(rst)
    );
    initial begin
        clk=0;
        rst=1;
        #10 rst=0;
    end
    always #5 clk=~clk;
endmodule
