---
title: "A YANG Module for Entitlement Inventory"
abbrev: "entitlement-inventory"
category: std
docname: draft-ietf-ivy-entitlement-inventory-latest
submissiontype: IETF
number:
date:
consensus: true
v: 3
area: "Operations and Management"
workgroup: "Network Inventory YANG WG"
keyword:
  - inventory
  - capability
  - entitlement
  - licensing
venue:
  group: "Network Inventory YANG WG"
  type: "Working Group"
  mail: "inventory-yang@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/inventory-yang/"

  github: "dr2lopez/ivy-capability-entitlement"
  latest: "https://dr2lopez.github.io/ivy-capability-entitlement/draft-ietf-ivy-entitlement-inventory.html"
author:
  - name: Marisol Palmero
    organization: Independent
    email: "marisol.ietf@gmail.com"
  - name: Camilo Cardona
    organization: NTT
    email: "camilo@gin.ntt.net"
  - name: Diego Lopez
    organization: Telefonica
    email: "diego.r.lopez@telefonica.com"
  - name: Italo Busi
    organization: Huawei
    email: "italo.busi@huawei.com"

normative:

informative:
  BaseInventory: I-D.ietf-ivy-network-inventory-yang

--- abstract

This document defines a YANG data model for managing software entitlements (licenses) within a network inventory. The model represents the relationship between organizational entitlements, network element capabilities, and the constraints that entitlements impose on capability usage.

This data model enables operators to determine what capabilities their network elements possess, which capabilities are currently entitled for use, and what restrictions apply. The model supports both centralized entitlement management and device-local entitlement tracking for physical and virtual network elements.

--- middle

# Introduction

Network elements provide capabilities—functions such as MPLS routing, advanced QoS, or bandwidth throughput—that operators use to build services. Many capabilities require entitlements (licenses) from vendors before activation.

This document defines a YANG data model for tracking entitlements and their relationship to capabilities. The model supports three operational use cases:

- Tracking entitlements held by the organization, their scope, and assigned holders
- Representing capabilities available on network elements and whether entitlements permit their use
- Monitoring active capability usage and enforced restrictions

Operators use this information to answer: What can this device do? What is it entitlement-id to do? What restrictions apply?

As network technology evolves toward modular, software-defined, and virtualized architectures, managing the rights to activate specific functions becomes increasingly complex. These rights granted via entitlements or licenses must be tracked, aggregated, and matched to assets to ensure that services can be delivered using available capabilities. This complexity calls for structured, machine-readable models that represent which capabilities are available, permitted, and in use.

This draft provides a foundational YANG structure for representing these relationships as standards, complementing the network inventory module.

## Scope of the Entitlement Model

The entitlement model provides an inventory of entitlements. This includes the entitled holders and the capabilities to which they are entitled. Additionally, it offers information into the restrictions of the operation of the different assets (network entities and components). In general, this model seeks to address the following questions:

* What entitlements are administered/owned by the organization?
* How are entitlements restricted to some assets and holders?
* What entitlements are installed on each network asset?
* What constraints do the current installed entitlements impose on the network assets' functionality?
* Does the entitlement impose any kind of global restrictions? What are they?
* What are the restrictions that each network element has due to the entitlements it holds locally?

In this document, the term "installed entitlements" refers to entitlements that have been assigned to a particular network asset. The act of installation may involve directly provisioning the entitlement on the device or component, or it may represent a logical assignment in a centralized system. Some entitlements may be assigned to multiple network assets up to a defined limit; such constraints can be modelled as global restrictions of under the entitlement.

The model supports entitlement tracking and capability management. It is intentionally designed to be extensible through YANG augmentation. Organizations requiring vendor-specific entitlement features should augment this base model rather than modifying it directly.

This model focuses on operational inventory of entitlements and capabilities. The following are explicitly out of scope:

* Commercial aspects of entitlement acquisition and pricing
* Entitlement migration policies between devices (vendor-specific)
* Per-user access control mechanisms (covered by separate access control standards)

This model focuses on the ability to use capabilities, not on access control mechanisms. For example, if a router cannot enable MPLS due to entitlement restrictions, it means the organization lacks the rights to use that capability—even if access to the device itself is available. This distinction is separate from, for instance, the ability of a specific user to configure MPLS due to access control limitations.

## Entitlement Deployment Models

Entitlements can be deployed and managed in different ways depending on the operational environment and vendor implementation. The following deployment models are commonly encountered:

- **Local Installation:** The entitlement is installed directly on the network asset, which maintains knowledge of its entitlements and enforces capability restrictions locally. This is a common approach for devices that operate independently.

- **License Server:** Entitlements reside in an external license server, which may be deployed on-premises or in the cloud. Network assets communicate with the license server to verify entitlement status and capability permissions. This model supports centralized management and dynamic entitlement allocation.

- **Commercial Agreement:** In some deployments, entitlements exist purely as commercial agreements, and policy enforcement occurs outside the network asset. The network asset may operate without direct knowledge of the entitlement, relying on external systems for compliance tracking.

This model is designed to be exposed by both network elements and license services. It provides mechanisms for each system to express the information it knows while being clear about the information it does not have, primarily through the presence or absence of containers. A network element should contain certain entitlement information, a license service other information, and a telemetry monitoring system could gather data from both sources to provide a complete picture.

### Entitlement Provisioning

This model is not intended for automatic discovery of entitlements or capabilities through the network elements themselves. Instead, it assumes that entitlements and their associations are either:

- Provisioned in a license server or asset database;
- Installed on individual devices and reported through management interfaces; or
- Manually configured as part of an inventory process.

Future augmentations may explore capability discovery or telemetry-driven models, but they are out of scope for the current version.


# Conventions and Definitions

{::boilerplate bcp14-tagged}

* ToBeUpdated(TBU) Open Issue for the IVY WG, to include:

<<Update Glossary under  Network Inventory draft, {{BaseInventory}}. We need at least formal definitions of "capability" and "entitlement".>>

-Capability: A discrete function, feature, or resource that a network element is technically capable of performing when properly entitled. Examples include MPLS routing, specific bandwidth throughput, or advanced QoS features.
-Entitlement: A vendor-issued authorization (typically a license) that grants permission to activate and use one or more capabilities on specific network elements, potentially subject to constraints such as time limits, usage quotas, or scope restrictions.
-Installed Entitlement: An entitlement that has been locally activated on a network element and is available for use by that element's capabilities.
-Capability Restriction: A constraint imposed by an entitlement that limits how a capability can be used (e.g., bandwidth cap, concurrent user limit, geographic restriction)."
- Network Asset: A network element or a component within a network element. The model supports entitlements and capabilities at both levels. This term is used throughout the document when the concept applies equally to network elements and their components.

# Modeling Capabilities and Entitlements

The model describes how to represent capabilities and the entitlements that enable them across inventoried network assets. Capabilities describe what an asset can do. Entitlements indicate whether those capabilities are allowed and under what conditions.

~~~ aasvg
{::include art/Organization_NetworkElements.txt}
~~~
{: #fig-extBaseNetworkInventory title="Relationship Between Entitlements and Capabilities" }

The following subsections describe how the model progressively builds upon the base network inventory to incorporate capabilities, entitlements, and their relationships. The model uses identity-based classes in multiple parts to enable extensibility, allowing implementations to derive custom types that reference external definitions when needed.


## Foundational model: NetworkElement-Entitlements-Capabilities and Restrictions

To represent the complex relationships between network elements, capabilities, and entitlements, a foundational Network Inventory model should be built through a series of extensions. The following diagrams illustrate the progressive complexity of the approach, starting with simple network inventory extensions and culminating in a comprehensive model incorporating capabilities, entitlements, and restrictions.

### Progressive Model Complexity

{{fig-extBaseNetworkInventory}} depicts the initial step, highlighting the base network inventory and the areas to be extended: hardware, software, and entitlements. These extensions are necessary to properly model the relationships.

~~~ aasvg
{::include art/extensionBaseNetworkInventory.txt}
~~~
{: #fig-extBaseNetworkInventory title="Base Network Inventory Entitlement extension" }


{{fig-ascii-art_baseInventory}} illustrates the initial relationship between Network Elements and entitlements is two ways: entitlements SHOULD be attached to NE, and NE SHOULD have entitlements installed.

~~~ aasvg
{::include art/ascii-art_baseInventory.txt}
~~~
{: #fig-ascii-art_baseInventory title="Relationship between entitlements and Base Inventory" }


{{fig-capabilities_baseinventory}} depicts NE support capabilities thanks to entitlements that entitle them of their use

~~~ aasvg
{::include art/capabilities_baseinventory.txt}
~~~
{: #fig-capabilities_baseinventory title="Capabilities integration with the Base Inventory" }


Finally, NE support capabilities thanks to entitlements that entitle them of their use under certain constraints as shown in {{fig-capabilities_restrictions}}.

~~~ aasvg
{::include art/capabilities_restrictions.txt}
~~~
{: #fig-capabilities_restrictions title="Complete model with restrictions" }


## Capabilities

Capabilities are modeled by augmenting "network-element" in the "ietf-network-inventory" module in {{BaseInventory}} according to the following tree:

~~~ aasvg
{::include trees/capability_tree.txt}
~~~

For any given network asset, the capabilities list MAY include all potential capabilities advertised by the vendor, and MUST include those for which the network operator holds a valid entitlement—whether active or not.

This document does not define a complete theory of capabilities or their internal relationships; such work may be addressed elsewhere. Instead, the model provides a flexible framework through the use of identity-based capability classes:

- **Basic capability class**: The module defines `basic-capability-description` as a simple capability  class using only identifiers and descriptions. This supports implementations that present capabilities as straightforward lists.

- **Extended capability classes**: For structured capability definitions, implementations derive new identities from `capability-class`. These reference external YANG modules where capabilities have formal structure and semantics. (TBU - See Section X for extension examples.)

This separation ensures that capability definitions can evolve independently of the entitlement inventory model, and that implementations can adopt capability models appropriate to their domain without modifications to this base module.

The granularity at which capabilities are defined is at the discretion of the vendor. A vendor MAY choose to advertise capabilities at a high level of abstraction, such as "Advanced Services," and consumers of this information should refer to vendor documentation to understand what specific functions are included. Alternatively, an implementation MAY enumerate capabilities at a finer granularity, listing individual protocols or features such as MPLS, BGP, or QoS. The model accommodates both approaches.

The capabilities of an inventoried network asset may be restricted based on the availability of proper entitlements. An entitlement manager should be interested in the capabilities available to be used on the network assets, and the capabilities that are currently available. The model includes this information by means of the "supporting entitlements" list, which references installed entitlements and includes potential restrictions related to the status of the entitlement. This allows organizations to monitor entitlement usage and avoid misconfigurations or exceeding permitted capability limits.

### Extending Capability Classes

The `capability-class` identity provides an extension point for integrating external capability models. This module does not define domain-specific capability classes; instead, extensions derive new capability classes that reference separate models where capabilities are formally defined.

The extension pattern involves two modules:

1. **Capability definition module**: An independent module defining capability concepts with its own structure (lists, containers, attributes). This module has no dependency on the entitlement inventory.
2. **Integration module**: An extension module that derives a new `capability-class` identity and augments the entitlement inventory to reference the capability definitions from the first module.

This pattern ensures that:

- Capability models evolve independently of entitlement tracking
- Multiple capability domains can coexist (e.g., routing capabilities, security capabilities, QoS capabilities) each with their own defining module
- The entitlement inventory remains a thin integration layer rather than a repository of capability definitions

The following example module defines capability concepts for a specific domain:

~~~
{::include yang/examples/example-capability-framework.yang}
~~~

The following extension module extends the `capability-class` identity and augments the entitlement inventory to reference the capability definitions from the module above:

~~~
{::include yang/examples/example-capability-extension.yang}
~~~

This pattern allows capability definitions to evolve independently while maintaining a clean integration with the entitlement inventory through the capability-class identity mechanism.

## Entitlements

The entitlement modeling augments "network-inventory" in the ietf-network-inventory module in {{BaseInventory}} with a top-level entitlements container according to the following tree:

{{fig-ModelRelationship}} depicts the relationship between the Entitlement Inventory model and other models. The Entitlement Inventory model enhances the model defined in the base network inventory model with entitlement-specific attributes and centralized entitlement management capabilities.

~~~
   +----------------------+
   |                      |
   |Base Network Inventory|
   |                      |
   +----------+-----------+
              ^
              |
   +----------+-----------+
   |                      |
   | Entitlement Inventory|
   |  e.g., licenses,     |
   |  capabilities,       |
   |  restrictions        |
   +----------------------+
~~~
{: #fig-ModelRelationship title="Relationship of Entitlement Inventory Model to Other Inventory Models" }

~~~
{::include trees/entitlements_tree.txt}
~~~

Entitlements MUST be listed at the top level, directly under the `network-inventory` container. This is required because organizations may own entitlements that are not yet assigned to any network asset. Such entitlements exist in a pending state, available for future assignment or installation when the organization decides to allocate them to specific assets.

Entitlements may be listed without explicitly identifying the assets (network elements or components) they apply to. Entitlements are linked to network assets in multiple ways: (1) When entitlements are created for specific assets (i.e., they should only be installed on those), then those assets are specified under the entitlement's attachment section. (2) When an entitlement is installed on a network asset, it appears in the asset's installed-entitlements list. (3) When an installed entitlement enables capabilities, the asset's capabilities will reference the installed entitlement via the supporting-entitlements list.

The base network inventory model includes both network elements and components within them. A network element is an abstraction that typically represents a complete device such as a router or switch. For single-chassis devices, entitlements are typically associated with the network element itself rather than with individual chassis components. However, certain deployment scenarios involve multi-chassis systems—such as stacked switches or optical network elements—where multiple physical units operate as a single logical network element. In these cases, each component may have its own commercial identity (such as a serial number) while the collection behaves as one network element.

Entitlements are typically assigned based on commercial identifiers, often targeting serial numbers. The model supports linking entitlements to both network elements and individual components. However, component-level entitlement tracking is RECOMMENDED only when necessary—specifically when each component has its own set of capability limitations that must be managed independently. Examples include:

- Individual switches in a stack, where each unit has separate entitlements;
- Individual chassis in a multi-chassis network element, such as optical equipment; or
- Pay-as-you-grow routers where line cards have independent entitlement requirements.

In the YANG model, both network elements and components are supported by providing augmentations to each.

Entitlements and network assets are linked in the model in multiple ways. Entitlements at the network-inventory level should be attached to network assets through their attachment mechanism, representing organizational entitlements. Network assets have their own installed-entitlements that may be derived from the centralized entitlements or assigned directly. The capabilities of network assets reference these installed entitlements through their supporting-entitlements lists. The former addresses the case of a centralized license server or inventory system, while the latter represents entitlements that are actively entitling the asset's capabilities. An installed entitlement that is not referenced by any capability means that it is active on the asset but not currently in use.

Entitlements are managed both centrally at the network-inventory level and at the asset level through installed-entitlements. Network assets reference their installed entitlements through their capabilities' supporting-entitlements lists. For instance, a license server or inventory system should list an entitlement at the top level, which then gets installed on specific network assets where the capabilities reference the active entitlement. Each installed entitlement references its centralized entitlement directly via the entitlement-id leafref. For hierarchical or pooled entitlements (e.g., a base license with add-on upgrades), the "parent-entitlement-uid" field in the centralized entitlement catalog links child entitlements to their parent. Proper identification of entitlements is imperative to ensure consistency across systems, enabling monitoring systems to recognize when multiple locations reference related entitlements.

### Reverse Mapping from Entitlements to Capabilities

While the model includes links from capabilities to supporting entitlements, some inventory operators may need to evaluate entitlements independently and identify the capabilities they enable.

To support this, implementers may use the "product-id" or "capability-class" metadata along with external references or catalogs. Implementations requiring reverse mapping (identifying capabilities enabled by a specific entitlement) may leverage vendor-specific augmentations or external entitlement catalogs. Standardization of such reverse mappings is outside the scope of this document.

## Entitlement Attachment

The "entitlement" container holds a container called "entitlement-attachment" which relates how the entitlement is operationally linked to holders or network assets. Note that there is a difference between an entitlement being attached to a network asset and an entitlement being installed on the asset. In the former, the license was explicitly associated with one or more assets. Some licenses actually can be open but have a limited number of installations. Other licenses should be openly constrained to a geographic location. We are not dealing with these complex cases now, but the container can be expanded for this in the future.

The model accommodates listing entitlements acquired by the organization but not yet applied or utilized by any actor/asset at the network-inventory level. For these pending entitlements, they can be managed centrally without requiring individual network assets to be aware of their existence.

Some entitlements are inherently associated with a holder, such as organization or a user. For example, a software license may be directly attached to a user. Also, the use of a network device may come with a basic license provided solely to an organization. Some entitlements could be assigned to a more abstract description of holders, such as people under a jurisdiction or a geographical area. The model contains basic information about this, but it can be extended in the future to be more descriptive.

While attachment is optional, the model should be capable of expressing attachment in various scenarios. The model can be expanded to list to which network assets an entitlement is aimed for, when this link is more vague, such as a site license (e.g., network assets located in a specific site), or more open licenses (e.g., free software for all users subscribed to a streaming platform).

The current model does not provide information on whether an entitlement can be reassigned to other network assets. Such scenarios fall under the "what if" category, which is not covered by this model.

## Installed Entitlements

Since capabilities are optional in network assets, the model also provides an augmentation to track entitlements that are installed directly on network assets. This augmentation of "network-element" and "component" in the "ietf-network-inventory" module provides local entitlement storage according to the following tree:

~~~
{::include trees/installed_entitlments_tree.txt}
~~~

The installed entitlements represent references to entitlements that are currently active and entitling the network asset. The "entitlement-id" field provides a direct reference to the centralized entitlement at the network-inventory level.

This structure allows network assets to track which entitlements are actively granting them rights, while maintaining the ability to trace relationships to organization-wide entitlement policies.

When entitlements are installed at the component level (e.g., line cards), implementations MAY also list them at the parent network-element level to provide a consolidated view of all entitlements active on the device. Management systems should recognize when an entitlement-id appears at both levels and treat them as the same license instance to avoid double-counting. This point requires further exploration in future instances of this document.

## Implementation Considerations

The model is designed to support partial implementations. Not all systems need to implement every container or feature. The use of presence containers throughout the model allows implementations to signal which parts of the model they support. An implementation that does not populate a presence container indicates that it cannot report that information.

The following progression describes how implementations can adopt the model incrementally, from basic entitlement tracking to full capability and restriction reporting:

### Level 1: Centralized Entitlement Inventory

The minimal implementation populates the top-level `entitlements` container under `network-inventory`. This provides a centralized catalog of all entitlements owned or managed by the organization, including their identifiers, vendors, states, and validity periods.

At this level, the system answers: What entitlements does the organization have?

### Level 2: Installed Entitlements on Assets

Building on Level 1, implementations can populate the `installed-entitlements` container on network elements and/or components. This tracks which entitlements are currently active and entitling each network asset, by referencing the centralized entitlement catalog.

At this level, the system additionally answers: Which entitlements are actively entitling which assets?

### Level 3: Capabilities Reporting

Implementations that can report device capabilities populate the `capabilities` container on network elements and/or components. This lists what functions each asset can perform, organized by capability class.

At this level, the system additionally answers: What can each asset do?

### Level 4: Capability-Entitlement Linkage

Advanced implementations populate the `supporting-entitlements` container within each capability. This links capabilities to the installed entitlements that enable them, along with the `entitlement-state` container indicating whether each capability is allowed and in use.

When a capability lists multiple supporting entitlements, the `entitlement-state/allowed` field MUST reflect the combined effect of all required entitlements. If any required entitlement is missing, expired, or revoked, `allowed` should be false. The `in-use` field indicates whether the capability is currently operational.

At this level, the system additionally answers: Which entitlements enable which capabilities? What is allowed and what is in use?

### Level 5: Restrictions Reporting

Full implementations populate restriction information at two levels:

- The `restrictions` container under each entitlement for global restrictions (e.g., total allowed installations, aggregate usage limits)
- The `capability-restrictions` container within each capability for capability-specific limits (e.g., maximum throughput, connection limits)

At this level, the system additionally answers: What constraints apply to entitlements and capabilities? What are the current usage levels?

Implementations SHOULD document which levels they support and any deviations from this progression.

## Model Definition
~~~
{::include yang/ietf-entitlement-inventory.yang}
~~~

### Model tree

~~~
{::include yang/trees/ietf-entitlement-inventory.tree}
~~~


# Use cases and Examples

This section describes use cases and provides validated JSON examples demonstrating how to model entitlements and capabilities. Each example shows how the questions explored in this draft can be answered by the model.

## Basic Structure

This example shows the fundamental structure of the model: a network element with an installed entitlement that enables a capability. The entitlement is defined at the network-inventory level and referenced by the network element. The capability includes entitlement-state (allowed/in-use) and supporting-entitlements that link back to the installed entitlement.

~~~
{::include yang/examples/example1-basic-structure.json}
~~~

## Expired License Handling

This example demonstrates how the model handles entitlement lifecycle states. An expired security entitlement results in capabilities being disallowed (allowed: false), while an active routing entitlement keeps its capabilities enabled. The installed-entitlements list shows in-use status reflecting actual capability usage.

~~~
{::include yang/examples/example2-expired-license.json}
~~~

## Utilization Tracking with Restrictions

This example shows comprehensive utilization tracking across multiple capabilities. Each capability includes capability-restrictions with current-value and max-value fields, enabling organizations to monitor resource consumption against licensed limits. This addresses the question: "What constraints apply and what are current usage levels?"

~~~
{::include yang/examples/example3-utilization-tracking.json}
~~~

## Hierarchical Entitlements

This example demonstrates the parent-entitlement-uid mechanism for modeling entitlement hierarchies. A base "bronze" entitlement provides foundational capabilities, while a "silver" upgrade entitlement (referencing the bronze as parent) adds advanced features. This pattern supports tiered licensing models.

~~~
{::include yang/examples/example4-hierarchical-entitlements.json}
~~~

## License Pooling

This example shows how shared entitlements can be installed across multiple network elements. A pool-based license is defined once at the network-inventory level with global restrictions (total seats), then installed on multiple routers. Each router's capabilities reference the shared entitlement, and individual capability-restrictions track per-device usage against the pool.

~~~
{::include yang/examples/example5-license-pooling.json}
~~~

## Multi-Vendor Environment

This example illustrates entitlement management in a heterogeneous network with devices from multiple vendors. Each vendor may use different licensing models (consumption-based, perpetual, subscription), but the unified model captures all entitlements consistently. The example shows how organizations gain visibility across their entire multi-vendor infrastructure.

~~~
{::include yang/examples/example6-multi-vendor.json}
~~~

## Component-Level Entitlements

This example demonstrates entitlement tracking at the component level within a modular network element. Individual line cards have their own port licenses, while the chassis has system-level entitlements. This addresses scenarios where different components within the same device have independent entitlement requirements, such as pay-as-you-grow deployments.

~~~
{::include yang/examples/example7-modular-components.json}
~~~

## Capability Class Extension

This example demonstrates extending the capability-class identity to reference external capability definitions. The example-capability-extension module derives a new capability class and augments the model to reference capabilities defined in a separate module. This pattern allows domain-specific capability models to integrate cleanly with entitlement tracking.

~~~
{::include yang/examples/example8-capability-extension.json}
~~~

# Operational Considerations

## Entitlement Synchronization

When entitlements are managed both centrally and locally, implementations SHOULD provide mechanisms to detect inconsistencies between:

* Centralized entitlement records
* Locally installed entitlements
* Actual capability usage

## Entitlement Expiration Handling

Network elements SHOULD generate notifications when installed entitlements are approaching expiration. The notification timing and handling is implementation-specific but SHOULD provide sufficient lead time for renewal.

## Performance Considerations

Implementations tracking large numbers of entitlements SHOULD consider:

* Caching strategies for frequently accessed entitlement data
* Efficient indexing of entitlement-to-capability mappings
* Minimizing overhead of entitlement validation checks

## Migration and Version Compatibility

When migrating from vendor-specific entitlement systems, implementers should consider mapping strategies that preserve entitlement relationships while adopting this standard model.

# IANA Considerations

This document registers one URI in the "IETF XML Registry" {{!RFC3688}} and one YANG module in the "YANG Module Names" registry {{!RFC6020}}.

## URI Registration

IANA is requested to register the following URI in the "ns" subregistry within the "IETF XML Registry" {{!RFC3688}}:

~~~~
   URI:  urn:ietf:params:xml:ns:yang:ietf-entitlement-inventory
   Registrant Contact:  The IESG.
   XML:  N/A; the requested URI is an XML namespace.
~~~~

## YANG Module Name Registration

IANA is requested to register the following entry in the "YANG Module Names" registry {{!RFC6020}}:

~~~~
   Name:         ietf-entitlement-inventory
   Namespace:    urn:ietf:params:xml:ns:yang:ietf-entitlement-inventory
   Prefix:       ei
   Maintained by IANA:  N
   Reference:    RFC XXXX
~~~~


# Security Considerations

## Entitlement Data Sensitivity

Implementations MUST protect entitlement data with appropriate access controls consistent with organizational security policies.

## Entitlement Tampering

Implementations SHOULD use cryptographic signatures or similar mechanisms to verify entitlement integrity. Network elements SHOULD validate entitlements before activating capabilities.

## Information Disclosure

Access to entitlement inventory data SHOULD be restricted to authorized personnel. Consider implementing role-based access controls that limit visibility based on operational need.

--- back

# Acknowledgments
{:numbered="false"}

This document is based on work partially funded by the EU Horizon Europe projects ACROSS (grant 101097122), ROBUST-6G (grant 101139068), iTrust6G (grant 101139198), MARE (grant 101191436), and CYBERNEMO (grant 101168182).
