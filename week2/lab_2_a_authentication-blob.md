# 🔐 Lab 2-A: Microsoft Entra ID Authentication for Azure Blob Storage

<img width="1536" height="1024" alt="IMAGE" src="https://github.com/user-attachments/assets/bb7d623d-6b95-4983-841c-ca93059455da" />

Use Microsoft Entra ID (formerly Azure AD) to grant secure, token-based access to Blob Storage **without** using storage keys or SAS tokens.

---

## 🌟 Objective
Demonstrate secure, identity-based access to Azure Blob Storage with role-based authorization (RBAC) using **your own user account**.

---

## 🧰 Prerequisites
- Azure subscription with **Owner** or **Contributor** permissions for your signed-in account
- Azure Portal access
- Azure CLI ≥ 2.60 installed (`az version`)

---

## ⚙️ Variables (parametrize everything)
> Copy/paste and adjust as needed. Values are randomized to avoid naming collisions.

```bash
# ==== PARAMS ====
location="australiaeast"
rg="adblobdemo-rg"
storage="adblob$RANDOM"
container="files$RANDOM"
file_name="demo.txt"
```

---

## 👣 Step-by-Step (Portal + CLI)

### 1) Create Resource Group & Storage Account

**Portal**
1. Go to **Storage accounts → + Create**.
2. Resource Group → **Create new:** `adblobdemo-rg`.
3. Storage account name → `adblob<unique>`.
4. Region → **Australia East**.
5. Redundancy → **Standard LRS**.
6. **Review + Create → Create**.

**Important (Portal-only setting):**
- Open the new Storage Account → **Configuration**.
- Set **Default to Azure AD authorization in the Azure portal** → **Enabled**.
- Click **Save**.

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
> ⚠️ The **Azure AD authorization** default cannot currently be set by CLI/ARM; use the **Portal** once after creation.

---

### 2) Create a **Private** Blob Container

**Portal**
1. Storage Account → **Containers → + Container**.
2. Name → `files<unique>`.
3. Public access → **Private (no anonymous access)** → **Create**.

**CLI**
```bash
az storage container create \
  --account-name "$storage" \
  --name "$container" \
  --auth-mode login \
  --public-access off
```

---

### 3) Attempt Upload (Expect **Failure** — no role yet)

**Portal**
- Go to the container → **Upload** a small file → Upload fails with **AuthorizationPermissionMismatch**.

**CLI**
```bash
echo "Azure AD Blob test" > "$file_name"

az storage blob upload \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$file_name" \
  --file "$file_name" \
  --auth-mode login
```
**Expected:** Failure (insufficient privileges).

> 💡 This demonstrates identity-based access **without** SAS/keys and the need for RBAC on data plane.

---

### 4) Assign Role to **Yourself** (Data Plane RBAC)

**Portal**
1. Storage Account → **Access control (IAM) → + Add role assignment**.
2. Role → **Storage Blob Data Contributor**.
3. Member → your signed-in user → **Review + assign**.

**CLI**
```bash
subid=$(az account show --query id -o tsv)
upn=$(az ad signed-in-user show --query userPrincipalName -o tsv)

az role assignment create \
  --assignee "$upn" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$subid/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$storage"
```

> ⏳ RBAC propagation can take up to a few minutes. If access still fails, wait 60–120 seconds and retry.

---

### 5) Retry Upload (Expect **Success**)

**Portal**
- Upload the same file again → **Succeeds** ✅ (authorized via Entra ID token).

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

**Verify**
```bash
az storage blob show \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$file_name" \
  --auth-mode login
```

**Optional: list blobs**
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
> Optional: remove local `demo.txt` if desired.

---

## 🧠 Learning Outcomes
- Configure **Microsoft Entra ID** authentication for Blob Storage.
- Understand and validate **RBAC** for data-plane operations.
- Contrast **key/SAS** vs **identity-based** access.
- Apply **least-privilege** by granting only **Storage Blob Data Contributor** to the required identity.
