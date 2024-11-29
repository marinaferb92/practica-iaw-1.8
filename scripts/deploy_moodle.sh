#!/bin/bash
set -ex

# Importamos el archivo de variables
source .env

# Eliminamos descargas previas de Moodle
rm -rf /tmp/moodle-latest-405.tgz*

# Descargamos Moodle
wget https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz -P /tmp

# Extraemos el archivo descargado
tar -xzf /tmp/moodle-latest-405.tgz -C /tmp


sudo mkdir -p $MOODLE_DIRECTORY

sudo rm -rf $MOODLE_DIRECTORY/*

mv /tmp/moodle/*  "$MOODLE_DIRECTORY"

# Cambiar los permisos de Moodlecd p    
chown -R www-data:www-data "$MOODLE_DIRECTORY" 

cp ../htaccess/.htaccess "$MOODLE_DIRECTORY"


# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

# Crear el directorio de datos de Moodle
mkdir -p /var/www/moodledata
chown -R www-data:www-data /var/www/moodledata

# Reiniciamos Apache
systemctl restart apache2

# Crear la base de datos de Moodle
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"

# Crear el usuario y asignar permisos
mysql -u root <<< "DROP USER IF EXISTS '$MOODLE_DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$MOODLE_DB_USER'@'%' IDENTIFIED BY '$MOODLE_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO '$MOODLE_DB_USER'@'%'"

# Reiniciar Apache nuevamente
sudo systemctl restart apache2