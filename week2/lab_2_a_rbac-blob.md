# 🔐 Lab 2-A: Role-Based Access Control (RBAC) for Azure Blob Storage

<img width="1395" height="859" alt="IMAGE" src="https://github.com/user-attachments/assets/c51e28aa-691b-42bc-b410-c5f640cd1462" />


Use Azure **Role-Based Access Control (RBAC)** to manage and enforce granular access to Azure Blob Storage.  
This lab demonstrates how user permissions directly impact data-plane operations such as blob uploads.

---

## 🌟 Objective
Demonstrate how Azure RBAC determines **who can perform what actions** in Blob Storage.  
You will attempt an upload without a role, receive an authorization failure, then assign a role and retry successfully.

---

## 🧰 Prerequisites
- Azure subscription with **Owner** or **Contributor** permissions for your signed-in account  
- Azure Portal access  
- Azure CLI ≥ 2.60 installed (`az version`)  

---

## ⚙️ Variables (Parameterize Everything)
> Copy and adjust these before running commands — randomized values prevent naming collisions.

```bash
# ==== PARAMS ====
location="australiaeast"
rg="rbacblobdemo-rg"
storage="rbacblob$RANDOM"
container="files$RANDOM"
file_name="demo.txt"
```

---

## 👣 Step-by-Step (Portal + CLI)

### 1️⃣ Create a Resource Group and Storage Account

**Portal**
1. Go to **Storage accounts → + Create**.  
2. Resource Group → **Create new:** `rbacblobdemo-rg`.  
3. Storage account name → `rbacblob<unique>`.  
4. Region → **Australia East**.  
5. Redundancy → **Standard LRS**.  
6. **Review + Create → Create**.  

**CLI**
```bash
az login

az group create \
  --name "$rg" \
  --location "$location"

az storage account create \
  --name "$storage" \
  --resource-group "$rg" \
  --location "$location" \
  --sku Standard_LRS
```

---

### 2️⃣ Create a **Private** Blob Container

**Portal**
1. Storage Account → **Containers → + Container**.  
2. Name → `files<unique>`.  
3. Public access → **Private (no anonymous access)** → **Create**.

**CLI**
```bash
az storage container create   --account-name "$storage"   --name "$container"   --auth-mode login   --public-access off
```

---

### 3️⃣ Attempt Upload (Expect **Failure** — No Role Assigned)

**Portal**
- Navigate to the container → **Upload** a file → Upload fails with **AuthorizationPermissionMismatch**.

**CLI**
```bash
echo "RBAC demo test" > "$file_name"

az storage blob upload \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$file_name" \
  --file "$file_name" \
  --auth-mode login
```
**Expected:** Failure (insufficient privileges).

> 💡 This shows that although you are authenticated, RBAC denies data access until a role is assigned.

---

### 4️⃣ Assign a Role (Data-Plane Permission)

**Portal**
1. Storage Account → **Access control (IAM) → + Add role assignment**.  
2. Role → **Storage Blob Data Contributor**.  
3. Member → your signed-in user.  
4. **Review + Assign.**

**CLI**
```bash
subid=$(az account show --query id -o tsv)
upn=$(az ad signed-in-user show --query userPrincipalName -o tsv)

az role assignment create \
  --assignee "$upn" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$subid/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$storage"
```

> ⏳ RBAC propagation may take 1–2 minutes before access works.

---

### 5️⃣ Retry Upload (Expect **Success**)

**Portal**
- Upload the same file again → ✅ **Succeeds** — RBAC now authorizes the operation.

**CLI**
```bash
az storage blob upload \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$file_name" \
  --file "$file_name" \
  --auth-mode login \
  --overwrite true
```

**Verify Upload**
```bash
az storage blob show \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$file_name" \
  --auth-mode login
```

**List Blobs**
```bash
az storage blob list \
  --account-name "$storage" \
  --container-name "$container" \
  --auth-mode login \
  -o table
```

---

## 🧹 Clean Up
```bash
az group delete \
  --name "$rg" \
  --yes \
  --no-wait
```
> Optional: remove the local file `demo.txt`.

---

## 🧠 Learning Outcomes
✅ Understand **Azure RBAC** and its role in securing Blob Storage.  
✅ Differentiate between **authentication** and **authorization**.  
✅ Observe how access fails without proper role assignment.  
✅ Apply the **principle of least privilege** by granting minimal required roles.
