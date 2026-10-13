# 🎥 Zero Galaxy Book Camera Effects
**Open-Source AI Studio Camera Effects & Virtual Webcam for Linux**  
*Optimized for Samsung Galaxy Book Series & Modern Hybrid Laptops (Intel Core + NVIDIA / AMD / Wayland)*

---

## 🌟 Overview

On Windows 11, Samsung Galaxy Book laptops feature **Studio Mode** (Auto-framing, Background Blur, Virtual Backgrounds, and AI Voice Focus).

**Zero Galaxy Book Camera Effects** brings full feature parity to **Linux**:
- 🎯 **Auto-Framing (Center Stage / Face Tracking):** Smoothly crops and centers the user's face and upper body in real-time.
- 🎨 **Background Blur & Bokeh:** Adjustable blur intensity radius (4–32px).
- 🖼️ **Virtual Background:** Instant background replacement with custom images.
- ⚡ **Zero-Lag Hybrid GPU Optimization:** Built-in Wayland / Mesa EGL routing (`DRI_PRIME` / `LB_FORCE_RAW=1`) preventing screen stutter on hybrid Intel + NVIDIA laptops.
- 🔋 **Lazy Producer Mode:** Zero battery consumption when video conferencing apps are closed; turns on instantly when Zoom, Google Meet, Microsoft Teams, Discord, or web browsers request the camera.
- 🎙️ **Voice Focus Compatibility:** Seamless integration with PipeWire and EasyEffects (RNNoise / DeepFilterNet) for studio-grade microphone background noise suppression.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Physical / Calibrated Camera Node (/dev/video0)          │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Zero-Linux-Broadcast Engine (Rust + ONNX Runtime)        │
│    • Real-time Face Tracking & Smoothed Dynamic Crop        │
│    • MediaPipe Selfie Multiclass / RVM Matting Models       │
│    • GPU/EGL Buffer Routing (Zero-Copy)                     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Virtual V4L2 Output Node (/dev/video40)                  │
│    "Zero Galaxy Book AI Camera" (1080p / 720p YUY2 @ 30fps) │
│    Consumed by Zoom, Teams, Meet, Discord, Firefox, Chrome  │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚡ Quick Start (1-Command Installation)

### Prerequisites

- A Linux distribution running a modern kernel (Fedora 40+, Ubuntu 22.04+, Arch Linux, Debian 12+).
- `v4l2loopback` kernel module installed.
- Rust toolchain (`cargo`, `rustc`) if building from source.

### Installation

```bash
git clone https://github.com/fabio-linhares/zero-galaxybook-cameraefects.git
cd zero-galaxybook-cameraefects
./install.sh
```

Once installed:
- Open your application menu and launch **`Zero Galaxy Book AI (Efeitos de Câmera)`**.
- Or run directly from terminal:
  ```bash
  zero-linux-broadcast
  ```

---

## 🎛️ How to Use in Video Calls

In your favorite video conferencing app (Zoom, Google Meet, Microsoft Teams, Discord, Slack):
1. Go to **Settings > Video / Camera**.
2. Select **`Zero Galaxy Book AI Camera`** for AI-processed video (Blur / Framing).
3. Select your native camera (e.g. `Intel MIPI Camera` on `/dev/video0`) for clean, unedited passthrough.

---

## 📂 Repository Structure

```text
zero-galaxybook-cameraefects/
├── install.sh                                # Automated turnkey installer
├── uninstall.sh                              # Clean uninstaller script
├── configs/                                  # Declarative system configurations
│   ├── desktop/
│   │   ├── zero-galaxybook-ai.desktop        # Desktop menu launcher
│   │   └── zero-linux-broadcast.sh           # Hybrid GPU Wayland/Mesa wrapper
│   ├── systemd/
│   │   └── zero-galaxybook-ai-loopback.service # Loopback persistence daemon
│   └── wireplumber/
│       └── 60-camera-priority.conf           # WirePlumber routing rules
└── src/                                      # Complete Rust source code & ONNX models
```

---

## 📄 License

This project is licensed under the [GNU General Public License v3.0 (GPL-3.0-or-later)](./LICENSE).
Built upon the open-source foundation of `linux-broadcast` with specialized architecture enhancements for Samsung Galaxy Book hardware and hybrid GPU Linux platforms.
