#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

# Actualizamos el sistema
apt update

# Actualiza paquetes
apt upgrade -y  

# Instalamos Apache
apt install apache2 -y

# Habilitamos el módulo rewrite
a2enmod rewrite

# Instalamos PHP 8.0 y los módulos necesarios
sudo apt install php8.0 php8.0-cli php8.0-fpm php8.0-mysql php8.0-mbstring php8.0-xml php8.0-intl php8.0-curl php8.0-zip -y

# Habilitamos PHP 8.0 en Apache
sudo a2enmod php8.0
sudo systemctl restart apache2

# Corregir permisos en el directorio de Moodle
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Corregir permisos en el directorio de datos de Moodle
sudo chown -R www-data:www-data $MOODLE_DATA_DIRECTORY
sudo chmod -R 775 $MOODLE_DATA_DIRECTORY

# Instalamos la extensión intl de PHP
sudo apt install php8.0-intl -y
sudo systemctl restart apache2

# Ajustar max_input_vars en php.ini
sudo sed -i 's/max_input_vars = 1000/max_input_vars = 5000/' /etc/php/8.0/apache2/php.ini

# Reiniciar Apache para aplicar los cambios en php.ini
sudo systemctl restart apache2

# Instalamos MySQL
apt install mysql-server -y

# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/

# Copiamos el script de prueba PHP
cp ../php/index.php /var/www/html

# Modificamos el propietario y el grupo del archivo index.php
sudo chown -R www-data:www-data /var/www/html

# Reiniciamos el servicio de Apache
systemctl restart apache2