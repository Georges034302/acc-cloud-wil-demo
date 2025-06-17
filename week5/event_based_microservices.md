# 🔔 Demo Guide: Event-Based Microservice Communication

## 🎯 Objective

Simulate asynchronous communication between microservices using Azure Storage Queue and Azure Functions. Learn to trigger background processing when messages are sent to the queue.

---

## 🧭 Prerequisites

- Azure CLI installed and logged in
- Azure subscription and access to Azure Portal
- Python 3.11 installed
- Visual Studio Code with Azure Functions Extension (for local deployment)

---

## 👣 Step-by-Step Instructions (CLI + Portal + ARM)

### 1️⃣ Create Resource Group and Storage Account

🔸 **CLI:**

```bash
az group create --name event-demo-rg --location australiaeast

az storage account create \
  --name eventdemostorage123 \
  --resource-group event-demo-rg \
  --location australiaeast \
  --sku Standard_LRS
```

🔸 **Portal:**

1. Go to [portal.azure.com](https://portal.azure.com)
2. Search **Storage accounts** → Click **+ Create**
3. Fill in:
   - Resource Group: `event-demo-rg`
   - Storage Account Name: `eventdemostorage123` (must be globally unique)
   - Region: `Australia East`
   - Performance: Standard
   - Redundancy: LRS
4. Click **Review + create** → **Create**

🔸 **ARM Template Deployment:**

1. Save the following JSON as `storage-arm.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2022-09-01",
      "name": "eventdemostorage123",
      "location": "australiaeast",
      "sku": { "name": "Standard_LRS" },
      "kind": "StorageV2",
      "properties": {}
    }
  ]
}
```

2. Deploy via **CLI**:

```bash
az deployment group create \
  --resource-group event-demo-rg \
  --template-file storage-arm.json
```

3. Or deploy via **Portal**:
   - Go to [portal.azure.com](https://portal.azure.com)
   - Search **Deploy a custom template** in the marketplace
   - Click **Build your own template in the editor**
   - Paste the JSON, then click **Save** and follow the wizard

---

### 2️⃣ Create Queue in Storage Account

🔸 **CLI:**

```bash
az storage queue create \
  --name orders \
  --account-name eventdemostorage123
```

🔸 **Portal:**

1. Go to **eventdemostorage123** → **Queues** (under Data storage)
2. Click **+ Queue**
3. Name: `orders` → Click **OK**

🔸 **ARM:** Not supported directly for queues — must be created post-deployment using CLI or Portal.

---

### 3️⃣ Create Azure Function App and Queue Trigger

🔸 **CLI:**

```bash
az functionapp create \
  --resource-group event-demo-rg \
  --consumption-plan-location australiaeast \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name queueprocessorfunc \
  --storage-account eventdemostorage123
```

🔸 **Create Function App Locally:**

```bash
func init QueueProcessorProj --python
cd QueueProcessorProj
func new --template "Azure Queue Storage trigger" --name ProcessOrder
```

Update `ProcessOrder/__init__.py`:

```python
import logging
import azure.functions as func

def main(msg: func.QueueMessage):
    logging.info(f"Processing order: {msg.get_body().decode()}")
```

🔸 **Deploy Locally to Azure:**

```bash
func azure functionapp publish queueprocessorfunc
```

🔸 **Portal Deployment:**

1. Go to **Function Apps** → **+ Create**
2. Fill in:
   - Function App name: `queueprocessorfunc`
   - Runtime: Python 3.11
   - Region: `Australia East`
   - Hosting Plan: Consumption
   - Storage Account: Select `eventdemostorage123`
3. Click **Create**
4. After deployment, go to **Functions** tab → Click **+ Add** → Choose **Queue trigger**
5. Fill in:
   - Function name: `ProcessOrder`
   - Queue name: `orders`
   - Storage account connection: `AzureWebJobsStorage`
6. Click **Create**

🔸 **ARM Template:** Use ARM for Function App shell creation, then deploy bindings via CLI or VS Code. Full end-to-end deployment of Queue-triggered code via ARM is recommended using **Bicep or GitHub Actions**.

---

### 4️⃣ Send Messages to Queue

🔸 **CLI:**

```bash
az storage message put \
  --queue-name orders \
  --account-name eventdemostorage123 \
  --content "Order #101 received"
```

🔸 **Portal:**

1. Go to **Storage Account** → **Queues** → `orders`
2. Click **+ Add Message**
3. Type message: `Order #101 received` → Click **OK**

---

### 5️⃣ Verify Function Execution

🔸 **Portal:**

1. Go to **Function App** → **Functions** → `ProcessOrder`
2. Click **Monitor** to view recent executions
3. Click any invocation to see logs like:
   - `Processing order: Order #101 received`

🔸 **CLI (Log stream):**

```bash
az webapp log tail --name queueprocessorfunc --resource-group event-demo-rg
```

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name event-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have implemented async communication using Azure Queue and Functions via Portal, CLI, and ARM (where applicable)!**

