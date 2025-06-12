#!/bin/bash

# Step 1: Define and export temporary variables for Azure setup
export RESOURCE_GROUP="MyResourceGroup"  
export LOCATION="australiaeast"
export VNET_NAME="MyVNet"  
export CIDR="10.0.0.0/16"
export SUBNET_NAME="FrontendSubnet"  
export SUBNET_PREFIX="10.0.1.0/24"    
export NSG_NAME="MyNSG"  
export VM_NAME="webserver"  
export VM_IMAGE="Ubuntu2404"  
export VM_SIZE="Standard_B2ms"  
export VM_USERNAME="azureuser"  
export VM_PUBLIC_IP_NAME="MyPublicIP"  
export NIC_NAME="MyNIC" 
export HTML_FILE_PATH="/var/www/html/index.html"  


# Display the variables (optional, to confirm)
echo "Setup Environment Variables ..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "VNet Name: $VNET_NAME"
echo "VNet Address Prefix: $CIDR"
echo "Subnet Name: $SUBNET_NAME"
echo "Subnet Prefix: $SUBNET_PREFIX"
echo "NSG Name: $NSG_NAME"
echo "Webserver Name: $VM_NAME"
echo "VM Size: $VM_SIZE"
echo "NIC Name: $NIC_NAME"
echo "Public IP Name: $VM_PUBLIC_IP_NAME"
echo "Username: $VM_USERNAME"
echo "Website: $HTML_FILE_PATH"