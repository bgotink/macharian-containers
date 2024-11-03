#!/usr/bin/env bash
#shellcheck disable=SC2086

: ${PORT:=8080}
: ${MEDIA_PATH:=/music}

sed --in-place \
    -e "s/:80/:${PORT}/" \
    -e "s|</VirtualHost>|XSendFile on\nXSendFilePath ${MEDIA_PATH}\n</VirtualHost>|" \
    /etc/apache2/sites-enabled/000-default.conf

sed --in-place \
    -s "s/Listen\s80/Listen ${PORT}/" \
    /etc/apache2/ports.conf

exec \
    docker-php-entrypoint \
        "$@"
