FROM composer:2 AS composer

FROM php:8-cli-alpine AS extensions

RUN apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS

RUN pecl install xdebug
RUN rm -rf /tmp/* &&\
    apk del .phpize-deps

FROM php:8-cli-alpine AS final

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN echo "export PATH=\"$PATH:$HOME/.composer/vendor/bin\"" > $HOME/.profile &&\
    source $HOME/.profile

COPY --from=extensions /usr/local/lib/php/extensions/no-debug-non-zts-20210902/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20210902/xdebug.so

RUN docker-php-ext-enable xdebug

RUN apk add --update git openssh

RUN addgroup -g 1000 developer && adduser -u 1000 -h /home/developer -G developer -s /bin/sh -D developer
