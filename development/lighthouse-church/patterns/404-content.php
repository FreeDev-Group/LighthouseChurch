<?php
/**
 * Title: 404 content
 * Slug: lighthouse-church/404-content
 * Inserter: no
 *
 * @package LightHouse_Church
 */
?>
<!-- wp:group {"style":{"spacing":{"blockGap":"var:preset|spacing|40"}},"layout":{"type":"constrained","contentSize":"640px"}} -->
<div class="wp-block-group">
	<!-- wp:paragraph {"align":"center","className":"is-style-eyebrow"} -->
	<p class="has-text-align-center is-style-eyebrow"><?php esc_html_e( 'Erreur 404', 'lighthouse-church' ); ?></p>
	<!-- /wp:paragraph -->

	<!-- wp:heading {"textAlign":"center","level":1,"fontSize":"xx-large"} -->
	<h1 class="wp-block-heading has-text-align-center has-xx-large-font-size"><?php esc_html_e( 'Cette page est introuvable', 'lighthouse-church' ); ?></h1>
	<!-- /wp:heading -->

	<!-- wp:paragraph {"align":"center"} -->
	<p class="has-text-align-center"><?php esc_html_e( 'La page que vous cherchez a peut-être été déplacée ou supprimée. Essayez une recherche ou revenez à l’accueil.', 'lighthouse-church' ); ?></p>
	<!-- /wp:paragraph -->

	<!-- wp:search {"label":"<?php echo esc_attr__( 'Rechercher', 'lighthouse-church' ); ?>","showLabel":false,"placeholder":"<?php echo esc_attr__( 'Rechercher sur le site…', 'lighthouse-church' ); ?>","buttonText":"<?php echo esc_attr__( 'Rechercher', 'lighthouse-church' ); ?>"} /-->

	<!-- wp:buttons {"layout":{"type":"flex","justifyContent":"center"}} -->
	<div class="wp-block-buttons">
		<!-- wp:button -->
		<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( home_url( '/' ) ); ?>"><?php esc_html_e( 'Retour à l’accueil', 'lighthouse-church' ); ?></a></div>
		<!-- /wp:button -->
	</div>
	<!-- /wp:buttons -->
</div>
<!-- /wp:group -->
