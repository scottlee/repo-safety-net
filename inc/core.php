<?php
namespace Repo_Safety_Net\Core;

/**
 * Setup
 */
function setup() {

	add_action( 'init', __NAMESPACE__ . '\register_endpoint' );
	add_action( 'template_redirect', __NAMESPACE__ . '\redirect_handler' );

	// Allow requests through RSA
	add_filter( 'restricted_site_access_is_restricted', __NAMESPACE__ . '\allow_with_rsa', 10, 2 );
}

/**
 * Create the endpoint
 */
function register_endpoint() {

	add_rewrite_endpoint( 'repo-status', EP_ROOT );
}

/**
 * Handles the redirect and response.
 */
function redirect_handler() {

	global $wp_query;

	// Bail if this isn't a repo-status query
	if ( ! _is_repo_query( $wp_query ) ) {
		return;
	}

	// Set header response to 200 if repo is open. Else 400.
	$options     = \Repo_Safety_Net\Admin\_get_option();
	$header_code = ( 'Open' === $options['repo_status'] ) ? 200 : 400;
	@header( 'Content-Type: text/plain; charset=' . get_option( 'blog_charset' ), true, $header_code );

	// Echo the repo info
	echo _prepare_response( $options );

	if ( defined( 'DOING_AJAX' ) && DOING_AJAX ) {
		wp_die();
	} else {
		die;
	}
}

/**
 * Allows repo-status request if the RSA plugin is installed.
 *
 * @param string $is_restricted
 * @param object $wp
 *
 * @return bool
 */
function allow_with_rsa( $is_restricted, $wp ) {

	if ( _is_repo_query( $wp ) ) {
		return false;
	}

	return $is_restricted;
}

/**
 * Checks if the repo-status query var is set.
 *
 * @param object $wp
 *
 * @return bool
 */
function _is_repo_query( $wp ) {

	if ( isset( $wp->query_vars['repo-status'] ) ) {
		return true;
	} else {
		return false;
	}
}

/**
 * Beautifies the options array for the response
 *
 * @param array $options
 *
 * @return string|void
 */
function _prepare_response( $options ) {

	// Bail early
	if ( ! $options || ! is_array( $options ) ) {
		return;
	}

	$response = '';

	// A bit to clever, but whatever.
	foreach ( _options_array() as $k => $v ) {
		$response .= $v . ': ' . esc_html( $options[ $k ] ) . PHP_EOL;
		if ( 'Open' === $options[ $k ] ) {
			break;
		}

	}

	return $response;
}

/**
 * Stores the friendly name and value of the plugin options.
 *
 * @return array
 */
function _options_array() {

	$options_array_map = array(
		'repo_status'  => 'Repository Status',
		'repo_name'    => 'Repository Name',
		'contact_name' => 'Contact',
		'message'      => 'Message'
	);

	return $options_array_map;
}