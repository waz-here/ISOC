# Community IXP Development Workshop (Bangladesh)
## 3-Day Agenda

This 3-day workshop focuses on the design, deployment, and sustainable operation of a community Internet Exchange Point (IXP) in the Bangladesh context. It combines technical foundations with governance, compliance, and economic considerations, with a strong emphasis on practical outcomes.

## Workshop Outcomes

By the end of the workshop, participants will be able to:

- Explain the role of IXPs in improving Internet performance and resilience  
- Evaluate economic and policy considerations for IXP sustainability  
  <!-- Design a neutral and scalable IXP architecture  -->
- Describe peering models (private, bilateral, and multilateral via route servers) and their trade-offs.
- Configure peering at an IXP using both route servers and bilateral sessions.
- Apply routing, filtering, and security best practices  
<!-- Develop a roadmap for establishing or improving an IXP in Bangladesh  -->

---

## Target Audience

- Internet Service Providers (ISPs)  
- Network engineers and architects  
- Data centre operators  
- Regulators and policy makers  
- Content providers and network operators  

---

## Prerequisites

- Familiarity with IP routing and basic BGP concepts.  
- Access to a lab environment (routers, VMs, or containers).  
- SSH client and text editor for configuration exercises.

We recommend the following free courses be completed before the start of the tutorial:
  
- Internet Exchange Point (IXP) 2.0 (Internet Society): [https://www.internetsociety.org/learning/ixp-2-0/](https://www.internetsociety.org/learning/ixp-2-0/)
- BGP for All (NSRC): [https://learn.nsrc.org/bgp](https://learn.nsrc.org/bgp)
- Routing Fundamentals (APNIC): [https://academy.apnic.net/en/course/routing-fundamentals-course/](https://academy.apnic.net/en/course/routing-fundamentals-course/)
- Deploying BGP (APNIC): [https://academy.apnic.net/en/virtual-labs?labId=69078](https://academy.apnic.net/en/virtual-labs?labId=69078)

___

## Day 1 — Context, Economics, and Community

| Time        | Session | Topic | Inst | Presentation | Exercise |
|------------|--------|-------|--------|--------|--------|
| 09:30–11:00 | 1.1 | Welcome and workshop overview <br> Bangladesh Internet landscape and interconnection challenges ([APNIC context](https://blog.apnic.net/2025/03/26/bridging-connectivity-and-collaboration-gaps-in-bangladesh/))| TBD | <br> [Internet eXchange Point (IXP)](https://apnic.foundation/wp-content/uploads/2025/09/Warren-IXPRS_BP_Value-and-BenefitsPPT_V01.pdf) <br> [Intro to peering](https://www.bgp4all.com/pfs/_media/workshops/06-peering_transit_network_design.pdf) | |
| 11:00–11:30 |        | Break |        | | |
| 11:30–13:00 | 1.2 | Role and value of IXPs ([ISOC IXP Toolkit](https://www.internetsociety.org/resources/doc/2014/ixptoolkitguide/)) | TBD | [Value of Peering](https://www.bgp4all.com/pfs/_media/workshops/02-value-of-peering.pdf) | |
| 13:00–14:00 |        | Lunch |        | | |
| 14:00–15:30 | 1.3 | Economics of peering and IXPs (cost models, transit vs peering) | TBD | Presentation + Exercise | |
| 15:30–16:00 |        | Break |        | | |
| 16:00–17:00 | 1.4 | Building a community IXP (stakeholders, trust, participation) <br> Peering fundamentals ([BGP4All](https://www.bgp4all.com/pfs/workshops/start)) | TBD | Presentation | |

**Day 1 Outcomes**
- Understand the Bangladesh interconnection environment  
- Explain the economic and operational value of IXPs  
- Identify key stakeholders and community-building approaches  

---

## Day 2 — Governance, Compliance, and Technical Design

| Time        | Session | Topic | Format |
|------------|--------|-------|--------|
| 09:30–11:00 | 2.1   | Routing policy and peering ([NSRC BGP training](https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/bgp-deploy/en/)) | Presentation + Lab |
| 11:00–11:30 |        | Break |        |
| 11:30–13:00 | 2.2 | IXP governance models (non-profit, cooperative, neutral operations) <br> Compliance and regulatory considerations (Bangladesh context) | Presentation + Discussion |
| 13:00–14:00 |        | Lunch |        |
| 14:00–15:30 | 2.3 | Technical design of an IXP ([NSRC IXP Design](https://nsrc.org/workshops/2026/nsrc-bknix-peeringixp/)) | Presentation |
| 15:30–16:00 |        | Break |        |
| 16:00–17:00 | 2.4 | Peering intelligence and decision making (tools + scenario exercise) | Demo + Lab |

### Session 2.5 References
- PeeringDB tutorial: https://tutorial.peeringdb.com/  
- BGPQ4 intro: https://nsrc.org/workshops/2026/nsrc-nznog2026-adv-bgp/networking/bgp-deploy/en/documents/BGPQ4-Introduction-whois-lookups.txt  
- Internet Society Pulse (IXP Tracker): https://pulse.internetsociety.org/en/ixp-tracker/  
- Cloudflare Radar: https://radar.cloudflare.com/  
- bgproutes.io: https://www.bgproutes.io/  
- Peercortex: https://peercortex.org/  

**Day 2 Outcomes**
- Understand governance and policy structures for IXPs  
- Identify compliance considerations in Bangladesh  
- Design a technically sound and neutral IXP architecture  
- Apply routing and security best practices  
- Use real-world data to make informed peering decisions  

---

## Day 3 — Operations, Documentation, and Next Steps (Friday)

**Note:** Friday schedule is adjusted to accommodate Jumu’ah (Friday prayer). Critical sessions are scheduled in the morning, with interactive content in the afternoon.

| Time        | Session | Topic | Format |
|------------|--------|-------|--------|
| 09:30–11:00 | 3.1 | Documentation and source of truth (NetBox, digital twin concepts) | Presentation |
| 11:00–11:30 |        | Break |        |
| 11:30–12:00 | 3.2 | Minimum viable IXP operations | Presentation + Demo |
| 12:00–14:30 |        | Friday Prayer / Extended Break |        |
| 14:30–16:00 | 3.3 | Group exercise: Design a Bangladesh community IXP | Workshop |
| 16:00–16:15 |        | Break |        |
| 16:15–17:00 | 3.4 | Group presentations and feedback <br> Closing: Roadmap and next steps  | Discussion |

**Day 3 Outcomes**
- Define operational requirements for a new IXP  
- Understand the importance of documentation and operational maturity  
- Develop a practical IXP deployment plan  
- Agree on actionable next steps for participants  

---

## Attribution & Licensing

Some of the workshop material is by **Dr Philip Smith**, available at **[BGP4ALL](https://bgp4all.com/)** under a  
**Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)** licence.  
Full terms at [https://creativecommons.org/licenses/by-nc-nd/4.0/](https://creativecommons.org/licenses/by-nc-nd/4.0/).

Where referenced, workshop materials are licensed under their own Creative Commons terms.
- Training material draws from open resources including NSRC, BGP4All, and Internet Society 

---

## Notes
Additional background reading:
- [RFC 8212 — Default EBGP Route Propagation Behaviour](https://datatracker.ietf.org/doc/html/rfc8212)  
- [RFC 7454 — BGP Operations and Security](https://datatracker.ietf.org/doc/html/rfc7454)  
- [MANRS — Routing Security Best Practices](https://www.manrs.org/)  
- [BCP 38 — Ingress Filtering](https://datatracker.ietf.org/doc/html/bcp38)

 
