<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/2005/xpath-functions"
                xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                version="3.0"
                xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
                exclude-result-prefixes="#all">
   <xsl:output indent="yes"/>
   <xsl:template match="/">
      <map>
         <xsl:apply-templates mode="xml2json"/>
      </map>
   </xsl:template>
   <xsl:template name="prose">
      <xsl:if test="exists(p | ul | ol | pre)">
         <array key="prose">
            <xsl:apply-templates mode="md" select="p | ul | ol | pre"/>
         </array>
      </xsl:if>
   </xsl:template>
   <xsl:template mode="as-string" match="@* | *">
      <xsl:param name="key" select="local-name()"/>
      <xsl:if test="matches(.,'\S')">
         <string key="{$key}">
            <xsl:value-of select="."/>
         </string>
      </xsl:if>
   </xsl:template>
   <xsl:template mode="md" match="p | link | part/*">
      <string>
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template mode="md" priority="1" match="pre">
      <string>```</string>
      <string>
         <xsl:apply-templates mode="md"/>
      </string>
      <string>```</string>
   </xsl:template>
   <xsl:template mode="md" priority="1" match="ul | ol">
      <string/>
      <xsl:apply-templates mode="md"/>
      <string/>
   </xsl:template>
   <xsl:template mode="md" match="ul//ul | ol//ol | ol//ul | ul//ol">
      <xsl:apply-templates mode="md"/>
   </xsl:template>
   <xsl:template mode="md" match="li">
      <string>
         <xsl:for-each select="../ancestor::ul">
            <xsl:text/>
         </xsl:for-each>
         <xsl:text>* </xsl:text>
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template mode="md" match="ol/li">
      <string/>
      <string>
         <xsl:for-each select="../ancestor::ul">
            <xsl:text/>
         </xsl:for-each>
         <xsl:text>1. </xsl:text>
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template mode="md" match="code | span[contains(@class,'code')]">
      <xsl:text>`</xsl:text>
      <xsl:apply-templates mode="md"/>
      <xsl:text>`</xsl:text>
   </xsl:template>
   <xsl:template mode="md" match="em | i">
      <xsl:text>*</xsl:text>
      <xsl:apply-templates mode="md"/>
      <xsl:text>*</xsl:text>
   </xsl:template>
   <xsl:template mode="md" match="strong | b">
      <xsl:text>**</xsl:text>
      <xsl:apply-templates mode="md"/>
      <xsl:text>**</xsl:text>
   </xsl:template>
   <xsl:template mode="md" match="q">
      <xsl:text>"</xsl:text>
      <xsl:apply-templates mode="md"/>
      <xsl:text>"</xsl:text>
   </xsl:template>
   <xsl:key name="element-by-id" match="*[exists(@id)]" use="@id"/>
   <xsl:template mode="md" match="a[starts-with(@href,'#')]">
      <xsl:variable name="link-target"
                    select="key('element-by-id',substring-after(@href,'#'))"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="replace(.,'&lt;','&amp;lt;')"/>
      <xsl:text>]</xsl:text>
      <xsl:text>(#</xsl:text>
      <xsl:value-of select="$link-target/*[1] =&gt; normalize-space() =&gt; lower-case() =&gt; replace('\s+','-') =&gt; replace('[^a-z\-\d]','')"/>
      <xsl:text>)</xsl:text>
   </xsl:template>
   <xsl:template match="text()" mode="md">
      <xsl:value-of select="replace(.,'\s+',' ') ! replace(.,'([`~\^\*])','\$1')"/>
   </xsl:template>
   <xsl:template match="catalog" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:apply-templates select="declarations" mode="#current"/>
         <xsl:apply-templates select="references" mode="#current"/>
         <xsl:if test="exists(section)">
            <array key="sections">
               <xsl:apply-templates select="section" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(group)">
            <array key="groups">
               <xsl:apply-templates select="group" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(control)">
            <array key="controls">
               <xsl:apply-templates select="control" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="declarations" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@href"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">VALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="section" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:call-template name="prose"/>
         <xsl:if test="exists(section)">
            <array key="sections">
               <xsl:apply-templates select="section" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="references" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="group" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:for-each-group select="param" group-by="local-name()">
            <map key="params">
               <xsl:apply-templates select="current-group()" mode="#current"/>
            </map>
         </xsl:for-each-group>
         <xsl:if test="exists(prop)">
            <array key="props">
               <xsl:apply-templates select="prop" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(part)">
            <array key="parts">
               <xsl:apply-templates select="part" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(group)">
            <array key="groups">
               <xsl:apply-templates select="group" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(control)">
            <array key="controls">
               <xsl:apply-templates select="control" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="references" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="control" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:for-each-group select="param" group-by="local-name()">
            <map key="params">
               <xsl:apply-templates select="current-group()" mode="#current"/>
            </map>
         </xsl:for-each-group>
         <xsl:if test="exists(prop)">
            <array key="props">
               <xsl:apply-templates select="prop" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(link)">
            <array key="links">
               <xsl:apply-templates select="link" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(part)">
            <array key="parts">
               <xsl:apply-templates select="part" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:for-each-group select="subcontrol" group-by="local-name()">
            <map key="subcontrols">
               <xsl:apply-templates select="current-group()" mode="#current"/>
            </map>
         </xsl:for-each-group>
         <xsl:apply-templates select="references" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="subcontrol" mode="xml2json">
      <map key="{@id}">
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:for-each-group select="param" group-by="local-name()">
            <map key="params">
               <xsl:apply-templates select="current-group()" mode="#current"/>
            </map>
         </xsl:for-each-group>
         <xsl:if test="exists(prop)">
            <array key="props">
               <xsl:apply-templates select="prop" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(link)">
            <array key="links">
               <xsl:apply-templates select="link" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(part)">
            <array key="parts">
               <xsl:apply-templates select="part" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="references" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="title" mode="xml2json">
      <string key="title">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="prop" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">VALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="param" mode="xml2json">
      <map key="{@id}">
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates mode="as-string" select="@depends-on"/>
         <xsl:apply-templates select="label" mode="#current"/>
         <xsl:if test="exists(desc)">
            <array key="descriptions">
               <xsl:apply-templates select="desc" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(constraint)">
            <array key="constraints">
               <xsl:apply-templates select="constraint" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="value" mode="#current"/>
         <xsl:apply-templates select="select" mode="#current"/>
         <xsl:if test="exists(link)">
            <array key="links">
               <xsl:apply-templates select="link" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(part)">
            <array key="parts">
               <xsl:apply-templates select="part" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="label" mode="xml2json">
      <string key="label">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="desc" mode="xml2json">
      <string key="desc">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="constraint" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@test"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">VALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="value" mode="xml2json">
      <string key="value">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="select" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@how-many"/>
         <xsl:if test="exists(choice)">
            <array key="alternatives">
               <xsl:apply-templates select="choice" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="choice" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:if test="matches(.,'\S')">
            <string key="TEXT">
               <xsl:apply-templates mode="md"/>
            </string>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="part" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@class"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:if test="exists(prop)">
            <array key="props">
               <xsl:apply-templates select="prop" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:call-template name="prose"/>
         <xsl:if test="exists(part)">
            <array key="parts">
               <xsl:apply-templates select="part" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(link)">
            <array key="links">
               <xsl:apply-templates select="link" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="link" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@href"/>
         <xsl:apply-templates mode="as-string" select="@rel"/>
         <xsl:if test="matches(.,'\S')">
            <string key="TEXT">
               <xsl:apply-templates mode="md"/>
            </string>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="references" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:if test="exists(link)">
            <array key="links">
               <xsl:apply-templates select="link" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(ref)">
            <array key="refs">
               <xsl:apply-templates select="ref" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="ref" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:if test="exists(citation)">
            <array key="citations">
               <xsl:apply-templates select="citation" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:call-template name="prose"/>
      </map>
   </xsl:template>
   <xsl:template match="citation" mode="xml2json">
      <map>
         <xsl:apply-templates mode="as-string" select="@id"/>
         <xsl:apply-templates mode="as-string" select="@href"/>
         <xsl:if test="matches(.,'\S')">
            <string key="TEXT">
               <xsl:apply-templates mode="md"/>
            </string>
         </xsl:if>
      </map>
   </xsl:template>
</xsl:stylesheet>
