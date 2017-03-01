# nginx

base nginx image w/ prebuild nginx confs

## Use
```Dockerfile
FROM willfarrell/nginx

COPY etc/nginx/conf/csp_policies.conf /etc/nginx/conf/

COPY etc/nginx/conf.d/ /etc/nginx/conf.d/
COPY www /var/www
```

## Testing
```bash
docker build -t base_nginx .
docker rm -f base_nginx
docker run --name base_nginx -p 80:80 -p 443:443 base_nginx
```

```bash
docker-compose build
docker-compose up -d
```

## letsencrypt
docker build --tag letsencrypt letsencrypt
docker stop letsencrypt
docker rm letsencrypt

# private
docker run \
    --volumes-from nginx_nginx_1 \
    --env-file letsencrypt.env \
    willfarrell/letsencrypt \
    dehydrated \
        --cron --domain certbot.willfarrell.ca \
        --hook dehydrated-dns \
        --challenge dns-01

# tmp
docker run \
    --volumes-from nginx_nginx_1 \
    --env-file letsencrypt.env \
    willfarrell/letsencrypt \
    ls /etc/ssl

# public
docker run -d \
    --volumes-from nginx_nginx_1 \
    --env-file letsencrypt.env \
    willfarrell/letsencrypt \
    dehydrated \
        --cron --domain certbot.willfarrell.ca \
        --challenge http-01

docker exec -it nginx_nginx_1 /etc/scripts/make_hpkp
docker exec -it nginx_nginx_1 /etc/init.d/nginx reload                                                                          

## ENV
```bash
# development: self-signed cert
# staging: untrusted letsencrypt signed cert
# production: trusted letsencrypt signed cert
NGINX_ENV={development,staging,production}
NGINX_DOMAIN=

CERTBOT_EMAIL=
#CERTBOT_RENEW_PERIOD=1296000

HPKP_BACKUP_CERT_1=/etc/ssl/certs/COMODO_Certification_Authority.pem
HPKP_BACKUP_CERT_2=/etc/ssl/certs/GlobalSign_Root_CA.pem
HPKP_REPORT_URI=https://*****.report-uri.io/r/default/hpkp/enforce

CSP_REPORT_URI=https://*****.report-uri.io/r/default/csp/enforce
```

## Sample.conf
```
server_tokens off;

include		conf/logging.conf;
include		conf/csp_policies.conf;
include		conf/timeout.conf;
include		conf/forcehttps.conf;

proxy_cache_path /tmp/cache keys_zone=microcache:10m levels=1:2 inactive=300s max_size=100m use_temp_path=off;

server {
    server_name $host;

    listen 443 ssl http2;
    listen [::]:443 ssl http2;
	include		conf/https.ecdsa.conf;

    access_log  /var/log/nginx/access.log logstash_params buffer=256k flush=10s;
	error_log	/var/log/nginx/error.log;

	root		/var/www;

	gzip_static on;

    # Custom Error Pages
	error_page 504 /504.json;
    location = /504.json {
        root /usr/share/nginx/html;
        internal;
    }

	location / {
        include     conf/header/security.conf;
        include     conf/header/https.conf;
	    include		conf/header/cors.conf;

	    #try_files $uri $uri/index.html =404;
	    try_files $uri @rewriteapp;
    }

    location @rewriteapp {
        include     conf/header/security.conf;
        include     conf/header/https.conf;
	    include	    conf/header/cors.conf;
	    add_header  X-Request-Id $request_id;
	    
	    include	    conf/header/proxy_upgrade.conf;

        include     conf/microcache.conf;

        # Requested here to allow $request_body to get generated
        access_log        /var/log/nginx/access.log logstash_params buffer=256k flush=10s;
        proxy_set_header  X-Request-Id $request_id;
        proxy_pass        http://apigateway;

        # Request Timeout
        proxy_connect_timeout       120;
        proxy_send_timeout          120;
        proxy_read_timeout          120;
        send_timeout                120;
    }
}

upstream apigateway  {
     keepalive 20;
     server node:3000 fail_timeout=5s max_fails=5;
}
```