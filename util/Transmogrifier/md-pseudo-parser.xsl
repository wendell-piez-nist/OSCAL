<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://raventracks.org/ExtensibleMarkdown/ns"
    xpath-default-namespace="http://raventracks.org/ExtensibleMarkdown/ns"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output/>
    
<!-- Markdown pseudoparser in XSLT  -->
    
    <!-- Mappings:
        *** becomes <strong><em>
        ** becomes <strong>
        * becomes <em>
        ` becomes <code>
        ~ becomes <sub>
        ^ becomes <sup>
        " becomes <q>
        ()[] becomes <a href>
        
        We manage this by casting syntax to tagging, then attempting to parse the tagging (when it is available).
    First, we have to escape characters that will be construed as markup
    i.e. < and & to &lt; and &amp;
    (we ignore quotes b/c we will not be producing attributes only elements)
    
    casting (escaped) delimiter chars to numeric char references?
    
    casting delimiter-string pairs to tags
    trying to parse (eheh) - wf error drops back
      to show raw syntax
      
    
    -->
   
    <xsl:variable name="tag-specification" as="element(tag-spec)">
        <tag-spec>
            <q>"<insert/>"</q>
            <a href="\[{{$insert}}\]">\(<insert/>\)</a>
            <code>`<insert/>`</code>
            <strong><em>\*\*\*<insert/>\*\*\*</em></strong>
            <strong>\*\*<insert/>\*\*</strong>
            <em>\*<insert/>\*</em>
            <sub>~<insert/>~</sub>
            <sup>\^<insert/>\^</sup>
        </tag-spec>
    </xsl:variable>
    
    <xsl:variable name="tag-replacements">
        <rules>
        <replace match="&lt;">&amp;lt;</replace>
        <replace match="&amp;">&amp;amp;</replace>
        <replace match="\\&#34;">&amp;quot;</replace>
            <replace match="\\\*">&amp;#2A;</replace>
            <replace match="\\`">&amp;#60;</replace>
        <replace match="\\~">&amp;#7E;</replace>
        <replace match="\\^">&amp;#5E;</replace>
        

        <xsl:for-each select="$tag-specification/*">
            <xsl:variable name="match-expr">
                <xsl:apply-templates select="." mode="write-match"/>
            </xsl:variable>
            <xsl:variable name="repl-expr">
                <xsl:apply-templates select="." mode="write-replace"/>
            </xsl:variable>
            
            <replace match="{$match-expr}">
                <xsl:sequence select="$repl-expr"/>
            </replace>
            
        </xsl:for-each>
        </rules>
    </xsl:variable>
    
    <xsl:template match="*" mode="write-replace">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:apply-templates mode="#current" select="@*"/>

        <xsl:text>&gt;</xsl:text>

        <xsl:apply-templates mode="#current" select="*"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>

    <xsl:template match="*" mode="write-match">
        <xsl:apply-templates select="@*, node()" mode="write-match"/>
    </xsl:template>
    
    <xsl:template match="@*[matches(.,'\{\$insert\}')]" mode="write-match">
        <xsl:value-of select="replace(.,'\{\$insert\}','(.*)?')"/>
    </xsl:template>
    
    <xsl:template match="insert" mode="write-replace">
        <xsl:text>$1</xsl:text>
    </xsl:template>
    
    <xsl:template match="a/@href" mode="write-replace">
        <xsl:text> href="$2"</xsl:text>
        <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
    </xsl:template>
    
    
<xsl:template match="insert" mode="write-match">
  <xsl:text>(.*?)</xsl:text>
</xsl:template>

    <!--<xsl:template match="insert" mode="write-replace"/>-->

    <xsl:template match="/">
        <examples>
        <xsl:variable name="examples">
            <p>Here's a markdown string.</p>
            <p>`code` may occasionally turn up `in the middle`.</p>
            <p>Here's a ***really interesting*** markdown string.</p>
            <p>Some paragraphs might have [links elsewhere](https://link.org).</p>
                
        </xsl:variable>
        <xsl:for-each select="$examples/p">
            <xsl:text>&#xA;</xsl:text>
                 <xsl:variable name="markup-string">
                    <xsl:text>&lt;p xmlns="http://raventracks.org/ExtensibleMarkdown/ns"></xsl:text>
                    
            <xsl:apply-templates select="$tag-replacements/rules">
                <xsl:with-param name="original" tunnel="yes" as="text()">
                    <xsl:value-of select="string(.)"/>
                </xsl:with-param>
            </xsl:apply-templates>
                    <xsl:text>&lt;/p></xsl:text>
                    
                </xsl:variable>
                <xsl:sequence select="parse-xml($markup-string)  "/>
        </xsl:for-each>
        </examples>
        
    </xsl:template>
        
<!-- Match 'rules' passing in $original to receive original back
        as a fully-replaced string. -->
    <xsl:template match="rules" as="xs:string">
        
        <!-- Original is only provided for processing text nodes -->
        <xsl:param name="original" as="text()?" tunnel="yes"/>
        <xsl:param name="starting" as="xs:string" select="string($original)"/>
        <xsl:iterate select="*">
            <xsl:param name="original" select="$original" as="text()?"/>
            <xsl:param name="str"      select="$starting" as="xs:string"/>
            <xsl:on-completion select="$str"/>
            <xsl:next-iteration>
                <xsl:with-param name="str">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="str"      select="$str"/>
                    </xsl:apply-templates>
                </xsl:with-param>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:template>
    
    <xsl:template match="replace" expand-text="true">
        <xsl:param name="str" as="xs:string"/>
        <!--<xsl:value-of>replace({$str},{@match},{string(.)})</xsl:value-of>-->
        <xsl:sequence select="replace($str,@match,string(.))"/>
        <!--<xsl:copy-of select="."/>-->
    </xsl:template>
    
</xsl:stylesheet>