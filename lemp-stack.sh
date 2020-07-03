#!/bin/bash

# Install mandatory files
apt install curl nano


# Install nginx from nginx repo
sudo apt install curl gnupg2 ca-certificates lsb-release


echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    
echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
    
sudo apt-key fingerprint ABF5BD827BD9BF62
     
sudo apt update -y
    
sudo apt install nginx

# Install MariaB

sudo apt -y update
sudo apt -y install software-properties-common gnupg2

sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.liquidtelecom.com/repo/10.4/debian buster main'

sudo apt update -y

sudo apt install mariadb-server mariadb-client

# PHP 7.4
sudo apt -y install lsb-release apt-transport-https ca-certificates 
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

sudo apt update -y

sudo apt-get install php7.4-fpm php7.4-bcmath php7.4-bz2 php7.4-curl php7.4-common php7.4-json php7.4-xml php7.4-intl php7.4-gd php7.4-mbstring php7.4-mysql php7.4-zip


# Secure mysql installation
sudo mysql_secure_installation
