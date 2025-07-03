# 🔄 Demo Guide: Web-Queue-Worker Architecture with Azure App Service, Storage Queue, and Azure Functions

## 🎯 Objective

Implement a decoupled Web-Queue-Worker pattern using:

- Azure App Service (Web Frontend)
- Azure Storage Queue (Message Queue)
- Azure Function (Background Worker)

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed and authenticated (`az login`)
- Python 3.11 and Azure Functions Core Tools

---

## 👣 Step-by-Step Instructions (Azure Portal + CLI)

### 1️⃣ Create the Resource Group and Storage Account

```bash
az group create --name webqueue-demo-rg --location australiaeast

az storage account create \
  --name webqueuestorage123 \
  --resource-group webqueue-demo-rg \
  --location australiaeast \
  --sku Standard_LRS
```

Get connection string:

```bash
az storage account show-connection-string \
  --name webqueuestorage123 \
  --resource-group webqueue-demo-rg --query connectionString --output tsv
```

Save the value as `STORAGE_CONN_STRING` for later use.

---

### 2️⃣ Create a Queue in Storage

```bash
az storage queue create \
  --account-name webqueuestorage123 \
  --name taskqueue
```

---

### 3️⃣ Deploy a Web App (Queue Producer)

This app adds messages to the queue.

**application.py**

```python
from flask import Flask, request
from azure.storage.queue import QueueClient
import os

app = Flask(__name__)
queue_client = QueueClient.from_connection_string(os.environ['STORAGE_CONN_STRING'], "taskqueue")

@app.route('/')
def index():
    return '<form method="POST"><input name="task"><input type="submit"></form>'

@app.route('/', methods=['POST'])
def enqueue():
    task = request.form['task']
    queue_client.send_message(task)
    return f"Task '{task}' added to queue."
```

**requirements.txt**

```
flask
azure-storage-queue
```

**startup.txt** (for App Service)

```
python application.py
```

Create App Service Plan + Web App:

```bash
az appservice plan create --name webqueue-plan --resource-group webqueue-demo-rg --sku B1 --is-linux

az webapp create \
  --resource-group webqueue-demo-rg \
  --plan webqueue-plan \
  --name webqueueapp123 \
  --runtime "PYTHON|3.11"
```

Configure settings:

```bash
az webapp config appsettings set \
  --resource-group webqueue-demo-rg \
  --name webqueueapp123 \
  --settings STORAGE_CONN_STRING="<connection_string>"
```

Deploy via Zip or Git.

---

### 4️⃣ Create Azure Function to Process Queue (Worker)

```bash
func init workerfunc --python
cd workerfunc
func new --name ProcessTask --template "Azure Queue Storage trigger"
```

Update `__init__.py`:

```python
def main(msg: func.QueueMessage) -> None:
    logging.info(f"Processing task: {msg.get_body().decode()}")
```

Update `function.json`:

```json
{
  "bindings": [
    {
      "name": "msg",
      "type": "queueTrigger",
      "direction": "in",
      "queueName": "taskqueue",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

Deploy to Azure:

```bash
func azure functionapp publish workerfunc123 --python
```

---

### 5️⃣ Test End-to-End

1. In your browser, open:\
   `https://<your-web-app-name>.azurewebsites.net/`
2. Submit a new task using the web form.
3. Message goes into `taskqueue`.
4. Azure Function automatically triggers and logs the task.

#### 🚦 Expected Output

- Your Azure Function logs should include:
  ```
  Processing task: <your-task>
  ```
- If you see this log, your pipeline works!

**Troubleshooting:**

- If messages are not processed, check:
  - The function is running and connected to the correct storage account/queue.
  - Your connection string is correct in both web app and function.
  - You can view logs via the Portal or:
    ```bash
    az functionapp log tail --name workerfunc123 --resource-group webqueue-demo-rg
    ```

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name webqueue-demo-rg --yes --no-wait
```

---

✅ **Demo complete – you have built a decoupled cloud application using the Web-Queue-Worker pattern with Azure services!**

