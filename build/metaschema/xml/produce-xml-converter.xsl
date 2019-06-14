<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    version="3.0"
    
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    
    xmlns="http://www.w3.org/2005/xpath-functions">
    
<!-- Purpose: Produce an XSLT supporting bidirectional XML-JSON syntax negotiation based on constraints declared in a netaschema -->
<!-- Input:   A Metaschema -->
<!-- Output:  An XSLT, supporting bidirectional transformation. -->

<!-- nb A schema and Schematron for the metaschema format should be found nearby. -->

    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    <xsl:variable name="target-namespace" select="string(/METASCHEMA/namespace)"/>
    
    <xsl:variable name="root-name" select="/METASCHEMA/@root/string(.)"/>
    
    <xsl:key name="definition-by-name" match="define-flag | define-field | define-assembly"
        use="@name"/>
    
    <!-- Produces composed metaschema (imports resolved) -->
    <xsl:import href="../lib/metaschema-compose.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="$composed-metaschema/METASCHEMA"/>
    </xsl:template>
    
    <xsl:template match="METASCHEMA">
        <XSLT:stylesheet version="3.0"
            xpath-default-namespace="{ $target-namespace }"
            exclude-result-prefixes="#all">
            
            <XSLT:output indent="yes" method="xml" omit-xml-declaration="yes" use-character-maps="delimiters"/>
            
            <xsl:comment> METASCHEMA conversion stylesheet supports XML->JSON conversion </xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:comment> 88888888888888888888888888888888888888888888888888888888888888 </xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:call-template name="furniture"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:comment> 88888888888888888888888888888888888888888888888888888888888888 </xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:apply-templates select="$composed-metaschema/METASCHEMA/*"/>


        </XSLT:stylesheet>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/title"/>
    
    <xsl:template match="/METASCHEMA/*" priority="-0.2"/>
    
    
<!-- Flags don't need templates since they are always handled
     with fields or assemblies. -->
    <xsl:template match="define-flag"/>
    
    <!--<xsl:template match="define-field[@address=flag/@name][@as='mixed'][empty(flag)]" priority="4">
        <XSLT:template match="{@name}" mode="xml2json">
            <string key="{@address}">
                <xsl:apply-templates mode="md"/>
            </string>
        </XSLT:template>
    </xsl:template>-->
    
    <!--<xsl:template match="define-field[@address=flag/@name][empty(flag)]" priority="3">
        <XSLT:template match="{@name}" mode="xml2json">
            <string key="{@address}">
                <xsl:apply-templates mode="md"/>
            </string>
        </XSLT:template>
    </xsl:template>-->
    
    <!--<xsl:template match="define-field[@address=flag/@name][@as='mixed']" priority="2">
        <XSLT:template match="{@name}" mode="xml2json">
            <map key="{@address}">
                <xsl:apply-templates select="flag"/>
                
                <XSLT:if test="matches(.,'\S')">
                    <string key="TEXT">
                        <XSLT:apply-templates mode="md"/>
                    </string>
                </XSLT:if>
            </map>
        </XSLT:template>
    </xsl:template>-->
    
    
<!-- Keys are added to everything and then removed from nodes in arrays, in mode 'rectify' -->

    <!-- ignoring address in these cases -->
   <!-- <xsl:template match="define-field[empty(flag)][@as='mixed']" priority="3">
        <XSLT:template match="{@name}" mode="xml2json">
            <string key="{@name}">
                <XSLT:apply-templates mode="md"/>
            </string>
        </XSLT:template>
    </xsl:template>-->
    
<!-- Handles define-field[@as='boolean']  -->
    <xsl:template match="define-field[empty(flag)]" priority="2">
        <XSLT:template match="{@name}" mode="xml2json">
            <XSLT:variable name="text-key">
                <xsl:apply-templates select="." mode="text-key"/>
            </XSLT:variable>
            
            <string key="{@name}">
                <XSLT:apply-templates mode="md"/>
            </string>
        </XSLT:template>
    </xsl:template>
    
    <!--<xsl:template match="define-field[@as='mixed']">
        <XSLT:template match="{@name}" mode="xml2json">
            <map key="{@name}">
                <xsl:apply-templates select="flag"/>
                
                <XSLT:if test="matches(.,'\S')">
                    <string key="RICHTEXT">
                        <XSLT:apply-templates mode="md"/>
                    </string>
                </XSLT:if>
            </map>
        </XSLT:template>
    </xsl:template>-->
    
    <xsl:template match="define-field" mode="text-key"             >STRVALUE</xsl:template>
    <xsl:template match="define-field[@as='mixed']" mode="text-key">RICHTEXT</xsl:template>
    
    <xsl:template match="define-field[exists(value-key)]" mode="text-key">
        <xsl:for-each select="value-key/@name">
            <XSLT:value-of select="string[@key='{.}']"/>
        </xsl:for-each>
        <xsl:if test="empty(value-key/@name)">
            <xsl:value-of select="value-key"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="define-field">
        <XSLT:template match="{@name}" mode="xml2json">
            <XSLT:variable name="text-key">
                <xsl:apply-templates select="." mode="text-key"/>
            </XSLT:variable>
            <map key="{@name}">
                <xsl:for-each select="key">
                    <xsl:attribute name="key">{@<xsl:value-of select="@name"/>}</xsl:attribute>
                </xsl:for-each>
                <xsl:apply-templates select="flag"/>

                <XSLT:apply-templates mode="as-string" select=".">
                    <XSLT:with-param name="key" select="$text-key"/>
                </XSLT:apply-templates>
            </map>
        </XSLT:template>
        <!-- flagged, groupable fields marked as collapsible may be collapsed -->
        <xsl:if test="matches(@group-as, '\S') and exists(flag) and @collapsible = ('yes','true')">
            <XSLT:template match="array[@key = '{@group-as}'][count(map) gt 1]" mode="rectify"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
                <XSLT:variable name="text-key">
                    <xsl:apply-templates select="." mode="text-key"/>
                </XSLT:variable>
                <xsl:variable name="group-properties">
                    <xsl:variable name="flag-names" as="xs:string*">
                        <xsl:perform-sort select="flag/@name/normalize-space(.)">
                            <xsl:sort select="."/>
                        </xsl:perform-sort>
                    </xsl:variable>
                    <xsl:sequence select="string-join($flag-names ! ( '*[@key = ''' || . || ''']'),',')"/>
                </xsl:variable>
                <XSLT:for-each-group select="map"
                    group-by="string-join( ({ $group-properties } ), '#' )">
                    <map key="{ @group-as}">
                        <XSLT:copy-of select="*[@key = ('days', 'baker')]"/>
                        <array key="{{$text-key}}">
                            <XSLT:for-each select="current-group()/string[@key = $text-key]">
                                <string>
                                    <XSLT:apply-templates mode="#current"/>
                                </string>
                            </XSLT:for-each>
                        </array>
                    </map>
                </XSLT:for-each-group>
            </XSLT:template>
        </xsl:if>
    </xsl:template>
   
    
    <!-- no special provision made for addressing by @id that happens at the other end -->
    <xsl:template match="define-assembly">
        <XSLT:template match="{@name}" mode="xml2json">
            <map key="{@name}">
                <xsl:for-each select="key">
                    <xsl:attribute name="key">{@<xsl:value-of select="@name"/>}</xsl:attribute>
                </xsl:for-each>

                <xsl:apply-templates select="flag"/>

                <xsl:apply-templates select="model"/>
            </map>
        </XSLT:template>
    </xsl:template>
    
    <xsl:template match="flag">
        <!-- no datatyping support yet -->
        <XSLT:apply-templates mode="as-string" select="@{@name}"/>
    </xsl:template>
    
    <xsl:template match="model">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="prose">
        <XSLT:call-template name="prose"/>
    </xsl:template>
    
    <xsl:template match="field | assembly">
        <XSLT:apply-templates select="{@named}" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="fields | assemblies">
            <XSLT:if test="exists({@named})">
                <array key="{ key('definition-by-name',@named)/@group-as }">
                    <XSLT:apply-templates select="{@named}" mode="#current"/>
                </array>
            </XSLT:if>
        <!--<XSLT:call-template name="elems-arrayed">
            <XSLT:with-param name="elems" select="{@named}"/>
            <XSLT:with-param name="group-as" select="'{@group-as}'"/>
        </XSLT:call-template>-->
    </xsl:template>
    
    <xsl:template match="fields[exists(key('definition-by-name',@named)/key)] |
        assemblies[exists(key('definition-by-name',@named)/key)]">
        <xsl:variable name="key" select="exists(key('definition-by-name',@named)/key)"/>
            <XSLT:for-each-group select="{@named}" group-by="local-name()">
                <map key="{  key('definition-by-name',@named)/@group-as }">
                    <XSLT:apply-templates select="current-group()" mode="#current"/>
                </map>
            </XSLT:for-each-group>
    </xsl:template>
    
    <xsl:template name="furniture">
        
        <XSLT:character-map name="delimiters">
            <XSLT:output-character character="&lt;" string="\u003c"/>
            <XSLT:output-character character="&gt;" string="\u003e"/>
        </XSLT:character-map>
        
        <XSLT:param name="json-indent" as="xs:string">no</XSLT:param>
        <xsl:comment> Pass $diagnostic as 'rough' for first pass, 'rectified' for second pass </xsl:comment>
        <XSLT:param name="diagnostic"  as="xs:string">no</XSLT:param>
        
        <XSLT:variable name="write-options" as="map(*)" expand-text="true">
            <XSLT:map>
                <XSLT:map-entry key="'indent'">{ $json-indent='yes' }</XSLT:map-entry>
            </XSLT:map>
        </XSLT:variable>
        
        <XSLT:variable name="xpath-json">
            <map>
                <XSLT:apply-templates select="/" mode="xml2json"/>
            </map>
        </XSLT:variable>
        
        <XSLT:variable name="rectified">
            <XSLT:apply-templates select="$xpath-json" mode="rectify"/>
        </XSLT:variable>
        
        <XSLT:template match="/">
            <XSLT:choose>
                <XSLT:when test="$diagnostic='rough'">
                    <XSLT:copy-of select="$xpath-json"/>
                </XSLT:when>
                <XSLT:when test="$diagnostic='rectified'">
                    <XSLT:copy-of select="$rectified"/>
                </XSLT:when>
                <XSLT:otherwise>
                    <XSLT:value-of select="xml-to-json($rectified, $write-options)"/>
                </XSLT:otherwise>
            </XSLT:choose>
        </XSLT:template>
        
        <XSLT:mode name="rectify" on-no-match="shallow-copy"/>
        
        <XSLT:template mode="rectify" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
            match="/*/@key | array/*/@key"/>
        
        <XSLT:template mode="rectify" match="array[count(*) eq 1]"
            xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
            <XSLT:for-each select="*">
                <XSLT:copy>
                    <XSLT:copy-of select="../@key"/>
                    <XSLT:apply-templates mode="#current"/>
                </XSLT:copy>
            </XSLT:for-each>
        </XSLT:template>
        
        <XSLT:template name="prose">
            <XSLT:variable name="blocks" select="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table"/>
            <XSLT:if test="exists($blocks)">
                <array key="prose">
                    <XSLT:apply-templates mode="md" select="$blocks"/>
                </array>
            </XSLT:if>
        </XSLT:template>
        
        <XSLT:template mode="as-string" match="@* | *">
            <XSLT:param name="key" select="local-name()"/>
            <XSLT:if test="matches(.,'\S')">
            <string key="{{$key}}">
                <XSLT:value-of select="."/>
            </string>
            </XSLT:if>
        </XSLT:template>
        
        <!--<XSLT:key name="parameters" match="param" use="@id"/>-->
        
        <XSLT:template name="conditional-lf">
            <XSLT:variable name="predecessor"
                select="preceding-sibling::p | preceding-sibling::ul | preceding-sibling::ol | preceding-sibling::table | preceding-sibling::pre"/>
            <XSLT:if test="exists($predecessor)">
                <string/>
            </XSLT:if>
        </XSLT:template>
        
        <XSLT:template mode="md" match="p | link | part/*">
            <XSLT:call-template name="conditional-lf"/>
            <string>
                <XSLT:apply-templates mode="md"/>
            </string>
        </XSLT:template>
        
        <XSLT:template mode="md" match="h1 | h2 | h3 | h4 | h5 | h6">
            <XSLT:call-template name="conditional-lf"/>
            <string>
                <XSLT:apply-templates select="." mode="mark"/>
                <XSLT:apply-templates mode="md"/>
            </string>
        </XSLT:template>

        <XSLT:template mode="mark" match="h1"># </XSLT:template>
        <XSLT:template mode="mark" match="h2">## </XSLT:template>
        <XSLT:template mode="mark" match="h3">### </XSLT:template>
        <XSLT:template mode="mark" match="h4">#### </XSLT:template>
        <XSLT:template mode="mark" match="h5">##### </XSLT:template>
        <XSLT:template mode="mark" match="h6">###### </XSLT:template>
        
        <XSLT:template mode="md" match="table">
            <XSLT:call-template name="conditional-lf"/>
            <XSLT:apply-templates  select="*"  mode="md"/>
        </XSLT:template>
        
        <XSLT:template mode="md" match="tr">
            <string>
                <XSLT:apply-templates select="*" mode="md"/>
            </string>
            <XSLT:if test="empty(preceding-sibling::tr)">
                <string>
                    <XSLT:text>|</XSLT:text>
                    <XSLT:for-each select="th | td">
                        <xsl:text> --- |</xsl:text>
                    </XSLT:for-each>
                </string>
            </XSLT:if>
        </XSLT:template>
        
        <XSLT:template mode="md" match="th | td">
            <XSLT:if test="empty(preceding-sibling::*)">|</XSLT:if>
            <XSLT:text><xsl:text> </xsl:text></XSLT:text>
            <XSLT:apply-templates mode="md"/>
            <XSLT:text> |</XSLT:text>
        </XSLT:template>
        
        <XSLT:template mode="md" priority="1" match="pre">
            <XSLT:call-template name="conditional-lf"/>
            <string>```</string>
            <string>
                <XSLT:apply-templates mode="md"/>
            </string>
            <string>```</string>
        </XSLT:template>

        <XSLT:template mode="md" priority="1" match="ul | ol">
            <XSLT:call-template name="conditional-lf"/>
            <XSLT:apply-templates mode="md"/>
            <string/>
        </XSLT:template>
        
        <XSLT:template mode="md" match="ul//ul | ol//ol | ol//ul | ul//ol">
            <XSLT:apply-templates mode="md"/>
        </XSLT:template>
        
        <XSLT:template mode="md" match="li">
            <string>
                <XSLT:for-each select="../ancestor::ul">
                    <XSLT:text>&#32;&#32;</XSLT:text>
                </XSLT:for-each>
                <XSLT:text>* </XSLT:text>
                <XSLT:apply-templates mode="md"/>
            </string>
        </XSLT:template><!-- Since XProc doesn't support character maps we do this in XSLT -   -->
        
        <XSLT:template mode="md" match="ol/li">
            <string/>
            <string>
                <XSLT:for-each select="../ancestor::ul">
                    <XSLT:text>&#32;&#32;</XSLT:text>
                </XSLT:for-each>
                <XSLT:text>1. </XSLT:text>
                <XSLT:apply-templates mode="md"/>
            </string>
        </XSLT:template><!-- Since XProc doesn't support character maps we do this in XSLT -   -->
        
        
        
        <XSLT:template mode="md" match="code | span[contains(@class,'code')]">
            <XSLT:text>`</XSLT:text>
            <XSLT:apply-templates mode="md"/>
            <XSLT:text>`</XSLT:text>
        </XSLT:template>
        
        <XSLT:template mode="md" match="em | i">
            <XSLT:text>*</XSLT:text>
            <XSLT:apply-templates mode="md"/>
            <XSLT:text>*</XSLT:text>
        </XSLT:template>
        
        <XSLT:template mode="md" match="strong | b">
            <XSLT:text>**</XSLT:text>
            <XSLT:apply-templates mode="md"/>
            <XSLT:text>**</XSLT:text>
        </XSLT:template>
        
        <XSLT:template mode="md" match="q">
            <XSLT:text>"</XSLT:text>
            <XSLT:apply-templates mode="md"/>
            <XSLT:text>"</XSLT:text>
        </XSLT:template>
        
        <!-- <insert param-id="ac-1_prm_1"/> -->
        <XSLT:template mode="md" match="insert">
            <XSLT:text>{ </XSLT:text>
            <XSLT:value-of select="@param-id"/>
            <XSLT:text> }</XSLT:text>
        </XSLT:template>
        
        <XSLT:key name="element-by-id" match="*[exists(@id)]" use="@id"/>
        
        <XSLT:template mode="md" match="a">
            <XSLT:text>[</XSLT:text>
            <XSLT:value-of select="."/>
            <XSLT:text>]</XSLT:text>
            <XSLT:text>(</XSLT:text>
            <XSLT:value-of select="@href"/>
            <XSLT:text>)</XSLT:text>
        </XSLT:template>
        
        <XSLT:template match="text()" mode="md">
            <!-- Escapes go here       -->
            <!--<XSLT:value-of select="replace(.,'\s+',' ') ! replace(.,'([`~\^\*])','\\$1')"/>-->
            <XSLT:value-of select="replace(.,'([`~\^\*''&quot;])','\\$1')"/>
        </XSLT:template>
        
        
    </xsl:template>
    
</xsl:stylesheet>