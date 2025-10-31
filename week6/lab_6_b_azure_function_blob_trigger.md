# Lab 6-B: Student CSV Processor — Azure Function App
<img width="1536" height="725" alt="6-B" src="https://github.com/user-attachments/assets/57e58e9b-d33d-43f3-9a15-b161ccf94562" />

## Objective
Create a **serverless data ingestion pipeline** using **Azure Functions** with a **Blob Storage trigger** and **Table Storage output**.  
When a CSV file is uploaded to a designated container, the function automatically parses and inserts each record into an Azure Table.

---

## Estimated Duration
**60 minutes**

---

## Prerequisites
- Active Azure Subscription  
- Azure CLI and Azure Functions Core Tools v4 installed  
- Node.js (v18 or later) installed  
- Azure Storage Explorer (optional, for verification)

---

## 1️⃣ Create Resource Group and Storage Account

```bash
LOCATION="australiaeast"
RG="rg-student-func"
STO="ststudent$RANDOM"

az group create --name $RG --location $LOCATION

az storage account create \
  --name $STO \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS
```

---

## 2️⃣ Initialize Function App Project (Node.js)

```bash
func init student-app --worker-runtime node --language javascript
cd student-app
```

---

## 3️⃣ Create a Blob Trigger Function

```bash
func new --name ProcessStudentCSV --template "Azure Blob Storage trigger"
```

This creates:
```
student-app/
 └── ProcessStudentCSV/
     ├── function.json
     └── index.js
```

---

## 4️⃣ Add Required NPM Packages

```bash
npm install @azure/data-tables csv-parse uuid
```

---

## 5️⃣ Update `function.json`

Edit to define trigger and Table Storage output:

```json
{
  "bindings": [
    {
      "name": "myBlob",
      "type": "blobTrigger",
      "direction": "in",
      "path": "student-files/{name}",
      "connection": "AzureWebJobsStorage"
    }
  ],
  "scriptFile": "index.js"
}
```

---

## 6️⃣ Edit `index.js`

Replace existing code with:

```javascript
const { TableClient, AzureNamedKeyCredential } = require("@azure/data-tables");
const parse = require("csv-parse/sync").parse;
const { v4: uuidv4 } = require("uuid");

module.exports = async function (context, myBlob) {
  context.log("Processing CSV upload...");

  const csvContent = myBlob.toString("utf8");
  const records = parse(csvContent, { columns: true, skip_empty_lines: true });

  const account = process.env.STORAGE_ACCOUNT_NAME;
  const accountKey = process.env.STORAGE_ACCOUNT_KEY;
  const tableName = "StudentGrades";

  const credential = new AzureNamedKeyCredential(account, accountKey);
  const client = new TableClient(`https://${account}.table.core.windows.net`, tableName, credential);

  await client.createTable();

  for (const record of records) {
    const entity = {
      partitionKey: "Grades",
      rowKey: uuidv4(),
      Name: record.Name,
      Subject: record.Subject,
      Grade: record.Grade
    };
    await client.createEntity(entity);
  }

  context.log(`✅ Inserted ${records.length} records.`);
};
```

---

## 7️⃣ Create the Target Table

```bash
az storage table create \
  --name StudentGrades \
  --account-name $STO \
  --resource-group $RG
```

---

## 8️⃣ Create Blob Container

```bash
az storage container create \
  --name student-files \
  --account-name $STO
```

---

## 9️⃣ Configure Local Settings

Edit **`local.settings.json`**:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=<storage-name>;AccountKey=<key>;EndpointSuffix=core.windows.net",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "STORAGE_ACCOUNT_NAME": "<storage-name>",
    "STORAGE_ACCOUNT_KEY": "<key>"
  }
}
```

Retrieve keys:

```bash
az storage account keys list --resource-group $RG --account-name $STO -o table
```

---

## 🔟 Run Locally

```bash
func start
```

Upload `students.csv` into the `student-files` container.  
The function will parse and insert data into the `StudentGrades` table.

---

## 1️⃣1️⃣ Deploy to Azure

```bash
FUNC_APP="func-student-$RANDOM"

az functionapp create \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --name $FUNC_APP \
  --storage-account $STO \
  --runtime node \
  --functions-version 4

func azure functionapp publish $FUNC_APP
```

---

## 1️⃣2️⃣ Test the Function

Upload a CSV to trigger it:

```bash
az storage blob upload \
  --account-name $STO \
  --container-name student-files \
  --file students.csv \
  --name students.csv
```

Verify inserts in **Table Storage → StudentGrades**.

---

## ✅ Expected Result

- Function triggers automatically on CSV upload.  
- Each record is inserted into **Azure Table Storage**.  
- Logs confirm successful parsing and insertion.

---

## 🧹 Clean Up

```bash
az group delete --name $RG --yes --no-wait
```

---

## Success Criteria

| Step | Verification |
|------|---------------|
| Blob trigger fires upon file upload | ✅ |
| Function parses CSV correctly | ✅ |
| Table `StudentGrades` populated with new entities | ✅ |
| Function deploys successfully in `australiaeast` | ✅ |
