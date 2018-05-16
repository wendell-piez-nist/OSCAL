<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"

    xmlns="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="baseline"    as="xs:string">LOW</xsl:param>
    
    <!--<xsl:template match="/">
        <xsl:comment expand-text="true"> Produced by SP800-53-profile-with-filter.xsl { current-date() }
        runtime parameter settings: $baseline='{ $baseline }'</xsl:comment>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="*"/>
    </xsl:template>-->
    
    <xsl:template match="*[text()[contains(.,'>')]]">
        <xsl:variable name="e" select="."/>
        <xsl:analyze-string select="string(.)" regex="&lt;br>">
            <xsl:matching-substring/>
            <xsl:non-matching-substring>
                <xsl:variable name="me" select="."/>
                    <xsl:for-each select="$e">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </xsl:copy>
                    </xsl:for-each>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
            
    
    
</xsl:stylesheet>