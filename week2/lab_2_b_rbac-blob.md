# 🔐 Demo Guide: Role-Based Access Control (RBAC) for Azure Blob Storage

## 🌟 Objective

Experience Azure RBAC by attempting to upload a blob without permission, then assigning the correct role to allow access.

---

## 🌭 Prerequisites

- Azure Portal access
- Azure CLI installed
- Two Azure AD users:
  - One with **Owner** or **Contributor** role (Instructor/Admin)
  - One with **no roles assigned** (Student/User)

---

## 👣 Step-by-Step Instructions (Portal + CLI)

### 0️⃣ Create Azure AD Users (Admin & Student)

👤 **Performed by: Global Administrator**

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Open **Microsoft Entra ID** → **Users** → **+ New user**
3. Create **Admin User**:
   - Username: `adminuser@<your_domain>`
   - Name: `Admin User`
   - Password: auto-generated or custom
   - Click **Create**
4. Repeat to create **Student User**:
   - Username: `studentuser@<your_domain>`
   - Do not assign roles
5. Go to **Subscriptions** → your subscription → **Access control (IAM)**
   - Assign **Owner** or **Contributor** to the **Admin User** only

🔐 **Login Tips:**

- After user creation, the portal shows the temporary password.
- User receives an email invite (if email is configured), or the admin shares the credentials manually.
- On first login, users are prompted to reset their password.
- Use **Incognito Mode** to sign in separately as **student user**.

---

### 1️⃣ Create Storage Account with Azure AD Authentication

👤 **Performed by: Admin User**

🔸 **Portal:**

1. Log in as **Admin User**
2. Go to **Storage accounts** → **+ Create**
3. Fill in:
   - Resource group: `rbacdemo-rg`
   - Storage name: `rbacdemo<unique>`
   - Region: `Australia East`
   - SKU: Standard\_LRS
4. Click **Review + create** → **Create**
5. After deployment completes, go to the **Storage Account**
6. In the left menu, click **Configuration**
7. Under **Default to Azure AD authorization in the Azure portal**, set to **Enabled**
8. Enable the setting **Allow enabling public access override** if it's not already enabled
9. Click **Save**

💡 These two settings ensure:

- Azure AD token-based authentication is enforced in the portal and CLI.
- You can assign granular access at the container level via IAM.

🔸 **CLI:**

```bash
az login  # Log in as Admin User

az group create --name rbacdemo-rg --location australiaeast

az storage account create \
  --name rbacdemo123 \
  --resource-group rbacdemo-rg \
  --location australiaeast \
  --sku Standard_LRS
```

⚠️ **Important:** Step 6–9 **must be done in the Portal by the Admin User.** There is currently **no CLI/ARM option** to set "Azure AD authorization" or "public access override".

---

### 2️⃣ Create a Private Blob Container

👤 **Performed by: Admin User**

🔸 **Portal:**

1. Go to **Storage Account** → **Containers** → **+ Container**
2. Name: `myfiles`
3. Access level: **Private (no anonymous access)**
4. Click **Create**

🔸 **CLI:**

```bash
az storage container create \
  --account-name rbacdemo123 \
  --name myfiles \
  --auth-mode login \
  --public-access off
```

---

### 3️⃣ Attempt Upload Without Permissions ❌

👤 **Performed by: Student User**

🔸 **Portal:**

1. Open **Incognito Mode** and log in as the **student user**
2. Go to **Storage Account** → **Containers** → `myfiles`
3. Click **Upload** → select a file → Click **Upload**
4. ❌ You will receive an **Unauthorized** error (expected)

🔸 **CLI:**

```bash
az login  # Log in as student user

az storage blob upload \
  --account-name rbacdemo123 \
  --container-name myfiles \
  --name test.txt \
  --file ./test.txt \
  --auth-mode login \
  --overwrite true
```

⚠️ Expected to fail due to lack of RBAC permissions.

---

### 4️⃣ Assign Role to Student ✅

👤 **Performed by: Admin User**

🔸 **Portal:**

1. Go to **Storage Account** → **Access control (IAM)**
2. Click **+ Add role assignment**
3. Role: `Storage Blob Data Contributor`
4. Click **Next** → **+ Select members**
5. Choose **student user** → **Next** → **Review + assign**

🔸 **CLI:**

```bash
az role assignment create \
  --assignee studentuser@<your_domain> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<subscription_id>/resourceGroups/rbacdemo-rg/providers/Microsoft.Storage/storageAccounts/rbacdemo123"
```

---

### 5️⃣ Upload File Again (With Access) ✅

👤 **Performed by: Student User**

🔸 **Portal:**

1. Return to **Portal** → Login as **student user**
2. Go to **Storage Account** → **Containers** → `myfiles`
3. Click **Upload** → select file → ✅ Check **Overwrite if file exists** → Click **Upload**

🔸 **CLI:**

```bash
az storage blob upload \
  --account-name rbacdemo123 \
  --container-name myfiles \
  --name test.txt \
  --file ./test.txt \
  --auth-mode login \
  --overwrite true
```

✅ Upload will succeed using token-based RBAC access.

---

### 6️⃣ Optional: Verify & Clean Up

👤 **Performed by: Admin User**

🔸 **Verify Blob:**

```bash
az storage blob show \
  --account-name rbacdemo123 \
  --container-name myfiles \
  --name test.txt \
  --auth-mode login
```

🔸 **Clean Up:**

```bash
az group delete --name rbacdemo-rg --yes --no-wait
```

---

✅ **Demo complete – students have experienced secure, identity-based access to Azure Blob Storage using RBAC!**

