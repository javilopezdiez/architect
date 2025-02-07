#!/bin/bash

# Fix gp_saml_gui.py
mymodder.sh \
        --file "$HOME/.local/lib/python3.11/site-packages/gp_saml_gui.py" \
        --codefile "$HOME/.local/bin/mysrc/init_poolmanager.py"


# Set up split tunneling vpnc-script ENVIRONMENTALS
mymodder.sh \
        --file "/etc/vpnc/vpnc-script" \
        --before "# =========== script (variable) setup ====================================" \
        --codefile "$HOME/.local/bin/mysrc/tunneling.txt"

eval $(gp-saml-gui -P \
        --gateway \
        --allow-insecure-crypto \
        --no-verify \
        --clientos=Windows \
        evpn.gobiernodecanarias.org \
        -- --script=/etc/vpnc/vpnc-script \
        )
        # --csd-wrapper=/etc/vpnc/hipreport.sh \
        