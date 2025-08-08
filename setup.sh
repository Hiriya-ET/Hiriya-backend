#!/bin/bash

echo "Starting Laravel + MongoDB project setup..."

# 1. Start Docker containers
echo "Starting Docker containers..."
docker-compose up -d --build

# 2. Copy .env if not present
if [ ! -f .env ]; then
    echo "Copying .env.example to .env..."
    cp .env.example .env
else
    echo ".env already exists, skipping..."
fi

# 3. Install Composer dependencies inside the backend container
echo "Installing Composer dependencies..."
docker-compose exec backend composer install

# 4. Generate the application key
echo "Generating APP_KEY..."
docker-compose exec backend php artisan key:generate

# 5. Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
until docker exec mongodb mongosh --eval "db.stats()" >/dev/null 2>&1
do
    echo "Waiting for MongoDB..."
    sleep 2
done
echo "MongoDB is ready."

# 6. (Optional) Seed data if a seeder exists
read -p "Do you want to run seeders? (y/n): " seed
if [ "$seed" == "y" ]; then
    echo " Running seeders..."
    docker-compose exec backend php artisan db:seed
fi

echo "Setup complete! Visit your app at: http://localhost:8080"
