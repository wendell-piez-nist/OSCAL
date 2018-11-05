<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">
    
       <xsl:template match="/">
           <proposal>
               <head>SSP Roles Reduced</head>
               <roles>
                   <xsl:apply-templates/>
               </roles>
           </proposal>
       </xsl:template>
        
        <xsl:template match="/*">
            <xsl:call-template name="role-assignment"/>
        </xsl:template>
    
    <xsl:template name="role-assignment">
        <xsl:for-each select="/descendant::table[23]">
           <xsl:apply-templates select="tr"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tr">
        <role>
            <xsl:apply-templates mode="as-attribute"/>
            <xsl:apply-templates/>
            <!--<as>
            <xsl:apply-templates mode="as"/>
            </as>-->
        </role>
    </xsl:template>
    
    <xsl:template match="*" mode="as-attribute"/>



    <xsl:template match="td[1]">
        <assignment>
            <xsl:apply-templates/>
        </assignment>
    </xsl:template>
    
    
    <xsl:template match="td[2]" mode="as-attribute">
        <xsl:attribute name="I_E">
            <xsl:apply-templates/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="td[3]" mode="as-attribute">
        <xsl:attribute name="priv">
            <xsl:apply-templates/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="td[4]">
        <sensitivity>
            <xsl:apply-templates/>
        </sensitivity>
    </xsl:template>
    
    <xsl:template match="td[5]">
        <authorization>
            <xsl:apply-templates/>
        </authorization>
    </xsl:template>
    
    <xsl:template match="td[6]">
        <functions>
            <xsl:apply-templates/>
        </functions>
    </xsl:template>
    
    <xsl:template match="td[6]//*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tr/td" priority="0"/>
        
    <xsl:template match="tr/td" mode="as" priority="0">
        <xsl:variable name="pos" select="count(.|preceding-sibling::td)"/>
        <as flag="{../../tr[1]/td[$pos]}">
            <xsl:apply-templates/>
        </as>
    </xsl:template>
            
</xsl:stylesheet>