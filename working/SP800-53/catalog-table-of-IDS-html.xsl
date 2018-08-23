<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  exclude-result-prefixes="oscal">
  
  
<!-- Notes:
  Objective AC-1_obj-1.a aligns with with statement AC-1_stm-1.a
    for every statement there should be a corresponding objective (with descendants?)
  -->
  <xsl:template match="/">
    <html>
      <head>
        <title>
        <xsl:value-of select="descendant::oscal:title[1]"/>
        </title>
        <xsl:copy-of select="$script"/>
        <style type="text/css">
          <!-- Permits easier overlaying -->
           <xsl:copy-of select="$css"/>
        </style>
      </head>
      <xsl:apply-templates/>
    </html>
  </xsl:template>
  
  <xsl:template match="oscal:references"/>
  
  <xsl:template match="oscal:catalog | oscal:collection">
    <body class="{local-name(/*)}">
      <xsl:apply-templates/>
    </body>
  </xsl:template>
  
  <xsl:template match="oscal:title">
    <h2 class="title">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  <xsl:template match="oscal:title" mode="inline">
    <em class="title">
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  
<xsl:variable name="script">
  <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript"><![CDATA[

function flashClass(ilk, flag) {
    var flashers = document.getElementsByClassName(ilk);
    //[for (flasher of flashers) flasher.classList.toggle(flag) ];
    //flashers.forEach(element.classList.toggle(flag));
    var i;
    for (i = 0; i < flashers.length; i++) {
        flashers[i].classList.toggle(flag);
    }
}
]]>
  </script>
</xsl:variable>
  
  <xsl:variable name="css">
    body { font-size: small }
    
    section { margin: 0.25em 0.25em 0.25em 1em; padding: 0.25em 0.25em 0.25em 1em; 
      border: thin dotted black }
    
    section * { margin-top: 0em; margin-bottom: 0em }
    
h2 { font-size: 100%; font-weight: normal }
em.title { font-weight: bold }

.OFF { display: none }

.alert, .report { display: inline-block; border: thin dotted black;
  margin: 0.5em; }

  </xsl:variable>
  

  <xsl:template match="oscal:declarations"/>
    
  
  <xsl:template match="oscal:group | oscal:control | oscal:subcontrol | oscal:part">
    <xsl:variable name="off">
      <xsl:if test="ancestor::oscal:group"> OFF</xsl:if>
    </xsl:variable>
    <section id="{generate-id()}" class="{local-name()} childOf{generate-id(..)}{$off}">
      <h2 onclick="javascript:flashClass('childOf{generate-id()}','OFF')">[<xsl:value-of select="local-name()"/>] <xsl:value-of select="@class"/> : <xsl:apply-templates select="oscal:title" mode="inline"/></h2>
      <xsl:apply-templates select="." mode="id-report"/>
      <xsl:apply-templates select="." mode="alerts"/>
      
      <xsl:apply-templates select="oscal:group | oscal:control | oscal:subcontrol | oscal:part"/>
    </section>
  </xsl:template>
  
  <xsl:template match="@id" mode="id-report">
    <p class="report">@id (explicit 'id' attribute): <xsl:value-of select="."/></p>  
  </xsl:template>

  <xsl:template match="*" mode="id-report" name="base-report">
    <xsl:variable name="implicit-number">
      <xsl:number count="oscal:group|oscal:control|oscal:subcontrol|oscal:part" level="multiple"/>
    </xsl:variable>
    <p class="report">implicit number: <xsl:value-of select="$implicit-number"/></p>
    <xsl:for-each select="oscal:prop[@class='label'] | oscal:prop[@class='name']">
      <p class="report"><xsl:value-of select="@class"/>: <xsl:value-of select="."/></p>
      <p class="report">names-and-labels:
        <xsl:for-each select="ancestor-or-self::*/oscal:prop[@class='label'] |
          ancestor-or-self::*/oscal:prop[@class='name']"><xsl:value-of select="."/></xsl:for-each>
      </p>
    </xsl:for-each>
    <xsl:apply-templates select="@id" mode="id-report"/>
    <xsl:if test="not(@id)">
      <p class="alert">Data gives no @id</p>
    </xsl:if>
  </xsl:template>    
  
  
  <xsl:template match="*" mode="alerts">
    
  </xsl:template>    
  
  
</xsl:stylesheet>