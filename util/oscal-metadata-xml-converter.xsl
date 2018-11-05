<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/2005/xpath-functions"
                xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                version="3.0"
                xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
                exclude-result-prefixes="#all">
   <xsl:output indent="yes" method="text" use-character-maps="delimiters"/>
   <!-- METASCHEMA conversion stylesheet supports XML->JSON conversion -->
   <!-- 88888888888888888888888888888888888888888888888888888888888888 -->
   <xsl:character-map name="delimiters">
      <xsl:output-character character="&lt;" string="\u003c"/>
      <xsl:output-character character="&gt;" string="\u003e"/>
   </xsl:character-map>
   <xsl:param name="json-indent" as="xs:string">no</xsl:param>
   <xsl:mode name="rectify" on-no-match="shallow-copy"/>
   
   <xsl:template mode="rectify"
      xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
      match="/*/@key | array/*/@key"/>
   
   <!--<xsl:template mode="rectify" priority="2"
      xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
      match="array[(count(map)=1) and not(*/*/@key != 'STRVALUE')]">
      <string key="{map/@key (: or use another address :)}">
         <xsl:for-each select="*/*[@key='STRVALUE']">
            <xsl:apply-templates mode="#current"/>
         </xsl:for-each>
      </string>
   </xsl:template>
   <xsl:template mode="rectify" priority="1"
      xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
      match="array[count(map) = 1]">
      <map key="{map/@key (: or use another address :)}">
         <xsl:for-each select="map">
            <xsl:apply-templates mode="#current"/>
         </xsl:for-each>
      </map>
   </xsl:template>
   
   <xsl:template mode="rectify" priority="2"
      xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
      match="map[not(*/@key != 'STRVALUE')]">
      <string key="{@key (: or use another address :)}">
         <xsl:for-each select="*[@key='STRVALUE']">
            <xsl:apply-templates mode="#current"/>
         </xsl:for-each>
      </string>
   </xsl:template>-->
   
   <xsl:variable name="write-options" as="map(*)" expand-text="true">
      <xsl:map>
         <xsl:map-entry key="'indent'">{ $json-indent='yes' }</xsl:map-entry>
      </xsl:map>
   </xsl:variable>
   <xsl:template match="/" mode="debug">
      <xsl:apply-templates mode="xml2json"/>
   </xsl:template>
   <xsl:template match="/">
      <xsl:variable name="xpath-json">
         <xsl:apply-templates mode="xml2json"/>
      </xsl:variable>
      <xsl:variable name="rectified">
         <xsl:apply-templates select="$xpath-json" mode="rectify"/>
      </xsl:variable>
      <!--<xsl:sequence select="$xpath-json"/>-->
      <!--<xsl:sequence select="$rectified"/>-->
      <json>
         <xsl:value-of select="xml-to-json($rectified, $write-options)"/>
      </json>
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
   <!-- 88888888888888888888888888888888888888888888888888888888888888 -->
   <xsl:template match="metadata" mode="xml2json">
      <map key="metadata">
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:apply-templates select="date" mode="#current"/>
         <xsl:apply-templates select="version" mode="#current"/>
         <xsl:if test="exists(doc-id)">
            <array key="document-identifiers">
               <xsl:apply-templates select="doc-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(pub-id)">
            <array key="publication-identifiers">
               <xsl:apply-templates select="pub-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="system" mode="#current"/>
         <xsl:apply-templates select="sensitivity" mode="#current"/>
         <xsl:if test="exists(organization)">
            <array key="organizations">
               <xsl:apply-templates select="organization" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="preparation" mode="#current"/>
         <xsl:apply-templates select="history" mode="#current"/>
         <xsl:if test="exists(attachment)">
            <array key="attachments">
               <xsl:apply-templates select="attachment" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="notes" mode="#current"/>
         <xsl:if test="exists(meta-group)">
            <array key="meta-groups">
               <xsl:apply-templates select="meta-group" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="title" mode="xml2json">
      <string key="title">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="date" mode="xml2json">
      <string key="date">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="version" mode="xml2json">
      <map key="version">
         <xsl:apply-templates mode="as-string" select="@iso-date"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">STRVALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="doc-id" mode="xml2json">
      <map key="doc-id">
         <xsl:apply-templates mode="as-string" select="@type"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">STRVALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="pub-id" mode="xml2json">
      <map key="pub-id">
         <xsl:apply-templates mode="as-string" select="@type"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">STRVALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="sensitivity" mode="xml2json">
      <map key="sensitivity">
         <xsl:apply-templates mode="as-string" select="@type"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">STRVALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="organization" mode="xml2json">
      <map key="organization">
         <xsl:apply-templates mode="as-string" select="@role"/>
         <xsl:apply-templates select="full-name" mode="#current"/>
         <xsl:apply-templates select="short-name" mode="#current"/>
         <xsl:if test="exists(org-id)">
            <array key="organization-identifiers">
               <xsl:apply-templates select="org-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="address" mode="#current"/>
         <xsl:apply-templates select="email" mode="#current"/>
         <xsl:apply-templates select="phone" mode="#current"/>
         <xsl:apply-templates select="url" mode="#current"/>
         <xsl:apply-templates select="notes" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="org-id" mode="xml2json">
      <map key="org-id">
         <xsl:apply-templates mode="as-string" select="@type"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">STRVALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="full-name" mode="xml2json">
      <string key="full-name">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="short-name" mode="xml2json">
      <string key="short-name">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="address" mode="xml2json">
      <map key="address">
         <xsl:if test="exists(addr-line)">
            <array key="address-lines">
               <xsl:apply-templates select="addr-line" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="city" mode="#current"/>
         <xsl:apply-templates select="state" mode="#current"/>
         <xsl:apply-templates select="postal-code" mode="#current"/>
         <xsl:apply-templates select="country" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="addr-line" mode="xml2json">
      <string key="addr-line">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="city" mode="xml2json">
      <string key="city">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="state" mode="xml2json">
      <string key="state">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="postal-code" mode="xml2json">
      <string key="postal-code">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="country" mode="xml2json">
      <string key="country">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="email" mode="xml2json">
      <string key="email">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="phone" mode="xml2json">
      <string key="phone">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="url" mode="xml2json">
      <string key="url">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="notes" mode="xml2json">
      <map key="notes">
         <xsl:call-template name="prose"/>
      </map>
   </xsl:template>
   <xsl:template match="system" mode="xml2json">
      <map key="system">
         <xsl:apply-templates select="full-name" mode="#current"/>
         <xsl:apply-templates select="short-name" mode="#current"/>
         <xsl:apply-templates select="system-id" mode="#current"/>
         <xsl:apply-templates select="desc" mode="#current"/>
         <xsl:apply-templates select="notes" mode="#current"/>
         <xsl:if test="exists(meta-group)">
            <array key="meta-groups">
               <xsl:apply-templates select="meta-group" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="system-id" mode="xml2json">
      <map key="system-id">
         <xsl:apply-templates mode="as-string" select="@type"/>
         <xsl:apply-templates mode="as-string" select=".">
            <xsl:with-param name="key">STRVALUE</xsl:with-param>
         </xsl:apply-templates>
      </map>
   </xsl:template>
   <xsl:template match="desc" mode="xml2json">
      <string key="desc">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="history" mode="xml2json">
      <map key="history">
         <xsl:if test="exists(release)">
            <array key="releases">
               <xsl:apply-templates select="release" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="release" mode="xml2json">
      <map key="release">
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:apply-templates select="date" mode="#current"/>
         <xsl:apply-templates select="version" mode="#current"/>
         <xsl:if test="exists(doc-id)">
            <array key="document-identifiers">
               <xsl:apply-templates select="doc-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(pub-id)">
            <array key="publication-identifiers">
               <xsl:apply-templates select="pub-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="preparation" mode="#current"/>
         <xsl:apply-templates select="notes" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="preparation" mode="xml2json">
      <map key="preparation">
         <xsl:if test="exists(organization)">
            <array key="organizations">
               <xsl:apply-templates select="organization" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="attachment" mode="xml2json">
      <map key="attachment">
         <xsl:apply-templates mode="as-string" select="@href"/>
         <xsl:apply-templates select="title" mode="#current"/>
         <xsl:apply-templates select="desc" mode="#current"/>
         <xsl:if test="exists(doc-id)">
            <array key="document-identifiers">
               <xsl:apply-templates select="doc-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(pub-id)">
            <array key="publication-identifiers">
               <xsl:apply-templates select="pub-id" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="file" mode="#current"/>
         <xsl:apply-templates select="notes" mode="#current"/>
         <xsl:if test="exists(meta-group)">
            <array key="meta-groups">
               <xsl:apply-templates select="meta-group" mode="#current"/>
            </array>
         </xsl:if>
      </map>
   </xsl:template>
   <xsl:template match="file" mode="xml2json">
      <map key="file">
         <xsl:apply-templates select="format" mode="#current"/>
         <xsl:apply-templates select="timestamp" mode="#current"/>
         <xsl:apply-templates select="url" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="format" mode="xml2json">
      <string key="format">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="timestamp" mode="xml2json">
      <string key="timestamp">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
   <xsl:template match="meta-group" mode="xml2json">
      <map key="meta-group">
         <xsl:apply-templates mode="as-string" select="@term"/>
         <xsl:apply-templates mode="as-string" select="@type"/>
         <xsl:if test="exists(meta)">
            <array key="metadata-fields">
               <xsl:apply-templates select="meta" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:if test="exists(meta-group)">
            <array key="metadata-groups">
               <xsl:apply-templates select="meta-group" mode="#current"/>
            </array>
         </xsl:if>
         <xsl:apply-templates select="notes" mode="#current"/>
      </map>
   </xsl:template>
   <xsl:template match="meta" mode="xml2json">
      <string key="meta">
         <xsl:apply-templates mode="md"/>
      </string>
   </xsl:template>
</xsl:stylesheet>
