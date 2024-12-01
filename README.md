# practica-iaw-1.8
#Implantación de Moodle en Amazon Web Services (AWS)

##  1. Introducción
En esta práctica, vamos a instalar y configurar la aplicación web Moodle en Amazon Web Services (AWS). Moodle es una plataforma de gestión de cursos de código abierto, utilizada por instituciones educativas de todo el mundo.

La instalación de Moodle se realizará sobre una pila LAMP y configuraremos un certificado SSL/TLS utilizando Let's Encrypt para asegurar la conexión HTTPS.

En esta práctica también aprenderemos a usar algunos scripts de automatización para facilitar el proceso de configuración.

Para realizar la instalación de Moodle, es necesario conocer los requisitos del sistema y las extensiones de PHP necesarias. La documentación oficial de Moodle detalla todos los requisitos.

[Installing Moodle]([https://make.wordpress.org/cli/handbook/](https://docs.moodle.org/405/en/Installing_Moodle))

[Administration via command line]([https://developer.wordpress.org/cli/commands/](https://docs.moodle.org/405/en/Administration_via_command_line))


## 2.Creacion de una instancia EC2 en AWS e instalacion de Pila LAMP
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.1 y utilizaremos el script ``` install_lamp.sh ```.

**Esta vez tenemos la siguiente IP elastica para nuestra maquina**

 ![3Ugc2bqAY4](https://github.com/user-attachments/assets/c90aa8c9-5321-4489-bda4-e508349b0f4f)


[Practica-iaw-1.1](https://github.com/marinaferb92/practica-iaw-1.1/tree/main)

[Script Install LAMP](https://github.com/marinaferb92/practica-iaw-1.1/blob/main/scripts/install_lamp.sh)



Una vez hecho esto nos aseguraremos de que la Pila LAMP esta funcionando correctamente.

- Verificaremos el estado de apache.

  
  ![ZsjbEFIRRH](https://github.com/user-attachments/assets/d5eb21b5-3519-4787-8a35-d22fcda06cf1)


- Entramos en mysql desde la terminal para ver que esta corriendo.

 
  ![1hifxKi9yV](https://github.com/user-attachments/assets/ad485e3a-5459-42d9-90f3-e8262e8222ec)



## 3. Registrar un Nombre de Dominio

Usamos un proveedor gratuito de nombres de dominio como son Freenom o No-IP.
En nuestro caso lo hemos hecho a traves de No-IP, nos hemos registrado en la página web y hemos registrado un nombre de dominio con la IP pública del servidor.


   ![TwkcTIoiNE](https://github.com/user-attachments/assets/f66b4d80-4c6e-4251-a12c-26303bfdcc00)


## 4. Instalar Certbot y Configurar el Certificado SSL/TLS con Let’s Encrypt
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.5 y utilizaremos el script ``` setup_letsencrypt_certificate.sh ```.

[Practica-iaw-1.5](https://github.com/marinaferb92/practica-iaw-1.5)


  ![PsKwRkTpSO](https://github.com/user-attachments/assets/ccac2524-4dba-4111-b9b2-f37b8518358b)



# Instalación de Moodle en el servidor LAMP

Tras los pasos anteriores y que se hayan ejecutado exitosamente los scripts ``` install_lamp.sh ``` y ``` setup_letsencrypt_certificate.sh ```, el siguiente paso es instalar Moodle.:

### 1. Cargamos el archivo de variables
   
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```


### 2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```

### 3. Eliminamos las descargas previas de Moodle en /tmp

Elminiamos cualquier descarga previa de Modlee en el directorio temporal, para que en  caso de que ejecutemos el script varias veces no queden archivos residuales de las descargas anteriores 


```
rm -rf /tmp/moodle-latest-405.tgz*
```

### 4. Descarga y descompresión de Moodle

Descargamos la ultima versión estable de Moodle y la descomprimimos en el directorio temporal

````

wget https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz -P /tmp
tar -xzf /tmp/moodle-latest-405.tgz -C /tmp

````

### 5. Preparación del directorio de Moodle

Creamos el directorio donde se instalará Moodle, la variable *$MOODLE_DIRECTORY* estará definida en la en archivo `.env`.

Eliminamos cualquier instalación anterior y movemos los archivos extraidos en */tmp/moodle* al directorio que hemos creado.

````

sudo mkdir -p $MOODLE_DIRECTORY

sudo rm -rf $MOODLE_DIRECTORY/*

mv /tmp/moodle/* "$MOODLE_DIRECTORY"

````

### 6. Configuración de permisos y seguridad

Cambiamos la propiedad de todos los archivos de Moodle para que el usuario www-data (el usuario del servidor web Apache) tenga control sobre ellos y ajustamos los permisos para que el propietario tenga permisos completos y otros usuarios solo puedan leer y ejecutar los archivos.

```
chown -R www-data:www-data "$MOODLE_DIRECTORY"
chmod -R 755 "$MOODLE_DIRECTORY"
````

### 7. Creación y configuración del archivo htaccess.

Copiamos el archivo *.htaccess* que ha de tener esta estructura. 

```
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```
Este archivo se utiliza para configurar la seguridad y el acceso a los archivos en el servidor web.

```
cp ../htaccess/.htaccess "$MOODLE_DIRECTORY"
```


### 8. Creación y configuración del archivo 000-default.conf

Copia un archivo de configuración de Apache personalizado a la ubicación de configuracion determinada de Apache. Este archivo sirve para configurar el comportamiento de Apache a la hora de servir al sitio Moodle.

```
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf: 
```

### 9. Configuración de la base de datos de Moodle

Creamos un directorio moodledata en /var/www, este se usa para almacenar los archivos subidos por los usuarios a Moodle y los datos importantes de Moodle. Antes de esto, habremos eliminado cualquier directorio moodledata previo para no crear conflicto.

Cambiamos la propiedad del directorio a www-data y le damos permisos completos a este.

```
rm -rf /var/www/moodledata
mkdir /var/www/moodledata
chown -R www-data:www-data /var/www/moodledata
chmod -R 755 /var/www/moodledata
```

### 10. Instalación de las extensiones PHP requeridas para Moodle

Para que Moodle funcione correctamente habra que instalar unas extensiones adicionales de PHP:
- php-curl: Extensión para interactuar con otros servidores usando el protocolo HTTP.
- php-zip: Extensión para manejar archivos comprimidos.
- php-xml: Extensión para procesar archivos XML.
- php-mbstring: Extensión para manipulación de cadenas multibyte.
- php-gd: Extensión para trabajar con imágenes.

```
sudo apt remove -y php-curl php-zip php-xml php-mbstring php-gd
sudo apt install -y php-curl php-zip php-xml php-mbstring php-gd
```

Y tras esto reiniciaremos Apache para que carguen las nuevas extensiones.

```
systemctl restart apache2
```

### 11. Configuración de la base de datos MySQL

Creamos la base de datos de Moodle, las variables estaran todas definidas en el archivo .env

```
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"

```

Después crearemos el usuario para la base de datos y le daremos todos los privilegios sobre la base de datos.

```

mysql -u root <<< "DROP USER IF EXISTS '$MOODLE_DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$MOODLE_DB_USER'@'%' IDENTIFIED BY '$MOODLE_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO '$MOODLE_DB_USER'@'%'"

```

### 12. Instalación autmatica de Moodle 

Crearemos un comando con el que se realizará la instalación de la base de datos sin que tengamos que intervenir completando los pasos.

- *sudo -u www-data php "$MOODLE_DIRECTORY/admin/cli/install.php"*:
Ejecuta el script install.php para realizar la instalación de Moodle en modo no interactivo.
Pondremos todos los parámetros necesarios para la instalacion a continuación:
 - *--wwwroot*: La URL de Moodle (con http o https).
 - *--dataroot*: El directorio donde Moodle almacenará los archivos subidos (/var/www/moodledata).
 - *--dbtype*: El tipo de base de datos.
 - *--dbname*: El nombre de la base de datos.
 - *--dbuser*: El usuario de la base de datos.
 - *--dbpass*: La contraseña del usuario de la base de datos.
 - *--adminuser*: El nombre del usuario administrador de Moodle.
 - *--adminpass*: La contraseña del usuario administrador.

```
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
```

### 13. Configuración de PHP max_input_vars

Modificamos el archivo de configuración de PHP para establecer el valor de max_input_vars a 5000, para que PHP pueda manejar formularios grandes, como los formularios de configuración de Moodle.

```
sudo sed -i 's/^;*max_input_vars\s*=.*/max_input_vars = 5000/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;*max_input_vars\s*=.*/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini
```

Reiniciamos ApAche apra que se apliquen los cambios 

```
sudo systemctl restart apache2
```` 

### 14. Configurar la redirección HTTP a HTTPS

Configuramos la redirección de HTTP a HTTPS en Apache, asegurando que todas las solicitudes de HTTP sean redirigidas a HTTPS

````
echo "Configurando redirección de HTTP a HTTPS"
sudo sed -i '/<VirtualHost \*:80>/a Redirect permanent / https://'$MOODLE_URL'/' /etc/apache2/sites-available/000-default.conf
```` 

### 15. Verificación de configuración de Apache y estado del servicio

Reiniciamos Apache para aplicar cualquier cambio de configuración relacionado con la redirección, SSL y las nuevas configuraciones de seguridad y verificamos que funciona todo correctamente.

```
sudo apachectl configtest

sudo systemctl restart apache2

sudo systemctl status apache2
```

#Comprobaciones 

Entramos en el nombre de Dominio que hemos configurado para que sea nuestro Moodle

  ![UdAT0t1pj7](https://github.com/user-attachments/assets/9d32d865-b9cf-492f-b373-95648833dfda)


Nos logueamos con el Usuario administrador que hemos definido 

  ![J2kiITOx8l](https://github.com/user-attachments/assets/d38087f3-31d0-4405-a635-4d86af219c46)


Ya podemos comenzar a configurar nuestra plataforma con las asignaturas que queramos ponerles horarios, etc.

  ![z6UtYIOlJU](https://github.com/user-attachments/assets/421cb4f3-776b-49b1-b8c9-67342ee8e7f8)












