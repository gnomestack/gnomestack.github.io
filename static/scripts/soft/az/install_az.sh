#!/usr/bin/bash

function ok() {
    MSG=$1
    printf "\e[32m%s\e[0m" "$MSG"
    echo ""
}

function fail() {
    MSG=$1
    printf "\e[31m%s\e[0m" "$MSG"
    echo ""
}

function info() {
    MSG=$1
    printf "\e[34m%s\e[0m" "$MSG"
    echo ""
}

if command -v az &> /dev/null; then 
    ok "Azure cli is already installed"
    exit 0
fi

OS_RELEASE="/etc/os-release"
if [ -f "$OS_RELEASE" ]; then
    source "$OS_RELEASE"

    if [ -z "$ID" ]; then
        fail 'Unable to determine the OS. $ID is not set in /etc/os-release'
        exit 1
    fi

    case "$ID" in
        "ubuntu")
                if [ -z "$VERSION_ID" ]; then
                    fail 'Unable to determine the OS version. $VERSION_ID is not set in /etc/os-release'
                    exit 1
                fi

                sudo apt-get install -y --no-install-recommends \
                    ca-certificates \
                    curl \
                    apt-transport-https \
                    gnupg

                if [ ! -d "/etc/apt/keyrings" ]; then
                    sudo mkdir -p /etc/apt/keyrings
                fi
            ;;
        *)
            fail "Unsupported OS: $ID"
            exit 1
            ;;
    esac

   
fi
