<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="3.0">
    
    <xsl:output method="text"/>
    
    <xsl:variable name="stuff">
        <param id="ac-2.2_prm_1">suspends</param>
        <param id="ac-2.2_prm_2">dawn breaks</param>
        <part class="statement" id="ac-2.2_smt">
        <p>The information system automatically <insert param-id="ac-2.2_prm_1"/> temporary and emergency accounts after <insert param-id="ac-2.2_prm_2"/>.</p>
      </part>
    </xsl:variable>
    
    <xsl:key name="param-by-id" match="param" use="@id"/>
    
    <xsl:template match="insert">
        <xsl:apply-templates select="key('param-by-id',@param-id)"/>
    </xsl:template>
  
    <xsl:template match="/">
        <xsl:apply-templates select="$stuff/part"/>
    </xsl:template>
    
</xsl:stylesheet>