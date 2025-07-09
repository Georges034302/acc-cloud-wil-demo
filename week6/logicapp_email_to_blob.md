# 🔁 Demo 5 Guide: Automate Email to Blob Upload with Azure Logic App

## 🎯 Objective
Create an Azure Logic App that monitors an email inbox for incoming messages with attachments and saves those attachments to a Blob Storage container using **Portal**, **CLI**, and **ARM**.

---

## 🧭 Prerequisites
- Azure subscription
- Office 365 or Outlook.com email account
- Azure CLI installed
- Permissions to assign roles

---

## 👣 Step-by-Step Instructions (Portal + CLI + ARM)

### 1️⃣ Create Resource Group and Storage Account

🔸 **CLI:**
```bash
az group create --name logicapp-rg --location australiaeast

az storage account create \
  --name emailblobsa123 \
  --resource-group logicapp-rg \
  --location australiaeast \
  --sku Standard_LRS

az storage container create \
  --account-name emailblobsa123 \
  --name attachments \
  --auth-mode login
```

🔸 **Portal:**
1. Go to **Storage accounts** → **+ Create**
2. Resource Group: `logicapp-rg`
3. Storage account name: `emailblobsa123`
4. Region: Australia East → **Review + Create**
5. Navigate to storage account → **Containers** → **+ Container**
6. Name: `attachments`, Access level: Private → **Create**

---

### 2️⃣ Create Logic App

🔸 **CLI:**
```bash
az logicapp create \
  --resource-group logicapp-rg \
  --name email-to-blob \
  --location australiaeast \
  --definition "@logicapp-definition.json" \
  --identity-type SystemAssigned
```

> You’ll define `logicapp-definition.json` in step 4.

🔸 **Portal:**
1. Go to **Logic Apps** → **+ Create**
2. Resource Group: `logicapp-rg`
3. Name: `email-to-blob`
4. Region: Australia East
5. Plan Type: **Consumption**
6. Enable **System Assigned Identity**
7. Click **Review + Create**

---

### 3️⃣ Grant Logic App Access to Blob Storage

🔸 **CLI:**
```bash
LOGIC_ID=$(az logicapp show \
  --name email-to-blob \
  --resource-group logicapp-rg \
  --query identity.principalId --output tsv)

STORAGE_ID=$(az storage account show \
  --name emailblobsa123 \
  --resource-group logicapp-rg \
  --query id --output tsv)

az role assignment create \
  --assignee $LOGIC_ID \
  --role "Storage Blob Data Contributor" \
  --scope $STORAGE_ID
```

🔸 **Portal:**
1. Go to **Logic App** → **Identity** → Enable System Assigned → Copy Object ID
2. Go to **Storage Account** → **Access Control (IAM)** → **+ Add** → **Add Role Assignment**
3. Role: `Storage Blob Data Contributor` → Next
4. Select members → paste Logic App Object ID → Select → Next → **Review + Assign**

---

### 4️⃣ Define Logic App Workflow

🔸 **Portal:**
1. Open Logic App → Designer → **Blank Logic App**
2. Add trigger: `When a new email arrives (V3)` (Office 365 Outlook or Outlook.com)
3. Sign in → Folder: `Inbox`, Only with Attachments: `Yes`
4. Add action: **Apply to each** → `Attachments`
5. Inside loop:
   - Add action: **Create blob** (Azure Blob Storage)
   - Sign in → Container: `attachments`
   - Blob name: `Name` (dynamic)
   - Blob content: `ContentBytes` (dynamic)

🔸 **ARM JSON** (save as `logicapp-definition.json`):
```json
{
  "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
  "actions": {
    "For_each": {
      "foreach": "@triggerOutputs()?['body/Attachments']",
      "actions": {
        "Create_blob": {
          "inputs": {
            "host": {
              "connection": {
                "name": "@parameters('$connections')['azureblob']['connectionId']"
              }
            },
            "method": "post",
            "path": "/v2/datasets/default/files",
            "queries": {
              "folderPath": "/attachments",
              "name": "@items('For_each')?['Name']"
            },
            "body": "@items('For_each')?['ContentBytes']"
          },
          "runAfter": {},
          "type": "ApiConnection"
        }
      },
      "type": "Foreach"
    }
  },
  "contentVersion": "1.0.0.0",
  "outputs": {},
  "parameters": {
    "$connections": {
      "defaultValue": {},
      "type": "Object"
    }
  },
  "triggers": {
    "When_a_new_email_arrives": {
      "inputs": {
        "host": {
          "connection": {
            "name": "@parameters('$connections')['office365']['connectionId']"
          }
        },
        "method": "get",
        "path": "/v2/Mail/OnNewEmail",
        "queries": {
          "folderPath": "Inbox",
          "hasAttachment": true
        }
      },
      "recurrence": {
        "frequency": "Minute",
        "interval": 1
      },
      "type": "ApiConnection"
    }
  }
}
```

🔸 **ARM Deployment Instructions:**
1. Save the above JSON to a file named `logicapp-definition.json`
2. Run the following CLI command:
```bash
az deployment group create \
  --resource-group logicapp-rg \
  --template-file logicapp-definition.json \
  --parameters '{"$connections": {"value": {}}}'
```

> 💡 Note: You may need to authorize connectors in the Portal after deployment.

---

### 5️⃣ Test Logic App
1. Send email with a file attachment to connected mailbox
2. Wait ~1 min or manually run Logic App
3. Open **Storage Account** → **Containers** → `attachments`
4. ✅ File appears in the container

---

### 6️⃣ Clean Up
```bash
az group delete --name logicapp-rg --yes --no-wait
```

✅ **Demo complete – Logic App reads new emails with attachments and saves them to Blob Storage. All steps covered with Portal, CLI, and ARM.**

