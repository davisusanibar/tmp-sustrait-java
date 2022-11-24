#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail

echo "Validate Sonatype OSSRH Credentials."
CODE=$(curl -u "$SONATYPE_USER:$SONATYPE_PASSWORD" -sSL -w '%{http_code}' -o /dev/null https://s01.oss.sonatype.org/service/local/staging/profiles)
if [[ "$CODE" =~ ^2 ]]; then
    echo "Sonatype OSSRH Credentials configured successfully."
else
    echo "Error to get the profile. Server returned HTTP code $CODE."
fi

echo "Validate Signing Private/Public Key."
gpg --list-secret-keys $SIGNING_KEY_ID
echi "Validate passphrase"
#echo $SIGNING_KEY | base64 --decode | gpg  --import
#gpg --list-secret-keys
echo "dummy_value" | gpg -q --batch --status-fd 1 --sign --local-user $SIGNING_KEY_ID --passphrase-fd 0 > /dev/null

