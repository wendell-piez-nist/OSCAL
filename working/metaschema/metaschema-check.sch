<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0">


<!--
# extra-schema constraints:
#  prose may not appear twice among siblings i.e. count(prose) is never gt 1
#  @named may not be repeated among siblings
#  same w/ @group-as
#  likewise @named may not equal any @group-as
#  @named always resolves (to some /*/*/@name)
-->

    <xsl:key name="declaration-by-name" match="/*/*" use="@name"/>
    
    <sch:pattern>
        <sch:rule context="/METASCHEMA">
            <sch:assert test="@use=*/@name">METASCHEMA/@use should be one of <sch:value-of select="string-join(*/@name,', ')"/></sch:assert>
        </sch:rule>
        <sch:rule context="/*/*">
            <sch:report test="@name=('p','ul','ol','pre')">Can't use name '<sch:value-of select="@name"/>': it's reserved for prose.</sch:report>
            <sch:assert test="count( key('declaration-by-name',@name) ) eq 1">Not a distinct declaration</sch:assert>
            <sch:report test="@name = ../*/@group-as">Clashing name with group name: <sch:value-of select="@name"/></sch:report>
            <sch:report test="@group-as = ../*/@name">Clashing group name with name: <sch:value-of select="@name"/></sch:report>
            
            <sch:assert test="not(@label = 'id') or (@has-id='required')">If labeled with 'id', has-id should be "required"</sch:assert>
        </sch:rule>

        <!--<sch:rule context="define-field[@address-by='id']/*">
            <sch:assert test="empty(*)">Line defined as string may not have attributes</sch:assert>
        </sch:rule>-->
        <sch:rule context="define-property[@as='boolean']/*">
            <sch:assert test="empty(*)">Property defined as boolean may not have attributes</sch:assert>
        </sch:rule>
        
        <sch:rule context="*[exists(@named)]">
            <sch:let name="decl" value="key('declaration-by-name',@named)"/>
            
            <sch:assert test="exists($decl)">No declaration found for '<sch:value-of select="@named"/>' <sch:value-of select="local-name()"/></sch:assert>
            <sch:assert test="empty($decl) or empty(@group-as) or (@group-as = $decl/@group-as)">Declaration group name doesn't match: here is '<sch:value-of select="@group-as"/>' but the declaration has '<sch:value-of select="$decl/@group-as"/>'</sch:assert>
            <sch:assert test="empty($decl) or empty(@address) or ($decl/@address = @address)">The target definition has <sch:value-of select="if (exists($decl/@address)) then ('address ''' || $decl/@address || '''') else 'no address'"/></sch:assert>
            
            <sch:report test="@named = ../(* except current())/@named">Everything named the same must appear together</sch:report>
            <sch:report test="@named = ../*/@group-as">Clashing name with group name: <sch:value-of select="@named"/></sch:report>
            <sch:report test="@group-as = ../*/@named">Clashing group name with name: <sch:value-of select="@named"/></sch:report>
        </sch:rule>
        <sch:rule context="prose">
            <sch:assert test="count(../prose) eq 1">Prose may not appear in more than one position in a part</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@has-id='none']">
            <sch:report test="@address='id'">has-id="none" will be ignored on <sch:value-of select="name(..)"/> with address="id"</sch:report>
        </sch:rule>
    </sch:pattern>

</sch:schema>