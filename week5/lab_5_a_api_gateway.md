# 🧩 Lab 5-A: Deploy an API Gateway for the Joke API

<img width="930" height="400" alt="IMAGE" src="https://github.com/user-attachments/assets/73e3c100-4dff-4ae3-bfc7-ec2305637821" />

## 🎯 Objective
Deploy and manage the **Joke API** through **Azure API Management (APIM)** to demonstrate the API Gateway pattern. The goal is to create multiple routes (endpoints), secure them, and test API traffic through a unified entry point.

---

## 🧭 Prerequisites
- An existing **Joke API** deployed to Azure App Service or running locally with a public endpoint.
- Azure CLI installed and logged in (`az login`).
- Azure subscription access.

---

## 1️⃣ Create Resource Group
```bash
RG_NAME="jokeapi-rg"
LOCATION="australiaeast"

az group create \
  --name "$RG_NAME" \
  --location "$LOCATION"
```

---

## 2️⃣ Create Azure API Management (APIM) Instance
```bash
APIM_NAME="jokeapi-gateway$RANDOM"
PUBLISHER_EMAIL="georges.boughantous@gmail.com"
PUBLISHER_NAME="Joke API Gateway"
APIM_SKU="Consumption"

az apim create \
  --name "$APIM_NAME" \
  --resource-group "$RG_NAME" \
  --publisher-email "$PUBLISHER_EMAIL" \
  --publisher-name "$PUBLISHER_NAME" \
  --sku-name "$APIM_SKU"
```
> 🕐 This can take several minutes to provision.

---

## 3️⃣ Add an API to APIM (via Azure Portal)
1. Go to **Azure Portal → API Management Services → jokeapi-gateway**.
2. In the left menu, select **APIs**.
3. Click **+ Add API** → **HTTP**.
4. Choose **Blank API** and fill in:
  - **Display name:** `Joke API`
  - **Name:** `joke-api`
  - **Web service URL:** `http://$APIM_NAME.azure-api.net` (for mock/demo purposes)
  - **API URL suffix:** `v1`
  - Click **Create**
---

## 4️⃣ Add Operations (Routes)
Within the newly created `Joke API`, add the following operations:

| HTTP Method | Path       | Purpose              | Backend  |
| ----------- | ---------- | -------------------- | --------------- |
| GET         | /jokes     | List all jokes       | Mock  |
| GET         | /joke/{id} | Fetch a single joke  | Mock  |
| POST        | /jokes/add | Add a new joke       | Mock            |
---

### 🔹 Add Operation:  `GET /jokes`  – Return all jokes
- Click **+ Add Operation**.
- **Display name:** `Get All Jokes`
- **Name:** `get-all-jokes`
- **URL template:** `/jokes`
- **Method:** `GET`
- Click **Save**


#### 🔸 Add the GET /jokes mock response policy

> In **Design** tab → **Inbound Processing** → **Add Policy** → choose from library (Mock responses):

```xml
<policies>    
    <inbound>
        <base />
        <return-response>
            <set-status code="200" reason="OK" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>[
        {"id": 1, "joke": "Why did the chicken cross the road? To get to the other side!"},
        {"id": 2, "joke": "I told my computer I needed a break, and it said 'No problem, I'll go to sleep.'"}
      ]</set-body>
        </return-response>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

#### ✅ Test the GET /jokes api operation
1. From APIM Overview → Click **APIs**.
2. Browse to the `Joke API` → SELECT **GET jokes** operation → CLICK Test tab 
3. CLICK **Send**

or use the GET URL in the browser: 
```bash
"$BROWSER" "https://$APIM_NAME.azure-api.net/v1/jokes"
```

---

### 🔹 Add the `GET /joke/{id}` – Return joke by ID
- Click **+ Add Operation**.
- **Display name:** `Get Joke By ID`
- **Name:** `get-joke-by-id`
- **URL template:** `/joke/{id}`
- **Method:** `GET`
- Add a parameter:
  - **Name:** `id`
  - **Type:** `string`
  - **Location:** `Path`
  - **Required:** `Yes`
- Click **Save**

#### 🔸 Add the GET /joke/{id} mock response policy

> In **Design** tab → **Inbound Processing** → **Add Policy** → choose from library (Mock responses):

```xml
<policies>
    <inbound>
        <!-- Short-circuit BEFORE any backend call -->
        <return-response>
            <set-status code="200" reason="OK" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body><![CDATA[
        {
          "id": "5",
          "joke": "Why did the chicken cross the road? To get to the other side!"
        }
      ]]></set-body>
        </return-response>
        <base />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

#### ✅ Test the GET /joke/{id} api operation
1. From APIM Overview → Click **APIs**.
2. Browse to the `Joke API` → SELECT **GET joke By ID** operation → CLICK Test tab 
3. Provide value = 5 (for id in the Template parameters)
5. CLICK **Send**

or use the GET URL in the browser: 
```bash
"$BROWSER" "https://$APIM_NAME.azure-api.net/v1/joke/5"
```

---

### 🔹 Add the `POST /jokes/add` – Add a new joke (Mocked)
- Click **+ Add Operation**.
- **Display name:** `Add Joke`
- **Name:** `add-joke`
- **URL template:** `/jokes/add`
- **Method:** `POST`
- Leave **Web service URL** blank (you’re mocking the behavior).
- Click **Save**

#### 🔸 Add the POST /joke/add mock response policy

> In **Design** tab → **Inbound Processing** → **Add Policy** → choose from library (Mock responses):

```xml
<policies>
  <inbound>
    <!-- Short-circuit and mock a JSON success response -->
    <return-response>
      <set-status code="201" reason="Created" />
      <set-header name="Content-Type" exists-action="override">
        <value>application/json</value>
      </set-header>
      <set-body><![CDATA[
        {
          "message": "Joke added successfully!",
          "status": "success",
          "example": {
            "id": "101",
            "joke": "Why did the developer go broke? Because he used up all his cache."
          }
        }
      ]]></set-body>
    </return-response>
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

### ✅ Test the POST /joke/add api operation
1. From APIM Overview → Click **APIs**.
2. Browse to the `Joke API` → SELECT **Add Joke** operation → CLICK Test tab 
3. Add the following JSON to the request body
  ```json
    {
      "id": 101,
      "joke": "Why did the developer go broke? Because he used up all his cache."
    }
  ```
5. CLICK **Send** 
6. Expected Output:
  ```json
    {
      "message": "Joke added successfully!",
      "status": "success",
      "example": {
        "id": "101",
        "joke": "Why did the developer go broke? Because he used up all his cache."
      }
    }
  ```

---

## 5️⃣ Clean Up
```bash
az group delete \
  --name "$RG_NAME" \
  --yes \
  --no-wait
```

✅ **Lab Complete** – You have deployed an API Gateway for the Joke API using Azure API Management, defined multiple routes, added basic policies, and tested traffic through a unified API endpoint.
