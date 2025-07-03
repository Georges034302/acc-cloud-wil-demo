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
- Register with Miscroft.Web

  #### ⚙️ Install Azure Functions Core Tools (One Time Setup Only)

  Run the following commands to install Azure Azure Functions Core Tools:

  ```bash
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  sudo apt-get update
  sudo apt-get install azure-functions-core-tools-4
  ```
  Verify installation:

  ```bash
  az --version
  func --version
  ```

  #### 📝 Register with Miscroft.Web (One Time Setup Only)
    ```bash
    az provider register --namespace Microsoft.Web
    ```
    Confirm the Registration:
    ```bash
    az provider show --namespace Microsoft.Web --query registrationState
    ```
---

## 👣 Step-by-Step Instructions (Azure Portal + CLI)

### 1️⃣ Setup Resource Group and Storage Queue

```bash
az group create --name webqueue-demo-rg --location australiaeast
```
#### 🗃️ Create a Queue in Storage

```bash
STORAGE_QUEUE=webqueuestorage$RANDOM 

az storage account create \
  --name $STORAGE_QUEUE \
  --resource-group webqueue-demo-rg \
  --location australiaeast \
  --sku Standard_LRS
```

#### 🔗 Get connection string:

```bash
az storage account show-connection-string \
  --name $STORAGE_QUEUE \
  --resource-group webqueue-demo-rg --query connectionString --output tsv
```

Save the value as `STORAGE_CONN_STRING` for later use.

---

#### 📋 Create a Queue in Storage

```bash
az storage queue create \
  --account-name $STORAGE_QUEUE \
  --name taskqueue
```

#### 🛡️ Assign Storage Queue Data Contributor Role via Azure Portal

1. Go to the **Azure Portal**: [https://portal.azure.com](https://portal.azure.com)

2. Navigate to your **Storage Account** (e.g., `webqueuestorage123`).

3. In the left menu, click **Access control (IAM)**.

4. Click on the **+ Add > Add role assignment** button.

5. In the **Role** dropdown, select **Storage Queue Data Contributor**.

6. In the **Assign access to** dropdown, select the identity type:
   - **Managed identity** (if your app uses Managed Identity)
   - Or **User, group, or service principal** (for service principals or users)

7. In the **Select** box, find and select your **App Service** or **Azure Function** principal.

8. Click **Save** to assign the role.

---

### 2️⃣ Deploy a Web App (Queue Producer)

This simple Flask app allows users to add messages to an Azure Storage Queue.

#### 📁 Create the Folder Structure and Files

```bash
mkdir -p webqueueapp
cd webqueueapp
touch application.py requirements.txt startup.txt
```

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

#### 🛠️ Create App Service Plan

```bash
az appservice plan create \
  --name webqueue-plan \
  --resource-group webqueue-demo-rg \
  --sku B1 \
  --is-linux
```

#### 🚀 Create App Service Web App:

```bash
WEB_APP=webqueueapp$RANDOM

az webapp create \
  --resource-group webqueue-demo-rg \
  --plan webqueue-plan \
  --name $WEB_APP \
  --runtime "PYTHON|3.11"
```

#### ⚙️ Configure settings:

```bash
az webapp config appsettings set \
  --resource-group webqueue-demo-rg \
  --name $WEB_APP \
  --settings STORAGE_CONN_STRING="$STORAGE_CONN_STRING"
```

#### 🔄 Deploy via Git:

**Set Git Remote Deployment URL: (One Time Only Setup)**
```bash
cd webqueueapp
git init
git remote add azure https://<your-username>@"$WEB_APP".scm.azurewebsites.net/"$WEB_APP".git
```

**Deploy The queue app: (Reuse and deploy after every update to the application)**
```bash
git add .
git commit -m "Web app deployment"
git push azure main:master
```
Use your Azure App Service deployment credentials when prompted.  
After you push, Azure automatically builds and deploys your app, then restarts it.

Once deployment completes, verify your app by visiting:  `https://<your-app-name>.azurewebsites.net`

---

### 3️⃣ Create Azure Function to Process Queue (Worker)

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

#### 🚀 Deploy to Azure:

```bash
func azure functionapp publish workerfunc123 --python
```

---

### 4️⃣ Test End-to-End

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

