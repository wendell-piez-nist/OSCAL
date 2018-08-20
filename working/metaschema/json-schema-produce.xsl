<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns="http://www.w3.org/2005/xpath-functions"
    expand-text="true">
    
    <xsl:output indent="yes" method="text" use-character-maps="safe"/>
    
    <xsl:template match="text()"/>
    
    <xsl:character-map name="safe">
        <!--<xsl:output-character character="&lt;" string="\u003c"/>
        <xsl:output-character character="&gt;" string="\u003e"/>-->
        <!-- Force unescaping       -->
        <xsl:output-character character="\" string=""/>
    </xsl:character-map>
   <!-- <xsl:variable name="metaschema" select="document('implementation-metaschema.xml')"/>-->
    
    <xsl:variable name="write-options" as="map(*)">
        <xsl:map>
            <xsl:map-entry key="'indent'">true</xsl:map-entry>
        </xsl:map>
    </xsl:variable>
    
    <xsl:key name="definition-by-name" match="define-flag | define-field | define-assembly" use="@name"/>
    
    <xsl:template match="/">
        <xsl:variable name="xpath-json">
            <xsl:apply-templates/>
        </xsl:variable>
        <json>
            <xsl:value-of select="xml-to-json($xpath-json, $write-options)"/>
        </json>
    </xsl:template>
    
    <xsl:template match="/METASCHEMA" expand-text="true">
        <xsl:variable name="top-group" select="@top"/>
        <xsl:variable name="top-each" select="@use"/>
        <map>
            <string key="$schema">http://json-schema.org/draft-07/schema#</string>
            <string key="$id">http://csrc.nist.gov/ns/oscal/1.0-metaschema.json</string>
            <string key="$comment">METASCHEMA Test JSON Schema</string>
            <string key="type">object</string>
            <map key="definitions">
                <xsl:apply-templates/>
            </map>
            <map key="properties">
                <map key="{$top-group}">
                    <string key="type">array</string>
                    <map key="items">
                        <string key="$ref">#/definitions/{ $top-each }</string>
                    </map>
                </map>
            </map>
            <map key="propertyNames">
                <array key="enum">
                    <string>{ $top-group }</string>
                </array>
            </map>
        </map>
        
    </xsl:template>
    
    
    
    
    <xsl:template match="define-assembly | define-field">
        <map key="{ @name (: @group-as | @name[empty(../@group-as)] :) }">
            <string key="$id">#/definitions/{@name}</string>
            <string key="type">object</string>
                <map key="properties">
                    <xsl:apply-templates select="." mode="default-attributes"/>
                    <xsl:apply-templates select="." mode="properties"/>
                </map>
                
                <!--<xsl:for-each-group select="*/( @named[empty(../@group-as)] | @group-as )" group-by="true()">
                    <map key="propertyNames">
                        <array key="enum">
                            <xsl:for-each select="current-group()">
                                <string>{ . }</string>
                            </xsl:for-each>
                        </array>
                    </map>
                </xsl:for-each-group>-->
        </map>      
    </xsl:template>
    
    <xsl:template match="define-field[empty(model/*) and (@has-id='none')]">
        <map key="{ @name (: @group-as | @name[empty(../@group-as)] :) }">
            <string key="$id">#/definitions/{@name}</string>
            <string key="type">string</string>
        </map>
    </xsl:template>
    
    <!-- Supervene key here when declaration has label="id"?       -->
    
    <xsl:template match="define-assembly" mode="properties">
        <xsl:apply-templates mode="declaration" select="model"/>
    </xsl:template>
    
    <xsl:template match="define-field[@as='mixed']" mode="properties">
        <xsl:apply-templates mode="declaration" select="model"/>
        <map key="TEXT">
            <string key="type">string</string>
        </map>
    </xsl:template>
    
    <xsl:template match="define-field" mode="properties">
        <xsl:apply-templates mode="declaration" select="model"/>
        <map key="VALUE">
            <string key="type">string</string>
        </map>
    </xsl:template>
    
    <xsl:template mode="default-attributes" match="*">
        <xsl:if test="not(@has-id='none') and not(model/flag/@name='id')">
            <map key="id">
            <string key="type">string</string>
        </map>
        </xsl:if>
        <xsl:message> ... any attributes to have assigned? ... </xsl:message>
    </xsl:template>
    
    <!-- How to express a required attribute or element in JSON schema? -->
    <xsl:template mode="default-attributes" match="*[@has-id='none']"/>
    
    <xsl:template mode="declaration" match="flag">
        <map key="{@name}">
            <string key="type">string</string>
        </map>
    </xsl:template>
    
    
    <xsl:template mode="declaration" match="assemblies | fields">
        <map key="{ @group-as }">
            <string key="type">array</string>
            <map key="items">
                <string key="$ref">#/definitions/{ @named }</string>
            </map>
        </map>
    </xsl:template>
    
    <xsl:template mode="declaration" match="assemblies[@address='id'] | fields[@address='id']">
        <map key="{ @group-as }">
            <string key="type">object</string>
            <map key="properties">
                <string key="$ref">#/definitions/{ @named }</string>
            </map>
        </map>
    </xsl:template>
        
    <xsl:template match="*" mode="object-type">
        <string key="type">object</string>
    </xsl:template>
    
    <xsl:template match="define-field[empty(model/*) and (@has-id='none')]" mode="object-type">
        <string key="type">string</string>
    </xsl:template>
    
    <xsl:template mode="declaration" match="assembly | field">
        
        <map key="{@named}">
            <xsl:apply-templates select="key('definition-by-name',@named)" mode="object-type"/>
            <string key="$ref">#/definitions/{ @named }</string>
        </map>
    </xsl:template>
    
    <xsl:template mode="declaration" match="prose">
        <map key="prose">
            <string key="$ref">#/definitions/prose</string>
        </map>
    </xsl:template>
    
    
    <xsl:template match="prose" name="prose"/>
    <!--<xsl:template match="prose" name="prose">
        <map key="prose">
            <string key="type">array</string>
            <map key="items">
                <xsl:comment>can't be right</xsl:comment>
                <string key="$ref">#/definitions/prose</string>
            </map>
        </map>
    </xsl:template>-->
    
</xsl:stylesheet>