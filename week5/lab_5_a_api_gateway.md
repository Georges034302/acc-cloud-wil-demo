# 🧩 Lab 5-A: Deploy an API Gateway for the Joke API

## 🎯 Objective
Deploy and manage the **Joke API** through **Azure API Management (APIM)** to demonstrate the API Gateway pattern. The goal is to create multiple routes (endpoints), secure them, and test API traffic through a unified entry point.

---

## 🧭 Prerequisites
- An existing **Joke API** deployed to Azure App Service or running locally with a public endpoint.
- Azure CLI installed and logged in (`az login`).
- Azure subscription access.

---

## ⚙️ Steps (CLI + Portal)

### 1️⃣ Create Resource Group
```bash
az group create --name jokeapi-rg --location australiaeast
```

---

### 2️⃣ Create Azure API Management (APIM) Instance
```bash
az apim create   --name jokeapi-gateway   --resource-group jokeapi-rg   --publisher-email you@example.com   --publisher-name "Joke API Gateway"   --sku-name Consumption
```
> 🕐 This can take several minutes to provision.

---

### 3️⃣ Add an API to APIM (via Azure Portal)
1. Go to **Azure Portal → API Management Services → jokeapi-gateway**.
2. Select **APIs** → **+ Add API** → **HTTP**.
3. Choose **Blank API** and fill in:
   - **Display name:** `Joke API`
   - **Name:** `joke-api`
   - **Web service URL:** your existing endpoint, e.g., `https://<yourapp>.azurewebsites.net`
   - **API URL suffix:** `v1`
   - Click **Create**.

---

### 4️⃣ Define Routes (Operations)
Within the newly created `Joke API`, add multiple operations:

#### 🔹 `GET /jokes` – Return all jokes
- Display name: `Get All Jokes`
- URL: `GET /jokes`
- Backend: Forward to `/jokes` on your API endpoint.

#### 🔹 `GET /joke` – Return one random joke
- Display name: `Get Random Joke`
- URL: `GET /joke`
- Backend: Forward to `/joke` on your API endpoint.

#### 🔹 `POST /jokes/add` – Add a joke (optional if your API supports it)
- Display name: `Add Joke`
- URL: `POST /jokes/add`
- Backend: Forward to `/jokes/add`

---

### 5️⃣ Apply Basic Policies
In **Design** tab → **Inbound Processing** → **Add Policy** → choose from library:

#### 🔸 Example 1: Rate Limit Policy
```xml
<policies>
  <inbound>
    <rate-limit calls="5" renewal-period="60" />
    <base />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
</policies>
```

#### 🔸 Example 2: Add a Response Header
```xml
<policies>
  <inbound>
    <base />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <set-header name="X-API-Gateway" exists-action="override">
      <value>Azure API Management</value>
    </set-header>
    <base />
  </outbound>
</policies>
```

---

### 6️⃣ Test Your API in the Developer Portal
1. From APIM Overview → Click **Developer Portal**.
2. Browse to the `Joke API` → **Try It** → Test each route (`/jokes`, `/joke`).
3. Observe response headers (e.g., `X-API-Gateway`).

---

### 7️⃣ (Optional) Secure the API
Add a subscription key requirement:
1. In **Settings → Security**, ensure **Subscription required** is set to **Yes**.
2. Generate subscription keys from the **Subscriptions** tab.
3. Test requests by including the header:
   ```bash
   curl -H "Ocp-Apim-Subscription-Key: <your-key>"         https://<apim-name>.azure-api.net/v1/joke
   ```

---

### 🧼 Clean Up
```bash
az group delete --name jokeapi-rg --yes --no-wait
```

✅ **Lab Complete** – You have deployed an API Gateway for the Joke API using Azure API Management, defined multiple routes, added basic policies, and tested traffic through a unified API endpoint.
