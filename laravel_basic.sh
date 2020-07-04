read -p "Host name? [example.com]: " hostname
hostname=${hostname:-example.com}

cat > /etc/nginx/conf.d/$hostname.conf << EOL

    server {

        listen      80;
        server_name $hostname;

        listen       443 ssl default_server;
        #add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

        ssl_certificate         "/usr/local/nginx/conf/cert/ssl-bundle.crt";
        ssl_certificate_key     "/usr/local/nginx/conf/cert/private/server.key";
        ssl_dhparam cert/dhparam.pem;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout  30m;
        ssl_session_tickets off;
        #ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
        ssl_prefer_server_ciphers on;
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 8.8.8.8 8.8.4.4 valid=300s;
        resolver_timeout 5s;

        index index.php index.html;

        location / {

            root /var/www/html/fs/public;
            index index.php;

            try_files \$uri \$uri/ /index.php?\$query_string;

             location ~ \.php\$ {
                        fastcgi_pass   unix:/run/php/php7.3-fpm.sock;
                        fastcgi_index  index.php;
                        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
                        include        fastcgi_params;
             }
        }

    }
EOL
