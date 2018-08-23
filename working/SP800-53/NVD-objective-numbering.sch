<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <!-- For validating numbering in rev4 objectives -->
<!-- Applicable to NVD XML -->
<!-- Shows where an old version needs fixing, or failure points in a conversion.  -->
    
    <sch:ns prefix="controls" uri="http://scap.nist.gov/schema/sp800-53/feed/2.0"/>
    <sch:ns prefix="scap"     uri="http://scap.nist.gov/schema/sp800-53/2.0"/>
    
    <!--<controls:controls xmlns="http://scap.nist.gov/schema/sp800-53/2.0" xmlns:controls="http://scap.nist.gov/schema/sp800-53/feed/2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" pub_date="2015-01-09T08:26:01.231-05:00">
    -->    
    
    
    <sch:pattern>
        <sch:rule context="scap:objective">
            <xsl:variable name="segment-format">
                <xsl:apply-templates mode="format-number-segment" select="."/>
            </xsl:variable>
            <xsl:variable name="num">
                <xsl:number level="single" format="{$segment-format}"/>
            </xsl:variable>
            <sch:let name="num-seg" value="substring-after(scap:number,../scap:number)"/>
            <sch:assert test="$num = $num-seg">
                (<sch:value-of select="count(ancestor-or-self::scap:objective)"/>deep) expecting number to be '<sch:value-of select="$num"/>' instead we have '<sch:value-of select="$num-seg"/>'
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <xsl:template match="scap:objective"
        mode="format-number-segment" priority="1">(a)</xsl:template>
    
    <xsl:template match="scap:control-enhancement/scap:objective"
        mode="format-number-segment" priority="2">[1]</xsl:template>
    
    <xsl:template match="scap:objective/scap:objective"
        mode="format-number-segment" priority="3">[1]</xsl:template>
    
    <xsl:template match="scap:control-enhancement/scap:objective/scap:objective"
        mode="format-number-segment" priority="4">[a]</xsl:template>
    
    <xsl:template match="scap:objective/scap:objective/scap:objective"
        mode="format-number-segment" priority="5">[a]</xsl:template>
    
    <xsl:template match="scap:control-enhancement/scap:objective/scap:objective/scap:objective"
        mode="format-number-segment" priority="6">(a)</xsl:template>
    
    <xsl:template match="scap:objective/scap:objective/scap:objective/scap:objective"
        mode="format-number-segment" priority="7">[1]</xsl:template>
    
        
</sch:schema>