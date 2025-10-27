# 🔐 Lab 4-D: Secure App Settings in App Service with Azure Key Vault

## 🎯 Objective

Securely inject secrets into **Azure App Service** using **Azure Key Vault**, **Managed Identity**, and **App Settings**—without hardcoding sensitive values.

---

## 🧭 Prerequisites

- Azure CLI installed and logged in
- Azure subscription access
- Python installed (locally, for app packaging)
- Basic understanding of App Service and environment variables

---

## 👣 Step-by-Step Instructions (CLI + Portal)

---

### 1️⃣ Create Resource Group and Key Vault

#### 🔸 Create Resource Group

```bash
az group create \
  --name secureapp-rg \
  --location australiaeast
```

#### 🔸 Create Azure Key Vault

```bash
az keyvault create \
  --name securekvdemo123 \
  --resource-group secureapp-rg \
  --location australiaeast \
  --sku standard
```

#### 🔸 Add a sample secret

```bash
az keyvault secret set \
  --vault-name securekvdemo123 \
  --name "DbConnectionString" \
  --value "Server=sql.local;Database=appdb;Uid=admin;Pwd=secret123;"
```

---

### 2️⃣ Create App Service and Enable Managed Identity

#### 🔸 Register the Provider to enable the creation and management of web-related resources (App Service) 

```bash
az provider register --namespace Microsoft.Web

az provider show --namespace Microsoft.Web --query "registrationState"
```

#### 🔸 Create App Service Plan

```bash
az appservice plan create \
  --name secureapp-plan \
  --resource-group secureapp-rg \
  --is-linux \
  --sku B1
```

#### 🔸 Create App Service

```bash
APP_NAME=secureapp$RANDOM

az webapp create \
  --resource-group secureapp-rg \
  --plan secureapp-plan \
  --name $APP_NAME \
  --runtime "PYTHON:3.11"
```

#### 🔸 Enable System-Assigned Managed Identity

```bash
az webapp identity assign \
  --name $APP_NAME \
  --resource-group secureapp-rg
```

---

### 3️⃣ Grant Access to Key Vault

#### 🔸 Get App Service Principal ID

```bash
PRINCIPAL_ID=$(az webapp identity show \
  --name $APP_NAME \
  --resource-group secureapp-rg \
  --query principalId \
  --output tsv)
```

#### 🔸 Set Access Policy on Key Vault

```bash
az keyvault set-policy \
  --name securekvdemo123 \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list
```

---

### 4️⃣ Configure App Settings with Key Vault Reference

#### 🔸 Add App Setting Linked to Key Vault Secret

```bash
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group secureapp-rg \
  --settings "DbConnectionString=@Microsoft.KeyVault(SecretUri=https://securekvdemo123.vault.azure.net/secrets/DbConnectionString/)"
```

---

### 5️⃣ Build and Deploy Sample Flask App

#### 📁 Create App Files

```bash
mkdir secureflask
cd secureflask
touch app.py requirements.txt
```

#### ✅ Expected Outcome:

```
webapp/
├── app.py
├── requirements.txt
```

##### 🔹 `app.py`

```python
from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def home():
    conn = os.environ.get("DbConnectionString", "Not Found")
    return f"<h2>Database Connection:</h2><p>{conn}</p>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

##### 🔹 `requirements.txt`

```
flask
```

---

#### 📦 Zip the App

```bash
zip -r secureflask.zip .
```

---

#### 🚀 Deploy to Azure App Service

```bash
az webapp deploy \
  --resource-group secureapp-rg \
  --name $APP_NAME \
  --src-path secureflask.zip \
  --type zip
```

---

### 6️⃣ Test Your App

Navigate to:

```
https://<your-app-name>.azurewebsites.net
```

✅ You should see:

```
Database Connection:
Server=sql.local;Database=appdb;Uid=admin;Pwd=secret123;
```

---

### 7️⃣ Portal Setup (Optional)

- Navigate to your App Service → **Configuration**
- Add new app setting:
  - Name: `DbConnectionString`
  - Value: `@Microsoft.KeyVault(SecretUri=https://securekvdemo123.vault.azure.net/secrets/DbConnectionString/)`
- Save and restart

---

### 🧼 Clean Up

```bash
az group delete \
  --name secureapp-rg \
  --yes \
  --no-wait
```

✅ **Demo Complete – You integrated Azure App Service with Key Vault using Managed Identity!**
