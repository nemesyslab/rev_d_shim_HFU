###############################################################################
#
#   Single-ended ports
#
###############################################################################


#------------------------------------------------------------
# Inputs
#------------------------------------------------------------

# (10Mhz_In)
create_bd_port -dir I Scanner_10Mhz_In
# (Shutdown_Sense)
create_bd_port -dir I Shutdown_Sense
# (Trigger_In)
create_bd_port -dir I Trigger_In
# (Eth_Clk)
create_bd_port -dir I Eth_Clk
# (~Shutdown_Reset)
create_bd_port -dir I n_Shutdown_Reset


#------------------------------------------------------------
# Outputs
#------------------------------------------------------------

# (Shutdown_Sense_Sel0-2)
create_bd_port -dir O -from 2 -to 0 Shutdown_Sense_Sel
# (Shutdown_Force)
create_bd_port -dir O Shutdown_Force



###############################################################################
#
#   Differential ports
#
###############################################################################


#------------------------------------------------------------
# DAC
#------------------------------------------------------------

# (LDAC+)
create_bd_port -dir O -from 0 -to 0 LDAC_p
# (LDAC-)
create_bd_port -dir O -from 0 -to 0 LDAC_n
# (~DAC_CS+)
create_bd_port -dir O -from 7 -to 0 n_DAC_CS_p
# (~DAC_CS-)
create_bd_port -dir O -from 7 -to 0 n_DAC_CS_n
# (DAC_MOSI+)
create_bd_port -dir O -from 7 -to 0 DAC_MOSI_p
# (DAC_MOSI-)
create_bd_port -dir O -from 7 -to 0 DAC_MOSI_n
# (DAC_MISO+)
create_bd_port -dir I -from 7 -to 0 DAC_MISO_p
# (DAC_MISO-)
create_bd_port -dir I -from 7 -to 0 DAC_MISO_n


#------------------------------------------------------------
# ADC
#------------------------------------------------------------

# (~ADC_CS+)
create_bd_port -dir O -from 7 -to 0 n_ADC_CS_p
# (~ADC_CS-)
create_bd_port -dir O -from 7 -to 0 n_ADC_CS_n
# (ADC_MOSI+)
create_bd_port -dir O -from 7 -to 0 ADC_MOSI_p
# (ADC_MOSI-)
create_bd_port -dir O -from 7 -to 0 ADC_MOSI_n
# (ADC_MISO+)
create_bd_port -dir I -from 7 -to 0 ADC_MISO_p
# (ADC_MISO-)
create_bd_port -dir I -from 7 -to 0 ADC_MISO_n


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
