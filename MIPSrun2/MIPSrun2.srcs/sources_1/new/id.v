`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: id
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

module id(
	input wire                    clk,
	input wire					  rst,
    input wire[`InstAddrBus]	  pc_i,
	input wire[`InstBus]          inst_i,

    // 璇诲彇鐨凴EGFILE鐨勫??
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	// 杈撳嚭鍒癛EGFILE鐨勪俊鎭紝鍖呮嫭璇荤鍙?鍜?鐨勮浣胯兘淇″彿浠ュ強璇诲湴鍧?淇″彿
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//閫佸埌IF鐨勫垎鏀痜lag鍜屽垎鏀湴鍧?
	output reg                    branch_flag,
	output reg[`InstAddrBus]      branch_addr,
	
	//澶勪簬鎵ц闃舵鐨勬寚浠ょ殑杩愮畻缁撴灉
	input wire     				  ex_wreg_i,
	input wire[`RegBus]			  ex_wdata_i,
	input wire[`RegAddrBus]       ex_wd_i,
	//澶勪簬璁垮瓨闃舵鐨勬寚浠ょ殑杩愮畻缁撴灉
	input wire                    mem_wreg_i,
	input wire[`RegBus]           mem_wdata_i,
	input wire[`RegAddrBus]       mem_wd_i,
	
	// 閫佸埌EX闃舵鐨勪俊鎭?
    output reg[`AluOpBus]         aluop_o,  // ALU鎿嶄綔鐮?
    output reg[`RegBus]           reg1_o,   // 婧愭搷浣滄暟 1
    output reg[`RegBus]           reg2_o,   // 婧愭搷浣滄暟 2
    output reg[`RegAddrBus]       wd_o,     // 瑕佸啓鍏ョ殑瀵勫瓨鍣ㄧ殑鍦板潃
	output reg                    wreg_o ,   // 鍐欎娇鑳戒俊鍙?
	output reg                     mem_ce_o,   //璇诲啓鍐欎富瀛樹娇鑳戒俊鍙?
	output reg                     mem_we_o,    //璇诲啓涓诲瓨淇″彿锛岄珮鐢靛钩鍐欙紝浣庣數骞宠
	output reg stallreq
    );
    
			// 鍙栧緱鎸囦护鐨勬寚浠ょ爜銆佸姛鑳界爜绛夛紱
	wire[3:0] op = inst_i[7:4]; 
	wire[4:0] rs = inst_i[3:2];
	wire[5:0] rd = inst_i[1:0];
		// 淇濆瓨鎸囦护鎵ц闇?瑕佺殑绔嬪嵆鏁?
	reg[`RegBus]	imm;
		// 鎸囦护鏄惁鏈夋晥
	reg instvalid;
	  
	  //reg[3:0] op16code;    //16浣嶆寚浠ょ殑鎿嶄綔鐮?
	  //reg[`RegAddrBus]  op16_addr_rd;   //load鎸囦护鐩殑瀵勫瓨鍣ㄥ湴鍧?
	  //reg[`RegBus]       op16_addr_rs;  //store鎸囦护婧愬瘎瀛樺櫒鍦板潃
	reg[7:0] op16;    //16浣嶆寚浠ゅ墠鍏綅
	reg[7:0] op16_reg;  //瀛樺偍16浣嶆寚浠ゅ墠鍏綅鐨勫瘎瀛樺櫒
	wire[3:0] op16_code=op16_reg[7:4]; //16浣嶆寚浠ょ殑鎿嶄綔鐮?
	wire[`RegAddrBus]       op16_addr_rd={6'b0,op16_reg[1:0]};   //load鎸囦护鐩殑瀵勫瓨鍣ㄥ湴鍧?
	wire[`RegAddrBus]       op16_addr_rs={6'b0,op16_reg[3:2]};  //store鎸囦护婧愬瘎瀛樺櫒鍦板潃
  
	reg stallreq_reg;
	reg[1:0] nowrd;
    //澶勭悊鍐欏悗璇诲啿绐佺殑鐘舵?佽〃
    reg[3:0]        reg_state[3:0];
    reg[3:0]        reg_state_reg[3:0]; 
        
        //reg_state琛ㄧ殑缁存姢
    always @(posedge clk)begin
        reg_state_reg[4'h0]<= reg_state[4'h0]>>1;
        reg_state_reg[4'h1]<= reg_state[4'h1]>>1;
        reg_state_reg[4'h2]<= reg_state[4'h2]>>1;
        reg_state_reg[4'h3]<= reg_state[4'h3]>>1;
    end
     


     // 濡傛灉涓嶉噸缃垯杩涜浠ヤ笅鎿嶄綔
	always @ (*) begin	
      if ( rst == `RstEnable )
             begin
                branch_flag <= `BranchInvalid;
                branch_addr <= `NOPRegAddr;
                aluop_o <= `EXE_NOP_OP;
                wd_o <= `NOPRegAddr;
                wreg_o <= `WriteDisable;
                instvalid <= `InstValid;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                reg1_addr_o <= `NOPRegAddr;
                reg2_addr_o <= `NOPRegAddr;
                imm <= `ZeroWord;
                mem_ce_o <= `ChipDisable;
                mem_we_o <= `WriteDisable;;
                op16 <= `NOP_16OP;
                reg1_o <= `NOPRegAddr;
                reg2_o <= `NOPRegAddr;
                stallreq<=`NoStop;
                reg_state[4'h0] <= 4'b0;
                reg_state[4'h1] <= 4'b0;
                reg_state[4'h2] <= 4'b0;
                reg_state[4'h3] <= 4'b0;
                nowrd <= 2'b0;
          end 
	  else if ( op16_reg== `ZeroWord ) 
           begin
             // 杩欓噷鍏跺疄鏄痙efault閲岄潰鐨勫??
           //   鎴戜滑鍏堢湅涓嬮潰鐨刢ase
             branch_flag <= `BranchInvalid;
             branch_addr <= `NOPRegAddr;
             aluop_o <= `EXE_NOP_OP;
             wd_o <= inst_i[1:0];
             wreg_o <= `WriteDisable;
             instvalid <= `InstInvalid;       
             reg1_read_o <= `ReadDisable;
             reg2_read_o <=  `ReadDisable;
             reg1_addr_o <= `ARegAddr;
             reg2_addr_o <= `BRegAddr;        
             imm <= `ZeroWord;    ;
             mem_ce_o <= `ChipDisable;
             mem_we_o <= `WriteDisable;
             op16 <= `NOP_16OP;
             reg1_o <= `NOPRegAddr;
             reg2_o <= `NOPRegAddr;
             reg_state[4'h0] <= reg_state_reg[4'h0];
             reg_state[4'h1] <= reg_state_reg[4'h1];
             reg_state[4'h2] <= reg_state_reg[4'h2];
             reg_state[4'h3] <= reg_state_reg[4'h3];
             stallreq <= 0;
             case (op)
              `EXE_NOP_OP:
                 begin
                    aluop_o<=`ALU_NOP;
                 end
             
               `EXE_MOV:   
               begin         
                    if(reg_state_reg[rs]==4'b0010||reg_state_reg[rs]==4'b0011)begin //mem娈垫暟鎹墠鎺?
                            aluop_o <= `ALU_MOV;
                            reg1_o <= mem_wdata_i;
                            wd_o <= {6'b0,inst_i[1:0]};
                            wreg_o <= `WriteEnable;
                            instvalid <=`InstValid;
                            reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                            reg_state[rs]<=reg_state_reg[rs]&4'b1101;
                    end  else if(reg_state_reg[rs]!=4'b0)begin //鏁版嵁鍐茬獊
                            stallreq<=`Stop;
                    end else begin            //鏃犳暟鎹啿绐?
                            aluop_o <= `ALU_MOV;
                            reg1_read_o <= `ReadEnable;
                            reg1_addr_o <= {6'b0,inst_i[3:2]};;
                            wd_o <= {6'b0,inst_i[1:0]};
                            wreg_o <= `WriteEnable;
                            instvalid <=`InstValid;
                            reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                    end
                end     
               
               `EXE_ADD:
                    begin
                        if(reg_state_reg[4'b0]!=4'b0|reg_state_reg[4'b0011]!=4'b0) begin
                            stallreq<=`Stop;
                        end else begin
                            aluop_o <= `ALU_ADD;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            wd_o <= {6'b0,inst_i[1:0]};
                            wreg_o <= `WriteEnable;
                            instvalid <= `InstValid;
                            reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                        end
                    end
               
               `EXE_JMP:
                    begin
                        op16 <= inst_i;
                        aluop_o <= `ALU_NOP;
                        instvalid <= `InstValid;
                    end
               
               `EXE_LOAD:
                    begin
                        if(reg_state_reg[rs]!=4'b0)begin
                             stallreq<=`Stop;
                        end else begin
                            op16 <=inst_i;
                            aluop_o <=`ALU_NOP;
                            instvalid <=`InstValid;
                        end
                    end
               
               `EXE_STORE:
                    begin
                        if(reg_state_reg[rs]==4'b0100)begin //mem娈垫暟鎹墠鎺?
                            op16 <=inst_i;
                            aluop_o <=`ALU_NOP;
                             instvalid <=`InstValid;
                        end else if(reg_state_reg[rs]!=4'b0)begin
                             stallreq<=`Stop;
                        end else begin
                            op16 <=inst_i;
                            aluop_o <=`ALU_NOP;
                            instvalid <=`InstValid;
                        end
                    end                
                        
             `EXE_ORI:            
                 begin
                       wreg_o <= `WriteEnable; // 鍐欎娇鑳?
                     aluop_o <= `EXE_OR_OP;
                     reg1_read_o <= `ReadEnable;    // 璇?rs
                     reg2_read_o <= `ReadDisable;    // 涓嶈 rt      
                     wd_o <= {6'b0,inst_i[1:0]};  // 鍐欏瘎瀛樺櫒鍦板潃浣?rt
                     instvalid <= `InstValid;    
                   end                              
             default:
                 begin 
                 end
           endcase
          end 
	  else   
           begin
              branch_flag <= `BranchInvalid;
              branch_addr <= `NOPRegAddr;
              aluop_o <= `EXE_NOP_OP;
              wreg_o <= `WriteDisable;
              instvalid <= `InstInvalid;       
              reg1_read_o <= `ReadDisable;
              reg2_read_o <= `ReadDisable;
              reg1_addr_o <= `ARegAddr;
              reg2_addr_o <= `BRegAddr;        
              imm <= `ZeroWord;
              mem_ce_o <= `ChipDisable;
              mem_we_o <= `WriteDisable;
              op16 <= `NOP_16OP; 
              reg_state[4'h0] <= reg_state_reg[4'h0];
              reg_state[4'h1] <= reg_state_reg[4'h1];
              reg_state[4'h2] <= reg_state_reg[4'h2];
              reg_state[4'h3] <= reg_state_reg[4'h3];                    
              case(op16_code)   //for 16-bit inst addr
                  `EXE_JMP: begin
                      aluop_o <= `ALU_NOP;
                      branch_flag <= `BranchValid;
                      branch_addr <= inst_i;           
                  end
                  `EXE_LOAD:begin
                      aluop_o <= `ALU_LOAD;
    //                   alusel_o<=`EXE_RES_LOGIC;
                      reg1_o<=inst_i;  //LOAD鎸囦护鐨勬簮鏁版嵁鍦ㄥ唴瀛樼殑鍦板潃
                      wd_o <= op16_addr_rd;
                      wreg_o <= `WriteEnable;
                      instvalid<=`InstValid;
                      mem_ce_o <= `ChipEnable;
                      mem_we_o <= `WriteDisable;
                      reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                  end
                  `EXE_STORE:begin
                      aluop_o <= `ALU_STORE;
    //                 alusel_o<=`EXE_RES_LOGIC;
                      reg2_o <= inst_i;  //STORE鎸囦护鐨勬簮鏁版嵁鍦ㄥ唴瀛樼殑鍦板潃
					  if(reg_state_reg[op16_reg[3:2]]==4'b0010)begin
					       reg1_o<= mem_wdata_i;
					       reg_state[op16_reg[3:2]]<=reg_state_reg[op16_reg[3:2]]&4'b1101;
					  end else begin 
					  reg1_read_o <= `ReadEnable;
				      reg1_addr_o <= op16_addr_rs;
					  end
					  instvalid <= `InstValid;
                      mem_ce_o <= `ChipEnable;
                      mem_we_o <= `WriteEnable;
                  end
              endcase
     
            end
	end

	

  // 确定运算的操作数1
	always @ (*) begin
        if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
        end else if(reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
            // 若没有 读使能，则把立即数作为数据输出为 操作数1
        end else if(reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
    
    //16位指令存储前8位和一些寄存器
    always @(posedge clk)begin
        op16_reg<=op16;
    end

    // 确定运算的操作数2
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
        end else if(reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
            // 若没有 读使能，则把立即数作为数据输出为 操作数1
        end else if(reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
