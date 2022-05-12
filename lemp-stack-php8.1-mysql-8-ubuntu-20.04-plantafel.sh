#!/bin/bash

apt update && apt upgrade -y

# Install mandatory files
apt install -y curl htop wget sudo git


# Install nginx from nginx repo
sudo apt install -y gnupg2 ca-certificates lsb-release

deb https://nginx.org/packages/ubuntu/ focal nginx
deb-src https://nginx.org/packages/ubuntu/ focal nginx

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
sudo apt update
        
sudo apt update -y
    
sudo apt install -y nginx

# Install MySQL 8

sudo apt -y update
sudo apt install -y mysql-server

# PHP 8.1
sudo apt update
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php

sudo apt update -y

sudo apt-get install -y php8.1-fpm php8.1-bcmath php8.1-bz2 php8.1-curl php8.1-common php8.1-xml php8.1-intl php8.1-gd php8.1-mbstring php8.1-mysql php8.1-zip


# Secure mysql installation
# Zuerst
# ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'mynewpassword'; 
# ausführen
# sudo mysql_secure_installation

# NODEJS
sudo curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -

sudo sh -c "echo deb https://deb.nodesource.com/node_17.x focal main > /etc/apt/sources.list.d/nodesource.list"
sudo apt-get update
sudo apt-get install nodejs

# VISUDO

#ALL ALL=NOPASSWD: /bin/systemctl start laravel_echo_dev
#ALL ALL=NOPASSWD: /bin/systemctl stop laravel_echo_dev
#ALL ALL=NOPASSWD: /bin/systemctl restart laravel_echo_dev
#ALL ALL=NOPASSWD: /bin/systemctl status laravel_echo_dev
#ALL ALL=NOPASSWD: /bin/systemctl start laravel_echo_staging
#ALL ALL=NOPASSWD: /bin/systemctl stop laravel_echo_staging
#ALL ALL=NOPASSWD: /bin/systemctl restart laravel_echo_staging
#ALL ALL=NOPASSWD: /bin/systemctl status laravel_echo_staging
#ALL ALL=NOPASSWD: /bin/systemctl start laravel_echo_production
#ALL ALL=NOPASSWD: /bin/systemctl stop laravel_echo_production
#ALL ALL=NOPASSWD: /bin/systemctl restart laravel_echo_production
#ALL ALL=NOPASSWD: /bin/systemctl status laravel_echo_production

#ALL ALL=NOPASSWD: /www/plantafel-digital/sudoscripts/update_nginx_conf *

sudo mkdir -p /www/plantafel-digital/sudoscripts
sudo cp /www/plantafel-digital/dev/sh/update_nginx_conf /www/plantafel-digital/sudoscripts/update_nginx_conf

sudo chmod +Xx /www/plantafel-digital/sudoscripts/update_nginx_conf

# CERTBOT

# CRONJOBS
(crontab -l ; echo "14 5 * * * /usr/bin/certbot renew --quiet --post-hook "/usr/sbin/service nginx reload" > /dev/null 2>&1") | crontab -

(crontab -l -u www-data ; echo "* * * * * cd $SCRIPTDIR && php artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -
