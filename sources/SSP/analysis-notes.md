# Summary View: Control Summary Info (from cloud.gov SSP)

A "Proposal" would include a summary view covering controls as scoped by either or both:
  A relevant catalog or profile(s), separately or in aggregate
  As presented in a set of source ('imported') 'proposals'
  Arbitrarily (probably in correspondence w/ known control catalogs)
   
Those controls would be as selected and modified in the source profile.

The Summary View presented will aggregate together (from a capabilities map):

* information from the source (reference) controls, as modified (traceably) via profiling
* information presented from imported proposals addressing the same controls or points w/in them
* information provided as "proposal content" (local enhancement)

These various sources are distinguishable.


 

- Summary
  - responsibleRole*
  - implementationStatus
    -   one or more selections from a list of controlled values
    -   values include 'implemented' 'partially implemented' 'planned' 'alternative implementation' and 'n/a' (say)
    - could this be provided by a synopsis of system components addressing the control with their qualifications? i.e. not whehter 'implemented' but 'implementationInputs'
    - 
  - controlOrigination
    -   one or more selections from a list of controlled values, e.g.
      -  ☐ Service Provider Corporate
       - ☐ Service Provider System Specific
       - ☐ Service Provider Hybrid (Corporate and System Specific)
       - ☐ Configured by Customer (Customer System Specific)
       - ☐ Provided by Customer (Customer System Specific)
       - ☒ Shared (Service Provider and Customer Responsibility)
       - ☒ Inherited from pre-existing FedRAMP Authorization for AWS GovCloud , 6/21/2016 s

       
    - These categories map to
      - SP component (factory settings or as configured by SP)
      - SP component (as configured by customer)
      - Customer component
      - Customer capability
      - Shared capability
      - (so more generally: a capability provided by an included or explicit component or just as proposed)
      - (additionally) Inherited from [reference]

"What is the solution and how is it implemented"

Descriptive prose maps to the control text in organization
i.e. a template driven from the catalog (profile). Frequent cross-links to ROLES TABLE

ROLES TABLE ( Table 9-1 User Roles and Privileges) is key

| Role | Internal or External | Privileged (P), Non-Privileged (NP), or No Logical Access (NLA) | Sensitivity Level | Authorized Privileges | Functions Performed |
|--|--|--|--|--|


Also: Can we produce ports, protocols and services table


Capability maps should provide prose addressing specific items (points) in control catalogs

These can be assembled into "summary views" of all the prose addressing particular controls

So, e.g.
AC-1.j might get several clauses, from each of several capabilities entailing several components
  So AC-1.j from AWS via capability X
            from cloud.gov via capability Y etc.

- scenario
  - vendor e.g. docker produces an OSCAL "capability map"
  -   describes components
  -   describes controls addressed by those components
  
  
  
  An SSP Control Summary can be produced from the capability map
  this document is indexed to produce SSP-supplement
    Control Summary Info as extracted from capability maps
    
    
    - capabilities
      - component*
        - id, name, contact
        - capability*
      - capability
        - responsibleRole
          component*
          control*
            addresses/partially addresses etc.
          set-param*
          
          inheritance model
            previous proposals/authorizations should be referenceable
            so you get its controls 'for free' eg MP-3
            
          
  - component descriptions/specs
    - describing addressable controls via capabilities 
      settings