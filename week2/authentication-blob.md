# 🔐 Demo Guide: Azure AD Authentication for Blob Storage

## 🎯 Objective

Use Azure Active Directory (Azure AD) to grant secure, token-based access to Blob Storage without using keys or SAS tokens.

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed
- An Azure AD user (student) with no storage roles
- A storage account and resource group (created in this demo)

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create Storage Account and Enable Azure AD Authentication

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Navigate to **Storage accounts** → **+ Create**
3. Fill out:
   - Subscription: your active subscription
   - Resource group: `adblobdemo-rg` (create new)
   - Storage account name: `adblobdemo<random>` (must be unique)
   - Region: `Australia East`
   - Performance: Standard
   - Redundancy: LRS
4. Click **Review + create** → **Create**
5. After deployment completes, open the storage account
6. Select **Configuration** from the left menu
7. Under **Default to Azure AD authorization in the Azure portal**, set to `Enabled`
8. Click **Save**

🔸 **CLI:**

```bash
az group create --name adblobdemo-rg --location australiaeast

az storage account create \
  --name adblobdemo123 \
  --resource-group adblobdemo-rg \
  --location australiaeast \
  --sku Standard_LRS
```

> ⚠️ Note: Azure AD auth setting must still be enabled in Portal manually.

---

### 2️⃣ Create a Private Blob Container

🔸 **Portal:**

1. Go to your Storage Account → **Containers**
2. Click **+ Container**
   - Name: `myfiles`
   - Access level: `Private`
   - Click **Create**

🔸 **CLI:**

```bash
az storage container create \
  --account-name adblobdemo123 \
  --name myfiles \
  --auth-mode login \
  --public-access off
```

---

### 3️⃣ Assign Azure AD Role to Student User

🔸 **Portal:**

1. Open the **Storage Account** → **Access control (IAM)**
2. Click **+ Add** → **Add role assignment**
3. Role: `Storage Blob Data Reader` (read access) or `Storage Blob Data Contributor` (read/write)
4. Click **Next** → **+ Select members**
5. Search and select the **student user**
6. Click **Select** → **Next** → **Review + assign**

🔸 **CLI:**

```bash
az role assignment create \
  --assignee <student_email_or_object_id> \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/<subscription_id>/resourceGroups/adblobdemo-rg/providers/Microsoft.Storage/storageAccounts/adblobdemo123"
```

✅ The student now has secure Azure AD access to the blob container.

---

### 4️⃣ Test Access as Student

🔸 **Portal:**

1. Open browser in **Incognito/Private Mode**
2. Sign in to [https://portal.azure.com](https://portal.azure.com) as the **student user**
3. Navigate to **Storage Account** → **Containers** → `myfiles`
4. Click **Upload** → Select a file → **Upload**
5. ✅ Upload should work without keys or SAS

🔸 **CLI:**

```bash
az login  # Use student user credentials

az storage blob list \
  --account-name adblobdemo123 \
  --container-name myfiles \
  --auth-mode login \
  --output table
```

✅ List of blobs should appear if permission is granted.

---

## 🚨 Notes

- Azure AD removes the need to manage storage keys or SAS tokens
- Supports token-based access from CLI, SDKs, or managed identities
- For app scenarios, use Managed Identity instead of user role assignment

---

✅ **Demo complete – students have experienced secure, identity-based access to Blob Storage via Azure AD.**

