# export http_proxy="http://username:password@host:port"
# tce-load -wi bridge-utils.tcz

tce-load -wi make
tce-load -wi ncurses-utils.tcz

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
