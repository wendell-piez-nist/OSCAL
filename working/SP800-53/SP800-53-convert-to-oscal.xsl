<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   version="2.0"
  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:feed="http://scap.nist.gov/schema/sp800-53/feed/2.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xlink="https://www.w3.org/TR/xlink/"
  xmlns:java="java:java.util.UUID"
  xpath-default-namespace="http://scap.nist.gov/schema/sp800-53/2.0"
  xmlns="http://csrc.nist.gov/ns/oscal/1.0"
   exclude-result-prefixes="#all"
   
   xmlns:oscal="http://www.example.com/fn">

  <xsl:strip-space elements="feed:controls feed:control description html:div html:ol supplemental-guidance references control-enhancements control-enhancement objectives objective decisions decision potential-assessments potential-assessment withdrawn statement"/>


  <xsl:output indent="yes"/>
  
  <xsl:variable name="source" select="/"/>
  
  <xsl:template match="feed:controls">
    <!--id="NIST_SP-800-53_rev4_catalog.{ format-date(current-date(),'[Y][M01][D01]') }"-->
    <catalog id="uuid-{java:random-UUID()}" model-version="0.9.11">
      <!-- for now, 0.9.11 b/c Sprint 11 -->
      <title>NIST SP800-53</title>
      <declarations href="NIST_SP-800-53_rev4_declarations.xml"/>

      <xsl:for-each-group select="feed:control" group-by="family">
        <!-- ID is the upper case letters from the first control's number -->
        <xsl:variable name="label-id" select="replace(current-group()[1]/number,'\P{Lu}','') ! lower-case(.)"/>
        <group class="family" label-id="{ $label-id }">
          <title><xsl:value-of select="current-grouping-key()"/></title>
          <xsl:apply-templates select="current-group()"/>
        </group>
      </xsl:for-each-group>
    </catalog>
  </xsl:template>
  
  <xsl:template match="feed:control">
    <control class="SP800-53">
      <xsl:attribute name="label-id">
        <xsl:apply-templates select="number" mode="label-as-id"/>
      </xsl:attribute>
      
      
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="* except (title | references)"/>
      <xsl:apply-templates select="control-enhancements/control-enhancement"/>
      <xsl:apply-templates select="references"/>    
    </control>
  </xsl:template>
  

  

  <xsl:variable name="brace" as="xs:string">[\p{Ps}\p{Pe}]</xsl:variable>
  
  <xsl:template match="feed:control/number | control-enhancement/number" mode="label-as-id" as="xs:string">
    <xsl:value-of
      select="oscal:parens-to-dots(.) ! lower-case(.)"/>
  </xsl:template>
  
<!-- Only inside controls do statements get numbers; in subcontrols (enhancements) they are unnumbered blocks -->
  <xsl:function name="oscal:parens-to-dots">
    <xsl:param name="what"/>
    <xsl:value-of select="replace($what, '\(', '.') ! replace(., '\)', '') ! replace(.,'\.$','')"/>
  </xsl:function>
  
  <xsl:template match="statement/number" mode="label-as-id" as="xs:string">
    <xsl:variable name="control-label" select="if (exists(ancestor::control-enhancement)) then ancestor::control-enhancement/number else ancestor::feed:control/number"/>
    
<!-- the local part removes the control label, parentheses, and strips a final period   -->
    <xsl:variable name="local-part" select="substring-after(.,$control-label) ! oscal:parens-to-dots(.)"/>
    <xsl:value-of select="oscal:parens-to-dots($control-label) ! lower-case(.) || '_smt.' || $local-part"/>
  </xsl:template>
  
  
  <xsl:template match="objective/number" mode="label-as-id" as="xs:string">
    <xsl:variable name="on">
      <xsl:analyze-string select="." regex="\[[\da-z]+\]">
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:variable name="as">
      <xsl:text>_obj</xsl:text>
      <xsl:analyze-string select="." regex="\[[\da-z]+\]">
        <xsl:matching-substring>
          <xsl:value-of select="."/>
        </xsl:matching-substring>
      </xsl:analyze-string>
      
    </xsl:variable>
    <xsl:variable name="on-part" select="replace(lower-case($on), '\(', '.') ! replace(., '\)', '')"/>
    <xsl:variable name="as-part" select="replace(lower-case($as), '\[', '.') ! replace(., '\]', '')"/>
    
    <xsl:value-of select="$on-part || $as-part"/>
    <!--<xsl:value-of
      select="replace(number, '[\-\(]', '.') ! replace(., '\)', '.') ! lower-case(.)"/>-->
  </xsl:template>
  
  <xsl:template match="*" mode="label-as-id">
    <xsl:message>ID without number? for <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>
  
  <!--suppressed in default traversal-->
  <xsl:template match="control-enhancements"/>
  
    
  <xsl:template match="title">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  
  <!-- Accounted for by 'div' grouping. -->
  <xsl:template match="family"/>
  
  <xsl:template match="control-class">
    <prop class="{name()}">
      <xsl:apply-templates/>
    </prop>
  </xsl:template>
  
<!--  <xsl:template match="family">
    <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
  </xsl:template>
-->  


  <!-- The number coming out of the NVD XML is preserved until id's are assigned - truncated
       in a later step. But whitespace has to be stripped to normalize. -->
  
  <xsl:template match="number">
    <prop class="label">
      <xsl:value-of select="replace(.,'\s','')"/>
    </prop>
  </xsl:template>
  
  <xsl:template match="descriptions | decisions">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="references">
    <references>
      <!--<xsl:apply-templates select="." mode="group-label"/>-->
      <xsl:apply-templates/>
    </references>
  </xsl:template>
  
  <xsl:template match="control-enhancement">
    <subcontrol class="SP800-53-enhancement">
      <xsl:attribute name="label-id">
         <xsl:apply-templates select="number" mode="label-as-id"/>
      </xsl:attribute>
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="@* except @sequence" mode="asElement"/>
      <xsl:apply-templates select="* except title"/>
    </subcontrol>
  </xsl:template>
  
  <xsl:template match="statement">
    <part class="statement">
      <xsl:attribute name="label-id">
        <xsl:apply-templates select="number" mode="label-as-id"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="asElement"/>
      <xsl:apply-templates/>
    </part>
  </xsl:template>
  
  <xsl:template match="feed:control/statement | control-enhancement/statement">
    <part class="statement">
      <xsl:attribute name="label-id" >
        <xsl:apply-templates select="../number" mode="label-as-id"/>
        <xsl:text>_smt</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="asElement"/>
      <xsl:apply-templates/>
    </part>
  </xsl:template>
  
  <!--<xsl:template match="statement/statement" priority="2">
    <part class="item">
      <xsl:apply-templates select="number" mode="label-as-id"/>
      <xsl:apply-templates select="@*" mode="asElement"/>
      <xsl:apply-templates/>
    </part>
  </xsl:template>
  
  <xsl:template match="statement/statement/statement" priority="3">
    <part class="item">
      <xsl:apply-templates select="number" mode="label-as-id"/>
      <xsl:apply-templates select="@*" mode="asElement"/>
      <xsl:apply-templates/>
    </part>
  </xsl:template>-->
  
  <xsl:template match="statement/description">
      <p>
        <xsl:apply-templates select="@*" mode="asElement"/>
        <xsl:apply-templates/>
      </p>
  </xsl:template>
  
  <xsl:template match="related">
    <link rel="related" href="#{normalize-space(.)}">
      <xsl:apply-templates/>
    </link>
  </xsl:template>
  
  <xsl:template match="description">
      <p>
        <xsl:apply-templates/>
      </p>
  </xsl:template>
  
  <!-- In latest sp80053a, objective is recursive,
       resulting in nested part//part -->
  
  <xsl:template match="appendixA">
    <xsl:apply-templates select="objective | potential-assessments/potential-assessment"/>
  </xsl:template>
  
  
  <xsl:template match="objective">
    <part class="objective">
      <xsl:attribute name="label-id">
        <xsl:apply-templates select="number" mode="label-as-id"/>
      </xsl:attribute>
      <!--<xsl:for-each select="number[@as|@on]">
        <xsl:variable name="compound-value" select="string-join((@on,@as),'_')"/>
        <xsl:attribute name="new-id">
          <xsl:apply-templates select="." mode="label-as-id"/>
        </xsl:attribute>
      </xsl:for-each>-->
      <xsl:variable name="target-label">
        <xsl:analyze-string select="string(number)" regex="\[[\da-z]+\]">
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:variable name="parent-label">
        <xsl:analyze-string select="string(../number)" regex="\[[\da-z]+\]">
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:variable name="target-as" select="replace($target-label, '\)', '.') ! replace(., '\(', '')"/>
      <xsl:variable name="parent-as" select="replace($parent-label, '\)', '.') ! replace(., '\(', '')"/>
      
      <!--<link><xsl:value-of select="$target-as"/></link>-->
      
      <xsl:apply-templates select="@*" mode="asElement"/>
      
      <xsl:apply-templates/>
      
      <xsl:if test="not($target-as = $parent-as)">
        <xsl:apply-templates mode="corresp-link" select="key('statement-by-number',$target-as)"/>
      </xsl:if>
    </part>
  </xsl:template>
  
  <xsl:key name="statement-by-number" match="statement" use="number"/>
  
  <xsl:template match="*" mode="corresp-link">
    <link rel="corresp">
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="number" mode="label-as-id"/>
      </xsl:attribute>
      <xsl:value-of select="number"/>
    </link>
  </xsl:template>
  
  <xsl:template match="supplemental-guidance">
    <part class="guidance">
      <xsl:attribute name="label-id">
        <xsl:apply-templates select="../number" mode="label-as-id"/>
        <xsl:text>_gdn</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="asElement"/>
      <xsl:apply-templates/>
    </part>
  </xsl:template>
  
  <xsl:template match="decision">
    <p>
        <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="@*" mode="asElement">
    <prop class="{name()}"><xsl:value-of select="."/></prop>
  </xsl:template>
  
  <xsl:template match="@sequence" mode="asElement"/>
  
  <xsl:template match="potential-assessment">
    <part class="assessment">
      <xsl:apply-templates select="@* except @sequence" mode="asElement"/>
      <xsl:for-each-group select="object" group-by="true()">
        <part class="objects">
          <xsl:apply-templates select="current-group()"/>
        </part>
      </xsl:for-each-group>
    </part>
  </xsl:template>
  
  <xsl:template match="object">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
<!-- Keeping these to be removed by a subsequent step.
     Keeping them here exposes them to queries for analysis before we scrub em out. :-) -->
  <xsl:template match="priority | baseline-impact">
    <prop class="{name()}">
      <xsl:apply-templates/>
    </prop>  
  </xsl:template>

  <xsl:template match="reference">
    <ref>
       <xsl:apply-templates/>
    </ref>
  </xsl:template>
  
  <xsl:template match="item">
    <citation>
      <!-- NISO STS -->
      <xsl:apply-templates select="@href"/>
      <!--<xsl:comment> or STS &lt;std> ... </xsl:comment>-->
      <xsl:apply-templates/>
    </citation>
  </xsl:template>
  
  <xsl:template match="@href">
    <xsl:attribute name="href">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="html:div">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="html:div[exists(child::text()[matches(.,'\S')])]">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  

  <xsl:template match="withdrawn">
    <prop class="status">Withdrawn</prop>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="incorporated-into">
    <link rel="incorporated-into" href="#{normalize-space(.)}">
      <xsl:apply-templates/>
    </link>
  </xsl:template>
  
  <xsl:template match="html:p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <!--<xsl:template match="html:ol">
    <list list-type="ordered">
      <xsl:apply-templates/>
    </list>
  </xsl:template>
  
  
  <xsl:template match="html:li">
    <list-item>
      <p>
        <!-\-<xsl:copy-of select="@class"/>-\->
        <xsl:apply-templates select="node() except html:ol"/>
      </p>
      <!-\- safe since in the input, nested html lists are always at the ends of their items. -\->
      <xsl:apply-templates select="html:ol"/>
    </list-item>
  </xsl:template>

  <!-\- Sorry ... -\->
  <xsl:template match="html:em">
    <italic>
      <xsl:apply-templates/>
    </italic>
  </xsl:template>-->
  
  <xsl:template match="html:*">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:message terminate="no">
      <xsl:value-of select="name()"/>
      <xsl:text> NOT MATCHED </xsl:text>
    </xsl:message>
    <xsl:next-match/>
  </xsl:template>
  
</xsl:stylesheet>