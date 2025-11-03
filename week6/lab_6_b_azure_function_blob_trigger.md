# Lab 6-B: Student CSV Processor — Azure Function App
<img width="1536" height="725" alt="6-B" src="https://github.com/user-attachments/assets/57e58e9b-d33d-43f3-9a15-b161ccf94562" />

## Objective
Create a **serverless data ingestion pipeline** using **Azure Functions** with a **Blob Storage trigger** and **Table Storage output**.  
When a CSV file is uploaded to a designated container, the function automatically parses and inserts each record into an Azure Table.

---

## Prerequisites
- Active Azure Subscription  
- Azure CLI and Azure Functions Core Tools v4 installed
  ```bash
    # Check if Azure Functions Core Tools v4 is installed
    func --version || echo "Azure Functions Core Tools not found. Installing..."
    # Install Azure Functions Core Tools v4 (requires Node.js)
    npm install -g azure-functions-core-tools@4 --unsafe-perm true
    # Verify installation
    func --version
  ```
- Node.js (v18 or later) installed  
- Azure Storage Explorer (optional, for verification)

---

## 1️⃣ Set Enviroment Variables 

```bash
LOCATION="australiaeast"
RG="rg-student-func"
STO="stdemo$RANDOM"
FUNC_APP="func-student-app-$RANDOM"
TABLE_NAME="StudentGrades"
CONTAINER_NAME="student-files"
```

## 2️⃣ Create Resource Group and Storage Account

```bash
# Create the resource group
az group create \
  --name $RG \
  --location $LOCATION
```

```bash
# Create the storage account
az storage account create \
  --name $STO \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS
```

---

## 3️⃣ Create Blob Container and Target Table

```bash
# Create Blob Container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STO # Create the blob container
```

```bash
# Get the storage account KEY
STO_KEY=$(az storage account keys list \
  --resource-group $RG \
  --account-name $STO \
  --query "[0].value" \
  -o tsv)
```

```bash
# Create the Target Table
az storage table create \
  --name $TABLE_NAME \
  --account-name $STO \
  --account-key $STO_KEY # Create the target table
```

---

## 4️⃣ Initialize Function App Project (Node.js)
```bash
# Initialize the function app project (Node.js v4 model)
func init . --worker-runtime node --language javascript
# All files will be created in the current directory, with functions in src/functions/
```

---

## 5️⃣ Create a Blob Trigger Function

```bash
# Create a new blob trigger function
func new --name ProcessStudentCSV --template "Azure Blob Storage trigger"
# This creates src/functions/ProcessStudentCSV.js
```

---

## 6️⃣ Add Required NPM Packages

```bash
# Install required npm packages in the project root
npm install @azure/data-tables csv-parse uuid
```

---

## 7️⃣ Edit `ProcessStudentCSV.js`

Replace existing code with:

```javascript
const { app } = require('@azure/functions');

app.storageBlob('ProcessStudentCSV', {
    // Use environment variable for container name
    path: `${process.env.CONTAINER_NAME || 'student-files'}/{name}`,
    // Use default AzureWebJobsStorage connection
    connection: 'AzureWebJobsStorage',
    handler: async (blob, context) => {
        context.log("Processing CSV upload...");

        const csvContent = blob.toString("utf8");
        const parse = require("csv-parse/sync").parse;
        const { TableClient, AzureNamedKeyCredential } = require("@azure/data-tables");
        const { v4: uuidv4 } = require("uuid");

        const records = parse(csvContent, { columns: true, skip_empty_lines: true });

        const account = process.env.STORAGE_ACCOUNT_NAME;
        const accountKey = process.env.STORAGE_ACCOUNT_KEY;
        const tableName = process.env.TABLE_NAME || "StudentGrades";

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
    }
});

```

---

## 8️⃣ Deploy to Azure

```bash
# Create the Azure Function App
az functionapp create \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --name $FUNC_APP \
  --storage-account $STO \
  --runtime node \
  --functions-version 4
```

### Set Function App Settings
```bash
# Set required app settings for Table Storage access
az functionapp config appsettings set --name $FUNC_APP --resource-group $RG --settings STORAGE_ACCOUNT_NAME=$STO STORAGE_ACCOUNT_KEY=$STO_KEY TABLE_NAME=$TABLE_NAME
# List all app settings to verify
az functionapp config appsettings list --name $FUNC_APP --resource-group $RG
```

```bash
# Publish the function app to Azure
func azure functionapp publish $FUNC_APP
```

---

## 9️⃣ Test the Function

Upload a CSV to trigger it:

```bash
# Upload a CSV file to trigger the function
az storage blob upload \
  --account-name $STO \
  --container-name $CONTAINER_NAME \
  --file ../week6/students.csv \
  --name students.csv \
  --account-key $STO_KEY
```

> Verify inserts in **Table Storage → StudentGrades**.

## ✅ Expected Result

- Function triggers automatically on CSV upload.  
- Each record is inserted into **Azure Table Storage**.  
- Logs confirm successful parsing and insertion.

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

## Success Criteria

| Step | Verification |
|------|---------------|
| Blob trigger fires upon file upload | ✅ |
| Function parses CSV correctly | ✅ |
| Table `StudentGrades` populated with new entities | ✅ |
| Function deploys successfully in `australiaeast` | ✅ |
