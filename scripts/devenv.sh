#!/bin/bash

apt update
apt -y upgrade
apt -y install git \
               redis-tools \
               mariadb-client \
               gnupg2 \
               ssh-client \
               socat \
               sudo \
               lsof \
               tree \
               jq \
               procps \
               psutils \
               nano

pecl install xdebug
docker-php-ext-enable xdebug

useradd --shell /bin/bash --create-home --home-dir /home/devenv --uid 1000 -U devenv
echo "devenv ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

curl -fsSL https://deb.nodesource.com/setup_23.x -o /tmp/nodesource_setup.sh
chmod +x /tmp/nodesource_setup.sh
bash -E /tmp/nodesource_setup.sh

apt install -y nodejs

rm -f /tmp/nodesource_setup.sh

cat /tmp/scripts/bashrc >> /home/devenv/.bashrc

printf 'if [ -d "\$HOME/.bun/bin" ]; then\n    export PATH="\$HOME/.bun/bin:\$PATH"\nfi\n' >> /home/devenv/.profile
