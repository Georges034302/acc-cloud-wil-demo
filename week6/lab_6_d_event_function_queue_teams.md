# 💬 Lab 6-D: Event-Driven Notification System Using Azure Queue Trigger and Microsoft Teams Webhook

<img width="1536" height="619" alt="IMG" src="https://github.com/user-attachments/assets/689aab98-9019-4926-833c-2329e29a3cb9" />

---

## 🎯 Objectives

In this lab, you will:
- Build a **serverless Azure Function (Node 20 LTS)** triggered by a **Storage Queue**  
- Process both **info** and **error** events  
- Send notifications to a **Microsoft Teams channel** via **Incoming Webhook**  
- Demonstrate a fully event-driven alerting workflow with no external dependencies

---

## 🧭 Prerequisites

- ✅ Active **Azure Subscription**  
- ✅ **Azure CLI v2.57+** installed  
- ✅ **Node.js 20 LTS** installed (`node -v`)  
- ✅ **Azure Functions Core Tools v4**
  ```bash
  npm install -g azure-functions-core-tools@4 --unsafe-perm true
  func --version
  ```
- ✅ **Microsoft Teams** channel with an **Incoming Webhook** created  
  (Channel → Connectors → Incoming Webhook → copy the Webhook URL)

---

## ⚙️ 1️⃣ Create Azure Resources

```bash
# Set environment variables for resource names and location
export LOCATION="australiaeast"
export RG="rg-lab6d-notify"
export STORAGE="stnotify$RANDOM"
export FUNC_APP="func-notify$RANDOM"
export QUEUE="event-queue"

# Create a new resource group in Azure
az group create \
  --name $RG \
  --location $LOCATION

# Create a storage account for queue and function app
az storage account create \
  --name $STORAGE \
  --location $LOCATION \
  --resource-group $RG \
  --sku Standard_LRS

# Create an Azure Function App using Node.js 20 LTS
az functionapp create \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --runtime node \
  --runtime-version 20 \
  --functions-version 4 \
  --name $FUNC_APP \
  --storage-account $STORAGE \
  --os-type Linux

# Create a storage queue for event messages
az storage queue create \
  --name $QUEUE \
  --account-name $STORAGE
```

---

## 💻 2️⃣ Initialize Function Project (Node 20)

```bash
PROJECT="lab6d-notify-func"
FUNCTION_NAME="EventNotifier"

# Initialize a new Azure Functions project (Node.js)
func init $PROJECT \
  --worker-runtime node \
  --language javascript

# Change directory to the new project folder
cd $PROJECT

# Create a new Queue Trigger function
func new \
  --name $FUNCTION_NAME \
  --template "Queue trigger"
```

---

## 🧠 3️⃣ Update Function Code to Post to Teams

### 📁 Project Structure
```
lab6d-notify-func/
├── package.json
├── EventNotifier/
│   ├── function.json
│   └── index.js
└── host.json
```

### 🧩 EventNotifier/function.json
```json
{
  "scriptFile": "index.js",
  "bindings": [
    {
      "name": "myQueueItem",
      "type": "queueTrigger",
      "direction": "in",
      "queueName": "event-queue",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

### 💻 EventNotifier/index.js
```javascript
import fetch from "node-fetch";

export async function main(context, myQueueItem) {
  context.log("=== EventNotifier START ===");
  context.log("Raw queue message:", myQueueItem);

  const webhookUrl = process.env.TEAMS_WEBHOOK_URL;
  if (!webhookUrl) {
    context.log.error("❌ Missing TEAMS_WEBHOOK_URL setting.");
    return;
  }

  let data;
  try {
    data = typeof myQueueItem === "string" ? JSON.parse(myQueueItem) : myQueueItem;
  } catch (err) {
    context.log.error("Invalid JSON:", err.message);
    return;
  }

  const service = data.service || "unknown";
  const level = data.level || "info";
  const message = data.message || "No message";

  const emoji = level === "error" ? "🚨" : "✅";
  const title = `${emoji} ${level.toUpperCase()} in ${service}`;
  const text = `${message}\n\nTimestamp: ${new Date().toISOString()}`;

  try {
    const payload = { text: `${title}\n${text}` };
    const response = await fetch(webhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (response.ok) {
      context.log(`📨 Teams notification sent successfully for ${service}`);
    } else {
      context.log.error(`Teams webhook failed with status: ${response.status}`);
    }
  } catch (error) {
    context.log.error("Failed to send message to Teams:", error);
  }
}
```

### 📦 Install Dependencies
```bash
# Install node-fetch for HTTP requests to Teams webhook
npm install node-fetch
```

---

## 🔐 4️⃣ Configure Application Settings

# Set the Teams webhook URL in Function App settings (replace with your actual webhook URL)
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings "TEAMS_WEBHOOK_URL=<YOUR_TEAMS_WEBHOOK_URL>"
```

---

## 🚀 5️⃣ Deploy Function to Azure

```bash
# Deploy the function app code to Azure
func azure functionapp publish $FUNC_APP
```

---

## 🧪 6️⃣ Test the Workflow

### ✅ Push a Success Message
```bash
# Send a success message to the queue to trigger notification
az storage message put \
  --queue-name $QUEUE \
  --account-name $STORAGE \
  --content '{"service":"payment-api","level":"info","message":"Transaction completed successfully"}'
```

### 🚨 Push an Error Message
```bash
# Send an error message to the queue to trigger notification
az storage message put \
  --queue-name $QUEUE \
  --account-name $STORAGE \
  --content '{"service":"user-api","level":"error","message":"Database connection timeout"}'
```

### 🔍 Expected Result
Each message triggers the Function, and your Teams channel displays:

```
✅ INFO in payment-api
Transaction completed successfully
Timestamp: 2025-11-04T09:00:00Z
```

```
🚨 ERROR in user-api
Database connection timeout
Timestamp: 2025-11-04T09:01:00Z
```

---

## 🧹 7️⃣ Clean Up Resources

```bash
# Delete the resource group and all resources created in this lab
az group delete \
  --name $RG \
  --yes \
  --no-wait
```

---

## ✅ Success Criteria

| Verification Step | Expected Result |
|--------------------|----------------|
| Function deployed successfully | ✅ |
| Queue messages processed automatically | ✅ |
| Teams notifications received | ✅ |
| Resource group deleted | ✅ |

---

### 🏁 Outcome
You have built an **event-driven notification system** using **Azure Functions (Node 20 LTS)**, **Azure Storage Queue**, and **Microsoft Teams Webhooks** — a lightweight, enterprise-friendly, and easily extensible approach to real-time alerting in Azure.
