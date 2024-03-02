#!/bin/bash

if [ ! -f "vendor/autoload.php" ]; then
    # composer update
    composer install --no-progress --no-interaction
fi

if [ ! -f ".env" ]; then
    echo "Creating .env file for $APP_ENV"
    cp .env.example .env
else
    echo "The .env file exitst!"
fi

role=${CONTAINER_ROLE:-app}
if [ "$role" = "app" ]; then
    php artisan key:generate --no-interaction
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan migrate --no-interaction

    php artisan serve --port=$PORT --host=0.0.0.0 --env=.env

    exec docker-php-entrypoint "$@"
elif [ "$role" = "queue" ]; then
    echo "Running the queue ..."
    php /var/www/artisan queue:work --verbose --tries=3 --timeout=180
fi
