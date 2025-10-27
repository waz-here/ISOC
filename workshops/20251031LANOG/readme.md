# Peering & IXP Workshop (3-Day Version)

> **Original outline source:** https://nsrc.org/activities/outlines/peering-ixp-en  
> **Note:** Based on NSRC’s detailed 3-day agenda for the Peering & IXP Workshop (see: NSRC agenda page). :contentReference[oaicite:1]{index=1}

## Overview

This workshop is a condensed 3-day intensive course covering the fundamentals of BGP, peering models, traffic engineering, and Internet Exchange Point (IXP) operations. It is designed for network engineers, IXP operators and policy/technical staff needing a practical understanding of peering and route policy.

## Objectives / Learning Outcomes

By the end of this 3-day workshop participants will be able to:

- Describe peering models (private peering, bi-lateral at IXPs, multilateral via route servers) and associated trade-offs.
- Set up peering at an IXP (via a route server and bilateral).
- Implement BGP policy (local-preference, MED, communities) to shape traffic flows.
- Design and evaluate multihoming and transit scenarios.
- Apply operational best practice for peering and IXP participation.

## Prerequisites

- Familiarity with IP routing and previous experience using BGP (i.e., not a complete introduction).
- Terminal/SSH client access, text editor, and a lab environment with router VMs or containers.
- Comfortable working hands-on with router configurations.

## Workshop Format & Schedule

Each day is structured into four sessions (~1.5 hr each) plus breaks, using the NSRC format. :contentReference[oaicite:2]{index=2}  
Below is the day-by-day breakdown for the 3-day version:

### Day 1 — Foundations & BGP Scale  
- Session 1.1: Introduction to the Peering & IXP Workshop  
- Session 1.2: Lab Setup (Topology, Addressing)  
- Session 1.3: IS-IS Introduction & Lab  
- Session 1.4: BGP Introduction, Scaling BGP  
- Break & Wrap up  

### Day 2 — Policy, Multihoming & Transit  
- Session 2.1: BGP Attributes & Policy  
- Session 2.2: eBGP with Transit (Lab)  
- Session 2.3: Multihoming Introduction + Inbound Traffic Engineering  
- Session 2.4: Private Peering (Lab)  
- Break & Wrap up  

### Day 3 — Peering, IXPs & Best Practice  
- Session 3.1: IXP Peering (Lab)  
- Session 3.2: Peering Policies (Lab)  
- Session 3.3: Value of Peering (Presentation)  
- Session 3.4: IXP Bilateral Peering (Lab) + BGP Communities  
- Session 3.5: BGP Best Practices & Closing  
- Wrap up and Certification  

## Labs (Key exercises)

- **Lab Setup** – Initial configuration of lab topology, routers, addressing plan. :contentReference[oaicite:3]{index=3}  
- **eBGP with Transit Lab** – Using transit provider connection and configuring eBGP. :contentReference[oaicite:4]{index=4}  
- **Private Peering Lab** – Direct peering between ASes. :contentReference[oaicite:5]{index=5}  
- **IXP Peering Lab** – Introduce an IXP route-server, eBGP with RS. :contentReference[oaicite:6]{index=6}  
- **Peering Policy Lab** – Apply filtering and policy in IXP context. :contentReference[oaicite:7]{index=7}  
- **IXP Bilateral Peering Lab** – Bilateral peerings beyond route server. :contentReference[oaicite:8]{index=8}  

## Slides & Reference Materials

Participants should use the NSRC slide decks and lab documents alongside this outline. Example topics:  
- “Value of Peering” presentation.  
- “BGP Communities” presentation.  
- RFC 8212, RFC 7454, MANRS best practice guide. :contentReference[oaicite:9]{index=9}  

## Attribution & Licensing

Some of the workshop material is by **Dr Philip Smith** (available at BGP4ALL) under **Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)**. Full terms at https://creativecommons.org/licenses/by-nc-nd/4.0/.

Where indicated, NSRC workshop materials are used under their own Creative Commons licences.

## How to Use This Outline

1. Fork or clone this repository into your training workspace.  
2. Map each session block to your local copies of slide decks & lab guides.  
3. Adjust timing or emphasis depending on your audience (e.g., technical vs policy).  
4. Prepare lab environment ahead of session (routers, VMs, connectivity).  
5. Encourage interactive, group-based tasks during labs for best outcomes.

## Provenance

- NSRC detailed agenda for the 3-day version: “Peering & IXP Workshop – 3 day: Agenda”. :contentReference[oaicite:11]{index=11}  
- NSRC list of workshop outlines. :contentReference[oaicite:12]{index=12}  
- Lab setup documentation. :contentReference[oaicite:13]{index=13}  

---

If you like, I can format this outline for Markdown including a table of sessions with timeslots, and generate a printable PDF. Would you like me to do that?
::contentReference[oaicite:14]{index=14}
