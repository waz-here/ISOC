
# Resetting a Cisco Router Password in GNS3

This guide explains how to reset a Cisco router password in GNS3 using safe, repeatable methods suitable for training labs and workshops.


## Overview

In GNS3, you **cannot bypass a login prompt directly** if credentials are unknown.

Instead, password recovery is performed by:

* Resetting the device state (recommended)
* Skipping the startup configuration
* Reapplying a known configuration


## Method 1: Wipe the Router (Recommended)

This is the simplest and most reliable approach.

### Steps (GUI)

1. Stop the router
2. Right-click the router
3. Select **Wipe**
4. Start the router again

### What this does

* Deletes NVRAM (startup-config)
* Removes all passwords
* Returns router to factory default

### Result

You will get:

```text
Router>
```

No username or password required.


## Method 2: Reset via GNS3 API (Automation)

This method is ideal for labs or scripted environments.

### Step 1: Get Project and Node IDs

Set the credentials via an interactive prompt

```bash
export GNS3_USER=admin
read -rsp "GNS3 password: " GNS3_PASS
export GNS3_PASS
echo
```

Why this is safer:
read -s   hides what you type
-r        prevents backslash interpretation
-p        shows a prompt


```bash
curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects | jq
```

Find your project name:

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects \
| jq -r '.[] | "\(.name) → \(.project_id)"'
```

This will query GNS3 API and extracts the name and project identifier

Select the project id (example: IXP lab)

```bash
PROJECT_NAME="IXP lab"

PROJECT_ID=$(curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects \
  | jq -r --arg name "$PROJECT_NAME" '.[] | select(.name == $name) | .project_id')

echo "$PROJECT_ID"
```

Select the Node ID (example: B1)

```bash
NODE_ID=$(curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes \
 | jq -r '.[] | select(.name=="B1") | .node_id')
```

### Step 2: Stop the Router

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/stop
```

### Step 3: Wipe the Router

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/wipe
```

### Step 4: Start the Router

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/start
```

### Result

* Router boots with no configuration
* No password required

## Method 3: Ignore Startup Config (Config Register)

This mimics real Cisco password recovery.

### Step 1: Set config-register

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X PUT http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID \
-H "Content-Type: application/json" \
-d '{"properties": {"config_register": "0x2142"}}'
```

---

### Step 2: Restart Router

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/reload
```

### Step 3: Reset Password

```bash
enable
copy startup-config running-config
conf t
enable secret NEWPASSWORD
config-register 0x2102
end
write memory
reload
```

## Method 4: Apply a Known Startup Config

Best for structured labs (e.g. workshops).

1. Create a clean config file:

```bash
hostname B1
no ip domain-lookup
enable secret cisco
line vty 0 4
 password cisco
 login
```

2. Apply via GNS3 API:

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST \
http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/startup-config \
-d @router.cfg
```


### Result

* Router boots with known credentials
* No recovery required


## What Does NOT Work

* Expect scripts against login prompts
* Telnet automation without credentials
* Sending CLI commands before authentication


## Key Takeaway

> In GNS3, password recovery is done by controlling the **device state**, not the **login session**.



## Recommended Workflow for Labs

For repeatable training environments:

```bash
for each router:
  stop
  wipe
  apply baseline config
  start
```


## 📎 References

* GNS3 API Documentation
  [https://gns3-server.readthedocs.io/en/stable/api/v2/](https://gns3-server.readthedocs.io/en/stable/api/v2/)

* Cisco Password Recovery (IOS XE)
  [https://www.cisco.com/c/en/us/support/docs/ios-nx-os-software/ios-xe-16/217045-troubleshoot-password-recovery-in-cisco.html](https://www.cisco.com/c/en/us/support/docs/ios-nx-os-software/ios-xe-16/217045-troubleshoot-password-recovery-in-cisco.html)


## Summary

| Method          | Use Case           | Difficulty |
| --------------- | ------------------ | ---------- |
| Wipe            | Quick reset        | * Easy     |
| API wipe        | Automation         | **         |
| Config-register | Realistic recovery | ***      |
| Startup config  | Lab environments   | **         |

