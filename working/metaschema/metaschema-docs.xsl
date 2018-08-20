<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math oscal"
    version="3.0"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:variable name="oscal-docs" select="document('../../docs/schema/oscal-oscal.xml')"/>
    
    <xsl:key name="description-by-tag" match="oscal:component" use="oscal:prop[@class='tag']"/>
    
    <xsl:template match="define-field | define-assembly | define-flag">
        <xsl:variable name="after" select="model|example"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="* except $after"/>
            <xsl:apply-templates select="key('description-by-tag',@name,$oscal-docs)"/>
            <xsl:apply-templates select="$after"/>
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="oscal:prop[@class='tag']"/>
    
    <xsl:template match="oscal:prop[@class='full_name']">
        <formal-name>
            <xsl:apply-templates/>
        </formal-name>
    </xsl:template>
    
    <xsl:template match="oscal:component">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="oscal:*">
        <xsl:element name="{(@class, local-name())[1]}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!--<prop class="tag">id</prop>
    <prop class="full_name">ID / identifier</prop>
    <part class="description"><p>A value on @id unique within local document scope, i.e. across a given catalog or representation of catalog contents (controls).</p></part>
    <part class="remarks">
        <p>No mechanism is proposed to ensure that <code>@id</code> values do not collide across different catalogs. Use profiling without <q>merge</q> to detect such clashes.</p>
    </part>
    -->
</xsl:stylesheet>