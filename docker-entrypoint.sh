#!/bin/bash
set -e
#set -x

if [ "${1}" = 'nginx' ]; then

    # replace all set ${ENV}
    /etc/scripts/nginx_env /etc/nginx
    /etc/scripts/make_csp

    /etc/scripts/bootstrap_https
    
    # custom startup script
    /etc/scripts/nginx_env /var/www
    /etc/scripts/bootstrap

fi

echo "${@}"
exec "${@}"
