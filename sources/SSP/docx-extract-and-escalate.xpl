<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xsw="http://coko.foundation/xsweet"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  type="oscal:docx-extract-and-escalate" name="docx-extract-and-escalate">
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:option name="docx-file-uri" required="true"/>
  
  <p:output port="_Z_FINAL">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:output port="_X_CRUNCHED" primary="false">
    <p:pipe port="result" step="crunched"/>
  </p:output>
  
  <p:output port="_A_in" primary="false">
    <p:pipe port="_Z_FINAL" step="document-production"/>
  </p:output>

  
  <p:serialization port="_A_in"                indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_Z_FINAL"             indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_X_CRUNCHED"          indent="true" omit-xml-declaration="true"/>
  
  <p:import href="../../../XSweet/XSweet-master/applications/docx-extract/docx-document-production.xpl"/>
  
  <p:variable name="document-path" select="concat('jar:',$docx-file-uri,'!/word/document.xml')"/>
  <!--<p:variable name="document-xml"  select="doc($document-path)"/>-->
  <!-- Validate HTML5 results here:  http://validator.w3.org/nu/ -->

  <p:load>
    <p:with-option name="href" select="$document-path"/>
  </p:load>
  
  <xsw:docx-document-production name="document-production"/>
  
  <p:xslt name="with-headers">
    <p:input port="stylesheet">
      <p:document href="../../../XSweet/HTMLevator-master/applications/header-promote/outline-headers.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="with-structure">
    <p:input port="stylesheet">
      <p:document href="../../../XSweet/HTMLevator-master/applications/induce-sections/induce-sections.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="remediated">
    <p:input port="stylesheet">
      <p:document href="xsweet-spiffup.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
  
  <p:xslt name="crunched">
    <p:input port="stylesheet">
      <p:document href="ssp-crunch.xsl"/>
    </p:input>
  </p:xslt>
  
  
  <!--<p:xslt name="stuff">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="3.0"
          xmlns="http://www.w3.org/1999/xhtml"
          xpath-default-namespace="http://www.w3.org/1999/xhtml"
          exclude-result-prefixes="#all">
          
          <xsl:mode on-no-match="shallow-copy"/>
          
          
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  -->
  
  
</p:declare-step>