
# Install phpMyAdmin 5
sudo apt install php-mbstring php-zip php-gd

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip

unzip phpMyAdmin-5.0.2-all-languages.zip

sudo mv phpMyAdmin-5.0.2-all-languages/ /usr/share/phpmyadmin

sudo mkdir -p /var/lib/phpmyadmin/tmp

sudo chown -R www-data:www-data /var/lib/phpmyadmin

sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

sudo nano /usr/share/phpmyadmin/config.inc.php

sudo apt install pwgen

uniquegen = $(pwgen -s 32 1)

sed -i "s/\\$cfg['blowfish_secret'\] = '';/\$cfg['blowfish_secret'\] = '$uniquegen';/g" /usr/share/phpmyadmin/config.inc.php
