FROM library/nginx:1.11-alpine

# TODO add in deamon off in config
# TODO add in nginx user

RUN apk --no-cache add bash ca-certificates openssl

COPY etc/scripts/ /etc/scripts/
COPY etc/nginx/ /etc/nginx/
COPY etc/ssl/dhparam.pem /etc/ssl/
COPY www/ /var/www/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /etc/nginx
CMD ["nginx", "-g", "daemon off;"]
