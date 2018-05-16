<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  xmlns="http://csrc.nist.gov/ns/oscal/1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
  version="3.0">
  
<!-- For producing indexes and other analytical artifacts from SP800-53 OSCAL -->

  <xsl:template match="/*">
    <analysis>
      <xsl:call-template name="param-index"/>
    </analysis>
  </xsl:template>
  
  <xsl:template name="param-index">
    <index>
      <head>Parameters and insertions</head>
    <xsl:for-each-group select="//insert" group-by="oscal:insertion-label(.)">
      <location>
        <label><xsl:value-of select="current-grouping-key()"/></label>
        <xsl:apply-templates select="key('params',current-group()/@param-id)"/>
      </location>
    </xsl:for-each-group>
    </index>
    
  </xsl:template>
  
  <xsl:key name="params" match="param" use="@id"/>
  
  <xsl:template match="param">
    <xsl:copy-of select="."/>
  </xsl:template>
      
  <xsl:function name="oscal:insertion-label" as="xs:string?">
    <xsl:param name="who" as="node()"/>
      <xsl:value-of select="$who/ancestor::*[prop/@class='name'][1]/prop[@class='name']"/>
  </xsl:function>
  
</xsl:stylesheet>