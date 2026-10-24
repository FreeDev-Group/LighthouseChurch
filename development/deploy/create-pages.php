<?php
/**
 * Creates the nine LightHouse Church pages and the main menu.
 *
 * Run with WP-CLI from the WordPress root, only after a verified backup
 * (see Doc/deployment/hostinger-deployment.md):
 *
 *   wp eval-file create-pages.php                 Dry run: lists what would be created, changes nothing.
 *   wp eval-file create-pages.php pages <dir>     Creates the missing pages as DRAFTS from <dir>.
 *   wp eval-file create-pages.php menu            Creates the published "Menu principal" once all nine pages are published.
 *
 * <dir> is the folder holding Doc/content/pages/*.html (default: ../../Doc/content/pages from this file).
 * Existing pages (same slug, any status) and an existing "Menu principal" are never modified or deleted.
 *
 * @package LightHouse_Church
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit( 1 );
}

$lhc_mode = isset( $args[0] ) ? $args[0] : 'dry-run';
$lhc_dir  = isset( $args[1] ) ? rtrim( $args[1], '/' ) : dirname( __DIR__, 2 ) . '/Doc/content/pages';

// Menu order follows Doc/website-navigation.md §2 and decision D-018.
$lhc_pages = array(
	array( 'file' => '01-accueil.html', 'title' => 'Accueil', 'slug' => 'accueil', 'template' => 'page-full-width' ),
	array( 'file' => '02-a-propos.html', 'title' => 'À propos', 'slug' => 'a-propos', 'template' => '' ),
	array( 'file' => '03-ministeres.html', 'title' => 'Ministères', 'slug' => 'ministeres', 'template' => '' ),
	array( 'file' => '04-evenements.html', 'title' => 'Événements', 'slug' => 'evenements', 'template' => '' ),
	array( 'file' => '05-ressources.html', 'title' => 'Ressources', 'slug' => 'ressources', 'template' => '' ),
	array( 'file' => '06-actualites.html', 'title' => 'Actualités', 'slug' => 'actualites', 'template' => '' ),
	array( 'file' => '07-galerie.html', 'title' => 'Galerie', 'slug' => 'galerie', 'template' => '' ),
	array( 'file' => '08-donner.html', 'title' => 'Donner', 'slug' => 'donner', 'template' => '' ),
	array( 'file' => '09-contact.html', 'title' => 'Contact', 'slug' => 'contact', 'template' => '' ),
);
$lhc_menu_title = 'Menu principal';

/**
 * Prints one line of output.
 *
 * @param string $message Message.
 */
function lhc_say( $message ) {
	echo $message . "\n"; // phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped
}

/**
 * Returns the existing page for a slug, whatever its status, or null.
 *
 * @param string $slug Page slug.
 * @return WP_Post|null
 */
function lhc_find_page( $slug ) {
	return get_page_by_path( $slug, OBJECT, 'page' );
}

/**
 * Returns the ID of the existing navigation menu with this title, or 0.
 *
 * @param string $title Menu title.
 * @return int
 */
function lhc_find_menu( $title ) {
	$query = new WP_Query(
		array(
			'post_type'      => 'wp_navigation',
			'post_status'    => 'any',
			'title'          => $title,
			'posts_per_page' => 1,
			'fields'         => 'ids',
		)
	);
	return $query->posts ? (int) $query->posts[0] : 0;
}

if ( ! in_array( $lhc_mode, array( 'dry-run', 'pages', 'menu' ), true ) ) {
	lhc_say( "Unknown mode '$lhc_mode'. Use dry-run, pages or menu." );
	exit( 1 );
}

lhc_say( "Site: " . home_url( '/' ) . " — mode: $lhc_mode" );

if ( 'menu' !== $lhc_mode ) {
	// The content comes from the reviewed repository files: keep the block markup as is.
	kses_remove_filters();

	foreach ( $lhc_pages as $index => $page ) {
		$existing = lhc_find_page( $page['slug'] );
		if ( $existing ) {
			lhc_say( "SKIP   /{$page['slug']}/ already exists (ID {$existing->ID}, status {$existing->post_status}); not changed." );
			continue;
		}

		$path = "$lhc_dir/{$page['file']}";
		if ( ! is_readable( $path ) ) {
			lhc_say( "ERROR  $path not found." );
			exit( 1 );
		}

		if ( 'dry-run' === $lhc_mode ) {
			lhc_say( "CREATE /{$page['slug']}/ \"{$page['title']}\" as draft from {$page['file']}" );
			continue;
		}

		$post_id = wp_insert_post(
			wp_slash(
				array(
					'post_type'    => 'page',
					'post_status'  => 'draft',
					'post_title'   => $page['title'],
					'post_name'    => $page['slug'],
					'menu_order'   => $index + 1,
					'post_content' => file_get_contents( $path ), // phpcs:ignore WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents
				)
			),
			true
		);
		if ( is_wp_error( $post_id ) ) {
			lhc_say( "ERROR  /{$page['slug']}/: " . $post_id->get_error_message() );
			exit( 1 );
		}
		// wp_insert_post() rejects block theme templates when run from the command line: store the template as the editor does.
		if ( $page['template'] ) {
			update_post_meta( $post_id, '_wp_page_template', $page['template'] );
		}
		lhc_say( "DONE   /{$page['slug']}/ created as draft (ID $post_id)." );
	}

	lhc_say( 'Pages are drafts: review and publish them in Pages before running the menu step.' );
	return;
}

// Menu step: only once the nine pages exist and are published.
$lhc_existing_menu = lhc_find_menu( $lhc_menu_title );
if ( $lhc_existing_menu ) {
	lhc_say( "SKIP   \"$lhc_menu_title\" already exists (ID $lhc_existing_menu); not changed." );
	return;
}

$lhc_links = array();
foreach ( $lhc_pages as $page ) {
	$existing = lhc_find_page( $page['slug'] );
	if ( ! $existing || 'publish' !== $existing->post_status ) {
		lhc_say( "STOP   /{$page['slug']}/ is missing or not published; menu not created." );
		exit( 1 );
	}
	$url         = 'accueil' === $page['slug'] ? '/' : "/{$page['slug']}/";
	$lhc_links[] = sprintf(
		'<!-- wp:navigation-link %s /-->',
		wp_json_encode(
			array(
				'label' => $page['title'],
				'type'  => 'page',
				'id'    => $existing->ID,
				'url'   => $url,
				'kind'  => 'post-type',
			),
			JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
		)
	);
}

$lhc_menu_id = wp_insert_post(
	wp_slash(
		array(
			'post_type'    => 'wp_navigation',
			'post_status'  => 'publish',
			'post_title'   => $lhc_menu_title,
			'post_content' => implode( "\n", $lhc_links ),
		)
	),
	true
);
if ( is_wp_error( $lhc_menu_id ) ) {
	lhc_say( 'ERROR  menu: ' . $lhc_menu_id->get_error_message() );
	exit( 1 );
}
lhc_say( "DONE   \"$lhc_menu_title\" created (ID $lhc_menu_id) with " . count( $lhc_links ) . ' links.' );
