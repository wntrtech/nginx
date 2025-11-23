#!/bin/sh
# vim:sw=4:ts=4:et

set -e

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

ME=$(basename "$0")
NGINX_CONF_FILE="etc/nginx/nginx.conf"
DEFAULT_CONF_FILE="etc/nginx/conf.d/default.conf"

if [ ! -f "/$DEFAULT_CONF_FILE" ]; then
    entrypoint_log "$ME: info: /$DEFAULT_CONF_FILE is not a file or does not exist"
    exit 0
fi

# check if the file can be modified, e.g. not on a r/o filesystem
touch /$DEFAULT_CONF_FILE 2>/dev/null || { entrypoint_log "$ME: info: can not modify /$DEFAULT_CONF_FILE (read-only file system?)"; exit 0; }

# check if the file can be modified, e.g. not on a r/o filesystem
touch /$NGINX_CONF_FILE 2>/dev/null || { entrypoint_log "$ME: info: can not modify /$NGINX_CONF_FILE (read-only file system?)"; exit 0; }

if [ -f "/etc/os-release" ]; then
    . /etc/os-release
else
    entrypoint_log "$ME: info: can not guess the operating system"
    exit 0
fi

# switch to port 8080 in default.conf listen sockets
sed -i -E 's,listen       80;,listen       8080;,' /$DEFAULT_CONF_FILE
sed -i -E 's,listen  \[::\]:80;,listen  [::]:8080;,' /$DEFAULT_CONF_FILE

entrypoint_log "$ME: info: Enabled listen on port 8080 in /$DEFAULT_CONF_FILE"

sed -i -E 's,user  nginx;,,' /$NGINX_CONF_FILE

exit 0
