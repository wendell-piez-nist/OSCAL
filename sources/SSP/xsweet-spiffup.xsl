<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">
    
    
        
        <xsl:mode on-no-match="shallow-copy"/>
        
        <xsl:template match="style"/>
        
        <xsl:template match="body">
            <xsl:apply-templates select="div[@class='docx-body']"/>
        </xsl:template>
        <xsl:template match="div[@class='docx-body']">
            <body>
                <xsl:apply-templates/>
            </body>
        </xsl:template>
        
        <xsl:template match="a[@class='bookmarkStart' or matches(@href,'^#docx-bookmark_\d+$')]"/>
        <xsl:template match="@data-xsweet-list-level | @data-xsweet-outline-level | @style"/>
        
        <xsl:template match="noProof | iCs | tr/b">
            <xsl:apply-templates/>
        </xsl:template>
        
        <xsl:template match="caps | spacing | highlight | tab | webHidden">
            <span class="{local-name()}">
                <xsl:apply-templates/>
            </span>
        </xsl:template>
        
        
</xsl:stylesheet>