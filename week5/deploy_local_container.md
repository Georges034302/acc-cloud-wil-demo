# 🐋 Demo 4 Guide: Local Container Build, Push to ACR, and Deploy to App Service

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

📁 Project Structure:

```
webapp/
├── app.py
├── requirements.txt
├── Dockerfile
```

📄 Sample `Dockerfile`:

```Dockerfile
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

🔸 **CLI:**

```bash
cd webapp

docker build -t webapp:v1 .
```

---

### 2️⃣ Create Resource Group and ACR

🔸 **CLI:**

```bash
az group create --name localbuild-rg --location australiaeast

az acr create \
  --resource-group localbuild-rg \
  --name localbuildacr123 \
  --sku Basic \
  --admin-enabled true
```

🔸 **Portal:**

1. Go to **Container Registries** → **+ Create**
2. Resource Group: `localbuild-rg`
3. Registry Name: `localbuildacr123`
4. Location: `Australia East`
5. Enable Admin access
6. Review + Create

🔸 **ARM Template Deployment:** Save ACR ARM template as `acr-arm.json` and run:

```bash
az deployment group create \
  --resource-group localbuild-rg \
  --template-file acr-arm.json
```

---

### 3️⃣ Push Image to ACR

🔸 **CLI:**

```bash
az acr login --name localbuildacr123

docker tag webapp:v1 localbuildacr123.azurecr.io/webapp:v1

docker push localbuildacr123.azurecr.io/webapp:v1
```

✅ The image is now hosted in ACR

---

### 4️⃣ Deploy Container to Azure App Service

🔸 **CLI:**

```bash
az appservice plan create \
  --name localbuild-plan \
  --resource-group localbuild-rg \
  --is-linux \
  --sku B1

az webapp create \
  --resource-group localbuild-rg \
  --plan localbuild-plan \
  --name localwebapp123 \
  --deployment-container-image-name localbuildacr123.azurecr.io/webapp:v1

az webapp config container set \
  --name localwebapp123 \
  --resource-group localbuild-rg \
  --docker-custom-image-name localbuildacr123.azurecr.io/webapp:v1 \
  --docker-registry-server-url https://localbuildacr123.azurecr.io \
  --docker-registry-server-user $(az acr credential show --name localbuildacr123 --query username -o tsv) \
  --docker-registry-server-password $(az acr credential show --name localbuildacr123 --query passwords[0].value -o tsv)
```

🔸 **Portal:**

1. Go to **App Services** → **+ Create**
2. App Name: `localwebapp123` → Region: `Australia East`
3. Publish: Docker Container → OS: Linux
4. Plan: `localbuild-plan`
5. Docker:
   - Source: Azure Container Registry
   - Registry: `localbuildacr123`
   - Image: `webapp:v1`
6. Review + Create

🔸 **ARM Template:** Save as `webapp-arm.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2022-03-01",
      "name": "localbuild-plan",
      "location": "australiaeast",
      "sku": { "name": "B1", "tier": "Basic" },
      "properties": { "reserved": true }
    },
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2022-03-01",
      "name": "localwebapp123",
      "location": "australiaeast",
      "kind": "app,linux,container",
      "properties": {
        "serverFarmId": "localbuild-plan",
        "siteConfig": {
          "linuxFxVersion": "DOCKER|localbuildacr123.azurecr.io/webapp:v1",
          "appSettings": [
            { "name": "DOCKER_REGISTRY_SERVER_URL", "value": "https://localbuildacr123.azurecr.io" },
            { "name": "DOCKER_REGISTRY_SERVER_USERNAME", "value": "<acr-username>" },
            { "name": "DOCKER_REGISTRY_SERVER_PASSWORD", "value": "<acr-password>" }
          ]
        }
      },
      "dependsOn": ["Microsoft.Web/serverfarms/localbuild-plan"]
    }
  ]
}
```

Deploy it:

```bash
az deployment group create \
  --resource-group localbuild-rg \
  --template-file webapp-arm.json
```

---

### 5️⃣ Test the Deployment

Open your browser:

```
https://localwebapp123.azurewebsites.net
```

✅ You should see your running app.

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name localbuild-rg --yes --no-wait
```

✅ **Demo complete – students built a Docker image locally, pushed to ACR, and deployed to Azure App Service via CLI, Portal, and ARM.**

