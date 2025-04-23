#!/bin/bash
# Check if the XSA for a project exists
# Arguments: <board_name> <board_version> <project_name>
if [ $# -ne 3 ]; then
    echo "[CHECK PTLNX CFG] ERROR:"
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

# Check PetaLinux requirements
./scripts/check/petalinux_req.sh ${BRD} ${VER} ${PRJ}

# Check that the necessary PetaLinux config file exists
if [ ! -f "projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}/config.patch" ]; then
    echo "[CHECK PTLNX CFG] ERROR:"
    echo "Missing PetaLinux project configuration patch file for ${PBV}"
    echo " Path: projects/${PRJ}/cfg/${BRD}/${VER}/petalinux/${PETALINUX_VERSION}/config.patch"
    echo "You can create this file by running the following command:"
    echo
    echo " scripts/petalinux/config_project.sh ${BRD} ${VER} ${PRJ}"
    echo
    exit 1
fi
