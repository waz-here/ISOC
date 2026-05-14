# Update Console Port Numbering in a GNS3 Project using Python

## Purpose

This tutorial explains how to inspect and safely modify a GNS3 project file so console / Telnet port numbers follow a predictable workshop numbering scheme. It is intended for training people preparing repeatable GNS3 lab environments with multiple router groups, transit routers and Internet Exchange Point (IXP) devices.

## References

- GNS3 project files are `.gns3` files in JSON format: https://gns3-server.readthedocs.io/en/stable/file_format.html
- GNS3 node objects include a `console` field for the console TCP port: https://gns3-server.readthedocs.io/en/stable/api/v2/controller/node/projectsprojectidnodes.html
- GNS3 architecture separates the GUI, controller, compute and emulators: https://docs.gns3.com/docs/using-gns3/design/architecture/

---

## 1. Introduction to GNS3 Project File and Folder Structure

A GNS3 project is stored as a project directory containing a `.gns3` topology file and supporting runtime files. The `.gns3` file is JSON, not XML, and records the nodes, links, console ports and topology metadata. The project folder may also contain QEMU, Dynamips, Docker or appliance-specific files used by the GNS3 server when the lab runs.

---

## 2. Expected GNS3 Project File / Folder Structure

A typical GNS3 project directory looks like this:

```text
~/GNS3/projects/
└── IXP lab/
    ├── IXP lab.gns3
    ├── project-files/
    │   ├── qemu/
    │   │   └── <node-id>/
    │   ├── dynamips/
    │   ├── docker/
    │   └── vpcs/
    └── README or local notes, if created by the lab maintainer
```

The important file for static console port changes is:

```text
IXP lab.gns3
```

This file contains a JSON list of nodes. Each node normally has fields such as:

```json
{
  "name": "B1",
  "console": 5011,
  "console_type": "telnet"
}
```

---

## 3. Why GNS3 Console Ports Need Manual Sequencing

GNS3 assigns console ports to nodes so users can access devices using Telnet or another configured console method. By default, these ports may not follow a logical sequence, especially after adding, deleting, cloning or importing nodes. In a workshop, random console ports slow down troubleshooting and make trainer instructions harder to follow.

Static assignment makes access predictable. For example:

```text
telnet <gns3-server> 5011  # B1
telnet <gns3-server> 5012  # C1
telnet <gns3-server> 5013  # P1
```

This is useful because:

- trainers can quickly identify a device from the port number
- students can follow a consistent connection scheme
- deployment scripts can target known node names and ports
- troubleshooting is faster during live labs

---

## 4. Required Port Numbering Scheme

### External Devices

```text
TR1 = 5001
TR2 = 5002
```

### Group-Based Router Ports

```text
Group 1 → 501X
Group 2 → 502X
Group 3 → 503X
Group 4 → 504X
Group 5 → 505X
Group 6 → 506X
Group 7 → 507X
Group 8 → 508X
```

### Group Router Role Mapping

```text
B       = 1
C       = 2
P       = 3
A       = 4
Trigger = 5
SRV     = 6
Cust    = 7
```

Example:

```text
B1       = 5011
C1       = 5012
P1       = 5013
A1       = 5014
Trigger1 = 5015
SRV1     = 5016
Cust1    = 5017

B8       = 5081
C8       = 5082
P8       = 5083
A8       = 5084
Trigger8 = 5085
SRV8     = 5086
Cust8    = 5087
```

### IXP Device Ports

```text
IXP1 devices → 511X
IXP2 devices → 512X
```

### IXP Role Mapping

```text
SW = 1
RS = 2
SR = 3
```

Example:

```text
SW1 = 5111
RS1 = 5112
SR1 = 5113

SW2 = 5121
RS2 = 5122
SR2 = 5123
```

---

## 5. Step-by-Step: Static Assign Console Ports Using the `.gns3` Project File

> Important: Stop the GNS3 project before editing the `.gns3` file. Editing while the project is open can cause GNS3 to overwrite your changes.

### Step 1: Go to the Project Directory

```bash
cd "$HOME/GNS3/projects/IXP lab"
```

This places you in the folder containing the project file so all following commands operate on the correct lab.

### Step 2: Confirm the Project File Exists

```bash
ls -lh *.gns3
```

This confirms the target `.gns3` file is present and shows file size and ownership before changes.

### Step 3: Back Up the Project File

```bash
cp -a "IXP lab.gns3" "IXP lab.gns3.$(date +%Y%m%d-%H%M%S).bak"
```

`cp -a` preserves ownership, permissions and timestamps. The timestamp makes each backup unique and easy to identify.

Optional check:

```bash
ls -lh *.bak
```

This confirms the backup was created before any modification is attempted.

### Step 4: Validate the Existing File is JSON

```bash
python3 -m json.tool "IXP lab.gns3" >/dev/null
```

GNS3 `.gns3` files are JSON. This command parses the file and returns no output if the syntax is valid. If it fails now, fix or restore the project before making changes.

### Step 5: Create a Local Port-Fix Script

Although `sed` is useful for line-based text, it is not safe for structured JSON updates. Use a CLI Python script instead so the JSON structure is preserved.

```bash
cat << 'EOF' > fix_gns3_ports_correct_scheme.py
#!/usr/bin/env python3

import csv
import json
import re
import sys
from pathlib import Path


ROLE_OFFSETS = {
    "B": 1,
    "C": 2,
    "P": 3,
    "A": 4,
    "Trigger": 5,
    "T": 5,
    "SRV": 6,
    "Cust": 7,
}


IXP_ROLE_OFFSETS = {
    "SW": 1,
    "RS": 2,
    "SR": 3,
}


def group_port(group: int, offset: int) -> int:
    return 5000 + (group * 10) + offset


def ixp_port(ixp_number: int, offset: int) -> int:
    return 5100 + (ixp_number * 10) + offset


def get_tr_port(name: str):
    if name == "TR1":
        return 5001
    if name == "TR2":
        return 5002
    return None


def get_ixp_port(name: str):
    # Expected names include forms such as SW1, RS1, SR1, IXP1-SW, IXP1-RS, IXP1-SR.
    for role, offset in IXP_ROLE_OFFSETS.items():
        patterns = [
            rf"^{role}([12])$",
            rf"^IXP([12]).*{role}$",
            rf"^IXP([12])[-_ ]?{role}$",
            rf"^{role}[-_ ]?IXP([12])$",
        ]

        for pattern in patterns:
            match = re.search(pattern, name, re.IGNORECASE)
            if match:
                return ixp_port(int(match.group(1)), offset)

    return None


def get_group_router_port(name: str):
    # Check longest prefixes first so Cust1 is not confused with C1.
    for role in sorted(ROLE_OFFSETS, key=len, reverse=True):
        match = re.match(rf"^{role}(\d+)$", name, re.IGNORECASE)
        if match:
            group = int(match.group(1))
            if 1 <= group <= 8:
                return group_port(group, ROLE_OFFSETS[role])

    return None


def expected_port(name: str):
    return (
        get_tr_port(name)
        or get_ixp_port(name)
        or get_group_router_port(name)
    )


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 fix_gns3_ports_correct_scheme.py '<project>.gns3'")
        sys.exit(1)

    project_file = Path(sys.argv[1])

    with project_file.open() as f:
        data = json.load(f)

    mappings = []
    used_ports = {}

    for node in data.get("nodes", []):
        name = node.get("name", "")
        old_port = node.get("console")
        new_port = expected_port(name)

        if new_port is None:
            mappings.append((name, old_port, old_port, "unchanged - no matching rule"))
            continue

        node["console"] = new_port
        mappings.append((name, old_port, new_port, "updated"))

        if new_port in used_ports:
            used_ports[new_port].append(name)
        else:
            used_ports[new_port] = [name]

    duplicates = {port: names for port, names in used_ports.items() if len(names) > 1}
    if duplicates:
        print("ERROR: duplicate console ports detected:")
        for port, names in duplicates.items():
            print(f"  {port}: {', '.join(names)}")
        print("No output file written.")
        sys.exit(2)

    output_file = project_file.with_name(project_file.stem + "_ports_fixed.gns3")
    mapping_file = project_file.with_name(project_file.stem + "_console_port_mapping.csv")

    with output_file.open("w") as f:
        json.dump(data, f, indent=2)

    with mapping_file.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["node", "old_console", "new_console", "status"])
        writer.writerows(sorted(mappings, key=lambda row: row[0]))

    print(f"Fixed project written to: {output_file}")
    print(f"Mapping CSV written to:  {mapping_file}")


if __name__ == "__main__":
    main()
EOF
```

The heredoc (`cat << 'EOF'`) creates the script without using an editor. This avoids indentation problems and preserves Python formatting exactly.

### Step 6: Make the Script Executable

```bash
chmod +x fix_gns3_ports_correct_scheme.py
```

This allows the script to be run directly as a local command if desired.

### Step 7: Run the Port-Fix Script

```bash
python3 fix_gns3_ports_correct_scheme.py "IXP lab.gns3"
```

The script reads the project JSON, updates node `console` values based on the defined naming rules, checks for duplicates, and writes a new project file instead of overwriting the original.

Expected output:

```text
Fixed project written to: IXP lab_ports_fixed.gns3
Mapping CSV written to:  IXP lab_console_port_mapping.csv
```

### Step 8: Review the Mapping Table

```bash
column -s, -t "IXP lab_console_port_mapping.csv" | less -S
```

This formats the CSV into readable columns so trainers can quickly confirm that each device has the expected console port.

Useful checks:

```bash
grep -E '^(TR1|TR2|B1|C1|P1|A1|Trigger1|SRV1|Cust1|SW1|RS1|SR1)' "IXP lab_console_port_mapping.csv"
```

This spot-checks external, group and IXP devices without manually reading the whole file.

### Step 9: Check for Duplicate Ports

```bash
awk -F, 'NR>1 {print $3}' "IXP lab_console_port_mapping.csv" | sort | uniq -d
```

This prints duplicate new console ports. No output means no duplicates were found.

### Step 10: Replace the Active Project File

Only do this after checking the mapping and syntax.

```bash
cp -a "IXP lab.gns3" "IXP lab.gns3.pre-port-fix"
cp -a "IXP lab_ports_fixed.gns3" "IXP lab.gns3"
```

The first command creates a final rollback copy. The second command promotes the fixed file to the active project filename expected by GNS3.

---

## 6. Check the GNS3 Project Syntax After Modifying

### Step 1: Validate JSON Syntax

```bash
python3 -m json.tool "IXP lab.gns3" >/dev/null
```

This confirms the `.gns3` file is syntactically valid JSON. If the command returns no output, the file parsed successfully.

### Step 2: Pretty-Print to a Temporary File

```bash
python3 -m json.tool "IXP lab.gns3" > /tmp/gns3-project-check.json
```

This creates a parsed and formatted copy. If the command succeeds, the project file is readable as JSON.

Optional review:

```bash
head -40 /tmp/gns3-project-check.json
```

This gives a quick visual check that the file structure is intact.

### Step 3: Confirm Console Fields Exist

```bash
grep -n '"console"' "IXP lab.gns3" | head
```

This confirms the file still contains console port assignments after modification.

### Step 4: Confirm Expected Ports Are Present

```bash
grep -E '"console": 5001|"console": 5002|"console": 5011|"console": 5087|"console": 5111|"console": 5123' "IXP lab.gns3"
```

This checks for known key ports in the expected scheme, including transit, group and IXP devices.

### Step 5: Open the Project in GNS3

Start GNS3 and open the project normally. If the project opens and devices appear, the file structure is acceptable to GNS3.

Optional CLI launch:

```bash
gns3 "IXP lab.gns3" &
```

This starts the GNS3 GUI with the specified project file. In many deployments, the GUI connects to the GNS3 server/controller, which manages project state and nodes.

---

## 7. Operational Notes for Trainers

- Always stop the project before editing the `.gns3` file.
- Always create a backup before changing project files.
- Do not edit JSON manually unless necessary.
- Prefer a repeatable script for bulk port changes.
- Avoid `sed` for JSON modifications because it can corrupt structure if matching text appears in unexpected places.
- Keep a CSV mapping table with the lab notes so trainers can quickly connect to devices.
- After modifying ports, restart the project or reload it in GNS3 so the new console values are used.

---

## 8. Quick Reference

### Validate Project File

```bash
python3 -m json.tool "IXP lab.gns3" >/dev/null
```

### Back Up Project File

```bash
cp -a "IXP lab.gns3" "IXP lab.gns3.$(date +%Y%m%d-%H%M%S).bak"
```

### Run Port Fix

```bash
python3 fix_gns3_ports_correct_scheme.py "IXP lab.gns3"
```

### Check Duplicate Ports

```bash
awk -F, 'NR>1 {print $3}' "IXP lab_console_port_mapping.csv" | sort | uniq -d
```

### Example Console Access

```bash
telnet <gns3-server-ip> 5011  # B1
telnet <gns3-server-ip> 5012  # C1
telnet <gns3-server-ip> 5013  # P1
telnet <gns3-server-ip> 5014  # A1
```

---

## 9. Expected Final Port Scheme

```text
TR1 = 5001
TR2 = 5002

B1       = 5011
C1       = 5012
P1       = 5013
A1       = 5014
Trigger1 = 5015
SRV1     = 5016
Cust1    = 5017

B2       = 5021
C2       = 5022
P2       = 5023
A2       = 5024
Trigger2 = 5025
SRV2     = 5026
Cust2    = 5027

...

B8       = 5081
C8       = 5082
P8       = 5083
A8       = 5084
Trigger8 = 5085
SRV8     = 5086
Cust8    = 5087

SW1      = 5111
RS1      = 5112
SR1      = 5113

SW2      = 5121
RS2      = 5122
SR2      = 5123
```
