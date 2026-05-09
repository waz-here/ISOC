# Community IXP Development Workshop (Bangladesh)

## 3-Day Agenda

This 3-day workshop focuses on the design, deployment, and sustainable operation of a community Internet Exchange Point (IXP) in the Bangladesh context. It combines technical foundations with governance, compliance, and economic considerations, with a strong emphasis on practical outcomes.

---

## Workshop Outcomes

By the end of the workshop, participants will be able to:

* Explain the role of IXPs in improving Internet performance and resilience
* Evaluate economic and policy considerations for IXP sustainability
* Describe and implement peering models (private, bilateral, and multilateral via route servers)
* Configure peering at an IXP using both route servers and bilateral sessions
* Apply routing, filtering, and security best practices
* Use real-world data to make informed peering decisions

---

## Target Audience

* Internet Service Providers (ISPs)
* Network engineers and architects
* Data centre operators
* Regulators and policy-makers
* Content providers and network operators

---

## Prerequisites

* Familiarity with IP routing and basic BGP concepts
* Access to a lab environment (routers, VMs, or containers)
* SSH client and text editor for configuration exercises

We recommend the following free courses be completed before the workshop:

* Internet Exchange Point (IXP) 2.0 (Internet Society): https://www.internetsociety.org/learning/ixp-2-0/
* BGP for All (NSRC): https://learn.nsrc.org/bgp
* Routing Fundamentals (APNIC): https://academy.apnic.net/en/course/routing-fundamentals-course/
* Deploying BGP (APNIC): https://academy.apnic.net/en/virtual-labs?labId=69078

---

# Day 1 — Why IXPs and Peering Matter

| Time        | Session | Topic                                                                | Inst | Presentation      | Exercise                                                                                                                                     |
| ----------- | ------- | -------------------------------------------------------------------- | ---- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| 09:30–11:00 | 1.1     | Welcome and workshop overview <br> Bangladesh Internet landscape and interconnection challenges ([APNIC context](https://blog.apnic.net/2025/03/26/bridging-connectivity-and-collaboration-gaps-in-bangladesh/)) | WF  | [IXP Value and Benefits](files/02%20IXPRS_BP_Value-and-Benefits(PPT)_V01.pdf) <br> [Introduction to Peering](https://www.bgp4all.com/pfs/_media/workshops/06-peering_transit_network_design.pdf) | [Pulse IXP Tracker](https://pulse.internetsociety.org/en/ixp-tracker/country/BD/) <br>  [Country Report](https://pulse.internetsociety.org/en/reports/bd/) <br> [APNIC Resource Explorer](https://rex.apnic.net/overview?economy=BD) |
| 11:00–11:30 |         | Break   |      |                                                                                                                                                                                                                                                |                                                                                |
| 11:30–12:30 | 1.2     | Role and value of IXPs ([ISOC IXP Toolkit](https://www.internetsociety.org/resources/doc/2014/ixptoolkitguide/))                                                                                                 | RNB  | [Value of Peering (BGP4All)](https://www.bgp4all.com/pfs/_media/workshops/02-value-of-peering.pdf)   |  [IP Transit Pricing in 2025](https://resources.telegeography.com/ip-transit-price-erosion-significant-regional-differences-remain) <br> [Beyond the Megabits: The True Value of an Internet Exchange Platform](https://www.mdcdatacenters.com/company/blog/beyond-megabits-true-value-internet-exchange-platform/) <br> [Pricing for Efficient Traffic Exchange at IXPs](https://par.nsf.gov/servlets/purl/10483623)   | 
| 12:30–13:30 |         | Lunch   |      |                                                                                                                                                                                                                                                |                                                                                |
| 13:30–15:00 | 1.3     | Routing policy and peering                                                                                                                                                                                       | TBD  | [BGP Policy (NSRC)](https://nsrc.org/workshops/2026/nsrc-bknix-peeringixp/networking/bgp-deploy/en/presentations/BGP-Policy.pdf)                                                                                                               |                                                                                |
| 15:00–15:30 |         | Break   |      |                                                                                                                                                                                                                                                |                                                                                |
| 15:30–17:00 | 1.4     | Peering fundamentals ([BGP4All](https://www.bgp4all.com/pfs/workshops/start))        | RNB  |                                                                               | [IXP Peering Lab (APNIC)](https://academy.apnic.net/virtual-labs?labId=145487) |

**Day 1 Outcomes**

* Understand the Bangladesh interconnection environment
* Explain the economic and operational value of IXPs
* Describe transit vs peering trade-offs
* Understand basic routing policy concepts

**Other resources**
* https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/agenda.html

---

# Day 2 — How to Peer (Configuration and Decision-Making)

| Time        | Session | Topic                                                                | Inst | Presentation      | Exercise                                                                                                                                     |
| ----------- | ------- | -------------------------------------------------------------------- | ---- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| 09:00–11:00 | 2.1     | Building an IXP (stakeholders, trust, participation)                 | RNB  |        |    [IXP Manager Lab (APNIC)](https://academy.apnic.net/virtual-labs?labId=138784)  |
| 11:00–11:30 |         | Break                                                                |      |        |                                                                                    |
| 11:30–13:00 | 2.2     | Private peering                                                      | TBD  |        | [Address Plan](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/routing-security/en/labs/address-plan.html) <br> [Private Peering Lab (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/routing-security/en/labs/private.html) <br> [Configs](files/upto-04-ebgp-integrated.zip)                  |
| 13:00–14:00 |         | Lunch                                                                |      |        |                                                                                                                                                         |
| 14:00–15:30 | 2.3     | IXP peering                                                          | TBD  |        | [IXP Peering Lab (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/routing-security/en/labs/ixp.html)                           |
| 15:30–16:00 |         | Break                                                                |      |        |                                                                                                                                                         |
| 16:00–17:00 | 2.4     | Peering intelligence and decision making (tools + scenario exercise) | WF   | [BGPQ4 Introduction (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/bgp-deploy/en/presentations/BGPQ4-Introduction.pdf) | [BGPQ4 Lookup Examples](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/bgp-deploy/en/documents/BGPQ4-Introduction-whois-lookups.txt) |

### Session 2.4 References

* PeeringDB tutorial: https://tutorial.peeringdb.com/
* Internet Society Pulse (IXP Tracker): https://pulse.internetsociety.org/en/ixp-tracker/
* Cloudflare Radar: https://radar.cloudflare.com/
* bgproutes.io: https://www.bgproutes.io/
* Peercortex: https://peercortex.org/

**Day 2 Outcomes**

* Configure private and IXP-based peering sessions
* Apply routing and filtering best practices
* Use real-world data to evaluate peering opportunities
* Make informed peering decisions using operational tools

---

# Day 3 — Operating and Securing Peering Infrastructure 

**Note:** Friday schedule is adjusted to accommodate Friday prayer.

| Time        | Session | Topic                                                                                     | Inst   | Presentation                                                                                                                                        | Exercise                                                                              |
| ----------- | ------- | ----------------------------------------------------------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 09:00–11:00 | 3.1     | BGP best practices <br> Documentation and source of truth (NetBox, digital twin concepts) | WF     | [BGP Best Practices (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/bgp-deploy/en/presentations/BGP-BCP.pdf)              |                                                                                       |
| 11:00–11:30 |         | Break                                                                                     |        |                                                                                                                                                     |                                                                                       |
| 11:30–12:30 | 3.2     | Remote Triggered Blackhole (RTBH) filtering                                               | WF     | [RTBH Presentation (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/routing-security/en/presentations/RTBH.pdf)            | [RTBH Lab (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/routing-security/en/labs/RTBH-local.html) |
| 12:30–14:30 |         | Friday Prayer / Extended Break                                                            |        |                                                                                                                                                     |                                                                                       |
| 14:30–16:00 | 3.3     | BGP origin validation (RPKI)                                                              | WF     | [RPKI Theory (NSRC)](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/routing-security/en/presentations/BGP-Origin-Validation.pdf) | [RPKI Deployment Lab (APNIC)](https://academy.apnic.net/virtual-labs?labId=174499)    |
| 16:00–16:15 |         | Break                                                                                     |        |                                                                                                                                                     |                                                                       |
| 16:15–17:00 | 3.4     | Closing: roadmap and next steps                                                           | Discussion |           | [IXP Self-Assessment](https://ixpsa.internetsociety.org)  |

**Day 3 Outcomes**

* Understand operational and security requirements for peering environments
* Apply routing security techniques (RTBH, RPKI)
* Understand the importance of documentation and operational maturity
* Define next steps for IXP and peering deployment

---

## Attribution & Licensing

Some workshop material is by **Dr Philip Smith**, available via **BGP4All** under the
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International licence:
https://creativecommons.org/licenses/by-nc-nd/4.0/

Additional materials are sourced from NSRC, APNIC, and the Internet Society under their respective licences.

---

## Notes

Additional background reading:

* RFC 8212 — Default EBGP Route Propagation Behaviour: https://datatracker.ietf.org/doc/html/rfc8212
* RFC 7454 — BGP Operations and Security: https://datatracker.ietf.org/doc/html/rfc7454
* MANRS — Routing Security Best Practices: https://www.manrs.org/
* MANRS - IXP Guidelines: https://manrs.org/ixps/ixp-guide/
* BCP 38 — Ingress Filtering: https://datatracker.ietf.org/doc/html/bcp38
* APNIC IXP workshop - https://academy.apnic.net/en/events?id=a0B2e000000dID6EAM&cmdisplay=fullscreen
* BGP From Theory to Practice (ch1) - https://blog.lacnic.net/wp-content/uploads/2023/11/bgp-from-theory-to-practice-contents.pdf
