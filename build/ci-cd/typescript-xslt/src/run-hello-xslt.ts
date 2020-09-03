import * as SaxonJS from "../node_modules/saxon-js/SaxonJS2N.js"

/*let xslt = 'hello-world.xsl'*/
/* const sysPath: string = 'file:///C:/Users/wap1/source/repos/NodejsTestConsole/src' */
let helloXML:   string = 'hello-world.xml'
let xsltFile:   string = 'hello-world.xsl'
let sefFile: string = 'hello.sef.json'
/*let resultFile: URL = 'file:///C:/Users/wap1/source/repos/NodejsTestConsole/src/hello.html'*/

/*API docs: http://www.saxonica.com/saxon-js/documentation/index.html#!api/transform */

 SaxonJS.transform({
    stylesheetLocation: sefFile,
    stylesheetBaseURI: xsltFile,
    sourceLocation: helloXML,
    sourceFileName: helloXML,
    destination: "stdout",

})

/*console.log(htmlout.principalResult)*/

/*    .then(output) {
    response.writeHead(200, { 'Content-Type': 'application/xml' });
    response.write(output.principalResult);
    response.end();
});  */ 

/*let message: string = "Hello World"
console.log(message)*/