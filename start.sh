#!/usr/bin/env bash
set -Eeuo pipefail

PORT="${PORT:-8080}"
DISPLAY_NUM="${DISPLAY_NUM:-99}"
DISPLAY=":${DISPLAY_NUM}"
VNC_PORT="${VNC_PORT:-5900}"
SCREEN_SIZE="${SCREEN_SIZE:-1280x800x24}"

export DISPLAY
export XDG_RUNTIME_DIR="/tmp/runtime-ubuntu"

mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Railway containers are ephemeral. If no password is supplied,
# generate one and print it once to the deployment logs.
if [[ -z "${VNC_PASSWORD:-}" ]]; then
    VNC_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16 || true)"
    VNC_PASSWORD="${VNC_PASSWORD:-UbuntuVNC123456}"
fi

echo "============================================================"
echo "Ubuntu XFCE Desktop is starting"
echo "noVNC HTTP port : ${PORT}"
echo "VNC password    : ${VNC_PASSWORD}"
echo "Screen          : ${SCREEN_SIZE}"
echo "============================================================"

rm -f "/tmp/.X${DISPLAY_NUM}-lock" "/tmp/.X11-unix/X${DISPLAY_NUM}" 2>/dev/null || true
mkdir -p /tmp/.X11-unix

Xvfb "$DISPLAY" \
    -screen 0 "$SCREEN_SIZE" \
    -ac \
    +extension GLX \
    +render \
    -noreset &
XVFB_PID=$!

cleanup() {
    kill "$XVFB_PID" "${XFCE_PID:-}" "${VNC_PID:-}" "${WEBSOCKIFY_PID:-}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

sleep 1

runuser -u ubuntu -- env \
    DISPLAY="$DISPLAY" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    dbus-run-session -- startxfce4 &
XFCE_PID=$!

sleep 3

x11vnc \
    -display "$DISPLAY" \
    -rfbport "$VNC_PORT" \
    -passwd "$VNC_PASSWORD" \
    -forever \
    -shared \
    -noxdamage \
    -repeat \
    -cursor most \
    -listen 127.0.0.1 \
    -localhost &
VNC_PID=$!

sleep 2

exec websockify \
    --web=/usr/share/novnc \
    --heartbeat=30 \
    "$PORT" \
    "127.0.0.1:${VNC_PORT}"
