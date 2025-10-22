# 🧪 Lab 4-C – Web–Queue–Worker Architecture Using Azure App Service and Storage Queue (Node.js)
<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/6798c0a5-e8e3-44ad-9cc6-ec11ffeb2102" />

## 🎯 Objective
Deploy two Node.js applications:  
- **Web App (Producer):** Adds tasks to an Azure Storage Queue  
- **Worker App (Consumer):** Processes tasks from the queue  

Demonstrates the **Web–Queue–Worker pattern** for decoupled workloads using **Azure App Service** and **Azure Storage Queue**, without Azure Functions.

---

## 🧭 Prerequisites
- Azure CLI ≥ 2.60  
- Logged in (`az login`)  
- Node.js ≥ 18 + npm  
- [Azure Portal](https://portal.azure.com)  
- Provider registration:
  ```bash
  az provider register \
    --namespace Microsoft.Web
  ```

---

## ⚙️ Step 1 – Define Variables
Set the following variables in your shell and store them into a `.env` file:
```bash
RG_NAME="webqueueworker-demo-rg"
PLAN_NAME="webqueueworker-plan$RANDOM"
LOCATION="australiaeast"
SKU="B1"
STORAGE_ACCOUNT="queueworker$RANDOM"
QUEUE_NAME="taskqueue"
WEB_APP="queuewebapp$RANDOM"
WORKER_APP="queueworkerapp$RANDOM"

cat <<EOF > .env
RG_NAME="$RG_NAME"
PLAN_NAME="$PLAN_NAME"
LOCATION="$LOCATION"
SKU="$SKU"
STORAGE_ACCOUNT="$STORAGE_ACCOUNT"
QUEUE_NAME="$QUEUE_NAME"
WEB_APP="$WEB_APP"
WORKER_APP="$WORKER_APP"
EOF
```

Then load the variables in your shell before running commands:
```bash
set -a
source .env
set +a
```

---

## 🧱 Step 2 – Create Resource Group and Storage Queue

### 2.1 – Create Resource Group
```bash
# Create a new resource group to hold all resources for this lab
az group create \
  --name $RG_NAME \
  --location $LOCATION
```

### 2.2 – Create Storage Account
```bash
# Create an Azure Storage Account for queue storage
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG_NAME \
  --location $LOCATION \
  --sku Standard_LRS
```

### 2.3 – Get Storage Connection String
```bash
# Retrieve the connection string for the storage account
STORAGE_CONN_STRING=$( \
  az storage account show-connection-string \
    --name $STORAGE_ACCOUNT \
    --resource-group $RG_NAME \
    --query connectionString \
    -o tsv \
)
```

### 2.4 – Create Storage Queue
```bash
# Create a queue in the storage account for tasks
az storage queue create \
  --account-name $STORAGE_ACCOUNT \
  --name $QUEUE_NAME
```

### 2.5 – Append Storage Connection Data to .env**
```bash
# Append only the storage connection string to your .env file (QUEUE_NAME is already present)
echo "STORAGE_CONN_STRING=$STORAGE_CONN_STRING" >> .env
```
---

## 🌐 Step 3 – Create and Deploy Web App (Producer)

### 3.1 – Create Project
```bash
mkdir webapp && cd webapp
npm init -y
npm install express dotenv @azure/storage-queue
```

**index.js**
```javascript
const express = require('express');
const { QueueClient } = require('@azure/storage-queue');
require('dotenv').config();

const app = express();
app.use(express.urlencoded({ extended: true }));

const queueClient = new QueueClient(process.env.STORAGE_CONN_STRING, process.env.QUEUE_NAME);
queueClient.createIfNotExists();

app.get('/', (req, res) => {
  res.send('<h2>Task Queue</h2><form method="POST"><input name="task"><button>Submit</button></form>');
});

app.post('/', async (req, res) => {
  const task = req.body.task;
  await queueClient.sendMessage(task);
  res.send(`✅ Task '${task}' added to queue.`);
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Web app running on port ${port}`));
```

---

### 3.2 – Create App Service Plan and Web App

```bash
# Create an App Service plan for hosting web apps (Linux)
az appservice plan create \
  --name $PLAN_NAME \
  --resource-group $RG_NAME \
  --sku $SKU \
  --is-linux

# Create a Node.js 20 web app using the above plan
az webapp create \
  --resource-group $RG_NAME \
  --plan $PLAN_NAME \
  --name $WEB_APP \
  --runtime "NODE|20-lts"

# Set app settings for the web app (storage connection string and queue name)
az webapp config appsettings set \
  --resource-group $RG_NAME \
  --name $WEB_APP \
  --settings STORAGE_CONN_STRING="$STORAGE_CONN_STRING" \
  QUEUE_NAME="$QUEUE_NAME"
```

---

### 3.3 – Deploy via ZIP

```bash
# Change to the webapp directory
cd webapp
# Create a ZIP archive of the webapp for deployment
zip -r ../webapp-deploy.zip .
# Deploy the ZIP archive to the Azure Web App
az webapp deploy \
  --resource-group "$RG_NAME" \
  --name "$WEB_APP" \
  --src-path ../webapp-deploy.zip \
  --type zip
# Remove the ZIP archive after deployment
rm ../webapp-deploy.zip || true
```

---

## ⚙️ Step 4 – Create and Deploy Worker App (Consumer)

### 4.1 – Create Project
```bash
# Create a new directory for the worker app and enter it
mkdir workerapp && cd workerapp
# Initialize a new Node.js project
npm init -y
# Install required packages for the worker app
npm install dotenv @azure/storage-queue
```

**worker.js**
```javascript
const { QueueClient } = require('@azure/storage-queue');
require('dotenv').config();

const queueClient = new QueueClient(process.env.STORAGE_CONN_STRING, process.env.QUEUE_NAME);

async function processQueue() {
  const messages = await queueClient.receiveMessages({ numberOfMessages: 5 });
  if (messages.receivedMessageItems.length > 0) {
    for (const msg of messages.receivedMessageItems) {
      console.log("✅ Processing task:", msg.messageText);
      await queueClient.deleteMessage(msg.messageId, msg.popReceipt);
    }
  } else {
    console.log("⏳ No messages to process...");
  }
}

setInterval(processQueue, 10000);
```

---

### 4.2 – Create Azure Worker App

```bash
# Create a Node.js 20 worker app using the shared App Service plan
az webapp create \
  --resource-group $RG_NAME \
  --plan $PLAN_NAME \
  --name $WORKER_APP \
  --runtime "NODE|20-lts"

# Set app settings for the worker app (storage connection string and queue name)
az webapp config appsettings set \
  --resource-group $RG_NAME \
  --name $WORKER_APP \
  --settings STORAGE_CONN_STRING="$STORAGE_CONN_STRING" \
  QUEUE_NAME="$QUEUE_NAME"
```

---

### 4.3 – Deploy via ZIP

```bash
# Create a ZIP archive of the worker app for deployment
zip -r ../workerapp-deploy.zip .
# Deploy the ZIP archive to the Azure Worker App
az webapp deploy \
  --resource-group "$RG_NAME" \
  --name "$WORKER_APP" \
  --src-path ../workerapp-deploy.zip \
  --type zip
# Remove the ZIP archive after deployment
rm ../workerapp-deploy.zip || true
```

---

## 🧪 Step 5 – Test End-to-End
1. Open the Web App in your browser:
   ```bash
   "$BROWSER" "https://$WEB_APP.azurewebsites.net" || true
   # Or manually visit: https://$WEB_APP.azurewebsites.net
   ```

2. Submit a few tasks using the web form.

3. (Optional) Test with curl:
   ```bash
   curl -X POST \
     -d "task=Build Docker image" \
     "https://$WEB_APP.azurewebsites.net/"
   ```

4. Tail worker logs to verify processing:
   ```bash
   az webapp log tail \
     --name $WORKER_APP \
     --resource-group $RG_NAME
   ```

**Expected Outcome:**
```
✅ Processing task: Build Docker image
✅ Processing task: Deploy app
```

If you do not see tasks being processed, check:
- That the web app is running and reachable
- That the worker app is running and has correct app settings
- That the queue contains messages

---

## 🧰 Step 6 – Troubleshooting

| Issue | Cause | Fix |
|-------|--------|-----|
| Queue not created | Wrong name or region | Run `az storage queue create` again |
| No logs | Worker idle | Restart App Service (`az webapp restart`) |
| 403 error | Missing storage settings | Ensure app settings are set |

---

## 🧼 Step 7 – Clean Up
```bash
# Delete the resource group and all resources created for this lab
az group delete \
  --name $RG_NAME \
  --yes \
  --no-wait
```

---

## ✅ Lab Summary

| Component | Purpose |
|------------|----------|
| Web App (Producer) | Sends tasks to queue |
| Storage Queue | Buffers messages |
| Worker App (Consumer) | Processes queued tasks |

**Architecture Highlights**
- Decoupled producer/consumer design  
- Independent scaling of apps  
- 100% PaaS solution (no Functions needed)

---

### 🧩 Result
You deployed a **Web–Queue–Worker** system using:
- Node.js Express web and worker apps  
- Azure Storage Queue for asynchronous message processing  
- Shared Azure App Service Plan and ZIP deployment
