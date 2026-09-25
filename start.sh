#!/bin/bash
set -e

VNC_DIR="$HOME/.vnc"
mkdir -p "$VNC_DIR"

# TigerVNC ships the password tool under different names depending on the
# Ubuntu version / which package pulled it in ("tigervnc-tools" vs the
# "vncpasswd" alternative symlink). Try both instead of hard-coding one.
if command -v vncpasswd >/dev/null 2>&1; then
    VNCPASSWD_BIN="vncpasswd"
elif command -v tigervncpasswd >/dev/null 2>&1; then
    VNCPASSWD_BIN="tigervncpasswd"
else
    echo "FATAL: neither vncpasswd nor tigervncpasswd found. Is tigervnc-tools installed?" >&2
    exit 1
fi

echo "${VNC_PASSWORD:-changeme}" | "$VNCPASSWD_BIN" -f > "$VNC_DIR/passwd"
chmod 600 "$VNC_DIR/passwd"

vncserver -localhost no -SecurityTypes VncAuth -rfbauth "$VNC_DIR/passwd" -geometry "${SCREEN_SIZE:-1920x1080}"

CERT="$HOME/self.pem"
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out "$CERT" -keyout "$CERT"

websockify -D --web=/usr/share/novnc/ --cert="$CERT" 6080 localhost:5901

tail -f /dev/null
