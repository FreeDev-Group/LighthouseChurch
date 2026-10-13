<?php
/**
 * Title: No results
 * Slug: lighthouse-church/no-results
 * Inserter: no
 *
 * @package LightHouse_Church
 */
?>
<!-- wp:group {"style":{"spacing":{"blockGap":"var:preset|spacing|40"}},"layout":{"type":"constrained","contentSize":"640px"}} -->
<div class="wp-block-group">
	<!-- wp:heading {"level":2,"fontSize":"x-large"} -->
	<h2 class="wp-block-heading has-x-large-font-size"><?php esc_html_e( 'Aucun résultat', 'lighthouse-church' ); ?></h2>
	<!-- /wp:heading -->

	<!-- wp:paragraph -->
	<p><?php esc_html_e( 'Aucun contenu ne correspond pour le moment. Essayez une autre recherche.', 'lighthouse-church' ); ?></p>
	<!-- /wp:paragraph -->

	<!-- wp:search {"label":"<?php echo esc_attr__( 'Rechercher', 'lighthouse-church' ); ?>","showLabel":false,"placeholder":"<?php echo esc_attr__( 'Rechercher sur le site…', 'lighthouse-church' ); ?>","buttonText":"<?php echo esc_attr__( 'Rechercher', 'lighthouse-church' ); ?>"} /-->
</div>
<!-- /wp:group -->
