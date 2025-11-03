# 📩 Lab 6-D: Real-Time Email-to-SMS Notification Using Microsoft Graph and Azure Function (with Twilio)

<img width="1536" height="474" alt="IMG" src="https://github.com/user-attachments/assets/3dac82ed-eab5-4e97-af41-2268b241ed8b" />

## 🎯 Objective
Build an **event-driven serverless system** using **Azure Functions (Node.js)** that listens for new emails via a **Microsoft Graph webhook** and sends an **SMS alert** using **Twilio**.  
When a new email arrives, the function extracts the sender and subject, then delivers a text-message notification to the **admin’s mobile phone**.

---

## 🧭 Prerequisites
- Active Azure Subscription  
- Office 365 Mailbox with Microsoft Graph API access  
- Azure CLI and Node.js (v18+) installed  
- Azure Functions Core Tools v4 installed  
- [ngrok](https://ngrok.com/) installed (for local webhook testing)  
- Admin permission to register an Azure AD App  
- Active [Twilio Account](https://www.twilio.com/try-twilio) with SMS-capable number  
- Confirmed mobile number (e.g., `+61400000000`)  

---

## 1️⃣ Create Azure Resources
```bash
# Set Azure region and resource names
LOCATION="australiaeast"
RG="rg-lab6d-email-sms"
STO="stemail$RANDOM"
FUNC_APP="func-email-sms$RANDOM"

# Create resource group for all resources
az group create \
  --name $RG \
  --location $LOCATION

# Create storage account for function app
az storage account create \
  --name $STO \
  --location $LOCATION \
  --resource-group $RG \
  --sku Standard_LRS

# Create Azure Function App (Node.js)
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
# Initialize a new Azure Functions project (JavaScript)
func init lab6d-email-func --javascript

# Change to the project directory
cd lab6d-email-func

# Create a new HTTP trigger function named EmailWebhook
func new \
  --name EmailWebhook \
  --template "HTTP trigger" \
  --authlevel "anonymous"
```

---

## 3️⃣ Implement EmailWebhook Logic (using Twilio)

Replace `EmailWebhook/index.js` with:

```javascript
const twilio = require("twilio");
const axios = require("axios");

module.exports = async function (context, req) {
  const mode = req.query.validationToken ? "validate" : "notify";

  // Step 1 – Webhook validation
  if (mode === "validate") {
    context.res = {
      status: 200,
      body: req.query.validationToken,
      headers: { "Content-Type": "text/plain" },
    };
    return;
  }

  // Step 2 – Extract message ID
  const messageId = req.body?.value?.[0]?.resourceData?.id;
  if (!messageId) {
    context.res = { status: 400, body: "No message ID received" };
    return;
  }

  // Step 3 – Get email details from Graph
  const accessToken = await getAccessToken();
  const msgRes = await axios.get(
    `https://graph.microsoft.com/v1.0/me/messages/${messageId}`,
    { headers: { Authorization: `Bearer ${accessToken}` } }
  );

  const sender = msgRes.data?.from?.emailAddress?.address || "Unknown";
  const subject = msgRes.data?.subject || "(No Subject)";

  // Step 4 – Send SMS via Twilio
  try {
    const client = twilio(
      process.env.TWILIO_SID,
      process.env.TWILIO_AUTH_TOKEN
    );

    await client.messages.create({
      from: process.env.TWILIO_PHONE,
      to: process.env.RECIPIENT_PHONE,
      body: `📧 New Email from ${sender}: ${subject}`,
    });

    context.res = { status: 200, body: "SMS sent successfully via Twilio." };
  } catch (err) {
    context.res = { status: 500, body: "SMS failed: " + err.message };
  }
};

// Helper – Acquire Microsoft Graph token
async function getAccessToken() {
  const qs = require("querystring");
  const axios = require("axios");
  const tokenRes = await axios.post(
    `https://login.microsoftonline.com/${process.env.TENANT_ID}/oauth2/v2.0/token`,
    qs.stringify({
      grant_type: "client_credentials",
      client_id: process.env.CLIENT_ID,
      client_secret: process.env.CLIENT_SECRET,
      scope: "https://graph.microsoft.com/.default",
    }),
    { headers: { "Content-Type": "application/x-www-form-urlencoded" } }
  );
  return tokenRes.data.access_token;
}
```

---

## 4️⃣ Function Bindings (`function.json`)
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

> Project structure:
```
lab6d-email-func/
└── EmailWebhook/
    ├── function.json
    └── index.js
```

---

## 5️⃣ Install Dependencies
```bash
# Install required npm packages for the function
npm install \
  twilio \
  axios \
  querystring
```

---

## 6️⃣ Configure Environment Variables
```bash
# Set environment variables for Twilio, Microsoft Graph, and recipient phone number
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings \
    "TWILIO_SID=<your_twilio_account_sid>" \
    "TWILIO_AUTH_TOKEN=<your_twilio_auth_token>" \
    "TWILIO_PHONE=<your_twilio_phone_number>" \
    "RECIPIENT_PHONE=<admin_phone_number_in_E164_format>" \
    "CLIENT_ID=<app_client_id>" \
    "CLIENT_SECRET=<app_client_secret>" \
    "TENANT_ID=<your_tenant_id>"
```

---

## 7️⃣ Test Locally
```bash
# Start the function app locally for testing
func start
```

Expose publicly using **ngrok**:
```bash
# Expose local function app to the internet for webhook testing
ngrok http 7071
```
> Example URL: `https://abcd1234.ngrok.io/api/EmailWebhook`

---

## 8️⃣ Register Azure AD App (for Microsoft Graph)

1. Portal → **Microsoft Entra ID → App registrations → + New registration**  
2. Name: `EmailWebhookApp`  
3. Redirect URI: `https://localhost`  
4. After creation, note: Client ID and Tenant ID  
5. Certificates & Secrets → + New secret  
6. API Permissions → Microsoft Graph → Application permissions:  
   - `Mail.Read`  
   - `MailboxSettings.Read`  
   - `offline_access`  
7. Grant Admin consent.

---

## 9️⃣ Create Microsoft Graph Webhook Subscription
```bash
# Get an access token for Microsoft Graph API
ACCESS_TOKEN=$(curl -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=<client_id>&client_secret=<client_secret>&scope=https://graph.microsoft.com/.default" \
  https://login.microsoftonline.com/<tenant_id>/oauth2/v2.0/token | jq -r '.access_token')

# Register the webhook subscription for new emails
curl -X POST https://graph.microsoft.com/v1.0/subscriptions \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "changeType": "created",
    "notificationUrl": "https://<ngrok_url>/api/EmailWebhook",
    "resource": "me/mailFolders('Inbox')/messages",
    "expirationDateTime": "'$(date -u -d "+4230 minutes" '+%Y-%m-%dT%H:%M:%SZ')'",
    "clientState": "secretClientValue"
  }'
```

---

## 🔟 Deploy to Azure
```bash
# Deploy the function app to Azure
func azure functionapp publish $FUNC_APP
```
> Update the webhook `notificationUrl` to your live Function App endpoint after deployment.

---

## 1️⃣1️⃣ Test the Workflow
1. Send a new email to your Office 365 inbox.  
2. Microsoft Graph notifies your Function.  
3. Function retrieves email details.  
4. Twilio sends an SMS to the admin’s phone (`+61400000000`).  
5. Confirm SMS receipt on device.  

---

## 🧹 Clean Up
```bash
# Delete the resource group and all resources
az group delete \
  --name $RG \
  --yes \
  --no-wait
```

---

## ✅ Success Criteria

| Verification Step | Expected Result |
|--------------------|----------------|
| Function deployed successfully | ✅ |
| Graph webhook validated | ✅ |
| Email triggers function execution | ✅ |
| SMS received via Twilio | ✅ |
| Resources deleted after cleanup | ✅ |
