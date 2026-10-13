#!/usr/bin/env bash
# ==============================================================================
# Zero Galaxy Book Camera Effects — Universal Installer
# Automated Turnkey Setup for AI Camera Effects & Virtual Webcam on Linux
# ==============================================================================
set -euo pipefail

echo "======================================================================"
echo "    ZERO GALAXY BOOK CAMERA EFFECTS — INSTALLATION SCRIPT             "
echo "======================================================================"

if [[ $EUID -eq 0 ]]; then
    echo "[-] Please run this script as a regular user (not root)."
    echo "    Sudo permissions will be requested when needed."
    exit 1
fi

TARGET_USER="${USER}"
TARGET_HOME="${HOME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/5] Checking dependencies..."
MISSING_PKGS=()

if ! command -v v4l2loopback-ctl &>/dev/null; then
    MISSING_PKGS+=("v4l2loopback / v4l2loopback-utils")
fi

if ! command -v cargo &>/dev/null; then
    MISSING_PKGS+=("cargo (Rust toolchain)")
fi

if [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
    echo "[-] Missing recommended tools: ${MISSING_PKGS[*]}"
    echo "    Please install them via your distribution package manager."
    echo "    Fedora: sudo dnf install v4l2loopback cargo gstreamer1-devel"
    echo "    Ubuntu: sudo apt install v4l2loopback-dkms cargo libgstreamer1.0-dev"
    echo "    Arch:   sudo pacman -S v4l2loopback-dkms rust"
fi

echo "[2/5] Building or installing Zero-Linux-Broadcast..."
if [[ -f "/usr/lib/linux-broadcast/linux-broadcast" ]]; then
    echo "  ✔ Pre-compiled binary found in /usr/lib/linux-broadcast/."
    sudo cp "${SCRIPT_DIR}/configs/desktop/zero-linux-broadcast.sh" /usr/bin/zero-linux-broadcast
    sudo chmod 755 /usr/bin/zero-linux-broadcast
else
    echo "  Building from Rust source in src/ (this may take a few minutes)..."
    cd "${SCRIPT_DIR}/src"
    cargo build --release --locked || cargo build --release
    sudo mkdir -p /usr/local/lib/zero-linux-broadcast
    sudo cp target/release/linux-broadcast /usr/local/lib/zero-linux-broadcast/zero-linux-broadcast
    sudo cp "${SCRIPT_DIR}/configs/desktop/zero-linux-broadcast.sh" /usr/bin/zero-linux-broadcast
    sudo chmod 755 /usr/bin/zero-linux-broadcast
    cd "${SCRIPT_DIR}"
fi

echo "[3/5] Configuring virtual loopback device (/dev/video40)..."
sudo cp "${SCRIPT_DIR}/configs/systemd/zero-galaxybook-ai-loopback.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zero-galaxybook-ai-loopback.service
sudo systemctl start zero-galaxybook-ai-loopback.service || true

if command -v v4l2loopback-ctl &>/dev/null; then
    sudo v4l2loopback-ctl add -n "Zero Galaxy Book AI Camera" -x 1 40 2>/dev/null || true
fi

echo "[4/5] Configuring WirePlumber routing..."
if [[ -d "/etc/wireplumber/wireplumber.conf.d" ]]; then
    sudo cp "${SCRIPT_DIR}/configs/wireplumber/60-camera-priority.conf" /etc/wireplumber/wireplumber.conf.d/
    systemctl --user restart wireplumber 2>/dev/null || true
fi

echo "[5/5] Installing desktop entry and default user configuration..."
mkdir -p "${TARGET_HOME}/.local/share/applications"
cp "${SCRIPT_DIR}/configs/desktop/zero-galaxybook-ai.desktop" "${TARGET_HOME}/.local/share/applications/"
update-desktop-database "${TARGET_HOME}/.local/share/applications" 2>/dev/null || true

mkdir -p "${TARGET_HOME}/.config/linux-broadcast"
if [[ ! -f "${TARGET_HOME}/.config/linux-broadcast/config.toml" ]]; then
    cat > "${TARGET_HOME}/.config/linux-broadcast/config.toml" << 'EOF'
source_device = "/dev/video0"
sink_device = "/dev/video40"
width = 1280
height = 720
framerate = 30
mode = "blur"
blur_strength = 0.50
model = "selfie_multiclass"
start_on_login = false
show_preview = true
auto_frame = true
EOF
fi

echo "======================================================================"
echo "✔ Installation complete!"
echo "  • Launcher: 'Zero Galaxy Book AI (Efeitos de Câmera)'"
echo "  • Virtual camera node: /dev/video40 (Zero Galaxy Book AI Camera)"
echo "  • Run directly via CLI: zero-linux-broadcast"
echo "======================================================================"
