# 🔐 Lab 2-B: Shared Access Signature (SAS) for Azure Blob Storage


<img width="1536" height="850" alt="IMAGE" src="https://github.com/user-attachments/assets/30894230-b6fa-4cec-9936-7caf6b4320a3" />

Learn how to create and test a **time-limited Shared Access Signature (SAS)** token to grant fine-grained, temporary access to Blob Storage **without assigning RBAC roles**.

---

## 🌟 Objective
Demonstrate the use of **Shared Access Signatures (SAS)** for secure, time-bound, delegated access to Azure Blob Storage.  
You will generate a SAS token, share it, and test access via the URL.

---

## 🧰 Prerequisites
- Azure Portal access  
- Azure CLI ≥ 2.60 installed (`az version`)  
- Any valid Azure subscription  
- One uploaded blob (e.g., `example.txt`) in a container  

---

## ⚙️ Variables (Parameterize Everything)
> Copy and adjust before execution to avoid naming collisions.

```bash
location="australiaeast"
rg="sastokendemo-rg"
storage="sasdemo$RANDOM"
container="myfiles$RANDOM"
blob_name="example.txt"
```

---

## 👣 Step-by-Step (Portal + CLI)

### 1️⃣ Create Storage Account & Upload Blob

**Portal**
1. Go to **Storage accounts → + Create**  
2. Resource Group → `$rg`  
3. Storage Account → `sasdemo<unique>`  
4. Region → **Australia East**, Redundancy → **Standard LRS**  
5. **Review + Create → Create**  
6. After creation → **Configuration** tab →  
   - Set **Default to Azure AD authorization** → **Disabled**  
   - Ensure **Public access override** → **Enabled** → **Save**  
7. **Containers → + Container** → Name `$container`, Access = Private → Create  
8. Upload any local file (e.g., `example.txt`) into the container  

**CLI**
```bash
az group create \
  --name "$rg" \
  --location "$location"

az storage account create \
  --name "$storage" \
  --resource-group "$rg" \
  --location "$location" \
  --sku Standard_LRS

az storage container create \
  --account-name "$storage" \
  --name "$container" \
  --auth-mode login \
  --public-access off

account_key=$(az storage account keys list \
  --account-name "$storage" \
  --resource-group "$rg" \
  --query '[0].value' \
  -o tsv)

echo "This is a SAS demo blob" > "$blob_name"

az storage blob upload \
  --account-name "$storage" \
  --container-name "$container" \
  --name "$blob_name" \
  --file "$blob_name" \
  --account-key "$account_key" \
  --overwrite
```

---

### 2️⃣ Generate a SAS Token

**Portal**
1. Open the **Storage Account → Containers → $container**  
2. Select your blob (e.g., `example.txt`)  
3. Click **Generate SAS** → Configure:  
   - ✅ Permissions: Read  
   - ⏰ Expiry: 1 hour  
   - 🔒 Protocol: HTTPS only  
4. Click **Generate SAS token and URL**  
5. Copy the **SAS URL** and **Token**

**CLI**
```bash
expiry=$(date -u -d "1 hour" '+%Y-%m-%dT%H:%MZ')

az storage account generate-sas \
  --permissions r \
  --account-name "$storage" \
  --services b \
  --resource-types sco \
  --expiry "$expiry" \
  --https-only \
  --output tsv
```

Compose the URL:
```bash
echo "https://$storage.blob.core.windows.net/$container/$blob_name?<SAS_TOKEN>"
```

---

### 3️⃣ Test Access via SAS URL

**Browser**
- Paste the full SAS URL into a browser tab  
- ✅ If valid, the blob will download or display  

---

### 4️⃣ (Optional) Use SAS in Azure Storage Explorer
1. Open Storage Explorer → **Add Account**  
2. Choose **Use a Shared Access Signature (SAS) URI**  
3. Paste the SAS URL → Connect → Verify access  

---

## 🚨 Notes
- SAS tokens grant temporary delegated access — treat them like passwords.  
- You can **revoke** SAS tokens by **regenerating account keys** or using **stored access policies**.  
- SAS is ideal for temporary app access without role assignments.

---

## 🧹 Clean Up
```bash
az group delete \
  --name "$rg" \
  --yes \
  --no-wait
```

---

## 🧠 Learning Outcomes
✅ Understand **SAS** as an alternative to RBAC for delegated access  
✅ Generate and test **time-limited blob access**  
✅ Recognize **security risks and revocation methods**  
✅ Contrast **identity-based** vs **token-based** access models


