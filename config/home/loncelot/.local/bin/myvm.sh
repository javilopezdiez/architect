#!/bin/bash


if command -v vmware-view >/dev/null 2>&1; then
    vmware-view --save --nonInteractive --hideClientAfterLaunchSession \
        --serverURL="escritoriovirtual.gobiernodecanarias.net" \
        --userName="ext-jlopdie@gobcan.net" \
        --password="passwd" \
        --nomenubar --desktopSize=large \
        --desktopName="evtf999f01-0014"
else
    if command -v thorium-browser &>/dev/null; then
        THORIUM="thorium-browser"
    elif [ -x "$HOME/.local/bin/thorium-browser-arm64/thorium" ]; then
        THORIUM="$HOME/.local/bin/thorium-browser-arm64/thorium"
    fi
    $THORIUM \
        --incognito \
        --ignore-certificate-errors \
        --app="https://escritoriovirtual.gobiernodecanarias.net/portal/webclient/#/home" \
        --no-first-run \
        --no-default-browser-check
fi
