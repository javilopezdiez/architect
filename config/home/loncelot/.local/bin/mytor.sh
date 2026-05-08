#!/usr/bin/env bash
sudo systemctl start tor

cleanup() {
  sudo systemctl stop tor
  exit
}

trap cleanup SIGINT SIGTERM

thorium-browser \
  --proxy-server="socks5://127.0.0.1:9050" \
  --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE 127.0.0.1" \
  --disable-webrtc \
  --incognito \
  --user-data-dir=/tmp/thorium-tor-profile

cleanup