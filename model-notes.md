# Modeling notes

Tracking things that have been mentioned or come up, until they can become issues or go stale.

## Possible OSCAL schema changes under discussion

### Catalog

- [ ] Rename `class` to `name` throughout
  - [ ] This impacts Schematrons, CSS and XSLT
  - [ ] Can we remove support for multiple @name (where it is found)?

### Profile

- [ ] Add capabity to patch (modify) by regex-based or other multiple match
  - [ ] Supporting global and en masse removals and additions
    - [ ] Support passing in parameters?
    - [ ] Dynamic expansion of values...?
  - [ ] Test this on SP800-53 profiles (priority settings)
