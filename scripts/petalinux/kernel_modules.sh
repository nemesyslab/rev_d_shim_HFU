#!/bin/bash
# Build a PetaLinux project for the given board and project
# Arguments: <board_name> <board_version> <project_name>
if [ $# -ne 3 ]; then
  echo "[PTLNX KMOD SCRIPT] ERROR:"
  echo "Usage: $0 <board_name> <board_version> <project_name>"
  exit 1
fi

# Store the positional parameters in named variables and clear them
BRD=${1}
VER=${2}
PRJ=${3}
PBV="project \"${PRJ}\" and board \"${BRD}\" v${VER}"
set --

# If any subsequent command fails, exit immediately
set -e

# Check that the minimum kernel module requirements are met
./scripts/check/kmod_src.sh ${BRD} ${VER} ${PRJ}

# Check for a kernel_modules file
KERNEL_MODULES_FILE="projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}/kernel_modules"
if [ ! -f "${KERNEL_MODULES_FILE}" ]; then
  echo "[PTLNS KMOD SCRIPT] INFO: No kernel_modules file found. Skipping kernel module checks."
  echo "  Path: ${KERNEL_MODULES_FILE}"
  exit 0
fi

# Source the PetaLinux settings script (make sure to clear positional parameters first)
source ${PETALINUX_PATH}/settings.sh

# Enter the PetaLinux project directory
cd tmp/${BRD}/${VER}/${PRJ}/petalinux

# Add kernel modules to the project
# TODO: Not actually adding kernel modules yet, just doing a dummy step
echo "[PTLNX KMOD SCRIPT] Adding kernel modules to PetaLinux project"
while IFS= read -r MOD; do
  echo "[PTLNX KMOD SCRIPT] Adding kernel module: ${MOD}"
  petalinux-create modules --name ${MOD} --enable --force
done < ../../../../../${KERNEL_MODULES_FILE}


