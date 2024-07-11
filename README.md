
# Laravel Deployment Automation

This project automates the deployment of a Laravel-PHP web application with MySQL on a bare server using Ansible. It also includes a separate containerization option using Docker.

## Prerequisites

Ensure you have the following installed on your local machine:

- Ansible
- Git
- Docker

## Project Structure

```
.
├── application
│   └── bare_server
│       └── (Laravel application files)
├── group_vars
│   └── all.yml
├── roles
│   ├── composer
│   ├── mysql
│   ├── nginx
│   ├── php
│   └── setup
├── laravel-deploy.yml
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Ansible Deployment

### Configuration

1. Clone this repository:
   ```
   git clone https://github.com/your-username/laravel-deployment-automation.git
   cd laravel-deployment-automation
   ```

2. Update the `group_vars/all.yml` file with your specific variables:
   ```yaml
   mysql_root_password: your_root_password
   mysql_database: your_database_name
   mysql_user: your_database_user
   mysql_password: your_database_password
   laravel_app_key: your_laravel_app_key
   ```

3. Update the `hosts` file with your target server's IP address or hostname:
   ```
   [webservers]
   your_server_ip_or_hostname
   ```

### Roles

The project uses the following Ansible roles:

- `setup`: Prepares the server environment
- `php`: Installs and configures PHP
- `mysql`: Installs and configures MySQL
- `nginx`: Installs and configures Nginx
- `composer`: Installs Composer and manages Laravel dependencies

### Deployment

To deploy the Laravel application, run:

```
ansible-playbook -i hosts laravel-deploy.yml
```

This playbook will:

1. Set up the server environment
2. Install and configure PHP, MySQL, and Nginx
3. Install Composer and Laravel dependencies
4. Configure the Laravel application
5. Set up the database
6. Configure Nginx for the Laravel application

## Containerization

For a containerized deployment, we provide a Docker-based solution.

### Dockerfile

The `Dockerfile` in the root directory defines the Laravel application container:

```dockerfile
FROM php:8.1-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libzip-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY ./application/bare_server /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Change current user to www-data
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
```

### Docker Compose

The `docker-compose.yml` file orchestrates the Laravel application, MySQL, and Nginx containers:

```yaml
version: '3'
services:

  #PHP Service
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: laravel-app
    container_name: app
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: app
      SERVICE_TAGS: dev
    working_dir: /var/www
    volumes:
      - ./application/bare_server:/var/www
      - ./php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - app-network

  #Nginx Service
  webserver:
    image: nginx:alpine
    container_name: webserver
    restart: unless-stopped
    tty: true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./application/bare_server:/var/www
      - ./nginx/conf.d/:/etc/nginx/conf.d/
    networks:
      - app-network

  #MySQL Service
  db:
    image: mysql:5.7.22
    container_name: db
    restart: unless-stopped
    tty: true
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql
    volumes:
      - dbdata:/var/lib/mysql/
      - ./mysql/my.cnf:/etc/mysql/my.cnf
    networks:
      - app-network

#Docker Networks
networks:
  app-network:
    driver: bridge

#Volumes
volumes:
  dbdata:
    driver: local
```

### Running with Docker

To deploy the containerized version:

1. Build the Docker images:
   ```
   docker-compose build
   ```

2. Start the containers:
   ```
   docker-compose up -d
   ```

3. Access the application at `http://localhost`

To stop the containers:
```
docker-compose down
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
