FROM php:8.1.30-apache-bookworm

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

RUN \
    # Download the koel release matching the version and remove anything not necessary for production
    curl -fSsL https://github.com/koel/koel/releases/download/v${VERSION}/koel-v${VERSION}.tar.gz \
        | tar -xz --strip-components=1 -C /var/www/html \
    && cd /var/www/html \
    && rm -rf .editorconfig \
        .eslintignore \
        .eslintrc \
        .git \
        .gitattributes \
        .github \
        .gitignore \
        .gitmodules \
        .gitpod.dockerfile \
        .gitpod.yml \
        api-docs \
        cypress \
        cypress.json \
        nginx.conf.example \
        package.json \
        phpstan.neon.dist \
        phpunit.xml.dist \
        resources/artifacts/ \
        ruleset.xml \
        scripts/ \
        tag.sh \
        vite.config.js \
    # Install koel runtime dependencies.
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        cron \
        libapache2-mod-xsendfile \
        libzip-dev \
        zip \
        ffmpeg \
        locales \
        libpng-dev \
        libjpeg62-turbo-dev \
        libpq-dev \
        libwebp-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    # https://laravel.com/docs/8.x/deployment#server-requirements
    # ctype, fileinfo, json, mbstring, openssl, tokenizer and xml are already activated in the base image
    && docker-php-ext-install \
        bcmath \
        exif \
        gd \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        zip \
    && apt-get install catatonit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html/storage/search-indexes \
    && chmod -R 777 /var/www/html/storage \
    # Set locale to prevent removal of non-ASCII path characters when transcoding with ffmpeg
    # See https://github.com/koel/docker/pull/91
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && /usr/sbin/locale-gen \
    && echo "memory_limit = 512M" > "$PHP_INI_DIR/conf.d/koel.ini" \
    && echo "upload_max_filesize = 800M" >> "$PHP_INI_DIR/conf.d/koel.ini" \
    && chmod -R go+rw /etc/apache2 /etc/apache2/sites-enabled/ \
    && sed --in-place -e 's#/var/www/html#/var/www/html/public#' /etc/apache2/sites-available/000-default.conf

# Deploy Apache configuration
RUN a2enmod rewrite

ENV FFMPEG_PATH=/usr/bin/ffmpeg \
    STREAMING_METHOD=x-sendfile \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY ./apps/koel/entrypoint.sh /entrypoint.sh

USER nobody:nogroup
WORKDIR /var/www/html

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
CMD ["apache2-foreground"]

LABEL org.opencontainers.image.source="https://github.com/koel/koel"
