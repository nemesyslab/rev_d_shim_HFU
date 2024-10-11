Based on Pavel Demin's Notes on the Red Pitaya Open Source Instrument
http://pavel-demin.github.io/red-pitaya-notes/
as well as the Open-MRI OCRA project (also based off of Pavel Demin's repo)
https://github.com/OpenMRI/ocra


# Rev D Shim

## Getting Started

First, you'll need the Xilinx/AMD Vivado toolchain installed.
Second, you'll need to set up the repo's Vivado init script. Read the information inside `scripts/vivado_repo_init.tcl` for more information.
Finally, to make a project, you can run
```
make PROJECT=<project_name> BOARD=<board_name>
```

## Directory Structure

The modified organization of this repository is as follows:
```
rev_d_shim/
├── boards/                               - Board files for different supported boards
│   ├── snickerdoodle_black/              - Board files for the Snickerdoodle Black, the target board
│   │                                       for the Rev D Shim
│   ├── stemlab_125_14/                   - Board files for the Red Pitaya STEMlab 125-14, used in many of Pavel 
│   │                                       Demin's projects
│   ├── sdrlab_122_16/                    - Board files for the Red Pitaya SDRLab 122-16, which the OCRA project 
│                                           supports
├── cores/                                - Custom IP cores for use in Vivado's block design build flow
│   ├── lcb/                              - Cores written by Lincoln Craven-Brightman
│   ├── open-mri/                         - Cores written by contributors to Open-MRI/OCRA projects
│   ├── pavel-demin/                      - Cores written by Pavel Demin
├── kernel_modules/                       - Custom kernel modules
│   ├── README.md                         - Instructions on building kernel modules
│   ├── cma/                              - CMA kernel module, for allocating contiguous memory
├── modules/                              - Custom modules used in other cores
├── projects/                             - Files/scripts to build particular projects
│   ├── pavel_adc_recorder/               - Example ADC recorder project from Pavel Demin's repo
│   ├── example_fclk_control/             - Example project for controlling the FPGA clock from the PS
│   ├── example_axi_hub/                  - Example project for controlling the AXI Hub core's
│   │                                       CFG and STS registers from the PS
│   ├── shim_controller/                  - Previous working version of the shim controller
├── scripts/                              - Scripts for building the shim and other projects
│   ├── bitstream.tcl                     - Script to build the bitstream from a Vivado .XPR project file,
│   │                                       used in the Makefile
│   ├── cross_compile.sh                  - Script to cross compile C code for the ARM Cortex-A9
│   ├── get_cores_from_tcl.sh             - Script to extract used cores from a project's 
│   │                                       "block_design.tcl", used in the Makefile
│   ├── package_core.tcl                  - Script to package a custom IP core for use in a 
│   │                                       Vivado block design, used in the Makefile
│   ├── project.tcl                       - Script to build a Vivado .XPR project file, used in the Makefile
│   ├── symlink_defaults.sh               - Script to symlink the default "ports.tcl" file and "[board]_xdc" 
│                                           directory from a given board to a given project
├── README.md                             - This file
```
