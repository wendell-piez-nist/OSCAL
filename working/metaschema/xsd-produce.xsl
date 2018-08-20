<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0">
    
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/METASCHEMA">
        <xs:schema elementFormDefault="qualified" targetNamespace="http://csrc.nist.gov/ns/oscal/1.0">
            <xs:include schemaLocation="oscal-prose.xsd"/>
            <xsl:apply-templates/>
            <xs:group name="prose">
                <xs:choice>
                    <xs:element ref="oscal:p"/>
                    <xs:element ref="oscal:ul"/>
                    <xs:element ref="oscal:ol"/>
                    <xs:element ref="oscal:pre"/>
                </xs:choice>
            </xs:group>
        </xs:schema>
    </xsl:template>
    
    <xsl:template match="*[matches(@named,'\S')]">
        <xs:element minOccurs="{ number(@required = 'yes') }" ref="oscal:{@named}"/>
    </xsl:template>
    
<!-- Will not match declaration elements, which do not have @named -->
    <xsl:template priority="5" match="*[matches(@named,'\S')][matches(@group-as,'\S')]">
        <xs:element maxOccurs="unbounded" minOccurs="{ number(@required = 'yes') }" ref="oscal:{@named}"/>
    </xsl:template>
    
    <xsl:template match="define-field">
        <xs:element name="{@name }">
            <xs:complexType mixed="true">
                <xsl:if test="@as='mixed'">
                    <xs:group ref="oscal:everything-inline"/>
                </xsl:if>
                
                <!-- picking up attribute declarations -->
                <xsl:apply-templates select="flag"/>
                <xsl:apply-templates select="." mode="default-attributes"/>
            </xs:complexType>
        </xs:element>
    </xsl:template>
    
    <xsl:template match="define-assembly">
        <xs:element name="{@name}">
            <xs:complexType>
                <xsl:apply-templates select="model"/>
                <xsl:apply-templates select="flag"/>
                <xsl:apply-templates select="." mode="default-attributes"/>
            </xs:complexType>
        </xs:element>
    </xsl:template>

    <xsl:template match="define-flag"/>

    <xsl:template match="model">
        <xs:sequence>
            <xsl:apply-templates/>
        </xs:sequence>
    </xsl:template>
    
    <xsl:template match="choice">
        <xs:choice>
            <xsl:apply-templates/>
        </xs:choice>
    </xsl:template>
    
    <xsl:template match="prose">
        <xs:group ref="oscal:prose" maxOccurs="unbounded" minOccurs="0"/>
    </xsl:template>
    
    
    <xsl:template match="flag">
        <xs:attribute name="{ @name }" type="xs:string">
            <xsl:for-each select="@required[.='yes']">
                <xsl:attribute name="use">required</xsl:attribute>
            </xsl:for-each>
            <xsl:for-each select="@datatype">
                <xsl:attribute name="type" expand-text="true">xs:{ . }</xsl:attribute>
            </xsl:for-each>
        </xs:attribute>
    </xsl:template>
    
    <!-- Ignore these -->
    <xsl:template match="*[@has-id='required']/flag[@name='id']"/>
    <xsl:template match="*[@has-id='none'    ][not(@assign='id')]/flag[@name='id']"/>
    
    <!-- These templates apply to everyone to provide for default or implicit attribute declarations. -->
    
    <xsl:template priority="2" match="*[@has-id='required' or @address='id']" mode="default-attributes">
        <xs:attribute name="id" type="xs:ID" use="required"/>
    </xsl:template>
    
    <xsl:template priority="1" match="*[matches(@address,'\i\c*')]" mode="default-attributes">
        <xs:attribute name="{@address}" type="NCNAME" use="required"/>
    </xsl:template>
    
    <!-- No declaration for @id when one is already there -->
    <xsl:template match="*[flag/@name='id']" mode="default-attributes"/>

    <!-- No declaration when explicitly excluded -->
    <xsl:template match="*[@has-id='none']"       mode="default-attributes"/>
    
    <!-- Ordinarily, @id is available as an option -->
    <xsl:template match="*" mode="default-attributes">
        <xs:attribute name="id" type="xs:ID"/>
    </xsl:template>
    
</xsl:stylesheet>