# ☸️ Lab 5-E: Deploy the Container to Azure Container Apps (ACA)

## 🎯 Objective
Deploy the **Joke API** container image from **Azure Container Registry (ACR)** to **Azure Container Apps (ACA)**.  
This lab demonstrates how to host containerized applications on a **fully managed, scalable, event-driven platform** built on Azure Kubernetes Service (AKS).

---

## 🧭 Prerequisites
- Completed **Lab 5-C** (image pushed to ACR)
- Azure CLI installed and logged in (`az login`)
- Azure subscription access
- The Azure CLI **Container Apps** extension installed:
  ```bash
  az extension add --name containerapp --upgrade
  ```

---

## ⚙️ Step-by-Step Instructions (CLI + Portal)

### 1️⃣ Verify ACR Image
Confirm your image exists in ACR:
```bash
az acr repository list --name localbuildacr123 --output table
```

---

### 2️⃣ Enable Required Providers
Ensure the following Azure providers are registered:
```bash
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
```

---

### 3️⃣ Create a Log Analytics Workspace
```bash
az monitor log-analytics workspace create   --resource-group localbuild-rg   --workspace-name jokeapi-logs   --location australiaeast
```
Retrieve the workspace ID:
```bash
LOG_ID=$(az monitor log-analytics workspace show   --resource-group localbuild-rg   --workspace-name jokeapi-logs   --query customerId -o tsv)
```

---

### 4️⃣ Create a Container Apps Environment
```bash
az containerapp env create   --name jokeapi-env   --resource-group localbuild-rg   --logs-workspace-id $LOG_ID   --location australiaeast
```

---

### 5️⃣ Deploy the Container App
```bash
az containerapp create   --name jokeapi-app   --resource-group localbuild-rg   --environment jokeapi-env   --image localbuildacr123.azurecr.io/webapp:v1   --target-port 80   --ingress external   --registry-server localbuildacr123.azurecr.io   --registry-username $(az acr credential show --name localbuildacr123 --query username -o tsv)   --registry-password $(az acr credential show --name localbuildacr123 --query passwords[0].value -o tsv)
```
✅ This command deploys your container image to ACA and exposes a public endpoint.

---

### 6️⃣ Verify Deployment
Check status and get the public URL:
```bash
az containerapp show   --name jokeapi-app   --resource-group localbuild-rg   --query properties.configuration.ingress.fqdn   -o tsv
```
Visit the URL in your browser (e.g., `https://jokeapi-app.australiaeast.azurecontainerapps.io`).

---

### 7️⃣ Test the API Routes
Use `curl` or browser to test routes:
```bash
curl https://<your-app>.australiaeast.azurecontainerapps.io/joke
```
or
```bash
curl https://<your-app>.australiaeast.azurecontainerapps.io/jokes
```

✅ You should see JSON responses from your containerized Joke API.

---

### 8️⃣ (Optional) Configure Autoscaling
Add autoscaling based on concurrent requests:
```bash
az containerapp revision set-mode   --name jokeapi-app   --resource-group localbuild-rg   --mode multiple

az containerapp scale rule create   --name jokeapi-scale   --container-app jokeapi-app   --resource-group localbuild-rg   --custom-rule-type http   --metadata concurrentRequests=5   --min-replicas 1   --max-replicas 5
```
✅ ACA will now automatically scale out/in based on load.

---

### 🧼 Clean Up Resources
```bash
az group delete --name localbuild-rg --yes --no-wait
```

---

✅ **Lab Complete** – You successfully deployed a containerized web API to **Azure Container Apps**, validated routes, and configured autoscaling on a modern, serverless Kubernetes-backed platform.
