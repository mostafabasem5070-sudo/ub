# Ubuntu 22.04 XFCE Desktop (Windows 11 theme) — VNC / noVNC

Ubuntu 22.04 + XFCE4 + Firefox + TigerVNC + noVNC, themed to look like Windows 11
(GTK theme + icon theme from `yeyushengfan258`), accessible from a browser.

## What's inside

- Base: `ubuntu:22.04`
- Desktop: `xfce4` + `xfce4-goodies`
- Browser: Firefox (installed from the Mozilla Team PPA, .deb build — not the snap)
- Remote access: `tigervnc-standalone-server` + `novnc` + `websockify`
- Theme: Windows 11 GTK theme + matching icon set, applied automatically on login via
  an XFCE autostart entry (`xfconf-query`)

## Build

```bash
docker build -t win11-desktop .
```

## Run

```bash
docker run -d \
  -p 6080:6080 \
  -p 5901:5901 \
  -e VNC_PASSWORD=your-strong-password \
  --name win11-desktop \
  win11-desktop
```

Then open `http://localhost:6080` in your browser. noVNC will auto-connect and ask
for the VNC password you set.

## Environment variables

| Variable        | Default    | Description                                             |
|-----------------|------------|-----------------------------------------------------------|
| `VNC_PASSWORD`  | `changeme` | Password required to connect over VNC / noVNC. **Always override this at runtime.** |

```bash
-e VNC_PASSWORD=your-strong-password
```

## Ports

| Port   | Purpose                                  |
|--------|-------------------------------------------|
| `6080` | noVNC (HTTP/WebSocket) — the port to expose publicly |
| `5901` | Raw VNC — keep this internal/firewalled, don't expose it publicly |

## Security notes

- TigerVNC's classic password authentication only uses the **first 8 characters**
  of `VNC_PASSWORD` — anything after that is ignored. Treat this as a basic gate,
  not strong protection.
- Do not expose port `5901` (raw VNC) to the internet; only publish `6080` (noVNC),
  and ideally put it behind HTTPS / a reverse proxy or SSH tunnel for anything
  beyond local/testing use.
- The container has no automatic TLS trust chain — the self-signed cert generated
  at startup (`self.pem`) will show a browser warning; that's expected for `https://<host>:6080`.
- Always set `VNC_PASSWORD` explicitly. Never deploy with the `changeme` default.

## Notes

- The container runs everything as `root` inside a single process tree — it's meant
  for disposable/ephemeral desktop sessions (testing, demos, temporary remote
  browsing), not as persistent storage. Anything written inside the container is
  lost when it's removed.
- Screen resolution is fixed at `1920x1080` in the `vncserver` command; edit the
  `-geometry` flag in the Dockerfile's `CMD` to change it.
