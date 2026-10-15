# Investigating an IXP or potential peer from Ubuntu 24.04

A reproducible command-line guide using the Papua New Guinea Internet Exchange Point (PNG-IXP) as an example. We use **PeeringDB** for interconnection directory information, **APNIC WHOIS** for current address registration, and **APNIC Whowas** (historical Registration Data Access Protocol, or RDAP) for historical registration changes.

**Important:** Registration and directory entries do not prove that an Internet Exchange Point (IXP) is operational or exchanging traffic.

## 1. Install tools

```bash
sudo apt update
sudo apt install -y curl jq whois util-linux ca-certificates
```

All commands below stream results to the terminal. No JSON files or API credentials are required.

## 2. Look up the exchange in PeeringDB

PNG-IXP has [PeeringDB exchange ID 2332](https://www.peeringdb.com/ix/2332). The PeeringDB API exposes structured records:

```bash
curl -fsSL 'https://www.peeringdb.com/api/ix/2332' |
  jq '.data[] | {id, name, name_long, city, country, website, updated}'
```

Check the complete record if any field is absent:

```bash
curl -fsSL 'https://www.peeringdb.com/api/ix/2332' | jq '.data[]'
```

An exchange can have one or more peering LAN objects. Discover their IDs:

```bash
curl -fsSL 'https://www.peeringdb.com/api/ixlan?ix_id=2332' |
  jq '.data[] | {id, ix_id, name, updated}'
```

Replace `REPLACE_WITH_IXLAN_ID` with an ID returned above:

```bash
IXLAN_ID='REPLACE_WITH_IXLAN_ID'

# Peering LAN prefixes
curl -fsSL "https://www.peeringdb.com/api/ixpfx?ixlan_id=${IXLAN_ID}" |
  jq '.data[] | {prefix, protocol, in_dfz, updated}'

# Networks listed on that peering LAN
curl -fsSL "https://www.peeringdb.com/api/netixlan?ixlan_id=${IXLAN_ID}" |
  jq -r '.data[] | [.asn, .name, (.ipaddr4 // "-"), (.ipaddr6 // "-")] | @tsv' |
  column -t -s "$(printf '\t')"
```

PeeringDB records are supplied and maintained by participants. Check update dates and API pagination (`meta`) for larger datasets. Listed networks are not necessarily currently exchanging traffic.

The PNG-IXP peering LAN prefix investigated here is **`103.82.247.0/24`**.

## 3. Query current APNIC WHOIS

```bash
whois -h whois.apnic.net 103.82.247.0
```

Filter for useful fields:

```bash
whois -h whois.apnic.net 103.82.247.0 |
  grep -iE '^(inetnum|netname|descr|org|status|mnt-by|last-modified|origin|route):'
```

During our investigation this returned the broad parent range `103.0.0.0 - 103.255.255.255`. **A parent range is not evidence of a specific `/24` registration.** Ask for an exact match:

```bash
whois -h whois.apnic.net -- '-x 103.82.247.0/24'
```

Observed response:

```text
%ERROR:101: no entries found
```

This means no exact object was returned by that query, not that PNG-IXP necessarily stopped operating.

## 4. Query historical APNIC RDAP (Whowas)

Historical endpoint: https://rdap.apnic.net/history/ip/103.82.247.0/24

Inspect the structure and record count:

```bash
curl -fsSL 'https://rdap.apnic.net/history/ip/103.82.247.0/24' |
  jq '{keys: keys, record_count: (.records | length)}'
```

Our investigation found **34 records**, including broader APNIC and Internet Assigned Numbers Authority (IANA) records. To see only historical versions of the specific PNG-IXP range:

```bash
curl -fsSL 'https://rdap.apnic.net/history/ip/103.82.247.0/24' |
jq -r '
  .records |
  sort_by(.applicableFrom)[] |
  select(.content.handle == "103.82.247.0 - 103.82.247.255") |
  [
    .applicableFrom,
    (.applicableUntil // "CURRENT"),
    (.content.name // "DELETED"),
    (.content.type // "N/A")
  ] | @tsv
' | column -t -s "$(printf '\t')"
```

The records show a specific `NICTA-PG` registration from **9 January 2017**, with assignment type `ASSIGNED PORTABLE`.

### Find the deletion event

```bash
curl -fsSL 'https://rdap.apnic.net/history/ip/103.82.247.0/24' |
jq -r '
  .records[] |
  select(.content.handle == "103.82.247.0 - 103.82.247.255") |
  select(any(.content.remarks[]?; .title == "deleted")) |
  "Prefix: \(.content.handle)",
  "Deleted: \(.applicableFrom)",
  (.content.remarks[] | select(.title == "deleted") | .description[])
'
```

Observed output:

```text
Prefix: 103.82.247.0 - 103.82.247.255
Deleted: 2025-06-22T22:36:27Z
This object has been deleted
```

**Interpretation:** APNIC's historical RDAP explicitly records the deletion of the **registration object** on **22 June 2025 at 22:36:27 UTC**. It does not establish the reason for deletion or whether the IXP was operational at that time.

### Show the final named registration before deletion

```bash
curl -fsSL 'https://rdap.apnic.net/history/ip/103.82.247.0/24' |
jq -r '
  [
    .records[] |
    select(.content.handle == "103.82.247.0 - 103.82.247.255"
           and .content.name == "NICTA-PG")
  ] |
  sort_by(.applicableFrom) | last |
  "Version from: \(.applicableFrom)",
  "Version until: \(.applicableUntil)",
  "Network name: \(.content.name)",
  "Address range: \(.content.handle)",
  "Assignment type: \(.content.type)",
  "Status: \((.content.status // []) | join(", "))"
'
```

Observed output:

```text
Version from: 2023-09-05T02:17:08Z
Version until: 2025-06-22T22:36:27Z
Network name: NICTA-PG
Address range: 103.82.247.0 - 103.82.247.255
Assignment type: ASSIGNED PORTABLE
Status: active
```

`Version from` is the start of this *version* of the record, not the original assignment date. The historical registrant was Papua New Guinea's National Information & Communications Technology Authority (NICTA).

## 5. Reuse the approach for another IXP or potential peer

1. Find the exchange or network in [PeeringDB](https://www.peeringdb.com/) and note the exchange ID or Autonomous System Number (ASN).
2. Inspect its PeeringDB `ix`, `ixlan`, `ixpfx`, and `netixlan` records. For a network, start with the `net` API collection.
3. Identify the relevant peering LAN prefix or network prefix.
4. Query its current registration with the appropriate Regional Internet Registry (RIR). These commands use APNIC for an Asia-Pacific example.
5. Request an **exact** WHOIS match; do not confuse a parent range with the target prefix.
6. If the RIR supports historical queries, check for changes or deletion events.
7. Independently verify operational status with the operator, peers, recent traffic statistics, or live BGP session evidence. An IXP peering LAN need not be globally advertised.

For a **potential peer**, confirm the ASN, peering addresses, routing policy, and authorisation with the operator before configuring a session. PeeringDB is a discovery aid, not configuration authorisation.

## 6. Evidence and limitations

| Observation | What it establishes |
| --- | --- |
| PeeringDB lists PNG-IXP | A directory entry exists |
| Exact APNIC WHOIS returns no entry | No exact current registration object was returned |
| APNIC Whowas lists `NICTA-PG` from 2017 | The prefix had a historical specific registration |
| Whowas says `This object has been deleted` | The registration object was deleted on 22 June 2025 |
| Any of these records alone | **Do not prove current IXP operation or inactivity** |

## References

- PNG-IXP on PeeringDB: https://www.peeringdb.com/ix/2332
- PeeringDB API documentation: https://docs.peeringdb.com/api_specs/
- APNIC historical RDAP: https://rdap.apnic.net/history/ip/103.82.247.0/24
- APNIC current RDAP: https://rdap.apnic.net/ip/103.82.247.0/24
- APNIC PNG-IXP launch article: https://blog.apnic.net/2017/06/07/event-wrap-png-ixp-launch/
- APNIC whois: https://wq.apnic.net//static/search.html?query=103.82.247.0/24
- APNIC whowas: https://www.apnic.net/static/whowas-ui/#103.82.247.0/24
- Internet Society Pulse: https://pulse.internetsociety.org/

**Reproducibility:** Observed outputs are from an **October 2026** investigation. Live directory and registry responses can change. Record the date of your queries and retain raw responses when preparing formal evidence. All commands above run directly without saving intermediate JSON files.
