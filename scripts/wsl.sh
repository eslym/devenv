#!/bin/bash
set -e

apt update
apt install -y systemd systemd-sysv dbus polkitd
printf "[user]\ndefault=devenv\n[boot]\nsystemd=true\n" > /etc/wsl.conf
