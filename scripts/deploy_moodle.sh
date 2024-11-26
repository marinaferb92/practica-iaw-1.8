#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables
source .env

#Borramos descargas previas moodle-latest-402.tgz
rm -rf /tmp/moodle-latest-402.tgz

#Descargamos el archivo moodle-latest-402.tgz
wget https://download.moodle.org/stable402/moodle-latest-402.tgz -P /tmp

tar -xzvf moodle-latest-402.tgz


