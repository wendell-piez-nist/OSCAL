<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns="http://www.w3.org/2005/xpath-functions"
    
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="#all">
    
    <xsl:output indent="yes"/>
    
    
<!-- Produces JSON from OSCAL. Tested on SP-800-53 OSCAL
     but it should work on any. -->
     
     <!-- 
        
        we want results like
        
       
        <map xmlns="http://www.w3.org/2005/xpath-functions">
   <map key="controls">
      <array key="control">
         <map>
            <string key="family">ACCESS CONTROL</string>
            <string key="number">AC-1</string>
            <string key="title">ACCESS CONTROL POLICY AND PROCEDURES</string>
            <string key="description">This control addresses the establishment of policy and procedures for the
   
    this conforms to schema analysis/xml-json.xsd, which describes the requirements for the
    XML mapping format (for JSON targets) specified by XPath and implemented by the XPath xml-to-json() function.
    
    Producing such XML, that is, produces stable JSON for free, with mapping issues exposed in the transformation.
    
    -->
    
    <xsl:template match="/">
        <map>
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="/control">
        <xsl:variable name="as-map">
            <xsl:next-match/>
        </xsl:variable>
        <map>
            <xsl:sequence select="$as-map/*"/>
        </map>
    </xsl:template>
    
    
    <xsl:template match="catalog">
        <map key="catalog">
            <xsl:apply-templates select="title, declarations"/>
            <xsl:call-template name="controls-then-groups"/>
        </map>
    </xsl:template>
    
    <xsl:template match="group">
        <map>
            <xsl:apply-templates select="title"/>
            <xsl:call-template name="controls-then-groups"/>
        </map>
    </xsl:template>
    
    <xsl:template name="controls-then-groups">
        <xsl:call-template name="elems-arrayed">
            <xsl:with-param name="elems" select="control"/>
        </xsl:call-template>
        <xsl:call-template name="elems-arrayed">
            <xsl:with-param name="elems" select="group"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Map full declarations in subsequent pass - -->
    <xsl:template match="declarations">
        <map key="declarations">
            <xsl:apply-templates mode="as-string" select="@*"/>
        </map>
    </xsl:template>

    <xsl:template mode="as-string" match="@* | *">
        <xsl:param name="key" select="local-name()"/>
        <string key="{$key}">
            <xsl:value-of select="."/>
        </string>
    </xsl:template>
    
    
    <xsl:template mode="prose" match="*">
        <xsl:if test="exists(p | ul | ol | pre)">
        <array key="prose">
            <xsl:apply-templates mode="md" select="p | ul | ol | pre"/>
        </array>
        </xsl:if>
    </xsl:template>
    
    
    
    
    <xsl:template match="control | subcontrol">
        <map>
            <xsl:if test="empty(parent::*)">
                <xsl:attribute name="key" select="local-name()"/>
            </xsl:if>
            
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:apply-templates select="title"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="prop"/>
            </xsl:call-template>
            <xsl:call-template name="param-sequence-as-object"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="part | link | subcontrol"/>
            </xsl:call-template>
            <!--<xsl:apply-templates/>-->
        </map>
    </xsl:template>
    
    <xsl:template name="elems-arrayed">
        <xsl:param name="elems" as="node()*" select="*"/>
        <xsl:for-each-group select="$elems" group-by="local-name()">
            <xsl:variable name="new-key">
                <xsl:apply-templates mode="cast-key" select="current-grouping-key()"/>
            </xsl:variable>
            <array key="{$new-key}">
                <xsl:apply-templates select="current-group()"/>
            </array>
        </xsl:for-each-group>
    </xsl:template>
    
<!-- Experimental   -->
    
   
    <xsl:template name="param-sequence-as-object">
        <xsl:for-each-group select="param" group-by="local-name()">
            <map key="params">
                <xsl:apply-templates select="current-group()"/>
            </map>
            
            <!--<xsl:variable name="new-key">
                <xsl:apply-templates mode="cast-key" select="current-grouping-key()"/>
            </xsl:variable>
            <array key="{$new-key}">
                <xsl:apply-templates select="current-group()"/>
            </array>-->
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template mode="cast-key" match="." expand-text="true">{.}s</xsl:template>
        
    <xsl:template mode="cast-key" match=".[.='match']"        >matches</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='set-param']"    >param-settings</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='alter']"        >alterations</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='remove']"       >removals</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='add']"          >additions</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='desc']"         >descriptions</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='choice']"       >alternatives</xsl:template>
    
    <xsl:template mode="cast-key" match=".[.='requirement']"  >requirements</xsl:template>
    
    
    <xsl:template match="title">
        <string key="title">
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>
    
    <!--Declaration of param: 
        <fields named="desc" group-as="descriptions"/>
    <field  named="label"/>
    <fields named="requirement" group-as="requirements"/>
    <choice>
        <field    named="value"/>
        <assembly named="select"/>
    </choice>
    <fields named="link" group-as="links"/>
    <assemblies named="part" group-as="parts"/>
    -->
    <xsl:template match="param">
        <map key="{@id}">
            <xsl:apply-templates mode="as-string" select="@* except @id"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="desc"/>
            </xsl:call-template>
            <xsl:apply-templates mode="as-string" select="label"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="requirement"/>
            </xsl:call-template>
            <xsl:apply-templates mode="as-string" select="value"/>
            <xsl:apply-templates                  select="select"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="link, part"/>
            </xsl:call-template>
            
        </map>
        <!--<map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:apply-templates mode="as-string" select="*"/>
        </map>-->
    </xsl:template>
    
    <xsl:template match="prop">
        <!--<map>
          <xsl:apply-templates select="." mode="as-string">
              <xsl:with-param name="key" select="@class"/>
          </xsl:apply-templates>
        </map>-->
        <map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:apply-templates mode="as-string" select=".">
                <xsl:with-param name="key">VALUE</xsl:with-param>
            </xsl:apply-templates>
        </map>
    </xsl:template>
    
    <xsl:template match="part">
        <map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:apply-templates select="title"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="param | prop"/>
            </xsl:call-template>
            <xsl:apply-templates mode="prose" select="."/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="part | link"/>
            </xsl:call-template>
        </map>
    </xsl:template>
    
    <xsl:template match="link">
        <map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:if test="matches(.,'\S')">
                <string key="TEXT">
                    <xsl:apply-templates mode="md"/>
                </string>
            </xsl:if>
        </map>
    </xsl:template>
    
    <xsl:template match="select">
        <map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="choice"/>
            </xsl:call-template>
        </map>
    </xsl:template>
    
    <xsl:template match="choice">
        <map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:if test="matches(.,'\S')">
                <string key="TEXT">
                    <xsl:apply-templates mode="md"/>
                </string>
            </xsl:if>
        </map>
    </xsl:template>
    
    <xsl:template match="desc">
        <string>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>
    
    <xsl:template xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        match="@xsi:*" mode="#all" priority="99"/>
    
    
    
   <xsl:key name="parameters" match="param" use="@id"/>
    
   <xsl:template match="references"/>
    

<!--    <xsl:template match="references">
        <map key="references">
            <array key="item">
                <xsl:for-each select="ref/citation">
                    <map>
                        <string key="text">
                            <xsl:value-of select="."/>
                        </string>
                        <xsl:for-each select="@href">
                            <string key="href">
                                <xsl:value-of select="."/>
                            </string>
                        </xsl:for-each>

                    </map>
                </xsl:for-each>
            </array>
        </map>
    </xsl:template>
-->    

<!-- Now templates for profile -->
    
    <xsl:template match="profile">
        <map key="profile">
            <string key="document-type">profile</string>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="import"/>
            </xsl:call-template>
            <!-- Extra step to silence oxygen warning msg -->
            <xsl:apply-templates select="./merge, ./modify"/>
        </map>
    </xsl:template>
    
    <xsl:template match="import">
        <map>
            <xsl:apply-templates select="@*" mode="as-string"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="include | exclude"/>
            </xsl:call-template>
            
        </map>
    </xsl:template>
    
    <xsl:template match="include | exclude">
        <map>
            <xsl:apply-templates select="@*" mode="as-string"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="call | match"/>
            </xsl:call-template>
            
        </map>
    </xsl:template>
    
    <xsl:template match="call | match">
        <map>
            <xsl:apply-templates select="@*" mode="as-string"/>
        </map>
    </xsl:template>
    
    <xsl:template match="set-param">
        <map>
            <xsl:apply-templates select="@*" mode="as-string"/>
            <xsl:apply-templates select="*"  mode="as-string"/>
        </map>
    </xsl:template>
    
    <xsl:template match="modify">
        <xsl:call-template name="elems-arrayed">
            <xsl:with-param name="elems" select="set-param | alter"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="alter">
        <map>
            <xsl:apply-templates select="@*" mode="as-string"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="remove"/>
            </xsl:call-template>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="add"/>
            </xsl:call-template>
            <!-- Extra step to silence oxygen warning msg -->
            <xsl:apply-templates select="./merge, ./modify"/>
        </map>
    </xsl:template>
    
    <xsl:template match="remove">
        <map>
            <xsl:call-template name="elems-arrayed">
            <xsl:with-param name="elems" select="@class-ref | @id-ref | @item-name"/>
        </xsl:call-template>
        </map>
        
    </xsl:template>

    <xsl:template match="remove/@*" expand-text="true">
        <xsl:for-each select="tokenize(.,'\s+')">
            <string>{.}</string>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="add">
        <map>
            <xsl:apply-templates mode="as-string" select="@*"/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="param | prop"/>
            </xsl:call-template>
            <xsl:apply-templates mode="prose" select="."/>
            <xsl:call-template name="elems-arrayed">
                <xsl:with-param name="elems" select="part | link"/>
            </xsl:call-template>
        </map>
    </xsl:template>
    
    
    <!--<xsl:template mode="md" match="@* | *">
        <string>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>-->
    
    
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
                <xsl:text>&#32;&#32;</xsl:text>
            </xsl:for-each>
            <xsl:text>* </xsl:text>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template><!-- Since XProc doesn't support character maps we do this in XSLT -   -->
    
    <xsl:template mode="md" match="ol/li">
        <string/>
        <string>
            <xsl:for-each select="../ancestor::ul">
                <xsl:text>&#32;&#32;</xsl:text>
            </xsl:for-each>
            <xsl:text>1. </xsl:text>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template><!-- Since XProc doesn't support character maps we do this in XSLT -   -->
    
    
    
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
        <xsl:variable name="link-target" select="key('element-by-id',substring-after(@href,'#'))"/>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="replace(.,'&lt;','&amp;lt;')"/>
        <xsl:text>]</xsl:text>
        <xsl:text>(#</xsl:text>
        <xsl:value-of select="$link-target/*[1] => normalize-space() => lower-case() => replace('\s+','-') => replace('[^a-z\-\d]','')"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="pre//text()">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()">
        <!-- Escapes go here       -->
        <xsl:value-of select="replace(.,'\s+',' ') => replace('([`~\^\*])','\$1')"/>
    </xsl:template>
    
    <!--<xsl:function name="oscal:serialize" as="xs:string">
        <xsl:param name="who" as="node()"/>
        <xsl:variable name="no-ns">
            <xsl:apply-templates select="$who" mode="serialize"/>
        </xsl:variable>
        <!-\- Note we have to cast off delimiters after serializing -\->
        <xsl:value-of select="serialize($no-ns)"/>
        <!-\-<xsl:value-of select="serialize($no-ns) => replace('&lt;','\\u003c') => replace('&gt;','\\u003e')"/>"/>-\->
    </xsl:function>-->
    
    
</xsl:stylesheet>