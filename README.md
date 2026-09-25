# Ubuntu 24.04 XFCE Desktop — Railway

Ubuntu 24.04 official Docker image + XFCE + Xvfb + x11vnc + noVNC.

## Deploy

1. Upload these files to a GitHub repository.
2. In Railway choose **Deploy from GitHub Repo**.
3. Select the repository.
4. Railway detects the root `Dockerfile`.
5. Deploy.
6. Generate a public domain under Railway Networking.
7. Open the domain in your browser.
8. The noVNC interface will load.
9. If `VNC_PASSWORD` is not configured, get the generated password from Railway Deploy Logs.

## Environment variables

Recommended:

```text
VNC_PASSWORD=your-long-random-password
SCREEN_SIZE=1366x768x24
```

Optional:

```text
DISPLAY_NUM=99
VNC_PORT=5900
```

Do not expose the raw VNC port publicly. noVNC/websockify is the public HTTP entry point.

## Important

The base image is:

```dockerfile
FROM ubuntu:24.04
```

The image already contains an `ubuntu` user, so this project does not attempt to create that user again.

The container is intended for temporary/ephemeral desktop sessions. Do not rely on its filesystem as permanent storage.
