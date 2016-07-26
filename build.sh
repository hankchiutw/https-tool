#!/bin/sh

DOMAIN=$1
EMAIL=$2
DEST=$3 # where to store .pem files

# create
echo creating...
/usr/local/bin/certbot-auto certonly --standalone --email $EMAIL -d $DOMAIN

# copy
echo copying...
mkdir -p $DEST
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $DEST
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $DEST

echo done.
