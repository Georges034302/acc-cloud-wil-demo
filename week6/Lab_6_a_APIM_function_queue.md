# Lab 6-A: Expose an HTTP-Triggered Node.js Azure Function via API Management with Queue Output Binding

<img width="1467" height="912" alt="6-A" src="https://github.com/user-attachments/assets/9c3e9637-3b63-48b8-bd9b-ec69aefa0a58" />

## Objective
Create a **Node.js HTTP-triggered Azure Function** that writes messages into **Azure Storage Queue**, then expose it through **Azure API Management (APIM)** **without** a subscription key. Region is fixed to **`australiaeast`**. All resources are created from scratch in an isolated resource group.

## Estimated Duration
**60–75 minutes** (APIM Developer SKU provisioning typically takes ~30–45 minutes).

## Prerequisites
- Active Azure subscription (Contributor or higher)
- Azure CLI ≥ 2.61 (`az version`)
- Optional: `curl` or Postman for external testing

---

## 1) Set Variables and Create Resource Group (CLI)

> Replace `gbg123` and email with your values.

```bash
# >>> EDIT THESE VALUES <<<
UNIQ="gbg123"                 # globally unique suffix (letters/numbers)
EMAIL="you@example.com"

# Fixed values for the lab
LOCATION="australiaeast"
RG="rg-func-apim-$UNIQ"
STO="stfunc$UNIQ"
FUNCAPP="func-httpq-$UNIQ"
APIM="apim-$UNIQ"

# Create resource group
az group create --name "$RG" --location "$LOCATION"
```

---

## 2) Create the Function App (Azure Portal)

1. **Create a resource → Function App**
2. **Basics**
   - Resource Group: `rg-func-apim-<UNIQ>`
   - Name: `func-httpq-<UNIQ>`
   - Publish: **Code**
   - Runtime: **Node.js 18 LTS**
   - Region: **Australia East**
3. **Hosting**
   - Storage account: **Create new** → `stfunc<UNIQ>`
   - OS: **Linux**
   - Plan: **Consumption (Serverless)**
4. **Monitoring**
   - Application Insights: **Enable** (create new)
5. **Review + Create → Create**

Wait until deployment completes.

---

## 3) Add an HTTP Trigger Function (Portal)

1. Function App → **Functions → + Create**
2. Template: **HTTP trigger**
3. Function name: `sendMessage`
4. Authorization level: **Function**
5. **Create**

---

## 4) Add Queue Output Binding (Portal)

1. Function → **Integration → + Add output**
2. Binding type: **Azure Queue Storage**
3. Storage account connection: `AzureWebJobsStorage`
4. Queue name: `messages-out`
5. Parameter name: `outputQueueItem`
6. **Save**

---

## 5) Edit Function Code (Portal)

Open **Code + Test → `index.js`**, replace content with:

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

Click **Save**, then **Test/Run** with body:
```json
{ "message": "hello" }
```
Expect **200 OK**.

---

## 6) Verify Queue Message (Portal)

1. Storage accounts → `stfunc<UNIQ>`
2. **Queues → messages-out**
3. Confirm a new queue message exists.

---

## 7) Provision API Management (CLI)

```bash
az apim create \
  --name "$APIM" \
  --resource-group "$RG" \
  --publisher-email "$EMAIL" \
  --publisher-name "Lab6A-Publisher" \
  --location "$LOCATION" \
  --sku-name "Developer"
```

Check status until **Succeeded**:
```bash
az apim show -g "$RG" -n "$APIM" --query "provisioningState" -o tsv
```

---

## 8) Import the Function into APIM (Portal)

1. **API Management services → `apim-<UNIQ>`**
2. **APIs → + Add API → Function App**
3. Select Function App `func-httpq-<UNIQ>`
4. Select function `sendMessage` → **Create**
5. Open **Settings** for the imported API:
   - Disable **Subscription required** (toggle **off**)
   - **Save**

> The endpoint is now public through APIM. The backend Function still requires its **function key**.

---

## 9) Test via APIM (Portal) and Externally

### Test in APIM (Portal)
- APIM → **APIs → sendMessage → Test**
- Method: **POST**
- Body:
  ```json
  { "message": "Hello from APIM" }
  ```
- Click **Send** → Expect **200 OK**.

### External Test (cURL)
1. Copy the **Invoke URL** from APIM (Frontend), e.g.:
   ```
   https://apim-<UNIQ>.azure-api.net/sendMessage
   ```
2. Get the **Function key** from Function → **Code + Test → Get Function URL** (copy `code=<FUNCTION_KEY>`).

Run:
```bash
FUNC_KEY="<FUNCTION_KEY>"
APIM_URL="https://apim-$UNIQ.azure-api.net/sendMessage?code=$FUNC_KEY"

curl -i -X POST "$APIM_URL" \
  -H "Content-Type: application/json" \
  -d '{"message": "Triggered via APIM"}'
```

Expected response:
```json
{ "result": "Message enqueued", "value": "Triggered via APIM" }
```

Verify new message appears in **Queues → messages-out**.

---

## 10) Clean Up (CLI)

```bash
az group delete --name "$RG" --yes --no-wait
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
