#!/bin/bash

# Caveat: 
# Browsers load password file into memory, meaning this requires browser restart to take effect
# If user saves a new password, they will restore removed passwords.
# Make sure to block password manager via policy before running this script

# Do not use quotes here
paths=(
    /Users/*/Library/Application\ Support/BraveSoftware/Brave-Browser/Default/Login\ Data*
    /Users/*/Library/Application\ Support/Google/Chrome/Default/Login\ Data*
    /Users/*/Library/Application\ Support/Microsoft\ Edge/Default/Login\ Data*
    /Users/*/Library/Application\ Support/Firefox/Profiles/*/logins.json
)

for path in "${paths[@]}"; do
    files=("$path")  # Expand the wildcard pattern
    for passwordFile in "${files[@]}"; do
        if [[ -f "$passwordFile" ]]; then  # Check if file exists
            echo "Removing $passwordFile"
            rm -rif "$passwordFile"
        fi
    done
done