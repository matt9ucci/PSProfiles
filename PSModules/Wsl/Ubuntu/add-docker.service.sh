#!/bin/sh
set -eu

# See: [Configuring remote access with systemd unit file](https://docs.docker.com/config/daemon/remote-access/)

SYSTEMD_EDITOR='tee' systemctl edit docker.service <<eof
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375
eof

systemctl daemon-reload

systemctl restart docker.service
