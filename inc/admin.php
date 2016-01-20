<?php
namespace Repo_Safety_Net\Admin;

/**
 * Setup
 */
function setup() {

	add_action( 'admin_menu', __NAMESPACE__ . '\add_page' );
	add_action( 'admin_init', __NAMESPACE__ . '\register_settings' );
}

/**
 * Add/Register the plugin page
 */
function add_page() {

	add_plugins_page(
		'Repo Safety Net',
		'Repo Safety Net',
		'manage_options',
		'repo-safety-net',
		__NAMESPACE__ . '\create_admin_page'
	);
}

/**
 * Populates the plugin page.
 *
 * @return void
 */
function create_admin_page() { ?>

	<div class="wrap">
		<h2>Repo Safety Net</h2>
		<?php settings_errors(); ?>

		<form method="post" action="options.php">
			<?php
			settings_fields( 'rsn_option_group' );
			do_settings_sections( 'rsn-admin' );
			submit_button();
			?>
		</form>
	</div>
<?php }

/**
 * Registers the settings group, section, and settings
 *
 * @return void
 */
function register_settings() {

	register_setting(
		'rsn_option_group',
		'repo_safety_net_options',
		__NAMESPACE__ . '\sanitize_callback'
	);

	add_settings_section(
		'rsn_settings_section',
		'Settings',
		__NAMESPACE__ . '\section_callback',
		'rsn-admin'
	);

	// Repo Status
	add_settings_field(
		'repo_status',
		'Enable repository lock',
		__NAMESPACE__ . '\repo_status_callback',
		'rsn-admin',
		'rsn_settings_section'
	);

	// Repo Name
	add_settings_field(
		'repo_name',
		'Repository Name',
		__NAMESPACE__ . '\repo_name_callback',
		'rsn-admin',
		'rsn_settings_section'
	);

	// Repo Contact
	add_settings_field(
		'contact_name',
		'Contact',
		__NAMESPACE__ . '\contact_name_callback',
		'rsn-admin',
		'rsn_settings_section'
	);

	// Message
	add_settings_field(
		'message',
		'Message',
		__NAMESPACE__ . '\message_callback',
		'rsn-admin',
		'rsn_settings_section'
	);
}


/**
 * Handles sanitization for the settings
 *
 * @param $input
 *
 * @return array
 */
function sanitize_callback( $input ) {

	$sanitary_values = array();

	if ( isset( $input['repo_status'] ) ) {
		// Likely a better sanitize function here.
		$sanitary_values['repo_status'] = sanitize_text_field( $input['repo_status'] );
	} else {
		$sanitary_values['repo_status'] = 'Open';
	}

	if ( isset( $input['repo_name'] ) ) {
		$sanitary_values['repo_name'] = sanitize_text_field( $input['repo_name'] );
	}

	if ( isset( $input['contact_name'] ) ) {
		$sanitary_values['contact_name'] = sanitize_text_field( $input['contact_name'] );
	}

	if ( isset( $input['message'] ) ) {
		$sanitary_values['message'] = sanitize_text_field( $input['message'] );
	}

	return $sanitary_values;
}

/**
 * Section callback
 */
function section_callback() {
}

/**
 *
 * @return html
 */
function repo_name_callback() {

	$repo_name = _get_option( 'repo_name' );

	printf(
		'<input class="regular-text" type="text" name="repo_safety_net_options[repo_name]" id="repo_name" value="%s">',
		isset( $repo_name ) ? esc_attr( $repo_name ) : ''
	);
}

function repo_status_callback() {

	$repo_status = ( _get_option( 'repo_status' ) ) ? _get_option( 'repo_status' ) : 0;
	?>
	<input type='checkbox' name='repo_safety_net_options[repo_status]' <?php checked( $repo_status, 'Closed' ) ?> value='Closed'>
	<?php

}

/**
 *
 * @return html
 */
function contact_name_callback() {

	$username = _get_option( 'contact_name' );

	printf(
		'<input class="regular-text" type="text" name="repo_safety_net_options[contact_name]" id="contact_name" value="%s">',
		isset( $username ) ? esc_attr( $username ) : ''

	);
}

function message_callback() {

	$message = _get_option( 'message' );

	printf(
		'<input class="regular-text" type="text" name="repo_safety_net_options[message]" id="message" value="%s">',
		isset( $message ) ? esc_attr( $message ) : ''

	);
}

/**
 * Helper for returning the value of the Last.fm Posts options
 * @todo move this to helpers.php
 *
 * @param string $option
 *
 * @return mixed
 */
function _get_option( $option = '' ) {

	$rsn_options = get_option( 'repo_safety_net_options' );

	if ( '' === $option ) {
		$option = $rsn_options;
	} else {
		$option = ( isset( $rsn_options[ $option ] ) ) ? $rsn_options[ $option ] : null;
	}

	return $option;
}
