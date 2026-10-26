=== LightHouse Church ===
Contributors: FreeDEV
Requires at least: 6.6
Requires PHP: 7.4
Stable tag: 0.1.1
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

A standalone Full Site Editing block theme for LightHouse Church Bujumbura.

== Description ==

LightHouse Church is a block theme built with native WordPress blocks only.
Colors, typography, spacing and layouts are defined in theme.json and can be
changed in Appearance > Editor > Styles. Templates, template parts and
patterns can be edited in the Site Editor. No page builder or plugin is
required.

The minimum WordPress and PHP versions above are provisional until the
production hosting versions are confirmed.

== Installation ==

1. In WordPress, go to Appearance > Themes > Add New > Upload Theme.
2. Upload lighthouse-church-<version>.zip (built with development/build-theme-zip.sh).
3. Activate the theme.

== Frequently Asked Questions ==

= Where are the design settings? =

In theme.json (palette, fonts, font sizes, spacing, element and block styles)
and in styles/sections/ (section styles: night, sand, card).

== Changelog ==

= 0.1.1 =
* Fix: the open mobile menu had no inner spacing (its links touched the screen edge). The root top and bottom padding in theme.json are now "0px": a unitless "0" made the core clamp() padding of the menu overlay invalid.

= 0.1.0 =
* Initial development version. Not released.

== Copyright ==

LightHouse Church WordPress Theme, (C) FreeDEV.
LightHouse Church is distributed under the terms of the GNU GPL v2 or later.

This theme bundles the following third-party resources:

Lora
Copyright 2011 The Lora Project Authors (https://github.com/cyrealtype/Lora-Cyrillic), with Reserved Font Name "Lora".
License: SIL Open Font License, Version 1.1 (assets/fonts/lora/OFL.txt)
Source: Fontsource package @fontsource-variable/lora 5.3.0 (Latin subset of Lora 3.008, variable weight 400-700)

Source Sans 3
© 2023 Adobe (http://www.adobe.com/), with Reserved Font Name 'Source'.
License: SIL Open Font License, Version 1.1 (assets/fonts/source-sans-3/OFL.txt)
Source: Fontsource package @fontsource-variable/source-sans-3 5.3.1 (Latin subset of Source Sans 3 3.052, variable weight 200-900)

Lighthouse mark (assets/images/lighthouse-mark.svg)
Original artwork created for this theme. License: GPLv2 or later.
