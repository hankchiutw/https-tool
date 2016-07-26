# HTTPS tool

Shell scripts to enable Let's Encrypt.

For detail, check [https://github.com/certbot/certbot](https://github.com/certbot/certbot)

### Folder structure
```bash
.
├── README.md               # this file
├── build-test.sh           # test creating .pem files. Usage: sudo ./build-test.sh DOMAIN EMAIL
├── build.sh                # create .pem files. Usage: sudo ./build.sh DOMAIN EMAIL DEST
├── install.sh              # install Let's Encrypt client wrapper certbot-auto. Usage: sudo ./install.sh
└── renew.sh                # do cert renewal. Usage: sudo ./cert-renew.sh
```

### Quick start
```bash
git clone https://github.com/hankchiutw/https-tool.git
cd https-tool
sudo ./install.sh
sudo ./build.sh admin@example.com example.com /data/cert
```

### How it works
Install Let's Encrypt client -> Build .pem files -> (Setup your https server) -> Schedule certification renewal.

#### install.sh
It will install `certbot-auto` under `/usr/local/bin/`. `certbot-auto` is a wrapped Let's Encrypt client.

To install manually:
```bash
wget https://dl.eff.org/certbot-auto
chmod a+x ./certbot-auto

# do install process
./certbot-auto
```

#### build.sh: create .pem files
Provide adminstrator's email(`--email`) and domain name of current machine(`-d`).

Use `--test-cert` first, once ok, use without `--test-cert`.
```bash
./certbot-auto certonly --test-cert --standalone --email admin@example.com -d example.com
```

The certificated files will be stored in `/etc/letsencrypt/live/`.

#### Running with Docker
If the above methods with `certbot-auto` are not applicable, use Docker as descibed [here](http://letsencrypt.readthedocs.io/en/latest/using.html#running-with-docker).

```bash
sudo docker run -it --rm -p 443:443 -p 80:80 --name certbot \
            -v "/etc/letsencrypt:/etc/letsencrypt" \
            -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
            quay.io/letsencrypt/letsencrypt:latest auth
```

But you still need `certbot-auto` to do renewal.

#### Renew
The certification will be [expired every 90 days](http://letsencrypt.readthedocs.io/en/latest/using.html#renewal). To do renewal:
```
./certbot-auto renew
```

For production, schedule renew.sh as a cron event:
```
# m h dom mon dow user  command
00 00    1 * *   root    /usr/local/renew.sh

```

### Example nginx setting with proxy and SSL

Replace *public.ip*, *public.domain.name* and .pem file location in your context.

```
upstream internal {
    server public.ip:80;
    keepalive 256;
}

server {
    listen         80;
    server_name    public.domain.name;
    return         301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name    public.domain.name;

# HTTPS server

    ssl on;
    ssl_certificate cert/fullchain.pem;
    ssl_certificate_key cert/privkey.pem;

    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass  http://internal/;
        proxy_set_header   Connection "";
        proxy_http_version 1.1;
        proxy_set_header        Host            $host;
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    }

}
```


### References
- [Let's Encrypt user guide](http://letsencrypt.readthedocs.io/en/latest/using.html)
- [GitHub: certbot](https://github.com/certbot/certbot)
