
# Demo Guide: Real-Time Email to SMS Notification Using Microsoft Graph and Azure Function

## 🎯 Objective
In this lab, you'll build an event-driven system using a Node.js Azure Function that listens for new emails via a Microsoft Graph webhook and sends an SMS alert using Twilio with the sender and subject of the email.

---

## 🧭 Prerequisites

- Azure Subscription
- Office 365 Mailbox (with API access)
- Azure CLI installed
- Node.js (v16+) and Azure Functions Core Tools
- Twilio Account and Verified Phone Number
- [ngrok](https://ngrok.com/) installed (for local testing)
- Admin permissions to register an Azure AD App

---

## 🛠️ Architecture Overview

```
📧 Office 365 Mailbox
    ↓ (new email)
🔔 Microsoft Graph Subscription (Webhook)
    ↓
🟦 Azure Function (Node.js)
    ↓
📲 Twilio API → Sends SMS
```

---

## 👣 Step-by-Step Instructions

### 1️⃣ Create Azure Resources

```bash
az group create --name lab4-rg --location australiaeast

STORAGE_NAME=lab4storage$RANDOM
FUNC_APP=lab4func$RANDOM

az storage account create \
  --name $STORAGE_NAME \
  --location australiaeast \
  --resource-group lab4-rg \
  --sku Standard_LRS

az functionapp create \
  --resource-group lab4-rg \
  --consumption-plan-location australiaeast \
  --name $FUNC_APP \
  --storage-account $STORAGE_NAME \
  --runtime node \
  --functions-version 4
```

---

### 2️⃣ Initialize Node.js Azure Function Locally

```bash
func init lab4-email-func --javascript
cd lab4-email-func
func new --name EmailWebhook --template "HTTP trigger" --authlevel "anonymous"
```

---

### 3️⃣ Implement EmailWebhook Logic

Replace `EmailWebhook/index.js` with:

```javascript
const twilio = require('twilio');
const axios = require('axios');

module.exports = async function (context, req) {
    const mode = req.query.validationToken ? "validate" : "notify";

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
    const tenantId = req.body?.value?.[0]?.tenantId;

    if (!messageId) {
        context.res = { status: 400, body: "No message ID received" };
        return;
    }

    const accessToken = await getAccessToken(); // custom token acquisition method
    const msgRes = await axios.get(`https://graph.microsoft.com/v1.0/me/messages/${messageId}`, {
        headers: { Authorization: `Bearer ${accessToken}` }
    });

    const sender = msgRes.data?.from?.emailAddress?.address || "Unknown";
    const subject = msgRes.data?.subject || "(No Subject)";

    try {
        const client = twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);
        await client.messages.create({
            body: `📧 Email from ${sender}: ${subject}`,
            from: process.env.TWILIO_PHONE,
            to: process.env.RECIPIENT_PHONE
        });

        context.res = { status: 200, body: "SMS sent." };
    } catch (err) {
        context.res = { status: 500, body: "SMS failed: " + err.message };
    }
};
```

Update `function.json`:

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

### 4️⃣ Install Dependencies

```bash
npm install twilio axios
```

---

### 5️⃣ Set Environment Variables

```bash
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group lab4-rg \
  --settings \
  TWILIO_SID=<your_twilio_sid> \
  TWILIO_AUTH_TOKEN=<your_twilio_token> \
  TWILIO_PHONE=<twilio_number> \
  RECIPIENT_PHONE=<destination_number>
```

---

### 6️⃣ Run Function Locally for Testing

```bash
func start
```

Expose it with `ngrok`:

```bash
ngrok http 7071
```

Copy the generated public URL for webhook subscription.

---

### 7️⃣ Register Azure AD App for Graph API

1. Go to [Azure Portal → Azure AD → App Registrations → + New Registration](https://portal.azure.com/)
2. Name: `EmailWebhookApp`
3. Platform: Web → Redirect URI: `http://localhost` (for testing)
4. After creation:
   - Go to **Certificates & Secrets** → Generate a **Client Secret**
   - Note `Application (client) ID`, `Directory (tenant) ID`, and secret
5. API Permissions → Microsoft Graph → Add:
   - `Mail.Read`
   - `MailboxSettings.Read`
   - `offline_access`

Grant admin consent for the tenant.

---

### 8️⃣ Create Microsoft Graph Subscription (CLI via REST)

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
    "notificationUrl": "https://<your_ngrok_url>/api/EmailWebhook",
    "resource": "me/mailFolders(\'Inbox\')/messages",
    "expirationDateTime": "'$(date -u -d "+4230 minutes" '+%Y-%m-%dT%H:%M:%SZ')'",
    "clientState": "secretClientValue"
  }'
```

---

### 9️⃣ Deploy to Azure Function

```bash
func azure functionapp publish $FUNC_APP
```

Once tested with `ngrok`, update `notificationUrl` to point to your Azure Function URL.

---

## ✅ Test

1. Send an email to your Office 365 inbox
2. Graph will POST a notification to your Azure Function
3. Function reads email subject and sender → Sends SMS via Twilio
4. Check recipient device for the alert!

---

## 🧹 Clean Up Resources

```bash
az group delete --name lab4-rg --yes --no-wait
```

---

## 📌 Notes

- Graph subscriptions expire after ~1 hour (max 4320 min) — use a background renewal job in production
- Ensure Azure Function app has proper CORS config if accessed by external services
- Use Key Vault for managing Twilio credentials securely in production

---

✅ **Lab Complete**  
You have now built a fully event-driven system using Microsoft Graph and Azure Functions to trigger SMS notifications in real time when a new email arrives.
