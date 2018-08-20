<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:uuid="java:java.util.UUID"

    xmlns="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    
    exclude-result-prefixes="xs math uuid"
    version="3.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="baseline"    as="xs:string">LOW</xsl:param>
    
    <xsl:template match="/">
        <xsl:comment expand-text="true"> Produced by SP800-53-profile-with-filter.xsl { current-date() }
        runtime parameter settings: $baseline='{ $baseline }'</xsl:comment>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:key name="components-by-baseline" match="control | subcontrol" use="prop[@class='baseline-impact']"/>
    
    <xsl:template match="catalog">
        <profile id="uuid-{uuid:randomUUID()}">
            <title xsl:expand-text="true">SP800-53 { $baseline } BASELINE IMPACT</title>
            <import href="NIST_SP800-53_rev4_catalog.xml">
                <include>
                    <xsl:apply-templates select="key('components-by-baseline',$baseline)" mode="write-call"/>
                </include>
            </import>
                    <merge>
                        <as-is/>
                    </merge>
                    <modify>
                        <xsl:apply-templates select="key('components-by-baseline',$baseline)" mode="write-patch"/>
                    </modify>
        </profile>
    </xsl:template>
    
    <!--<xsl:variable name="catalog" select="document('../SP800-53/SP800-53-OSCAL-refined.xml')"/>-->
    
    <!--<xsl:key name="sp800-53-control-object-by-name" match="group|control|subcontrol" use="prop[@class='name']"/>-->
    
    <xsl:template match="control | subcontrol" mode="write-call">
        <call>
            <xsl:apply-templates select="." mode="write-id"/>
        </call>
    </xsl:template>
    
    <xsl:template match="control" mode="write-id">
        <xsl:attribute name="control-id" select="@id"/>
    </xsl:template>
    
    <xsl:template match="subcontrol" mode="write-id">
        <xsl:attribute name="subcontrol-id" select="@id"/>
    </xsl:template>
    
    
    <xsl:template priority="2" match="control[not(prop/@class='priority')] | subcontrol[not(prop/@class='priority')]" mode="write-patch"/>
        
    <xsl:template match="control | subcontrol" mode="write-patch">
        <alter>
          <xsl:apply-templates select="." mode="write-id"/>
            <add position="starting">
                <xsl:copy-of select="prop[@class='priority']"/>
            </add>
        </alter>
        
    </xsl:template>
    
    <xsl:template match="param" mode="param"/>
    
    <!--<xsl:template match="control[prop[@class=$property]=$value]/param |
                         subcontrol[prop[@class=$property]=$value]/param" mode="param">
        <xsl:variable name="insertions" select="..//insert[@param-id=current()/@id]"/>
        <set-param param-id="{@id}">
            <xsl:comment expand-text="true"> inserted into {$insertions/(ancestor::part | ancestor::subcontrol | ancestor::control)[last()]/prop[@class='name']} </xsl:comment>
            <xsl:copy-of select="desc, value"/>
        </set-param>
    </xsl:template>-->
    
    
</xsl:stylesheet>