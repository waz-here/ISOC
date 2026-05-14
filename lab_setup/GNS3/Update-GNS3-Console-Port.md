# Update Console Port Numbering in a GNS3 Project

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

### Step 5: Understand Where Console Ports Are Stored

Open or inspect the `.gns3` project file. Each device appears as a JSON object inside the project file. A router entry will look similar to this:

```json
{
  "name": "B1",
  "node_id": "...",
  "console": 5011,
  "console_type": "telnet",
  "console_host": "127.0.0.1"
}
```

The important fields are:

| Field | Meaning |
|---|---|
| `name` | The GNS3 node name, such as `B1`, `C1`, `TR1`, or `RS1` |
| `console` | The telnet console port number |
| `console_type` | Usually `telnet` |
| `console_host` | Usually `127.0.0.1` or the GNS3 server address |

The field you normally change is:

```json
"console": 5011
```
