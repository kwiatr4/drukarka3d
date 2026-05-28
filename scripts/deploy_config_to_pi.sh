#!/usr/bin/env bash
set -euo pipefail

# deploy_config_to_pi.sh
# Usage: edit variables below or export them before running
# Example: PI_USER=biqu PI_HOST=192.168.1.12 ./deploy_config_to_pi.sh

PI_USER=${PI_USER:-biqu}
PI_HOST=${PI_HOST:-192.168.1.12}
REPO_URL=${REPO_URL:-https://github.com/kwiatr4/drukarka3d.git}
REPO_DIR=${REPO_DIR:-/home/${PI_USER}/drukarka3d}
REMOTE_CONFIG_DIR=${REMOTE_CONFIG_DIR:-/home/${PI_USER}/printer_data/config}
MERGED_PATH_IN_REPO=${MERGED_PATH_IN_REPO:-"EP3D SWX2 Klipper Configs and Firmware/Klipper/Configs/Merged/printer-artillery-sidewinder-x2-bttpi.cfg"}

echo "Deploying merged printer.cfg to ${PI_USER}@${PI_HOST}"

ssh ${PI_USER}@${PI_HOST} bash -s <<EOF
set -euo pipefail
echo "Preparing repository on Pi..."
sudo apt-get update -y || true
sudo apt-get install -y git || true

if [ -d "${REPO_DIR}" ]; then
  echo "Repo exists, pulling latest..."
  cd "${REPO_DIR}"
  git pull || true
else
  echo "Cloning repo to ${REPO_DIR}"
  git clone "${REPO_URL}" "${REPO_DIR}"
fi

echo "Backing up existing printer config (if any)"
mkdir -p "${REMOTE_CONFIG_DIR}/backup"
if [ -e "${REMOTE_CONFIG_DIR}/printer.cfg" ]; then
  cp "${REMOTE_CONFIG_DIR}/printer.cfg" "${REMOTE_CONFIG_DIR}/backup/printer.cfg.\$(date +%Y%m%d_%H%M)" || true
fi

echo "Creating symlink from repo config to ${REMOTE_CONFIG_DIR}/printer.cfg"
rm -f "${REMOTE_CONFIG_DIR}/printer.cfg"
ln -s "${REPO_DIR}/${MERGED_PATH_IN_REPO}" "${REMOTE_CONFIG_DIR}/printer.cfg"
chown -h ${PI_USER}:${PI_USER} "${REMOTE_CONFIG_DIR}/printer.cfg" || true

echo "Restarting Klipper service"
sudo systemctl restart klipper || true
sleep 1
sudo systemctl status klipper --no-pager

echo "Done. If using Moonraker or web UI, you may restart those services as needed."
EOF

echo "Deployment script finished. If SSH asks for a password, enter it now."
