# 🐋 Demo 2 Guide: Local Container Build, Push to ACR, and Deploy to App Service

## 🎯 Objective

Build a Docker container **locally**, push it to **Azure Container Registry (ACR)**, and deploy it to **Azure App Service** using **CLI**, **Portal**, and **ARM templates**.

---

## 🧭 Prerequisites

- Docker installed and running
- Azure CLI installed and logged in
- Azure subscription access
- Sample app with `Dockerfile`

---

## 👣 Step-by-Step Instructions (CLI + Portal + ARM)

### 1️⃣ Build Local Docker Image

#### 📁 Create Project Structure:

```bash
mkdir webapp
cd webapp
touch app.py requirements.txt Dockerfile
```
#### ✅ Expected Outcome:

```
webapp/
├── app.py
├── requirements.txt
├── Dockerfile
```

#### 📄 Sample `app.py`:

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>Hello from Azure App Service Container!</h1>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

#### 📄 Sample `requirements.txt`:

```
flask
```

#### 📄 Sample `Dockerfile`:

```Dockerfile
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 80
CMD ["python", "app.py"]
```

#### 🔸 Build Docler 

```bash
cd webapp

docker build -t webapp:v1 .
```

---

### 2️⃣ Create Resource Group and ACR

#### 🔸 Register the Provider to enable the creation and management of web-related resources (App Service) 

```bash
az provider register --namespace Microsoft.Web

az provider show --namespace Microsoft.Web --query "registrationState"
```

#### 🔸 Create Resource Group using 

```bash
az group create --name localbuild-rg --location australiaeast
```

#### 🔸 Create ACR 

```bash
az acr create \
  --resource-group localbuild-rg \
  --name localbuildacr123 \
  --sku Basic \
  --admin-enabled true
```

#### 🔸 Create Resource Group using **Portal:** (Optional) 

1. Go to **Container Registries** → **+ Create**
2. Resource Group: `localbuild-rg`
3. Registry Name: `localbuildacr123`
4. Location: `Australia East`
5. Enable Admin access
6. Review + Create


---

### 3️⃣ Push Image to ACR

#### 🔸 Login to ACR 

```bash
az acr login --name localbuildacr123
```
#### 🔸 Build the Docker image locally

```bash
docker build -t webapp:v1 .
```

#### 🔸 Tag the Docker image

```bash
docker tag webapp:v1 localbuildacr123.azurecr.io/webapp:v1
```

#### 🔸 Push the Docker image to ACR

```bash
docker push localbuildacr123.azurecr.io/webapp:v1
```

#### ✅ The image is now hosted in ACR

---

### 4️⃣ Deploy Container to Azure App Service

#### 🔸 Create App Service plan

```bash
az appservice plan create \
  --name localbuild-plan \
  --resource-group localbuild-rg \
  --is-linux \
  --sku B1
```

#### 🔸 Create App Service app (app name must be unique)

```bash
APP_NAME=localwebapp$RANDOM

az webapp create \
  --resource-group localbuild-rg \
  --plan localbuild-plan \
  --name $APP_NAME \
  --deployment-container-image-name $APP_NAME.azurecr.io/webapp:v1
```

#### 🔸 Enable Managed Identity on the App Service

```bash
az webapp identity assign \
  --name $APP_NAME \
  --resource-group localbuild-rg
```

#### 🔸 Get the Principal ID of the App Service

```bash
PRINCIPAL_ID=$(az webapp identity show \
  --name $APP_NAME \
  --resource-group localbuild-rg \
  --query principalId \
  --output tsv)
```

#### 🔸 Assign AcrPull role to the App's Managed Identity for ACR access

```bash
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --scope $(az acr show --name localbuildacr123 --query id --output tsv) \
  --role AcrPull
```

#### 🔸 Deploys a Docker container from ACR to an Azure Web App

```bash
az webapp config container set \
  --name $APP_NAME \
  --resource-group localbuild-rg \
  --docker-custom-image-name localbuildacr123.azurecr.io/webapp:v1 \
  --docker-registry-server-url https://localbuildacr123.azurecr.io
```

---
### 5️⃣ Test the Deployment

Open your browser and navigate to:

```
echo $APP_NAME
https://$APP_NAME.azurewebsites.net
```

✅ **You should see your running app.**

---

### 6️⃣ Deploy Docker Container to Azure Web App via **Portal:** (Optional)

#### 1. Create Resource Group (Optional)
- Go to **Azure Portal** → Search for **Resource groups**
- Click **➕ Create**
- Set:
  - **Subscription**: Your active subscription
  - **Resource group name**: `localbuild-rg`
  - **Region**: `Australia East` or your preferred location
- Click **Review + Create** → **Create**

#### 2. Create App Service Plan (Linux)
- Go to **App Service Plans** → **➕ Create**
- Set:
  - **Resource Group**: `localbuild-rg`
  - **Name**: `localbuild-plan`
  - **Operating System**: **Linux**
  - **Region**: `Australia East`
  - **Pricing Tier**: **B1 Basic** (or higher)
- Click **Review + Create** → **Create**

#### 🔸 3. Create Web App for Container
- Go to **App Services** → **➕ Create**
- Set:
  - **Resource Group**: `localbuild-rg`
  - **Name**: e.g., `localwebapp123` (must be globally unique)
  - **Publish**: **Docker Container**
  - **Operating System**: **Linux**
  - **Region**: `Australia East`
  - **App Service Plan**: Choose `localbuild-plan`
- Under **Docker** tab:
  - **Options**: **Single Container**
  - **Image Source**: **Azure Container Registry**
  - **Registry**: Select `localbuildacr123`
  - **Image**: `webapp`
  - **Tag**: `v1`
- Click **Review + Create** → **Create**

#### 🔸 4. Enable System-Assigned Managed Identity
- Navigate to your new Web App → **Identity**
- Under **System assigned**, set **Status** to **On**
- Click **Save**

#### 🔸 5. Assign `AcrPull` Role to Web App Identity
- Go to **Container Registry** → `localbuildacr123`
- Click **Access Control (IAM)** → **+ Add > Add role assignment**
- Role: **AcrPull**
- Assign access to: **Managed identity**
- Select:
  - Subscription: same as Web App
  - Resource: your Web App (`localwebapp123`)
- Click **Save**

---

### 7️⃣ Create App Service app using **ARM Template** Save as `webapp-arm.json` (Optional)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "appName": {
      "type": "string"
    },
    "acrName": {
      "type": "string"
    },
    "acrLoginServer": {
      "type": "string"
    },
    "resourceGroupName": {
      "type": "string"
    },
    "location": {
      "type": "string",
      "defaultValue": "australiaeast"
    },
    "planName": {
      "type": "string",
      "defaultValue": "localbuild-plan"
    },
    "sku": {
      "type": "string",
      "defaultValue": "B1"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2022-03-01",
      "name": "[parameters('planName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "[parameters('sku')]",
        "tier": "Basic"
      },
      "kind": "linux",
      "properties": {
        "reserved": true
      }
    },
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2022-03-01",
      "name": "[parameters('appName')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
      ],
      "properties": {
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]",
        "siteConfig": {
          "linuxFxVersion": "[concat('DOCKER|', parameters('acrLoginServer'), '/webapp:v1')]"
        }
      }
    },
    {
      "type": "Microsoft.Authorization/roleAssignments",
      "apiVersion": "2022-04-01",
      "name": "[guid(resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName')), 'acrpull')]",
      "dependsOn": [
        "[resourceId('Microsoft.Web/sites', parameters('appName'))]"
      ],
      "properties": {
        "roleDefinitionId": "[subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')]",
        "principalId": "[reference(resourceId('Microsoft.Web/sites', parameters('appName')), '2022-03-01', 'Full').identity.principalId]",
        "principalType": "ServicePrincipal",
        "scope": "[resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))]"
      }
    }
  ]
}
```

#### 🔸 Deploy the ARM Template:

```bash
az deployment group create \
  --resource-group localbuild-rg \
  --template-file webapp-arm.json
```

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name localbuild-rg --yes --no-wait
```

✅ **Demo complete – You built a Docker image locally, pushed to ACR, and deployed to Azure App Service via CLI, Portal, and ARM.**

