# 📩 Lab 6-D: Real-Time Email to SMS Notification Using Microsoft Graph and Azure Function
<img width="1382" height="913" alt="6-d" src="https://github.com/user-attachments/assets/a8a70d3a-eb5c-4764-afb1-643d4c6fed41" />

## 🎯 Objective
Build an **event-driven serverless system** using **Azure Functions (Node.js)** that listens for new emails via a **Microsoft Graph webhook** and sends an **SMS alert** using **Twilio**.  
When a new email arrives, the function extracts the sender and subject, then delivers a text message notification.

---

## ⏱ Estimated Duration
**90 minutes**

---

## 🧭 Prerequisites
- Active Azure Subscription  
- Office 365 Mailbox with Microsoft Graph API access  
- Azure CLI and Node.js (v18+) installed  
- Azure Functions Core Tools v4 installed  
- Twilio Account with verified phone number  
- [ngrok](https://ngrok.com/) installed (for local webhook testing)  
- Admin permission to register an Azure AD App

---

## 1️⃣ Create Azure Resources

```bash
LOCATION="australiaeast"
RG="rg-lab6d-email-sms"
STO="stemail$RANDOM"
FUNC_APP="func-email-sms$RANDOM"

az group create --name $RG --location $LOCATION

az storage account create \
  --name $STO \
  --location $LOCATION \
  --resource-group $RG \
  --sku Standard_LRS

az functionapp create \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --name $FUNC_APP \
  --storage-account $STO \
  --runtime node \
  --functions-version 4
```

---

## 2️⃣ Initialize Function Locally

```bash
func init lab6d-email-func --javascript
cd lab6d-email-func
func new --name EmailWebhook --template "HTTP trigger" --authlevel "anonymous"
```

This creates:
```
lab6d-email-func/
 └── EmailWebhook/
     ├── function.json
     └── index.js
```

---

## 3️⃣ Implement EmailWebhook Logic

Replace `EmailWebhook/index.js` with the following code:

```javascript
const twilio = require('twilio');
const axios = require('axios');

module.exports = async function (context, req) {
  const mode = req.query.validationToken ? "validate" : "notify";

  // Webhook validation from Microsoft Graph
  if (mode === "validate") {
    context.log("Validating webhook...");
    context.res = {
      status: 200,
      body: req.query.validationToken,
      headers: { 'Content-Type': 'text/plain' }
    };
    return;
  }

  const messageId = req.body?.value?.[0]?.resourceData?.id;

  if (!messageId) {
    context.res = { status: 400, body: "No message ID received" };
    return;
  }

  const accessToken = await getAccessToken();
  const msgRes = await axios.get(`https://graph.microsoft.com/v1.0/me/messages/${messageId}`, {
    headers: { Authorization: `Bearer ${accessToken}` }
  });

  const sender = msgRes.data?.from?.emailAddress?.address || "Unknown";
  const subject = msgRes.data?.subject || "(No Subject)";

  try {
    const client = twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);
    await client.messages.create({
      body: `📧 New Email from ${sender}: ${subject}`,
      from: process.env.TWILIO_PHONE,
      to: process.env.RECIPIENT_PHONE
    });
    context.res = { status: 200, body: "SMS sent successfully." };
  } catch (err) {
    context.res = { status: 500, body: "SMS failed: " + err.message };
  }
};

// Helper: Acquire Microsoft Graph Access Token
async function getAccessToken() {
  const qs = require('querystring');
  const axios = require('axios');

  const tokenRes = await axios.post(
    `https://login.microsoftonline.com/${process.env.TENANT_ID}/oauth2/v2.0/token`,
    qs.stringify({
      grant_type: "client_credentials",
      client_id: process.env.CLIENT_ID,
      client_secret: process.env.CLIENT_SECRET,
      scope: "https://graph.microsoft.com/.default"
    }),
    { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
  );

  return tokenRes.data.access_token;
}
```

---

## 4️⃣ Update `function.json`

```json
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["post", "get"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

---

## 5️⃣ Install Dependencies

```bash
npm install twilio axios querystring
```

---

## 6️⃣ Set Environment Variables

```bash
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings \
  TWILIO_SID=<your_twilio_sid> \
  TWILIO_AUTH_TOKEN=<your_twilio_auth_token> \
  TWILIO_PHONE=<your_twilio_phone> \
  RECIPIENT_PHONE=<destination_number> \
  CLIENT_ID=<app_client_id> \
  CLIENT_SECRET=<app_client_secret> \
  TENANT_ID=<your_tenant_id>
```

---

## 7️⃣ Test Locally

```bash
func start
```

Expose it publicly using **ngrok**:

```bash
ngrok http 7071
```

Copy the public URL — e.g. `https://abcd1234.ngrok.io/api/EmailWebhook`.

---

## 8️⃣ Register Azure AD App for Microsoft Graph

1. Go to **Azure Portal → Microsoft Entra ID → App registrations → + New registration**
2. **Name:** `EmailWebhookApp`
3. **Redirect URI:** `https://localhost`
4. After creation:
   - Copy `Application (client) ID` and `Directory (tenant) ID`
   - Go to **Certificates & Secrets → + New client secret**
5. Under **API Permissions → Microsoft Graph → + Add a permission → Application permissions:**
   - `Mail.Read`
   - `MailboxSettings.Read`
   - `offline_access`
6. Grant **Admin consent** for your organization.

---

## 9️⃣ Create Microsoft Graph Webhook Subscription

Replace placeholders and run:

```bash
ACCESS_TOKEN=$(curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=<client_id>&client_secret=<client_secret>&scope=https://graph.microsoft.com/.default" \
  https://login.microsoftonline.com/<tenant_id>/oauth2/v2.0/token | jq -r '.access_token')

curl -X POST https://graph.microsoft.com/v1.0/subscriptions \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changeType": "created",
    "notificationUrl": "https://<ngrok_url>/api/EmailWebhook",
    "resource": "me/mailFolders(\'Inbox\')/messages",
    "expirationDateTime": "'$(date -u -d "+4230 minutes" '+%Y-%m-%dT%H:%M:%SZ')'",
    "clientState": "secretClientValue"
  }'
```

This registers a webhook for new incoming emails.

---

## 🔟 Deploy to Azure

```bash
func azure functionapp publish $FUNC_APP
```

After testing successfully with **ngrok**, update the **notificationUrl** in Microsoft Graph to point to your **Azure Function URL**.

---

## 1️⃣1️⃣ Test the Workflow

1. Send a new email to your Office 365 inbox.  
2. Microsoft Graph posts a notification to your Function App.  
3. The Function fetches the sender and subject.  
4. Twilio sends an SMS alert to your configured phone number.  
5. Verify SMS on your mobile device.

---

## 🧹 Clean Up

```bash
az group delete --name $RG --yes --no-wait
```

---

## ✅ Success Criteria

| Verification Step | Expected Result |
|--------------------|------------------|
| Azure Function deployed successfully | ✅ |
| Microsoft Graph subscription validated | ✅ |
| Email triggers Function execution | ✅ |
| SMS sent via Twilio with sender & subject | ✅ |
| Resources deleted after cleanup | ✅ |

---

## 🧩 Optional Enhancements

- Replace Twilio with **Azure Communication Services (ACS)** for full Azure integration.  
- Persist email metadata in **Cosmos DB** for analytics.  
- Add retry policies for SMS delivery failures.  
- Extend webhook logic to handle calendar events or Teams messages.

