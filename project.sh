#!/bin/bash

#update your linux system
sudo apt update -y
#install your apache webserver
sudo apt install apache2 -y
#add the php ondrej repository
sudo add-apt-repository ppa:ondrej/php
#update your repository again
sudo apt update -y
# install php8.2
sudo apt install php8.2 -y
#install some of those php dependencies that are needed for laravel to work
sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y
#enable rewrite
sudo a2enmod rewrite
#restart your apache server
sudo systemctl restart apache2
#change directory in the bin directory
cd /usr/bin
install composer
sudo curl -sS https://getcomposer.org/installer | sudo php
#move the content of the deafault composer.phar
sudo mv composer.phar composer
#change directory in /var/www directory so we can clone of laravel repo there
cd /var/www/
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R root laravel
cd laravel/
#install composer autoloader
composer install --optimize-autoloader --no-dev --no-interaction
composer update --no-interaction
#copy the content of the default env file to .env 
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache
#cd /etc/apache2/sites-available/
sudo touch latest.conf
sudo echo '<VirtualHost *:80>
    ServerName 192.168.56.5
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/latest.conf
sudo a2ensite latest.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
sudo apt install mysql-server -y
sudo apt install mysql-client -y
sudo systemctl start mysql
sudo mysql -uroot -e "CREATE DATABASE Ehijator;"
sudo mysql -uroot -e "CREATE USER 'Amagbewan'@'localhost' IDENTIFIED BY 'felix';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON Ehijator.* TO 'Amagbewan'@'localhost';"
cd /var/www/laravel
sudo sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=mysql/' .env
sudo sed -i 's/DB_HOST=localhost/DB_HOST=localhost/' .env
sudo sed -i 's/DB_PORT=3306/DB_PORT=3306/' .env
sudo sed -i 's/DB_DATABASE=Ehijator/DB_DATABASE=Ehijator/' .env
sudo sed -i 's/DB_USERNAME=Amagbewan/DB_USERNAME=Amagbewan/' .env
sudo sed -i 's/DB_PASSWORD=felix/DB_PASSWORD=felix/' .env
sudo php artisan key:generate
sudo php artisan storage:link
sudo php artisan migrate
sudo php artisan db:seed
sudo systemctl restart apache2
