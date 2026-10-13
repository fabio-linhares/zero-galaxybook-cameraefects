#!/usr/bin/env bash
# ==============================================================================
# Zero Galaxy Book Camera Effects — Uninstaller
# ==============================================================================
set -euo pipefail

echo "Removing Zero Galaxy Book Camera Effects..."

sudo systemctl stop zero-galaxybook-ai-loopback.service 2>/dev/null || true
sudo systemctl disable zero-galaxybook-ai-loopback.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/zero-galaxybook-ai-loopback.service
sudo systemctl daemon-reload

if command -v v4l2loopback-ctl &>/dev/null; then
    sudo v4l2loopback-ctl delete /dev/video40 2>/dev/null || true
fi

rm -f "${HOME}/.local/share/applications/zero-galaxybook-ai.desktop"
update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true

sudo rm -f /usr/bin/zero-linux-broadcast
sudo rm -rf /usr/local/lib/zero-linux-broadcast

echo "✔ Zero Galaxy Book Camera Effects uninstalled cleanly."
