# 🔐 Demo Guide: Shared Access Signature (SAS) for Azure Blob Storage

## 🌟 Objective

Learn how to create and test a time-limited Shared Access Signature (SAS) token to grant fine-grained access to Blob Storage without assigning roles.

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed
- One storage account and a blob container (e.g., `myfiles`)
- One uploaded blob (e.g., `example.txt`)

---

## 👣 Step-by-Step Instructions (Portal + CLI)

### 0️⃣ Setup: Create Storage Account, Container & Upload File

👤 **Performed by: Admin User**

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **Storage accounts** → Click **+ Create**
3. Fill in:
   - Resource Group: `sastokendemo-rg`
   - Storage Account: `sasdemo<unique>`
   - Region: `Australia East`
   - SKU: Standard\_LRS
4. Click **Review + create** → **Create**
5. After deployment, go to **Containers** → **+ Container**
6. Name: `myfiles`, Access: **Private** → Click **Create**
7. Open the container → Click **Upload** → Choose a file (e.g. `example.txt`) → Click **Upload**

🔸 **CLI:**

```bash
az group create --name sastokendemo-rg --location australiaeast

az storage account create \
  --name sasdemo123 \
  --resource-group sastokendemo-rg \
  --location australiaeast \
  --sku Standard_LRS

az storage container create \
  --account-name sasdemo123 \
  --name myfiles \
  --auth-mode login \
  --public-access off

az storage blob upload \
  --account-name sasdemo123 \
  --container-name myfiles \
  --name example.txt \
  --file ./example.txt \
  --auth-mode login \
  --overwrite true
```

---

### 1️⃣ Generate SAS Token

👤 **Performed by: Admin User**

🔸 **Portal:**

1. Go to the **Storage Account** → Scroll down to **Shared access signature**
2. Configure:
   - ✔ **Allowed services**: Blob
   - ✔ **Resource types**: Service, Container, Object
   - ✔ **Permissions**: Read, Write, Create
   - Set **Start time**: now
   - Set **Expiry time**: e.g., 1 hour from now
   - ✅ Enable **HTTPS only**
3. Click **Generate SAS and connection string**
4. Copy:
   - **Blob service SAS token**
   - **Blob service SAS URL**

🔸 **CLI:**

```bash
az storage account generate-sas \
  --permissions rwd \
  --account-name sasdemo123 \
  --services b \
  --resource-types sco \
  --expiry "$(date -u -d '1 hour' '+%Y-%m-%dT%H:%MZ')" \
  --https-only \
  --output tsv
```

Then append the SAS token to the blob URL:

```bash
# URL format:
https://sasdemo123.blob.core.windows.net/myfiles/example.txt?<SAS_TOKEN>
```

---

### 2️⃣ Test Access via SAS Link

👤 **Performed by: Any user (e.g., Student)**

🔸 **Browser:**

1. Paste the full URL into a browser tab
2. ✅ If the token is valid, the file should display or download

---

### 3️⃣ (Optional) Use SAS in Storage Explorer

👤 **Performed by: Any user (e.g., Student)**

🔸 **Azure Storage Explorer:**

1. Open Storage Explorer → **Add Account**
2. Select **Use a shared access signature (SAS) URI**
3. Paste the full URL copied earlier
4. Access the container and verify you can see and download the blob

---

## 🚨 Notes

- You can **revoke SAS tokens** by regenerating the account keys or configuring stored access policies
- SAS tokens offer granular access for apps and users **without needing to assign IAM roles**
- Be cautious: treat tokens like passwords

---

## 🧼 Clean Up (Admin User)

```bash
az group delete --name sastokendemo-rg --yes --no-wait
```

---

✅ **Demo complete – students have experienced temporary, URL-based access to Blob Storage using SAS tokens!**

