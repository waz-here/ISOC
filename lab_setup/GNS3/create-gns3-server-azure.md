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
- Standard_D48as_v5 virtual machine
- Native GNS3 server installation

This guide assumes basic Linux and Azure familiarity.

# Estimated Workshop Cost

The following estimates are approximate only and may change depending on Azure pricing, region, storage selection, and bandwidth usage.

At the time of writing, the Standard_D48as_v4 instance provides:

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
| Standard_D48as_v4 | 48 | 192 GB | ~$4.60/hr | ~$110 |
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
| D48as_v4 | ~$120-130 |
| D48as_v5 | ~$125-140 |
| D48as_v6 | ~$140-160 |
| D48as_v7 | ~$155-180 |

The Standard_D48as_v5 provides a good balance between cost and performance for large CSR1000v based workshop environments.

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
  --size Standard_D48as_v4 \
  --query "[].{
    Name:name,
    vCPU: capabilities[?name=='vCPUs'] | [0].value,
    MemoryGB: capabilities[?name=='MemoryGB'] | [0].value
  }" \
  -o table
```

Note:

This command can take several minutes to complete.


# Create Variables

Create deployment variables:

```bash
LOCATION="southeastasia"
RG="rg-gns3"
VM="gns3srv01"
USER="user01"
SIZE="Standard_D48as_v4"
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
  --storage-sku Premium_LRS
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
sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update
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
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo usermod -aG docker $USER
sudo usermod -aG ubridge $USER
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

A Standard_D48as_v4 instance should comfortably support approximately:

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

---

## References

- Azure VM documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/
- Azure CLI documentation: https://learn.microsoft.com/en-us/cli/azure/
- GNS3 documentation: https://docs.gns3.com/
- Azure D-Series documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/dasv5-dadsv5-series

