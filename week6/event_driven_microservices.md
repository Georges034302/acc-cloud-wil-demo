# 🔔 Demo 3 Guide: Event-Based Microservice Communication

## 🎯 Objective

Simulate asynchronous communication between microservices using Azure Storage Queue and Azure Functions. Learn to trigger background processing when messages are sent to the queue.

---

## 🧭 Prerequisites

- Azure CLI installed and logged in
- Azure subscription and access to Azure Portal
- Python 3.11 installed (3.10 as fallback)
- Visual Studio Code with Azure Functions Extension (for local deployment)
- **Azure Functions Core Tools installed:**  
  ```bash
  npm install -g azure-functions-core-tools@4 --unsafe-perm true
  ```
---

## 👣 Step-by-Step Instructions

### 1️⃣ Create Resource Group and Storage Account

```bash
az group create --name event-demo-rg --location australiaeast

EVENT_STORAGE=eventdemostorage$RANDOM
az storage account create \
  --name $EVENT_STORAGE \
  --resource-group event-demo-rg \
  --location australiaeast \
  --sku Standard_LRS
```

### 2️⃣ Create Queue in Storage Account

```bash
# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --account-name $EVENT_STORAGE \
  --resource-group event-demo-rg \
  --query "[0].value" --output tsv)

# Create queue using key auth
az storage queue create \
  --name orders \
  --account-name $EVENT_STORAGE \
  --account-key $STORAGE_KEY
```

### 3️⃣ Assign Contributor Role to Current User (for Full Access)

To allow your user account to manage the storage account and related services:

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Storage accounts** → `eventdemostorage123 <unique name>`
3. In the left menu, select **Access control (IAM)**
4. Click **+ Add > Add role assignment**
5. Role: **Contributor**
6. Assign access to: **User, group, or service principal**
7. Select your account (signed-in user)
8. Click **Save**

---

### 4️⃣ Create Azure Function App

```bash
az functionapp create \
  --resource-group event-demo-rg \
  --consumption-plan-location australiaeast \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name queueprocessorfunc \
  --storage-account $EVENT_STORAGE
```

### 5️⃣ Create Function Locally

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

Install dependencies:

```bash
pip install azure-functions
pip freeze > requirements.txt
```

### 6️⃣ Deploy Locally to Azure

```bash
func azure functionapp publish queueprocessorfunc
```

---

### 7️⃣ Send Messages to Queue

```bash
az storage message put \
  --queue-name orders \
  --account-name $EVENT_STORAGE \
  --account-key $STORAGE_KEY \
  --content "Order #101 received"
```

---

### 8️⃣ Verify Function Execution

Enable App Logging (if not already):

```bash
az webapp log config \
  --name queueprocessorfunc \
  --resource-group event-demo-rg \
  --application-logging true
```

Stream logs:

```bash
az webapp log tail \
  --name queueprocessorfunc \
  --resource-group event-demo-rg
```

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name event-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have implemented async communication using Azure Queue and Functions via CLI!**

