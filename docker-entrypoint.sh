#!/bin/bash
set -e
#set -x

update_hpkp() {
    if [ ! -f /etc/ssl/$1/cert.pem ]; then
        sleep 5
        update_hpkp $1 &
    else
        echo "certificate for $1 found"
        /etc/scripts/make_hpkp $1
        nginx -t
        set +e
        nginx -s reload 2> /dev/null
        set -e
    fi

}
if [ "${1}" = 'nginx' ]; then

    # replace all set ${ENV}
    /etc/scripts/nginx_env
    /etc/scripts/make_csp

    #for domain in $(echo ${NGINX_DOMAIN} | sed "s/,/ /g"); do
    domain=${NGINX_DOMAIN}
    echo "setup certificate for ${domain}"
    if [ ! -f /etc/ssl/${domain}/cert.pem ]; then
        /etc/scripts/make_ecdsa_cert ${domain}
        rm /etc/ssl/${domain}/cert.pem
        echo "docker run -e ... -v ... willfarrell/letsencrypt dehydrated --cron --out /etc/ssl --domain ${domain} --challenge ..."
        update_hpkp ${domain} &
        nginx -t
    else
        update_hpkp ${domain}
    fi
    #done

fi

echo "${@}"
exec "${@}"
