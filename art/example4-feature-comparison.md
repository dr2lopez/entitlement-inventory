# Example 4: Hierarchical Entitlements - Feature Comparison

## License Tier Comparison

This table shows which features are enabled by each license tier in the hierarchical entitlements example.

| Feature                    | Bronze Base | Bronze + Silver Upgrade |
|:---------------------------|:-----------:|:-----------------------:|
| **Basic Routing**          |             |                         |
| OSPF Routing               | ✓           | ✓                       |
| Static Routing             | ✓           | ✓                       |
| **Advanced Routing**       |             |                         |
| BGP Routing                | ✗           | ✓                       |
| MPLS Label Switching       | ✗           | ✓                       |
| Advanced QoS               | ✗           | ✓                       |

## Device Deployment

| Device          | Installed Entitlements              | Enabled Features                                    |
|:----------------|:------------------------------------|:----------------------------------------------------|
| branch-router-1 | bronze-routing-base                 | OSPF, Static Routing                                |
| branch-router-2 | bronze-routing-base + silver-upgrade | OSPF, Static Routing, BGP, MPLS, Advanced QoS       |

## Entitlement Relationship

~~~
bronze-routing-base (parent)
    |
    +-- Enables: OSPF, Static Routing
    |
    +-- silver-routing-upgrade (child, requires parent)
            |
            +-- Adds: BGP, MPLS, Advanced QoS
~~~

## Resource Limits by Tier

| Resource                  | Bronze Tier  | Silver Tier  |
|:--------------------------|:-------------|:-------------|
| OSPF Areas                | 10 max       | 10 max       |
| Static Routes             | 500 max      | 500 max      |
| BGP Peers                 | N/A          | 100 max      |
| MPLS LSPs                 | N/A          | 200 max      |
| QoS Classes               | N/A          | 16 max       |

## Notes

- Silver upgrade requires bronze base (parent-child relationship)
- Silver upgrade purchased later (June 2025) but aligned expiration date with base (Jan 2027)
- branch-router-1 remained on bronze tier (cost optimization)
- Advanced QoS capability is available but not in-use on branch-router-2
