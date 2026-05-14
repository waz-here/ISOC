# Update Console Port Numbering in a GNS3 Project via API (CLI-Based Guide)

## 1. Introduction

This guide explains how to safely update GNS3 console (telnet) port numbers using the GNS3 API. This method avoids directly editing the `.gns3` project file and provides a controlled, repeatable workflow suitable for training environments and automation.

## 2. Why Check Port Availability?

Before assigning a console port, you must ensure it is not already in use.

**Why:**

* Prevents port conflicts
* Avoids silent failures
* Ensures predictable lab behaviour

## 3. Backup (MANDATORY)

Always back up your project before making changes:

```bash
cp "IXP lab.gns3" "IXP lab.gns3.bak"
```

This creates a rollback copy and protects against accidental corruption


## 4. Get Project ID

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

Select the project id

```bash
PROJECT_NAME="IXP lab"

PROJECT_ID=$(curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects \
  | jq -r --arg name "$PROJECT_NAME" '.[] | select(.name == $name) | .project_id')

echo "$PROJECT_ID"
```


## 5. List Nodes

Lists all nodes and show the current console ports

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes | jq
```

Check existing allocated console port

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes \
 | jq -r '.[] | "\(.console) → \(.name) → \(.node_id)"' | sort
```

## 6. Get Node ID (example: B1)

```bash
NODE_ID=$(curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes \
 | jq -r '.[] | select(.name=="B1") | .node_id')
```


## 7. Check if Port is Already in Use

Lists listening TCP ports to confirm whether port is already bound

### Option 1 — Check locally

```bash
ss -tln | grep 5011
```

### Option 2 — Check entire range

```bash
ss -tln | grep 50
```


## 8. Stop the Node (Important)

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST \
http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/stop
```

**Why:**

* Prevents stale console bindings
* Ensures clean reallocation


## 9. Update Console Port

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X PUT \
http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID \
-H "Content-Type: application/json" \
-d '{"console":5011}'
```

Updates the node configuration and assign new console port


## 10. Restart the Node

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -X POST \
http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes/$NODE_ID/start
```



## 11. Verify

```bash
curl -u "$GNS3_USER:$GNS3_PASS" -s http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes \
 | jq -r '.[] | {name, console}'
```

Expected:

```text
B1 → 5011
```



## 12. Test Console Access

```bash
telnet 127.0.0.1 5011
```


## 13. Recommended Port Scheme (Example)

```text
TR1 = 5001
TR2 = 5002

Group 1 = 501X
Group 2 = 502X
...
Group 8 = 508X

B = 1
C = 2
P = 3
A = 4
Trigger = 5
SRV = 6
Cust = 7

IXP1 → 511X
IXP2 → 512X
```

## 14. Bulk Validation (Optional)

Check for duplicate ports:

```bash
curl -s http://127.0.0.1:3080/v2/projects/$PROJECT_ID/nodes \
 | jq -r '.[] | .console' | sort | uniq -d
```



* Identifies duplicate console ports
* Helps prevent conflicts


## 15. Key Takeaways

* Always back up before changes
* Always verify port availability
* Always stop nodes before updating
* Prefer API over manual file editing for repeatability

---

## Summary

Using the GNS3 API provides a safe, scriptable, and consistent method to manage console ports. Combined with proper validation and a structured numbering scheme, it significantly improves usability and troubleshooting in large lab environments.
