# 📩 Lab 6-D: Event-Driven Notification System Using Azure Queue Trigger and ACS Email

---

## 🎯 Objectives

In this lab, you will:
- Build a **serverless Azure Function (Node.js)** triggered by a **Storage Queue**.
- Process both **error** and **success** messages from the same queue.
- Send email notifications via **Azure Communication Services (ACS)**.
- Demonstrate a simple, event-driven alerting workflow with no third-party dependencies.

---

## 🧭 Prerequisites

- ✅ Active **Azure Subscription**
- ✅ **Azure CLI** installed (v2.57+ recommended)
- ✅ **Node.js 18+** and **Azure Functions Core Tools v4** installed
- Azure CLI and Azure Functions Core Tools v4 installed
  ```bash
    # Check if Azure Functions Core Tools v4 is installed
    func --version || echo "Azure Functions Core Tools not found. Installing..."
    # Install Azure Functions Core Tools v4 (requires Node.js)
    npm install -g azure-functions-core-tools@4 --unsafe-perm true
    # Verify installation
    func --version
  ```
- ✅ Permission to create Azure resources (Resource Group, Storage, Function App, ACS)
- ✅ Valid **email address** to receive alerts

---

## ⚙️ 1️⃣ CLI Setup: Resource Group, Storage, Function App, and Queue

```bash
# ===========================
# Set up environment variables
# ===========================

LOCATION="australiaeast"
RG="rg-lab6d-notify"
STORAGE="stnotify$RANDOM"
FUNC_APP="func-notify$RANDOM"
QUEUE="event-queue"
ACS_NAME="acs-lab6d-notify"

# ===========================
# Create Azure resources
# ===========================

# Create resource group
az group create \
  --name $RG \
  --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE \
  --location $LOCATION \
  --resource-group $RG \
  --sku Standard_LRS

# Create Azure Function App (Node.js 18)
az functionapp create \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --name $FUNC_APP \
  --storage-account $STORAGE

# Create storage queue for events
az storage queue create \
  --name $QUEUE \
  --account-name $STORAGE
```

---

## 💻 2️⃣ Function Code: Process Queue Messages and Send Email

### 📁 Project Structure
```
lab6d-notify-func/
└── EventNotifier/
    ├── function.json
    └── index.js
```

### 🧠 index.js
```javascript
const { EmailClient } = require("@azure/communication-email");

module.exports = async function (context, myQueueItem) {
  context.log("Received message:", myQueueItem);

  // Parse incoming message (JSON string)
  let data;
  try {
    data = JSON.parse(myQueueItem);
  } catch (err) {
    context.log("Invalid JSON format in queue message.");
    return;
  }

  // Initialize ACS email client
  const emailClient = new EmailClient(process.env.ACS_CONNECTION_STRING);

  // Build subject and body based on event type
  const isError = data.level && data.level.toLowerCase() === "error";
  const subject = isError
    ? `🚨 ERROR in ${data.service}`
    : `✅ SUCCESS in ${data.service}`;
  const body = `${data.message}\n\nTimestamp: ${new Date().toISOString()}`;

  try {
    await emailClient.send({
      senderAddress: process.env.EMAIL_SENDER,
      content: { subject, plainText: body },
      recipients: { to: [{ address: process.env.EMAIL_RECIPIENT }] },
    });

    context.log(`Email sent successfully for ${data.level} event.`);
  } catch (err) {
    context.log(`Email sending failed: ${err.message}`);
  }
};
```

### ⚙️ function.json
```json
{
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

### 📦 Install Required Package
```bash
# Change to the function directory
cd lab6d-notify-func/EventNotifier
# Initialize a new Node.js project
npm init -y
# Install ACS email client package
npm install \
  @azure/communication-email
```

---

## ✉️ 3️⃣ Configure Azure Communication Services (ACS)

### 📦 – Create ACS Resource
```bash
# Create Azure Communication Services resource for email
az communication create \
  --name $ACS_NAME \
  --data-location global \
  --resource-group $RG
```

### 🔗 – Retrieve Connection String
```bash
# Retrieve the ACS connection string for email client
ACS_CONNECTION_STRING=$(az communication list-key \
  --name $ACS_NAME \
  --resource-group $RG \
  --query "primaryConnectionString" \
  --output tsv)
echo "ACS_CONNECTION_STRING=$ACS_CONNECTION_STRING"
```

### 🆔 – Identify Sender Domain
The default sender domain is usually:
```bash
DoNotReply@${ACS_NAME}.azurecomm.net
```

---

## 🔐 4️⃣ Configure Function App Settings
```bash
# Set environment variables for ACS and email addresses in the Function App
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings \
    "ACS_CONNECTION_STRING=$ACS_CONNECTION_STRING" \
    "EMAIL_SENDER=DoNotReply@${ACS_NAME}.azurecomm.net" \
    "EMAIL_RECIPIENT=<your_email_address>"
```

---

## 🚀 5️⃣ Deploy Function to Azure
```bash
# Deploy the function app to Azure
func azure functionapp publish $FUNC_APP
```

---

## 🧪 6️⃣ Test the Workflow

### Push a success message
```bash
# Push a success message to the queue
az storage message put \
  --queue-name $QUEUE \
  --account-name $STORAGE \
  --content '{"service":"payment-api","level":"info","message":"Transaction completed successfully"}'
```

### Push an error message
```bash
# Push an error message to the queue
az storage message put \
  --queue-name $QUEUE \
  --account-name $STORAGE \
  --content '{"service":"user-api","level":"error","message":"Database connection timeout"}'
```

### Expected Results
- The Function triggers automatically for each queue message.
- Two emails should be received:
  - Subject: “✅ SUCCESS in payment-api”
  - Subject: “🚨 ERROR in user-api”

---

## 🧹 7️⃣ Clean Up
```bash
# Delete the resource group and all resources
az group delete \
  --name $RG \
  --yes \
  --no-wait
```

---

## ✅ 8️⃣ Success Criteria

| Verification Step | Expected Result |
|--------------------|----------------|
| Function deployed successfully | ✅ |
| Queue messages processed automatically | ✅ |
| Success email received | ✅ |
| Error email received | ✅ |
| Resource group deleted | ✅ |

---

### 🏁 Outcome
You’ve built an **event-driven serverless email alert system** using only Azure-native services:  
**Storage Queue + Function + ACS Email**.  
This is a clean, reliable demonstration of **event-driven automation** in Azure.
