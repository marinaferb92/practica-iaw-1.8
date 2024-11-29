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
$CFG->dbpass    = 'user';
$CFG->prefix    = 'mdl_'; 
$CFG->dboptions = array(                    
    'dbpersist' => 0,                        
    'dbsocket'  => 0 
);
// Configuración de Moodle
$CFG->wwwroot   = 'https://practicahttpsmfb.ddns.net';         
$CFG->dataroot  = '/var/www/moodledata';     
$CFG->admin     = 'admin';                   

// Configuración de permisos
$CFG->directorypermissions = 0777;
$CFG->filepermissions = 0666;

// Configuración de depuración (debugging)
$CFG->debug = (E_ALL);              // Mostrar todos los errores
$CFG->debugdisplay = 1;

require_once(__DIR__ . '/lib/setup.php');
