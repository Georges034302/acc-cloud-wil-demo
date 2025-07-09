# ⚡ Demo 2 Guide: Azure Function Node.js App: Blob Trigger ➜ Queue Writer

Create an event-driven integration using Azure Function (Node.js), Blob Storage, and Queue Storage — entirely through the **Azure Portal**.

---

## 📌 Objectives

✅ Upload a file to Blob Storage  
✅ Trigger a Node.js Azure Function on Blob creation  
✅ Function writes a message to Azure Queue  
✅ Secure with Managed Identity and RBAC

---

## 🗺️ Architecture Overview

```
[User Uploads File to Blob Storage]
                ⬇️
     [Azure Function (Node.js)]
        - Trigger: Blob Upload  
        - Action: Write message to Queue  
                ⬇️
         [Azure Storage Queue]
```

---

## 🔧 Prerequisites

- Azure subscription
- Resource Group (e.g. `demo3-rg`)
- Node.js knowledge (basic)
- Azure CLI (optional for scripting)

---

## 🛠️ Step-by-Step Setup (Portal Only)

### 🔹 Step 1: Create Storage Account

1. Go to **Storage Accounts** → **Create**
2. Use the following:
   - **Name**: `funcdemo3storage`
   - **Region**: `Australia East`
   - **Redundancy**: LRS
3. Once created:
   - Create a **Blob Container** named `upload-input`
     - Access level: `Private`
   - Go to **Queues** tab → Create queue: `filequeue`

---

### 🔹 Step 2: Create Azure Function App (Node.js)

1. Go to **Function Apps** → **Create**
2. Use these values:
   - **Name**: `demo3-func`
   - **Runtime stack**: Node.js (18 LTS)
   - **Region**: `Australia East`
   - **Hosting Plan**: Consumption
   - **Storage**: Use the one from Step 1
3. Once created, go to:
   - **Functions** → **Add Function**
   - Choose **Blob trigger**
   - Name: `BlobToQueueFn`
   - Path: `upload-input/{name}`
   - Storage connection: Select existing (`AzureWebJobsStorage`)

---

### 🔹 Step 3: Modify Function Code

Go to **Code + Test** and update `index.js`:

```javascript
const { QueueServiceClient } = require("@azure/storage-queue");

module.exports = async function (context, myBlob) {
    const filename = context.bindingData.name;
    const connStr = process.env["AzureWebJobsStorage"];
    const queueName = "filequeue";

    const queueClient = QueueServiceClient.fromConnectionString(connStr).getQueueClient(queueName);
    await queueClient.sendMessage(Buffer.from(\`File uploaded: \${filename}\`).toString('base64'));

    context.log(\`✅ File "\${filename}" processed and message sent to queue.\`);
};
```

Ensure `function.json` is as follows:

```json
{
  "bindings": [
    {
      "name": "myBlob",
      "type": "blobTrigger",
      "direction": "in",
      "path": "upload-input/{name}",
      "connection": "AzureWebJobsStorage"
    }
  ],
  "scriptFile": "index.js"
}
```

Click **Save** ✅

---

### 🔹 Step 4: Test the End-to-End Flow

1. Go to **Storage Account** → `upload-input` container  
2. Upload a file (e.g., `sample.txt`)
3. Wait ~10 seconds
4. Go to **Queues** → `filequeue`
5. Confirm a new message:  
   ```
   File uploaded: sample.txt
   ```

---

### 🔹 Step 5: 🔐 Assign Roles to Function Identity

#### ✅ Enable System-Assigned Identity

1. Go to **Function App** → **Identity**
2. Under **System-assigned**, set Status to **On**
3. Click **Save**

> This creates a Managed Identity named `demo3-func`

---

#### ✅ Assign RBAC Roles on Storage Account

Go to **Storage Account** → **Access Control (IAM)** → **+ Add Role Assignment**

🔸 **Role 1**: `Storage Blob Data Contributor`
- Assign to: `demo3-func` (Managed identity)

🔸 **Role 2**: `Storage Queue Data Contributor`
- Assign to: `demo3-func` (Managed identity)

✅ This allows the function to:
- Trigger from Blob
- Send messages to Queue

---

## ✅ Summary

| Component        | Purpose                             |
|------------------|--------------------------------------|
| Blob Container   | Stores uploaded files (input)        |
| Azure Function   | Node.js logic triggered by Blob      |
| Queue Storage    | Stores messages about uploaded files |
| RBAC Roles       | Grant function required permissions  |

---

## 🧪 Sample Output in Queue

```plaintext
File uploaded: invoice-123.pdf
File uploaded: profile-image.jpg
```

---

## 🧠 Notes

- Logs available in **Monitor** tab inside the Function
- You can later add a **Queue-triggered Function** to process messages
- All config is portal-based; no CLI or Bicep used in this demo
