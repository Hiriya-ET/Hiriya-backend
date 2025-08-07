FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev \
    libssl-dev pkg-config gnupg \
    && docker-php-ext-install mbstring exif pcntl bcmath

# Install MongoDB extension
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy project files
COPY . .

# Set permissions (optional, but good practice)
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

EXPOSE 8080
