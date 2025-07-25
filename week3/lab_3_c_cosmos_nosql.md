# 🌌 Demo Guide: Deploying and Querying Azure Cosmos DB (NoSQL)

## 🎯 Objective

Provision an Azure Cosmos DB account using the Core (SQL) API, create a database and container, and run queries using Data Explorer, Visual Studio Code, or Azure CLI.

---

## 🛍️ Prerequisites

- Azure Portal access
- Azure CLI installed
- Visual Studio Code with **Azure Databases extension** installed
- A sample JSON file (or JSON content to insert)

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create a Cosmos DB Account

⚠️ **Before you begin**, ensure the Azure Cosmos DB provider is registered for your subscription:

```bash
az provider register --namespace Microsoft.DocumentDB

az provider show --namespace Microsoft.DocumentDB --query "registrationState"
```

Expected output:

```
"Registered"
```

Then proceed with the following commands:

```bash
COSMOS_DB_NAME="cosmosdemo$RANDOM"
az group create --name cosmos-demo-rg --location australiaeast

az cosmosdb create \
  --name $COSMOS_DB_NAME \
  --resource-group cosmos-demo-rg \
  --kind GlobalDocumentDB \
  --locations regionName=australiaeast failoverPriority=0 isZoneRedundant=False
```

---

### 2️⃣ Create a Database and Container

🔸 **Portal:**

1. Open the Cosmos DB account
2. In the left pane, click **Data Explorer** → **New Container**
3. Fill in:
   - **Database id**: `studentsdb` (create new)
   - **Container id**: `grades`
   - **Partition key**: `/studentId`
4. Click **OK** to create

🔸 **CLI:**

```bash
az cosmosdb sql database create \
  --account-name $COSMOS_DB_NAME \
  --resource-group cosmos-demo-rg \
  --name studentsdb

az cosmosdb sql container create \
  --account-name $COSMOS_DB_NAME \
  --resource-group cosmos-demo-rg \
  --database-name studentsdb \
  --name grades \
  --partition-key-path /studentId
```

---

### 3️⃣ Insert and Query JSON Documents

#### 📥 Option 1: Insert Using Portal

1. Go to your Cosmos DB account in the Azure Portal
2. Click **Data Explorer** → Select `studentsdb > grades`
3. Click **+ New Item**, then paste:

```json
{
  "id": "1",
  "studentId": "s1001",
  "name": "Ava Chen",
  "course": "Math",
  "grade": 88
}
```

4. Click **Save**

#### 💻 Option 2: Insert and Query Using Visual Studio Code

1. Open VS Code with the **Azure Databases** extension installed
2. Sign in to your Azure subscription from the extension panel
3. Locate your Cosmos DB account > Expand `studentsdb > grades`
4. Right-click `grades` > Click **Create Document**, paste JSON above
5. Click **Query** tab → Run:

```sql
SELECT * FROM grades g WHERE g.grade > 80
```

✅ Results will appear in the query pane

#### 🚫 CLI Limitations

As of now, the Azure CLI **does not support** `az cosmosdb sql container item create`. Therefore, document insertion must be done via Portal or VS Code extension.

---

## 🪼 Clean Up (Optional)

```bash
az group delete --name cosmos-demo-rg --yes --no-wait
```

---

📊 **Demo complete – students have deployed Cosmos DB, created a container, inserted documents, and run NoSQL queries using both Portal and Visual Studio Code!**

