# Lab 2.5a Prompt Engineering for Peering Intelligence and Decision Making

The trick is to design the prompt so ChatGPT does **three different jobs well**:

1. gather evidence from the right sources
2. analyse the evidence consistently
3. produce a decision report that is useful to an operator, not just a summary dump

If you do not constrain those three parts, the output will often sound polished but be weak on method, inconsistent in judgement, and too trusting of incomplete routing data.

Below is a strong prompt you can use, followed by an honest evaluation of where it will work well and where it can still fail.

---

## Draft prompt for ChatGPT

```text
You are an experienced Internet routing and peering analyst assisting a Network Operator Group workshop.

Your task is to analyse whether a Bangladesh ISP should peer with:
- AS10075 (Fiber@Home Ltd.)
- AS23729 (Alo Communications Ltd.)
- or both

The goal is to produce a structured peering decision report suitable for network operators and technical managers.

Important operating rules:

1. Use a data-driven approach.
2. Do not assume that an organisation operates only one ASN.
3. Explicitly distinguish between:
   - organisation
   - ASN
   - role of the ASN (for example transit, access, infrastructure, hosting, content, enterprise)
4. Do not treat IXP presence as proof that meaningful peering will occur.
5. Do not treat IRR data as complete or authoritative without qualification.
6. For prefix filtering examples, prefer APNIC Whois, not RADB.
7. If evidence is incomplete or ambiguous, say so clearly.
8. Prefer practical operator reasoning over generic explanation.

Your report must evaluate the following questions:

A. Identity and role
- What organisation does each ASN belong to?
- Does the organisation appear to operate multiple ASNs?
- What role does each ASN appear to play in the network ecosystem?

B. Peering policy and discoverability
- Is the ASN listed in PeeringDB?
- What peering policy is shown?
- Which IXPs is it present at?
- Are there signs that the ASN is intended for peering, transit, infrastructure, or another purpose?

C. Routing and topology signals
- What do public routing views suggest about:
  - announced prefixes
  - upstreams
  - visibility
  - scale
- If available, comment on:
  - Peer Rank
  - AS Cone
  - Eyeball characteristics
  - Host/content characteristics
- Explain what these signals imply, but do not overstate certainty.

D. Filtering and routing hygiene
- Show example BGPQ4 commands using APNIC Whois for both ASNs:
  - bgpq4 -h whois.apnic.net -Jl AS10075
  - bgpq4 -h whois.apnic.net -Jl AS23729
- Explain what the commands are intended to do.
- State the limitations of using IRR-derived filters alone.

E. Peering decision analysis
Assess each of these options:
1. Peer with AS10075 only
2. Peer with AS23729 only
3. Peer with both
4. Use transit only / no new peering

For each option, evaluate:
- likely traffic benefit
- likely operational simplicity or complexity
- expected value for a Bangladesh ISP
- possible risks or limitations
- whether the ASN seems to be a strong, weak, or conditional peering target

F. Final recommendation
Provide:
- a short executive summary
- a comparison table
- a recommended decision
- the reasoning behind that decision
- any caveats
- suggested next validation steps before implementation

Required report format:

# Peering Decision Report: AS10075 vs AS23729

## 1. Executive Summary

## 2. Organisation and ASN Role Analysis

## 3. PeeringDB and IXP Presence

## 4. Routing and Network Signals

## 5. Prefix Filtering and IRR Considerations

## 6. Option Assessment

### 6.1 Peer with AS10075 only
### 6.2 Peer with AS23729 only
### 6.3 Peer with both
### 6.4 No new peering / transit only

## 7. Comparison Table

The table must include:
- ASN
- Organisation
- Apparent role
- IXP/peering suitability
- Likely value
- Main caveats

## 8. Recommendation

## 9. Next Validation Steps

Additional requirements:
- Write in clear operator-friendly language
- Avoid marketing language
- Do not invent facts
- Where evidence is weak, state “evidence inconclusive”
- Separate observed facts from inference
- If you infer something, label it as an inference
- Include source URLs used in the report
```

---

## Stronger version for repeated lab use

If you want to make this reusable for other ASN pairs, use this version instead:

```text
You are an experienced Internet routing and peering analyst assisting a Network Operator Group workshop.

Analyse whether a Bangladesh ISP should peer with the following ASNs:

- Candidate ASN 1: {{ASN1}}
- Candidate ASN 2: {{ASN2}}

Optional organisation labels:
- Candidate 1 organisation: {{ORG1}}
- Candidate 2 organisation: {{ORG2}}

Produce a structured peering decision report comparing:
- peering with ASN 1 only
- peering with ASN 2 only
- peering with both
- no new peering

Use the same operating rules and report structure as defined below:

[insert the full rules and required structure from the main prompt here]
```

That gives you a template you can reuse for Cloudflare vs Google, Summit vs another ISP, and so on.

---

## Why this prompt is effective

This prompt is strong because it forces the model to avoid the usual failure modes.

First, it separates **fact gathering** from **judgement**. That matters because a weaker prompt often jumps straight to “peer with both” without actually examining role, policy, or value.

Second, it explicitly tells the model not to confuse **organisation** with **ASN**. That is especially important in Bangladesh and in operator environments generally, because one company may have multiple ASNs serving very different purposes.

Third, it makes the model evaluate **four options**, not just the obvious two. That improves the quality of the recommendation because “peer with both” and “do nothing new” are both realistic outcomes.

Fourth, it forces the model to include **limitations and caveats**. That is important for anything based on PeeringDB, public BGP views, and IRR data, because those sources are useful but incomplete. PeeringDB: [https://www.peeringdb.com/](https://www.peeringdb.com/) ; APNIC Whois: [https://wq.apnic.net/static/search.html](https://wq.apnic.net/static/search.html) ; Internet Society Pulse IXP Tracker: [https://pulse.internetsociety.org/en/ixp-tracker/](https://pulse.internetsociety.org/en/ixp-tracker/) ; bgp.tools rankings: [https://bgp.tools/](https://bgp.tools/)

---

## Where this prompt will still be weak

It will not fully automate the process in the way a script or API workflow would.

An LLM can compare public evidence and write a good report, but it cannot guarantee:

* live, complete, or consistent routing observations
* the actual traffic volume between your network and those ASNs
* whether a session would be accepted operationally
* whether the peering would materially reduce your transit bill

Those last points usually require:

* your own NetFlow/sFlow/IPFIX or traffic data
* your IXP membership costs
* direct policy confirmation from the target network
* sometimes live testing or bilateral discussion

So the prompt is very good for a **preliminary decision report**, but not enough by itself for a production peering decision.

---

## How to improve the prompt further

The most useful upgrade is to make the model score each candidate against a rubric.

For example, add this block:

```text
Score each ASN from 1 to 5 for:
- Peering suitability
- Likely traffic value
- Operational simplicity
- Confidence in available evidence

Explain each score in one sentence.
```

That helps reduce vague conclusions.

A second good upgrade is to force a final decision style:

```text
At the end, choose one of the following:
- Recommend peering with AS10075
- Recommend peering with AS23729
- Recommend peering with both
- Recommend further validation before any peering decision

Do not avoid choosing unless the evidence is clearly insufficient.
```

That stops the model from hedging too much.

A third upgrade, if you want a more operational output, is to add:

```text
Include a final section called “Operator Action Plan” with:
- immediate checks
- data to collect internally
- external confirmation steps
- implementation prerequisites
```

That makes the report more actionable.

# Other resources
[https://github.com/f/prompts.chat?tab=readme-ov-file](https://github.com/f/prompts.chat?tab=readme-ov-file)

---
