# 🔐 Demo Guide: Shared Access Signature (SAS) for Azure Blob Storage

## 🎯 Objective
Learn how to create a Shared Access Signature (SAS) token to grant time-limited, permission-based access to Azure Blob Storage without assigning roles.

---

## 🧭 Prerequisites
- Azure Portal access
- A Storage Account with an existing **container** (e.g. `myfiles`)
- Azure CLI installed

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Navigate to Your Storage Account

🔸 **Portal:**
1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Open your **Storage Account** (e.g. `rbacdemo123`)

🔸 **CLI:** *(Already created storage account is required; see CLI steps in Demo 1)*

---

### 2️⃣ Open Shared Access Signature Settings

🔸 **Portal:**
1. In the left-hand menu, scroll down and click **Shared access signature**
2. Configure the following options:
   - **Allowed services**: ✔ Blob
   - **Allowed resource types**: ✔ Service, Container, Object
   - **Allowed permissions**: ✔ Read, Write, Create
   - **Start and expiry date/time**: Set a valid time window (e.g. now + 1 hour)
   - (Optional) Restrict to specific IPs or protocols (HTTPS recommended)
3. Click **Generate SAS and connection string**
4. Copy the **Blob service SAS URL** and **SAS token** ✂️

🔸 **CLI:**
```bash
az storage account generate-sas \
  --permissions rwd \
  --account-name <storage_account> \
  --services b \
  --resource-types sco \
  --expiry <YYYY-MM-DD>T<HH:MMZ> \
  --https-only \
  --output tsv
```
Use the output token with the URL:
```
https://<storage_account>.blob.core.windows.net/myfiles/<filename>?<sas_token>
```

---

### 3️⃣ Test SAS URL in Browser (Read-Only)

🔸 **Portal:**
1. Go to **Containers** → `myfiles`
2. Upload a file (e.g. `example.txt`) if not already uploaded
3. Click the file → Click **Properties**
4. Copy the **URL** (without SAS)
5. Append the **SAS token** to the URL:
   - `https://<account>.blob.core.windows.net/myfiles/example.txt?<SAS_token>`
6. Paste the full URL in a browser tab → press **Enter**
7. ✅ The file should open/download

🔸 **CLI:** *(Browser-based test; no CLI step required)*

---

### 4️⃣ Use SAS Token in Azure Storage Explorer (Optional)

🔸 **Portal:**
1. Open **Azure Storage Explorer**
2. Click **Add Account** → Choose **Use a shared access signature (SAS) URI**
3. Paste the full SAS URL
4. Access the container and test uploading/downloading files

🔸 **CLI:** *(No CLI equivalent; Storage Explorer is GUI-based)*

---

## 🚨 Notes
- SAS tokens are powerful – never share them insecurely
- You can revoke SAS access by regenerating account keys or using stored access policies

---

✅ **Demo complete – students now understand SAS tokens and how to use them securely!**

