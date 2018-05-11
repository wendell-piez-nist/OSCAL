# Modeling notes

Tracking things that have been mentioned or come up, until they can become issues or go stale.

## Possible OSCAL schema changes

* Move references section to the front in the catalog model
  * How are references represented in profiles and resolved profiles?
* Rename `@class` to `@name` throughout?
  * Poll data to see where `prop/@class=preceding-sibling::prop/@class` i.e. siblings have the same name - occurs in COBIT5, but elsewhere?
* Introduce `<para>` as additional component-level line element replacing `<p>`? E.g. in assessments
  * This lets "prose be prose"
  * Also provides an instruction point regarding the difference
* Strip down prose
  * Remove `<span>` and anything else unwanted
  * Remove `@class|@id`
  * How about `<a>` do we have markdown syntax for that?
* Eliminate `<withdrawn>` (dependency: refactoring SP800-53 to remove it)
  * Represent controls as withdrawn with a `status` property (or attribute)?
* Require `link/@href` in schema?
  * Arguments for enforcing this in the schema layer, not Schematron (as error or warning)
  * nb we already have Schematron that detects missing links and broken internal links
