#!/bin/sh

# Install phpMyAdmin 5
sudo apt install -y php7.4-mbstring php7.4-zip php7.4-gd wget

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip

unzip phpMyAdmin-5.0.2-all-languages.zip

sudo mv phpMyAdmin-5.0.2-all-languages/ /usr/share/phpmyadmin

sudo mkdir -p /var/lib/phpmyadmin/tmp

sudo chown -R www-data:www-data /var/lib/phpmyadmin

sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

sudo nano /usr/share/phpmyadmin/config.inc.php

sudo apt install -y pwgen

uniquegen=$(pwgen -s 32 1)

# Set blowfish secret
sed -i "s/\\$cfg['blowfish_secret'\] = '';/\$cfg['blowfish_secret'\] = '$uniquegen';/g" /usr/share/phpmyadmin/config.inc.php

# replace comments
sed -i "s|// \\$cfg\['Servers'\]|\\$cfg\['Servers'\]|g" /usr/share/phpmyadmin/config.inc.php

sed -i "s|\$cfg\['Servers'\]\[\$i\]\['controlhost'\] = '';|\$cfg\['Servers'\]\[\$i\]\['controlhost'\] = 'localhost';|g" /usr/share/phpmyadmin/config.inc.php
sed -i "s|\$cfg\['Servers'\]\[\$i\]\['controlport'\] = '';|\$cfg\['Servers'\]\[\$i\]\['controlport'\] = '3306';|g" /usr/share/phpmyadmin/config.inc.php

controlpass=$(pwgen -s 64 1)
sed -i "s|\$cfg\['Servers'\]\[\$i\]\['controlpass'\] = '.*';|\$cfg\['Servers'\]\[\$i\]\['controlpass'\] = '${controlpass}';|g" /usr/share/phpmyadmin/config.inc.php

# Create table
sudo mariadb < /usr/share/phpmyadmin/sql/create_tables.sql

sudo mariadb --execute="GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY '$controlpass'; FLUSH PRIVILEGES;"
