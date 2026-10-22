<?php
/**
 * LightHouse Church theme functions.
 *
 * Kept intentionally small: design settings live in theme.json, layouts in
 * templates/, parts/ and patterns/.
 *
 * @package LightHouse_Church
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Theme setup: translations and editor styles.
 */
function lighthouse_church_setup() {
	load_theme_textdomain( 'lighthouse-church', get_template_directory() . '/languages' );
	add_editor_style( 'assets/css/theme.css' );
}
add_action( 'after_setup_theme', 'lighthouse_church_setup' );

/**
 * Front-end stylesheet for the rules theme.json cannot express
 * (focus indicators, reduced motion, decorative details).
 */
function lighthouse_church_enqueue_styles() {
	wp_enqueue_style(
		'lighthouse-church',
		get_theme_file_uri( 'assets/css/theme.css' ),
		array(),
		wp_get_theme()->get( 'Version' )
	);
}
add_action( 'wp_enqueue_scripts', 'lighthouse_church_enqueue_styles' );

/**
 * Pattern categories shown in the block inserter.
 */
function lighthouse_church_register_pattern_categories() {
	register_block_pattern_category(
		'lighthouse-church-sections',
		array( 'label' => __( 'LightHouse: Sections', 'lighthouse-church' ) )
	);
	register_block_pattern_category(
		'lighthouse-church-cards',
		array( 'label' => __( 'LightHouse: Cards', 'lighthouse-church' ) )
	);
	register_block_pattern_category(
		'lighthouse-church-cta',
		array( 'label' => __( 'LightHouse: Calls to action', 'lighthouse-church' ) )
	);
	register_block_pattern_category(
		'lighthouse-church-pages',
		array( 'label' => __( 'LightHouse: Full pages', 'lighthouse-church' ) )
	);
}
add_action( 'init', 'lighthouse_church_register_pattern_categories' );

/**
 * Block styles that need a little CSS (defined in assets/css/theme.css).
 */
function lighthouse_church_register_block_styles() {
	register_block_style(
		'core/separator',
		array(
			'name'  => 'beam',
			'label' => __( 'Beam', 'lighthouse-church' ),
		)
	);
	register_block_style(
		'core/heading',
		array(
			'name'  => 'eyebrow',
			'label' => __( 'Eyebrow', 'lighthouse-church' ),
		)
	);
	register_block_style(
		'core/paragraph',
		array(
			'name'  => 'eyebrow',
			'label' => __( 'Eyebrow', 'lighthouse-church' ),
		)
	);
}
add_action( 'init', 'lighthouse_church_register_block_styles' );
