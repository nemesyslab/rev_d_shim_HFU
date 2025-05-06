#!/bin/bash
# Clear the BOOT and RootFS directories for the given board and project
# Arguments: <board_name> <board_version> <project_name> [<mount_directory>]
if [ $# -lt 3 ] || [ $# -gt 4 ]; then
  echo "[CLEAR SD] ERROR:"
  echo "Usage: $0 <board_name> <board_version> <project_name> [<mount_directory>]"
  exit 1
fi

# Store the positional parameters in named variables
BRD=${1}
VER=${2}
PRJ=${3}
if [ $# -eq 4 ]; then
  MNT=${4}
else
  MNT="/media/$(whoami)"
fi
PBV="project \"${PRJ}\" and board \"${BRD}\" v${VER}"
set --

# If any subsequent command fails, exit immediately
set -e

# Check that the media directory exists
if [ ! -d "${MNT}" ]; then
  echo "[CLEAR SD] ERROR:"
  echo "Media/mount directory does not exist: ${MNT}"
  exit 1
fi

# Check that BOOT and RootFS directories exist
if [ ! -d "${MNT}/BOOT" ]; then
  echo "[CLEAR SD] ERROR:"
  echo "Missing BOOT directory in mount point: ${MNT}/BOOT"
  echo "Ensure the SD card is partitioned and mounted correctly."
  exit 1
fi
if [ ! -d "${MNT}/RootFS" ]; then
  echo "[CLEAR SD] ERROR:"
  echo "Missing RootFS directory in mount point: ${MNT}/RootFS"
  echo "Ensure the SD card is partitioned and mounted correctly."
  exit 1
fi

# Verify with a confirmation prompt
echo "[CLEAR SD] WARNING: This will clear the BOOT and RootFS directories for ${PBV} at ${MNT}"
echo "[CLEAR SD] Are you sure you want to proceed? (y/n)"
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "[CLEAR SD] Aborting."
  exit 0
fi
echo "[CLEAR SD] Proceeding to clear BOOT and RootFS directories for ${PBV} at ${MNT}"

# Clear the BOOT directory
echo "[CLEAR SD] Clearing BOOT directory for ${PBV} at ${MNT}/BOOT (needs sudo)"
sudo rm -rf ${MNT}/BOOT/*

# Clear the RootFS directory
echo "[CLEAR SD] Clearing RootFS directory for ${PBV} at ${MNT}/RootFS (needs sudo)"
sudo rm -rf ${MNT}/RootFS/*

echo "[CLEAR SD] Successfully cleared BOOT and RootFS directories for ${PBV}"
