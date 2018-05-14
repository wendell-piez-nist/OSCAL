# Modeling notes

Tracking things that have been mentioned or come up, until they can become issues or go stale.

## Possible OSCAL schema changes

### Catalog

* Move references section to the front
  * How are references represented in profiles and resolved profiles?
* Rename `@class` to `@name` throughout?
  * Poll data to see where `prop/@class=preceding-sibling::prop/@class` i.e. siblings have the same name - occurs in COBIT5, but elsewhere?
* Introduce `<para>` as additional component-level line element replacing `<p>`? E.g. in assessments
  * This lets "prose be prose"
  * Also provides an instruction point regarding the difference between (addressable) lines (paras), and "plain p", i.e. unclassed, un-id'd HTML p....
* Strip down prose
  * Remove `<span>` and anything else unwanted
  * Remove `@class|@id`
  * How about `<a>` do we have markdown syntax for that?
* Eliminate `<withdrawn>` (dependency: refactoring SP800-53 to remove it)
  * Represent controls as withdrawn with a `status` property (or attribute)?
* Require `link/@href` in schema?
  * Arguments for enforcing this in the schema layer, not Schematron (as error or warning)
  * nb we already have Schematron that detects missing links and broken internal links

### Profile

* Add capabity to patch (modify) by regex-based or other many-to-one match?
  * Supporting global and en masse removals and additions
    * Support passing in parameters?
    * Dynamic expansion of values...?
  * Test this on SP800-53 profiles (priority settings)
