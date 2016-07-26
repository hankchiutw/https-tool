#!/bin/sh

wget https://dl.eff.org/certbot-auto -P /usr/local/bin/
chmod a+x /usr/local/bin/certbot-auto

# do install process
/usr/local/bin/certbot-auto
