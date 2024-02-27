---
title: Apt
---

Advanced Package Tool ("APT") is package management system for applications,
libraries, and even configuration for Debian and Debian based systems like
Ubuntu, Mint, and Pop!_OS.

There are related tools like `apt-get` and `apt-cache` that are used to manage
packages and search for packages.  Apt and apt-get interact with dpkg to install
and remove packages. Apt handles dependencies and can install multiple packages
at once, while dpkg does not handle dependencies and installs one package at a
time.

Operations that make changes to the system require root access and require
confirmation. This is to prevent accidental changes to the system.  The `-y`
flag can be used to automatically confirm changes.

Some installs may have an interactive prompt.  This can be disabled with
`DEBIAN_FRONTEND=noninteractive` environment variable.

Running apt from a script will result in warnings about an unstable api.  
Apt-get is considered the more stable api.

It should be possible to remove the warning by setting
`Apt::Cmd::Disable-Script-Warning` to `true` in `/etc/apt/apt.conf`.

## Install

This will install the package and any recommended packages.

```bash
sudo apt install -y <package>
```

```bash
sudo apt-get install -y <package>
```

### Install a Specific Version

```bash
sudo apt install -y <package>=<version>
```

```bash
sudo apt-get install -y <package>=<version>
```

### Install without recommended packages

```bash
sudo apt install --no-install-recommends -y <package>
```

```bash
sudo apt-get install -y --no-install-recommends <package>
```

## List

List installed packages that matches pattern.

```bash
apt list <pattern>
```

### Quiet List

Quiet gets rid of the additional output such as "Listing... Done"

```bash
apt list --installed --qq <pattern>
```

## Purge

Purge behaves the same as remove with the addition of removing
any system level configuration files.  Files in the home
directory will remain untouched.

```bash
sudo apt purge -y <package>
```

```bash
sudo apt-get purge -y <package>
```

## Remove

Remove only removes the specific package and not any of the dependencies.  To remove unused dependencies, call `apt autoremove`

```bash
sudo apt remove -y <package>
```

### Remove a specific version

```bash
sudo apt remove -y <package>=<version>
```

### AutoRemove

```bash
sudo apt autoremove -y
```

```bash
sudo apt-get autoremove -y
```

## Search

Searching for a package can be done with `apt search` or `apt-cache search`.
The search is performed against apt sources and not the local system.

```bash
apt search <package>
```

### Quiet Search

```bash
apt search -qq <package>
```

## Upgrade

Upgrading a package is generally done after runing `sudo apt update`
which updates all the sources to get the latest available versionsp
of packages.

```bash
sudo apt install -y --only-upgrade <package>
# or
sudo apt update -y && sudo apt install -y --only-upgrade <package>
```

```bash
sudo apt-get install -y --only-upgrade <package>
```

### Upgrade all packages

```bash
sudo apt upgrade -y
# or
sudo apt update -y && sudo apt upgrade -y
```

```bash
sudo apt-get upgrade -y
#or
sudo apt-get update -y && sudo apt upgrade -y
```
