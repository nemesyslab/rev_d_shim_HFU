#!/bin/bash
# Check if the XSA for a project exists
# Arguments: <board_name> <board_version> <project_name>
if [ $# -ne 3 ]; then
    echo "[CHECK PTLNX REQ] ERROR:"
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

# Check XSA file
./scripts/check/xsa.sh ${BRD} ${VER} ${PRJ}

# Check that the PetaLinux settings script exists
if [ -z "$PETALINUX_PATH" ]; then
    echo "[CHECK PTLNX REQ] ERROR: PETALINUX_PATH environment variable is not set."
    exit 1
fi
if [ ! -f "${PETALINUX_PATH}/settings.sh" ]; then
    echo "[CHECK PTLNX REQ] ERROR: PetaLinux settings script not found at ${PETALINUX_PATH}/settings.sh"
    exit 1
fi

# Check that the PetaLinux version environment variable is set
if [ -z "$PETALINUX_VERSION" ]; then
    echo "[CHECK PTLNX REQ] ERROR: PETALINUX_VERSION environment variable is not set."
    exit 1
fi

# Check that the board cfg directory (and petalinux directory) exists
if [ ! -d "projects/${PRJ}/cfg/${BRD}/${VER}/petalinux" ]; then
    echo "[CHECK PTLNX REQ] ERROR:"
    echo "Board PetaLinux configuration directory not found for ${PBV}"
    echo "  Path: projects/${PRJ}/cfg/${BRD}/${VER}/petalinux"
    exit 1
fi

# Check that the PetaLinux config directory exists for the PetaLinux version
if [ ! -d "projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}" ]; then
    echo "[CHECK PTLNX REQ] ERROR:"
    echo "PetaLinux version ${PETALINUX_VERSION} directory not found for ${PBV}"
    echo "  Path: projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}"
    exit 1
fi