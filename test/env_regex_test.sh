#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export ENV_EXISTS=PASS

./../etc/scripts/nginx_env $DIR

