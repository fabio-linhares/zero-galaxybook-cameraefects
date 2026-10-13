#!/bin/sh
# Zero Linux Broadcast Wrapper
# Prevents GPU/Wayland stuttering on hybrid graphics laptops (Intel + NVIDIA)

if [ -f /usr/share/glvnd/egl_vendor.d/50_mesa.json ]; then
    export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
fi
export __NV_PRIME_RENDER_OFFLOAD=0
export DRI_PRIME=pci-0000_00_02_0
export LB_FORCE_RAW=1

if [ -f /usr/lib/linux-broadcast/linux-broadcast ]; then
    exec /usr/lib/linux-broadcast/linux-broadcast "$@"
elif [ -f /usr/local/lib/zero-linux-broadcast/zero-linux-broadcast ]; then
    exec /usr/local/lib/zero-linux-broadcast/zero-linux-broadcast "$@"
else
    exec linux-broadcast "$@"
fi
