# 🔐 Demo Guide: Azure AD Authentication for Blob Storage

## 🌟 Objective

Use Azure Active Directory (Azure AD) to grant secure, token-based access to Blob Storage without using keys or SAS tokens.

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

🔸 **CLI (optional):**

```bash
# Define strong password
strong_password='Strong!Pas.sword123'
 
# Get current subscription ID
subscription_id=$(az account show --query id -o tsv)
 
# Create Admin User
az ad user create \
  --display-name "Admin User" \
  --user-principal-name "adminuser@$my_domain" \
  --password "$strong_password" \
  --force-change-password-next-sign-in true
 
# Create Student User
az ad user create \
  --display-name "Student User" \
  --user-principal-name "studentuser@$my_domain" \
  --password "$strong_password" \
  --force-change-password-next-sign-in true
 
# Assign "Contributor" role to Admin User
az role assignment create \
  --assignee "adminuser@$my_domain" \
  --role "Contributor" \
  --scope "/subscriptions/$subscription_id"
```

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
   - Resource group: `adblobdemo-rg`
   - Storage name: `adblobdemo<unique>`
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

az group create --name adblobdemo-rg --location australiaeast

az storage account create \
  --name adblobdemo123 \
  --resource-group adblobdemo-rg \
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
  --account-name adblobdemo123 \
  --name myfiles \
  --auth-mode login \
  --public-access off
```

---

### 3️⃣ Assign Role to Student

👤 **Performed by: Admin User**

🔸 **Portal:**

1. Go to **Storage Account** → **Access control (IAM)**
2. Click **+ Add role assignment**
3. Role: `Storage Blob Data Contributor` (read/write)
4. Click **Next**, then **+ Select members**
5. Find and select the **student user**
6. Click **Review + assign**

🔸 **CLI:**

```bash
az role assignment create \
  --assignee studentuser@<your_domain> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<subscription_id>/resourceGroups/adblobdemo-rg/providers/Microsoft.Storage/storageAccounts/adblobdemo123"
```

---

### 4️⃣ Test Access as Student

👤 **Performed by: Student User**

🔸 **Portal:**

1. Open **Incognito Mode** and log in as the **student user**
2. Go to **Storage Account** → **Containers** → `myfiles`
3. Click **Upload**
4. Choose a file and enable **Overwrite if file exists**
5. Click **Upload**

🔸 **CLI:**

```bash
az login  # Log in as student user

az storage blob upload \
  --account-name adblobdemo123 \
  --container-name myfiles \
  --name test.txt \
  --file ./test.txt \
  --auth-mode login \
  --overwrite true
```

✅ Upload will succeed without keys or SAS tokens.

---

### 5️⃣ Optional: Verify & Clean Up

👤 **Performed by: Admin User**

🔸 **Verify Blob:**

```bash
az storage blob show \
  --account-name adblobdemo123 \
  --container-name myfiles \
  --name test.txt \
  --auth-mode login
```

🔸 **Clean Up:**

```bash
az group delete --name adblobdemo-rg --yes --no-wait
```

---

✅ **Demo complete – students have experienced secure, identity-based access to Azure Blob Storage using Azure AD!**

