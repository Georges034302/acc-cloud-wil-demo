# 🌏 Lab 2-C: Geo-Redundant Storage and Failover Simulation


<img width="1536" height="1024" alt="IMAGE" src="https://github.com/user-attachments/assets/5bd9e0a4-5ce9-4c21-90dc-96fd0a5f825c" />

Demonstrate **business continuity and data durability** by configuring a **Geo-Redundant Storage Account (GRS)** and performing a **failover simulation** to validate data replication across Azure regions.

---

## 🌟 Objective
- Configure a **GRS or GZRS** redundancy option for a Storage Account  
- Verify blob replication between **primary and secondary regions**  
- Simulate **regional failover** and validate recovery  

---

## 🧰 Prerequisites
- Azure subscription with **Contributor** or higher role  
- Azure Portal and Azure CLI (≥ 2.60)  
- Basic understanding of Storage redundancy concepts  

---

## ⚙️ Variables (Parameterize Everything)
```bash
# ==== PARAMS ====
location="australiaeast"
rg="georedundancy-rg"
storage="geodemo$RANDOM"
container="geo$RANDOM"
file_name="testfile.txt"
```

---

## 👣 Step-by-Step (Portal + CLI)

### 1️⃣ Create Resource Group and Storage Account

**Portal**
1. Go to **Storage accounts → + Create**  
2. Resource Group → `georedundancy-rg`  
3. Storage Account Name → `geodemo<unique>`  
4. Region → **Australia East**  
5. **Performance** → Standard  
6. **Redundancy** → **Geo-Redundant Storage (GRS)** or **Geo-Zone-Redundant (GZRS)**  
7. Click **Review + create → Create**

**CLI**
```bash
az group create \
  --name "$rg" \
  --location "$location"

az storage account create \
  --name "$storage" \
  --resource-group "$rg" \
  --location "$location" \
  --sku Standard_GRS
```

✅ The storage account now replicates data asynchronously to a paired region (Australia Southeast).

---

### 2️⃣ Create Container and Upload File

```bash
ACCOUNT_KEY=$(az storage account keys list \
  --account-name "$storage" \
  --query '[0].value' \
  -o tsv)

az storage container create \
  --account-name "$storage" \
  --name "$container" \
  --account-key "$ACCOUNT_KEY"

echo "Azure Geo Redundancy Test" > "$file_name"

az storage blob upload \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$file_name" \
  --file "$file_name" \
  --account-key "$ACCOUNT_KEY" \
  --overwrite
```

✅ File uploaded to the **primary region** and replicated to the **secondary region** automatically.

---

### 3️⃣ View Redundancy and Replication Status

**Portal**
- Open the Storage Account → **Geo-Replication**  
- Observe:
  - **Primary location:** Australia East  
  - **Secondary location:** Australia Southeast  
  - **Last sync time:** shows replication health  

**CLI**
```bash
az storage account show \
  --name "$storage" \
  --resource-group "$rg" \
  --query "{Primary:primaryLocation,Secondary:secondaryLocation,Redundancy:sku.name}" \
  -o table
```

---

### 4️⃣ Trigger Failover (Simulated Disaster Recovery)

> ⚠️ Failover is irreversible and switches the secondary to become the new primary.  
> Only use this in **test environments**.

```bash
az storage account failover \
  --name "$storage" \
  --resource-group "$rg"
```

⏳ Wait ≈ 10–15 minutes for completion.

After failover, run:
```bash
az storage account show \
  --name "$storage" \
  --resource-group "$rg" \
  --query "{Status:statusOfPrimary,CurrentRegion:primaryLocation}" \
  -o table
```
✅ The secondary region (Australia Southeast) is now **primary**.

---

### 5️⃣ Validate Access Post-Failover

```bash
az storage blob list \
  --account-name "$storage" \
  --container-name "$container" \
  --account-key "$ACCOUNT_KEY" \
  -o table
```

✅ Blobs remain accessible, confirming successful replication and failover.

---

## 🧠 Discussion Points
- **GRS** → Asynchronous replication between paired regions  
- **GZRS** → Synchronous replication across zones + asynchronous to secondary region  
- **Failover** → Permanent region swap; DNS automatically updated  
- **Recovery Time Objective (RTO)** ≈ hours; use only for real outages  

---

## 🧹 Clean Up
```bash
az group delete \
  --name "$rg" \
  --yes \
  --no-wait
```

---

✅ **Lab 2-C complete — you’ve demonstrated Azure’s geo-redundancy and failover resilience for cloud storage.**
