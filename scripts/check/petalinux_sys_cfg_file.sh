#!/bin/bash
# Check the PetaLinux config file for a project, board, and version
# Arguments: <board_name> <board_version> <project_name> [--full]
# Full check: PetaLinux environment and prerequisites
# Minimum check: Project source, XSA file, and PetaLinux environment

# Parse arguments
if [ $# -lt 3 ] || [ $# -gt 4 ] || ( [ $# -eq 4 ] && [ "$4" != "--full" ] ); then
  echo "[CHECK PTLNX SYS CFG] ERROR:"
  echo "Usage: $0 <board_name> <board_version> <project_name> [--full]"
  exit 1
fi
FULL_CHECK=false
if [[ "$4" == "--full" ]]; then
  FULL_CHECK=true
fi

# Store the positional parameters in named variables and clear them
BRD=${1}
VER=${2}
PRJ=${3}
PBV="project \"${PRJ}\" and board \"${BRD}\" v${VER}"
set --

# If any subsequent command fails, exit immediately
set -e

# Check prerequisites. If full, check all prerequisites. Otherwise, just the immediate necessary ones.
if $FULL_CHECK; then
  # Full check: PetaLinux config directory and prerequisites
  ./scripts/check/petalinux_cfg_dir.sh ${BRD} ${VER} ${PRJ} --full
else
  # Minimum check: PetaLinux config directory (includes project source and PetaLinux environment)
  ./scripts/check/petalinux_cfg_dir.sh ${BRD} ${VER} ${PRJ}
fi

# Check that the necessary PetaLinux system config file exists
if [ ! -f "projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}/config.patch" ]; then
  echo "[CHECK PTLNX SYS CFG] ERROR:"
  echo "Missing PetaLinux system configuration patch file for ${PBV}"
  echo " Path: projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}/config.patch"
  echo "You can create this file by running the following command:"
  echo
  echo " scripts/petalinux/config_system.sh ${BRD} ${VER} ${PRJ}"
  echo
  exit 1
fi
