#!/bin/bash

PYTHON_SITE_DIR="$HOME/.local/lib/python$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')/site-packages"
VPN_GATEWAY="evpn.gobiernodecanarias.org"
USERNAME="ext-jlopdie"  # optional: you can also be prompted
SCRIPT="/etc/vpnc/vpnc-script"

# Fix gp_saml_gui.py
mymodder.sh \
        --file "$PYTHON_SITE_DIR/gp_saml_gui.py" \
        --codefile "$HOME/.local/bin/mysrc/init_poolmanager.py"


# Set up split tunneling vpnc-script ENVIRONMENTALS
mymodder.sh \
        --file "$SCRIPT" \
        --before "# =========== script (variable) setup ====================================" \
        --codefile "$HOME/.local/bin/mysrc/tunneling.txt"

eval $(gp-saml-gui -P \
        --gateway \
        --allow-insecure-crypto \
        --no-verify \
        --clientos=Windows \
        "$VPN_GATEWAY" \
        -- --script=/etc/vpnc/vpnc-script \
        --servercert pin-sha256:Q02uZ8dlYvST5wLROI3r95xjFqtJzZSy8ZdprzdygWc=)

        # evpn.gobiernodecanarias.org \
        # --portal \
        # --csd-wrapper=/etc/vpnc/hipreport.sh \

# sudo openconnect \
#     --protocol=gp \
#     --user="$USERNAME" \
#     --script="$SCRIPT" \
#     "$VPN_GATEWAY"