# Testing XSLT transformations using Saxon in Java and Node JS

## Using Saxon in Java in the Bash shell

This is useful if you wish to check whether XSLTs run correctly outside SaxonJS and node JS.

### Check Java

```
$ java -version
```

This should give you version information for a reasonably current version of Java. If it does not you need to install it.

### Check $SAXON_HOME and confirm Saxon runtime

```
$ ls $SAXON_HOME
```

I see `Saxon-HE-9.9.1-3.jar`. Similarly, you should see a directory listing including a copy of a SAXON jar file.

Any recent version should work; using the latest (now 10.2) is always a good choice.

If no Saxon HE `jar` file is in place, download Saxon and set up $SAXON_HOME as described in 
[../../ci-cd/README.md](../README.md)

From the command line, this instruction (as adjusted to point to your `jar` file) will confirm that Saxon can be run:

```
$ java -jar $SAXON_HOME/Saxon-HE-9.9.1-3.jar net.sf.saxon.Transform -versionmsg
```

### Make yourself a shell to run Saxon in Java

To simplify the command syntax we can run XSLT transformations using a Bash script to call Saxon.

Such a shell is included as `java-saxon.sh`. Copy it with a new name and/or edit to point to your copy of Saxon (the `jar` file in the $SAXON_HOME directory).

### Test the shell on the hello-world transformation

As adjusted, this should work (from a bash shell prompt in this directory):

```
$ ./java-saxon.sh hello-world.xml hello-world.xsl
```

A successful run will write an HTML result to `STDOUT`, showing it in the console. Try with other XML and XSLT files as well. If you wish to capture the results to a file, use the `>` output redirect, e.g.

```
$ ./java-saxon.sh hello-world.xml hello-world.xsl > hello.html
```

If it does not run, the problem is one of: Java setup; Saxon setup; command line syntax as scripted.

### Test diagnostic 'reflection' XSLT

In the `src/xslt` subdirectory is an XSLT that will produce an HTML file for any (well-formed) XML input, describing that XML.

Try it on `hello-world.xml` like this:

```
$ ./java-saxon.sh hello-world.xml src/xslt/reflect-xml.xsl
```

Again, HTML should be produced; this time it describes the XML document instead of converting its contents to HTML.

Try this XSLT on other XML documents to confirm that it produces accurate information.

## Using SaxonJS under node JS

Outside of Javascript or Typescript, we can also run SaxonJS as a command. This is useful for testing its features and conformance.

Install SaxonJS globally on your system as described in [its documentation](https://www.saxonica.com/saxon-js/documentation/index.html#!starting/installing-nodejs).

Again, run these *from the bash command line*. (It may also work from the Windows shell or Windows Powershell, but YMMV.)

Note that this time the arguments have flags `-s` and `-xsl`; but we need no shell script.

### Run the hello-world transformation:

```
$ xslt3 -s:hello-world.xml -xsl:hello-world.xsl

```

### Run something more interesting:

```

$ xslt3 -s:test-metaschema-m3.xml -xsl:src/xslt/reflect-xml.xsl
```

At time of writing, this XML file contains 27 elements total, which this transformation should report along with other information.
