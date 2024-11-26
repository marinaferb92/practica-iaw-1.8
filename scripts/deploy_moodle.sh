#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables
source .env

#Borramos descargas previas moodle.git
rm -rf /tmp/moodle.git

#Descargamos el archivo moodle.git
git clone -b MOODLE_403_STABLE git://git.moodle.org/moodle.git /tmp/moodle.git

mv /tmp/moodle.git/* /var/www/html

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Crear la base de datos y el usuario
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME;"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root <<< "DROP USER IF EXISTS $MOODLE_DB_USER@$MOODLE_DB_HOST;"
mysql -u root <<< "CREATE USER $MOODLE_DB_USER@$MOODLE_DB_HOST IDENTIFIED BY '$MOODLE_DB_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO $MOODLE_DB_USER@$MOODLE_DB_HOST;"

# Instalación de Moodle desde CLI
sudo -u www-data /usr/bin/php $MOODLE_DIRECTORY/admin/cli/install.php \
  --chmod=2770 \
  --lang=es \
  --wwwroot=$MOODLE_URL \
  --dataroot=$MOODLE_DATA_DIRECTORY \
  --dbtype=mysqli \
  --dbhost=$MOODLE_DB_HOST \
  --dbname=$MOODLE_DB_NAME \
  --dbuser=$MOODLE_DB_USER \
  --dbpass=$MOODLE_DB_PASSWORD \
  --fullname="Moodle Site" \
  --shortname="Moodle" \
  --adminuser=$ADMIN_USER \
  --adminpass=$ADMIN_PASSWORD \
  --adminemail=$ADMIN_EMAIL \
  --agree-license \
  --non-interactive

 # Activar modo mantenimiento antes de actualizaciones o tareas críticas
sudo -u www-data /usr/bin/php $MOODLE_DIRECTORY/admin/cli/maintenance.php --enable

# Actualizar Moodle y verificar integridad
sudo -u www-data /usr/bin/php $MOODLE_DIRECTORY/admin/cli/upgrade.php --non-interactive

# Purgar cachés (opcional)
sudo -u www-data /usr/bin/php $MOODLE_DIRECTORY/admin/cli/purge_caches.php

# Desactivar modo mantenimiento
sudo -u www-data /usr/bin/php $MOODLE_DIRECTORY/admin/cli/maintenance.php --disable 

# Configurar tareas agendadas (cron)
(crontab -l 2>/dev/null; echo "*/15 * * * * /usr/bin/php $MOODLE_DIRECTORY/admin/cli/cron.php > /dev/null 2>&1") | crontab -