<?php
/*
Plugin Name: Repo Safety Net
Description: Creates an endpoint for advertising repository status.
Author: Scott Lee
*/

define( 'RSN_VERSION', '0.1.0' );
define( 'RSN_PATH', dirname( __FILE__ ) . '/' );
define( 'RSN_URL', plugin_dir_url( __FILE__ ) . '/' );
define( 'RSN_INC', RSN_PATH . 'inc/' );

require_once RSN_INC . 'core.php';
require_once RSN_INC . 'admin.php';

// Bootstrap
Repo_Safety_Net\Core\setup();
Repo_Safety_Net\Admin\setup();