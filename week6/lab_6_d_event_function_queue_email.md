
# 📩 Lab 6-D: Event-Driven Notification System Using Azure Queue Trigger and ACS Email 
---

## 🎯 Objectives

In this lab, you will:
- Build a **serverless Azure Function (Python)** triggered by a **Storage Queue**.
- Process both **error** and **success** messages from the same queue.
- Send email notifications via **Azure Communication Services (ACS)**.
- Demonstrate a simple, event-driven alerting workflow with no third-party dependencies.

---

## 🧭 Prerequisites

- ✅ Active **Azure Subscription**
- ✅ **Azure CLI** installed (v2.57+ recommended)
- ✅ **Python 3.11+** and **Azure Functions Core Tools v4** installed
  ```bash
    # Check if Azure Functions Core Tools v4 is installed
    func --version || echo "Azure Functions Core Tools not found. Installing..."
    # Install Azure Functions Core Tools v4 (requires Python)
    npm install -g azure-functions-core-tools@4 --unsafe-perm true
    # Verify installation
    func --version
  ```
- ✅ Permission to create Azure resources (Resource Group, Storage, Function App, ACS)
- ✅ Valid **email address** to receive alerts

---

## ⚙️ 1️⃣ CLI Setup: Resource Group, Storage, Function App, and Queue

```bash
# Set up environment variables
export LOCATION="australiaeast"
export RG="rg-lab6d-notify"
export STORAGE="stnotify$RANDOM"
export FUNC_APP="func-notify$RANDOM"
export QUEUE="event-queue"
export ACS_NAME="acs-lab6d-notify"

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

# Create Azure Function App (Python 3.11)
az functionapp create \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name $FUNC_APP \
  --storage-account $STORAGE

# Create storage queue for events
az storage queue create \
  --name $QUEUE \
  --account-name $STORAGE
```

---


## 💻 2️⃣ Initialize Function App Project (Python)

### Initialize the function app (Python v4 model)
```bash
func init lab6d-notify-func --worker-runtime python
```

### Create a Queue Trigger Function
```bash
cd lab6d-notify-func
func new --name EventNotifier --template "Azure Queue Storage trigger" --language python
# This creates EventNotifier/function.json and __init__.py
```

### Add Required Python Packages
Create a `requirements.txt` in the project root:
```
azure-functions
azure-communication-email
```
Then install locally for testing:
```bash
pip install -r requirements.txt
```

---


## 3️⃣ Function Code: Process Queue Messages and Send Email (Python)

### 📁 Project Structure
```
lab6d-notify-func/
├── requirements.txt
├── EventNotifier/
│   ├── __init__.py
│   └── function.json
```

### 🧠 __init__.py
```python
import os
import json
from azure.communication.email import EmailClient
import logging

def main(myQueueItem: str):
    logging.info(f"Received message: {myQueueItem}")

    try:
        data = json.loads(myQueueItem)
    except Exception as e:
        logging.error(f"Invalid JSON: {e}")
        return

    subject = f"✅ SUCCESS in {data['service']}" if data.get('level') != 'error' \
              else f"🚨 ERROR in {data['service']}"
    body = f"{data['message']}\n\nTimestamp: {__import__('datetime').datetime.utcnow()}"

    client = EmailClient.from_connection_string(os.environ["ACS_CONNECTION_STRING"])
    try:
        message = {
            "senderAddress": os.environ["EMAIL_SENDER"],
            "recipients": {"to": [{"address": os.environ["EMAIL_RECIPIENT"]}]},
            "content": {"subject": subject, "plainText": body}
        }
        client.send(message)
        logging.info(f"Email sent successfully for {data['level']} event.")
    except Exception as e:
        logging.error(f"Email sending failed: {e}")
```


### ⚙️ function.json
```json
{
  "scriptFile": "__init__.py",
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

---


## ✉️ 4️⃣ Configure Azure Communication Services (ACS)

### 📦 – Create ACS Resource
```bash
az communication create \
  --name $ACS_NAME \
  --location global \
  --data-location australia \
  --resource-group $RG
```

### 🔗 – Retrieve Connection String
```bash
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
echo DoNotReply@${ACS_NAME}.azurecomm.net
```

---


## 🔐 5️⃣ Configure Function App Settings
```bash
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings \
    "ACS_CONNECTION_STRING=$ACS_CONNECTION_STRING" \
    "EMAIL_SENDER=DoNotReply@${ACS_NAME}.azurecomm.net" \
    "EMAIL_RECIPIENT=<your_email_address>"
```

---


## 🚀 6️⃣ Deploy Function to Azure
```bash
func azure functionapp publish $FUNC_APP
```

---


## 🧪 7️⃣ Test the Workflow

### Push a success message
```bash
az storage message put \
  --queue-name $QUEUE \
  --account-name $STORAGE \
  --content '{"service":"payment-api","level":"info","message":"Transaction completed successfully"}'
```

### Push an error message
```bash
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


## 🧹 8️⃣ Clean Up
```bash
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
| Success email received | ✅ |
| Error email received | ✅ |
| Resource group deleted | ✅ |

---

### 🏁 Outcome
You’ve built an **event-driven serverless email alert system** using only Azure-native services:  
**Storage Queue + Function + ACS Email** (Python).  
This is a clean, reliable demonstration of **event-driven automation** in Azure.
