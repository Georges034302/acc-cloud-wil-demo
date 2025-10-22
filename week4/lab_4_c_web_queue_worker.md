# 🧪 Lab 4-C – Web–Queue–Worker Architecture Using Azure App Service and Storage Queue (Node.js)
<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/6798c0a5-e8e3-44ad-9cc6-ec11ffeb2102" />

## 🎯 Objective
Deploy two Node.js applications —  
- **Web App (Producer):** Adds tasks to an Azure Storage Queue  
- **Worker App (Consumer):** Processes tasks from the queue  

Demonstrates the **Web–Queue–Worker pattern** for decoupled workloads using **Azure App Service** and **Azure Storage Queue**, without Azure Functions.

---

## 🧭 Prerequisites

- Azure CLI (≥ 2.60)
- Authenticated session (`az login`)
- Node.js ≥ 18 + npm
- Git installed
- [Azure Portal](https://portal.azure.com)
- **Microsoft.Web** provider registered:
  ```bash
  az provider register \
    --namespace Microsoft.Web
  ```

---

## ⚙️ Step 1 – Define Variables
```bash
RG_NAME="webqueueworker-demo-rg"
PLAN_NAME="webqueueworker-plan"
LOCATION="australiaeast"
SKU="B1"

STORAGE_ACCOUNT="queueworker$RANDOM"
QUEUE_NAME="taskqueue"
WEB_APP="queuewebapp$RANDOM"
WORKER_APP="queueworkerapp$RANDOM"
```

---

## 🧱 Step 2 – Create Resource Group and Storage Queue
```bash
# Create resource group
az group create \
  --name $RG_NAME \
  --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG_NAME \
  --location $LOCATION \
  --sku Standard_LRS

# Get connection string
STORAGE_CONN_STRING=$(
  az storage account show-connection-string \
    --name $STORAGE_ACCOUNT \
    --resource-group $RG_NAME \
    --query connectionString \
    -o tsv
)

# Create queue
az storage queue create \
  --account-name $STORAGE_ACCOUNT \
  --name $QUEUE_NAME
```

---

## 🌐 Step 3 – Create Web App (Producer)

### 3.1 – Create Project
```bash
mkdir webapp
cd webapp
npm init -y
npm install express dotenv @azure/storage-queue
touch index.js .env
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

**.env**
```
STORAGE_CONN_STRING=<to-be-injected>
QUEUE_NAME=taskqueue
```

---

### 3.2 – Deploy to Azure
```bash
az appservice plan create \
  --name $PLAN_NAME \
  --resource-group $RG_NAME \
  --sku $SKU \
  --is-linux

az webapp create \
  --resource-group $RG_NAME \
  --plan $PLAN_NAME \
  --name $WEB_APP \
  --runtime "NODE|20-lts"

az webapp config appsettings set \
  --resource-group $RG_NAME \
  --name $WEB_APP \
  --settings STORAGE_CONN_STRING="$STORAGE_CONN_STRING" \
  QUEUE_NAME="$QUEUE_NAME"
```

---

### 3.3 – Deploy via Git
```bash
git init
echo "web: node index.js" > Procfile
git add .
git commit -m "Initial commit - Web Queue Producer"
git remote add azure \
  "https://<username>@$WEB_APP.scm.azurewebsites.net/$WEB_APP.git"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push azure "$BRANCH":master
```

---

## ⚙️ Step 4 – Create Worker App (Consumer)

### 4.1 – Create Project
```bash
cd ..
mkdir workerapp
cd workerapp
npm init -y
npm install dotenv @azure/storage-queue
touch worker.js .env
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

// Poll queue every 10 seconds
setInterval(processQueue, 10000);
```

**.env**
```
STORAGE_CONN_STRING=<to-be-injected>
QUEUE_NAME=taskqueue
```

---

### 4.2 – Deploy to Azure
```bash
az webapp create \
  --resource-group $RG_NAME \
  --plan $PLAN_NAME \
  --name $WORKER_APP \
  --runtime "NODE|20-lts"

az webapp config appsettings set \
  --resource-group $RG_NAME \
  --name $WORKER_APP \
  --settings STORAGE_CONN_STRING="$STORAGE_CONN_STRING" \
  QUEUE_NAME="$QUEUE_NAME"
```

---

### 4.3 – Deploy via Git
```bash
git init
echo "web: node worker.js" > Procfile
git add .
git commit -m "Initial commit - Queue Worker"
git remote add azure \
  "https://<username>@$WORKER_APP.scm.azurewebsites.net/$WORKER_APP.git"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push azure "$BRANCH":master
```

---

## 🧪 Step 5 – Test End-to-End

1. Open the **Web App** in your browser:  
   `https://$WEB_APP.azurewebsites.net`

2. Submit a few tasks via the form.

3. The **Worker App** continuously polls and logs processed tasks.

4. View logs:
  ```bash
  az webapp log tail \
    --name $WORKER_APP \
    --resource-group $RG_NAME
  ```

✅ You should see:
```
✅ Processing task: Build Docker image
✅ Processing task: Deploy app
```

---

## 🧰 Step 6 – Troubleshooting

| Issue | Cause | Fix |
|-------|--------|-----|
| Queue not created | Wrong name or region | Run `az storage queue create` again |
| No logs | Worker not running | Restart App Service: `az webapp restart` |
| 403 error | Missing app settings | Ensure correct storage connection string set |

---

## 🧼 Step 7 – Clean Up Resources
```bash
az group delete \
  --name $RG_NAME \
  --yes \
  --no-wait
```

---

## ✅ Lab Summary

| Component | Purpose |
|------------|----------|
| Web App (Producer) | Accepts user input and sends to queue |
| Storage Queue | Buffers messages between services |
| Worker App (Consumer) | Polls and processes queued messages |

**Architecture:**  
- Decoupled via message queue  
- Independent scaling for producer and worker  
- Works entirely within Azure App Service (no Functions)

---

### 🧩 Result
You have built a **Web–Queue–Worker** system in Azure using:
- **Node.js** web and worker apps  
- **Azure Storage Queue** for communication  
- 100% **App Service PaaS** architecture (no Functions required)

---


