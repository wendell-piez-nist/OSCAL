<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:controls="http://scap.nist.gov/schema/sp800-53/feed/2.0"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="#all"
    version="3.0"
    xmlns="http://scap.nist.gov/schema/sp800-53/2.0"
    xpath-default-namespace="http://scap.nist.gov/schema/sp800-53/2.0">
 
<!-- Run on NVD XML source data 
    file:/home/wendell/Documents/OSCAL-working/sources/800-53/rev4/800-53a-objectives.xml
    
    to produce a structural revision with annotations
    
    results saved as 
    file:/home/wendell/Documents/OSCAL-working/working/SP800-53/rev4/800-53a-objectives-remodel.xml
    
    Results should (unlike the source data) validate to Schematron
      (except it doesn't yet reflect numbering rules :-)
    file:/home/wendell/Documents/OSCAL-working/working/SP800-53/NVD-objective-numbering.sch
    
    tbd: integrate this into OSCAL production pipeline; reform ID assignment
    
    -->
    
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="family number title decision object incorporated-into"/>
    
    <xsl:output indent="yes"/>
    
    <!--<xsl:mode on-no-match="shallow-copy"/>-->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="controls:control/objective | control-enhancement/objective">

        <xsl:variable name="in" select="string(ancestor::*[number][1]/number)"/>
        <xsl:apply-templates select="* except objective"/>
        
      <!-- This is really a splitter, not a grouper... but in our data this is enough -->
        <xsl:for-each-group select="objective" group-by="oscal:first-token(number,$in)">
            <xsl:choose>
                <xsl:when test="count(current-group()) eq 1">
                    <xsl:apply-templates select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <objective>
                        <number>
                            <xsl:value-of select="$in || current-grouping-key()"/>
                        </number>
                        <xsl:apply-templates select="current-group()"/>
                    </objective>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:function name="oscal:first-token" as="xs:string?">
        <xsl:param name="str"/>
        <xsl:param name="leader"/>
        <xsl:if test="exists($leader)">
            <xsl:variable name="remainder" select="substring-after($str,$leader)"/>
            <xsl:sequence select="replace($remainder,'(\p{Pe}).*$','$1')"/>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>