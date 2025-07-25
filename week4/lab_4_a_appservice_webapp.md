# 🌐 Demo Guide: Deploying a Web App Using Azure App Service

## 🎯 Objective
Deploy a simple web application to Azure App Service using an App Service Plan and understand PaaS hosting capabilities.

---

## 🧭 Prerequisites

- Azure Portal access ([https://portal.azure.com](https://portal.azure.com))
- Azure CLI installed and authenticated (`az login`)
- Python 3.11+ installed (for Flask app)
- Git installed
- **[Recommended] Register the App Service provider (first-time users):**

  **Portal:**
  1. In the Azure Portal, search for **Subscriptions** and select your subscription.
  2. Under **Settings**, click **Resource providers**.
  3. Search for `Microsoft.Web`.
  4. Click **Register** if it is not already registered.

  **CLI:**
  Register with Miscroft.Web: *Azure Resource Provider that manages all web-based (PaaS) resources in Azure*
  ```bash
  az provider register --namespace Microsoft.Web
  ```
  Confirm the Registration:
  ```bash
  az provider show --namespace Microsoft.Web --query registrationState
  ```

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create a Resource Group and App Service Plan

🔸 **Portal:**
1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **App Service Plans** → Click **+ Create**
3. Fill in:
   - **Resource Group**: `appservice-demo-rg`
   - **Name**: `demo-plan`
   - **Region**: `Australia East`
   - **Pricing tier**: Click **Change size** → Select **B1 (Basic)** or **F1 (Free)**
4. Click **Review + create** → **Create**

🔸 **CLI:**
```bash
az group create --name appservice-demo-rg --location australiaeast

az appservice plan create \
  --name demo-plan \
  --resource-group appservice-demo-rg \
  --sku B1 \
  --is-linux
```
#### 🎯 Expected Output

**Portal:**

- After creating the Resource Group and App Service Plan:
  - The new App Service Plan (`demo-plan`) appears under **App Service Plans**.
  - Both resources show **Region** as `Australia East`.
  - No errors or warnings are shown during creation.

**CLI:**

- For the App Service Plan creation command:
    ```bash
    az appservice plan create \
      --name demo-plan \
      --resource-group appservice-demo-rg \
      --sku B1 \
      --is-linux
    ```
  You’ll see a JSON output with key fields:
    ```json
    {
      "name": "demo-plan",
      "resourceGroup": "appservice-demo-rg",
      "location": "australiaeast",
      "sku": {
        "name": "B1",
        ...
      },
      "status": "Ready",
      ...
    }
    ```

- **Look for `"provisioningState": "Succeeded"` or `"status": "Ready"`** to confirm the resources were created successfully.

---

### 2️⃣ Create the Web App

🔸 **Portal:**
1. Go to **App Services** → Click **+ Create**
2. Fill in:
   - **App name**: `demo-webapp-<unique>` (e.g. use random name: APP_NAME="demo-webapp$RANDOM")
   - **Publish**: Code
   - **Runtime stack**: Choose Python 3.11
   - **Region**: `Australia East`
   - **App Service Plan**: Select `demo-plan`
3. Click **Review + create** → **Create**

🔸 **CLI:**
```bash
APP_NAME=webapp$RANDOM

az webapp create \
  --resource-group appservice-demo-rg \
  --plan demo-plan \
  --name "$APP_NAME" \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```
⏳ Note the Git URL from CLI output for step 3.

---
#### 📦 What Is This Step Doing?

You are provisioning a new web application on **Azure App Service**.

- This step reserves a unique app name and configures the environment (Linux + Python runtime), allowing you to deploy and run your Python code in the cloud.
- The `--deployment-local-git` flag enables local Git deployment for your app, giving you a special Git URL to deploy code directly from your Codespace.

---

#### 🎯 Expected Output

**Portal:**

- After creation, your new app (`demo-webapp-<unique>`) appears under **App Services** in the Azure Portal.
- The app’s **Status** will show as `Running`.
- The app’s **URL** (e.g., `https://$APP_NAME.azurewebsites.net`) will be displayed at the top of the overview page.

**CLI:**

- The Azure CLI will return a JSON output containing these important fields:

    ```json
    "defaultHostName": "$APP_NAME.azurewebsites.net",
    "deploymentLocalGitUrl": "https://<username>@$APP_NAME.scm.azurewebsites.net/$APP_NAME.git",
    ...
    ```
#### ⚠️ If Your Git Deployment URL Shows `None@` (e.g., `https://None@$APP_NAME.scm.azurewebsites.net/demo-$APP_NAME.git`)

This means Azure CLI was unable to detect your deployment username.  
You need to set up App Service deployment credentials before you can deploy code.

---

**How to Set Your App Service Deployment Credentials:**

1. **In the Azure Portal:**
   - Go to **App Services** and select your web app.
   - In the left menu from **Deployment**, click **Deployment Center**.
   - Under **Local Git/FTPS Credentials** tab, Set a **username** and **password** 
   - (these are used only for deployments, not your main Azure login).

2. **After setting your deployment credentials:**
  - Use the Git URL provided by Azure for your web app (the URL may show `None@`, but that's okay).
  - When you deploy your code with:
     ```bash
     git push azure main:master
     ```
     you will be prompted for a username and password (The newly set git username/password)).

  - **Deployment URL:**  
    ```bash
    https://<yourusername>@$APP_NAME.scm.azurewebsites.net/$APP_NAME.git
    ```

#### 💡 **Copy the `deploymentLocalGitUrl` value.** You will use this URL for the next deployment step.

---
### 3️⃣ Deploy Code to Azure Web App

We will use a simple Python Flask app.

🗂️ **App structure:**
Create folder: flaskapp with the correct file names
```
flaskapp/
├── application.py
├── requirements.txt
```
CLI option:
```bash
mkdir flaskapp
cd flaskapp
touch application.py requirements.txt
```



📄 `application.py`
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Welcome to Azure App Service!</h1>"
```

📄 `requirements.txt`
```
flask
```

🔸 **Set Up Your Python Environment and Install Dependencies:**
```bash
cd flaskapp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```
**Set Git Remote Deployment URL: (One Time Only Setup)**
```bash
cd studentservice
git init
git remote add azure https://<your-username>@"$APP_NAMEP".scm.azurewebsites.net/"$APP_NAME".git
```

**Deploy The service: (Reuse and deploy after every update to the service)**
```bash
git add .
git commit -m "Initial commit - app"
git 

✅ After push, browse to `https://$APP_NAME.azurewebsites.net`

🔸 **Alternative Deployment (Zip):**
1. Zip your `flaskapp` folder.
2. Go to **Web App → Deployment Center** → Select **Zip Deploy**
3. Upload the zip file

---

### 4️⃣ Test the Application
- Open the app URL: `https://$APP_NAME.azurewebsites.net`
- You should see: **Welcome to Azure App Service!**

---

## 🧼 Clean Up (Optional)
```bash
az group delete --name appservice-demo-rg --yes --no-wait
```

---

✅ **Demo complete – you have deployed a Python web app using Azure App Service and Git!**

