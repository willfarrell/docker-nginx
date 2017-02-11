FROM library/nginx:1.11-alpine

RUN apk add --no-cache --virtual .run-deps \
        bash ca-certificates openssl

COPY etc/scripts/ /etc/scripts/
COPY etc/nginx/ /etc/nginx/
COPY etc/ssl/dhparam.pem /etc/ssl/
COPY www/ /var/www/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

#RUN apk add --no-cache --virtual .health-check curl
#HEALTHCHECK --interval=5s --timeout=3s \
#    CMD curl --silent --fail http://localhost/robots.txt || exit 1

WORKDIR /etc/nginx
CMD ["nginx", "-g", "daemon off;"]
