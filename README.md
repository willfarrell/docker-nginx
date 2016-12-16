# nginx

Creates ECDSA certs based on ENV

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

## TODO
- switch default to alpine
- Travis CI testing
- RSA option
- Unit test for ENV replacement
- move letsencrypt into its own docker container
- allow multiple domains

## ENV
```
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
#daemon off;
#worker_processes auto;
#events {
#  worker_connections 4096;
#}

server_tokens off;

include		conf/logging.conf;
include		conf/csp_policies.conf;
include		conf/timeout.conf;
include		conf/forcehttps.conf;

proxy_cache_path /tmp/cache keys_zone=microcache:10m levels=1:2 inactive=300s max_size=100m use_temp_path=off;

server {
	include		conf/https.ecdsa.conf;

    access_log  /var/log/nginx/access.log logstash buffer=256k flush=10s;
	error_log	/var/log/nginx/error.log;

	root		/var/www;

	gzip_static on;

	location / {
        include     conf/header/security.conf;
        include     conf/header/https.conf;
	    include		conf/header/cors.conf;

	    try_files $uri @rewriteapp;
    }

    location @rewriteapp {
        include     conf/header/security.conf;
        include     conf/header/https.conf;
	    include		conf/header/cors.conf;
        include     conf/header/microcache.conf;

        include     conf/microcache.conf;
        proxy_pass  http://apigateway;
    }
}

upstream apigateway  {
    keepalive 20;
    server node:3000 fail_timeout=5s max_fails=5;
}
```