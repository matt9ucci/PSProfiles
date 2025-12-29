#!/bin/sh
set -eu

sudo snap install powershell --classic
pwsh -c 'git clone https://github.com/matt9ucci/PSProfiles.git (Split-Path $PROFILE)'
