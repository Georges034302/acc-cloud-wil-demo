# 🌐 Demo Guide: Virtual Network Design & Security (VNet + NSG)

## 🎯 Objective

Design a secure Azure virtual network with subnets and apply network security group (NSG) rules to control access.

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed
- SSH key pair available

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create a Virtual Network with Subnets

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **Virtual networks** → Click **+ Create**
3. Basics tab:
   - **Resource Group**: e.g. `network-demo-rg`
   - **Name**: `vnet-demo`
   - **Region**: `Australia East`
4. IP Addresses tab:
   - Leave address space as default or set `10.0.0.0/16`
   - Add two subnets:
     - `web-subnet` (e.g. `10.0.1.0/24`)
     - `db-subnet` (e.g. `10.0.2.0/24`)
5. Click **Review + create** → **Create**

🔸 **CLI:**

```bash
az group create --name network-demo-rg --location australiaeast

az network vnet create \
  --resource-group network-demo-rg \
  --name vnet-demo \
  --address-prefix 10.0.0.0/16 \
  --subnet-name web-subnet \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group network-demo-rg \
  --vnet-name vnet-demo \
  --name db-subnet \
  --address-prefix 10.0.2.0/24
```

---

### 2️⃣ Deploy a VM into the Web Subnet

🔸 **Portal:**

1. Go to **Virtual Machines** → Click **+ Create**
2. Set:
   - **Name**: `webvm`
   - **Region**: `Australia East`
   - **Image**: Ubuntu LTS
   - **Authentication**: SSH public key
   - **Username**: `azureuser`
3. Networking tab:
   - **VNet**: `vnet-demo`
   - **Subnet**: `web-subnet`
4. Click **Review + create** → **Create**

🔸 **CLI:**

```bash
az vm create \
  --resource-group network-demo-rg \
  --name webvm \
  --image UbuntuLTS \
  --vnet-name vnet-demo \
  --subnet web-subnet \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub
```

---

### 3️⃣ Create and Attach a Network Security Group (NSG)

🔸 **Portal:**

1. Go to **Network Security Groups** → **+ Create**
2. Name: `web-nsg` → Same resource group & region
3. After creation, go to the NSG → Click **Inbound security rules** → **+ Add rule**
   - Allow **SSH (22)** and **HTTP (80)**
   - Deny all other inbound traffic
4. Associate the NSG with `web-subnet` or VM NIC

🔸 **CLI:**

```bash
az network nsg create \
  --resource-group network-demo-rg \
  --name web-nsg

az network nsg rule create \
  --resource-group network-demo-rg \
  --nsg-name web-nsg \
  --name allow-ssh \
  --protocol Tcp \
  --direction Inbound \
  --priority 1000 \
  --source-address-prefixes '*' \
  --destination-port-ranges 22 \
  --access Allow

az network nsg rule create \
  --resource-group network-demo-rg \
  --nsg-name web-nsg \
  --name allow-http \
  --protocol Tcp \
  --direction Inbound \
  --priority 1010 \
  --source-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow

az network vnet subnet update \
  --vnet-name vnet-demo \
  --name web-subnet \
  --resource-group network-demo-rg \
  --network-security-group web-nsg
```

---

### 4️⃣ Verify Access to the VM

1. Get the public IP of `webvm`:

```bash
az vm list-ip-addresses --name webvm --resource-group network-demo-rg --output table
```

2. SSH into the VM:

```bash
ssh azureuser@<VM_PUBLIC_IP>
```

3. Install Apache:

```bash
sudo apt update && sudo apt install apache2 -y
```

4. In browser: `http://<VM_PUBLIC_IP>` ✅ Should show Apache welcome page

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name network-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have designed a secure VNet with controlled access using NSGs!**

