# Creating a GNS3 Server on Microsoft Azure

## Overview

This guide explains how to deploy a temporary GNS3 server on Microsoft Azure for workshop and training environments.

The environment is designed for:

- Network operator workshops
- GNS3 routing labs
- Temporary cloud-based training environments
- Remote workshop access
- Repeatable workshop infrastructure deployment

The guide uses:

- Microsoft Azure Cloud Shell
- Azure CLI
- Ubuntu 24.04 LTS
- Standard_D48s_v4 virtual machine
- Native GNS3 server installation

This guide assumes basic Linux and Azure familiarity.

# Estimated Workshop Cost

The following estimates are approximate only and may change depending on Azure pricing, region, storage selection, and bandwidth usage.

At the time of writing, the Standard_D48s_v4 instance provides:

- 48 vCPU
- 192 GB RAM
- AMD EPYC Rome (7002) CPUs
- Premium SSD support

The following estimates assume:

- 3 day workshop
- Approximately 8 hours runtime per day
- Total runtime approximately 24 hours
- Ubuntu Linux VM
- Premium SSD storage

| VM Size | vCPU | RAM | Approx Hourly Cost (USD) | Approx 24hr Compute Cost (USD) |
|---|---|---|---|---|
| Standard_D48s_v4 | 48 | 192 GB | ~$4.60/hr | ~$110 |
| Standard_D48as_v5 | 48 | 192 GB | ~$4.80/hr | ~$115 |
| Standard_D48as_v6 | 48 | 192 GB | ~$5.20-5.60/hr | ~$125-135 |
| Standard_D48as_v7 | 48 | 192 GB | ~$5.80-6.50/hr | ~$140-156 |

Additional storage and networking costs are typically:

| Item | Approx Cost |
|---|---|
| Premium SSD storage | ~$5-15 |
| Public IP | <$1 |
| Network traffic | Usually negligible |

Estimated total workshop cost:

| VM | Approx Total Workshop Cost |
|---|---|
| D48s_v4 | ~$120-130 |
| D48as_v5 | ~$125-140 |
| D48as_v6 | ~$140-160 |
| D48as_v7 | ~$155-180 |

The Standard_D48s_v4 provides a good balance between cost and performance for large CSR1000v based workshop environments.

### Recommended deployment process:

1. Deploy Azure VM
2. Install GNS3 server
3. Upload router images
4. Import topology
5. Test startup
6. Configure jumphost
7. Provide student access
8. Deallocate after workshop



# Launch Azure Cloud Shell

Login to:

https://portal.azure.com

Launch Cloud Shell from the Azure Portal.

Select:

- Bash

The Azure CLI is already installed in Cloud Shell.


# Azure Region Selection

List Azure locations:

```bash
az account list-locations --query '[].{Location:displayName,Name:name}' --output table | sort
```

Common nearby regions include:

- southeastasia (Singapore)
- eastasia (Hong Kong)
- australiaeast (Sydney)
- australiasoutheast (Melbourne)
- southafricanorth (Johannesburg)

For Asia Pacific workshops, Singapore is commonly used.

# Check VM Availability

The following command checks available D48as_v5 SKUs:

```bash
az vm list-skus \
  --location southeastasia \
  --resource-type virtualMachines \
  --size Standard_D48s_v4 \
  --query "[].{
    Name:name,
    vCPU: capabilities[?name=='vCPUs'] | [0].value,
    MemoryGB: capabilities[?name=='MemoryGB'] | [0].value
  }" \
  -o table
```

Note:

This command can take several minutes to complete.

# Check Azure Quotas Before Deployment

Large Azure virtual machines require sufficient vCPU quota in the selected region.

This is important because a Standard_D48s_v4 VM requires:

* 48 vCPU
* 192 GB RAM

Azure quota is applied per subscription and per region. A subscription may have enough quota in one region but not in another.

There are two quota types to check:

| Quota Type           | Purpose                                        |
| -------------------- | ---------------------------------------------- |
| Total Regional vCPUs | Maximum total vCPUs allowed in the region      |
| VM Family vCPUs      | Maximum vCPUs allowed for a specific VM family |

For the Standard_D48s_v4 VM, check:

* Total Regional vCPUs
* Standard DSv4 Family vCPUs



## Check Current Quota

Run:

```bash
az vm list-usage \
  --location southeastasia \
  -o table
```

Or to view just the Standard_D48s_v4 and Standard_D48as_v5

```bash
az vm list-usage \
  --location southeastasia \
  -o table | grep -Ei "Name|Total | DSv4| DSv5"
```

Example output:

```text
Name                                CurrentValue    Limit
----------------------------------  --------------  -------
Total Regional vCPUs                0               10
Standard DSv4 Family vCPUs         0               0
```

In this example, the subscription cannot deploy a Standard_D48s_v4 VM because:

* the regional quota is only 10 vCPU
* the D48s_v4 VM requires 48 vCPU
* the DSv4 family quota is 0 vCPU



## Example Quota Error

If quota is insufficient, VM creation may fail with an error similar to:

```text
QuotaExceeded
Location: southeastasia
Current Limit: 10
Current Usage: 0
Additional Required: 48
Minimum New Limit Required: 48
```

This means Azure has blocked the deployment because the requested VM would exceed the approved vCPU quota for that region.



## Request a Quota Increase

In the Azure Portal:

1. Search for Quotas
2. Select Compute
3. Filter by region, for example southeastasia
4. Request an increase for Total Regional vCPUs
5. Request an increase for Standard DSv4 Family vCPUs

Recommended quota request:

| Quota                       | Recommended Value |
| --------------------------- | ----------------- |
| Total Regional vCPUs        | 64                |
| Standard DSv4 Family vCPUs | 64                |
| Standard EASv5 Family vCPUs | 64                |

Requesting 64 vCPU provides enough quota for:

* one Standard_D48s_v4 GNS3 server
* one small jumphost
* rebuild or testing overhead

If planning to test memory optimised E-series VMs later, also request EASv5 quota.



## Recommended Backup Regions

Quota and capacity can vary by region.

Recommended approach:

| Region           | Purpose                              |
| ---------------- | ------------------------------------ |
| southeastasia    | Primary Asia Pacific workshop region |
| australiaeast    | Backup region                        |
| eastasia         | Backup region                        |
| southafricanorth | Africa workshop region               |

If the primary region does not have available quota or capacity, repeat the quota check in a backup region.



## Important Notes

Quota approval does not always guarantee VM allocation.

A deployment can still fail if Azure does not have capacity for that VM size in the selected region at that time.

For workshops:

* request quota early
* deploy and test several days before the workshop
* avoid first deployment on the day of the workshop
* keep a backup region or backup VM size available

For more details refer to:

[https://learn.microsoft.com/en-us/azure/quotas/regional-quota-requests](https://learn.microsoft.com/en-us/azure/quotas/regional-quota-requests)

[https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests](https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests)


# Create Variables

Create deployment variables:

```bash
LOCATION="southeastasia"
RG="rg-gns3"
VM="gns3srv01"
USER="user01"
SIZE="Standard_D48s_v4"
IMAGE="Ubuntu2404"
PASSWORD='ChangeMe123!'
```



# Create Resource Group

```bash
az group create \
  --name "$RG" \
  --location "$LOCATION"
```



# Create the GNS3 Server VM

```bash
az vm create \
  --resource-group "$RG" \
  --name "$VM" \
  --image "$IMAGE" \
  --size "$SIZE" \
  --admin-username "$USER" \
  --authentication-type password \
  --admin-password "$PASSWORD" \
```

The deployment process can take several minutes.



# Restrict SSH Access

Determine your public IP address:

```bash
curl ifconfig.me
```

Example:

```text
203.0.113.44
```

Update the Network Security Group:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes 203.0.113.44/32
```

If required, restore access from any IP:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes '*'
```



# Retrieve the Public IP Address

```bash
az vm list-ip-addresses \
  --resource-group "$RG" \
  --name "$VM" \
  -o table
```



# Connect via SSH

```bash
ssh user01@PUBLIC_IP
```



# Update Ubuntu

```bash
sudo apt update && sudo apt dist-upgrade -y && sudo apt -y autoremove
```

During installation the install will stop for user confimation to allow non-root access to ubridge and wireshark. Use debconf-set-selections before installation.

## Preseed ubridge

```bash
echo "ubridge ubridge/install-setuid boolean true" | sudo debconf-set-selections
```

This automatically answers:

Should non-superusers be able to run GNS3? <br>
YES

## Preseed Wireshark

```bash
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
```

This automatically answers:

Should non-superusers be able to capture packets? <br>
YES

# Add the software repo for GNS3 Server

```bash
sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update
```

# Install GNS3 Server Dependencies

```bash
sudo apt install -y \
  qemu-kvm \
  qemu-utils \
  libvirt-daemon-system \
  libvirt-clients \
  bridge-utils \
  dynamips \
  ubridge \
  docker.io \
  git \
  curl \
  wget
```

# Verify KVM Support

```bash
sudo kvm-ok
```

Expected output:

```text
KVM acceleration can be used
```

# Install GNS3 Server

```bash
sudo apt install -y gns3-server gns3-gui
```


# Enable Services

```bash
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo systemctl enable docker
sudo systemctl start docker
```



# Configure User Permissions

```bash
sudo usermod -aG ubridge,wireshark,libvirt,kvm,docker "$USER"
```

Logout and reconnect via SSH after applying group permissions.

# Verify CPU and RAM

```bash
lscpu
```

```bash
free -h
```

Expected approximate values:

| Resource | Expected |
|---|---|
| vCPU | 48 |
| RAM | ~192 GB |



# Recommended Storage Layout

Recommended locations:

| Purpose | Location |
|---|---|
| GNS3 projects | /opt/gns3/projects |
| CSR qcow2 images | /opt/gns3/images |
| Packet captures | /opt/gns3/captures |
| Temporary files | /tmp |

Example:

```bash
sudo mkdir -p /opt/gns3/{projects,images,captures}
sudo chown -R $USER:$USER /opt/gns3
```



# Recommended CSR1000v Notes

CSR1000v routers consume significant RAM and CPU resources.

Approximate sizing:

| Resource | Approximate Usage |
|---|---|
| RAM per router | 3-4 GB |
| vCPU per router | 1 |

A Standard_D48s_v4 instance should comfortably support approximately:

- 40-50 CSR1000v routers

depending on topology complexity and lab activity.


# Deallocate the VM After the Workshop

Important:

Stopping Ubuntu does not stop Azure billing.

To stop compute billing:

```bash
az vm deallocate \
  --resource-group "$RG" \
  --name "$VM"
```

To restart:

```bash
az vm start \
  --resource-group "$RG" \
  --name "$VM"
```



# Delete the Entire Environment

```bash
az group delete --name "$RG"
```

# Enable accesss to GNS3 server and import a project

## Step 1 — Enable the GNS3 Server

The Ubuntu GNS3 packages install `gns3server`, but they do **not always create a `gns3.service` systemd unit**.

Check the binary:

```bash
which gns3server
gns3server --version
```

Create a systemd service:

```bash
sudo tee /etc/systemd/system/gns3.service > /dev/null <<'EOF'
[Unit]
Description=GNS3 Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=user01
Group=user01
ExecStart=/usr/bin/gns3server --host 0.0.0.0 --port 3080
Restart=on-failure
RestartSec=5
WorkingDirectory=/home/user01

[Install]
WantedBy=multi-user.target
EOF
```

Then enable and start it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable gns3
sudo systemctl start gns3
sudo systemctl status gns3
```

Check logs if it fails:

```bash
journalctl -u gns3 -n 50 --no-pager
```

You should also restrict Azure NSG access to port `3080` to your public IP only.

## Step 2 — Open Port 3080 in Azure

Allow GNS3 server access:

```bash id="nl9n94"
az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name allow-gns3 \
  --priority 1010 \
  --destination-port-ranges 3080 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes YOUR_PUBLIC_IP/32
```

Replace:

* `YOUR_PUBLIC_IP` with your real IP.

## Step 3 — Access GNS3 Server via Browser

By default the standalone `gns3server` process:

* does not enable authentication
* does not use HTTPS
* listens openly on the configured interface
* exposes the REST API and web UI directly.

You can access the GNS3 Server via this URL

```text
http://203.0.113.44:3080/static/web-ui/server/1/projects
```

The service file:

```ini
ExecStart=/usr/bin/gns3server --host 0.0.0.0 --port 3080
```

explicitly tells GNS3 to:

* listen on all interfaces
* expose the server publicly.

So anyone who can reach TCP/3080 can:

* connect
* upload projects
* control routers
* access captures
* potentially execute commands via appliances.

This is normal GNS3 behaviour unless authentication is configured.

For workshop infrastructure this is dangerous if:

* NSG permits `0.0.0.0/0`
* public Internet can reach port 3080.

GNS3 was designed primarily for:

* trusted LAN environments
* lab networks
* local workstation use.


# Recommended Immediate Fix

## Restrict Azure NSG (currently restricted to SSH)

Allow only:

* your public IP
* workshop jump host IP.

NOT:

* all Internet access.

Example:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name allow-gns3 \
  --source-address-prefixes YOUR_IP/32
```

This is the most important protection.


## Recommended Better Architecture

Instead of exposing GNS3 publicly:

```text 
Laptop
  ->
SSH tunnel
  ->
Azure GNS3 Server
```

Much safer.

Example:

```bash 
ssh -L 3080:localhost:3080 user01@SERVER_IP
```

Then locally connect GNS3 GUI to:

```text 
localhost:3080
```

Now:

* no public 3080 exposure
* encrypted transport
* authentication handled by SSH.

This is the best operational model.

## GNS3 Authentication Support

You can enable authentication in:

```text 
/home/user01/.config/GNS3/2.2/gns3_server.conf
```

Example:

```ini
[Server]
host = 0.0.0.0
port = 3080
auth = True
user = admin
password = StrongPassword123!
```

Then restart:

```bash 
sudo systemctl restart gns3
```

However:

* many operators still rely primarily on firewall restrictions
* because workshop credentials become operationally annoying.


### HTTPS Support

GNS3 itself does not provide strong production-grade HTTPS handling.

If needed:

* use nginx reverse proxy
* TLS termination
* HTTP auth.

But for workshops:

* NSG restriction
* SSH tunnel

is usually sufficient.

### Important Workshop Recommendation

For Azure environment it is strongly recommended:

| Component                | Recommendation             |
| ------------------------ | -------------------------- |
| SSH                      | Restricted IPs             |
| GNS3 3080                | Restricted to your IP only |
| Student access           | Via jumphost               |
| Authentication           | Optional                   |
| Public Internet exposure | Avoid                      |

---

### Another Important Security Point

Remember:

* uploaded appliance templates
* Docker containers
* QEMU images

can potentially execute arbitrary code on the GNS3 server.

*So exposing GNS3 publicly without restriction is risky.*

# How to telnet to routers

You can tunnel:

* remote GNS3 telnet console ports
* through SSH port 22
* to local ports on your laptop.

This avoids exposing:

* hundreds of telnet ports
* publicly on Azure.

# Example

Suppose:

* Azure VM public IP = `203.0.113.44`
* GNS3 router console port = `5011`

Create SSH tunnel:

```bash 
ssh -L 5011:127.0.0.1:5011 user01@203.0.113.44
```

Now your local machine gets:

```text 
localhost:5011
```

which forwards securely to:

```text
AzureVM:5011
```

---

# Connect via Telnet Locally

After tunnel established:

```bash id="9on0k7"
telnet localhost 5011
```

or from GNS3 locally:

```text id="2djlwm"
localhost:5011
```

---

# Important Detail

Use:

```text id="vjlwm0"
127.0.0.1
```

on the remote side.

NOT:

* public IP
* 0.0.0.0

because GNS3/Dynamips/QEMU usually bind locally.

---

# Multiple Console Ports

You can tunnel many ports simultaneously.

Example:

```bash 
ssh \
  -L 5001:127.0.0.1:5001 \
  -L 5002:127.0.0.1:5002 \
  -L 5011:127.0.0.1:5011 \
  -L 5012:127.0.0.1:5012 \
  user01@203.0.113.44
```


[Optional] Use SSH Config

On your laptop:

```bash
nano ~/.ssh/config
```

Example:

```sshconfig 
Host gns3lab
    HostName 203.0.113.44
    User user01

    LocalForward 5001 127.0.0.1:5001
    LocalForward 5002 127.0.0.1:5002
    LocalForward 5011 127.0.0.1:5011
    LocalForward 5012 127.0.0.1:5012
```

Then simply:

```bash 
ssh gns3lab
```


This means:

* only SSH port 22 exposed publicly
* all telnet traffic encrypted
* no public telnet ports
* much cleaner NSG rules.


## Background SSH Tunnel

```bash 
ssh -f -N -L 5011:127.0.0.1:5011 user01@203.0.113.44
```

Options:

* `-f` = background
* `-N` = no shell

Useful for persistent tunnels.


---

## References

- Azure VM documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/
- Azure CLI documentation: https://learn.microsoft.com/en-us/cli/azure/
- GNS3 documentation: https://docs.gns3.com/
- Azure D-Series documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/dasv5-dadsv5-series
- [OpenSSH Port Forwarding Documentation](https://man.openbsd.org/ssh#TCP_FORWARDING)
- [GNS3 Remote Server Documentation](https://docs.gns3.com/docs/using-gns3/administration/gns3-server/)

