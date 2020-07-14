#!/bin/sh

read -p "Host name (including subdomain if wanted)? [example.com]: " hostname
hostname=${hostname:-example.com}

read -p "PHP Version? [7.4]: " phpversion
phpversion=${phpversion:-7.4}

read -p "Root path? /var/www/html/laravel/public: " rootpath
rootpath=${rootpath:-/var/www/html/laravel/public}

dhparam=/etc/nginx/certs/dhparam-2048.pem
if [ ! -f "$dhparam" ]; then

    echo "Create dhparam file $dhparam"
    openssl dhparam -out $dhparam 2048
fi

cat > /etc/nginx/conf.d/$hostname.conf << EOL

    server {

        listen      80;
        server_name $hostname;

        listen       443 ssl default_server;
        #add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

        ssl_certificate         /etc/nginx/certs/server.crt;
        ssl_certificate_key     /etc/nginx/certs/private/server.key;
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

        index index.php index.html;

        root $rootpath;
            
        error_log /var/log/nginx/$subdomain.error.log;
        access_log /var/log/nginx/$subdomain.access.log;
        
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        location ~ \.php\$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)\$;
            fastcgi_pass   unix:/run/php/php${phpversion}-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

    }
EOL
