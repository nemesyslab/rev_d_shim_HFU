#!/bin/bash
# INP = $1
# OUT = $2

# Options for Zynq 7020 (ARM Cortex-A9):
#  -static           : Compiles all dependencies into the file
#  -O3               : Optimizes for speed
#  -mcpu=cortex-a9   : Compiles for the cortex-a9 platform
#  -mfpu=neon        : Adds NEON floating point support
#  -mfloat-abi=hard  : Stores floating point inputs in registers, not as integers
arm-linux-gnueabihf-gcc -static -O3 -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard $1 -o $2 -lm
