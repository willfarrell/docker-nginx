#!/bin/bash
set -e
#set -x

if [ "${1}" = 'nginx' ]; then

    # replace all set ${ENV}
    /etc/scripts/nginx_env
    /etc/scripts/make_csp

    /etc/scripts/bootstrap_https

	# custom startup script
	/etc/scripts/bootstrap

fi

echo "${@}"
exec "${@}"
