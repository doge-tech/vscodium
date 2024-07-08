#!/usr/bin/bash

set -e

GH_HOST="github.com"
VSCODIUM_REPO="VSCodium/vscodium"

LOCAL_VERSIONS=$( git submodule foreach 'echo $name `git describe --contains`' )

git pull --recurse-submodules

# Check for newer VSCodium release
echo "[i] Checking for newer VSCodium release..."
GITHUB_RESPONSE=$( curl -s "https://api.${GH_HOST}/repos/${VSCODIUM_REPO}/releases/latest" )
VSCODIUM_VERSION=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.tag_name' )
LOCAL_VSCODIUM_VERSION=$( echo "${LOCAL_VERSIONS}" | awk '/^vscodium/ {print $NF}' )

echo "[i] Local VSCodium version: ${LOCAL_VSCODIUM_VERSION}"

if [[ "${VSCODIUM_VERSION}" == "${LOCAL_VSCODIUM_VERSION}" ]]; then
	echo "[i] VSCodium is up to date."
else
	echo "[i] Newer VSCodium release available ($VSCODIUM_VERSION)!"
	cd vscodium
	git checkout ${VSCODIUM_VERSION}
	cd ..
	LOCAL_VERSIONS=$( git submodule foreach 'echo $name `git describe --contains`' )
	LOCAL_VSCODIUM_VERSION=$( echo "${LOCAL_VERSIONS}" | awk '/^vscodium/ {print $NF}' )
fi

# Check VSCode is up to date
LOCAL_VSCODE_VERSION=$( echo "${LOCAL_VERSIONS}" | awk '/^vscode/ {print $NF}' )
IFS='.' read -ra VSCODIUM_VERSION_PARTS <<< "${LOCAL_VSCODIUM_VERSION}"
VSCODIUM_SHORT_VERSION="${VSCODIUM_VERSION_PARTS[0]}.${VSCODIUM_VERSION_PARTS[1]}.${VSCODIUM_VERSION_PARTS[2]}"

echo "[i] Local VSCode version: ${LOCAL_VSCODE_VERSION}"

if [[ "${LOCAL_VSCODE_VERSION}" == "${VSCODIUM_SHORT_VERSION}" ]]; then
	echo "[i] VSCode is up to date."
else
	echo "[i] VSCode needs to be updated to ${VSCODIUM_SHORT_VERSION}"
	cd vscode
	git checkout ${VSCODIUM_SHORT_VERSION}
	LOCAL_VERSIONS=$( git submodule foreach 'echo $name `git describe --contains`' )
	LOCAL_VSCODE_VERSION=$( echo "${LOCAL_VERSIONS}" | awk '/^vscode/ {print $NF}' )
fi
