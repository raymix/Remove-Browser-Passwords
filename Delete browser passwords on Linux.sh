#!/bin/bash

# Caveat: 
# Browsers load password file into memory, meaning this requires browser restart to take effect
# If user saves a new password, they will restore removed passwords.
# Make sure to block password manager via policy before running this script

paths=(
    /home/*/snap/chromium/common/chromium/Default/Login\ Data*
    /home/*/.config/microsoft-edge/Default/Login\ Data*
    /home/*/.config/google-chrome/Default/Login\ Data*
    /home/*/.config/BraveSoftware/Brave-Browser/Default/Login\ Data*
    /home/*/.mozilla/firefox/*/logins.json
    /home/*/.mozilla/firefox/*/key4.db
)

for path in "${paths[@]}"; do
    files=( "$path" )  # Expand the wildcard pattern
    for passwordFile in "${files[@]}"; do
        if [[ -f "$passwordFile" ]]; then  # Check if file exists
            echo "Removing $passwordFile"
            rm -rif "$passwordFile"
        fi
    done
done
