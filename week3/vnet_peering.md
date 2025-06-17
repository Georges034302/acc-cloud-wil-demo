# 🔗 Demo Guide: Virtual Network Peering in Azure

## 🎯 Objective

Set up two Azure Virtual Networks (VNets) and connect them using VNet Peering to enable secure communication between them.

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed
- SSH key pair available

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create Two VNets in the Same Region

🔸 **Portal:**

1. Go to **Virtual Networks** → Click **+ Create**
2. Create VNet1:
   - **Name**: `vnet-hub`
   - **Address space**: `10.1.0.0/16`
   - **Subnet**: `subnet-hub` (`10.1.1.0/24`)
3. Create VNet2:
   - **Name**: `vnet-spoke`
   - **Address space**: `10.2.0.0/16`
   - **Subnet**: `subnet-spoke` (`10.2.1.0/24`)

🔸 **CLI:**

```bash
az group create --name peering-demo-rg --location australiaeast

az network vnet create \
  --name vnet-hub \
  --resource-group peering-demo-rg \
  --address-prefix 10.1.0.0/16 \
  --subnet-name subnet-hub \
  --subnet-prefix 10.1.1.0/24

az network vnet create \
  --name vnet-spoke \
  --resource-group peering-demo-rg \
  --address-prefix 10.2.0.0/16 \
  --subnet-name subnet-spoke \
  --subnet-prefix 10.2.1.0/24
```

---

### 2️⃣ Deploy a VM into Each VNet

🔸 **Portal:**

1. Create VM1:
   - **Name**: `vm-hub`
   - **VNet**: `vnet-hub`, Subnet: `subnet-hub`
   - SSH Key: Use your public key
2. Create VM2:
   - **Name**: `vm-spoke`
   - **VNet**: `vnet-spoke`, Subnet: `subnet-spoke`

🔸 **CLI:**

```bash
az vm create \
  --resource-group peering-demo-rg \
  --name vm-hub \
  --image UbuntuLTS \
  --vnet-name vnet-hub \
  --subnet subnet-hub \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub

az vm create \
  --resource-group peering-demo-rg \
  --name vm-spoke \
  --image UbuntuLTS \
  --vnet-name vnet-spoke \
  --subnet subnet-spoke \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub
```

---

### 3️⃣ Enable VNet Peering (Both Directions)

🔸 **Portal:**

1. Go to `vnet-hub` → Settings → **Peerings** → **+ Add**
2. Name: `peer-to-spoke`, select `vnet-spoke`
3. Check “Allow virtual network access” → Create
4. Repeat the process in `vnet-spoke` to peer back to `vnet-hub`

🔸 **CLI:**

```bash
az network vnet peering create \
  --name peer-to-spoke \
  --resource-group peering-demo-rg \
  --vnet-name vnet-hub \
  --remote-vnet vnet-spoke \
  --allow-vnet-access

az network vnet peering create \
  --name peer-to-hub \
  --resource-group peering-demo-rg \
  --vnet-name vnet-spoke \
  --remote-vnet vnet-hub \
  --allow-vnet-access
```

---

### 4️⃣ Test VM-to-VM Connectivity

1. SSH into `vm-hub` and ping `vm-spoke`'s private IP

```bash
ssh azureuser@<vm-hub-public-ip>

ping <vm-spoke-private-ip>
```

✅ You should see replies, confirming VNet peering is working

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name peering-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have implemented VNet peering to enable secure cross-network communication!**

