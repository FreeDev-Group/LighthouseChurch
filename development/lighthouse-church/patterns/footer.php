<?php
/**
 * Title: Footer
 * Slug: lighthouse-church/footer
 * Categories: footer
 * Block Types: core/template-part/footer
 * Description: Site title, motto, social links, navigation, contact details and copyright line. Unvalidated information is marked [À CONFIRMER].
 *
 * @package LightHouse_Church
 */
?>
<!-- wp:group {"className":"is-style-section-night","style":{"spacing":{"padding":{"top":"var:preset|spacing|70","bottom":"var:preset|spacing|50"}}},"layout":{"type":"constrained"}} -->
<div class="wp-block-group is-style-section-night" style="padding-top:var(--wp--preset--spacing--70);padding-bottom:var(--wp--preset--spacing--50)">
	<!-- wp:columns {"align":"wide","style":{"spacing":{"blockGap":{"left":"var:preset|spacing|60"}}}} -->
	<div class="wp-block-columns alignwide">
		<!-- wp:column {"width":"40%"} -->
		<div class="wp-block-column" style="flex-basis:40%">
			<!-- wp:site-title {"level":0} /-->

			<!-- wp:paragraph {"textColor":"mist"} -->
			<p class="has-mist-color has-text-color"><?php echo esc_html__( '« Une Église au service de la ville de Bujumbura pour la gloire de Dieu »', 'lighthouse-church' ); ?> [À CONFIRMER]</p>
			<!-- /wp:paragraph -->

			<!-- wp:social-links {"iconColor":"base","iconColorValue":"#FBF8F2","openInNewTab":true,"className":"is-style-logos-only","style":{"spacing":{"blockGap":{"left":"var:preset|spacing|30"}}}} -->
			<ul class="wp-block-social-links has-icon-color is-style-logos-only">
				<!-- wp:social-link {"url":"","service":"facebook"} /-->

				<!-- wp:social-link {"url":"","service":"youtube"} /-->

				<!-- wp:social-link {"url":"","service":"instagram"} /-->

				<!-- wp:social-link {"url":"","service":"whatsapp"} /-->
			</ul>
			<!-- /wp:social-links -->
		</div>
		<!-- /wp:column -->

		<!-- wp:column -->
		<div class="wp-block-column">
			<!-- wp:heading {"fontSize":"medium","style":{"typography":{"fontFamily":"var:preset|font-family|body"}}} -->
			<h2 class="wp-block-heading has-medium-font-size" style="font-family:var(--wp--preset--font-family--body)"><?php echo esc_html_x( 'Navigation', 'Footer heading', 'lighthouse-church' ); ?></h2>
			<!-- /wp:heading -->

			<!-- wp:navigation {"ariaLabel":"<?php echo esc_attr__( 'Menu du pied de page', 'lighthouse-church' ); ?>","overlayMenu":"never","layout":{"type":"flex","orientation":"vertical"},"style":{"spacing":{"blockGap":"var:preset|spacing|20"}}} /-->
		</div>
		<!-- /wp:column -->

		<!-- wp:column -->
		<div class="wp-block-column">
			<!-- wp:heading {"fontSize":"medium","style":{"typography":{"fontFamily":"var:preset|font-family|body"}}} -->
			<h2 class="wp-block-heading has-medium-font-size" style="font-family:var(--wp--preset--font-family--body)"><?php echo esc_html_x( 'Nous trouver', 'Footer heading', 'lighthouse-church' ); ?></h2>
			<!-- /wp:heading -->

			<!-- wp:paragraph -->
			<p><?php echo esc_html__( 'Adresse :', 'lighthouse-church' ); ?> [À CONFIRMER]<br><?php echo esc_html__( 'E-mail :', 'lighthouse-church' ); ?> [À CONFIRMER]<br><?php echo esc_html__( 'Téléphone / WhatsApp :', 'lighthouse-church' ); ?> [À CONFIRMER]</p>
			<!-- /wp:paragraph -->

			<!-- wp:paragraph -->
			<p><?php echo esc_html__( 'Horaires des cultes :', 'lighthouse-church' ); ?> [À CONFIRMER]</p>
			<!-- /wp:paragraph -->
		</div>
		<!-- /wp:column -->
	</div>
	<!-- /wp:columns -->

	<!-- wp:separator {"align":"wide","className":"is-style-wide","style":{"spacing":{"margin":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|40"}}}} -->
	<hr class="wp-block-separator alignwide has-alpha-channel-opacity is-style-wide" style="margin-top:var(--wp--preset--spacing--60);margin-bottom:var(--wp--preset--spacing--40)"/>
	<!-- /wp:separator -->

	<!-- wp:group {"align":"wide","layout":{"type":"flex","flexWrap":"wrap","justifyContent":"space-between"}} -->
	<div class="wp-block-group alignwide">
		<!-- wp:paragraph {"textColor":"mist","fontSize":"small"} -->
		<p class="has-mist-color has-text-color has-small-font-size">© LightHouse Church Bujumbura</p>
		<!-- /wp:paragraph -->

		<!-- wp:paragraph {"textColor":"mist","fontSize":"small"} -->
		<p class="has-mist-color has-text-color has-small-font-size"><?php echo esc_html__( 'Affiliée à REACH-SA', 'lighthouse-church' ); ?> [À CONFIRMER]</p>
		<!-- /wp:paragraph -->
	</div>
	<!-- /wp:group -->
</div>
<!-- /wp:group -->
