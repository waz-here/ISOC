# Lab 2.5 — Peering Intelligence and Decision Making

## Overview

This lab introduces a data-driven approach to peering decisions using real-world Internet data sources.

Participants will evaluate whether a network should peer with another network, where that peering should occur, and whether it is economically beneficial.

This lab reflects real-world operator workflows used in Network Operator Group (NOG) environments.



## Objectives

By the end of this lab, you will be able to:

* Use PeeringDB to evaluate peering policies and presence
* Identify suitable IXPs for peering
* Analyse routing visibility using public tools
* Generate prefix filters using BGPQ4 with APNIC Whois
* Distinguish between organisation and ASN roles
* Make informed peering decisions based on technical and economic factors


## Scenario

You are the network engineer for a regional ISP in Bangladesh.

You want to optimise connectivity and reduce transit costs by evaluating peering opportunities.


## Scenario Assignment

Each group will be assigned one of the following scenarios:

### Scenario 1 — Content Peering (Cloudflare)

ASN X: Regional ISP (Bangladesh)  
ASN Y: AS13335 (Cloudflare)

### Scenario 2 — Content Peering (Google)

ASN X: Regional ISP  
ASN Y: AS15169 (Google)

### Scenario 3 — Transit vs Peering

ASN X: Regional ISP  
ASN Y: AS58717 (Summit Communications Ltd)

### Scenario 4 — Domestic Peering

ASN X: Regional ISP  
ASN Y: Another Bangladesh ISP

### Scenario 5 — Multi-ASN Organisation Analysis

ASN X: Regional ISP  
ASN Y: Organisation with multiple ASNs

* AS10075 (Fiber@Home Ltd.)
* AS23729 (Alo Communications Ltd.)



## Tools and References

* PeeringDB: https://www.peeringdb.com/
* PeeringDB Tutorial: https://tutorial.peeringdb.com/
* Internet Society Pulse (IXP Tracker): https://pulse.internetsociety.org/en/ixp-tracker/
* Cloudflare Radar: https://radar.cloudflare.com/
* bgproutes.io: https://www.bgproutes.io/
* Peercortex: https://peercortex.org/
* APNIC Whois: https://wq.apnic.net/static/search.html



## Part 1 — Peering Policy and ASN Identification

1. Search for ASN Y in PeeringDB
2. Record:
* Peering policy (Open / Selective / Restrictive)
* Network type (Content / Access / Transit)
* IXPs where ASN Y is present

### Questions

* Does ASN Y allow peering?
* Is negotiation required?



## Part 1B — Organisation vs ASN Validation

1. Identify the organisation for ASN Y
2. List all ASNs associated with this organisation

### Questions

* Does the organisation operate multiple ASNs?
* Do different ASNs serve different purposes?
* Which ASN is relevant for peering?

### Key Insight

An organisation may:

* operate multiple ASNs
* separate transit, access, and service roles
* use different ASNs at different IXPs



## Part 2 — Identify Peering Locations

1. List IXPs where ASN Y is present
2. Determine if ASN X shares any IXPs

If not:

* identify candidate IXPs

### Questions

* Are there shared IXPs?
* Are they geographically relevant?
* Are they active and well populated?



## Part 3 — Routing Visibility

Use:

* bgproutes.io
* Peercortex

### Identify

* Announced prefixes
* Upstream providers
* Peering visibility

### Questions

* Is ASN Y globally visible?
* Does it rely on transit or peering?
* Will traffic remain local if peered?



## Part 4 — Prefix Filtering (BGPQ4 with APNIC Whois)

### Example commands

```bash
bgpq4 -h whois.apnic.net -Jl AS13335
bgpq4 -h whois.apnic.net -Jl AS15169
```

### For this scenario

```bash
bgpq4 -h whois.apnic.net -Jl AS10075
bgpq4 -h whois.apnic.net -Jl AS23729
```

### Record

* Number of prefixes returned
* Missing or inconsistent data

### Questions

* Is IRR data complete?
* Are there risks in relying on this data?

### Note

This lab uses APNIC Whois to ensure regionally relevant and trusted IRR data.



## Part 5 — Network Value Analysis
Use:
* bgp.tools

Using BGP data and observation, evaluate:

* Peer connectivity (Peer Rank concept)
* User base (Eyeball networks)
* Content/services (Host networks)
* Network influence (AS Cone concept)

### Questions

* Is ASN Y a high-value peering target?
* Does it provide access to users or content?

### AS10075 (Fiber@Home)

* Likely characteristics:

  * Higher AS Cone (transit influence)
  * Lower Eyeball / Host value
* Role:
  * infrastructure provider

### AS23729 (Alo Communications)

* Likely characteristics:

  * Higher Eyeball value (users)
  * Moderate Peer Rank
* Role:
  * access / service provider

### Interpretation

| Metric       | AS10075      | AS23729       |
| ------------ | ------------ | ------------- |
| Peer Rank    | Moderate     | Moderate–High |
| AS Cone      | Higher       | Lower         |
| Eyeball Rank | Low          | Higher        |
| Host Rank    | Low–Moderate | Moderate      |


## Part 6 — Peering Options

### Option A — Direct Peering

* Private interconnection
* Higher cost
* Greater control

### Option B — IXP Peering

* Shared infrastructure
* Lower cost
* Access to multiple peers

### Questions

* Which option is technically feasible?
* Which is operationally simpler?



## Part 7 — Economic Evaluation

Estimate:

* IXP port costs
* Cross-connect costs
* Expected traffic volume
* Transit savings

### Questions

* Is peering cost-effective?
* Which IXP provides best value?



## Final Task — Recommendation

Prepare a short summary:

* Should ASN X peer with ASN Y?
* Where should peering occur?
* What are the expected benefits?
* What risks exist?



# Worked Example — AS10075 vs AS23729

## Scenario

ASN X: Regional ISP (Bangladesh)  
Target:

* AS10075 — Fiber@Home Ltd.
* AS23729 — Aamra Networks Ltd.



## Analysis

### AS10075

* Role: Infrastructure / transport provider
* Appears in transit paths
* Limited direct peering value

### AS23729

* Role: ISP / service provider
* Exchanges customer traffic
* More suitable peering target



## Routing Insight

* AS10075: traffic flows *through*
* AS23729: traffic flows *to/from*



## BGPQ4 Validation

```bash
bgpq4 -h whois.apnic.net -Jl AS10075
bgpq4 -h whois.apnic.net -Jl AS23729
```

Compare:

* prefix counts
* completeness



## Decision

|ASN|Recommendation|
|-|-|
|AS10075|Not a priority peering target|
|AS23729|Strong peering candidate|



## Final Recommendation

* Peer with AS23729 at a shared IXP
* Continue using AS10075 for transit where required



## Key Takeaways

* Not all large ASNs are good peering targets
* Infrastructure ≠ peering value
* Always validate organisation vs ASN
* Presence ≠ traffic exchange
* Peering is both technical and economic



## Optional Extension

* Compare two IXPs and select optimal location
* Evaluate multiple ASNs and prioritise peering
* Validate results using traceroute or looking glasses

