FROM library/nginx:1.11

####### ENV #######

# TODO add in deamon off in config
# TODO add in nginx user

RUN apt-get update -y \
    && apt-get install -y \
        openssl \
        cron \
        wget

# Allows for openssl=1.1.0, not in jessie repo
COPY etc/apt/stretch.list /etc/apt/sources.list.d/
COPY etc/apt/preferences /etc/apt/preferences

RUN apt-get update -y \
    && apt-get install -t stretch -y openssl

# certbot
RUN cd /usr/bin \
    && wget https://dl.eff.org/certbot-auto \
    && chmod a+x certbot-auto \
    && certbot-auto --os-packages-only --non-interactive

RUN apt-get purge -y --auto-remove \
        wget

COPY etc/scripts /etc/scripts
COPY etc/nginx/ /etc/nginx/
COPY etc/ssl/ /etc/ssl/
VOLUME /etc/ssl

COPY www/ /var/www/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]


####### Connection #######
WORKDIR /etc/nginx
CMD ["nginx", "-g", "daemon off;"]
