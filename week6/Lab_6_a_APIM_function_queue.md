# Lab 6-A: Expose an HTTP-Triggered Node.js Azure Function via API Management with Queue Output Binding

<img width="1467" height="912" alt="6-A" src="https://github.com/user-attachments/assets/9c3e9637-3b63-48b8-bd9b-ec69aefa0a58" />

## Objective
Create a **Node.js HTTP-triggered Azure Function** that writes messages into **Azure Storage Queue**, then expose it through **Azure API Management (APIM)** **without** a subscription key. Region is fixed to **`australiaeast`**. All resources are created from scratch in an isolated resource group.


## Prerequisites
- Active Azure subscription (Contributor or higher)
- Azure CLI ≥ 2.61 (`az version`)
- Optional: `curl` or Postman for external testing

---

## 1) Set Variables and Create Resource Group (CLI)

> Replace `gbg123` and email with your values.

```bash
# >>> EDIT THESE VALUES <<<
UNIQ="gbg$RANDOM"                 # globally unique suffix (letters/numbers)
EMAIL="you@example.com"

# Fixed values for the lab
LOCATION="australiaeast"
RG="rg-func-apim-$UNIQ"
STO="stfunc$UNIQ"
FUNCAPP="func-httpq-$UNIQ"
APIM="apim-$UNIQ"
APIM_SKU="Consumption"

```

```bash
# Create Resource Group (CLI)
az group create \
  --name "$RG" \
  --location "$LOCATION"

```

---

## 2) Create the Function App (Azure Portal)

1. **Create a resource → Function App**
   - Plan: **Consumption (Serverless)**
2. **Basics**
   - Resource Group: `rg-func-apim-<UNIQ>`
   - Name: `func-httpq-<UNIQ>`
   - OS: **Windows**
   - Runtime: **Node.js 20 LTS**
   - Region: **Australia East**
3. **Storage**
   - Storage account: **Create new** → `stfunc<UNIQ>` (or choose suggested storage name)
4. **Networking**
   - (Default settings)
5. **Monitoring**
   - Application Insights: **Enable** (create new)
6. **Deployment**
   - (Default settings)
8. **Authentication**
   - (Default settings)
9. **Tags**
   - (Default settings)
10. **Review + Create → Create**

> Wait until deployment completes, then proceed to step 3.

---

## 3) Assign Managed Identity and Storage Queue Permissions

### 🔹 Enable Managed Identity for Function App

1. Go to your Function App (`func-httpq-gbg123`) in the Azure Portal.
2. In the left menu, select **Identity**.
3. Under **System assigned**, set **Status** to **On**.
4. Click **Save**.

### 🔹 Assign Storage Queue Data Contributor Role

1. Go to your Storage Account (`stfuncgbg123`) in the Azure Portal.
2. In the left menu, select **Access Control (IAM)**.
3. Click **+ Add → Add role assignment**.
4. Set **Role** to: `Storage Queue Data Contributor`
5. Set **Assign access to**: `Managed identity`
6. In **Select members**, search for and select your Function App (`func-httpq-gbg123`).
7. Click **Save**.

### 🔹 Assign Role to Your User Account

1. Go to your Storage Account (`stfuncgbg123`) in the Azure Portal.
2. In the left menu, select **Access Control (IAM)**.
3. Click **+ Add → Add role assignment**.
4. Set **Role** to: `Storage Queue Data Contributor`
5. Set **Assign access to**: `User, group, or service principal`
6. In **Select members**, search for and select your user account (`georges.boughantous@gmail.com`).
7. Click **Save**.

---

## 4) Add an HTTP Trigger Function (Portal)

1. Function App → Select `func-httpq-<UNIQ>` 
2. Choose → **Create In Azure Portal**
2. Template: **HTTP trigger**
3. Function name: `sendMessage`
4. Authorization level: **Function**
5. **Create**

---

## 5) Add Queue Output Binding (Portal)

1. Function (`func-httpq-<UNIQ>` ) Select → **Integration → + Add output**
2. Binding type: **Azure Queue Storage**
3. Storage account connection: `AzureWebJobsStorage`
4. Parameter name: `outputQueueItem`
5. Queue name: `messages-out`
6. **Add**

---

## 6) Edit Function Code (Portal)

1. Function (`func-httpq-<UNIQ>` ) Select → **Code + Test → `index.js`**, replace content with:

```javascript
module.exports = async function (context, req) {
  const message = req.query.message || (req.body && req.body.message);

  if (!message) {
    context.res = { status: 400, body: "Missing 'message' parameter." };
    return;
  }

  context.log(`Enqueuing message: ${message}`);
  context.bindings.outputQueueItem = message;

  context.res = {
    status: 200,
    headers: { "Content-Type": "application/json" },
    body: { result: "Message enqueued", value: message }
  };
};
```

2. Click **Save**, then **Test/Run**:
  - In the request Input paste the JSON in the request body:
  ```json
    { 
      "message": "hello" 
    }
  ```
  - Expect Output:
    - HTTP response code: **200 OK**
    - HTTP response content
  ```json
    {
      "result": "Message enqueued",
      "value": "hello"
    }
  ```

---

## 7) Verify Queue Message (Portal)

1. Storage accounts → `stfunc<UNIQ>`
2. **Queues → messages-out**
3. Confirm a new queue message exists.

---

## 8) Provision API Management (CLI)

```bash
az apim create \
  --name "$APIM" \
  --resource-group "$RG" \
  --publisher-email "$EMAIL" \
  --publisher-name "Lab6A-Publisher" \
  --sku-name "$APIM_SKU"
```

> Check status until **Succeeded**:
```bash
az apim show \
  --resource-group "$RG" \
  --name "$APIM" \
  --query "provisioningState" \
  -o tsv
```

---

## 9) Import the Function into APIM (Portal) — Consumption SKU

### 🔹 Manual HTTP API Creation and Operation Setup (Portal)

1. Go to **API Management services → `apim-<UNIQ>`**.
2. Click **Add API**.
3. Choose **HTTP** (Manually define an HTTP API).
4. Fill in the details:
   - **Display name**: `sendMessage`
   - **Name**: `sendMessage`
   - **Web service URL**: Paste your Function App URL, including the function key
   - **API URL suffix**: `sendMessage`
   - **Protocols**: `HTTPS`
5. Click **Create**.

### 🔹 How to Get the Azure Function URL (with Function Key) to use as **Web service URL**

1. Go to the **Azure Portal** → open your **Function App**  (e.g., `func-httpq-<UNIQ>`)*
2. In the **Functions**, Select your target function — for example: **`sendMessage`**
3. At the top **Code+Test**, click **Get function URL**.
4. In the dialog that appears:
   - Choose **default (Function key)** from the dropdown.
   - Copy the generated URL — it will look like:
     ```bash
      https://func-http-node-app-<unique>.azurewebsites.net/api/sendMessage?code=<FUNCTION_KEY>
     ```
5. Use this URL (including the `?code=` part) as the **backend URL** in APIM or any client app.

### 🔹 Add POST Operation (Correct Path)

After the API is created:
1. Go to your new API (**sendMessage**) in APIM.
2. Click **Add operation**.
3. Set the following:
   - **Display name**: `POST sendMessage`
   - **Name**: `post-sendMessage`
   - **URL template**: `/` (not `/sendMessage`)
   - **Method**: `POST`
   - **Request body**: Add a parameter for the message (e.g., JSON body with `message` property)
4. Click **Save**.

### 🔹 Disable Subscription Requirement

After creating the API:
- Go to the API settings.
- **Subscription required**: Toggle **off** (if available).
- **Save**.

> The endpoint is now public through APIM. The backend Function requires its **function key** in the backend URL.

---

## 10) Test via APIM (Portal)

- Go to **APIs → sendMessage → Test** in APIM.
- Method: **POST**
- Body:
  ```json
  { "message": "Hello from APIM" }
  ```
- Click **Send**.
- Expect **200 OK** and a response like:
  ```json
  { "result": "Message enqueued", "value": "Hello from APIM" }
  ```

> Verify new message appears in **Queues → messages-out** in your Storage Account.

---

## 11) Clean Up (CLI)

```bash
az group delete \
  --name "$RG" \
  --yes \
  --no-wait
```

---

## Success Criteria
- Function App (Node.js 18, Consumption) deployed in `australiaeast`
- HTTP-triggered function `sendMessage` created
- Queue output binding configured (`messages-out` via `outputQueueItem`)
- API Management (Developer SKU) imported the function
- Subscription-key requirement **disabled**
- External HTTP POST to APIM (with **function key**) returns **200 OK**
- Queue contains the enqueued message
