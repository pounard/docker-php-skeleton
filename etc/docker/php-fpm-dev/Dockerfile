FROM php:8.2-fpm
RUN apt-get update && apt-get install -y \
        # Git
        git \
        # Zip
        libzip4 \
        libzip-dev \
        # GD
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        # PostgreSQL
        libpq-dev \
    # OpCache!
    && docker-php-ext-install -j$(nproc) opcache \
    # GD
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    # Zip support (for composer)
    && docker-php-ext-install -j$(nproc) zip \
    # PostgreSQL support
    && docker-php-ext-install -j$(nproc) pdo_pgsql \
    && docker-php-ext-install -j$(nproc) pgsql \
    # Install XDebug
    && pecl install xdebug-3.2.0 \
    && docker-php-ext-enable pgsql xdebug
