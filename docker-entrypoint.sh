#!/bin/bash
set -e
#set -x

if [ "${1}" = 'nginx' ]; then

    # replace all set ${ENV}
    /etc/scripts/nginx_env
    /etc/scripts/make_csp

    if [ "${NGINX_ENV}" == 'staging' ] || [ "${NGINX_ENV}" == 'production' ]; then
        /etc/scripts/make_letsencrypt_cert

        # run twice a day
        MIN=$((RANDOM%59))
        HOUR=$((RANDOM%6))
        HOUR2=$(($HOUR+12))
        echo "${MIN} ${HOUR},${HOUR2} * * * /etc/scripts/make_letsencrypt_cert" > /etc/cron.d/certbot
        cat /etc/cron.d/certbot
        service cron start
    else
        /etc/scripts/make_ecdsa_cert ${NGINX_DOMAIN}
    fi

    # validate configs
    nginx -t

fi

echo "${@}"
exec "${@}"
