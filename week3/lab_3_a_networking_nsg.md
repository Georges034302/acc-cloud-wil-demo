# Lab 3-A: 🌐 Networking & NSG Demo: Subnet + NIC Level Rules

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/181ce8a7-02b4-46cb-8bfb-33095568fc7d" />

## 🎯 Objective

Deploy a secure VM with both **subnet-level** and **NIC-level** NSGs and test access before and after allowing traffic.

---

## 🧭 Prerequisites

- Azure CLI installed and authenticated
- SSH client available

---

## ⚙️ Config and Deployment

### Configuration variables

```bash
# Edit these variables for your environment. Use unique suffixes to avoid collisions.
rg="network-demo-rg-$RANDOM"
location="australiaeast"
vnet="vnet-demo"
subnet="web-subnet"
subnet_prefix="10.0.1.0/24"
vnet_prefix="10.0.0.0/16"
subnet_nsg="subnet-nsg"
nic_nsg="nic-nsg"
pip="web-pip"
nic="web-nic"
vm="webvm"
admin_user="azureuser"
vm_size="Standard_B2s"

# Create resource group
az group create \
  --name "$rg" \
  --location "$location"
```

### 2️⃣ Create Virtual Network and Subnet

```bash
# Create a virtual network and a subnet for the VM
az network vnet create \
  --resource-group "$rg" \
  --name "$vnet" \
  --address-prefix "$vnet_prefix" \
  --subnet-name "$subnet" \
  --subnet-prefix "$subnet_prefix"
```

### 3️⃣ Create Subnet NSG and Associate with Subnet

```bash
# Create a Network Security Group for the subnet
az network nsg create \
  --resource-group "$rg" \
  --name "$subnet_nsg"

# Associate the NSG with the subnet
az network vnet subnet update \
  --vnet-name "$vnet" \
  --name "$subnet" \
  --resource-group "$rg" \
  --network-security-group "$subnet_nsg"
```

### 4️⃣ Create Public IP and NIC

```bash
# Create a public IP address for the VM
az network public-ip create \
  --resource-group "$rg" \
  --name "$pip"

# Create a network interface and attach the public IP
az network nic create \
  --resource-group "$rg" \
  --name "$nic" \
  --vnet-name "$vnet" \
  --subnet "$subnet" \
  --public-ip-address "$pip"
```

### 5️⃣ Create NIC NSG and Associate with NIC

```bash
# Create a Network Security Group for the NIC
az network nsg create \
  --resource-group "$rg" \
  --name "$nic_nsg"

# Associate the NSG with the NIC
az network nic update \
  --name "$nic" \
  --resource-group "$rg" \
  --network-security-group "$nic_nsg"
```

### 6️⃣ Create Ubuntu VM with Password Authentication + Install Apache

```bash
# Prompt for a strong password for the VM admin account (or set VM_PASSWORD in your shell)
if [ -z "$VM_PASSWORD" ]; then
  read -s -p "🔑 Enter a strong password for the VM admin account: " VM_PASSWORD
  echo
fi

echo "🚀 Creating VM..."

# Create the Ubuntu VM (uses Ubuntu 22.04 LTS image alias)
az vm create \
  --resource-group "$rg" \
  --name "$vm" \
  --image Ubuntu2204 \
  --nics "$nic" \
  --admin-username "$admin_user" \
  --admin-password "$VM_PASSWORD" \
  --size "$vm_size"

# Install Apache on the VM (required for HTTP test)
az vm run-command invoke \
  --resource-group "$rg" \
  --name "$vm" \
  --command-id RunShellScript \
  --scripts "sudo apt-get update && sudo apt-get install -y apache2"
```

---

## 🔍 Post-Deployment Testing (Before NSG Rules)

### ❌ SSH to VM (Expected to Fail)

```bash
# Try to SSH to the VM (should fail due to NSG rules)
PIP=$(az vm list-ip-addresses \
  --resource-group "$rg" \
  --name "$vm" \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

ssh "$admin_user"@"$PIP"
```

### ❌ HTTP Access (Expected to Fail)

```bash
# Try to access the Apache web server (should fail)
# Use the public IP from the previous step
echo "Visit: http://$PIP"
```

---

## 🔧 Update NSG Rules (Allow SSH + HTTP)

### ✅ Subnet NSG Rules

```bash
# Allow SSH traffic at the subnet level
az network nsg rule create \
  --resource-group "$rg" \
  --nsg-name "$subnet_nsg" \
  --name allow-ssh-subnet \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --access Allow \
  --source-address-prefixes '*'

# Allow HTTP traffic at the subnet level
az network nsg rule create \
  --resource-group "$rg" \
  --nsg-name "$subnet_nsg" \
  --name allow-http-subnet \
  --priority 110 \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 80 \
  --access Allow \
  --source-address-prefixes '*'
```

### ✅ NIC NSG Rules

```bash
# Allow SSH traffic at the NIC level
az network nsg rule create \
  --resource-group "$rg" \
  --nsg-name "$nic_nsg" \
  --name allow-ssh-nic \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --access Allow \
  --source-address-prefixes '*'

# Allow HTTP traffic at the NIC level
az network nsg rule create \
  --resource-group "$rg" \
  --nsg-name "$nic_nsg" \
  --name allow-http-nic \
  --priority 110 \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 80 \
  --access Allow \
  --source-address-prefixes '*'
```

---

## ✅ Post-Rule Testing (Should Succeed)

### ✔️ SSH to VM

```bash
# Try to SSH to the VM (should now succeed)
PIP=$(az vm list-ip-addresses \
  --resource-group "$rg" \
  --name "$vm" \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

ssh "$admin_user"@"$PIP"
```

### ✔️ HTTP Access

```bash
# Access the Apache web server in your browser (should now succeed)
echo "Visit: http://$PIP → Apache Welcome Page"
```

---

## 🧼 Clean Up

```bash
# Clean up all resources created in this lab
az group delete --name "$rg" --yes --no-wait
```

