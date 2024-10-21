## Instantiate the processing system and connect it to fixed IO and DDR

# Create the PS (processing_system7)
# - GP AXI 0 (Master) clock is connected to the processing system's first clock, FCLK_CLK0
cell xilinx.com:ip:processing_system7:5.5 ps_0 {} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
}

# Create all required interconnections
# - Make the processing system's FIXED_IO and DDR interfaces external
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]


## Create the reset hub

# Create xlconstant to hold reset low
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
# - Reset is constant low (active high)
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  slowest_sync_clk ps_0/FCLK_CLK0
}


## Create axi hub, where we use CFG as the inputs and STS as the outputs

# Create axi_hub
# - Config width is 64 bits, first 32 are NANDed with last 32
# - Status width is 32 bits, output of NAND
# - Connect the axi_hub to the processing system's GP AXI 0 interface
# - Connect the axi_hub to the processing system's clock and the reset hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 32
  STS_DATA_WIDTH 32
} {
  S_AXI ps_0/M_AXI_GP0
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Assign the address of the axi_hub in the PS address space
# - Offset: 0x40000000
# - Range: 128M (to 0x47FFFFFF)
# - Subordinate Port: hub_0/S_AXI
addr 0x40000000 128M hub_0/S_AXI


## Add a FIFO loopback on AXI hub port 0

# Create a FIFO block connected to the AXI hub
cell lcb:user:axis_fifo_sync fifo_0 {
  WRITE_DEPTH 16
  ALWAYS_READY TRUE
  ALWAYS_VALID TRUE
} {
  S_AXIS hub_0/M00_AXIS
  M_AXIS hub_0/S00_AXIS
  aclk ps_0/FCLK_CLK0
}

# Slice out the first CFG bit to be the FIFO's reset signal
cell pavel-demin:user:port_slicer fifo_0_rst_slice {
  DIN_WIDTH 32
  DIN_FROM 0
  DIN_TO 0
} {
  din hub_0/cfg_data
}
# Negate it (active 1 from CFG)
# Do a NOT on the result, output to STS
cell xilinx.com:ip:util_vector_logic fifo_0_rst_inv {
  C_SIZE 1
  C_OPERATION not
} {
  Op1 fifo_0_rst_slice/dout
  Res fifo_0/aresetn
}

# Concatenate the FIFO's status signals to the axi_hub's status signals
#  Read and write data width can only use the first 5 bits.
cell pavel-demin:user:port_slicer fifo_0_wr_cnt_slice {
  DIN_WIDTH 24
  DIN_FROM 4
  DIN_TO 0
} {
  din fifo_0/write_count
}
cell pavel-demin:user:port_slicer fifo_0_rd_cnt_slice {
  DIN_WIDTH 24
  DIN_FROM 4
  DIN_TO 0
} {
  din fifo_0/read_count
}
# 18 bit pad to make the status word 32 bits
cell xilinx.com:ip:xlconstant:1.1 fifo_0_sts_pad {
  CONST_VAL 0
  CONST_WIDTH 18
} {}
# Concatenate the status signals into a 32-bit word
cell xilinx.com:ip:xlconcat:2.1 fifo_0_sts_word {
  NUM_PORTS 7
} {
  In0 fifo_0_wr_cnt_slice/dout
  In1 fifo_0/full
  In2 fifo_0/overflow
  In3 fifo_0_rd_cnt_slice/dout
  In4 fifo_0/empty
  In5 fifo_0/underflow
  In6 fifo_0_sts_pad/dout
}
# Connect the status word to the axi_hub
wire fifo_0_sts_word/dout hub_0/sts_data
