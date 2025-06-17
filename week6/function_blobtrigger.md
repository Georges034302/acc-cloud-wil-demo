# ⚡️ Demo 2 Guide: Trigger Azure Function with Blob Storage Event

## 🎯 Objective

Deploy an Azure Function that automatically triggers when a file is uploaded to Azure Blob Storage using **CLI**, **Portal**, and **ARM template** options.

---

## 🧭 Prerequisites

- Azure CLI and Functions Core Tools installed
- Docker (optional for local testing)
- Azure Storage Account
- VS Code or local development environment for the function

---

## 👣 Step-by-Step Instructions (CLI + Portal + ARM)

### 1️⃣ Create Resource Group and Storage Account

🔸 **CLI:**

```bash
az group create --name blobtrigger-rg --location australiaeast

az storage account create \
  --name blobtriggersa123 \
  --resource-group blobtrigger-rg \
  --location australiaeast \
  --sku Standard_LRS
```

🔸 **Portal:**

1. Go to **Storage Accounts** → **+ Create**
2. Resource Group: `blobtrigger-rg`
3. Name: `blobtriggersa123` (must be globally unique)
4. Location: Australia East
5. Review + Create

---

### 2️⃣ Create a Blob Container

🔸 **CLI:**

```bash
az storage container create \
  --account-name blobtriggersa123 \
  --name uploads \
  --auth-mode login
```

🔸 **Portal:**

1. Navigate to your Storage Account
2. Under **Data storage**, click **Containers**
3. Click **+ Container** → Name: `uploads`, Access level: Private → Create

---

### 3️⃣ Create a Function App with Blob Trigger

🔸 **CLI:**

```bash
az functionapp create \
  --resource-group blobtrigger-rg \
  --consumption-plan-location australiaeast \
  --runtime python \
  --functions-version 4 \
  --name blobtriggerfunc123 \
  --storage-account blobtriggersa123
```

🔸 **Portal:**

1. Go to **Function Apps** → **+ Create**
2. Resource Group: `blobtrigger-rg`
3. Name: `blobtriggerfunc123`
4. Runtime stack: Python
5. Region: Australia East
6. Hosting: Use existing storage account `blobtriggersa123`
7. Plan type: Consumption → Review + Create

---

### 4️⃣ Assign Blob Role to Function Identity

🔸 **CLI:**

```bash
az functionapp identity assign \
  --name blobtriggerfunc123 \
  --resource-group blobtrigger-rg

FUNCTION_IDENTITY=$(az functionapp show \
  --name blobtriggerfunc123 \
  --resource-group blobtrigger-rg \
  --query identity.principalId --output tsv)

STORAGE_SCOPE=$(az storage account show \
  --name blobtriggersa123 \
  --resource-group blobtrigger-rg \
  --query id --output tsv)

az role assignment create \
  --assignee $FUNCTION_IDENTITY \
  --role "Storage Blob Data Contributor" \
  --scope $STORAGE_SCOPE
```

🔸 **Portal:**

1. Go to **Function App** → **Identity** → Enable System Assigned
2. Copy the Object ID
3. Go to **Storage Account** → **Access Control (IAM)**
4. Add Role Assignment:
   - Role: `Storage Blob Data Contributor`
   - Assign access to: User, group, or service principal
   - Select: paste the Object ID of the function
5. Click **Review + Assign**

---

### 5️⃣ Create and Deploy Function Locally

🔸 **Local Init and Code:**

```bash
func init BlobProcessor --python
cd BlobProcessor
func new --name ProcessBlob --template "Azure Blob Storage trigger" --authlevel "function"
```

🔸 `function.json` binding config:

```json
{
  "bindings": [
    {
      "name": "myblob",
      "type": "blobTrigger",
      "direction": "in",
      "path": "uploads/{name}",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

🔸 **Deploy:**

```bash
func azure functionapp publish blobtriggerfunc123
```

---

### 6️⃣ Upload File to Trigger Function

🔸 **CLI:**

```bash
az storage blob upload \
  --account-name blobtriggersa123 \
  --container-name uploads \
  --name hello.txt \
  --file ./hello.txt \
  --auth-mode login
```

🔸 **Portal:**

1. Go to your Storage Account → Containers → `uploads`
2. Click **Upload**, choose file → Upload

✅ This will trigger the function. Use **Log stream** in the Function App to view the output.

---

### 7️⃣ ARM Deployment (Optional)

📄 Save this as `blobtrigger-arm.json` and customize as needed:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2022-03-01",
      "name": "blobtriggerfunc123",
      "location": "australiaeast",
      "kind": "functionapp",
      "properties": {
        "siteConfig": {
          "appSettings": [
            {"name": "FUNCTIONS_WORKER_RUNTIME", "value": "python"},
            {"name": "AzureWebJobsStorage", "value": "<your-connection-string>"},
            {"name": "WEBSITE_RUN_FROM_PACKAGE", "value": "1"}
          ]
        },
        "serverFarmId": "/subscriptions/<subscription-id>/resourceGroups/blobtrigger-rg/providers/Microsoft.Web/serverfarms/<plan-name>"
      },
      "identity": {
        "type": "SystemAssigned"
      }
    }
  ]
}
```

Deploy with:

```bash
az deployment group create \
  --resource-group blobtrigger-rg \
  --template-file blobtrigger-arm.json
```

---

### 8️⃣ Clean Up

```bash
az group delete --name blobtrigger-rg --yes --no-wait
```

✅ **Demo complete – students created a secure, blob-triggered Azure Function using Portal, CLI, and ARM with no skipped steps.**

