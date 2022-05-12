#!/bin/bash

apt update && apt upgrade -y

# Install mandatory files
apt install -y curl htop wget sudo


# Install nginx from nginx repo
sudo apt install -y gnupg2 ca-certificates lsb-release


echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    
echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
    
sudo apt-key fingerprint ABF5BD827BD9BF62
     
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

sudo apt-get install -y php8.1-fpm php8.1-bcmath php8.1-bz2 php8.1-curl php8.1-common php8.1-json php8.1-xml php8.1-intl php8.1-gd php8.1-mbstring php8.1-mysql php8.1-zip


# Secure mysql installation
sudo mysql_secure_installation
