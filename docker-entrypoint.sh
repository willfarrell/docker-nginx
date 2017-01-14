#!/bin/bash
set -e
#set -x

if [ "${1}" = 'nginx' ]; then

    # replace all set ${ENV}
    /etc/scripts/nginx_env
    /etc/scripts/make_csp

    if [ "${NGINX_ENV}" == 'staging' ] || [ "${NGINX_ENV}" == 'production' ]; then
        while [ ! -f /etc/ssl/${NGINX_DOMAIN}/privkey.pem ] \
            || [ ! -f /etc/ssl/${NGINX_DOMAIN}/cert.pem ] \
            || [ ! -f /etc/ssl/${NGINX_DOMAIN}/chain.pem ] \
            || [ ! -f /etc/ssl/${NGINX_DOMAIN}/fullchain.pem ]; do
            echo "docker run willfarrell/letsencrypt ..."
            sleep 10;
         done;

         /etc/scripts/make_hpkp
    else
        /etc/scripts/make_ecdsa_cert
    fi

    # validate configs
    nginx -t

fi

echo "${@}"
exec "${@}"
