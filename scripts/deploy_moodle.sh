#!/bin/bash


set -ex

# Importamos el archivo de variables
source .env


# Eliminamos descargas previas de Moodle en /tmp
rm -rf /tmp/moodle-latest-405.tgz*

# # Descargamos la última versión estable de Moodle

wget https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz -P /tmp

# Extraemos el archivo descargado
tar -xzf /tmp/moodle-latest-405.tgz -C /tmp

# Preparamos el directorio de instalación de Moodle


sudo mkdir -p $MOODLE_DIRECTORY
# Eliminamos cualquier archivo o instalación previa en el directorio de Moodle


sudo rm -rf $MOODLE_DIRECTORY/*

# Movemos los archivos extraídos al directorio de instalación de Moodle

mv /tmp/moodle/*  "$MOODLE_DIRECTORY"

# Cambiar los permisos de Moodlecd p    
chown -R www-data:www-data "$MOODLE_DIRECTORY" 
chmod -R 755 "$MOODLE_DIRECTORY"

# Copiamos el archivo .htaccess para configurar el acceso y seguridad en el servidor web


cp ../htaccess/.htaccess "$MOODLE_DIRECTORY"


# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

# Crear el directorio de datos de Moodle
rm -rf /var/www/moodledata
mkdir /var/www/moodledata
chown -R www-data:www-data /var/www/moodledata
chmod -R 755 /var/www/moodledata


#Instalamos las extensiones php requeridas para moodle
sudo apt remove -y php-curl php-zip php-xml php-mbstring php-gd
sudo apt install -y php-curl php-zip
# Reiniciamos Apache
systemctl restart apache2

# Crear la base de datos de Moodle
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"

# Crear el usuario y asignar permisos
mysql -u root <<< "DROP USER IF EXISTS '$MOODLE_DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$MOODLE_DB_USER'@'%' IDENTIFIED BY '$MOODLE_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO '$MOODLE_DB_USER'@'%'"

sudo -u www-data php "$MOODLE_DIRECTORY/admin/cli/install.php" \
  --wwwroot="$MOODLE_URL" \
  --dataroot="/var/www/moodledata" \
  --dbtype="mysqli" \
  --dbname="$MOODLE_DB_NAME" \
  --dbuser="$MOODLE_DB_USER" \
  --dbpass="$MOODLE_DB_PASSWORD" \
  --dbhost="localhost" \
  --fullname="Moodle Site" \
  --shortname="Moodle" \
  --adminuser="admin" \
  --adminpass="adminpassword" \
  --non-interactive \
  --agree-license

sudo sed -i 's/^;max_input_vars = 1000/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini


# Reiniciamos Apache
systemctl restart apache2