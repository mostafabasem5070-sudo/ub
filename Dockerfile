FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# Override at runtime: docker run -e VNC_PASSWORD=yourpassword ...
# TigerVNC's classic auth only uses the first 8 characters of the password.
ENV VNC_PASSWORD=changeme
RUN apt update -y && apt install --no-install-recommends -y xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools novnc websockify sudo xterm init systemd snapd vim net-tools curl wget git tzdata
RUN apt update -y && apt install -y dbus-x11 x11-utils x11-xserver-utils x11-apps
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:mozillateam/ppa -y
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
RUN apt update -y && apt install -y firefox
RUN apt update -y && apt install -y xubuntu-icon-theme

# --- Windows 11 theme (GTK theme + matching icon theme) ---
RUN apt update -y && apt install -y sassc gnome-themes-extra gtk2-engines-murrine
RUN git clone https://github.com/yeyushengfan258/Windows11-gtk-theme.git /tmp/win11-gtk-theme && \
    cd /tmp/win11-gtk-theme && ./install.sh -d /usr/share/themes -n Win11 -t default -c standard && \
    rm -rf /tmp/win11-gtk-theme
RUN git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/win11-icon-theme && \
    cd /tmp/win11-icon-theme && ./install.sh -d /usr/share/icons -n Win11 && \
    rm -rf /tmp/win11-icon-theme
RUN mkdir -p /etc/xdg/autostart && \
    echo "[Desktop Entry]" > /etc/xdg/autostart/set-win-theme.desktop && \
    echo "Type=Application" >> /etc/xdg/autostart/set-win-theme.desktop && \
    echo "Exec=sh -c \"xfconf-query -c xsettings -p /Net/ThemeName -s Win11; xfconf-query -c xsettings -p /Net/IconThemeName -s Win11; xfconf-query -c xfwm4 -p /general/theme -s Win11\"" >> /etc/xdg/autostart/set-win-theme.desktop && \
    echo "Name=Set Win Theme" >> /etc/xdg/autostart/set-win-theme.desktop
# --- end Windows 11 theme ---

RUN echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale">' > /usr/share/novnc/index.html && \
    echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale">' > /usr/share/novnc/vnc_lite.html
RUN touch /root/.Xauthority
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 5901
EXPOSE 6080
CMD ["/start.sh"]
