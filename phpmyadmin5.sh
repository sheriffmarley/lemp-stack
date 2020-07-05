#!/bin/sh

# Install phpMyAdmin 5
sudo apt install -y php7.4-mbstring php7.4-zip php7.4-gd wget apache2-utils unzip

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip

unzip phpMyAdmin-5.0.2-all-languages.zip

sudo mv phpMyAdmin-5.0.2-all-languages/ /usr/share/phpmyadmin

sudo mkdir -p /var/lib/phpmyadmin/tmp

sudo chown -R www-data:www-data /var/lib/phpmyadmin

phpMyAdminConfig=/usr/share/phpmyadmin/config.inc.php

sudo cp /usr/share/phpmyadmin/config.sample.inc.php $phpMyAdminConfig

sudo apt install -y pwgen

uniquegen=$(pwgen -s 32 1)

# Set blowfish secret
sed -i "s/\$cfg['blowfish_secret'\] = '';/\$cfg['blowfish_secret'\] = '$uniquegen';/g" $phpMyAdminConfig

# replace comments
sed -i "s|// \$cfg\['Servers'\]|\$cfg\['Servers'\]|g" $phpMyAdminConfig

sed -i "s|\$cfg\['Servers'\]\[\$i\]\['controlhost'\] = '';|\$cfg\['Servers'\]\[\$i\]\['controlhost'\] = 'localhost';|g" $phpMyAdminConfig
sed -i "s|\$cfg\['Servers'\]\[\$i\]\['controlport'\] = '';|\$cfg\['Servers'\]\[\$i\]\['controlport'\] = '3306';|g" $phpMyAdminConfig

controlpass=$(pwgen -s 64 1)
sed -i "s|\$cfg\['Servers'\]\[\$i\]\['controlpass'\] = '.*';|\$cfg\['Servers'\]\[\$i\]\['controlpass'\] = '${controlpass}';|g" $phpMyAdminConfig

# Create table
sudo mariadb < /usr/share/phpmyadmin/sql/create_tables.sql

sudo mariadb --execute="GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY '$controlpass'; FLUSH PRIVILEGES;"


read -p "Host name? [example.com]: " hostname
hostname=${hostname:-example.com}

read -p "Subdomain? [phpmyadmin]: " subdomain
subdomain=${subdomain:-phpmyadmin}

read -p "PHP Version? [7.4]: " phpversion
phpversion=${phpversion:-7.4}

read -p "Root path? /var/www/html/$subdomain/: " root
root=${laravelpath:-/var/www/html/$subdomain/public}

ORIGINCERT=/etc/nginx/certs/cloudflare-origin.crt
if [ ! -f "$ORIGINCERT" ]; then
    
    mkdir -p /etc/nginx/certs

    echo "Download cf origin cert"
    wget https://support.cloudflare.com/hc/en-us/article_attachments/360044928032/origin-pull-ca.pem

    mv origin-pull-ca.pem $ORIGINCERT
fi

htpasswdfile=/etc/nginx/.htpasswd
read -p ".htaccess user? " htaccessuser
sudo htpasswd -c $htpasswdfile $htaccessuser

dhparam=/etc/nginx/certs/dhparam-2048.pem
if [ ! -f "$dhparam" ]; then

    echo "Create dhparam file $dhparam"
    openssl dhparam -out $dhparam 2048
fi

cat > /etc/nginx/conf.d/$subdomain.$hostname.conf << EOL
    server {
    
        server_name  $subdomain.$hostname;
        listen       443 ssl default_server;
        #add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
        ssl_certificate         /etc/nginx/certs/ssl-bundle.crt";
        ssl_certificate_key     /etc/nginx/certs/private/server.key";
        ssl_dhparam $dhparam;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout  30m;
        ssl_session_tickets off;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers on;
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 8.8.8.8 8.8.4.4 valid=300s;
        resolver_timeout 5s;
        
        ssl_client_certificate $ORIGINCERT;
        ssl_verify_client on;
    
        index index.php index.html;
        
        root $root;
        
        auth_basic "";
        auth_basic_user_file $htpasswdfile;
        
        error_log /var/log/nginx/$subdomain.error.log;
        access_log /var/log/nginx/$subdomain.access.log;
        
        location / {
            try_files $uri $uri/ =404;
        }
        
        location ~ \.php\$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass   unix:/run/php/php${phpversion}-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }
    }
EOL
