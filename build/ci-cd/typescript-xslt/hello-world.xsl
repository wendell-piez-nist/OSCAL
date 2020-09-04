<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    version="3.0">

	<xsl:output method="html" omit-xml-declaration="yes"/>
	
	<xsl:template priority="2" match="/hello">
		<html>
      <head>
        <title>Hello World XSLT demo</title>
      </head>
      <body>
        <h1>
          <xsl:text>Hooray </xsl:text>
          <xsl:text>Hello </xsl:text>        
			    <xsl:apply-templates/>
          <xsl:text>!</xsl:text>
        </h1>
      </body>
		</html>        
  </xsl:template>

</xsl:stylesheet>