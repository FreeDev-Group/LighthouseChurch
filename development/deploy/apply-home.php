<?php
/**
 * Homepage and footer layout update (images and footer inspired by the reference mock-up).
 *
 * Run with WP-CLI from the WordPress root, after a verified backup:
 *
 *   wp eval-file apply-home.php draft <dir>   Creates the draft page "accueil-v2" (homepage + footer markup) for review.
 *   wp eval-file apply-home.php apply <dir>   Puts <dir>/accueil-final.html into the Accueil page (a revision keeps
 *                                             the previous content), saves <dir>/footer-final.html as the footer
 *                                             template part (Site Editor customisation, "Reset" restores the theme
 *                                             footer) and moves the review draft to the trash.
 *
 * Nothing else is changed or deleted.
 *
 * @package LightHouse_Church
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit( 1 );
}

$lhc_mode = isset( $args[0] ) ? $args[0] : '';
$lhc_dir  = isset( $args[1] ) ? rtrim( $args[1], '/' ) : __DIR__ . '/drafts';

/**
 * Prints one line of output.
 *
 * @param string $message Message.
 */
function lhc_home_say( $message ) {
	echo $message . "\n"; // phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped
}

/**
 * Returns the content of a file of the drafts folder, or stops.
 *
 * @param string $path File path.
 * @return string
 */
function lhc_home_read( $path ) {
	if ( ! is_readable( $path ) ) {
		lhc_home_say( "ERROR  $path not found." );
		exit( 1 );
	}
	return file_get_contents( $path ); // phpcs:ignore WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents
}

// The content comes from the reviewed repository files: keep the block markup as is.
kses_remove_filters();

if ( 'draft' === $lhc_mode ) {
	$content = lhc_home_read( "$lhc_dir/accueil-v2.html" ) . "\n\n" . lhc_home_read( "$lhc_dir/footer-v2.html" );
	$draft   = get_page_by_path( 'accueil-v2', OBJECT, 'page' );
	$postarr = array(
		'post_type'    => 'page',
		'post_status'  => 'draft',
		'post_title'   => 'Accueil — nouvelle mise en page (brouillon de relecture)',
		'post_name'    => 'accueil-v2',
		'post_content' => $content,
	);
	if ( $draft ) {
		$postarr['ID'] = $draft->ID;
	}
	$id = wp_insert_post( wp_slash( $postarr ), true );
	if ( is_wp_error( $id ) ) {
		lhc_home_say( 'ERROR  ' . $id->get_error_message() );
		exit( 1 );
	}
	update_post_meta( $id, '_wp_page_template', 'page-full-width' );
	lhc_home_say( "DONE   review draft ID $id" );
	return;
}

if ( 'apply' !== $lhc_mode ) {
	lhc_home_say( 'Use: draft <dir> or apply <dir>.' );
	exit( 1 );
}

$home = get_page_by_path( 'accueil', OBJECT, 'page' );
if ( ! $home ) {
	lhc_home_say( 'ERROR  Accueil page not found.' );
	exit( 1 );
}
wp_save_post_revision( $home->ID );
$result = wp_update_post(
	wp_slash(
		array(
			'ID'           => $home->ID,
			'post_content' => lhc_home_read( "$lhc_dir/accueil-final.html" ),
		)
	),
	true
);
if ( is_wp_error( $result ) ) {
	lhc_home_say( 'ERROR  Accueil: ' . $result->get_error_message() );
	exit( 1 );
}
lhc_home_say( "DONE   Accueil (ID {$home->ID}) updated; previous content kept as a revision." );

// Footer: same storage as a Site Editor customisation of the theme's footer template part.
$footer   = lhc_home_read( "$lhc_dir/footer-final.html" );
$theme    = get_stylesheet();
$existing = get_posts(
	array(
		'post_type'      => 'wp_template_part',
		'post_status'    => 'any',
		'name'           => 'footer',
		'posts_per_page' => 1,
		'tax_query'      => array( // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_tax_query
			array(
				'taxonomy' => 'wp_theme',
				'field'    => 'name',
				'terms'    => $theme,
			),
		),
	)
);
if ( $existing ) {
	$part_id = wp_update_post(
		wp_slash(
			array(
				'ID'           => $existing[0]->ID,
				'post_content' => $footer,
			)
		),
		true
	);
} else {
	$part_id = wp_insert_post(
		wp_slash(
			array(
				'post_type'    => 'wp_template_part',
				'post_status'  => 'publish',
				'post_title'   => 'Footer',
				'post_name'    => 'footer',
				'post_content' => $footer,
			)
		),
		true
	);
}
if ( is_wp_error( $part_id ) ) {
	lhc_home_say( 'ERROR  footer: ' . $part_id->get_error_message() );
	exit( 1 );
}
wp_set_object_terms( $part_id, $theme, 'wp_theme' );
wp_set_object_terms( $part_id, 'footer', 'wp_template_part_area' );
lhc_home_say( "DONE   footer template part customised (ID $part_id); Site Editor › Patterns › Footer › Reset restores the theme footer." );

$draft = get_page_by_path( 'accueil-v2', OBJECT, 'page' );
if ( $draft ) {
	wp_trash_post( $draft->ID );
	lhc_home_say( "DONE   review draft ID {$draft->ID} moved to the trash." );
}
