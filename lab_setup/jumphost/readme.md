# How to set up the Jumphost

This builds a repeatable jumphost using an Ubuntu or Debian-based Proxmox LXC container.

## Purpose

Students SSH to the jumphost at `10.10.0.10` using the account `student01`. Instead of receiving a normal shell, SSH forces a lab menu script. The lab menu connects students to router consoles on a GNS3 server over ZeroTier.

This is a classroom access restriction, not a hardened security sandbox.

## Assumptions

| Item | Value |
|---|---|
| Jumphost IP | `10.10.0.10/24` |
| Student username | `student01` |
| Lab script path | `/usr/local/bin/lab.sh` |
| ZeroTier network ID | Supplied at install time |
| GNS3 host | Supplied at install time |
| Container OS | Ubuntu or Debian |
| Access method | SSH |

## 1. Proxmox host preparation for ZeroTier in LXC

ZeroTier needs access to `/dev/net/tun` to create the overlay interface.

On the Proxmox host, edit the LXC configuration:

```bash
nano /etc/pve/lxc/<CTID>.conf
```

Add:

```text
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```
These two lines:

* expose the Linux TUN device to the container
* allow ZeroTier to create its virtual interface
* enable overlay networking inside LXC

Without them:

* ZeroTier appears partially functional
* but networking does not actually work

Restart the container:

```bash
pct restart <CTID>
```

Inside the container, verify:

```bash
ls -l /dev/net/tun
```

Expected:

```text
crw-rw-rw- 1 root root 10, 200 ...
```

## 2. Copy files into the container

Copy these files into the container, for example into `/root`:

```bash
scp setup-jumphost.sh root@10.10.0.10:/root/
scp lab.sh root@10.10.0.10:/root/lab.sh
```

Or paste them directly into the container.

## 3. Run the provisioning script

Inside the container as root:

```bash
chmod +x /root/setup-jumphost.sh
/root/setup-jumphost.sh \
  --zerotier-network <ZEROTIER_NETWORK_ID> \
  --gns3-host 172.233.75.181 \
  --lab-script /root/lab.sh
```

The script will:

1. Install required packages.
2. Install and enable ZeroTier.
3. Join the ZeroTier network.
4. Create or update the `student01` account.
5. Install the lab menu at `/usr/local/bin/lab.sh`.
6. Configure OpenSSH to force the lab menu at login.
7. Disable SSH root login.
8. Disable SSH forwarding and tunnelling for `stduent01`.
9. Validate and restart SSH.

## 4. Authorise the ZeroTier node

After running the script, get the ZeroTier node ID:

```bash
zerotier-cli status
```

Go to ZeroTier Central and authorise the node.

Then verify:

```bash
zerotier-cli listnetworks
ip -br addr
ip route
```

Expected:

```text
ztxxxx UP 172.233.x.x/16
```

## 5. Test router access as root first

Before testing the restricted student account, confirm the network works from a privileged account:

```bash
ip route get 172.233.75.181
ping 172.233.75.181
tcptraceroute 172.233.75.181 22
telnet 172.233.75.181 <console-port>
```

If `tcptraceroute` shows:

```text
Selected device ztxxxxx, address 172.233.x.x
1 172.233.75.181 [open]
```

then ZeroTier and the target service are reachable.

## 6. Test student login

From another host:

```bash
ssh student01@10.10.0.10
```

Expected result:

```text
IXP Lab Jumphost
...
```

The student should see the lab menu, not a Bash prompt.

If the student exits the menu, the SSH session should close.

## 7. Useful validation commands

Run as root inside the container:

```bash
getent passwd student01
ls -l /usr/local/bin/lab.sh
sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|usepam|allowtcpforwarding|permittunnel'
grep -nEi 'Match User student01|ForceCommand|AllowTcpForwarding|PermitTunnel|X11Forwarding' /etc/ssh/sshd_config
journalctl -u ssh --no-pager -n 100
journalctl -u zerotier-one --no-pager -n 100
```

## 8. Troubleshooting

### `Permission denied` when SSH runs `/usr/local/bin/lab.sh`

Check the script is executable:

```bash
ls -l /usr/local/bin/lab.sh
chmod 755 /usr/local/bin/lab.sh
chown root:root /usr/local/bin/lab.sh
```

Check the first line:

```bash
head -1 /usr/local/bin/lab.sh
```

Expected:

```bash
#!/bin/bash
```

### ZeroTier says online, but no `zt` interface appears

Check TUN access:

```bash
ls -l /dev/net/tun
```

If missing, fix the LXC config on the Proxmox host and restart the container.

### `zerotier-cli listnetworks` is empty

The node has not joined or has not received network configuration. Run:

```bash
zerotier-cli join <ZEROTIER_NETWORK_ID>
zerotier-cli status
zerotier-cli listnetworks
```

Then authorise the node in ZeroTier Central.

### `Packet filtered` or traffic goes via the wrong gateway

Check the route decision:

```bash
ip route get 172.233.75.181
```

Expected:

```text
172.233.75.181 dev ztxxxxx src 172.233.x.x
```

If it goes via the default gateway, ZeroTier routes are not installed.

### Need to temporarily disable the forced menu

Edit SSH config:

```bash
nano /etc/ssh/sshd_config
```

Comment out the `Match User stduent01` block added by the provisioning script.

Then:

```bash
sshd -t
systemctl restart ssh
```

## 9. Rollback

Remove the SSH forced menu block:

```bash
sed -i '/# BEGIN JUMPHOST/,/# END JUMPHOST/d' /etc/ssh/sshd_config
sshd -t
systemctl restart ssh
```

Leave the ZeroTier network:

```bash
zerotier-cli leave <ZEROTIER_NETWORK_ID>
```

Lock the student account if needed:

```bash
passwd -l student01
```

## References

- ZeroTier CLI documentation: https://docs.zerotier.com/cli/
- ZeroTier quickstart: https://docs.zerotier.com/quickstart/
- OpenSSH `sshd_config` manual, including `ForceCommand`, `AllowTcpForwarding`, and `PermitTunnel`: https://man7.org/linux/man-pages/man5/sshd_config.5.html
