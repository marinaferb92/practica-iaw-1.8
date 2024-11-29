<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

// Configuración de base de datos
$CFG->dbtype    = 'mysqli';                   
$CFG->dblibrary = 'native';                   
$CFG->dbhost    = 'localhost';                
$CFG->dbname    = 'moodle';    
$CFG->dbuser    = 'user';      
$CFG->dbpass    = 'user';  // Reemplaza con una contraseña más segura
$CFG->prefix    = 'mdl_'; 
$CFG->dboptions = array(                    
    'dbpersist' => 0,                         
    'dbsocket'  => 0 
);

// Configuración de Moodle
$CFG->wwwroot   = 'https://practicahttpsmfb.ddns.net';  // Asegúrate que esta URL sea accesible
$CFG->dataroot  = '/var/www/moodledata';     
$CFG->admin     = 'admin';                    // Nombre del usuario administrador
$CFG->directorypermissions = 0770;  // Permisos más seguros para directorios
$CFG->filepermissions = 0660;      // Permisos más seguros para archivos

// Configuración de depuración (debugging)
$CFG->debug = E_ALL;               // Mostrar todos los errores
$CFG->debugdisplay = 1;            // Mostrar los errores en la página

// Establece el comportamiento de la instalación
$CFG->install_plugin_callbacks = false;

// Otras configuraciones de Moodle (opcional)
$CFG->timezone = 'Europe/Madrid'; // Ajusta la zona horaria si es necesario

// Configuración de cache y sesiones (ajustes recomendados)
$CFG->cachejs = true;
$CFG->sessioncookie = 'MoodleSession';

// Incluir el archivo de configuración de Moodle
require_once(__DIR__ . '/lib/setup.php'); 

