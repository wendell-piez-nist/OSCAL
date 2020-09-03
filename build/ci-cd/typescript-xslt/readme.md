# Hints


[Run from the command line](https://www.saxonica.com/saxon-js/documentation/index.html#!nodejs/command-line)

```
xslt3 -s:source -xsl:stylesheet -o:output
```

[Compile XSLT to produce SEF](https://www.saxonica.com/saxon-js/documentation/index.html#!starting/export/compiling-using-XX) file from XSLT:

```
xslt3 -t -xsl:hello-world.xsl -export:hello.sef.json -nogo
```

An SEF file is necessary for invoking SaxonJS from Typescript.

# Saxon

## SaxonJS under NodeJS

* [Setup](https://www.saxonica.com/saxon-js/documentation/index.html#!starting/installing-nodejs)
* [Command line invocation](https://www.saxonica.com/saxon-js/documentation/index.html#!nodejs/command-line)
* [Javascript API](https://www.saxonica.com/saxon-js/documentation/index.html#!api) - we need mainly [SaxonJS.transform](https://www.saxonica.com/saxon-js/documentation/index.html#!api/transform)

## Under Java

[Installation](https://www.saxonica.com/documentation/index.html#!about/installationjava) - (but we already have it installed to run current scripts)
[Running XSLT from the command line](https://www.saxonica.com/documentation/index.html#!using-xsl/commandline) - with runtime options

### Test a query (returns current date):

```
java -cp path/to/saxon-he-10.0.jar net.sf.saxon.Query -t -qs:"current-date()"
```

### Apply an XSLT:

This applies a transformation called `transform.xsl` to a file called `source.xml`, producing a new file `result.html` as its result:

```
java -cp path/to/saxon-he-10.0.jar net.sf.saxon.Transform -t -s:source.xml 
     -xsl:transform.xsl -o:result.html
```
