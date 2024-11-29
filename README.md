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

  ![bNabA1Ww5l](https://github.com/user-attachments/assets/ec67113e-343c-4890-8086-6d0cb5e3d4e9)

[Practica-iaw-1.1](https://github.com/marinaferb92/practica-iaw-1.1/tree/main)

[Script Install LAMP](https://github.com/marinaferb92/practica-iaw-1.1/blob/main/scripts/install_lamp.sh)



Una vez hecho esto nos aseguraremos de que la Pila LAMP esta funcionando correctamente.

- Verificaremos el estado de apache.

  ![MMA4oyDdYV](https://github.com/user-attachments/assets/ef998254-f5f8-4bc1-b702-0e41621b0844)


- Entramos en mysql desde la terminal para ver que esta corriendo.

  ![jYkXAri0jN](https://github.com/user-attachments/assets/c919d2a4-aaa8-4241-838d-698ef3685a2e)



## 3. Registrar un Nombre de Dominio

Usamos un proveedor gratuito de nombres de dominio como son Freenom o No-IP.
En nuestro caso lo hemos hecho a traves de No-IP, nos hemos registrado en la página web y hemos registrado un nombre de dominio con la IP pública del servidor.


   ![TwkcTIoiNE](https://github.com/user-attachments/assets/f66b4d80-4c6e-4251-a12c-26303bfdcc00)


## 4. Instalar Certbot y Configurar el Certificado SSL/TLS con Let’s Encrypt
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.5 y utilizaremos el script ``` setup_letsencrypt_certificate.sh ```.

[Practica-iaw-1.5](https://github.com/marinaferb92/practica-iaw-1.5)

[Script setup_letsencrypt_certificate.sh](scripts/setup_letsencrypt_certificate.sh)



# Instalación de Moodle en el servidor LAMP

Tras los pasos anteriores y que se hayan ejecutado exitosamente los scripts ``` install_lamp.sh ``` y ``` setup_letsencrypt_certificate.sh ```, el siguiente paso es instalar Moodle.:

### 1. Cargamos el archivo de variables
   
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```


### 2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```
