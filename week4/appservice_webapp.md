# 🌐 Demo Guide: Deploying a Web App Using Azure App Service

## 🎯 Objective
Deploy a simple web application to Azure App Service using an App Service Plan and understand PaaS hosting capabilities.

---

## 🧭 Prerequisites
- Azure Portal access
- Azure CLI installed
- Python installed (if using Flask app)

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

---

### 2️⃣ Create the Web App

🔸 **Portal:**
1. Go to **App Services** → Click **+ Create**
2. Fill in:
   - **App name**: `demo-webapp-<unique>`
   - **Publish**: Code
   - **Runtime stack**: Choose Python 3.11
   - **Region**: `Australia East`
   - **App Service Plan**: Select `demo-plan`
3. Click **Review + create** → **Create**

🔸 **CLI:**
```bash
az webapp create \
  --resource-group appservice-demo-rg \
  --plan demo-plan \
  --name demo-webapp123 \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```
⏳ Note the Git URL from CLI output for step 3.

---

### 3️⃣ Deploy Code to Azure Web App

We will use a simple Python Flask app.

🗂️ **App structure:**
```
flaskapp/
├── application.py
├── requirements.txt
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

🔸 **Steps to Deploy via Git CLI:**
```bash
cd flaskapp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Initialize and push to Azure
git init
git remote add azure <GIT_URL_FROM_STEP_2>
git add .
git commit -m "Deploy simple Flask app"
git push azure master
```
✅ After push, browse to `https://demo-webapp123.azurewebsites.net`

🔸 **Alternative Deployment (Zip):**
1. Zip your `flaskapp` folder.
2. Go to **Web App → Deployment Center** → Select **Zip Deploy**
3. Upload the zip file

---

### 4️⃣ Test the Application
- Open the app URL: `https://<app-name>.azurewebsites.net`
- You should see: **Welcome to Azure App Service!**

---

## 🧼 Clean Up (Optional)
```bash
az group delete --name appservice-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have deployed a Python web app using Azure App Service and Git!**

