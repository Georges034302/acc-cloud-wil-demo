#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load variables from setup.sh
echo "Loading variables from setup.sh..."
source ./setup.sh

# 1. Create Resource Group
echo "Creating Resource Group: $RESOURCE_GROUP in $LOCATION..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# 2. Create Virtual Network (VNet)
echo "Creating Virtual Network: $VNET_NAME with Subnet: $SUBNET_NAME..."
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --location "$LOCATION" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix "$SUBNET_PREFIX"

# 3. Create Network Security Group (NSG)
echo "Creating Network Security Group: $NSG_NAME..."
az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NSG_NAME" \
  --location "$LOCATION"

# 4. Add NSG Rule for HTTP (Port 80)
echo "Adding NSG rule to allow HTTP (port 80) to $NSG_NAME..."
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name AllowHTTP \
  --protocol tcp \
  --direction inbound \
  --priority 1000 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-port-ranges 80 \
  --access allow

# 5. Create Public IP Address
echo "Creating Public IP Address: $VM_PUBLIC_IP_NAME..."
az network public-ip create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_PUBLIC_IP_NAME" \
  --allocation-method Dynamic \
  --location "$LOCATION" \
  --sku Basic

# 6. Create Network Interface Card (NIC)
echo "Creating Network Interface Card: $NIC_NAME..."
az network nic create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NIC_NAME" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME" \
  --public-ip-address "$VM_PUBLIC_IP_NAME" \
  --location "$LOCATION"

# 7. Create Virtual Machine (VM)
echo "Creating Virtual Machine: $VM_NAME..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$VM_IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$VM_USERNAME" \
  --authentication-type password \
  --nics "$NIC_NAME" \
  --location "$LOCATION" \
  --no-wait

# Wait for the VM to be created (if no-wait is used)
echo "Waiting for VM $VM_NAME to be created..."
az vm wait --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --created

# 8. Install Apache Web Server and Ensure it's Running
echo "Installing Apache web server on VM: $VM_NAME..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts \
    "sudo apt-get update" \
    "sudo apt-get install -y apache2" \
    "sudo systemctl enable apache2" \
    "sudo systemctl start apache2"

# 9. Create HTML Page to Serve on the Web Server
echo "Creating sample HTML page on VM: $VM_NAME..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts \
    "echo '<html><body><h1>Hello from my VM!</h1></body></html>' | sudo tee /var/www/html/index.html"

# 10. Get the VM Public IP to Access HTTP
echo "Fetching the public IP of VM: $VM_NAME..."
VM_PUBLIC_IP=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query "publicIps" \
  --output tsv)

# Output VM public IP for HTTP access
echo "=================================================="
echo "Your VM is accessible at: http://$VM_PUBLIC_IP"
echo "=================================================="