# Peering & IXP Workshop (3-Day Version)

> **Original outline source:** [NSRC Peering & IXP Workshop Outline](https://nsrc.org/activities/outlines/peering-ixp-en)  
> **Note:** Adapted from the [NSRC 5-Day Peering & IXP Workshop Agenda](https://nsrc.org/activities/agendas/en/Peering%20%26%20IXP%20Workshop%20-%203%20day/)

---

## Overview

This workshop is a condensed **3-day intensive course** covering the fundamentals of BGP, peering models, traffic engineering, and Internet Exchange Point (IXP) operations.  
It is designed for **network engineers, IXP operators, and policy/technical staff** needing a practical understanding of peering and route policy.

---

## Learning Outcomes

By the end of this 3-day workshop participants will be able to:

- Describe peering models (private, bilateral, and multilateral via route servers) and their trade-offs.
- Configure peering at an IXP using both route servers and bilateral sessions.
- Apply BGP policy (local-preference, MED, and communities) to influence routing.
- Design and evaluate multihoming and transit strategies.
- Implement operational best practices for stable BGP and IXP participation.

---

## Prerequisites

- Familiarity with IP routing and basic BGP concepts.  
- Access to a lab environment (routers, VMs, or containers).  
- SSH client and text editor for configuration exercises.
- We recommend the following Academy courses be completed before the start of the tutorial:
  
* Internet Exchange Point (IXP) 2.0 (Internet Society): [https://www.internetsociety.org/learning/ixp-2-0/](https://www.internetsociety.org/learning/ixp-2-0/)
* Routing Fundamentals (APNIC): [https://academy.apnic.net/en/course/routing-fundamentals-course/](https://academy.apnic.net/en/course/routing-fundamentals-course/)
* Deploying BGP (APNIC): [https://academy.apnic.net/en/virtual-labs?labId=69078](https://academy.apnic.net/en/virtual-labs?labId=69078)


---

## Workshop Format & Schedule

Each day is divided into four 90-minute sessions with breaks between.  
The schedule below follows the NSRC 3-day agenda structure.

### **Day 1 — Foundations & BGP Scale**
- Introduction to the Peering & IXP Workshop  
- Lab Setup (Topology & Addressing)  
- IS-IS Introduction & Lab  
- BGP Introduction & Scaling BGP  
- **Wrap-Up Discussion**

### **Day 2 — Policy, Multihoming & Transit**
- BGP Attributes & Policy  
- eBGP with Transit (Lab)  
- Multihoming Concepts & Inbound Traffic Engineering  
- Private Peering (Lab)  
- **Wrap-Up Discussion**

### **Day 3 — Peering, IXPs & Best Practice**
- IXP Peering (Lab)  
- Peering Policy (Lab)  
- The Value of Peering (Presentation)  
- IXP Bilateral Peering (Lab)  
- BGP Communities & Best Practices  
- **Closing Session**

---

## Lab Exercises

The following labs accompany the sessions. All material is publicly available on the NSRC website.

- [Lab Setup](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/setup.html)  
  _Initial lab environment and addressing configuration._
- [eBGP with Transit](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/ebgp-transit.html)  
  _Using an upstream provider and basic transit policies._
- [Private Peering](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/private-peering.html)  
  _Direct interconnection between two ASNs._
- [IXP Peering](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/ixp.html)  
  _Connecting and peering via an Internet Exchange Point._
- [Peering Policy](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/peering-policy.html)  
  _Applying local-preference, MED, and filtering at the IXP._
- [IXP Bilateral Peering](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/ixp-bilateral.html)  
  _Establishing direct bilateral peerings in addition to route-server sessions._

---

## Slide Decks & References

Recommended NSRC slide decks to pair with this outline:

- [The Value of Peering](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/slides/value-of-peering.pdf)  
- [BGP Communities](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/slides/bgp-communities.pdf)  
- [BGP Best Practices](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/slides/bgp-best-practices.pdf)

Additional background reading:
- [RFC 8212 — Default EBGP Route Propagation Behaviour](https://datatracker.ietf.org/doc/html/rfc8212)  
- [RFC 7454 — BGP Operations and Security](https://datatracker.ietf.org/doc/html/rfc7454)  
- [MANRS — Routing Security Best Practices](https://www.manrs.org/)  
- [BCP 38 — Ingress Filtering](https://datatracker.ietf.org/doc/html/bcp38)

---

## Attribution & Licensing

Some of the workshop material is by **Dr Philip Smith**, available at **[BGP4ALL](https://bgp4all.com/)** under a  
**Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)** licence.  
Full terms at [https://creativecommons.org/licenses/by-nc-nd/4.0/](https://creativecommons.org/licenses/by-nc-nd/4.0/).

Where referenced, NSRC workshop materials are licensed under their own Creative Commons terms.

---

## How to Use This Outline

1. Clone or fork this repository into your training workspace.  
2. Link each session to your local copies of slides and lab guides.  
3. Adjust time allocation and examples for your audience (technical vs. policy).  
4. Prepare router or container lab infrastructure in advance.  
5. Encourage collaboration and discussion during the labs.

---

## Provenance

- [NSRC Workshop Outline](https://nsrc.org/activities/outlines/peering-ixp-en)  
- [NSRC 3-Day Agenda](https://nsrc.org/activities/agendas/en/Peering%20%26%20IXP%20Workshop%20-%203%20day/)  
- [NSRC Workshop Labs](https://nsrc.org/workshops/2022/rwnog/peering-ixp/networking/peering-ixp/en/labs/)

---
