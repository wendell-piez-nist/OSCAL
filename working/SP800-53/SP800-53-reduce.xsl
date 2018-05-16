<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="xs math"
  xmlns="http://csrc.nist.gov/ns/oscal/1.0"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
  version="3.0">
  
<!-- For further tweaking SP800-53 OSCAL -->

<!--  silencing noisy Saxon ... -->
  <xsl:template match="/*">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
<!-- For whatever reason the source contains empty elements mapping to p elements... -->
  <xsl:template match="p[not(matches(.,'\S'))]"/>
  
<!-- Unwanted properties - these will be provided at the profile level and don't belong in the catalog  -->
  <xsl:template match="prop[@class=('baseline-impact','priority')]"/>
  
<!-- Reference handling: we rewrite all literal citations into links to copies created in an earlier step
     inside /catalog/references -->
  
  <xsl:key name="citations-by-value" match="/*/references/ref/citation" use="normalize-space(.)"/>
  
<!-- 'Withdrawn' controls are re-expressed with properties -->
  <xsl:template match="control[exists(.//withdrawn)] | subcontrol[exists(.//withdrawn)]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="prop/(. | preceding-sibling::*)"/>
      <prop class="status">Withdrawn</prop>
      <xsl:apply-templates select="prop/following-sibling::*"/>
    </xsl:copy>
  </xsl:template>

<!-- Stripping this unwanted ws -->
  <xsl:template match="text()[not(matches(.,'S'))][exists(../withdrawn)]"/>
  
  <xsl:template match="withdrawn">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  
  <xsl:template match="control/references/ref | subcontrol/references/ref">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="control/references/ref/citation | subcontrol/references/ref/citation">
    <link href="#{key('citations-by-value',normalize-space(.))/parent::ref/@id}" rel="reference">
      <xsl:apply-templates/>
    </link>
  </xsl:template>
  
</xsl:stylesheet>