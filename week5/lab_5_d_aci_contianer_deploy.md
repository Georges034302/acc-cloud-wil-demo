# ⚙️ Lab 5-D: Deploy the Container to Azure Container Instances (ACI)

## 🎯 Objective
Deploy the **Joke API** container image from **Azure Container Registry (ACR)** to **Azure Container Instances (ACI)**.  
This lab demonstrates how to run a serverless container without managing infrastructure.

---

## 🧭 Prerequisites
- Completed **Lab 5-C** (image pushed to ACR)
- Azure CLI installed and logged in (`az login`)
- Resource group and ACR created (e.g., `localbuild-rg`, `localbuildacr123`)
- Docker image available at `localbuildacr123.azurecr.io/webapp:v1`

---

## ⚙️ Step-by-Step Instructions (CLI + Portal)

### 1️⃣ Verify ACR Image Exists
```bash
az acr repository list --name localbuildacr123 --output table
```
You should see your image `webapp:v1` in the list.

---

### 2️⃣ Create Azure Container Instance (ACI)
Deploy the image from ACR into a lightweight container instance.

```bash
az container create   --resource-group localbuild-rg   --name jokeapi-aci   --image localbuildacr123.azurecr.io/webapp:v1   --cpu 1   --memory 1   --registry-login-server localbuildacr123.azurecr.io   --registry-username $(az acr credential show --name localbuildacr123 --query username -o tsv)   --registry-password $(az acr credential show --name localbuildacr123 --query passwords[0].value -o tsv)   --ports 80   --dns-name-label jokeapi$(openssl rand -hex 2)   --location australiaeast
```
✅ This will create a publicly accessible endpoint like:  
`https://jokeapiabcd.australiaeast.azurecontainer.io`

---

### 3️⃣ Verify Deployment
Check the container status:

```bash
az container show   --name jokeapi-aci   --resource-group localbuild-rg   --query "{Status:instanceView.state, IP:ipAddress.fqdn}"   --output table
```

Once `Status` = **Running**, open the FQDN in your browser.

---

### 4️⃣ Test the API Routes
Use your browser or `curl`:

```bash
curl https://<your-dns>.australiaeast.azurecontainer.io/joke
```
or
```bash
curl https://<your-dns>.australiaeast.azurecontainer.io/jokes
```

✅ You should see JSON responses from your containerized Joke API.

---

### 5️⃣ View Logs
Inspect logs to verify successful container startup and requests:

```bash
az container logs   --name jokeapi-aci   --resource-group localbuild-rg
```

---

### 6️⃣ (Optional) Portal Validation
1. Go to **Azure Portal → Container Instances → jokeapi-aci**  
2. Check the **Containers → Logs** section for live output  
3. Under **Networking**, confirm public FQDN and exposed ports (80)

---

### 🧼 Clean Up Resources
```bash
az container delete --name jokeapi-aci --resource-group localbuild-rg --yes
```
(Optional) remove the entire resource group:
```bash
az group delete --name localbuild-rg --yes --no-wait
```

---

✅ **Lab Complete** – You successfully deployed a containerized web API to **Azure Container Instances**, tested endpoints, viewed logs, and learned how to manage lightweight, serverless containers on Azure.
