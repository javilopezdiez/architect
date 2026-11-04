#!/usr/bin/env bash
sudo systemctl start tor || exit 1

cleanup() {
		trap - EXIT INT TERM
		sudo systemctl stop tor
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

thorium-browser \
	--proxy-server="socks5://127.0.0.1:9050" \
	--host-resolver-rules="MAP * ~NOTFOUND, EXCLUDE 127.0.0.1" \
	--disable-webrtc \
	--incognito \
	--user-data-dir=/tmp/thorium-tor-profile