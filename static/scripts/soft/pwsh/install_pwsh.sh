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

if grep -q POWERSHELL_TELEMETRY_OPTOUT /etc/environment; then
  ok "POWERSHELL_TELEMETRY_OPTOUT already exists in /etc/environment"
else
  echo "POWERSHELL_TELEMETRY_OPTOUT=1" | sudo tee -a /etc/environment
  ok "POWERSHELL_TELEMETRY_OPTOUT added to /etc/environment"
fi


if command -v pwsh &> /dev/null; then 
    ok "Powershell is already installed"
    exit 0
fi

OS_RELEASE="/etc/os-release"
if [ -f "$OS_RELEASE" ]; then
    # shellcheck disable=SC1090
    source "$OS_RELEASE"
    
    if [ -z "$ID" ]; then
        # shellcheck disable=SC2016
        fail 'Unable to determine the OS. $ID is not set in /etc/os-release'
        exit 1
    fi

    U="$USER"
    if [ -n "$SUDO_USER" ]; then
        U="$SUDO_USER"
    fi

    if [ -z "$U" ]; then
        fail "Unable to determine the current user"
        exit 1
    fi

    DOWNLOAD_DIR="/home/$U/Downloads"

    if [ -z "$PWSH_VERSION" ]; then
        PWSH_VERSION="7.4.1"
    fi

    if [ ! -d "$DOWNLOAD_DIR" ]; then
        mkdir -p "$DOWNLOAD_DIR"
        sudo chown -R "$U":"$U" "$DOWNLOAD_DIR"
    fi

    ARCH="$(uname -m)"
    if [ "$ARCH" != "x86_64" ]; then
        fail "Unsupported architecture: $ARCH"
        exit 1
    fi

    case $ID in
        "ubuntu" | "debian")
            export DEBIAN_FRONTEND=noninteractive

            sudo apt-get install -y --no-install-recommends apt-transport-https curl software-properties-common gnupg

            if [ ! -f "/etc/apt/keyrings/microsoft.gpg" ]; then
                curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
                sudo chmod a+r /etc/apt/keyrings/microsoft.gpg
            fi

            if [ ! -f "/etc/apt/sources.list.d/microsoft.list" ]; then
                if [ "$ID" = "ubuntu" ]; then
                    VERSION_CODENAME=$(lsb_release -cs)
                else
                    VERSION_CODENAME=$(lsb_release -cs | sed 's|/|-|g')
                fi

                URL="https://packages.microsoft.com/config/ubuntu/${VERSION_CODENAME}/prod"
                DEB_ARCH="$(dpkg --print-architecture)"
                SOURCE="deb [arch=${DEB_ARCH} signed-by=/etc/apt/keyrings/microsoft.gpg] ${URL} ${VERSION_CODENAME} main"
                echo "$SOURCE" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
            fi
            
            sudo apt-get update -y
            sudo apt-get install powershell -y
            ok "Powershell installed"
            exit 0
            ;;
        "rhel")
            if [ "$(bc<<<"$VERSION_ID < 8")" = 1 ]; then majorver=7
            elif [ "$(bc<<<"$VERSION_ID < 9")" = 1 ]; then majorver=8
            else majorver=9
            fi

            # Register the Microsoft RedHat repository
            URL="https://packages.microsoft.com/config/rhel/$majorver/packages-microsoft-prod.rpm"
            curl -sSL -O "$URL"

            # Register the Microsoft repository keys
            sudo rpm -i packages-microsoft-prod.rpm

            # Delete the repository keys after installing
            rm packages-microsoft-prod.rpm

            sudo yum install -y curl

            # RHEL 7.x uses yum and RHEL 8+ uses dnf
            if [ "$(bc<<<"$majorver < 8")" ]
            then
                # Update package index files
                sudo yum update
                # Install PowerShell
                sudo yum install powershell -y
            else
                # Update package index files
                sudo dnf update
                # Install PowerShell
                sudo dnf install powershell -y
            fi
            ok "Powershell installed"
            exit 0
            ;;

        "alpine")
            sudo apk add --no-cache \
                ca-certificates \
                less \
                ncurses-terminfo-base \
                krb5-libs \
                libgcc \
                libintl \
                libssl1.1 \
                libstdc++ \
                tzdata \
                userspace-rcu \
                zlib \
                icu-libs \
                curl

            sudo apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
                lttng-ust

            URL="https://github.com/PowerShell/PowerShell/releases/download/v$PWSH_VERSION/powershell-$PWSH_VERSION-linux-musl-x64.tar.gz"

            # Download the powershell '.tar.gz' archive5    
            curl -L  -o /tmp/powershell.tar.gz

            # Create the target folder where powershell will be placed
            sudo mkdir -p /opt/microsoft/powershell/7

            # Expand powershell to the target folder
            sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

            # Set execute permissions
            sudo chmod +x /opt/microsoft/powershell/7/pwsh

            # Create the symbolic link that points to pwsh
            sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
            ok "Powershell installed"
            exit 0
            ;;
        *)
            fail "Unsupported OS: $ID"
            exit 1
            ;;
    esac
fi

# we're most likely on macOS
if command -v brew &> /dev/null; then
    brew install powershell/tap/powershell
    ok "Powershell installed"
    exit 0
fi

if [ -n "$OS" ]; then
    if [ "$OS" = "Windows_NT" ]; then
        if command -v choco &> /dev/null; then
            choco install powershell-core -y
            ok "Powershell installed"
            exit 0
        elif command -v winget &> /dev/null; then
            winget install -e --id Microsoft.PowerShell
            ok "Powershell installed"
            exit 0
        else 
            fail "Unable to install Powershell. Neither choco nor winget is installed."
            exit 1
        fi
    fi
fi