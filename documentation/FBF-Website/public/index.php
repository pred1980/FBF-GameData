<?php
// Define path to forum directory
defined('FORUM_PATH')
    || define('FORUM_PATH', realpath(dirname(__FILE__) . '/forum'));

// Define path to application directory
defined('APPLICATION_PATH')
    || define('APPLICATION_PATH', realpath(dirname(__FILE__) . '/../application'));

// Define path to config file
defined('CONFIG_FILE')
    || define('CONFIG_FILE', APPLICATION_PATH . '/configs/config.ini');

define('APPLICATION_ENV', 'development');

// Define application environment
if(!defined('APPLICATION_ENV')) {
    if(getenv('APPLICATION_ENV')) {
    define('APPLICATION_ENV', getenv('APPLICATION_ENV'));
    }
    else if('dev.forsaken-bastions-fall.com' == $_SERVER['SERVER_NAME']) {
    define('APPLICATION_ENV', 'development');
    }
    else if('localhost' == $_SERVER['SERVER_NAME']) {
    define('APPLICATION_ENV', 'local');
    }
    else {
    define('APPLICATION_ENV', 'production');
    }
}
// Ensure library/ is on include_path
set_include_path(implode(PATH_SEPARATOR, array(
    realpath(APPLICATION_PATH . '/../library'),
        get_include_path(),
)));


/** Zend_Application */
require_once 'Zend/Application.php';

// Create application, bootstrap, and run
$application = new Zend_Application(
    APPLICATION_ENV,
    APPLICATION_PATH . '/configs/application.ini'
);
// Run Application
$application->bootstrap()->run();