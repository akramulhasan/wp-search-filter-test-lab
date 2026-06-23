#!/usr/bin/env bash
#
# setup-search-filter-lab.sh
# Sets up a local WordPress testing lab with WooCommerce, CPTs, custom
# taxonomies, ACF fields, and sample content for search/filter plugin testing.
#
# WARNING: For fresh local/staging WordPress sites ONLY.
# Do NOT run this on a live or production website.

set -euo pipefail

echo "=================================================="
echo " Search & Filter Local Test Lab Setup"
echo "=================================================="

if ! command -v wp >/dev/null 2>&1; then
  echo "WP-CLI was not found. Open the site shell from Local by Flywheel and try again."
  exit 1
fi

if ! wp core is-installed --quiet; then
  echo "WordPress does not seem to be installed in this directory."
  echo "Please run this from your Local site WordPress root, usually: app/public"
  exit 1
fi

echo ""
echo "Checking WordPress path..."
WP_CONTENT_DIR=$(wp eval 'echo WP_CONTENT_DIR;' --skip-themes --skip-plugins)
echo "WP_CONTENT_DIR: $WP_CONTENT_DIR"

echo ""
echo "Setting basic site options..."
wp option update blogname "Search Filter Test Lab"
wp option update blogdescription "Local WordPress test site for Search & Filter support practice"
wp rewrite structure '/%postname%/' --hard

echo ""
echo "Installing and activating theme..."
wp theme install twentytwentyfive --activate

echo ""
echo "Installing and activating plugins..."
wp plugin install woocommerce search-filter advanced-custom-fields --activate

echo ""
echo "Creating MU plugin for CPTs, taxonomies, and ACF fields..."
mkdir -p "$WP_CONTENT_DIR/mu-plugins"

cat > "$WP_CONTENT_DIR/mu-plugins/search-filter-test-lab-cpts.php" <<'PHP'
<?php
/**
 * Plugin Name: Search Filter Test Lab - CPTs and Taxonomies
 * Description: Registers test CPTs, taxonomies, and ACF fields for Search & Filter plugin testing.
 * Author: Local Test Lab
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_action( 'init', function () {

	register_post_type( 'library_book', array(
		'labels' => array(
			'name'          => 'Books',
			'singular_name' => 'Book',
			'add_new_item'  => 'Add New Book',
			'edit_item'     => 'Edit Book',
		),
		'public'       => true,
		'show_in_rest' => true,
		'has_archive'  => true,
		'rewrite'      => array( 'slug' => 'books' ),
		'menu_icon'    => 'dashicons-book',
		'supports'     => array( 'title', 'editor', 'excerpt', 'thumbnail', 'custom-fields' ),
	) );

	register_taxonomy( 'book_genre', array( 'library_book' ), array(
		'labels' => array(
			'name'          => 'Book Genres',
			'singular_name' => 'Book Genre',
		),
		'public'       => true,
		'show_in_rest' => true,
		'hierarchical' => true,
		'rewrite'      => array( 'slug' => 'book-genre' ),
	) );

	register_taxonomy( 'book_level', array( 'library_book' ), array(
		'labels' => array(
			'name'          => 'Book Levels',
			'singular_name' => 'Book Level',
		),
		'public'       => true,
		'show_in_rest' => true,
		'hierarchical' => false,
		'rewrite'      => array( 'slug' => 'book-level' ),
	) );

	register_post_type( 'property', array(
		'labels' => array(
			'name'          => 'Properties',
			'singular_name' => 'Property',
			'add_new_item'  => 'Add New Property',
			'edit_item'     => 'Edit Property',
		),
		'public'       => true,
		'show_in_rest' => true,
		'has_archive'  => true,
		'rewrite'      => array( 'slug' => 'properties' ),
		'menu_icon'    => 'dashicons-building',
		'supports'     => array( 'title', 'editor', 'excerpt', 'thumbnail', 'custom-fields' ),
	) );

	register_taxonomy( 'property_location', array( 'property' ), array(
		'labels' => array(
			'name'          => 'Property Locations',
			'singular_name' => 'Property Location',
		),
		'public'       => true,
		'show_in_rest' => true,
		'hierarchical' => true,
		'rewrite'      => array( 'slug' => 'property-location' ),
	) );

	register_taxonomy( 'property_type', array( 'property' ), array(
		'labels' => array(
			'name'          => 'Property Types',
			'singular_name' => 'Property Type',
		),
		'public'       => true,
		'show_in_rest' => true,
		'hierarchical' => true,
		'rewrite'      => array( 'slug' => 'property-type' ),
	) );

	register_taxonomy( 'property_feature', array( 'property' ), array(
		'labels' => array(
			'name'          => 'Property Features',
			'singular_name' => 'Property Feature',
		),
		'public'       => true,
		'show_in_rest' => true,
		'hierarchical' => false,
		'rewrite'      => array( 'slug' => 'property-feature' ),
	) );
} );

add_action( 'acf/init', function () {

	if ( ! function_exists( 'acf_add_local_field_group' ) ) {
		return;
	}

	acf_add_local_field_group( array(
		'key'    => 'group_sf_test_books',
		'title'  => 'Book Test Fields',
		'fields' => array(
			array(
				'key'   => 'field_book_year',
				'label' => 'Book Year',
				'name'  => 'book_year',
				'type'  => 'number',
			),
			array(
				'key'   => 'field_book_rating',
				'label' => 'Book Rating',
				'name'  => 'book_rating',
				'type'  => 'number',
			),
			array(
				'key'   => 'field_book_pages',
				'label' => 'Book Pages',
				'name'  => 'book_pages',
				'type'  => 'number',
			),
			array(
				'key'     => 'field_book_audience',
				'label'   => 'Audience',
				'name'    => 'book_audience',
				'type'    => 'select',
				'choices' => array(
					'students'    => 'Students',
					'developers'  => 'Developers',
					'marketers'   => 'Marketers',
					'beginners'   => 'Beginners',
					'advanced'    => 'Advanced Users',
				),
			),
		),
		'location' => array(
			array(
				array(
					'param'    => 'post_type',
					'operator' => '==',
					'value'    => 'library_book',
				),
			),
		),
	) );

	acf_add_local_field_group( array(
		'key'    => 'group_sf_test_properties',
		'title'  => 'Property Test Fields',
		'fields' => array(
			array(
				'key'   => 'field_property_price',
				'label' => 'Property Price',
				'name'  => 'property_price',
				'type'  => 'number',
			),
			array(
				'key'   => 'field_property_bedrooms',
				'label' => 'Bedrooms',
				'name'  => 'property_bedrooms',
				'type'  => 'number',
			),
			array(
				'key'   => 'field_property_area',
				'label' => 'Area Sqft',
				'name'  => 'property_area_sqft',
				'type'  => 'number',
			),
			array(
				'key'           => 'field_property_furnished',
				'label'         => 'Furnished',
				'name'          => 'property_furnished',
				'type'          => 'true_false',
				'ui'            => 1,
				'default_value' => 0,
			),
		),
		'location' => array(
			array(
				array(
					'param'    => 'post_type',
					'operator' => '==',
					'value'    => 'property',
				),
			),
		),
	) );

	acf_add_local_field_group( array(
		'key'    => 'group_sf_test_products',
		'title'  => 'Product Test Fields',
		'fields' => array(
			array(
				'key'     => 'field_product_test_color',
				'label'   => 'Test Color',
				'name'    => 'test_color',
				'type'    => 'select',
				'choices' => array(
					'black'  => 'Black',
					'blue'   => 'Blue',
					'green'  => 'Green',
					'red'    => 'Red',
					'yellow' => 'Yellow',
				),
			),
			array(
				'key'     => 'field_product_test_size',
				'label'   => 'Test Size',
				'name'    => 'test_size',
				'type'    => 'select',
				'choices' => array(
					'small'  => 'Small',
					'medium' => 'Medium',
					'large'  => 'Large',
				),
			),
			array(
				'key'           => 'field_product_featured_local',
				'label'         => 'Local Featured',
				'name'          => 'local_featured',
				'type'          => 'true_false',
				'ui'            => 1,
				'default_value' => 0,
			),
		),
		'location' => array(
			array(
				array(
					'param'    => 'post_type',
					'operator' => '==',
					'value'    => 'product',
				),
			),
		),
	) );
} );
PHP

echo ""
echo "Flushing rewrite rules after CPT registration..."
wp rewrite flush --hard

echo ""
echo "Creating content seed file..."

cat > /tmp/search-filter-test-lab-seed.php <<'PHP'
<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

echo "Starting content seeding...\n";

function sft_term_id( $taxonomy, $name, $slug = '' ) {
	$exists = term_exists( $name, $taxonomy );

	if ( $exists && ! is_wp_error( $exists ) ) {
		return (int) $exists['term_id'];
	}

	$args = array();

	if ( $slug ) {
		$args['slug'] = $slug;
	}

	$created = wp_insert_term( $name, $taxonomy, $args );

	if ( is_wp_error( $created ) ) {
		echo "Could not create term {$name} in {$taxonomy}: " . $created->get_error_message() . "\n";
		return 0;
	}

	return (int) $created['term_id'];
}

function sft_upsert_post( $post_type, $title, $content, $status = 'publish', $date = '', $slug = '' ) {
	$slug = $slug ? $slug : sanitize_title( $title );

	$existing = get_page_by_path( $slug, OBJECT, $post_type );

	$post_data = array(
		'post_title'   => $title,
		'post_name'    => $slug,
		'post_content' => $content,
		'post_status'  => $status,
		'post_type'    => $post_type,
	);

	if ( $date ) {
		$post_data['post_date']     = $date;
		$post_data['post_date_gmt'] = get_gmt_from_date( $date );
	}

	if ( $existing ) {
		$post_data['ID'] = $existing->ID;
		wp_update_post( $post_data );
		return $existing->ID;
	}

	return wp_insert_post( $post_data );
}

function sft_set_meta( $post_id, $meta ) {
	foreach ( $meta as $key => $value ) {
		update_post_meta( $post_id, $key, $value );
	}
}

function sft_create_page( $title, $slug, $content ) {
	$page_id = sft_upsert_post( 'page', $title, $content, 'publish', '', $slug );
	return $page_id;
}

/**
 * WooCommerce basic setup.
 */
if ( class_exists( 'WooCommerce' ) ) {
	echo "Setting up WooCommerce basics...\n";

	if ( class_exists( 'WC_Install' ) ) {
		WC_Install::create_pages();
	}

	update_option( 'woocommerce_currency', 'USD' );
	update_option( 'woocommerce_store_address', '123 Local Test Street' );
	update_option( 'woocommerce_store_city', 'Local City' );
	update_option( 'woocommerce_default_country', 'US:CA' );
	update_option( 'woocommerce_store_postcode', '90001' );
	update_option( 'woocommerce_enable_guest_checkout', 'yes' );
	update_option( 'woocommerce_demo_store', 'yes' );
}

/**
 * Normal post categories and tags.
 */
echo "Creating normal post categories and tags...\n";

$post_categories = array(
	'WordPress Support',
	'WooCommerce',
	'Troubleshooting',
	'Case Studies',
	'Plugin Reviews',
	'Documentation',
);

$post_tags = array(
	'ajax',
	'filters',
	'custom taxonomy',
	'performance',
	'bug fix',
	'beginner',
	'advanced',
	'shortcode',
	'query loop',
	'search results',
);

$cat_ids = array();
foreach ( $post_categories as $cat ) {
	$cat_ids[ $cat ] = sft_term_id( 'category', $cat );
}

$tag_ids = array();
foreach ( $post_tags as $tag ) {
	$tag_ids[ $tag ] = sft_term_id( 'post_tag', $tag );
}

/**
 * Create normal blog posts.
 */
echo "Creating normal posts...\n";

for ( $i = 1; $i <= 36; $i++ ) {
	$cat_name = $post_categories[ $i % count( $post_categories ) ];
	$tag_one  = $post_tags[ $i % count( $post_tags ) ];
	$tag_two  = $post_tags[ ( $i + 3 ) % count( $post_tags ) ];

	$title = sprintf( 'Search Test Blog Post %02d - %s', $i, $cat_name );

	$content = sprintf(
		"This is a test blog post for search and filtering. It includes terms related to %s, %s, and %s. Use this post to test keyword search, category filtering, tag filtering, date filtering, and mixed filters.\n\nScenario: A customer says their search form works on posts but not on custom post types. This content helps you test normal WordPress behavior first.",
		$cat_name,
		$tag_one,
		$tag_two
	);

	$date = date( 'Y-m-d H:i:s', strtotime( "-{$i} days" ) );

	$post_id = sft_upsert_post( 'post', $title, $content, 'publish', $date );

	wp_set_post_terms( $post_id, array( $cat_ids[ $cat_name ] ), 'category' );
	wp_set_post_terms( $post_id, array( $tag_ids[ $tag_one ], $tag_ids[ $tag_two ] ), 'post_tag' );

	sft_set_meta( $post_id, array(
		'reading_time'    => rand( 3, 14 ),
		'difficulty'      => ( $i % 3 === 0 ) ? 'advanced' : ( ( $i % 2 === 0 ) ? 'intermediate' : 'beginner' ),
		'featured_article'=> ( $i % 5 === 0 ) ? 1 : 0,
	) );
}

/**
 * Book terms.
 */
echo "Creating Book CPT terms and posts...\n";

$book_genres = array(
	'Psychology',
	'Business',
	'Technology',
	'Fiction',
	'History',
	'Science',
	'Self Improvement',
);

$book_levels = array(
	'Beginner',
	'Intermediate',
	'Advanced',
	'For Developers',
	'For Agencies',
);

$book_genre_ids = array();
foreach ( $book_genres as $term ) {
	$book_genre_ids[ $term ] = sft_term_id( 'book_genre', $term );
}

$book_level_ids = array();
foreach ( $book_levels as $term ) {
	$book_level_ids[ $term ] = sft_term_id( 'book_level', $term );
}

for ( $i = 1; $i <= 32; $i++ ) {
	$genre = $book_genres[ $i % count( $book_genres ) ];
	$level = $book_levels[ $i % count( $book_levels ) ];

	$title = sprintf( 'Library Book %02d - %s Guide', $i, $genre );

	$content = sprintf(
		"This is a custom post type item for testing Search & Filter with custom post types and custom taxonomies. Genre: %s. Level: %s.\n\nUse this item to test book_genre, book_level, keyword search, archive pages, and custom field behavior.",
		$genre,
		$level
	);

	$post_id = sft_upsert_post( 'library_book', $title, $content, 'publish', '', sanitize_title( $title ) );

	wp_set_post_terms( $post_id, array( $book_genre_ids[ $genre ] ), 'book_genre' );
	wp_set_post_terms( $post_id, array( $book_level_ids[ $level ] ), 'book_level' );

	sft_set_meta( $post_id, array(
		'book_year'     => rand( 2015, 2026 ),
		'book_rating'   => rand( 30, 50 ) / 10,
		'book_pages'    => rand( 120, 650 ),
		'book_audience' => array_rand( array(
			'students'   => true,
			'developers' => true,
			'marketers'  => true,
			'beginners'  => true,
			'advanced'   => true,
		) ),
	) );
}

/**
 * Property terms.
 */
echo "Creating Property CPT terms and posts...\n";

$property_locations = array(
	'Dhaka',
	'Dubai',
	'London',
	'New York',
	'Toronto',
	'Sydney',
);

$property_types = array(
	'Apartment',
	'Villa',
	'Office',
	'Studio',
	'Land',
	'Shared Space',
);

$property_features = array(
	'Pool',
	'Garden',
	'Parking',
	'Furnished',
	'Pet Friendly',
	'Near Metro',
	'Sea View',
	'Rooftop',
);

$location_ids = array();
foreach ( $property_locations as $term ) {
	$location_ids[ $term ] = sft_term_id( 'property_location', $term );
}

$type_ids = array();
foreach ( $property_types as $term ) {
	$type_ids[ $term ] = sft_term_id( 'property_type', $term );
}

$feature_ids = array();
foreach ( $property_features as $term ) {
	$feature_ids[ $term ] = sft_term_id( 'property_feature', $term );
}

for ( $i = 1; $i <= 32; $i++ ) {
	$location = $property_locations[ $i % count( $property_locations ) ];
	$type     = $property_types[ $i % count( $property_types ) ];
	$feature1 = $property_features[ $i % count( $property_features ) ];
	$feature2 = $property_features[ ( $i + 2 ) % count( $property_features ) ];

	$title = sprintf( '%s %s Property %02d', $location, $type, $i );

	$content = sprintf(
		"This is a property custom post type item for testing search filters. Location: %s. Type: %s. Features: %s and %s.\n\nUse this item to test custom post type archives, hierarchical taxonomy filters, non-hierarchical taxonomy filters, and custom fields.",
		$location,
		$type,
		$feature1,
		$feature2
	);

	$post_id = sft_upsert_post( 'property', $title, $content, 'publish', '', sanitize_title( $title ) );

	wp_set_post_terms( $post_id, array( $location_ids[ $location ] ), 'property_location' );
	wp_set_post_terms( $post_id, array( $type_ids[ $type ] ), 'property_type' );
	wp_set_post_terms( $post_id, array( $feature_ids[ $feature1 ], $feature_ids[ $feature2 ] ), 'property_feature' );

	sft_set_meta( $post_id, array(
		'property_price'     => rand( 75000, 950000 ),
		'property_bedrooms'  => rand( 1, 6 ),
		'property_area_sqft' => rand( 450, 4500 ),
		'property_furnished' => ( $i % 2 === 0 ) ? 1 : 0,
	) );
}

/**
 * WooCommerce official sample product import attempt.
 */
function sft_try_import_woocommerce_sample_products() {
	if ( ! class_exists( 'WooCommerce' ) ) {
		echo "WooCommerce is not active. Skipping official sample product import.\n";
		return;
	}

	$csv = WP_PLUGIN_DIR . '/woocommerce/sample-data/sample_products.csv';

	if ( ! file_exists( $csv ) ) {
		echo "Official WooCommerce sample_products.csv was not found at: {$csv}\n";
		return;
	}

	echo "Trying to import official WooCommerce sample products CSV...\n";

	try {
		if ( ! class_exists( 'WC_Product_CSV_Importer' ) ) {
			$files = array(
				WC_ABSPATH . 'includes/import/abstract-wc-product-importer.php',
				WC_ABSPATH . 'includes/import/class-wc-product-csv-importer.php',
			);

			foreach ( $files as $file ) {
				if ( file_exists( $file ) ) {
					require_once $file;
				}
			}
		}

		if ( class_exists( 'WC_Product_CSV_Importer' ) ) {
			$importer = new WC_Product_CSV_Importer( $csv, array(
				'parse'           => true,
				'update_existing' => true,
				'delimiter'       => ',',
			) );

			$results = $importer->import();

			$imported = isset( $results['imported'] ) ? count( $results['imported'] ) : 0;
			$updated  = isset( $results['updated'] ) ? count( $results['updated'] ) : 0;
			$failed   = isset( $results['failed'] ) ? count( $results['failed'] ) : 0;

			echo "Official sample import attempt finished. Imported: {$imported}, Updated: {$updated}, Failed: {$failed}\n";
		} else {
			echo "WC_Product_CSV_Importer class not available. Skipping official sample import.\n";
		}
	} catch ( Throwable $e ) {
		echo "Official sample product import failed safely: " . $e->getMessage() . "\n";
		echo "No problem. The script will still create custom WooCommerce test products.\n";
	}
}

sft_try_import_woocommerce_sample_products();

/**
 * Create custom WooCommerce products for controlled testing.
 */
if ( class_exists( 'WooCommerce' ) ) {
	echo "Creating controlled WooCommerce test products...\n";

	$product_categories = array(
		'Clothing',
		'Accessories',
		'Home Decor',
		'Tech Gadgets',
		'Outdoor Gear',
		'Summer Collection',
	);

	$product_tags = array(
		'Premium',
		'Budget',
		'Popular',
		'New Arrival',
		'On Sale',
		'Limited',
		'Lightweight',
		'Durable',
	);

	$product_cat_ids = array();
	foreach ( $product_categories as $term ) {
		$product_cat_ids[ $term ] = sft_term_id( 'product_cat', $term );
	}

	$product_tag_ids = array();
	foreach ( $product_tags as $term ) {
		$product_tag_ids[ $term ] = sft_term_id( 'product_tag', $term );
	}

	$colors = array( 'black', 'blue', 'green', 'red', 'yellow' );
	$sizes  = array( 'small', 'medium', 'large' );

	for ( $i = 1; $i <= 30; $i++ ) {
		$cat   = $product_categories[ $i % count( $product_categories ) ];
		$tag1  = $product_tags[ $i % count( $product_tags ) ];
		$tag2  = $product_tags[ ( $i + 2 ) % count( $product_tags ) ];
		$color = $colors[ $i % count( $colors ) ];
		$size  = $sizes[ $i % count( $sizes ) ];

		$sku = sprintf( 'SFT-LAB-%03d', $i );

		$existing_product_id = wc_get_product_id_by_sku( $sku );

		if ( $existing_product_id ) {
			$product = wc_get_product( $existing_product_id );
		} else {
			$product = new WC_Product_Simple();
			$product->set_sku( $sku );
		}

		if ( ! $product ) {
			continue;
		}

		$product->set_name( sprintf( 'Search Filter Test Product %02d - %s', $i, $cat ) );
		$product->set_status( 'publish' );
		$product->set_catalog_visibility( 'visible' );
		$product->set_description(
			sprintf(
				"This is a controlled WooCommerce product for filter testing. Category: %s. Tags: %s, %s. Color: %s. Size: %s. Use this product to test WooCommerce product category, product tag, price, keyword search, and custom field behavior.",
				$cat,
				$tag1,
				$tag2,
				$color,
				$size
			)
		);
		$product->set_short_description( 'Controlled local test product for Search & Filter troubleshooting.' );
		$product->set_regular_price( (string) rand( 25, 250 ) );

		if ( $i % 4 === 0 ) {
			$product->set_sale_price( (string) rand( 15, 100 ) );
		} else {
			$product->set_sale_price( '' );
		}

		$product->set_manage_stock( true );
		$product->set_stock_quantity( rand( 0, 80 ) );
		$product->set_stock_status( $i % 7 === 0 ? 'outofstock' : 'instock' );
		$product->set_category_ids( array( $product_cat_ids[ $cat ] ) );
		$product->set_tag_ids( array( $product_tag_ids[ $tag1 ], $product_tag_ids[ $tag2 ] ) );

		$product_id = $product->save();

		sft_set_meta( $product_id, array(
			'test_color'     => $color,
			'test_size'      => $size,
			'local_featured' => ( $i % 6 === 0 ) ? 1 : 0,
			'_test_batch'    => 'search-filter-lab',
		) );
	}

	echo "Custom WooCommerce products created.\n";
}

/**
 * Create test pages with Search & Filter shortcodes and archive links.
 */
echo "Creating test pages...\n";

$lab_page_content = <<<HTML
<!-- wp:heading -->
<h2>Search & Filter Test Lab</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>This page was created for testing a WordPress search/filter plugin with normal posts, custom post types, custom taxonomies, WooCommerce products, dates, tags, and categories.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>Useful Archive Links</h3>
<!-- /wp:heading -->

<!-- wp:list -->
<ul>
<li><a href="/blog/">Blog page</a></li>
<li><a href="/books/">Books archive</a></li>
<li><a href="/properties/">Properties archive</a></li>
<li><a href="/shop/">WooCommerce shop</a></li>
</ul>
<!-- /wp:list -->

<!-- wp:heading {"level":3} -->
<h3>Basic Posts Search & Filter Shortcode</h3>
<!-- /wp:heading -->

<!-- wp:shortcode -->
[searchandfilter fields="search,category,post_tag"]
<!-- /wp:shortcode -->

<!-- wp:heading {"level":3} -->
<h3>Book CPT Taxonomy Test</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Use this shortcode to test custom taxonomies. If it does not behave as expected, check the plugin settings, shortcode support, and whether the plugin version supports this exact taxonomy field setup.</p>
<!-- /wp:paragraph -->

<!-- wp:shortcode -->
[searchandfilter fields="search,book_genre,book_level"]
<!-- /wp:shortcode -->

<!-- wp:heading {"level":3} -->
<h3>Property CPT Taxonomy Test</h3>
<!-- /wp:heading -->

<!-- wp:shortcode -->
[searchandfilter fields="search,property_location,property_type,property_feature"]
<!-- /wp:shortcode -->

<!-- wp:heading {"level":3} -->
<h3>WooCommerce Product Taxonomy Test</h3>
<!-- /wp:heading -->

<!-- wp:shortcode -->
[searchandfilter fields="search,product_cat,product_tag"]
<!-- /wp:shortcode -->
HTML;

$lab_page_id = sft_create_page( 'Search & Filter Test Lab', 'search-filter-test-lab', $lab_page_content );

$home_content = <<<HTML
<!-- wp:heading -->
<h1>Search Filter Test Lab</h1>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>This local site contains normal posts, WooCommerce products, custom post types, custom taxonomies, and custom fields for plugin support testing.</p>
<!-- /wp:paragraph -->

<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="/search-filter-test-lab/">Open Test Lab</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->
HTML;

$home_id = sft_create_page( 'Home', 'home', $home_content );

$blog_id = sft_create_page( 'Blog', 'blog', '<!-- wp:heading --><h1>Blog</h1><!-- /wp:heading -->' );

update_option( 'page_on_front', $home_id );
update_option( 'page_for_posts', $blog_id );
update_option( 'show_on_front', 'page' );

echo "Test pages created.\n";

/**
 * Output summary.
 */
echo "\n==================================================\n";
echo "Search & Filter Test Lab Ready\n";
echo "==================================================\n";
echo "Created:\n";
echo "- Normal blog posts: 36\n";
echo "- Book CPT items: 32\n";
echo "- Property CPT items: 32\n";
echo "- Controlled WooCommerce products: 30\n";
echo "- Product categories/tags\n";
echo "- Post categories/tags\n";
echo "- CPT taxonomies\n";
echo "- ACF local field groups\n";
echo "- Test pages\n";
echo "\nVisit these pages:\n";
echo "- /search-filter-test-lab/\n";
echo "- /books/\n";
echo "- /properties/\n";
echo "- /shop/\n";
echo "- /blog/\n";
echo "==================================================\n";
PHP

echo ""
echo "Running content seed..."
wp eval-file /tmp/search-filter-test-lab-seed.php

echo ""
echo "Final rewrite flush..."
wp rewrite flush --hard

echo ""
echo "=================================================="
echo "DONE."
echo "Visit: /search-filter-test-lab/"
echo "=================================================="