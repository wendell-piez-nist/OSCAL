<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
    version="3.0">

<!-- Purpose: by way of an imported stylesheet, converts OSCAL XML into equivalent OSCAL JSON. -->
<!-- Use: call this stylesheet to serialize JSON. Call the imported stylesheet to see the logic without serialization.   -->
    <xsl:output use-character-maps="delimiters" method="text"/>

    <xsl:character-map name="delimiters">
        <xsl:output-character character="&lt;" string="\u003c"/>
        <xsl:output-character character="&gt;" string="\u003e"/>
    </xsl:character-map>

    <xsl:import href="handmade-catalog-cast.xsl"/>

    <xsl:variable name="write-options" as="map(*)">
        <xsl:map>
            <xsl:map-entry key="'indent'">true</xsl:map-entry>
        </xsl:map>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="xpath-json">
            <xsl:apply-templates mode="xml2json"/>
        </xsl:variable>
        <json>
            <xsl:value-of select="xml-to-json($xpath-json, $write-options)"/>
        </json>
    </xsl:template>

</xsl:stylesheet>
