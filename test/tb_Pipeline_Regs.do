vlib work
vcom -2008 -work work ../src/IF_ID/dffg.vhd ../src/IF_ID/reg_n.vhd
vcom -2008 -work work ../src/Pipeline_Reg/dffg_sf.vhd ../src/Pipeline_Reg/reg_n_sf.vhd
vcom -2008 -work work ../src/IF/PC_Reg/reg_n_pc.vhd ../src/IF/PC_Reg/pc_reg_sf.vhd
vcom -2008 -work work ../src/IF_ID/IF_ID.vhd ../src/ID_EX/ID_EX.vhd ../src/EX_MEM/EX_MEM.vhd ../src/MEM_WB/MEM_WB.vhd
vcom -2008 -work work tb_Pipeline_Regs.vhd

vsim -voptargs=+acc work.tb_Pipeline_Regs

add wave -divider Control
add wave -radix decimal /tb_Pipeline_Regs/s_test
add wave /tb_Pipeline_Regs/CLK /tb_Pipeline_Regs/RST
add wave -label stall(MEM_WB..PC) /tb_Pipeline_Regs/s_stall
add wave -label flush(MEM_WB..PC) /tb_Pipeline_Regs/s_flush
add wave -radix decimal /tb_Pipeline_Regs/s_errors

add wave -divider PC
add wave -radix hex /tb_Pipeline_Regs/s_PC /tb_Pipeline_Regs/s_Inst

add wave -divider IF_ID
add wave -radix hex /tb_Pipeline_Regs/s_Inst_ID /tb_Pipeline_Regs/s_PC_ID

add wave -divider ID_EX
add wave -radix hex /tb_Pipeline_Regs/s_Inst_EX /tb_Pipeline_Regs/s_PC_EX
add wave /tb_Pipeline_Regs/s_RegWr_EX /tb_Pipeline_Regs/s_memread_EX

add wave -divider EX_MEM
add wave -radix hex /tb_Pipeline_Regs/s_Inst_MEM /tb_Pipeline_Regs/s_ALUout_MEM
add wave /tb_Pipeline_Regs/s_RegWr_MEM /tb_Pipeline_Regs/s_memread_MEM

add wave -divider MEM_WB
add wave -radix hex /tb_Pipeline_Regs/s_Inst_WB /tb_Pipeline_Regs/s_ALUout_WB
add wave /tb_Pipeline_Regs/s_RegWr_WB /tb_Pipeline_Regs/s_memtoreg_WB

run 3500 ns
wave zoom full
