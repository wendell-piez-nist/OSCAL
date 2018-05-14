<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  type="oscal:sp800-53-rev4-extraction" name="sp800-53-rev4-extraction">
  
  
  <p:input port="source" primary="true">
    <p:document href="../../sources/800-53/rev4/800-53-controls.xml"/>
  </p:input>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="_0_input" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>
  <p:output port="_A_corrected" primary="false">
    <p:pipe port="result" step="corrected"/>
  </p:output>
  <p:output port="_B_converted" primary="false">
    <p:pipe port="result" step="converted"/>
  </p:output>
  <p:output port="_C_assessed" primary="false">
    <p:pipe port="result" step="assessed"/>
  </p:output>
  <p:output port="_D_improved" primary="false">
    <p:pipe port="result" step="improved"/>
  </p:output>
  <p:output port="_E_reduced" primary="false">
    <p:pipe port="result" step="reduced"/>
  </p:output>
  <p:output port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>
  <p:output port="analysis" primary="false">
    <p:pipe port="result" step="analysis"/>
  </p:output>
  
  
  <p:serialization port="analysis"     indent="true"/>
  <p:serialization port="final"        indent="true"/>
  
  <p:serialization port="_0_input"     indent="true"/>
  <p:serialization port="_A_corrected" indent="true"/>
  <p:serialization port="_B_converted" indent="true"/>
  <p:serialization port="_C_assessed"  indent="true"/>
  <p:serialization port="_D_improved"  indent="true"/>
  <p:serialization port="_E_reduced"   indent="true"/>
  
  <p:identity name="input"/>

  <!--<p:identity name="corrected"/>-->
  <p:xslt name="corrected">
    <p:input port="stylesheet">
      <p:document href="SP800-53-corrections.xsl"/>
    </p:input>
  </p:xslt>

  <!--<p:identity name="converted"/>-->
  <p:xslt name="converted">
    <p:input port="stylesheet">
      <p:document href="SP800-53-convert-to-oscal.xsl"/>
    </p:input>
  </p:xslt>
  
  
  <!--<p:identity name="enhanced"/>-->
  <p:xslt name="assessed">
    <p:input port="stylesheet">
      <p:document href="SP800-53-param-detect.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="tuned"/>-->
  <p:xslt name="improved">
    <p:input port="stylesheet">
      <p:document href="SP800-53-params-and-ids.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="reduced">
    <p:input port="stylesheet">
      <p:document href="SP800-53-reduce.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="final">
    <p:with-param name="xslt-process" select="'SP800-53 OSCAL EXTRACTION'"/>
    <p:input port="stylesheet">
      <p:document href="../lib/XSLT/OSCAL-finalize.xsl"/>
    </p:input>
    <!--<p:input port="parameters" kind="parameter"/>-->
      
  </p:xslt>
  
  <p:identity name="analysis">
    <p:input port="source">
      <p:pipe port="result" step="final"/>
    </p:input>
  </p:identity>
  
  <p:for-each name="baseline">
    <p:iteration-source select="*/*">
      <p:inline>
        <oscal:schema-set>
          <oscal:LOW/>
          <oscal:MODERATE/>
          <oscal:HIGH/>
        </oscal:schema-set>
      </p:inline>
    </p:iteration-source>
    
    <p:identity name="baseline-name"/>
    
    <p:group>
      <p:variable name="baseline" select="local-name(/*)">
        <p:pipe step="baseline-name" port="result"/>
      </p:variable>
      
      <p:variable name="baseline-resultfile" select=" 'baselines/SP800-53-rev4-' || $baseline || '-baseline.xml' "/>
      
      <p:xslt name="baseline-pull">
        <p:input port="source">
          <p:pipe port="result" step="improved"/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="SP800-53-profile-with-filter.xsl"/>
        </p:input>
        <p:with-param name="baseline" select="$baseline"/>
      </p:xslt>
      
      <p:store method="xml" indent="true">
        <p:with-option name="href" select="$baseline-resultfile"/>
      </p:store>
    </p:group>
    
  </p:for-each>
  
  
</p:declare-step>