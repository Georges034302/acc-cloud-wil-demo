# 🐳 Demo 1 Guide: Deploy a Containerized App from ACR to Azure App Service

## 🎯 Objective

Deploy an existing container image from Azure Container Registry (ACR) to Azure App Service for Containers using CLI, Portal, and ARM.

---

## 🧭 Prerequisites

- Docker installed (only for building elsewhere)
- Azure CLI installed and logged in
- Azure subscription and access to Azure Portal
- Existing container image in ACR (e.g. `containerdemoacr123.azurecr.io/webapp:v1`)

---

## 👣 Step-by-Step Instructions (CLI + Portal + ARM)

### 1️⃣ Create Resource Group and App Service Plan

🔸 **CLI:**

```bash
az group create --name container-demo-rg --location australiaeast

az appservice plan create \
  --name container-plan \
  --resource-group container-demo-rg \
  --is-linux \
  --sku B1
```

🔸 **Portal:**

1. Go to [portal.azure.com](https://portal.azure.com)
2. Search **App Service Plans** → **+ Add**
3. Resource Group: `container-demo-rg`
4. Name: `container-plan`
5. OS: Linux, Region: `Australia East`, SKU: B1
6. Click **Review + create** → **Create**

---

### 2️⃣ Deploy Containerized App from ACR to App Service

🔸 **CLI:**

```bash
az webapp create \
  --resource-group container-demo-rg \
  --plan container-plan \
  --name containerwebapp123 \
  --deployment-container-image-name containerdemoacr123.azurecr.io/webapp:v1

az webapp config container set \
  --name containerwebapp123 \
  --resource-group container-demo-rg \
  --docker-custom-image-name containerdemoacr123.azurecr.io/webapp:v1 \
  --docker-registry-server-url https://containerdemoacr123.azurecr.io \
  --docker-registry-server-user $(az acr credential show --name containerdemoacr123 --query username -o tsv) \
  --docker-registry-server-password $(az acr credential show --name containerdemoacr123 --query passwords[0].value -o tsv)
```

🔸 **Portal:**

1. Go to **App Services** → Click **+ Create**
2. App name: `containerwebapp123`, Region: `Australia East`
3. Publish: Docker Container → OS: Linux
4. Plan: `container-plan`
5. Docker:
   - Source: Azure Container Registry
   - Registry: `containerdemoacr123`
   - Image: `webapp:v1`
6. Click **Review + create** → **Create**

🔸 **ARM Template:** Save as `webapp-arm.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2022-03-01",
      "name": "container-plan",
      "location": "australiaeast",
      "sku": { "name": "B1", "tier": "Basic" },
      "properties": { "reserved": true }
    },
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2022-03-01",
      "name": "containerwebapp123",
      "location": "australiaeast",
      "kind": "app,linux,container",
      "properties": {
        "serverFarmId": "container-plan",
        "siteConfig": {
          "linuxFxVersion": "DOCKER|containerdemoacr123.azurecr.io/webapp:v1",
          "appSettings": [
            { "name": "DOCKER_REGISTRY_SERVER_URL", "value": "https://containerdemoacr123.azurecr.io" },
            { "name": "DOCKER_REGISTRY_SERVER_USERNAME", "value": "<acr-username>" },
            { "name": "DOCKER_REGISTRY_SERVER_PASSWORD", "value": "<acr-password>" }
          ]
        }
      },
      "dependsOn": [
        "Microsoft.Web/serverfarms/container-plan"
      ]
    }
  ]
}
```

Deploy via CLI:

```bash
az deployment group create \
  --resource-group container-demo-rg \
  --template-file webapp-arm.json
```

---

### 3️⃣ Test the Deployment

Open:

```
https://containerwebapp123.azurewebsites.net
```

✅ App should be live.

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name container-demo-rg --yes --no-wait
```

✅ **Demo complete – students deployed a containerized app from ACR to App Service using CLI, Portal, and ARM!**

