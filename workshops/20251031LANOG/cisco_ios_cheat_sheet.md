
# Cisco IOS Verification & Troubleshooting Cheat Sheet

This guide provides essential Cisco IOS commands for verifying and troubleshooting interface, OSPF, iBGP, and eBGP configurations. Each command includes a brief explanation of its purpose.

## Interface Verification

### `show ip interface brief`
Displays a summary of all interfaces, their IP addresses, and their operational status (up/down).

### `show running-config | section interface`
Shows the configuration of all interfaces, useful for checking IPs, descriptions, and shutdown status.

### `ping <neighbor-IP>`
Tests basic IP connectivity to a neighbor router.

### `traceroute <neighbor-IP>`
Displays the path packets take to reach a destination, useful for identifying routing issues.

---

## OSPF Verification

### `show ip ospf neighbor`
Lists OSPF neighbors and their adjacency states (e.g., FULL, 2WAY).

### `show ip route ospf`
Displays routes learned via OSPF.

### `show ip ospf`
Provides details about the OSPF process, including router ID, areas, and interfaces.

---

## BGP Verification (Modern Commands)

### `show bgp ipv4 unicast summary`
Displays BGP neighbor relationships, AS numbers, session states, and received prefixes.

### `show bgp ipv4 unicast`
Shows the BGP routing table for IPv4 unicast, including best path selection.

### `show bgp ipv4 unicast neighbors`
Provides detailed information about BGP neighbors, including capabilities and timers.

### `show bgp ipv4 unicast neighbors <neighbor-IP> advertised-routes`
Lists the routes advertised to a specific BGP neighbor.

### `show bgp ipv4 unicast neighbors <neighbor-IP> routes`
Displays routes received from a specific BGP neighbor.

---

## Troubleshooting Commands

### `debug bgp ipv4 unicast`
Enables debugging for BGP IPv4 unicast events. Use with caution in production environments.

### `show logging`
Displays system logs, including BGP and OSPF events.

### `show ip protocols`
Shows routing protocols running on the router and their configuration.

### `show ip route`
Displays the full IP routing table, including static, connected, OSPF, and BGP routes.

---

## Additional Checks

### `show ip bgp`
Legacy command to view BGP routes. Still available but replaced by `show bgp ipv4 unicast`.

### `show ip bgp summary`
Legacy summary of BGP neighbors. Use `show bgp ipv4 unicast summary` instead.

### `show ip route static`
Lists static routes configured on the router.

### `show ip interface Loopback0`
Verifies the configuration of the loopback interface.

---

> ⚠️ **Note:** Always use caution with `debug` commands on production routers as they can impact performance.
