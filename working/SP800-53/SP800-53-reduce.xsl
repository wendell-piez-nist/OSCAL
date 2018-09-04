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
  
  <!--Truncate properties that echo their parents -->
  <!--<xsl:template match="part/prop[@class='label'][starts-with(.,../ancestor::*[prop/@class='label'][1]/prop[@class='label'])]">
    <prop class="label">
      <xsl:value-of select="substring-after(.,../ancestor::*[prop/@class='label'][1]/prop[@class='label'])"/>
    </prop>
  </xsl:template>-->
  
<!-- Reference handling: we rewrite all literal citations into links to copies created in an earlier step
     inside /catalog/references -->
  
  <xsl:key name="citations-by-value" match="/*/references/ref/citation" use="normalize-space(.)"/>
  
<!-- parts including statements are dropped from 'Withdrawn' controls and subcontrols. -->
  <xsl:template match="control[prop[@class='status']='Withdrawn']/part | subcontrol[prop[@class='status']='Withdrawn']/part"/>

  <xsl:template match="control | subcontrol | part">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="title, param, prop"/>
      <xsl:apply-templates select="* except (title | param | prop | part | link | references | subcontrol)"/>
      <xsl:apply-templates select="part, link"/>
      <xsl:apply-templates select="subcontrol, references"/>
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