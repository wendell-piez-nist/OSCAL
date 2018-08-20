# OSCAL Metaschema

## Notes and sketches

```
<define-component name="control" plural="controls">
  <element    name="title"/>
  <components name="props"/>
  <components name="params"/>
  <prose/>  
  <components name="parts"/>
  <components name="links"/>
  <components name="references"/>
</define-component> 

<define-element name="title">
 <mix name="inlines"/>
</define>

<define-mix name="inlines">
    <text/>
    <element name="sub"/>
    <element name="sup"/>
</define-mix>

<define-element name="sub">
 <mix name="inlines"/>
</define>

<define-element name="sup">
 <mix name="inlines"/>
</define>

<define-component name="prop" plural="props">
 <text/>
</define>

<define-component name="param" plural="params">
<components name="descriptions"/>
<components name="labels"/>
<components name="values"/>
<components name="links"/>
</define-component>

<define-component name="part" plural="parts">
  <element    name="title" required="no"/>
  <components name="props"/>
  <components name="params"/>
  <prose/>  
  <components name="parts"/>
  <components name="links"/>
</define-component>

<define-component name="links" plural="links">
      <attribute  name="href" required="no" datatype="anyURI"/>
      <attribute  name="rel"                datatype="NCName"/>
      <mix name="inlines"/>
</define-component>

<define-component name="ref" plural="references">
      <components name="citations"/>
  </define-component>  

<define-component name="citation" plural="citations">
      <components name="citations"/>
  </define-component>  

```


