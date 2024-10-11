# Initialize the Vivado environment for the Snickerdoodle Rev D, declaring directories

# First, set the REV_D_DIR environment variable to the repo root directory (in .bash_profile or similar)
# Example:
# ------------------------------------------------------------
#     # Add Rev D directory
#     export REV_D_DIR=/home/[YOUR_USERNAME]/Documents/rev_d_shim
# ------------------------------------------------------------

# Second, source this from your Vivado_init.tcl
# Example:
# ------------------------------------------------------------
#     # Set up Rev D configuration
#     set rev_d_dir $::env(REV_D_DIR)
#     source $rev_d_dir/scripts/Vivado_rev_d_init.tcl
# ------------------------------------------------------------

# Vivado_init.tcl is searched for in the following directories (in order, with each overwriting the previous):
# - Install directory (`/tools/Xilinx/Vivado/<version>/Vivado_init.tcl` by default)
# - Particular Vivado version (`~/.Xilinx/Vivado/<version>/Vivado_init.tc`)
# - Overall Vivado (`~/.Xilinx/Vivado/Vivado_init.tcl`)
set rev_d_dir $::env(REV_D_DIR)
set_param board.repoPaths [list ${rev_d_dir}/boards/snickerdoodle_black/brd/1.0/ ${rev_d_dir}/boards/stemlab_125_14/brd/1.1/ ${rev_d_dir}/boards/sdrlab_122_16/brd/1.0/ ]
