#!/bin/sh
set -eu

# See: [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

# Add Docker's official GPG key
apt-get update && apt-get --yes install \
	ca-certificates \
	curl \
	gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to APT sources
printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable' \
	"$(dpkg --print-architecture)" "$(. /etc/os-release && echo $VERSION_CODENAME)" |
	tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install the latest version
apt-get update && apt-get --yes install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin
