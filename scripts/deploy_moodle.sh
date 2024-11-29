#!/bin/bash

# Configurar para mostrar los comandos
set -ex

# Si el archivo .env existe, lo cargamos
if [ -f .env ]; then
    source .env
else
    echo ".env no encontrado. Asegúrate de tener un archivo .env con las variables necesarias."
    exit 1
fi

# Actualizamos el sistema
sudo apt update

# Instalamos las extensiones de PHP necesarias
sudo apt install -y php-gd php-soap php-curl php-iconv php-mbstring php-intl php-zip php-xml php-sqlite3 php-fileinfo php-exif php-pdo php-ctype php-json

# Habilitamos el módulo PHP 8.3 en Apache si no está habilitado
sudo a2enmod php8.3

# Recargamos la configuración de Apache para aplicar los cambios
sudo systemctl reload apache2

# Instalación y configuración de Moodle
# Eliminar cualquier descarga previa de Moodle
rm -rf /tmp/moodle-latest-405.tgz*

# Descargar Moodle
wget https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz -P /tmp

# Extraemos el archivo descargado
tar -xzf /tmp/moodle-latest-405.tgz -C /tmp

# Crear el directorio de Moodle
sudo mkdir -p $MOODLE_DIRECTORY

# Limpiar el directorio de Moodle si ya existe
sudo rm -rf $MOODLE_DIRECTORY/*

# Mover los archivos de Moodle al directorio de destino
mv /tmp/moodle/* "$MOODLE_DIRECTORY"

# Cambiar los permisos de Moodle
sudo chown -R www-data:www-data "$MOODLE_DIRECTORY"

# Copiar el archivo .htaccess si existe en tu estructura de directorios
if [ -f "../htaccess/.htaccess" ]; then
    cp ../htaccess/.htaccess "$MOODLE_DIRECTORY"
else
    echo "El archivo .htaccess no se encuentra. Omitiendo copiado."
fi

# Copiar el archivo de configuración de Apache para el sitio
if [ -f "../conf/000-default.conf" ]; then
    cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf
else
    echo "El archivo de configuración de Apache no se encuentra. Omitiendo configuración."
fi

# Recargar Apache para aplicar la configuración de AllowOverride
sudo systemctl reload apache2

# Crear el directorio de datos de Moodle (asegurándonos de que tiene los permisos correctos)
mkdir -p /var/www/moodledata
sudo chown -R www-data:www-data /var/www/moodledata

# Copiar el archivo de configuración mod-config.php a la carpeta de Moodle
if [ -f "../conf/mod-config.php" ]; then
    cp ../conf/mod-config.php "$MOODLE_DIRECTORY/config.php"
else
    echo "El archivo mod-config.php no se encuentra. Omitiendo copiado."
fi

# Ajustar permisos para el archivo de configuración
sudo chown www-data:www-data "$MOODLE_DIRECTORY/config.php"
sudo chmod 644 "$MOODLE_DIRECTORY/config.php"

# Cambiar los permisos para el directorio de Moodle y Moodle Data
sudo chown -R www-data:www-data "$MOODLE_DIRECTORY"
sudo chown -R www-data:www-data /var/www/moodledata

# Reiniciar Apache después de las configuraciones de Moodle
sudo systemctl restart apache2

# Crear la base de datos de Moodle
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"

# Crear el usuario y asignar permisos a la base de datos
mysql -u root <<< "DROP USER IF EXISTS '$MOODLE_DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$MOODLE_DB_USER'@'%' IDENTIFIED BY '$MOODLE_DB_PASSWORD'"
mysql -u root <<< "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON $MOODLE_DB_NAME.* TO '$MOODLE_DB_USER'@'%'"
mysql -u root <<< "FLUSH PRIVILEGES"

# Verificamos que el cambio se aplicó correctamente
php -i | grep max_input_vars

# Reiniciar Apache nuevamente para asegurarse de que todos los cambios se apliquen
sudo systemctl restart apache2

# Reiniciar el servicio de MySQL
sudo service mysql restart

### Limpiar archivos temporales y caché

# Limpiar el caché de apt
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove

