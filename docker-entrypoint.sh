#!/bin/bash
set -e
#set -x

update_hpkp() {
    if [ ! -f /etc/ssl/${NGINX_DOMAIN}/cert.pem ]; then
        echo "docker run willfarrell/letsencrypt ..."
        sleep 5
        update_hpkp &
    else
        echo "non-selfcertificate found"
        /etc/scripts/make_hpkp
        nginx -t
        exec "${@}"
    fi

}
if [ "${1}" = 'nginx' ]; then

    # replace all set ${ENV}
    /etc/scripts/nginx_env
    /etc/scripts/make_csp

    if [ ! -f /etc/ssl/${NGINX_DOMAIN}/cert.pem ]; then
        /etc/scripts/make_ecdsa_cert
        rm /etc/ssl/${NGINX_DOMAIN}/cert.pem
        update_hpkp &
    else
        # calls: nginx -t && exec "${@}"
        update_hpkp
    fi

    nginx -t
fi

echo "${@}"
exec "${@}"
