## Instantiate the processing system and connect it to fixed IO and DDR

# Create the PS (processing_system7)
# - GP AXI 0 (Master) clock is connected to the processing system's first clock, FCLK_CLK0
# - Enable ACP interface
cell xilinx.com:ip:processing_system7:5.5 ps_0 {} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
}
# Create all required interconnections
# - Make the processing system's FIXED_IO and DDR interfaces external
# - Apply the board preset
# - Disable PS cross-triggering in and out (master/slave)
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  apply_board_preset 1
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]
# Apply extra PS configuration for UART
# - Enable UART1 and assign MIO pins 36 and 37 for UART1
set_property -dict [list \
  CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_UART1_UART1_IO {MIO 36 .. 37} \
] [get_bd_cells ps_0]
