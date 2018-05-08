<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  
  xmlns="http://csrc.nist.gov/ns/oscal/1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
  exclude-result-prefixes="#all">

  <xsl:strip-space elements="group control subcontrol part section component"/>
  
  <xsl:output indent="yes"/>

  <xsl:mode name="#default"      on-no-match="shallow-copy"/>
  
  <xsl:mode name="oscal:resolve" on-no-match="shallow-copy"/>
  
  <xsl:mode name="copy"          on-no-match="shallow-copy"/>
  
  <xsl:mode name="import"        on-no-match="shallow-copy"/>
  
  <!-- 'filter-merge' mode post-processes merged results to remove duplicated data -->
  <xsl:mode name="filter-merge" on-no-match="shallow-copy"/>
  
  <!-- Extension point for merge-time enhancement here recording import provenance (otherwise lost in merge) -->
  <xsl:mode name="merge-enhance" on-no-match="shallow-copy"/>
  
  <xsl:mode name="patch"         on-no-match="shallow-copy"/>
  
  
<!-- Presumes new model (import*, merge? modify)
  1. Test import* across multiple deep imports
  2. Refine aggregation w/o merge logic
  3. Install / test merge logic
  4. Reimplement modify logic
  -->
  
  <!-- Frameworks and catalogs are resolved as themselves (for now). -->
  <xsl:template match="catalog | framework | worksheet" mode="oscal:resolve #default">
    <xsl:apply-templates select="." mode="copy"/>
  </xsl:template>
  
  <!-- Profiles, however, must be executed ... -->
  <xsl:template match="profile" mode="oscal:resolve #default">
    <!-- each child of profile indicates a filter:
      import: adds a new selection of controls
      merge: merges replicated catalog structures
      modify: propagates changes and parameter values -->
      
      <xsl:iterate select="*">
        <!-- $so-far starts with only a flag -->
        <xsl:param name="so-far">
          <resolution profile="{document-uri(/)}"/>
        </xsl:param>
        <xsl:on-completion select="$so-far"/>
        <xsl:next-iteration>
          <xsl:with-param name="so-far">
            <!-- now process the import, merge or modify as a proxy -->
            <xsl:apply-templates select="." mode="process-profile">
              <xsl:with-param name="so-far" select="$so-far"/>
            </xsl:apply-templates>
          </xsl:with-param>
        </xsl:next-iteration>
      </xsl:iterate>
  </xsl:template>
  
<!-- 'process-profile' mode drives the application of semantics of
      profile element children 'import', 'merge' and 'modify' -->
  
<!-- import: adds control set by (recursively) calling profiles/catalogs -->
  
  <xsl:template match="import" mode="process-profile">
    <xsl:param name="so-far" as="document-node()"/>
    <xsl:variable name="imported">
      <!-- Returns the imported profile or catalog, including only the designated controls. It will be a 'resolution' element or an ERROR.-->
      <xsl:apply-templates select="." mode="import"/>
    </xsl:variable>
    <!-- Returning $so-far, except with the imported / filtered catalog spliced in -->
    <xsl:for-each select="$so-far/*">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="node()"/>
        <xsl:sequence select="$imported"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:apply-templates select="." mode="echo"/>
  </xsl:template>
  
  <xsl:template match="*" mode="process-profile">
    <xsl:param name="so-far"/>
    <xsl:apply-templates select="." mode="echo"/>
    <xsl:sequence select="$so-far"/>
  </xsl:template>
  
  <!-- Mode 'import' manages importing controls from catalogs or upstream profiles -->
  <xsl:template match="import" mode="import oscal:resolve">
    <xsl:param name="authorities-so-far" tunnel="yes" select="document-uri(/)" as="xs:anyURI+"/>
    
    
    <!--<xsl:param name="invocation" tunnel="yes" select="."/>-->
    <xsl:variable name="invocation" select="."/>
    
    
    <!-- $authority will be a catalog, framework or profile. -->
    <xsl:variable name="authority"    select="document(@href,root(.))"/>
    <!-- $authorityURI is a full path not whatever relative form was used -->
    <xsl:variable name="authorityURI" select="document-uri($authority)"/>
    
    <importing>
      <xsl:attribute name="href" select="resolve-uri(@href,document-uri(/))"/>

      <xsl:choose>
        <xsl:when test="$authorityURI = $authorities-so-far" expand-text="true">
          <ERROR>Can't resolve profile against {$authorityURI}, already imported in this chain:
            {string-join($authorities-so-far,' / ')}</ERROR>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="report-invocation"/>
          
          <!--    first we process ourselves with our own rules, returning a catalog, worksheet or (if a profile), a resolution. -->
          <!-- then we filter the resolution using the new import -->
          <xsl:variable name="interim">
            <xsl:apply-templates select="$authority" mode="oscal:resolve"/>
          </xsl:variable>
          <!-- Next we apply templates in mode 'import', passing ourselves in as the invocation -->
          <xsl:apply-templates select="$interim" mode="import">
            <xsl:with-param name="invocation" tunnel="yes" select="."/>
            <xsl:with-param name="authorities-so-far" tunnel="yes" as="xs:anyURI+"
              select="$authorities-so-far, $authorityURI"/>
          </xsl:apply-templates>
          <!--<xsl:copy-of  select="$interim"/>-->
        </xsl:otherwise>
      </xsl:choose>
    </importing>
  </xsl:template>
  
  <xsl:template match="import" mode="report-invocation">
    <xsl:variable name="invocation" select="."/>
    <!-- $authority will be a catalog, framework or profile. -->
    <xsl:variable name="authority" select="document(@href,root(.))"/>
    <xsl:comment expand-text="true"> importing { $authority/*/local-name() }</xsl:comment>
    <!--<xsl:copy-of select="*"/>-->
  </xsl:template>
  
  <xsl:template match="catalog | framework | worksheet | resolution" mode="import">
    <xsl:variable name="filtered-results">
      <xsl:apply-templates select="*" mode="#current"/>
    </xsl:variable>
    <xsl:if test="exists($filtered-results/*)">
        <xsl:sequence select="$filtered-results"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="profile" mode="import">
    <xsl:message terminate="yes">Bah! matched profile unexpectedly</xsl:message>
  </xsl:template>
  
  <xsl:template match="section" mode="import"/>
  
  <xsl:template match="group" mode="import">
    <xsl:apply-templates select="group | control | component" mode="#current"/>
    <!--<xsl:variable name="included">
      <xsl:apply-templates select="group | control | component" mode="#current"/>
    </xsl:variable>
    <!-\- If the group contains nothing to be included, it isn't included either -\->
    <xsl:if test="exists($included/*)">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:attribute name="process-id" select="generate-id()"/>
        <xsl:apply-templates select="title" mode="#current"/>
        <xsl:sequence select="$included"/>
      </xsl:copy>  
    </xsl:if>-->
  </xsl:template>
  
  <!--<xsl:template match="catalog/title | framework/title | worksheet/title | profile/title | group/title" mode="filter-controls">
    <xsl:param name="invocation" tunnel="yes" as="element(import)" required="yes"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
      <xsl:text> [included in </xsl:text>
      <xsl:apply-templates select="$invocation/ancestor::profile[1]/title"/>
      <xsl:text>]</xsl:text>
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:function name="oscal:matched" as="xs:boolean">
    <!-- $comp should be a control, subcontrol or component -->
    <xsl:param name="comp" as="element()"/>
    <!-- $imp will be an import element -->
    <xsl:param name="invocation" as="element()"/>
    <xsl:variable name="included" as="xs:boolean" select="exists($invocation/include/all) or empty($invocation/include)"/>
    <xsl:variable name="matched" select="some $re in ($invocation/include/match/@pattern ! ('^' || . || '$') ) satisfies (matches($comp/@id,$re))"/>
    <xsl:variable name="parent-control" select="$comp/(parent::control | parent::comp[oscal:classes(.)='control'] )"/>
    <xsl:variable name="subcontrol-matched" select="some $re in ($invocation/include/match[@with-subcontrols='yes']/@pattern ! ('^' || . || '$') ) satisfies (matches($parent-control/@id,$re))"/>
    <!--<xsl:variable name="control-implied" select="some $re in ($invocation/include/match[@with-control='yes']/@pattern ! ('^' || . || '$') ) satisfies (matches($comp/subcontrol/@id,$re))"/>-->
    
    <xsl:variable name="unmatched" select="some $re in ($invocation/exclude/match/@pattern ! ('^' || . || '$') ) satisfies (matches($comp/@id,$re))"/>
    
    <xsl:sequence select="($included or $matched or $subcontrol-matched) and not($unmatched)"/>
  </xsl:function>
  
  <xsl:template match="control | component[oscal:classes(.)='control']" priority="3" mode="import">
    <!--A control or subcontrol is always excluded if it appears in import/exclude
    Otherwise, it is included if empty(import/include), exists(import/all)
    or exists(import/call[(@control-id | @subcontrol-id)=current()/@id]-->
    <xsl:param name="invocation" tunnel="yes" as="element(import)" required="yes"/>
    <!-- A control is included by 'all' or by default when no inclusion rule is given -->
    <xsl:variable name="included" as="xs:boolean" select="exists($invocation/include/all) or empty($invocation/include)"/>
    <xsl:variable name="excluded" as="xs:boolean" select="$invocation/exclude/call/@control-id = @id"/>
    <xsl:variable name="called"   as="xs:boolean" select="$invocation/include/call/@control-id = @id"/>
    <!--<xsl:copy-of select="$invocation"/>-->
    <xsl:if test="($included or oscal:matched(.,$invocation) or $called) and not($excluded)">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <!--<xsl:comment expand-text="true"> invoked by { $invocation/../title } { document-uri($invocation/root()) }</xsl:comment>-->
        <!--<xsl:apply-templates mode="#current" select="* except (subcontrol | component[oscal:classes(.)='subcontrol'])"/>-->
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:if>
    <!--<xsl:apply-templates mode="#current" select="subcontrol | component[oscal:classes(.)='subcontrol']"/>-->
  </xsl:template>
  
  <xsl:template match="subcontrol | component[oscal:classes(.)='subcontrol']" priority="2" mode="import">
    <!-- Subcontrol logic is analogous to control logic for keeping.
      Extend this with (parameterized) defaults for handling subcontrols. -->
    <xsl:param name="invocation" tunnel="yes" as="element(import)" required="yes"/>
    <!-- A subcontrol is included if all explicitly says to include all subcontrols, or
         if its containing controls is called and set @with-subcontrols -->
    <xsl:variable name="control" select="ancestor::control[1]"/>
    <xsl:variable name="included" select="(: include if with-subcontrols is on 'all'
      or on a corresponding 'call' :) 
      ($invocation/include/all/@with-subcontrols='yes') or
      ($invocation/include/call[@control-id  = $control/@id]/@with-subcontrols='yes')
      "/>
    <!-- Or it can be called on its own (no matter other settings) -->
    <xsl:variable name="called"   select="exists($invocation/include/call[@subcontrol-id  = current()/@id])"/>
    <!-- The subcontrol can still be excluded -->
    <xsl:variable name="excluded" select="exists($invocation/exclude/call[@subcontrol-id  = current()/@id])"/>
    
    <xsl:if test="($included or oscal:matched(.,$invocation) or $called) and not($excluded)">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="processing-instruction()" mode="import"/>



  <!-- Default merge behavior:
         collapses duplicates where possible
         inserts subcontrols into their controls (if warranted by ... what?)
         flags errors for
           controls in conflict (or are there collapsing rules)
           orphan subcontrols remaining -->
  
  
  
  <xsl:template match="merge" mode="process-profile">
    <xsl:param name="so-far"/>
    <!--<xsl:sequence select="$so-far"/>-->
    <xsl:variable name="merge-spec" select="."/>
    <xsl:variable name="merged">
      <merged>
        <!-- by default, and when nothing else happens, merge
          will combine multiple imports of the same catalog into a single list.
          So for example if 30 controls from three profiles are included, but
          those three profiles are all calling the same catalog, they will come merged in a single group. (And sorted?) -->
        <xsl:for-each-group select="$so-far//control | $so-far//subcontrol[empty(parent::control)]" group-by="parent::importing/@href">
          <group source="{current-grouping-key()}">
            <xsl:choose>
              <!-- when self::merge/build is given, each group is submitted to a rebuild process in reference to its catalog -->
              <xsl:when test="exists($merge-spec/build)">
                <xsl:apply-templates select="document(current-grouping-key())/*" mode="rebuild">
                  <xsl:with-param name="controls" tunnel="yes" select="current-group()"/>
                </xsl:apply-templates>
              </xsl:when>
              <!-- Other options might include building a new hierarchy. -->
              <xsl:otherwise>
                 <!-- Otherwise we just spill the groups. -->
                <xsl:sequence select="current-group()"/>
              </xsl:otherwise>
            </xsl:choose>
          </group>
        </xsl:for-each-group>
      </merged>
    </xsl:variable>
    <!--<xsl:sequence select="$merged"/>-->
    
    <xsl:for-each select="$so-far/*">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="node()"/>
        <xsl:sequence select="$merged"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:apply-templates select="." mode="echo"/>
    
    
  </xsl:template>
  
  <xsl:mode name="rebuild" on-no-match="shallow-copy"/>
  
  <xsl:template match="comment() | processing-instruction()" mode="rebuild"/>
  
  <xsl:template match="group" mode="rebuild">
    <xsl:param name="controls" tunnel="yes" select="()"/>
    <xsl:if test="$controls/@id = .//control/@id">
      <xsl:copy>
        <xsl:apply-templates mode="rebuild"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
      
  <xsl:template mode="rebuild" match="control">
    <xsl:param name="controls" tunnel="yes" select="()"/>
    <xsl:variable name="here"  select="."/>
    <xsl:if test="@id = $controls/@id">
      <xsl:for-each-group select="$controls[@id=$here/@id]" group-by="true()">
        <control id="{$here/@id}">
          <xsl:if test="exists(current-group()[matches(@class,'\s')])">
            <xsl:attribute name="class" select="distinct-values(current-group()/tokenize(@class,'\s+'))"/>
          </xsl:if>
          <xsl:apply-templates select="current-group()/*" mode="#current"/>
        </control>
      </xsl:for-each-group>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" mode="echo"/>
  
  
    
  
  <!-- Next, matching 'modify' - we pass the 'resolution' document into a filter that
       rewrites parameter values and patches controls, wrt the stipulated modifications. -->

  <xsl:template match="modify" mode="process-profile">
    <xsl:param name="so-far"/>
    <xsl:apply-templates select="$so-far" mode="patch">
      <xsl:with-param name="modifications" tunnel="yes" select="."/>
    </xsl:apply-templates>
    <!--<xsl:apply-templates select="." mode="echo"/>-->
  </xsl:template>
  
  <xsl:template match="control | subcontrol | component" mode="patch">
    <xsl:param name="modifications" tunnel="yes" as="element(modify)" required="yes"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="title" mode="#current"/>
      <xsl:copy-of select="key('alteration-by-target',@id,$modifications)/add[empty(@target)][@position='starting']/*"/>
      
      <xsl:apply-templates select="* except title" mode="#current"/>
      
      <xsl:copy-of select="key('alteration-by-target',@id,$modifications)/add[empty(@target)][@position='ending']/*"/>
      
    </xsl:copy>
  </xsl:template>
  
  <!-- When a catalog is filtered through a profile, its parameters are overwritten
       by parameters passed in from the invocation. -->
  <!-- set-param/desc overrides param/desc -->
  <xsl:template match="param/desc"  mode="patch" priority="10">
    <xsl:param name="modifications" tunnel="yes" as="element(modify)" required="yes"/>

    <xsl:copy-of select="(key('param-settings',parent::param/@id,$modifications)/desc,.)[1]"/>
  </xsl:template>
  
  <!-- set-param/value overrides param/value -->
  <xsl:template match="param/value" mode="patch" priority="10">
    <xsl:param name="modifications" tunnel="yes" as="element(modify)" required="yes"/>
    <xsl:copy-of select="(key('param-settings',parent::param/@id,$modifications)/value,.)[1]"/>
  </xsl:template>
  
  <!-- set-param/hint overrides param/hint, but so does set-param/vsalue. -->
  <xsl:template match="param/hint"  mode="patch" priority="10">
    <xsl:param name="modifications" tunnel="yes" as="element(modify)" required="yes"/>
    <xsl:copy-of select="(key('param-settings',parent::param/@id,$modifications)/value,
      key('param-settings',parent::param/@id,$modifications)/hint, .)[1]"/>
  </xsl:template>
  
  
<!--   -->
  <xsl:function name="oscal:removable" as="xs:boolean">
    <xsl:param name="who" as="node()"/>
    <xsl:param name="mods" as="element(modify)"/>
    <xsl:variable name="home" select="($who/ancestor::control | $who/ancestor::subcontrol | $who/ancestor::component)[last()]"/> 
    <xsl:variable name="alterations" select="key('alteration-by-target',$home/@id,$mods)"/>
    <xsl:variable name="removals" select="$alterations/remove"/>
    
    <xsl:variable name="excluded-by-id" select="$who/@id = $removals/tokenize(@id-ref,'\s+')"/>
    
    <xsl:variable name="excluded-by-class" select="oscal:classes($who) = $removals/tokenize(@class-ref,'\s+')"/>
    <xsl:variable name="excluded-by-proxy" select="some $r in ($removals/*) satisfies 
      ( local-name($r) eq local-name($who) ) and
      ( ($r/@id eq $who/@id) or (oscal:classes($r) = oscal:classes($who) )
        or empty($r/(@class|@id) ) )"/>
    
    <!--<xsl:message expand-text="true">{ count($removals) || ' ... ' || $who/@id || ': ' || $excluded-by-id }</xsl:message>-->
    <xsl:sequence select="$excluded-by-id or $excluded-by-class or $excluded-by-proxy"/>
  </xsl:function>  
  
  <xsl:template match="control//* | subcontrol//* | component//*" mode="patch">
    <xsl:param name="modifications" tunnel="yes" as="element(modify)" required="yes"/>
    <xsl:variable name="here" select="."/>
    <xsl:variable name="home" select="(ancestor::control | ancestor::subcontrol | ancestor::component)[last()]"/> 
    <xsl:variable name="alterations" select="key('alteration-by-target',$home/@id,$modifications)"/>
    <xsl:variable name="patches-to-id" select="$alterations/key('addition-by-target',$here/@id,.)"/>
    <xsl:variable name="patches-to-class" select="$alterations/key('addition-by-target',$here/oscal:classes(.),.)"/>
    
<!-- $patches-before contains 'add' elements marked as patching before this element, either by its @id
      or if bound by its @class, iff it is the first of its class in the containing control
     -->
    <xsl:variable name="patches-before" select="$patches-to-id[@position='before'] |
      $patches-to-class[$here is ($home/descendant::*[oscal:classes(.)=oscal:classes($here)])[1] ][@position='before']"/>
    
    <xsl:copy-of select="$patches-before/*"/>
    <xsl:if test="not(oscal:removable(.,$modifications))">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="#current"/>
        
        <xsl:variable name="patches-starting" select="$patches-to-id[@position='starting'] |
          $patches-to-class[$here is ($home/descendant::*[oscal:classes(.)=oscal:classes($here)])[1] ][@position='starting']"/>
        <xsl:copy-of select="$patches-starting/*"/>
        
        <xsl:apply-templates select="node()" mode="#current"/>
        
        <xsl:variable name="patches-ending" select="$patches-to-id[empty(@position) or @position='ending'] |
          $patches-to-class[$here is ($home/descendant::*[oscal:classes(.)=oscal:classes($here)])[last()] ][empty(@position) or @position='ending']"/>
        <xsl:copy-of select="$patches-ending/*"/>
      </xsl:copy>
    </xsl:if>

<!-- Reverse logic for 'after' patches. Note that elements inside descendant subcontrols or components are excluded from consideration.    -->
      <xsl:variable name="patches-after" select="$patches-to-id[@position='after'] |
        $patches-to-class[$here is ($home/(descendant::*[oscal:classes(.)=oscal:classes($here)]
        except .//(subcontrol|component)/descendant::*[oscal:classes(.)=oscal:classes($here)]) )[last()]
        ][@position='after']"/>
        <xsl:copy-of select="$patches-after/*"/>
        
        
  </xsl:template>
  
  
  <!--<xsl:template match="control/* | subcontrol/* | component/*" mode="patch">
    <xsl:param name="modifications" tunnel="yes" as="element(modify)" required="yes"/>
    <!-\- boolean comes back as true() if a 'remove' element in the invocation matches
         by id of the parent and class of the matching component -\->
    <xsl:variable name="remove_me" select="key('alteration-by-target',../@id,$modifications)/remove/@targets/tokenize(.,'\s+') = oscal:classes(.)"/>
    <xsl:if test="not($remove_me)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>-->
  
  
  <xsl:key name="param-settings" match="oscal:set-param" use="@param-id"/>
  
  <xsl:key name="alteration-by-target" match="alter" use="@control-id | @subcontrol-id"/>
  
<!-- additions (modify/alter/add elements) can be applied using either class value or id:
     however the key must be scoped to within the control (or subcontrol)
     -->
  <xsl:key name="addition-by-target" match="add" use="@target"/>
  
  
  <!-- Service functions: provided for Schematron etc. DON'T MESS WITH THESE OR YOU'LL BREAK IT. -->
  <!-- Returns a set of controls or components marked as controls for a profile. -->
  <xsl:function name="oscal:resolved-controls" as="element()*">
    <!--saxon:memo-function="yes" xmlns:saxon="http://saxon.sf.net/"-->
    <xsl:param name="who" as="document-node()?"/>
    <xsl:sequence select="oscal:resolve($who)//(control | component[contains-token(@class,'control')])"/> 
  </xsl:function>
  
  <!-- Returns a set of subcontrols or components marked as subcontrols for a profile. -->
  <xsl:function name="oscal:resolved-subcontrols" as="element()*">
    <xsl:param name="who" as="document-node()?"/>
    <xsl:sequence select="oscal:resolve($who)//(subcontrol | component[contains-token(@class,'subcontrol')])"/> 
  </xsl:function>
  
  <!-- Expect a profile to be resolved. If a catalog or framework, this should return a copy of the input. -->
  <xsl:function name="oscal:resolve" as="document-node()" saxon:memo-function="yes" xmlns:saxon="http://saxon.sf.net/">
    <xsl:param name="who" as="node()?"/>
    <xsl:document>
      <xsl:apply-templates select="$who" mode="oscal:resolve"/>
    </xsl:document>
  </xsl:function>
  
  <!-- returns sequence of tokens including passed value, but non-duplicatively -->
  <xsl:function name="oscal:classes-including" as="xs:string">
    <xsl:param name="class" as="attribute(class)?"/>
    <xsl:param name="value" as="xs:string"/>
    <xsl:sequence select="string-join((tokenize($class,'\s+')[. ne $value],$value), ' ')"/>
  </xsl:function>

  <xsl:function name="oscal:classes" as="xs:string*">
    <xsl:param name="who" as="element()"/>
    <!-- HTML is not case sensitive so neither are we -->
    <xsl:sequence select="tokenize($who/@class/lower-case(.), '\s+')"/>
  </xsl:function>
  
  <xsl:key name="element-by-id" match="*[@id]" use="@id"/>
  
  

 

  
</xsl:stylesheet>
