# 🔗 **Lab 3-D: Virtual Network Peering in Azure**

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/1a313a69-ee65-4de9-8ad9-ad0fcf2e0452" />

## 🎯 **Objective**

Set up two Azure Virtual Networks (VNets) and connect them using **VNet Peering** to enable secure, low-latency communication between virtual machines in different networks.

---

## 🧭 **Prerequisites**

- Access to the **Azure Portal** or **Azure Cloud Shell**
- **Azure CLI** installed (latest version)

---

## 👣 **Step-by-Step Instructions**

### 1️⃣ **Define Parameters and Create Resource Group**

Before deployment, define key parameters for consistent naming and easy cleanup.

```bash
# ==== VARIABLES ====
location="australiaeast"
rg="peering-demo-rg"
vnet1="vnet-hub"
vnet2="vnet-spoke"
subnet1="subnet-hub"
subnet2="subnet-spoke"
vnet1_prefix="10.1.0.0/16"
vnet2_prefix="10.2.0.0/16"
subnet1_prefix="10.1.1.0/24"
subnet2_prefix="10.2.1.0/24"
vm1="vm-hub"
vm2="vm-spoke"
admin_user="azureuser"


# ==== CREATE RESOURCE GROUP ====
az group create \
   --name "$rg" \
   --location "$location"
```

---

### 2️⃣ **Create Two Virtual Networks (VNets)**

#### 🔹 **Using Azure Portal**

1. In the [Azure Portal](https://portal.azure.com), search for **Virtual Networks** → Click **+ Create**.  
2. Create the **Hub VNet**:  
   - **Name:** `vnet-hub`  
   - **Address space:** `10.1.0.0/16`  
   - **Subnet name:** `subnet-hub` (`10.1.1.0/24`)  
3. Repeat for the **Spoke VNet**:  
   - **Name:** `vnet-spoke`  
   - **Address space:** `10.2.0.0/16`  
   - **Subnet name:** `subnet-spoke` (`10.2.1.0/24`)  

#### 🔹 **Using Azure CLI**

```bash
# Create Hub VNet
az network vnet create \
   --name "$vnet1" \
   --resource-group "$rg" \
   --address-prefix "$vnet1_prefix" \
   --subnet-name "$subnet1" \
   --subnet-prefix "$subnet1_prefix"

# Create Spoke VNet
az network vnet create \
   --name "$vnet2" \
   --resource-group "$rg" \
   --address-prefix "$vnet2_prefix" \
   --subnet-name "$subnet2" \
   --subnet-prefix "$subnet2_prefix"
```

---

### 3️⃣ **Deploy a VM into Each VNet**

#### 🔹 **Using Azure Portal**

1. Create **VM1**:  
   - **Name:** `vm-hub`  
   - **VNet/Subnet:** `vnet-hub` / `subnet-hub`  
   - **Authentication:** SSH key  
2. Create **VM2**:  
   - **Name:** `vm-spoke`  
   - **VNet/Subnet:** `vnet-spoke` / `subnet-spoke`  

#### 🔹 **Using Azure CLI**

```bash
read -s -p "🔑 Enter a strong password for the VM admin account: " vm_password
echo

# Create VM in Hub VNet (Ubuntu 22.04, password auth)
az vm create \
   --resource-group "$rg" \
   --name "$vm1" \
   --image Ubuntu2204 \
   --vnet-name "$vnet1" \
   --subnet "$subnet1" \
   --admin-username "$admin_user" \
   --admin-password "$vm_password"

# Create VM in Spoke VNet (Ubuntu 22.04, password auth)
az vm create \
   --resource-group "$rg" \
   --name "$vm2" \
   --image Ubuntu2204 \
   --vnet-name "$vnet2" \
   --subnet "$subnet2" \
   --admin-username "$admin_user" \
   --admin-password "$vm_password"
```

---

### 4️⃣ **Enable VNet Peering (Bidirectional)**

#### 🔹 **Using Azure Portal**

1. Open `vnet-hub` → **Peerings** → **+ Add**.  
2. Name: `peer-to-spoke` → Select `vnet-spoke`.  
3. Enable “Allow virtual network access” → **Create**.  
4. Repeat the same process in `vnet-spoke`, naming the connection `peer-to-hub`.  

#### 🔹 **Using Azure CLI**

```bash
# Create Peering from Hub → Spoke
az network vnet peering create \
   --name peer-to-spoke \
   --resource-group "$rg" \
   --vnet-name "$vnet1" \
   --remote-vnet "$vnet2" \
   --allow-vnet-access

# Create Peering from Spoke → Hub
az network vnet peering create \
   --name peer-to-hub \
   --resource-group "$rg" \
   --vnet-name "$vnet2" \
   --remote-vnet "$vnet1" \
   --allow-vnet-access
```

---

### 5️⃣ **Test VM-to-VM Connectivity**

1. Retrieve the private IP address of **vm-spoke**:

```bash
az vm list-ip-addresses \
   --name "$vm2" \
   --resource-group "$rg" \
   --query "[].virtualMachine.network.privateIpAddresses" \
   -o tsv
```

2. SSH into **vm-hub** and ping **vm-spoke**’s private IP:

ping <vm-spoke-private-ip>
```bash
ssh "$admin_user"@<vm-hub-public-ip>

ping <vm-spoke-private-ip>
```

✅ You should receive successful replies, confirming VNet Peering is operational.

---

### 6️⃣ **Clean Up (Optional)**

Delete the resource group to remove all associated resources:

```bash
az group delete \
   --name "$rg" \
   --yes \
   --no-wait
```

---

## 🧩 **Outcome**

Students have successfully:  
- Created two isolated **Virtual Networks** in Azure  
- Deployed virtual machines in each network  
- Configured **bidirectional VNet peering** for communication  
- Verified private network connectivity between VNets  
