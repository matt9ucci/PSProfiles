#!/bin/bash

sudo apt-get update
sudo apt-get install -y curl unzip

curl -fsSL https://fnm.vercel.app/install | bash

export PATH="~/.local/share/fnm:$PATH"
eval "`fnm env`"

fnm install --lts

npm install -g @devcontainers/cli
