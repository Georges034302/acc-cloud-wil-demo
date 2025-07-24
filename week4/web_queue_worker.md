# 🔄 Demo Guide: Web-Queue-Worker Architecture with Azure App Service, Storage Queue, and Azure Functions (Node.js Only)

## 🎯 Objective

Implement a decoupled Web-Queue-Worker pattern using:

- Azure App Service (Node.js Web Frontend)
- Azure Storage Queue (Message Queue)
- Azure Function (Node.js Background Worker)

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed and authenticated (`az login`)
- Azure Functions Core Tools (`func`)
- Node.js and npm installed
- Register Microsoft.Web provider

### ⚙️ Install Azure Functions Core Tools

```bash
npm i -g azure-functions-core-tools@4 --unsafe-perm true
```

### 📝 Register Microsoft.Web (One Time Only)

```bash
az provider register --namespace Microsoft.Web
```

---

## 👣 Step-by-Step Instructions

### 1️⃣ Setup Resource Group and Storage Queue

```bash
az group create   --name webqueue-demo-rg   --location australiaeast

STORAGE_QUEUE=webqueuestorage$RANDOM

az storage account create   --name $STORAGE_QUEUE   --resource-group webqueue-demo-rg   --location australiaeast   --sku Standard_LRS

STORAGE_CONN_STRING=$(az storage account show-connection-string   --name $STORAGE_QUEUE   --resource-group webqueue-demo-rg   --query connectionString   --output tsv)

az storage queue create   --account-name $STORAGE_QUEUE   --name taskqueue
```

---

### 2️⃣ Create Node.js Web App (Queue Producer)

#### 📁 Set Up Folder

```bash
mkdir webqueueapp
cd webqueueapp
npm init -y
npm install express dotenv @azure/storage-queue
touch index.js .env
```

#### ✍️ index.js

```javascript
const express = require('express');
const { QueueClient } = require('@azure/storage-queue');
require('dotenv').config();

const app = express();
app.use(express.urlencoded({ extended: true }));

const queueClient = new QueueClient(process.env.STORAGE_CONN_STRING, "taskqueue");
queueClient.createIfNotExists();

app.get('/', (req, res) => {
    res.send('<form method="POST"><input name="task"><input type="submit"></form>');
});

app.post('/', async (req, res) => {
    const task = req.body.task;
    await queueClient.sendMessage(task);
    res.send(`Task '${task}' added to queue.`);
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server running on port ${port}`));
```

#### ✍️ .env

```env
STORAGE_CONN_STRING=your-actual-connection-string-here
```

> You will inject this value as App Setting later.

#### 📜 Create App Service Plan and Web App

```bash
az appservice plan create \
  --name webqueue-plan \
  --resource-group webqueue-demo-rg \
  --sku B1 \
  --is-linux

WEB_APP=webqueueapp$RANDOM

az webapp create \
  --resource-group webqueue-demo-rg \
  --plan webqueue-plan \
  --name $WEB_APP \
  --runtime "NODE|18-lts"

az webapp config appsettings set \
  --resource-group webqueue-demo-rg \
  --name $WEB_APP \
  --settings STORAGE_CONN_STRING="$STORAGE_CONN_STRING"
```

#### 🚀 Deploy via Git (Manual Setup)

```bash
git init
git remote add azure https://<username>@$WEB_APP.scm.azurewebsites.net/$WEB_APP.git
echo "web: node index.js" > Procfile
git add .
git commit -m "Initial deployment"
git push azure main:master
```

> Use deployment credentials from Azure Portal → App Service → Deployment Center → FTPS Credentials

---

### 3️⃣ Create Azure Function to Process Queue (Node.js)

#### 📁 Initialize and Scaffold

```bash
func init workerfunc --javascript
cd workerfunc
func new --name ProcessTask --template "Azure Queue Storage trigger" --language JavaScript
```

Choose:
- Template: `Queue trigger`
- Function name: `ProcessTask`
- Queue name: `taskqueue`
- Storage connection: `AzureWebJobsStorage`

#### ✍️ Edit `src/functions/ProcessTask.js

```javascript
const { app } = require('@azure/functions');

app.storageQueue('ProcessTask', {
    queueName: 'taskqueue', // <-- match your queue name
    connection: 'AzureWebJobsStorage', // <-- use your storage connection setting
    handler: (queueItem, context) => {
        context.log('✅ Processing task:', queueItem);
    }
});

```

---

#### 🚀 Deploy Node.js Function App

```bash
# Create Function App
az functionapp create \
  --resource-group webqueue-demo-rg \
  --consumption-plan-location australiaeast \
  --runtime node \
  --runtime-version 20 \
  --functions-version 4 \
  --name workerfunc123 \
  --storage-account $STORAGE_QUEUE

# Deploy the NodeJS app
func azure functionapp publish workerfunc123
```

---

### 4️⃣ Test End-to-End

1. Open your deployed web app:  
   `https://<your-web-app-name>.azurewebsites.net/`

2. Submit a task.

3. It gets pushed to `taskqueue`.

4. Azure Function `workerfunc123` logs the message.

#### ✅ View Logs

```bash
az functionapp log tail   --name workerfunc123   --resource-group webqueue-demo-rg
```

You should see:

```
✅ Processing task: <your-task>
```

---

### 🧼 Clean Up

```bash
az group delete --name webqueue-demo-rg --yes --no-wait
```

---

✅ **Demo complete – you have implemented the Web-Queue-Worker pattern using Node.js for both producer and worker!**