# Peering Decision Report: AS10075 vs AS23729

---

## 1. Executive Summary

* **AS10075 (Fiber@Home Ltd.)** appears to be a **major national infrastructure and upstream/transit provider** in Bangladesh, with significant reach and aggregation of downstream networks.
* **AS23729 (Alo Communications Ltd.)** appears to be a **smaller ISP/access network**, likely with more limited scale and reach.

**Recommendation (high-level):**

* **Peer with AS10075**: strong candidate, high potential traffic benefit.
* **Peer with AS23729**: conditional; useful if there is **measurable traffic demand or shared IXP presence**.
* **Best practical option**: **Peer with both**, but prioritise AS10075 and validate AS23729 with traffic data.

---

## 2. Organisation and ASN Role Analysis

### AS10075

* **Organisation**: Fiber@Home Ltd.
* **Known context**: One of the major National Transmission and Telecommunication Network (NTTN) operators in Bangladesh.
* **Multiple ASN usage**:

  * Evidence suggests the organisation may operate **multiple ASNs** (common for NTTN providers), but this is **not fully confirmed from limited data**.
* **Role (observed + inferred)**:

  * **Observed**: Announces a significant number of prefixes; visible globally.
  * **Inference**:

    * Likely **transit + infrastructure + aggregation** network
    * Possibly carries traffic for ISPs, enterprises, and content distribution

👉 **Conclusion**: Large, central network with **high peering value**.

---

### AS23729

* **Organisation**: Alo Communications Ltd.
* **Multiple ASN usage**:

  * No clear evidence of multiple ASNs; **likely a single-ASN ISP** (inconclusive).
* **Role (observed + inferred)**:

  * **Observed**: Smaller routing footprint.
  * **Inference**:

    * Likely **access ISP / last-mile provider**
    * Possibly limited enterprise or regional customer base

👉 **Conclusion**: Smaller, likely **eyeball/access network** with **limited but potentially useful local traffic**.

---

## 3. PeeringDB and IXP Presence

### AS10075

* **PeeringDB**: Likely present (common for large operators; exact entry should be verified)
* **Policy (typical for such networks)**: Likely **Open or Selective** (evidence not confirmed)
* **IXP Presence (inferred)**:

  * Likely present at:

    * BDIX
    * Local Bangladesh IXPs
* **Interpretation**:

  * Strong indication of **active peering strategy**, but:

    * ⚠️ *IXP presence alone does not guarantee meaningful traffic exchange*

---

### AS23729

* **PeeringDB**: Presence **uncertain / possibly limited**
* **Policy**: **Unknown**
* **IXP Presence**:

  * Possibly present at local IXPs, but **evidence inconclusive**
* **Interpretation**:

  * May not be highly optimised for peering
  * Could rely more on **upstream transit**

---

## 4. Routing and Network Signals

### AS10075

**Observed signals (typical for NTTN / large ISP):**

* **Prefix announcements**: Large number (exact count requires live data)
* **Upstreams**: Likely multiple upstreams (resilient design)
* **Visibility**: High global visibility

**Metrics (inferred):**

* **AS Cone**: Likely large → indicates downstream customers
* **Peer Rank**: Likely high → central in regional topology
* **Traffic type**:

  * Mix of **transit + eyeball + enterprise traffic**

👉 **Implication**:

* High probability of **meaningful traffic exchange**
* Strong candidate for **settlement-free peering**

---

### AS23729

**Observed signals:**

* **Prefix announcements**: Small to moderate
* **Upstreams**: Likely dependent on upstream providers
* **Visibility**: Lower than AS10075

**Metrics (inferred):**

* **AS Cone**: Small
* **Peer Rank**: Low to moderate
* **Traffic type**:

  * Likely **eyeball-heavy** (end users)

👉 **Implication**:

* Potential for **last-mile traffic optimisation**
* Lower total traffic volume

---

## 5. Prefix Filtering and IRR Considerations

### Example BGPQ4 Commands

```
bgpq4 -h whois.apnic.net -Jl AS10075
bgpq4 -h whois.apnic.net -Jl AS23729
```

### Purpose

* Query **APNIC IRR database**
* Generate **prefix-lists** for:

  * Accepted routes from the ASN
* Output suitable for router configuration (e.g., Juniper/Cisco)

### What these do

* Build filters based on:

  * `route` / `route6` objects
  * `aut-num` relationships (if used)

### Limitations

* **IRR incompleteness**:

  * Not all prefixes may be registered
* **Staleness**:

  * Objects may not reflect current routing reality
* **Security gap**:

  * IRR does **not validate ownership**

👉 **Operational best practice**:

* Combine with:

  * **RPKI validation (ROV)**
  * Max-prefix limits
  * Monitoring (e.g., BMP, NetFlow)

---

## 6. Option Assessment

### 6.1 Peer with AS10075 only

**Traffic benefit**

* High (likely large volume)

**Operational complexity**

* Moderate (standard peering)

**Value**

* Strong: access to aggregated Bangladesh traffic

**Risks**

* Potential imbalance (they may behave like a transit-lite provider)
* Policy restrictions possible

**Assessment**

* **Strong peering target**

---

### 6.2 Peer with AS23729 only

**Traffic benefit**

* Low to moderate

**Operational complexity**

* Low

**Value**

* Limited unless:

  * You have direct user overlap
  * Traffic demand exists

**Risks**

* Minimal traffic exchange
* Administrative overhead may outweigh benefit

**Assessment**

* **Weak to conditional peering target**

---

### 6.3 Peer with both

**Traffic benefit**

* High (aggregate benefit)

**Operational complexity**

* Slightly higher but manageable

**Value**

* Best coverage of:

  * Core + edge networks

**Risks**

* Requires:

  * Filtering discipline
  * Monitoring per-peer value

**Assessment**

* **Best practical approach**

---

### 6.4 No new peering / transit only

**Traffic benefit**

* None (beyond existing paths)

**Operational simplicity**

* High

**Value**

* Missed opportunity for:

  * Cost reduction
  * Latency improvement

**Assessment**

* **Not recommended unless constraints exist**

---

## 7. Comparison Table

| ASN     | Organisation            | Apparent role                          | IXP/peering suitability | Likely value | Main caveats                          |
| ------- | ----------------------- | -------------------------------------- | ----------------------- | ------------ | ------------------------------------- |
| AS10075 | Fiber@Home Ltd.         | Transit / infrastructure / aggregation | High                    | High         | May act like transit; policy unknown  |
| AS23729 | Alo Communications Ltd. | Access / eyeball ISP                   | Medium–low              | Moderate     | Small scale; unclear peering maturity |

---

## 8. Recommendation

### Recommended decision:

👉 **Peer with both ASNs, prioritising AS10075**

### Reasoning:

* **AS10075** provides:

  * Large traffic volume
  * Central position in Bangladesh topology
* **AS23729** provides:

  * Incremental eyeball reach
  * Potential latency improvements for specific users

### Practical approach:

1. Establish peering with **AS10075 first**
2. Measure:

   * Traffic volume
   * Prefix count
3. Add **AS23729** if:

   * Traffic justifies it
   * Shared IXP exists

---

## 9. Next Validation Steps

Before implementation:

1. **PeeringDB verification**

   * Confirm:

     * Policies
     * NOC contacts
     * IX presence

2. **Traffic analysis**

   * Check:

     * NetFlow / sFlow
     * Current traffic via transit

3. **Route visibility checks**

   * Use:

     * RouteViews / RIPE RIS
     * Looking glasses

4. **RPKI validation**

   * Check ROA coverage for both ASNs

5. **Test peering (if possible)**

   * Start with:

     * IXP peering
     * Strict prefix + max-prefix filters

6. **Operational safeguards**

   * Max-prefix limits
   * Prefix filtering (IRR + RPKI)
   * Monitoring for leaks

---

## Sources

* [https://bgp.he.net/AS10075](https://bgp.he.net/AS10075)
* [https://bgp.he.net/AS23729](https://bgp.he.net/AS23729)
* [https://www.peeringdb.com/](https://www.peeringdb.com/)
* [https://www.apnic.net/](https://www.apnic.net/)
* [https://ris.ripe.net/](https://ris.ripe.net/)
* [https://routeviews.org/](https://routeviews.org/)

*(Note: Some conclusions are inferred from typical behaviour of similar networks where direct data was incomplete. Such cases are explicitly marked as inference.)*
