# 🐋 Lab 5-C: Local Container Build, Push to ACR, and Deploy to App Service

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/70747466-64d9-4bcd-8c33-19f46a5924bf" />

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
WEBAPP_DIR="webapp"
APP_NAME="webapp$RANDOM$RANDOM"
RG_NAME="webapp-rg"
LOCATION="australiaeast"
ACR_NAME="webappacr$RANDOM"
PLAN_NAME="webapp-plan$RANDOM"
SKU="B1"

mkdir "$WEBAPP_DIR"
cd "$WEBAPP_DIR"
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
az group create --name "$RG_NAME" --location "$LOCATION"
```

#### 🔸 Create ACR 

```bash
az acr create \
  --resource-group "$RG_NAME" \
  --name "$ACR_NAME" \
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
az acr login --name "$ACR_NAME"
```
#### 🔸 Build the Docker image locally

```bash
docker build -t webapp:v1 .
```

#### 🔸 Tag the Docker image

```bash
docker tag webapp:v1 "$ACR_NAME.azurecr.io/webapp:v1"
```

#### 🔸 Push the Docker image to ACR

```bash
docker push "$ACR_NAME.azurecr.io/webapp:v1"
```

#### ✅ The image is now hosted in ACR

---

### 4️⃣ Deploy Container to Azure App Service

#### 🔸 Create App Service plan (app plan name must be unique)

```bash
az appservice plan create \
  --name "$PLAN_NAME" \
  --resource-group "$RG_NAME" \
  --is-linux \
  --sku "$SKU"
```

#### 🔸 Create App Service app (app name must be unique)

```bash
az webapp create \
  --resource-group "$RG_NAME" \
  --plan "$PLAN_NAME" \
  --name "$APP_NAME" \
  --deployment-container-image-name "$ACR_NAME.azurecr.io/webapp:v1"
```

#### 🔸 Enable Managed Identity on the App Service

```bash
az webapp identity assign \
  --name "$APP_NAME" \
  --resource-group "$RG_NAME"
```

#### 🔸 Get the Principal ID of the App Service

```bash
PRINCIPAL_ID=$(az webapp identity show \
  --name "$APP_NAME" \
  --resource-group "$RG_NAME" \
  --query principalId \
  --output tsv)
```

#### 🔸 Assign AcrPull role to the App's Managed Identity for ACR access

```bash
az role assignment create \
  --assignee "$PRINCIPAL_ID" \
  --scope $(az acr show --name "$ACR_NAME" --query id --output tsv) \
  --role AcrPull
```

#### 🔸 Deploys a Docker container from ACR to an Azure Web App

```bash
az webapp config container set \
  --name "$APP_NAME" \
  --resource-group "$RG_NAME" \
  --docker-custom-image-name "$ACR_NAME.azurecr.io/webapp:v1" \
  --docker-registry-server-url "https://$ACR_NAME.azurecr.io"
```

---

### 5️⃣ Test the Deployment

Open your browser and navigate to:

```bash
# Click on the app link to open
echo "$APP_NAME"
echo "https://$APP_NAME.azurewebsites.net"

# Open in the current web-browser
"$BROWSER" "https://$APP_NAME.azurewebsites.net"
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
az group delete --name "$RG_NAME" --yes --no-wait
```

✅ **Demo complete – You built a Docker image locally, pushed to ACR, and deployed to Azure App Service via CLI, Portal, and ARM.**

