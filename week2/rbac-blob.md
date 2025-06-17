# 🔐 Demo Guide: Role-Based Access Control (RBAC) for Azure Blob Storage

## 🎯 Objective
Experience Azure RBAC by attempting to upload a blob without permission, then assigning the correct role to allow access.

---

## 🧭 Prerequisites
- Azure Portal access
- Two Azure AD users:
  - One with **Owner** or **Contributor** role (Instructor/Admin)
  - One with **no roles assigned** (Student/User)
- Azure CLI installed

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create a Storage Account

🔸 **Portal:**
1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **Storage accounts** and click **+ Create**
3. Fill in the required fields:
   - **Subscription**: Choose your active subscription
   - **Resource group**: Create or select one
   - **Storage account name**: e.g. `rbacdemo123` (must be globally unique)
   - **Region**: e.g. `Australia East`
   - **Performance**: Standard
   - **Redundancy**: Locally-redundant storage (LRS)
4. Click **Review + create** then **Create**

🔸 **CLI:**
```bash
az storage account create \
  --name rbacdemo123 \
  --resource-group <rg_name> \
  --location australiaeast \
  --sku Standard_LRS
```

---

### 2️⃣ Create a Private Blob Container

🔸 **Portal:**
1. Go to your new **Storage Account**
2. In the left menu, click **Containers**
3. Click **+ Container**
   - **Name**: `myfiles`
   - **Public access level**: Private (no anonymous access)
   - Click **Create**

🔸 **CLI:**
```bash
az storage container create \
  --account-name rbacdemo123 \
  --name myfiles \
  --public-access off \
  --auth-mode login
```

---

### 3️⃣ Attempt Upload Without Permissions ❌

🔸 **Portal:**
1. Log into Azure Portal as the **student user** (incognito tab)
2. Go to **Storage Account** → **Containers** → `myfiles`
3. Click **Upload**, choose a file, and click **Upload**
4. ❌ You will get an **Unauthorized** error (expected)

🔸 **CLI:**
```bash
az login  # as student user

az storage blob upload \
  --account-name rbacdemo123 \
  --container-name myfiles \
  --name test.txt \
  --file ./test.txt \
  --auth-mode login
```
⚠️ This should also fail due to insufficient permissions.

---

### 4️⃣ Assign Storage Blob Data Contributor Role ✅

🔸 **Portal:**
1. Switch back to the **admin account**
2. Go to the **Storage Account** → **Access control (IAM)**
3. Click **+ Add** → **Add role assignment**
4. Role: **Storage Blob Data Contributor** → Click **Next**
5. Click **+ Select members** → Search and select the **student user**
6. Click **Select** → **Next** → **Review + assign** twice

🔸 **CLI:**
```bash
az role assignment create \
  --assignee <student_email_or_object_id> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Storage/storageAccounts/rbacdemo123"
```

---

### 5️⃣ Upload File Again (With Access) ✅

🔸 **Portal:**
1. Switch back to the **student user**
2. Refresh the **Containers** page → `myfiles`
3. Click **Upload**, choose a file, and click **Upload**
4. ✅ Upload will succeed

🔸 **CLI:**
```bash
az storage blob upload \
  --account-name rbacdemo123 \
  --container-name myfiles \
  --name test.txt \
  --file ./test.txt \
  --auth-mode login
```
✅ Upload succeeds with proper RBAC access.

---

## 🧼 Clean Up (Optional)
- Delete the storage account or remove the role assignment to clean up the environment

---

✅ **Demo complete – students have now experienced RBAC in action with both Portal and CLI!**

