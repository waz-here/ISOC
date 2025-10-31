
# Cisco BGP Traffic Engineering Summary

This document provides a summary of Cisco IOS commands used for BGP traffic engineering, extracted from the [08-BGP-policy.pdf](https://www.bgp4all.com/pfs/_media/workshops/08-bgp-policy.pdf) workshop material.

## 1. Outbound Traffic Engineering using LOCAL_PREFERENCE

**Purpose**: Prefer specific outbound paths within an AS.

```bash
ip prefix-list R1-prefix permit 10.10.0.0/26
ip prefix-list R8-prefix permit 10.30.0.0/26

route-map as30-localpref permit 10
 match ip address prefix-list R1-prefix
 set local-preference 50

route-map as30-localpref permit 20
 match ip address prefix-list R8-prefix
 set local-preference 200

route-map as30-localpref permit 30

router bgp 20
 neighbor 10.30.15.5 remote-as 30
 neighbor 10.30.15.5 route-map as30-localpref in
```

## 2. Inbound Traffic Engineering using MED (Multi-Exit Discriminator)

**Purpose**: Influence how other ASes enter your AS.

```bash
ip prefix-list R5-prefix permit 10.20.0.64/26

route-map as30-med permit 10
 match ip address prefix-list R5-prefix
 set metric 10

route-map as30-med permit 20

router bgp 20
 neighbor 10.20.15.18 remote-as 30
 neighbor 10.20.15.18 route-map as30-med out
```

## 3. Inbound Traffic Engineering using BGP Communities

**Purpose**: Use communities to signal preference to upstream ASes.

```bash
ip community-list 1 permit 20:150
ip community-list 2 permit 20:50

route-map customer-comm permit 10
 match community 1
 set local-preference 150

route-map customer-comm permit 20
 match community 2
 set local-preference 50

route-map customer-comm permit 30

router bgp 30
 neighbor 10.20.15.17 remote-as 20
 neighbor 10.20.15.17 description eBGP peering with R6
 neighbor 10.20.15.17 route-map customer-comm in

ip prefix-list R8-prefix permit 10.30.0.0/26

route-map set-comm permit 10
 match ip address prefix-list R8-prefix
 set community 30:50

route-map set-comm permit 20

router bgp 30
 neighbor 10.20.15.17 route-map set-comm out
```

## 4. Inbound Traffic Engineering using AS Path Prepending

**Purpose**: Make a path less preferred by increasing AS path length.

```bash
ip prefix-list R5-prefix permit 10.20.0.64/26

route-map prepend-as-path permit 10
 match ip address prefix-list R5-prefix
 set as-path prepend 20 20 20

route-map prepend-as-path permit 20

router bgp 20
 neighbor 10.20.15.18 remote-as 30
 neighbor 10.20.15.18 route-map prepend-as-path out
```

## Summary Table

| Technique             | Purpose                          | Key Commands (Abbreviated)                                                                 | Direction     |
|-----------------------|----------------------------------|---------------------------------------------------------------------------------------------|---------------|
| Local Preference      | Prefer specific outbound paths   | `set local-preference <value>`<br>`route-map ... in`                                       | Inbound       |
| MED (Multi-Exit Discriminator) | Influence inbound path choice    | `set metric <value>`<br>`route-map ... out`                                                | Outbound      |
| BGP Communities       | Tag routes for policy control    | `set community <AS:val>`<br>`match community <list>`<br>`set local-preference <value>`     | Inbound/Out   |
| AS Path Prepending    | De-prioritize inbound paths      | `set as-path prepend <AS> <AS> <AS>`<br>`route-map ... out`                                | Outbound      |

