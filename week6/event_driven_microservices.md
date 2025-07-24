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
5. Role: **Storage Queue Data Contributor**
6. Assign access to: **User, group, or service principal**
7. Select your account (signed-in user)
8. Click **Save**

Run this command:

```bash
az role assignment create \
  --assignee $(az ad signed-in-user show --query id -o tsv) \
  --role Contributor \
  --scope $(az storage account show --name $EVENT_STORAGE --resource-group event-demo-rg --query id -o tsv)
```

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
  --storage-account $EVENT_STORAGE \
  --os-type Linux
```

### 5️⃣ Create Function Locally

```bash
func init QueueProcessorProj --python
cd QueueProcessorProj
func init . --worker-runtime python

# Initialize the Function App with Python worker
func init . --worker-runtime python --language python

# Begin interactive creation of a new function
func new --list

# When prompted, choose the "Queue trigger" template by entering:
# Choose option: 12

# Then respond to the next prompts:
# Function Name: ProcessOrder
# Queue Name: orders
# Storage Connection String: AzureWebJobsStorage
```

Update `function_app.py`:

```python
import logging
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="ProcessOrder")
@app.queue_trigger(arg_name="msg", queue_name="orders", connection="AzureWebJobsStorage")
def process_order(msg: func.QueueMessage):
    logging.warning("🚨 Triggered: ProcessOrder function")

    try:
        body_raw = msg.get_body()
        body = body_raw.decode("utf-8")
        logging.info(f"✅ Processing order: {body}")
    except UnicodeDecodeError:
        logging.error(f"❌ Could not decode message body: {body_raw!r}", exc_info=True)
    except Exception as e:
        logging.error(f"❌ Unexpected error: {str(e)}", exc_info=True)
        raise
```

Update host.json

```json
{
  "version": "2.0",
  "logging": {
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "excludedTypes": "Request"
      }
    }
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  },
  "extensions": {
    "queues": {
      "messageEncoding": "Base64"
    }
  }
}

```

Install dependencies:

```bash
# Activate Python Env
python3.11 -m venv /workspaces/acc-cloud-wil-demo/week6/QueueProcessorProj/.venv
source /workspaces/acc-cloud-wil-demo/week6/QueueProcessorProj/.venv/bin/activate

# Install Azure Functions SDK
pip install azure-functions

# Freeze installed packages to requirements.txt
pip freeze > requirements.txt

# Remove any invalid torch versions (e.g., 2.7.0+cpu)
sed -i '/torch==2\.7\.0\+cpu/d' requirements.txt
sed -i '/torch==2\.7\.0/d' requirements.txt

# Add a valid torch version explicitly
echo "torch==2.1.2" >> requirements.txt

# Reinstall from clean requirements.txt
pip install -r requirements.txt
```

Before Deployment ensure to install the correct interpreter version

```bash
# For Example, installing Python 3.11 on Ubuntu
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3.11-dev

# Create a Python 3.11 virtual environment
python3.11 -m venv .venv
source .venv/bin/activate
python --version  # should now print 3.11.x


# Re-install dependencies
pip install -r requirements.txt
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

Verify Deployed Functions:
```bash
az functionapp function list \
  --name queueprocessorfunc \
  --resource-group event-demo-rg
```

Enable App Logging (if not already):

```bash
az webapp log config \
  --name queueprocessorfunc \
  --resource-group event-demo-rg \
  --application-logging filesystem
```

View App Insights:

```bash
SUB_ID=$(az account show --query id --output tsv)

az monitor app-insights query \
  --app "/subscriptions/$SUB_ID/resourceGroups/event-demo-rg/providers/microsoft.insights/components/queueprocessorfunc" \
  --analytics-query "exceptions | order by timestamp desc | limit 5"
```

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name event-demo-rg --yes --no-wait
```

---

## 🟢 **Conclusion**

- Your instructions are correct and ready for students.
- Consider adding the above minor clarifications for even smoother student experience.
- All CLI commands are up-to-date and should work as expected.

---

✅ **Demo complete – students have implemented async communication using Azure Queue and Functions via CLI!**



