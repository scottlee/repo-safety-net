<?php
namespace Repo_Safety_Net\Core;

/**
 * Setup
 */
function setup() {

	add_action( 'init', __NAMESPACE__ . '\register_endpoint' );
	add_action( 'template_redirect', __NAMESPACE__ . '\redirect_handler' );
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

	// Check for repo-status query var
	if ( ! isset( $wp_query->query_vars['repo-status'] ) ) {
		return;
	}

	// Set header response to 200 if repo is open. Else 400.
	$header_code = ( 'Open' === \Repo_Safety_Net\Admin\_get_option( 'repo_status' ) ) ? 200 : 400;
	@header( 'Content-Type: text/plain; charset=' . get_option( 'blog_charset' ), true, $header_code );

	// Echo the repo info
	echo _prepare_response();

	if ( defined( 'DOING_AJAX' ) && DOING_AJAX ) {
		wp_die();
	} else {
		die;
	}
}

/**
 * Beautifies the options array for the response
 *
 * @return string
 */
function _prepare_response() {
	$options  = \Repo_Safety_Net\Admin\_get_option();
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