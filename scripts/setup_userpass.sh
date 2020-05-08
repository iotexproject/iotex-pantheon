#!/bin/sh

# This install script is intended to download and install the latest available
# release of the ioctl dependency manager for Golang.
#
# It attempts to identify the current platform and an error will be thrown if
# the platform is not supported.
#
# Environment variables:
# - INSTALL_DIRECTORY (optional): defaults to $GOPATH/bin (if $GOPATH exists) 
#   or /usr/local/bin (else)
# - CLI_RELEASE_TAG (optional): defaults to fetching the latest release
#
# You can install using this script:
# $ curl https://raw.githubusercontent.com/iotexproject/iotex-core/master/install-cli.sh | sh

set -e

DOWNLOAD_BASE_URL="https://github.com/iotexproject/installer4b/blob/master/bin"
RAW_TRUE="raw=true"
INSTALL_DIRECTORY='/usr/local/bin'

downloadFile() {
    url="$1"
    destination="$2"

    echo "Fetching $url.."
    if test -x "$(command -v curl)"; then
        code=$(curl -s -w '%{http_code}' -L "$url" -o "$destination")
    elif test -x "$(command -v wget)"; then
        code=$(wget -q -O "$destination" --server-response "$url" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        echo "Neither curl nor wget was available to perform http requests."
        exit 1
    fi

    if [ "$code" != 200 ]; then
        echo "Request failed with code $code"
        cp bin/$BINARY $destination
        if [ $? -ne 0 ];then
            cp ../bin/$BINARY $destination
            if [ $? -ne 0 ];then
                exit 1
            fi
        fi
    fi
}

initArch() {
    ARCH=$(uname -m)
    case $ARCH in
        amd64) ARCH="amd64";;
        x86_64) ARCH="amd64";;
        #aarch64) ARCH="arm64";;
        *) echo "Architecture ${ARCH} is not supported by this installation script"; exit 1;;
    esac
    echo "ARCH = $ARCH"
}

initOS() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    OS_CYGWIN=0
    case "$OS" in
        darwin) OS='darwin';;
        linux) OS='linux';;
        mingw*) OS='windows';;
        msys*) OS='windows';;
	cygwin*)
	    OS='windows'
	    OS_CYGWIN=1
	    ;;
        *) echo "OS ${OS} is not supported by this installation script"; exit 1;;
    esac
    echo "OS = $OS"
}

# identify platform based on uname output
initArch
initOS

# assemble expected release artifact name
BINARY="userpass-${OS}-${ARCH}"

# add .exe if on windows
if [ "$OS" = "windows" ]; then
    BINARY="$BINARY.exe"
fi

BINARY_URL="${DOWNLOAD_BASE_URL}/${BINARY}?${RAW_TRUE}"
DOWNLOAD_FILE=$(mktemp)

downloadFile "$BINARY_URL" "$DOWNLOAD_FILE"

echo "Setting executable permissions."
chmod +x "$DOWNLOAD_FILE"

INSTALL_NAME="userpass"

if [ "$OS" = "windows" ]; then
    INSTALL_NAME="$INSTALL_NAME.exe"
    echo "Moving executable to $HOME/$INSTALL_NAME"
    mv "$DOWNLOAD_FILE" "$HOME/$INSTALL_NAME"
else
    echo "Moving executable to $INSTALL_DIRECTORY/$INSTALL_NAME"
    sudo mv "$DOWNLOAD_FILE" "$INSTALL_DIRECTORY/$INSTALL_NAME"
fi
