# 🌐 Networking & NSG Demo: Subnet + NIC Level Rules

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
az group create \
  --name network-demo-rg \
  --location australiaeast
```

### 2️⃣ Create Virtual Network and Subnet

```bash
az network vnet create \
  --resource-group network-demo-rg \
  --name vnet-demo \
  --address-prefix 10.0.0.0/16 \
  --subnet-name web-subnet \
  --subnet-prefix 10.0.1.0/24
```

### 3️⃣ Create Subnet NSG and Associate with Subnet

```bash
az network nsg create \
  --resource-group network-demo-rg \
  --name subnet-nsg

az network vnet subnet update \
  --vnet-name vnet-demo \
  --name web-subnet \
  --resource-group network-demo-rg \
  --network-security-group subnet-nsg
```

### 4️⃣ Create Public IP and NIC

```bash
az network public-ip create \
  --resource-group network-demo-rg \
  --name web-pip

az network nic create \
  --resource-group network-demo-rg \
  --name web-nic \
  --vnet-name vnet-demo \
  --subnet web-subnet \
  --public-ip-address web-pip
```

### 5️⃣ Create NIC NSG and Associate with NIC

```bash
az network nsg create \
  --resource-group network-demo-rg \
  --name nic-nsg

az network nic update \
  --name web-nic \
  --resource-group network-demo-rg \
  --network-security-group nic-nsg
```

### 6️⃣ Create Ubuntu VM with Password Authentication + Install Apache

```bash
read -s -p "🔑 Enter a strong password for the VM admin account: " VM_PASSWORD

echo -e "\n🚀 Creating VM..."

az vm create \
  --resource-group network-demo-rg \
  --name webvm \
  --location australiaeast \
  --nics web-nic \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --admin-password "$VM_PASSWORD"
```

---

## 🔍 Post-Deployment Testing (Before NSG Rules)

### ❌ SSH to VM (Expected to Fail)

```bash
PIP=$(az vm list-ip-addresses \
  --resource-group network-demo-rg \
  --name webvm \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

ssh azureuser@"$PIP"
```

### ❌ HTTP Access (Expected to Fail)

Visit: `http://<web-pip>`

---

## 🔧 Update NSG Rules (Allow SSH + HTTP)

### ✅ Subnet NSG Rules

```bash
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
PIP=$(az vm list-ip-addresses \
  --resource-group network-demo-rg \
  --name webvm \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

ssh azureuser@"$PIP"
```

### ✔️ HTTP Access

Visit: `http://<web-pip>` → Apache Welcome Page

---

## 🧼 Clean Up

```bash
az group delete --name network-demo-rg --yes --no-wait
```

