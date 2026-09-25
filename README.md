# Ubuntu 24.04 XFCE Desktop for Railway

A minimal browser-accessible Ubuntu desktop container for Railway.

## Base image

This project starts directly from the official Ubuntu 24.04 Docker image:

```dockerfile
FROM ubuntu:24.04
```

It adds only the components required for an XFCE desktop, Xvfb, x11vnc and noVNC.

## Deploy on Railway

1. Push this repository to GitHub.
2. In Railway, create a new project.
3. Choose **Deploy from GitHub repo**.
4. Select this repository.
5. Railway detects the root `Dockerfile` automatically.
6. After deployment, generate a public domain from **Settings → Networking**.
7. Open the generated URL.
8. The noVNC page will appear.
9. Get the VNC password from the deployment logs.

Railway provides the HTTP port through the `PORT` environment variable. The container uses that variable automatically.

## Recommended Railway variables

You can optionally set:

- `VNC_PASSWORD` — your own VNC password.
- `SCREEN_SIZE` — for example `1366x768x24`.
- `DISPLAY_NUM` — normally leave as `99`.
- `VNC_PORT` — normally leave as `5900`.

Example:

```text
VNC_PASSWORD=your-long-random-password
SCREEN_SIZE=1366x768x24
```

## Important security note

This exposes a graphical Linux desktop through a public web endpoint. Use a strong `VNC_PASSWORD` and do not put secrets, SSH keys, API keys or personal files inside the image.

This image intentionally does not install SSH or expose the raw VNC port publicly.

## Included

- Ubuntu 24.04
- XFCE desktop
- Xvfb virtual display
- x11vnc
- noVNC
- websockify
- XTerm
- Mousepad
- sudo for the `ubuntu` user

## Not included

A full browser is intentionally not installed by default because Ubuntu's Firefox/Chromium packages may use Snap, which is not appropriate for this minimal container setup.

If you need a browser, add a container-compatible browser explicitly rather than relying on Snap.
