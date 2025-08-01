###############################################################################
#
#   Single-ended ports
#
###############################################################################


#------------------------------------------------------------
# Inputs
#------------------------------------------------------------

# (Shutdown_Sense)
create_bd_port -dir I -type data Shutdown_Sense
# (Trigger_In)
create_bd_port -dir I Trigger_In


#------------------------------------------------------------
# Outputs
#------------------------------------------------------------

# (Shutdown_Sense_Sel0-2)
create_bd_port -dir O -from 2 -to 0 -type data Shutdown_Sense_Sel
# (~Shutdown_Force)
create_bd_port -dir O n_Shutdown_Force
# (~Shutdown_Reset)
create_bd_port -dir O n_Shutdown_Reset



###############################################################################
#
#   Differential ports
#
###############################################################################


#------------------------------------------------------------
# DAC
#------------------------------------------------------------

# (LDAC+)
create_bd_port -dir O -from 0 -to 0 -type data LDAC_p
# (LDAC-)
create_bd_port -dir O -from 0 -to 0 -type data LDAC_n
# (~DAC_CS+)
create_bd_port -dir O -from 7 -to 0 -type data n_DAC_CS_p
# (~DAC_CS-)
create_bd_port -dir O -from 7 -to 0 -type data n_DAC_CS_n
# (DAC_MOSI+)
create_bd_port -dir O -from 7 -to 0 -type data DAC_MOSI_p
# (DAC_MOSI-)
create_bd_port -dir O -from 7 -to 0 -type data DAC_MOSI_n
# (DAC_MISO+)
create_bd_port -dir I -from 7 -to 0 -type data DAC_MISO_p
# (DAC_MISO-)
create_bd_port -dir I -from 7 -to 0 -type data DAC_MISO_n


#------------------------------------------------------------
# ADC
#------------------------------------------------------------

# (~ADC_CS+)
create_bd_port -dir O -from 7 -to 0 -type data n_ADC_CS_p
# (~ADC_CS-)
create_bd_port -dir O -from 7 -to 0 -type data n_ADC_CS_n
# (ADC_MOSI+)
create_bd_port -dir O -from 7 -to 0 -type data ADC_MOSI_p
# (ADC_MOSI-)
create_bd_port -dir O -from 7 -to 0 -type data ADC_MOSI_n
# (ADC_MISO+)
create_bd_port -dir I -from 7 -to 0 -type data ADC_MISO_p
# (ADC_MISO-)
create_bd_port -dir I -from 7 -to 0 -type data ADC_MISO_n


#------------------------------------------------------------
# Clocks
#------------------------------------------------------------

# (SCKO+)
create_bd_port -dir I -from 7 -to 0 MISO_SCK_p
# (SCKO-)
create_bd_port -dir I -from 7 -to 0 MISO_SCK_n
# (~SCKI+)
create_bd_port -dir O -from 0 -to 0 n_MOSI_SCK_p
# (~SCKI-)
create_bd_port -dir O -from 0 -to 0 n_MOSI_SCK_n


###############################################################################

### Create processing system
# Enable M_AXI_GP0 and M_AXI_GP1
# Enable UART1 on the correct MIO pins
# UART1 baud rate 921600
# Pullup for UART1 RX
# Enable I2C0 on the correct MIO pins
# Turn off FCLK1-3 and reset1-3
init_ps ps {
  PCW_USE_M_AXI_GP0 1
  PCW_USE_M_AXI_GP1 1
  PCW_USE_S_AXI_ACP 0
  PCW_UART1_PERIPHERAL_ENABLE 1
  PCW_UART1_UART1_IO {MIO 36 .. 37}
  PCW_UART1_BAUD_RATE 921600
  PCW_MIO_37_PULLUP enabled
  PCW_I2C0_PERIPHERAL_ENABLE 1
  PCW_I2C0_I2C0_IO {MIO 38 .. 39}
  PCW_EN_CLK1_PORT 0
  PCW_EN_CLK2_PORT 0
  PCW_EN_CLK3_PORT 0
  PCW_EN_RST1_PORT 0
  PCW_EN_RST2_PORT 0
  PCW_EN_RST3_PORT 0
} {
  M_AXI_GP0_ACLK ps/FCLK_CLK0
  M_AXI_GP1_ACLK ps/FCLK_CLK0
}
