<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://csrc.nist.gov/ns/oscal/1.0"
    xmlns:o="http://csrc.nist.gov/ns/oscal/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:opr="http://csrc.nist.gov/ns/oscal/profile-resolution"
    exclude-result-prefixes="xs math o opr"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" >
    
    <!-- XSLT 2.0 so as to validate against XSLT 3.0 constructs -->
    
    <xsl:param name="source-uri">urn:UNKNOWN</xsl:param>
    
    <xsl:template match="* | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
 
    <xsl:template match="profile" priority="1">
        <catalog id="{@id}-RESOLVED">
            <xsl:apply-templates/>
        </catalog>
    </xsl:template>
    
    <xsl:template match="profile/metadata">
        <xsl:variable name="leaders" select="(title | published | last-modified | version | oscal-version | doc-id)"/>
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*"/>
            <xsl:apply-templates mode="#current" select="$leaders"/>
            <prop name="resolution-timestamp">
                <xsl:value-of select="current-dateTime()"/>
            </prop>
            <xsl:apply-templates mode="#current" select="prop"/>
            <link href="{$source-uri}" rel="resolution-source">
                <xsl:for-each select="title">
                    <xsl:apply-templates/>
                </xsl:for-each>
            </link>
            <xsl:apply-templates mode="#current" select="* except ($leaders | prop)"/>
            <!--<xsl:apply-templates select="../selection" mode="imported-metadata"/>-->
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="selection" mode="imported-metadata">
        <resource id="{@id}-RESOURCE" rel="imported">
            <xsl:copy-of select="metadata/title" copy-namespaces="no"/>
            <rlink href="{@opr:src}"/>
        </resource>
    </xsl:template>-->
    
    <xsl:template match="selection/metadata"/>
    
</xsl:stylesheet>