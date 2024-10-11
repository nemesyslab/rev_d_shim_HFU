#!/bin/bash
# This script builds a custom kernel module (in kernel_modules/) for a specific board (in boards/).

if [ $# -lt 2 || $# -gt 3 ]; then
    echo "Usage: $0 <directory> <board> <make_args>"
    echo "  <directory>  The directory (relative to kernel_modules/) containing the kernel module(s) to build."
    echo "  <board>      The board to build the kernel module(s) for."
    echo "  <make_args>  Optional arguments to pass to the make command."
    exit 1
fi

## Check inputs
# Check if the environment variable REV_D_DIR is set
if [ -z "$REV_D_DIR" ]; then
    echo "Please set the environment variable 'REV_D_DIR' to the path of the RevD-Shim directory."
    exit 1
fi
# Check if the module directory exists
if [ ! -d "$REV_D_DIR/kernel_modules/$1" ]; then
    echo "The directory '$REV_D_DIR/kernel_modules/$1' does not exist."
    exit 1
fi
# Check if the board directory exists
if [ ! -d "$REV_D_DIR/boards/$2" ]; then
    echo "The directory '$REV_D_DIR/boards/$2/linux_src/build/kernel' does not exist. Please make sure the board has kernel source files and that the kernel has already been built!"
    exit 1
fi

## Construct the make command with optional arguments
# By default, just run make with ARCH=arm and CROSS_COMPILE=arm-linux-gnueabihf-
MAKE_CMD="make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- KDIR=$REV_D_DIR/boards/$2/build/kernel"
# Optionally append the second argument to the make command
if [ $# -eq 3 ]; then
    MAKE_CMD="$MAKE_CMD $3"
fi

# cd to the kernel module directory
cd "$REV_D_DIR/kernel_modules/$1"

# Run the make command
echo "Building kernel module(s) for $2 in directory: $(pwd)"
$MAKE_CMD
