## Progressive Model Complexity

### Figure 1: Base Network Inventory Extensions

~~~
                    ┌─────────────────┐
                    │Base Network     │
                    │Inventory        │
                    └─────────┬───────┘
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
│  Hardware   │    │    Software     │    │Entitlements │
│             │    │                 │    │             │
└─────────────┘    └─────────────────┘    └─────────────┘
~~~

We just list the entitlements that exist under the scope
### Figure 2: Attachment and Installation Relationships

~~~
                 ┌─────────────────────────┐
                 │Base Network Inventory   │
                 └─────────┬───────────────┘
     ┌─────────────────────┼─────────────────────┐
     ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
│  Hardware   │    │    Software     │    │Entitlements │
│             │◄───┼─────────────────┼────┤             │
│             │────┼─────────────────┼───►│             │
└─────────────┘    └─────────────────┘    └─────────────┘
~~~
The relationship between Network elements and entitlements is 2 way: entitlements MIGHT be attached to NE, and NE might have entitlements installed.

### Figure 3: Capabilities Integration

~~~
                 ┌─────────────────────────┐
                 │Base Network Inventory   │
                 └─────────┬───────────────┘
     ┌─────────────────────┼─────────────────────┐
     ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
│  Hardware   │    │    Software     │    │Entitlements │
│             │◄───┼─────────────────┼────┤             │
│             │────┼─────────────────┼───►│             │
└──────┬──────┘    └────────┬────────┘    └──────┬──────┘
       │ support            │                    │ entitles 
       └─────────┐          │                    │
                 └──────────┐                    │
                            ▼                    │
                     ┌─────────────────┐         │
                     │  Capabilities   │◄────────┘
                     └─────────────────┘
~~~
NE support capabilities thanks to entilements that entitle them of their use

### Figure 4: Complete Model with Restrictions

~~~
                 ┌─────────────────────────┐
                 │Base Network Inventory   │
                 └─────────┬───────────────┘
                           │
     ┌─────────────────────┼─────────────────────┐
     │                     │                     │
     ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
│  Hardware   │    │    Software     │    │Entitlements │
│             │◄───┼─────────────────┼────┤             │
│             │────┼─────────────────┼───►│             │
└──────┬──────┘    └────────┬────────┘    └──────┬──────┘
       └─────────┐          │                    │
                 └──────────┐                    │
                            ▼                    │
                     ┌─────────────────┐         │
                     │  Capabilities   │◄────────┘
                     └─────────┬───────┘
                               │ constrained by
                               ▼
                     ┌─────────────────┐
                     │  Restrictions   │
                     └─────────────────┘
~~~
NE support capabilities thanks to entilements that entitle them of their use under certain constraints