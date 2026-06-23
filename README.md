# WP Search Filter Test Lab

A WP-CLI/bash setup script for creating a realistic local WordPress testing environment. Useful when testing search/filter plugins, WooCommerce behavior, custom post types, custom taxonomies, custom fields, archives, shortcodes, and support issues.

A blank WordPress install is often not enough for proper plugin support or QA testing — this script seeds it with realistic, varied data so you can reproduce issues, validate fixes, and prepare documentation examples.

---

## What this script creates

- **Twenty Twenty-Five** theme (activated)
- **WooCommerce** plugin (installed and activated)
- **Search & Filter** plugin (installed and activated)
- **Advanced Custom Fields** plugin (installed and activated)
- **36 normal blog posts** across 6 categories and 10 tags
- **WooCommerce pages** (shop, cart, checkout, my account)
- **6 WooCommerce product categories** and **8 product tags**
- **30 controlled WooCommerce test products** with price, stock, sale, color, size, and ACF fields
- **2 custom post types** (Books and Properties) with archives
- **Custom taxonomies** per CPT
- **ACF local field groups** for Books, Properties, and Products
- **32 Book CPT items** and **32 Property CPT items**
- **Test landing page** at `/search-filter-test-lab/` with shortcode examples
- **Archive links** for blog, books, properties, and shop

---

## Custom post types included

### Books (`library_book`)

| Field | Details |
|---|---|
| Post type slug | `library_book` |
| Archive slug | `/books/` |
| Taxonomies | `book_genre` (hierarchical), `book_level` (flat) |
| ACF fields | `book_year`, `book_rating`, `book_pages`, `book_audience` |

### Properties (`property`)

| Field | Details |
|---|---|
| Post type slug | `property` |
| Archive slug | `/properties/` |
| Taxonomies | `property_location` (hierarchical), `property_type` (hierarchical), `property_feature` (flat) |
| ACF fields | `property_price`, `property_bedrooms`, `property_area_sqft`, `property_furnished` |

---

## Who is this useful for?

- WordPress plugin support engineers
- WooCommerce support engineers
- QA testers
- WordPress developers and plugin founders
- Documentation writers
- Anyone testing search/filter plugins (Search & Filter, FacetWP, JetSmartFilters, etc.)
- Anyone practicing bug reproduction and support troubleshooting

---

## Requirements

- A local WordPress site (fresh install recommended)
- WP-CLI available from the WordPress root
- [LocalWP / Local by Flywheel](https://localwp.com/), DevKinsta, Valet, Docker, or similar local environment
- PHP and WP-CLI working correctly

---

## Installation

Copy `setup-search-filter-lab.sh` into your WordPress root (where `wp-config.php` lives), then run:

```bash
cd app/public
chmod +x setup-search-filter-lab.sh
./setup-search-filter-lab.sh
```

**LocalWP users:** open the site shell from the Local app (Site → Open Site Shell), navigate to the WordPress root, and run the script from there.

---

## After running the script

These paths will be active on your local site:

| URL | Content |
|---|---|
| `/search-filter-test-lab/` | Test lab page with shortcodes and archive links |
| `/blog/` | Normal posts |
| `/books/` | Library Book CPT archive |
| `/properties/` | Property CPT archive |
| `/shop/` | WooCommerce shop |

---

## Example testing scenarios

| Scenario | What to check |
|---|---|
| Search form output | Does the shortcode render correctly? |
| Post category filtering | Do category filters narrow results correctly? |
| Post tag filtering | Do tag filters work alongside category filters? |
| CPT filtering | Does the filter form query `library_book` or `property` CPTs? |
| Custom taxonomy filtering | Do `book_genre`, `book_level`, `property_location`, etc. appear as options? |
| WooCommerce product category filtering | Does `product_cat` filter return correct products? |
| WooCommerce product tag filtering | Does `product_tag` filter work in the shop? |
| Empty result issues | Reproduce "no results found" bugs with specific filter combinations |
| Wrong result issues | Test why filtered results include unexpected posts |
| Shortcode output problems | Compare shortcode behavior across plugin versions |
| Archive behavior | Test whether CPT archives respect plugin settings |
| Theme/query compatibility | Check if active theme overrides break filter queries |
| Plugin conflict reproduction | Deactivate plugins one by one to isolate issues |
| Documentation examples | Generate realistic screenshots for tutorials and docs |
| Support reply preparation | Reproduce a customer issue and confirm it in a clean environment |

---

## Important warning

> **This script is intended for fresh local/staging WordPress sites only.**
>
> Do **not** run it on a live or production website.
>
> It installs plugins, activates a theme, creates posts/pages/products, registers CPTs and taxonomies, updates site options, and seeds a large amount of test data. Running it on a production site **will modify your content and settings.**

---

## Notes

- This is not an official project of any plugin company.
- It is a general-purpose local testing utility for WordPress search/filter, WooCommerce, CPT, taxonomy, and support troubleshooting workflows.
- The MU plugin file created by this script (`search-filter-test-lab-cpts.php`) registers CPTs, taxonomies, and ACF field groups only on your local site — it is not deployed anywhere.

---

## License

[MIT License](LICENSE) — Copyright (c) 2026 Akramul Hasan
