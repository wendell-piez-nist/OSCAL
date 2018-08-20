## Catalog XML Schema

The topmost element in the OSCAL catalog XML schema is [`<catalog>`](#code-lt-catalog-gt-code-element).

### `<catalog>` element

Each OSCAL catalog is defined by a `<catalog>` element. A `<catalog>` element may contain the following:

* `<title>` (mandatory)
* [`<declarations>`](#code-lt-declarations-gt-code-element) (zero or more)
* [`<section>`](#code-lt-section-gt-code-element), [`<group>`](#code-lt-group-gt-code-element), and/or [`<control>`](#code-lt-control-gt-code-element) (zero or more of each)
* [`<references>`](#code-lt-references-gt-code-element) (optional)

### `<section>` element

Catalogs may use `<section>` elements for partitioning a catalog itself or another `<section>` element. A `<section>` element may contain the following:

* `@id` (optional)
* `@class` (optional)
* `<title>` (mandatory)
* `<p>`, `<ul>`, `<ol>`, and/or `<pre>` (zero or more of each)
* `<section>` (zero or more)
* [`<references>`](#code-lt-references-gt-code-element) (optional)

### `<group>` element

Catalogs may use `<group>` elements to reference related controls or control groups. `<group>` elements may have their own properties, statements, parameters, and references, which are inherited by all members of the group. Unlike `<section>` elements, `<group>` elements may not contain arbitrary prose. A `<group>` element may contain the following:

* `@id` (optional)
* `@class` (optional)
* `<title>` (optional)
* [`<param>`](#code-lt-param-gt-code-element), [`<link>`](#code-lt-link-gt-code-element), [`<prop>`](#code-lt-prop-gt-code-element), and/or [`<part>`](#code-lt-part-gt-code-element) (zero or more of each)
* `<group>` or [`<control>`](#code-lt-control-gt-code-element) (one or more total)
* [`<references>`](#code-lt-references-gt-code-element) (optional)

### `<control>` element

Each security or privacy control within the catalog is defined by a `<control>` element. A `<control>` element may contain the following:

* `@id` (optional)
* `@class` (optional)
* `<title>` (optional)
* [`<param>`](#code-lt-param-gt-code-element), [`<link>`](#code-lt-link-gt-code-element), [`<prop>`](#code-lt-prop-gt-code-element), [`<part>`](#code-lt-part-gt-code-element), and/or [`<subcontrol>`](#code-lt-subcontrol-gt-code-element) elements (zero or more of each)
* [`<references>`](#code-lt-references-gt-code-element) (optional)

### `<subcontrol>` element

An OSCAL `<subcontrol>` element is very similar to an OSCAL `<control>` element in its composition. A `<subcontrol>` element may contain the following:

* `@id` (optional)
* `@class` (optional)
* `<title>` (optional)
* [`<param>`](#code-lt-param-gt-code-element), [`<link>`](#code-lt-link-gt-code-element), [`<prop>`](#code-lt-prop-gt-code-element), and/or [`<part>`](#code-lt-part-gt-code-element) (zero or more of each)
* [`<references>`](#code-lt-references-gt-code-element) (optional)

#### `<prop>` element

A `<prop>` element is a value with a name. It is attributed to the containing control, subcontrol, component, part, or group. Properties permit the deployment and management of arbitrary controlled values, with and among control objects (controls and parts and extensions), for any purpose useful to an application or implementation of those controls. Typically and routinely, properties will be used to sort, select, order, and arrange controls or relate them to one another or to class hierarchies, taxonomies, or external authorities.

A `<prop>` element may contain the following:

* `@id` (optional)
* text content

#### `<part>` element

A `<part>` element is a partition, piece, or section of a control, subcontrol, component, or part. Generally speaking, `<part>` elements will be of two kinds. Many parts are logical partitions or sections for prose; these may be called "statements" and may be expected to have simple prose contents, even just one paragraph. Other parts may be more formally constructed out of properties (`<prop>` elements) and/or their own parts. Such structured objects (sometimes called "features") may, at the extreme, function virtually as control extensions or subcontrol-like objects ("enhancements"). Since the composition of parts can be constrained using OSCAL declarations (of the items or components to be given in a part or in this type of part), their use for encoding "objects" of arbitrary complexity within controls is effectively open-ended.

A `<part>` element may contain the following:

* `<title>` (optional)
* [`<param>`](#code-lt-param-gt-code-element), [`<link>`](#code-lt-link-gt-code-element), [`<prop>`](#code-lt-prop-gt-code-element), `<part>`, `<p>`, `<ul>`, `<ol>`, and/or `<pre>` (zero or more of each)

#### `<link>` element

A `<link>` element is a line or paragraph with a hypertext link. A `<link>` element may contain the following:

* `@rel` (optional)
* `@href` (optional)
* text content, possibly mixed with zero or more of each of the following: `<q>`, `<code>`, `<em>`, `<i>`, `<b>`, `<sub>`, `<sup>`, and/or `<span>`

#### `<param>` element

A `<param>` element is a parameter setting to be propagated to one or more points of insertion. A `<param>` element may contain the following:

* `@id` (optional)
* `@class` (optional)
* `<desc>` (mandatory)
* `<label>` (optional)
* `<value>` (optional)

### `<references>` element

A `<references>` element contains one or more reference descriptions, each contained within a `<ref>` element. Each `<ref>` element may contain the following:

* `@id` (optional)
* `<std>` (citation of a formal published standard), `<citation>` (citation of a resource), `<p>`, `<ul>`, `<ol>`, and/or `<pre>` (zero or more of each)

> The first example shows the two references for a particular control, each defined using a ``<ref>`` element within the same ``<references>`` element. In this example, both references are citations because they are not formal standards. Each ``<citation>`` includes an ``@href`` specifying the URL for accessing the reference, as well as a string containing a human-readable name for the resource.

```xml
<references>
   <ref>
       <citation href="https://doi.org/10.6028/NIST.SP.800-153">NIST Special Publication 800-153</citation>
   </ref>
   <ref>
       <citation href="https://doi.org/10.6028/NIST.SP.800-179">NIST Special Publication 800-179</citation>
   </ref>
</references>
```

> The second example illustrates usage of the ``@id`` attribute within the ``<ref>`` element. The reference is being assigned the identifier "SP800-153". TBD: how can that ID be used? Do we have an example of the format for a ``<std>`` element we could use here instead of ``<citation>``?

```xml
<references>
   <ref id="SP800-153">
       <citation href="https://doi.org/10.6028/NIST.SP.800-153">NIST Special Publication 800-153</citation>
   </ref>
</references>
```

### `<declarations>` element

A `<declarations>` element is used for extra-schema validation of data given within controls. More information on this will be added to the documentation in the future.
