# How to set up an Azure Jumphost

This builds a simple Azure-based jumphost using an Ubuntu virtual machine.

## Purpose

Students SSH to the jumphost using a shared account. The jumphost provides a single access point into the lab environment.

This guide only covers the Azure VM deployment and basic SSH access. It does not configure a restricted lab menu, ZeroTier, GNS3 console access, or forced SSH commands.

This is a classroom access method, not a hardened security design.

## Assumptions

Item Value
Azure access Azure Portal with Cloud Shell
Shell Bash
Region `southeastasia`
Resource group `rg-jumphost`
VM name `jumphost01`
Username `user01`
VM image `Ubuntu2204`
VM size `Standard_B1s`
Access method SSH
Authentication Password
SSH port `22`
NSG rule `default-allow-ssh`

## 1. Open Azure Cloud Shell

Log in to the Azure Portal.

Open Cloud Shell from the portal and select Bash.

Cloud Shell already includes the Azure CLI, so there is no need to install Azure CLI locally or run `az login`.

Verify the active subscription:


    az account show -o table


If you have more than one subscription, list them:

    az account list -o table

Set the correct subscription if required:

    az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"

## 2. Find the Azure region name

To list available Azure locations:

    az account list-locations --query '[].{Location:displayName,Name:name}' --output table | sort

For Singapore, the Azure region name is:

    southeastasia

You can filter the location list:

    az account list-locations --query '[].{Location:displayName,Name:name}' --output table | sort | grep -iE "asia|singapore|africa"

## 3. Check small VM sizes

The newer Azure CLI command for VM sizes is:

    az vm list-skus

The command can be slow because it queries the Azure SKU catalogue for the selected region.

To limit the search to small B-series VMs:

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

For a lightweight jumphost, `Standard_B1s` is usually sufficient.

If the jumphost will have many concurrent student SSH sessions, consider `Standard_B1ms` or `Standard_B2s`.

## 4. Set the deployment variables

In Cloud Shell, set the variables used by the deployment commands:

    LOCATION="southeastasia"
    RG="rg-jumphost"
    VM="jumphost01"
    USER="user01"
    SIZE="Standard_B1s"
    IMAGE="Ubuntu2204"
    PASSWORD='LabPassword123!'

Change the password before using this in a real lab.

The password must meet Azure complexity requirements.

## 5. Create the resource group

Create the Azure resource group:

    az group create \
      --name "$RG" \
      --location "$LOCATION"

Verify it exists:

    az group list -o table

## 6. Create the jumphost VM

Create the Ubuntu VM with password authentication:

    az vm create \
      --resource-group "$RG" \
      --name "$VM" \
      --image "$IMAGE" \
      --size "$SIZE" \
      --admin-username "$USER" \
      --authentication-type password \
      --admin-password "$PASSWORD"

The VM creation process also creates supporting resources, including:

  * virtual network
  * subnet
  * network interface
  * public IP address
  * network security group
  * OS disk

By default, Azure creates an inbound SSH rule named `default-allow-ssh`.

## 7. Restrict SSH to a source IP

By default, the SSH rule may allow access from any source.

Find your current public IP address:

    curl ifconfig.me

Store it as a variable:

    MYIP="$(curl -s ifconfig.me)/32"

Update the existing SSH rule so that only your current public IP can connect:

    az network nsg rule update \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      --source-address-prefixes "$MYIP"

To use a known workshop source IP instead:

    az network nsg rule update \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      --source-address-prefixes 203.0.113.44/32

To allow a known workshop subnet:

    az network nsg rule update \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      --source-address-prefixes 203.0.113.0/24

Do not leave SSH open to the Internet unless there is a clear operational reason.

## 8. Display the public IP address

Show the VM IP details:

    az vm list-ip-addresses \
      --resource-group "$RG" \
      --name "$VM" \
      -o table

Example output:

    VirtualMachine    PublicIPAddresses    PrivateIPAddresses
    ----------------  -------------------  ------------------
    jumphost01        20.x.x.x             10.0.0.4

## 9. Test SSH access

From an allowed source IP, connect to the jumphost:

    ssh user01@<PUBLIC_IP_ADDRESS>

Example:

    ssh user01@20.x.x.x

Expected result:

    user01@jumphost01:~$

If the connection fails, check:

  * the public IP address is correct
  * the NSG source IP matches your current public IP
  * the SSH rule is still enabled
  * the VM is running
  * the username and password are correct

## 10. Useful validation commands

List NSGs in the resource group:

    az network nsg list \
      --resource-group "$RG" \
      -o table

List the NSG rules:

    az network nsg rule list \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      -o table

Show the SSH rule:

    az network nsg rule show \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      -o table

Show VM power state:

    az vm get-instance-view \
      --resource-group "$RG" \
      --name "$VM" \
      --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
      -o tsv

## 11. Stop and start the jumphost

To stop the VM and release compute billing:

    az vm deallocate \
      --resource-group "$RG" \
      --name "$VM"

To start it again:

    az vm start \
      --resource-group "$RG" \
      --name "$VM"

Check the public IP address again after starting the VM:

    az vm list-ip-addresses \
      --resource-group "$RG" \
      --name "$VM" \
      -o table

If the public IP is dynamic, it may change after deallocation.

## 12. Troubleshooting

### `az vm list-skus` appears to hang

The SKU command can be slow in Cloud Shell.

Use a narrower size filter:

    az vm list-skus \
      --location southeastasia \
      --resource-type virtualMachines \
      --size Standard_B1 \
      -o table

Or use a known small VM size such as:

    Standard_B1s

### SSH is still open to everyone

Check the source address prefix on the SSH rule:

    az network nsg rule show \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      --query "{Name:name,Source:sourceAddressPrefix,SourcePrefixes:sourceAddressPrefixes,Port:destinationPortRange,Access:access}" \
      -o table

If the source is `*`, update it:

    MYIP="$(curl -s ifconfig.me)/32"

    az network nsg rule update \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      --source-address-prefixes "$MYIP"

### Cannot SSH after restricting the NSG

Your public IP may have changed.

Check your current IP:

    curl ifconfig.me

Update the NSG rule again:

    MYIP="$(curl -s ifconfig.me)/32"

    az network nsg rule update \
      --resource-group "$RG" \
      --nsg-name "${VM}NSG" \
      --name default-allow-ssh \
      --source-address-prefixes "$MYIP"

### NSG name is different

The examples assume the NSG is named:

    jumphost01NSG

List the NSGs in the resource group:

    az network nsg list \
      --resource-group "$RG" \
      -o table

Then use the correct NSG name in the rule update command.

### SSH password login fails

Confirm the VM was created with password authentication:

    --authentication-type password

If the VM was created with SSH keys instead, recreate the VM using the password-based `az vm create` command.

## 13. Rollback

To delete the entire jumphost environment:

    az group delete \
      --name "$RG"

Confirm the deletion when prompted.

This removes the VM and the supporting Azure resources in the resource group.

## References

  * Azure CLI `az vm create`: https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
  * Azure CLI `az vm list-skus`: https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-list-skus
  * Azure CLI NSG rule update: https://learn.microsoft.com/en-us/cli/azure/network/nsg/rule?view=azure-cli-latest#az-network-nsg-rule-update
  * Azure Network Security Groups: https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
  * Azure VM states and billing: https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing
