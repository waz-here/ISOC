# How to set up an Azure Jumphost

This builds a simple Azure-based jumphost using an Ubuntu virtual machine.

## Purpose

Students SSH to the jumphost using a shared account. The jumphost provides a single access point into the lab environment.

This guide only covers the Azure VM deployment and basic SSH access. It does not configure a restricted lab menu, ZeroTier, GNS3 console access, or forced SSH commands. Refer to (How to set up the Jumphost)[readme.md]

This is a classroom access method, not a hardened security design.

## Assumptions

| Item | Value |
|---|---|
| Azure access | Azure Portal with Cloud Shell |
| Shell | Bash |
| Region | `southeastasia` |
| Resource group | `rg-jumphost` |
| VM name | `jumphost01` |
| Username | `user01` |
| VM image | `Ubuntu2204` |
| VM size | `Standard_B1s` |
| Access method | SSH |
| Authentication | Password |
| SSH port | `22` |
| NSG rule | `default-allow-ssh` |

## 1. Open Azure Cloud Shell

Log in to the Azure Portal.

Open Cloud Shell from the portal and select Bash.

Cloud Shell already includes the Azure CLI, so there is no need to install Azure CLI locally or run `az login`.

Verify the active subscription:

```bash
az account show -o table
```

If you have more than one subscription, list them:

```bash
az account list -o table
```

Set the correct subscription if required:

```bash
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

## 2. Find the Azure region name

To list available Azure locations:

```bash
az account list-locations --query '[].{Location:displayName,Name:name}' --output table | sort
```

For Singapore, the Azure region name is:

```text
southeastasia
```

You can filter the location list:

```bash
az account list-locations --query '[].{Location:displayName,Name:name}' --output table | sort | grep -iE "asia|singapore|africa"
```

## 3. Check small VM sizes

The newer Azure CLI command for VM sizes is:

```bash
az vm list-skus
```

The command can be slow because it queries the Azure SKU catalogue for the selected region.

To limit the search to small B-series VMs:

```bash
az vm list-skus \
  --location southeastasia \
  --resource-type virtualMachines \
  --size Standard_B1 \
  --query "[].{
    Name:name,
    vCPU: capabilities[?name=='vCPUs'] | [0].value,
    MemoryGB: capabilities[?name=='MemoryGB'] | [0].value
  }" \
  -o table
```

For a lightweight jumphost, `Standard_B1s` is usually sufficient. If the jumphost will have many concurrent student SSH sessions, consider `Standard_B1ms` or `Standard_B2s`.

## 4. Estimate jumphost cost

At the time of publishing, the estimated on-demand retail compute pricing for a Linux `Standard_B1s` VM in the `southeastasia` Azure region is approximately:

```text
0.012 USD/hour
```

These estimates are intended as a quick workshop budgeting reference only.

| Duration | Hours | Hourly rate | Formula | Estimated compute cost |
|---|---:|---:|---|---:|
| 6 hours | 6 | USD $0.012/hour | `0.012 × 6` | USD $0.07 |
| 1 day | 24 | USD $0.012/hour | `0.012 × 24` | USD $0.29 |
| 3 days | 72 | USD $0.012/hour | `0.012 × 72` | USD $0.86 |
| 5 days | 120 | USD $0.012/hour | `0.012 × 120` | USD $1.44 |
| 1 week | 168 | USD $0.012/hour | `0.012 × 168` | USD $2.02 |

### Costing notes

Prices change over time and vary by:

- Azure region
- VM size
- operating system
- currency
- subscription type
- reserved instances or savings plans
- organisation-specific discounts

These estimates are based on:

- pay-as-you-go retail pricing
- Linux VM pricing
- compute cost only

These estimates may not include:

- managed disks
- public IP addresses
- outbound bandwidth
- snapshots or backups
- taxes or GST
- enterprise agreements or discounts

Always verify current pricing before a workshop.

### Retrieve current pricing via API

Azure provides an unauthenticated Retail Prices API that can be used to retrieve current retail prices.

```bash
REGION="southeastasia"
SKU="Standard_B1s"

curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName eq 'Virtual Machines' and armRegionName eq '${REGION}' and armSkuName eq '${SKU}' and priceType eq 'Consumption'" \
| jq '.Items[] | {
    productName,
    armSkuName,
    armRegionName,
    retailPrice,
    unitOfMeasure,
    currencyCode
  }'
```

Refer to:

- Azure Retail Prices API: https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices
- Azure Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/
- Azure Linux VM pricing: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/

## 5. Check the Azure free account option

Microsoft offers Azure free services for eligible accounts. At the time of publishing, Microsoft lists free Azure services that include some services free for the first 12 months and other services that are always free.

For Linux virtual machines, the Azure free services page currently lists 750 hours each of eligible burstable Linux VM types for 12 months. This may be useful for testing or small training labs, depending on the VM size, region, account eligibility, storage use, public IP use, and outbound bandwidth.

Do not rely on the free account for workshop delivery without checking the current terms and confirming that the selected VM size and region are eligible.

Refer to:

- Azure free services: https://azure.microsoft.com/en-au/pricing/free-services/
- Azure free account signup: https://azure.microsoft.com/en-au/free/
- Azure free services documentation: https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-free-services

## 6. Set the deployment variables

In Cloud Shell, set the variables used by the deployment commands:

```bash
LOCATION="southeastasia"
RG="rg-jumphost"
VM="jumphost01"
USER="user01"
SIZE="Standard_B1s"
IMAGE="Ubuntu2204"
PASSWORD='ChangeMe123!'
```

Change the password before using this in a real lab. The password must meet Azure complexity requirements.

## 7. Create the resource group

Create the Azure resource group:

```bash
az group create \
  --name "$RG" \
  --location "$LOCATION"
```

Verify it exists:

```bash
az group list -o table
```

## 8. Create the jumphost VM

Create the Ubuntu VM with password authentication:

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

The VM creation process also creates supporting resources, including:

- virtual network
- subnet
- network interface
- public IP address
- network security group
- OS disk

By default, Azure creates an inbound SSH rule named `default-allow-ssh`.

## 9. Restrict SSH to a source IP

By default, the SSH rule may allow access from any source.

Find your current public IP address:

```bash
curl ifconfig.me
```

Store it as a variable:

```bash
MYIP="$(curl -s ifconfig.me)/32"
```

Update the existing SSH rule so that only your current public IP can connect:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes "$MYIP"
```

To use a known workshop source IP instead:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes 203.0.113.44/32
```

To allow a known workshop subnet:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes 203.0.113.0/24
```

Do not leave SSH open to the Internet unless there is a clear operational reason.

To allow any IP to connect:

```bash
az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes '*'
```

## 10. Display the public IP address

Show the VM IP details:

```bash
az vm list-ip-addresses \
  --resource-group "$RG" \
  --name "$VM" \
  -o table
```

Example output:

```text
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  ------------------
jumphost01        20.x.x.x             10.0.0.4
```

## 11. Test SSH access

From an allowed source IP, connect to the jumphost:

```bash
ssh user01@<PUBLIC_IP>
```

Example:

```bash
ssh user01@20.x.x.x
```

Expected result:

```bash
user01@jumphost01:~$
```

If the connection fails, check:

- the public IP address is correct
- the NSG source IP matches your current public IP
- the SSH rule is still enabled
- the VM is running
- the username and password are correct

## 12. Useful validation commands

List NSGs in the resource group:

```bash
az network nsg list \
  --resource-group "$RG" \
  -o table
```

List the NSG rules:

```bash
az network nsg rule list \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  -o table
```

Show the SSH rule:

```bash
az network nsg rule show \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  -o table
```

Show VM power state:

```bash
az vm get-instance-view \
  --resource-group "$RG" \
  --name "$VM" \
  --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
  -o tsv
```

## 13. Stop and start the jumphost

To stop the VM and release compute billing:

```bash
az vm deallocate \
  --resource-group "$RG" \
  --name "$VM"
```

To start it again:

```bash
az vm start \
  --resource-group "$RG" \
  --name "$VM"
```

Check the public IP address again after starting the VM:

```bash
az vm list-ip-addresses \
  --resource-group "$RG" \
  --name "$VM" \
  -o table
```

If the public IP is dynamic, it may change after deallocation.

## 14. Troubleshooting

### `az vm list-skus` appears to hang

The SKU command can be slow in Cloud Shell.

Use a narrower size filter:

```bash
az vm list-skus \
  --location southeastasia \
  --resource-type virtualMachines \
  --size Standard_B1 \
  -o table
```

Or use a known small VM size such as:

```text
Standard_B1s
```

### SSH is still open to everyone

Check the source address prefix on the SSH rule:

```bash
az network nsg rule show \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --query "{Name:name,Source:sourceAddressPrefix,SourcePrefixes:sourceAddressPrefixes,Port:destinationPortRange,Access:access}" \
  -o table
```

If the source is `*`, update it:

```bash
MYIP="$(curl -s ifconfig.me)/32"

az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes "$MYIP"
```

### Cannot SSH after restricting the NSG

Your public IP may have changed.

Check your current IP:

```bash
curl ifconfig.me
```

Update the NSG rule again:

```bash
MYIP="$(curl -s ifconfig.me)/32"

az network nsg rule update \
  --resource-group "$RG" \
  --nsg-name "${VM}NSG" \
  --name default-allow-ssh \
  --source-address-prefixes "$MYIP"
```

### NSG name is different

The examples assume the NSG is named:

```text
jumphost01NSG
```

List the NSGs in the resource group:

```bash
az network nsg list \
  --resource-group "$RG" \
  -o table
```

Then use the correct NSG name in the rule update command.

### SSH password login fails

Confirm the VM was created with password authentication:

```text
--authentication-type password
```

If the VM was created with SSH keys instead, recreate the VM using the password-based `az vm create` command.

## 15. Rollback

To delete the entire jumphost environment:

```bash
az group delete \
  --name "$RG"
```

Confirm the deletion when prompted.

This removes the VM and the supporting Azure resources in the resource group.

## References

- Azure CLI `az vm create`: https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
- Azure CLI `az vm list-skus`: https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-list-skus
- Azure CLI NSG rule update: https://learn.microsoft.com/en-us/cli/azure/network/nsg/rule?view=azure-cli-latest#az-network-nsg-rule-update
- Azure Network Security Groups: https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
- Azure VM states and billing: https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing
- Azure Retail Prices API: https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices
- Azure Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/
- Azure Linux VM pricing: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/
- Azure free services: https://azure.microsoft.com/en-au/pricing/free-services/
- Azure free account signup: https://azure.microsoft.com/en-au/free/
