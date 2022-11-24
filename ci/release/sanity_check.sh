#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail
export GPG_TTY=$(tty)

echo "START: Validate Sonatype OSSRH Credentials."
CODE=$(curl -u "$SONATYPE_USER:$SONATYPE_PASSWORD" -sSL -w '%{http_code}' -o /dev/null https://s01.oss.sonatype.org/service/local/staging/profiles)
if [[ "$CODE" =~ ^2 ]]; then
    echo "Sonatype OSSRH Credentials configured successfully."
else
    echo "Error to get the profile. Server returned HTTP code $CODE."
fi
echo "END: Validate Sonatype OSSRH Credentials."

echo "START: Validate Signing Private/Public Key."
echo "Import private key."
echo $SIGNING_KEY | base64 --decode | gpg --batch --import
echo "Get Keygrip."
KEYGRIP=`gpg --with-keygrip --list-secret-keys $SIGNING_KEY_ID | sed -e '/^ *Keygrip  *=  */!d;s///;q'`
echo "Configure caching passphrase."
allow-preset-passphrase  >> ~/.gnupg/gpg-agent.conf
gpgconf --reload gpg-agent
echo "Preset passphrase on cache."
"$(gpgconf --list-dirs libexecdir)/gpg-preset-passphrase" -c $KEYGRIP <<< $SIGNING_PASSWORD
echo "Test passphrase."
echo "1234" | gpg -q --batch --status-fd 1 --sign --local-user $SIGNING_KEY_ID --passphrase-fd 0 > /dev/null
echo "END: Validate Signing Private/Public Key."
