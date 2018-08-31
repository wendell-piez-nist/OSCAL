<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   version="3.0"
  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:feed="http://scap.nist.gov/schema/sp800-53/feed/2.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xlink="https://www.w3.org/TR/xlink/"
  xmlns:java="java:java.util.UUID"
  xpath-default-namespace="http://scap.nist.gov/schema/sp800-53/2.0"
  xmlns="http://scap.nist.gov/schema/sp800-53/2.0"
   exclude-result-prefixes="#all"
  >

  <xsl:strip-space elements="feed:controls feed:control description html:div html:ol supplemental-guidance references control-enhancements control-enhancement objectives objective decisions decision potential-assessments potential-assessment withdrawn statement"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:mode name="merge-appendixA" on-no-match="shallow-copy"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:variable name="source" select="/"/>
  
  <xsl:variable name="objectives" select="if (true()) then document('800-53a-objectives-remodel.xml',$source) else ()"/>
  
  <!-- space has to be stripped to integrate across disparities -->
  <xsl:key match="feed:control | control-enhancement" name="control-by-no" use="number"/>
  
  
  <xsl:template match="feed:control | control-enhancement">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="* except references"/>
      <xsl:if test="empty(withdrawn)">
        <xsl:apply-templates mode="merge-appendixA" select="key('control-by-no',number,$objectives)"/>
      </xsl:if>
      <xsl:apply-templates select="references"/>    
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="feed:control | control-enhancement" mode="merge-appendixA">
    <appendixA>
      <xsl:apply-templates mode="#current"/>
    </appendixA>
  </xsl:template>
  
  <xsl:template match="title" mode="merge-appendixA"/>
  
  <xsl:template mode="merge-appendixA" match="family"/>
  
</xsl:stylesheet>