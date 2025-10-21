# 🧪 Lab 4-A – Deploy a Web App Using Azure App Service (CLI)

<img width="931" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/e0ccd6cc-ff10-4b0f-8197-a1f42eb5a678" />

## 🎯 Objective
Deploy a simple Python Flask web application using Azure App Service and understand how the App Service Plan defines compute resources for PaaS hosting.

---

## 🧭 Prerequisites
- Azure CLI (2.60+)
- Logged in to Azure (`az login`)
- Azure subscription selected (`az account set --subscription <id>`)
- Python 3.11 + Flask installed (optional, for local testing)

---

## ⚙️ Step 1 – Define Variables
```bash
# Define resource names and region
RG_NAME="appservice-rg"
PLAN_NAME="plan-demo-$RANDOM"
APP_NAME="webapp-$RANDOM"
LOCATION="australiaeast"
# App Service plan SKU (e.g. B1, S1). Increase for scale.
SKU="B1"
# App Service runtime for Linux (format: RUNTIME|VERSION)
RUNTIME="PYTHON|3.11"
```
---

## 🏗️ Step 2 – Register App Service Provider
```bash
# Register the Microsoft.Web provider (required for App Service resources)
az provider register \
    --namespace Microsoft.Web

# Verify registration status
az provider show \
    --namespace Microsoft.Web \
    --query registrationState
```

---

## 🧱 Step 3 – Create a Resource Group
```bash
# Create a new resource group
az group create \
    --name $RG_NAME \
    --location $LOCATION
```

---

## ☁️ Step 4 – Create an App Service Plan
```bash
# Create an App Service Plan (Linux, Basic tier)
az appservice plan create \
    --name $PLAN_NAME \
    --resource-group $RG_NAME \
    --sku $SKU \
    --is-linux
```

---

## 🌐 Step 5 – Create the Web App
```bash
# Create a new web app using the defined plan and Python runtime (Linux)
az webapp create \
    --name $APP_NAME \
    --resource-group $RG_NAME \
    --plan $PLAN_NAME \
    --runtime "$RUNTIME"

# Configure local Git deployment and print the Git URL (you'll use this as the remote)
az webapp deployment source config-local-git \
    --name $APP_NAME \
    --resource-group $RG_NAME \
    --query url -o tsv

# The previous command prints a URL like:
# https://<username>@$APP_NAME.scm.azurewebsites.net/$APP_NAME.git
# The app URL will be https://$APP_NAME.azurewebsites.net
```

---

## 🧩 Step 6 – Deploy Application Code (Azure Git Deployment)

### 6.1 – Create a Local Project Folder
```bash
# Create and move into a new folder for your app
mkdir flaskapp
cd flaskapp
```

### 6.2 – Create the Application File

**Create a Python file named app.py  then paste the following code:**
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "<h1>Welcome to Azure App Service!</h1>"

# The block below is useful for local testing only. App Service will attempt to start
# a WSGI server when it detects this layout; the platform's detection will choose
# an appropriate server during deployment.
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

### 6.3 – Create the Requirements File
```bash
# Create a requirements.txt file listing dependencies
echo "flask" > requirements.txt
```

### 6.4 – Commit the app to your Git Repository
```bash
# Commit your app
git add .
git commit -m "Initial commit – Flask web app"
```
### 6.5 – Configure deployment user, ensure remote, clear cached creds, and push (exact)
Run these exact commands in your `flaskapp` folder. They do not use conditional branches and will set the subscription deployment user, replace the `azure` remote, clear cached credentials for the SCM host, then push.

```bash
# 0) (optional) confirm variables (prints app + rg)
echo "$APP_NAME" "$RG_NAME"

# 1) read password from stdin (hidden)
read -s -p "Deployment password for Georges034302: " DEPLOY_PW
echo

# 2) set the subscription-scoped deployment user to that password
az webapp deployment user set --user-name Georges034302 --password "$DEPLOY_PW"

# 3) immediately clear the password variable from shell memory
DEPLOY_PW=''
unset DEPLOY_PW

# 4) remove any cached git/http credentials for the SCM host
printf "protocol=https\nhost=webapp-14592.scm.azurewebsites.net\n" | git credential reject

# 5) restore the non-authenticated local-git URL as remote 'azure'
GIT_URL=$(az webapp deployment source config-local-git --name $APP_NAME --resource-group $RG_NAME --query url -o tsv)
git remote set-url azure "$GIT_URL"

# 6) push the current branch to Azure (exact step 6.6)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push azure "$BRANCH":master
```

### 6.6 – Verify Deployment
```bash
# Display the app URL
echo "https://$APP_NAME.azurewebsites.net"
```
Open the URL in your browser — you should see:
**Welcome to Azure App Service!**

---

## 🔍 Step 7 – Test the Web App
```bash
# Confirm app is running
az webapp show \
    --name $APP_NAME \
    --resource-group $RG_NAME \
    --query state
```

---

## 🧼 Step 8 – Clean Up Resources (Optional)
```bash
# Delete all created resources
az group delete \
    --name $RG_NAME \
    --yes \
    --no-wait
```

---

## ✅ Lab Summary

| Step | Description | Command |
|------|--------------|----------|
| 1 | Define variables | `RG_NAME`, `PLAN_NAME`, `APP_NAME`, etc. |
| 2 | Register provider | `az provider register` |
| 3 | Create resource group | `az group create` |
| 4 | Create App Service Plan | `az appservice plan create` |
| 5 | Create Web App | `az webapp create` |
| 6 | Deploy code | `git push azure main:master` |
| 7 | Test deployment | `az webapp show` |
| 8 | Clean up | `az group delete` |

---

**✅ Result:** You have successfully deployed a Python Flask web app to Azure App Service using Azure CLI.
