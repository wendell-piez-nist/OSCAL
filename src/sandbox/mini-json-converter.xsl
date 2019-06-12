<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                version="3.0"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all">
   <xsl:output indent="yes" method="xml"/>
   <!-- OSCAL lunch conversion stylesheet supports JSON->XML conversion -->
   <xsl:param name="target-ns" as="xs:string?" select="'urn:mini'"/>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <xsl:output indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xsl:preserve-space elements="string"/>
   <xsl:param name="json-file" as="xs:string"/>
   <xsl:variable name="json-xml" select="unparsed-text($json-file) ! json-to-xml(.)"/>
   <xsl:template name="xsl:initial-template" match="/">
      <xsl:choose>
         <xsl:when test="matches($json-file,'\S') and exists($json-xml/map)">
            <xsl:apply-templates select="$json-xml" mode="json2xml"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="json2xml"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="/map[empty(@key)]" priority="10" mode="json2xml">
      <xsl:apply-templates mode="#current" select="*[@key=('lunch')]"/>
   </xsl:template>
   <xsl:template match="array" priority="10" mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template match="array[@key='prose']" priority="11" mode="json2xml">
      <xsl:variable name="text-contents" select="string-join(string,'&#xA;')"/>
      <xsl:call-template name="parse">
         <xsl:with-param name="str" select="$text-contents"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="string[@key='prose']" priority="11" mode="json2xml">
      <xsl:call-template name="parse">
         <xsl:with-param name="str" select="string(.)"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="string" mode="handle-inlines"/>
   <xsl:template match="string[@key='RICHTEXT']" mode="json2xml handle-inlines">
      <xsl:variable name="markup">
         <xsl:apply-templates mode="infer-inlines"/>
      </xsl:variable>
      <xsl:apply-templates mode="cast-ns" select="$markup"/>
   </xsl:template>
   <xsl:template match="string[@key='STRVALUE']" mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="as-attribute" match="*"/>
   <xsl:template mode="as-attribute" match="string[@key='id']" priority="0.4">
      <xsl:attribute name="id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <!-- 000 Handling assembly "lunch" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='lunch'] | /map[empty(@key)]"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="lunch" namespace="urn:mini">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('salad')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('sandwich', 'sandwiches')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('chip', 'chips')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('cookie', 'cookies')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('cupcake', 'cupcakes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "sandwich" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='sandwich'] | *[@key='sandwiches'] | array[@key='sandwiches']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="sandwich" namespace="urn:mini">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "chip" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='chip'] | *[@key='chips'] | array[@key='chips']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="chip" namespace="urn:mini">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates mode="json2xml"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "cookie" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='cookie'] | *[@key='cookies'] | array[@key='cookies']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="cookie" namespace="urn:mini">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates mode="json2xml" select="string[@key=('STRVALUE','RICHTEXT')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "days" 000 -->
   <xsl:template match="*[@key='days']" mode="json2xml"/>
   <xsl:template match="*[@key='cookie']/*[@key='days'] | *[@key='cookies']/*[@key='days'] | array[@key='cookies']/*/*[@key='days']"
                 mode="as-attribute">
      <xsl:attribute name="days">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "baker" 000 -->
   <xsl:template match="*[@key='baker']" mode="json2xml"/>
   <xsl:template match="*[@key='cookie']/*[@key='baker'] | *[@key='cookies']/*[@key='baker'] | array[@key='cookies']/*/*[@key='baker']"
                 mode="as-attribute">
      <xsl:attribute name="baker">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling field "cupcake" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='cupcake'] | *[@key='cupcakes'] | array[@key='cupcakes']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="cupcake" namespace="urn:mini">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates mode="json2xml" select="string[@key=('STRVALUE','RICHTEXT')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "icing" 000 -->
   <xsl:template match="*[@key='icing']" mode="json2xml"/>
   <xsl:template match="*[@key='cupcake']/*[@key='icing'] | *[@key='cupcakes']/*[@key='icing'] | array[@key='cupcakes']/*/*[@key='icing']"
                 mode="as-attribute">
      <xsl:attribute name="icing">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "salad" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='salad']" priority="2" mode="json2xml">
      <xsl:element name="salad" namespace="urn:mini">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('masked-field', 'masked-fields')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('labeled-value-field', 'labeled-value-fields')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('ID-object', 'ID-objects')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "masked-field" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='masked-field'] | *[@key='masked-fields'] | array[@key='masked-fields']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="masked-field" namespace="urn:mini">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates mode="json2xml"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "labeled-value-field" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='labeled-value-field'] | *[@key='labeled-value-fields'] | array[@key='labeled-value-fields']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="labeled-value-field" namespace="urn:mini">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates mode="json2xml"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "ID-object" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='ID-object'] | *[@key='ID-objects'] | array[@key='ID-objects']/*"
                 priority="2"
                 mode="json2xml">
      <xsl:element name="ID-object" namespace="urn:mini">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates mode="json2xml"/>
      </xsl:element>
   </xsl:template>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <!-- Markdown converter-->
   <xsl:output indent="yes"/>
   <xsl:template name="parse"><!-- First, group according to ``` delimiters btw codeblocks and not
        within codeblock, escape & and < (only)
        within not-codeblock split lines at \n\s*\n
        
        --><!-- $str may be passed in, or we can process the current node -->
      <xsl:param name="str" select="string(.)"/>
      <xsl:variable name="starts-with-code" select="matches($str,'^```')"/>
      <!-- Blocks is split between code blocks and everything else -->
      <xsl:variable name="blocks">
         <xsl:for-each-group select="tokenize($str, '\n')"
                             group-starting-with=".[matches(., '^```')]">
            <xsl:variable name="this-is-code"
                          select="not((position() mod 2) + number($starts-with-code))"/>
            <m:p><!-- Adding an attribute flag when this is a code block, code='code' -->
               <xsl:if test="$this-is-code">
                  <xsl:variable name="language"
                                expand-text="true"
                                select="(replace(.,'^```','') ! normalize-space(.))[matches(.,'\S')]"/>
                  <xsl:attribute name="code" select="if ($language) then $language else 'code'"/>
               </xsl:if>
               <xsl:value-of select="string-join(current-group()[not(matches(., '^```'))],'&#xA;')"/>
            </m:p>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="rough-blocks">
         <xsl:apply-templates select="$blocks" mode="parse-block"/>
      </xsl:variable>
      <xsl:variable name="flat-structures">
         <xsl:apply-templates select="$rough-blocks" mode="mark-structures"/>
      </xsl:variable>
      <!--<xsl:copy-of select="$flat-structures"/>-->
      <xsl:variable name="nested-structures">
         <xsl:apply-templates select="$flat-structures" mode="build-structures"/>
      </xsl:variable>
      <xsl:variable name="fully-marked">
         <xsl:apply-templates select="$nested-structures" mode="infer-inlines"/>
      </xsl:variable>
      <xsl:apply-templates select="$fully-marked" mode="cast-ns"/>
   </xsl:template>
   <xsl:template match="*" mode="copy mark-structures build-structures infer-inlines">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template mode="parse-block"
                 priority="1"
                 match="m:p[exists(@code)]"
                 expand-text="true">
      <xsl:element name="m:pre" namespace="{ $target-ns }">
         <xsl:element name="code" namespace="{ $target-ns }">
            <xsl:for-each select="@code[not(.='code')]">
               <xsl:attribute name="class">language-{.}</xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="string(.)"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="parse-block" match="m:p" expand-text="true">
      <xsl:for-each select="tokenize(string(.),'\n\s*\n')[normalize-space(.)]">
         <m:p>
            <xsl:value-of select="replace(.,'^\s*\n','')"/>
         </m:p>
      </xsl:for-each>
   </xsl:template>
   <xsl:function name="m:is-table-row-demarcator" as="xs:boolean">
      <xsl:param name="line" as="xs:string"/>
      <xsl:sequence select="matches($line,'^[\|\-:\s]+$')"/>
   </xsl:function>
   <xsl:function name="m:is-table" as="xs:boolean">
      <xsl:param name="line" as="element(m:p)"/>
      <xsl:variable name="lines" select="tokenize($line,'\s*\n')[matches(.,'\S')]"/>
      <xsl:sequence select="(every $l in $lines satisfies matches($l,'^\|'))             and (some $l in $lines satisfies m:is-table-row-demarcator($l))"/>
   </xsl:function>
   <xsl:template mode="mark-structures" priority="5" match="m:p[m:is-table(.)]">
      <xsl:variable name="rows">
         <xsl:for-each select="tokenize(string(.),'\s*\n')">
            <m:tr>
               <xsl:value-of select="."/>
            </m:tr>
         </xsl:for-each>
      </xsl:variable>
      <m:table>
         <xsl:apply-templates select="$rows/m:tr" mode="make-row"/>
      </m:table>
   </xsl:template>
   <xsl:template match="m:tr[m:is-table-row-demarcator(string(.))]"
                 priority="5"
                 mode="make-row"/>
   <xsl:template match="m:tr" mode="make-row">
      <m:tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <m:td>
               <xsl:value-of select="."/>
            </m:td>
         </xsl:for-each>
      </m:tr>
   </xsl:template>
   <xsl:template match="m:tr[some $f in (following-sibling::tr) satisfies m:is-table-row-demarcator(string($f))]"
                 mode="make-row">
      <m:tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <m:th>
               <xsl:value-of select="."/>
            </m:th>
         </xsl:for-each>
      </m:tr>
   </xsl:template>
   <xsl:template mode="mark-structures" match="m:p[matches(.,'^#')]"><!-- 's' flag is dot-matches-all, so \n does not impede -->
      <m:p header-level="{ replace(.,'[^#].*$','','s') ! string-length(.) }">
         <xsl:value-of select="replace(.,'^#+\s*','') ! replace(.,'\s+$','')"/>
      </m:p>
   </xsl:template>
   <xsl:variable name="li-regex" as="xs:string">^\s*(\*|\d+\.)\s</xsl:variable>
   <xsl:template mode="mark-structures" match="m:p[matches(.,$li-regex)]">
      <m:list>
         <xsl:for-each-group group-starting-with=".[matches(.,$li-regex)]"
                             select="tokenize(., '\n')">
            <m:li level="{ replace(.,'\S.*$','') ! floor(string-length(.) div 2)}"
                  type="{ if (matches(.,'\s*\d')) then 'ol' else 'ul' }">
               <xsl:for-each select="current-group()[normalize-space(.)]">
                  <xsl:if test="not(position() eq 1)">
                     <m:br/>
                  </xsl:if>
                  <xsl:value-of select="replace(., $li-regex, '')"/>
               </xsl:for-each>
            </m:li>
         </xsl:for-each-group>
      </m:list>
   </xsl:template>
   <xsl:template mode="build-structures" match="m:p[@header-level]">
      <xsl:variable name="level" select="(@header-level[6 &gt;= .],6)[1]"/>
      <xsl:element name="m:h{$level}"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0/md-convertor">
         <xsl:value-of select="."/>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="build-structures" match="m:list" name="nest-lists"><!-- Starting at level 0 and grouping  --><!--        -->
      <xsl:param name="level" select="0"/>
      <xsl:param name="group" select="m:li"/>
      <xsl:variable name="this-type" select="$group[1]/@type"/>
      <!-- first, splitting ul from ol groups -->
      <xsl:for-each-group select="$group"
                          group-starting-with="*[@level = $level and not(@type = preceding-sibling::*/@type)]">
         <xsl:element name="m:{ $group[1]/@type }"
                      namespace="http://csrc.nist.gov/ns/oscal/1.0/md-convertor">
            <xsl:for-each-group select="current-group()" group-starting-with="li[@level = $level]">
               <xsl:choose>
                  <xsl:when test="@level = $level (: checking first item in group :)">
                     <m:li><!--<xsl:copy-of select="@level"/>-->
                        <xsl:apply-templates mode="copy"/>
                        <xsl:if test="current-group()/@level &gt; $level (: go deeper? :)">
                           <xsl:call-template name="nest-lists">
                              <xsl:with-param name="level" select="$level + 1"/>
                              <xsl:with-param name="group" select="current-group()[@level &gt; $level]"/>
                           </xsl:call-template>
                        </xsl:if>
                     </m:li>
                  </xsl:when>
                  <xsl:otherwise><!-- fallback for skipping levels -->
                     <m:li><!-- level="{$level}"-->
                        <xsl:call-template name="nest-lists">
                           <xsl:with-param name="level" select="$level + 1"/>
                           <xsl:with-param name="group" select="current-group()"/>
                        </xsl:call-template>
                     </m:li>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each-group>
         </xsl:element>
      </xsl:for-each-group>
   </xsl:template>
   <xsl:template match="m:pre//text()" mode="infer-inlines">
      <xsl:copy-of select="."/>
   </xsl:template>
   <xsl:template match="text()" mode="infer-inlines">
      <xsl:variable name="markup">
         <xsl:apply-templates select="$tag-replacements/m:rules">
            <xsl:with-param name="original" tunnel="yes" as="text()" select="."/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:try select="parse-xml-fragment($markup)">
         <xsl:catch select="."/>
      </xsl:try>
   </xsl:template>
   <xsl:template mode="cast-ns" match="*">
      <xsl:element name="{local-name()}" namespace="{ $target-ns }">
         <xsl:copy-of select="@*[matches(.,'\S')]"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="m:rules" as="xs:string"><!-- Original is only provided for processing text nodes -->
      <xsl:param name="original" as="text()?" tunnel="yes"/>
      <xsl:param name="starting" as="xs:string" select="string($original)"/>
      <xsl:iterate select="*">
         <xsl:param name="original" select="$original" as="text()?"/>
         <xsl:param name="str" select="$starting" as="xs:string"/>
         <xsl:on-completion select="$str"/>
         <xsl:next-iteration>
            <xsl:with-param name="str">
               <xsl:apply-templates select=".">
                  <xsl:with-param name="str" select="$str"/>
               </xsl:apply-templates>
            </xsl:with-param>
         </xsl:next-iteration>
      </xsl:iterate>
   </xsl:template>
   <xsl:template match="m:replace" expand-text="true">
      <xsl:param name="str" as="xs:string"/>
      <!--<xsl:value-of>replace({$str},{@match},{string(.)})</xsl:value-of>-->
      <xsl:sequence select="replace($str, @match, string(.))"/>
      <!--<xsl:copy-of select="."/>-->
   </xsl:template>
   <xsl:variable xmlns="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                 name="tag-replacements">
      <rules><!-- first, literal replacements -->
         <replace match="&amp;">&amp;amp;</replace>
         <replace match="&lt;">&amp;lt;</replace>
         <!-- next, explicit escape sequences -->
         <replace match="\\&#34;">&amp;quot;</replace>
         <replace match="\\'">&amp;apos;</replace>
         <replace match="\\\*">&amp;#2A;</replace>
         <replace match="\\`">&amp;#60;</replace>
         <replace match="\\~">&amp;#7E;</replace>
         <replace match="\\^">&amp;#5E;</replace>
         <!-- then, replacements based on $tag-specification -->
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
   <xsl:variable xmlns="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                 name="tag-specification"
                 as="element(m:tag-spec)">
      <tag-spec><!-- The XML notation represents the substitution by showing both delimiters and tags  --><!-- Note that text contents are regex notation for matching so * must be \* -->
         <q>"<text/>"</q>
         <img alt="!\[{{$text}}\]" src="\({{$text}}\)"/>
         <insert param-id="\{{{{$nws}}\}}"/>
         <a href="\[{{$text}}\]">\(<text/>\)</a>
         <code>`<text/>`</code>
         <strong>
            <em>\*\*\*<text/>\*\*\*</em>
         </strong>
         <strong>\*\*<text/>\*\*</strong>
         <em>\*<text/>\*</em>
         <sub>~<text/>~</sub>
         <sup>\^<text/>\^</sup>
      </tag-spec>
   </xsl:variable>
   <xsl:template match="*" mode="write-replace"><!-- we can write an open/close pair even for an empty element b/c
             it will be parsed and serialized -->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="local-name()"/>
      <!-- coercing the order to ensure correct formation of regegex       -->
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
   <xsl:template match="@*[matches(., '\{\$text\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$text\}', '(.*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$nws\}')]" mode="write-match"><!--<xsl:value-of select="."/>--><!--<xsl:value-of select="replace(., '\{\$nws\}', '(\S*)?')"/>-->
      <xsl:value-of select="replace(., '\{\$nws\}', '\\s*(\\S+)?\\s*')"/>
   </xsl:template>
   <xsl:template match="m:text" mode="write-replace">
      <xsl:text>$1</xsl:text>
   </xsl:template>
   <xsl:template match="m:insert/@param-id" mode="write-replace">
      <xsl:text> param-id='$1'</xsl:text>
   </xsl:template>
   <xsl:template match="m:a/@href" mode="write-replace">
      <xsl:text> href='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:img/@alt" mode="write-replace">
      <xsl:text> alt='$1'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:img/@src" mode="write-replace">
      <xsl:text> src='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:text" mode="write-match">
      <xsl:text>(.*?)</xsl:text>
   </xsl:template>
   <xsl:variable name="line-example" xml:space="preserve"> { insertion } </xsl:variable>
</xsl:stylesheet>
