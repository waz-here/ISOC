# Creating a GNS3 Server on Microsoft Azure

## Overview

This guide explains how to deploy a temporary GNS3 server on Microsoft Azure for workshop, training, and lab environments.

The environment is designed for:

* Network operator workshops
* GNS3 routing labs
* Temporary cloud-based training environments
* Remote workshop access
* Repeatable infrastructure deployment

This guide uses:

* Microsoft Azure Cloud Shell
* Azure CLI
* Ubuntu 24.04 LTS
* `Standard_D48s_v4` virtual machine
* Native GNS3 server installation

The document assumes basic familiarity with:

* Linux command-line administration
* SSH access
* Microsoft Azure concepts
* GNS3 operations



## Recommended architecture

The following architecture is recommended for temporary workshop deployments:

```text
Laptop
  |
SSH Tunnel
  |
Azure NSG
  |
GNS3 Server
  |
CSR1000v Routers
```

This approach:

* minimises public exposure
* encrypts management traffic
* avoids exposing telnet console ports publicly
* simplifies firewall configuration



## Naming conventions

The following naming conventions are used throughout this guide.

| Object                 | Naming Convention |
| ---------------------- | ----------------- |
| Resource Group         | `rg-gns3`         |
| Virtual Machine        | `gns3srv01`       |
| Username               | `user01`          |
| Network Security Group | `gns3srv01NSG`    |



## Estimated workshop cost

> [!IMPORTANT]
> Azure pricing changes regularly. All pricing estimates are approximate only and depend on:
>
> * Azure region
> * storage type
> * VM generation
> * network traffic
> * workshop duration

At the time of writing, the `Standard_D48s_v4` instance provides:

* 48 vCPU
* 192 GB RAM
* AMD EPYC Rome (7002) CPUs
* Premium SSD support

The following estimates assume:

* a three-day workshop
* approximately eight hours runtime per day
* approximately 24 hours total runtime
* Ubuntu Linux
* Premium SSD storage

| VM Size             | vCPU | RAM    | Approx Hourly Cost (USD) | Approx 24hr Compute Cost (USD) |
| ------------------- | ---- | ------ | ------------------------ | ------------------------------ |
| `Standard_D48s_v4`  | 48   | 192 GB | ~$4.60/hr                | ~$110                          |
| `Standard_D48as_v5` | 48   | 192 GB | ~$4.80/hr                | ~$115                          |
| `Standard_D48as_v6` | 48   | 192 GB | ~$5.20-5.60/hr           | ~$125-135                      |
| `Standard_D48as_v7` | 48   | 192 GB | ~$5.80-6.50/hr           | ~$140-156                      |

Additional costs typically include:

| Item                | Approximate Cost   |
| ------------------- | ------------------ |
| Premium SSD storage | ~$5-15             |
| Public IP address   | <$1                |
| Network traffic     | Usually negligible |

Estimated total workshop cost:

| VM         | Approximate Total Workshop Cost |
| ---------- | ------------------------------- |
| `D48s_v4`  | ~$120-130                       |
| `D48as_v5` | ~$125-140                       |
| `D48as_v6` | ~$140-160                       |
| `D48as_v7` | ~$155-180                       |

The `Standard_D48s_v4` provides a good balance between cost and performance for large CSR1000v workshop environments.

### Recommended deployment process

1. Deploy the Azure VM
2. Install the GNS3 server
3. Upload router images
4. Import the topology
5. Test startup behaviour
6. Configure the jumphost
7. Provide participant access
8. Deallocate the VM after the workshop



## Launch Azure Cloud Shell

Log in to the Azure Portal:

* [https://portal.azure.com](https://portal.azure.com)

Launch Azure Cloud Shell from the portal.

Select:

* Bash

The Azure CLI is pre-installed in Cloud Shell.



## Select an Azure region

List Azure regions:

```bash
az account list-locations \
  --query '[].{Location:displayName,Name:name}' \
  --output table | sort
```

Common nearby regions include:

* `southeastasia` (Singapore)
* `eastasia` (Hong Kong)
* `australiaeast` (Sydney)
* `australiasoutheast` (Melbourne)
* `southafricanorth` (Johannesburg)

For Asia Pacific workshops, Singapore is commonly used.



## Check VM availability

The following command checks available `D48s_v4` SKUs:

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

> [!NOTE]
> This command can take several minutes to complete.



## Check Azure quotas before deployment

Large Azure virtual machines require sufficient vCPU quota in the selected region.

This is important because a `Standard_D48s_v4` VM requires:

* 48 vCPU
* 192 GB RAM

Azure quota is applied per subscription and per region.

There are two quota types to check:

| Quota Type           | Purpose                                        |
| -------------------- | ---------------------------------------------- |
| Total Regional vCPUs | Maximum total vCPUs allowed in the region      |
| VM Family vCPUs      | Maximum vCPUs allowed for a specific VM family |

For the `Standard_D48s_v4` VM, check:

* Total Regional vCPUs
* Standard DSv4 Family vCPUs

### Check current quota

```bash
az vm list-usage \
  --location southeastasia \
  -o table
```

Or display only relevant VM families:

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
Standard DSv4 Family vCPUs          0               0
```

In this example, the subscription cannot deploy a `Standard_D48s_v4` VM because:

* the regional quota is only 10 vCPU
* the VM requires 48 vCPU
* the DSv4 family quota is 0 vCPU

### Example quota error

If quota is insufficient, deployment may fail with an error similar to:

```text
QuotaExceeded
Location: southeastasia
Current Limit: 10
Current Usage: 0
Additional Required: 48
Minimum New Limit Required: 48
```

### Request a quota increase

In the Azure Portal:

1. Search for `Quotas`
2. Select `Compute`
3. Filter by region
4. Request an increase for `Total Regional vCPUs`
5. Request an increase for `Standard DSv4 Family vCPUs`

Recommended quota request:

| Quota                       | Recommended Value |
| --------------------------- | ----------------- |
| Total Regional vCPUs        | 64                |
| Standard DSv4 Family vCPUs  | 64                |
| Standard EASv5 Family vCPUs | 64                |

Requesting 64 vCPU provides enough capacity for:

* one large GNS3 server
* one jumphost
* testing overhead
* temporary rebuild capacity

### Recommended backup regions

Quota and VM availability can vary by region.

| Region             | Purpose                              |
| ------------------ | ------------------------------------ |
| `southeastasia`    | Primary Asia Pacific workshop region |
| `australiaeast`    | Backup region                        |
| `eastasia`         | Backup region                        |
| `southafricanorth` | Africa workshop region               |

> [!IMPORTANT]
> Quota approval does not guarantee VM allocation.
>
> Azure deployments can still fail if the selected region does not currently have sufficient capacity for the requested VM size.

For workshop deployments:

* request quota early
* test the deployment several days before the workshop
* avoid first deployment on the workshop day
* maintain a backup region or VM size

For additional information:

* [https://learn.microsoft.com/en-us/azure/quotas/regional-quota-requests](https://learn.microsoft.com/en-us/azure/quotas/regional-quota-requests)
* [https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests](https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests)



## Create deployment variables

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

> [!WARNING]
> Avoid using weak passwords in production or publicly accessible environments.
>
> SSH key authentication is strongly recommended.



## Create the resource group

```bash
az group create \
  --name "$RG" \
  --location "$LOCATION"
```

Validate resource group creation:

```bash
az group show \
  --name "$RG" \
  -o table
```



## Create the GNS3 server VM

```bash
az vm create \
  --resource-group "$RG" \
  --name "$VM" \
  --image "$IMAGE" \
  --size "$SIZE" \
  --admin-username "$USER" \
  --authentication-type password \
  --admin-password "$PASSWORD"
```

> [!NOTE]
> The deployment process can take several minutes.

Validate VM creation:

```bash
az vm list \
  --resource-group "$RG" \
  -o table
```



## Restrict SSH access

Determine your public IP address:

```bash
curl ifconfig.me
```

Example:

```text
203.0.113.44
```

Restrict SSH access to your public IP:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes 203.0.113.44/32
```

If required, restore SSH access from any IP:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes '*'
```

> [!WARNING]
> Avoid leaving SSH open to `0.0.0.0/0` unless operationally necessary.



## Retrieve the public IP address

```bash
az vm list-ip-addresses \
  --resource-group "$RG" \
  --name "$VM" \
  -o table
```



## Connect via SSH

```bash
ssh user01@PUBLIC_IP
```

Validate connectivity:

```bash
hostname
whoami
```



## Update Ubuntu

```bash
sudo apt update && sudo apt dist-upgrade -y && sudo apt -y autoremove
```

During installation, the package installer prompts for confirmation to allow non-root access to `ubridge` and `wireshark`.

To automate these prompts, use `debconf-set-selections` before installation.

### Preseed ubridge

```bash
echo "ubridge ubridge/install-setuid boolean true" | sudo debconf-set-selections
```

This automatically answers:

```text
Should non-superusers be able to run GNS3?
YES
```

### Preseed Wireshark

```bash
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
```

This automatically answers:

```text
Should non-superusers be able to capture packets?
YES
```



## Add the GNS3 repository

```bash
sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update
```



## Install GNS3 server dependencies

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



## Verify KVM support

```bash
sudo kvm-ok
```

Expected output:

```text
KVM acceleration can be used
```



## Install the GNS3 server

```bash
sudo apt install -y gns3-server gns3-gui
```

Validate installation:

```bash
gns3server --version
```



## Enable required services

```bash
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo systemctl enable docker
sudo systemctl start docker
```

Validate service status:

```bash
sudo systemctl status libvirtd
sudo systemctl status docker
```



## Configure user permissions

```bash
sudo usermod -aG ubridge,wireshark,libvirt,kvm,docker "$USER"
```

Log out and reconnect via SSH after applying group permissions.

Verify group membership:

```bash
id
```



## Verify CPU and RAM

```bash
lscpu
```

```bash
free -h
```

Expected approximate values:

| Resource | Expected |
| -------- | -------- |
| vCPU     | 48       |
| RAM      | ~192 GB  |



## Recommended storage layout

Recommended locations:

| Purpose          | Location             |
| ---------------- | -------------------- |
| GNS3 projects    | `/opt/gns3/projects` |
| CSR qcow2 images | `/opt/gns3/images`   |
| Packet captures  | `/opt/gns3/captures` |
| Temporary files  | `/tmp`               |

Example:

```bash
sudo mkdir -p /opt/gns3/{projects,images,captures}
sudo chown -R $USER:$USER /opt/gns3
```



## CSR1000v sizing guidance

CSR1000v routers consume significant RAM and CPU resources.

Approximate sizing:

| Resource        | Approximate Usage |
| --------------- | ----------------- |
| RAM per router  | 3-4 GB            |
| vCPU per router | 1                 |

A `Standard_D48s_v4` instance should comfortably support approximately:

* 40-50 CSR1000v routers

Actual capacity depends on:

* topology complexity
* routing convergence
* traffic generation
* packet captures
* active services



## Enable access to the GNS3 server

### Create a systemd service

The Ubuntu GNS3 packages install `gns3server`, but they do not always create a `gns3.service` systemd unit.

Verify the binary:

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

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable gns3
sudo systemctl start gns3
```

Validate service status:

```bash
sudo systemctl status gns3
```

If the service fails:

```bash
journalctl -u gns3 -n 50 --no-pager
```



## Configure Azure NSG access for GNS3

Allow GNS3 access on TCP port `3080`:

```bash
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

* `YOUR_PUBLIC_IP` with your public IP address



## Security considerations

> [!WARNING]
> By default, the standalone `gns3server` process:
>
> * does not enable authentication
> * does not use HTTPS
> * exposes the REST API publicly
> * can allow appliance uploads and remote control
>
> Restrict access carefully.

The following URL exposes the GNS3 web UI:

```text
http://YOUR_PUBLIC_IP:3080/static/web-ui/server/1/projects
```

The following configuration:

```ini
ExecStart=/usr/bin/gns3server --host 0.0.0.0 --port 3080
```

causes the GNS3 server to:

* listen on all interfaces
* expose the service publicly

Any user able to reach TCP port `3080` may be able to:

* upload projects
* control routers
* access captures
* interact with appliances
* potentially execute arbitrary code

### Recommended protection model

Restrict access to:

* your public IP
* a workshop jumphost
* trusted management systems

Avoid:

* unrestricted public access
* `0.0.0.0/0` source ranges

Restrict access using Azure NSG rules:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name allow-gns3 \
  --source-address-prefixes YOUR_IP/32
```

Restricting NSG access is the primary security control for temporary workshop deployments.



## Recommended SSH tunnel access model

SSH tunnelling provides a more secure operational model than exposing GNS3 publicly.

Example:

```text
Laptop
  ->
SSH tunnel
  ->
Azure GNS3 Server
```

Create an SSH tunnel:

```bash
ssh -L 3080:localhost:3080 user01@SERVER_IP
```

Then connect locally to:

```text
localhost:3080
```

Benefits:

* no public TCP/3080 exposure
* encrypted transport
* SSH authentication
* simpler firewall policy



## Enable optional GNS3 authentication

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

Restart the service:

```bash
sudo systemctl restart gns3
```

> [!NOTE]
> Many workshop operators rely primarily on firewall restrictions because centrally managed workshop credentials can become operationally difficult.



## HTTPS considerations

GNS3 does not provide strong production-grade HTTPS support.

If HTTPS is required:

* deploy an nginx reverse proxy
* use TLS termination
* implement HTTP authentication

For most temporary workshop environments, the following is usually sufficient:

* Azure NSG restriction
* SSH tunnelling



## Workshop security recommendations

| Component                | Recommendation          |
| ------------------------ | ----------------------- |
| SSH                      | Restrict to trusted IPs |
| GNS3 TCP/3080            | Restrict to trusted IPs |
| Student access           | Use a jumphost          |
| Authentication           | Optional                |
| Public Internet exposure | Avoid                   |

> [!WARNING]
> Uploaded appliance templates, Docker containers, and QEMU images may execute arbitrary code on the GNS3 server.
>
> Avoid exposing GNS3 publicly without firewall restrictions.



## Telnet access via SSH tunnel

You can securely access router console ports through SSH tunnelling.

This avoids exposing large numbers of telnet ports publicly.

Example assumptions:

* Azure VM public IP: `203.0.113.44`
* GNS3 router console port: `5011`

Create an SSH tunnel:

```bash
ssh -L 5011:127.0.0.1:5011 user01@203.0.113.44
```

Your local system now has:

```text
localhost:5011
```

which securely forwards traffic to:

```text
AzureVM:5011
```

### Connect locally via telnet

After the tunnel is established:

```bash
telnet localhost 5011
```

Use:

```text
127.0.0.1
```

on the remote side rather than:

* a public IP
* `0.0.0.0`

because GNS3, Dynamips, and QEMU commonly bind locally.



## Tunnel multiple console ports

You can tunnel multiple ports simultaneously.

Example:

```bash
ssh \
  -L 5001:127.0.0.1:5001 \
  -L 5002:127.0.0.1:5002 \
  -L 5011:127.0.0.1:5011 \
  -L 5012:127.0.0.1:5012 \
  user01@203.0.113.44
```



## Optional SSH configuration

Edit your SSH configuration:

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

Then connect using:

```bash
ssh gns3lab
```

Benefits:

* only SSH port 22 exposed publicly
* encrypted telnet traffic
* cleaner NSG rules
* simplified operational management



## Background SSH tunnel

```bash
ssh -f -N -L 5011:127.0.0.1:5011 user01@203.0.113.44
```

Options:

| Option | Purpose                |
| ------ | ---------------------- |
| `-f`   | Run in background      |
| `-N`   | Do not execute a shell |

This approach is useful for persistent console tunnels.



## Deallocate the VM after the workshop

> [!IMPORTANT]
> Stopping Ubuntu does not stop Azure compute billing.
>
> Use `az vm deallocate` to stop VM charges.

Deallocate the VM:

```bash
az vm deallocate \
  --resource-group "$RG" \
  --name "$VM"
```

Restart the VM:

```bash
az vm start \
  --resource-group "$RG" \
  --name "$VM"
```



## Delete the environment

Delete the complete Azure resource group:

```bash
az group delete --name "$RG"
```



## Troubleshooting

### GNS3 service fails to start

Check service status:

```bash
sudo systemctl status gns3
```

Check logs:

```bash
journalctl -u gns3 -n 50 --no-pager
```

### KVM acceleration unavailable

Verify KVM support:

```bash
sudo kvm-ok
```

### Unable to access TCP/3080

Verify:

* Azure NSG rules
* local firewall configuration
* `gns3server` service status
* listening sockets

Check listening sockets:

```bash
ss -tulpn | grep 3080
```

### SSH connectivity issues

Verify:

* NSG source IP restrictions
* public IP address
* VM running state
* local outbound firewall rules

---

## References

* Azure VM documentation: [https://learn.microsoft.com/en-us/azure/virtual-machines/](https://learn.microsoft.com/en-us/azure/virtual-machines/)
* Azure CLI documentation: [https://learn.microsoft.com/en-us/cli/azure/](https://learn.microsoft.com/en-us/cli/azure/)
* GNS3 documentation: [https://docs.gns3.com/](https://docs.gns3.com/)
* Azure D-Series documentation: [https://learn.microsoft.com/en-us/azure/virtual-machines/dasv5-dadsv5-series](https://learn.microsoft.com/en-us/azure/virtual-machines/dasv5-dadsv5-series)
* OpenSSH Port Forwarding Documentation: [https://man.openbsd.org/ssh#TCP_FORWARDING](https://man.openbsd.org/ssh#TCP_FORWARDING)
* GNS3 Remote Server Documentation: [https://docs.gns3.com/docs/using-gns3/administration/gns3-server/](https://docs.gns3.com/docs/using-gns3/administration/gns3-server/)
