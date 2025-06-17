# 🔐 Demo Guide: Azure AD Authentication for Blob Storage

## 🎯 Objective

Use Azure Active Directory (Azure AD) to grant secure, token-based access to Blob Storage without using keys or SAS tokens.

---

## 🧭 Prerequisites

- Azure Portal access
- One Storage Account with a blob container (e.g. `myfiles`)
- An Azure AD user to assign access (student)
- Azure CLI installed

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Confirm Azure AD Integration is Enabled

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Open your **Storage Account**
3. In the left menu, select **Configuration**
4. Ensure **"Azure Active Directory"** is selected under **"Default to Azure AD authorization in the Azure portal"**
5. Click **Save** if changes were made

🔸 **CLI:** *(No direct CLI equivalent; this setting is changed only through the portal)*

---

### 2️⃣ Create a Private Blob Container

🔸 **Portal:**

1. In your storage account, click **Containers**
2. Click **+ Container**
   - **Name**: `myfiles`
   - **Public access level**: Private
   - Click **Create**

🔸 **CLI:**

```bash
az storage container create \
  --account-name <storage_account> \
  --name myfiles \
  --auth-mode login \
  --public-access off
```

---

### 3️⃣ Assign Azure AD Role to User

🔸 **Portal:**

1. In the Storage Account, go to **Access control (IAM)**
2. Click **+ Add** → **Add role assignment**
3. Role: **Storage Blob Data Reader** or **Contributor** (for read or write access)
4. Click **Next**
5. Click **+ Select members** → Search and select the **student user**
6. Click **Select** → **Next** → **Review + assign** twice

🔸 **CLI:**

```bash
az role assignment create \
  --assignee <user_object_id_or_email> \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Storage/storageAccounts/<storage_account>"
```

✅ User now has token-based access!

---

### 4️⃣ Test Authentication

🔸 **Portal:**

1. Log into the Azure Portal as the **student user**
2. Navigate to the **Storage Account** → **Containers** → `myfiles`
3. Click **Upload** or **Download** a file
4. ✅ Should succeed without keys or SAS

🔸 **CLI:**

```bash
az login

az storage blob list \
  --account-name <storage_account> \
  --container-name myfiles \
  --auth-mode login \
  --output table
```

✅ You are now accessing the container securely via Azure AD token.

---

## 🚨 Notes

- Azure AD removes the need to store account keys or SAS tokens
- You can use **Managed Identities** or **service principals** for app access

---

✅ **Demo complete – students have experienced secure, identity-based access to Blob Storage!**

