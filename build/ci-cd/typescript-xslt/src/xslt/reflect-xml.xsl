<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:template match="/" expand-text="true">
        <html>
            <head>
                <title>XML reflection</title>
            </head>
            <body>
                <p>This document has root element '{ name(/*) }'</p>
                <p>
                    <xsl:choose>
                        <xsl:when test="matches(/*/namespace-uri(), '\S')">It is in namespace {
                            /*/namespace-uri()}.</xsl:when>
                        <xsl:otherwise>It is in no namespace.</xsl:otherwise>
                    </xsl:choose>
                </p>
                <xsl:variable name="ec" select="count(//*)"/>
                <p>It contains { if ($ec eq 1) then '1 element' else ( $ec || ' elements, including ' || count(/*/*) || ' at the top'  ) }.</p>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>