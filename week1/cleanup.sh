#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load variables from setup.sh
echo "Loading variables from setup.sh..."
source ./setup.sh

# 1. Stop the Virtual Machine
echo "Stopping Virtual Machine: $VM_NAME..."
az vm stop \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME"

# 2. Deallocate the Virtual Machine
echo "Deallocating Virtual Machine: $VM_NAME..."
az vm deallocate \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME"

# 3. Delete the Virtual Machine
echo "Deleting Virtual Machine: $VM_NAME..."
az vm delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --yes

# 4. Disassociate Public IP from NIC
echo "Disassociating Public IP: $VM_PUBLIC_IP_NAME from NIC: $NIC_NAME..."
az network nic update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NIC_NAME" \
  --remove ipConfigurations[0].publicIpAddress

# 5. Delete the Public IP Address
echo "Deleting Public IP Address: $VM_PUBLIC_IP_NAME..."
az network public-ip delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_PUBLIC_IP_NAME"

# 6. Delete the Network Interface Card (NIC)
echo "Deleting Network Interface Card: $NIC_NAME..."
az network nic delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NIC_NAME"

# 7. Delete the Network Security Group (NSG)
echo "Deleting Network Security Group: $NSG_NAME..."
az network nsg delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NSG_NAME"

# 8. Delete the Virtual Network (VNet)
echo "Deleting Virtual Network: $VNET_NAME..."
az network vnet delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME"

# 9. Delete the Resource Group
echo "Deleting Resource Group: $RESOURCE_GROUP..."
az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait

echo "Cleanup completed successfully!"