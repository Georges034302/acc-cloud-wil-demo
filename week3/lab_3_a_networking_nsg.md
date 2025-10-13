# Lab 3-A: 🌐 Networking & NSG Demo: Subnet + NIC Level Rules

<img width="1024" height="1536" alt="ZIMG" src="https://github.com/user-attachments/assets/0953b63e-f66d-40fe-9165-58a5f0d6f031" />

## 🎯 Objective

Deploy a secure VM with both **subnet-level** and **NIC-level** NSGs and test access before and after allowing traffic.

---

## 🧭 Prerequisites

- Azure CLI installed and authenticated
- SSH client available

---

## ⚙️ Config and Deployment

### 1️⃣ Create Resource Group

```bash
# Create a new resource group for all networking resources
az group create \
  --name network-demo-rg \
  --location australiaeast
```

### 2️⃣ Create Virtual Network and Subnet

```bash
# Create a virtual network and a subnet for the VM
az network vnet create \
  --resource-group network-demo-rg \
  --name vnet-demo \
  --address-prefix 10.0.0.0/16 \
  --subnet-name web-subnet \
  --subnet-prefix 10.0.1.0/24
```

### 3️⃣ Create Subnet NSG and Associate with Subnet

```bash
# Create a Network Security Group for the subnet
az network nsg create \
  --resource-group network-demo-rg \
  --name subnet-nsg

# Associate the NSG with the subnet
az network vnet subnet update \
  --vnet-name vnet-demo \
  --name web-subnet \
  --resource-group network-demo-rg \
  --network-security-group subnet-nsg
```

### 4️⃣ Create Public IP and NIC

```bash
# Create a public IP address for the VM
az network public-ip create \
  --resource-group network-demo-rg \
  --name web-pip

# Create a network interface and attach the public IP
az network nic create \
  --resource-group network-demo-rg \
  --name web-nic \
  --vnet-name vnet-demo \
  --subnet web-subnet \
  --public-ip-address web-pip
```

### 5️⃣ Create NIC NSG and Associate with NIC

```bash
# Create a Network Security Group for the NIC
az network nsg create \
  --resource-group network-demo-rg \
  --name nic-nsg

# Associate the NSG with the NIC
az network nic update \
  --name web-nic \
  --resource-group network-demo-rg \
  --network-security-group nic-nsg
```

### 6️⃣ Create Ubuntu VM with Password Authentication + Install Apache

```bash
# Prompt for a strong password for the VM admin account
read -s -p "🔑 Enter a strong password for the VM admin account: " VM_PASSWORD

echo -e "\n🚀 Creating VM..."

# Create the Ubuntu VM
az vm create \
  --resource-group network-demo-rg \
  --name webvm \
  --location australiaeast \
  --nics web-nic \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --admin-password "$VM_PASSWORD"

# Install Apache on the VM (required for HTTP test)
az vm run-command invoke \
  --resource-group network-demo-rg \
  --name webvm \
  --command-id RunShellScript \
  --scripts "sudo apt-get update && sudo apt-get install -y apache2"
```

---

## 🔍 Post-Deployment Testing (Before NSG Rules)

### ❌ SSH to VM (Expected to Fail)

```bash
# Try to SSH to the VM (should fail due to NSG rules)
PIP=$(az vm list-ip-addresses \
  --resource-group network-demo-rg \
  --name webvm \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

ssh azureuser@"$PIP"
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
  --resource-group network-demo-rg \
  --nsg-name subnet-nsg \
  --name allow-ssh-subnet \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --access Allow \
  --source-address-prefixes '*'

# Allow HTTP traffic at the subnet level
az network nsg rule create \
  --resource-group network-demo-rg \
  --nsg-name subnet-nsg \
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
  --resource-group network-demo-rg \
  --nsg-name nic-nsg \
  --name allow-ssh-nic \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --access Allow \
  --source-address-prefixes '*'

# Allow HTTP traffic at the NIC level
az network nsg rule create \
  --resource-group network-demo-rg \
  --nsg-name nic-nsg \
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
  --resource-group network-demo-rg \
  --name webvm \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

ssh azureuser@"$PIP"
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
az group delete --name network-demo-rg --yes --no-wait
```

