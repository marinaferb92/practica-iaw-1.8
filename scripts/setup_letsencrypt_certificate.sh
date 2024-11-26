#!/bin/bash

#Importamos el archivo de variables

source .env

# Configuramos para mostrar los comandos 
set -ex

#Instalamos y acctualizamos snapd
snap install core
snap refresh core

#Eliminamos si existiese alguna instalación previa de certbot con apt
sudo apt remove certbot -y

#Instalamos el cliente de Certbot con snapd
 snap install --classic certbot

#Obtenemos el certificado y configuramos el servidor web Apache.
sudo certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

