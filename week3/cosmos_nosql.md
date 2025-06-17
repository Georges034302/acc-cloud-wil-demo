# 🌌 Demo Guide: Deploying and Querying Azure Cosmos DB (NoSQL)

## 🎯 Objective

Provision an Azure Cosmos DB account using the Core (SQL) API, create a database and container, and run queries using Data Explorer or Azure CLI.

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed
- A sample JSON file (or JSON content to insert)

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create a Cosmos DB Account

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **Azure Cosmos DB** → Click **+ Create**
3. Choose **Core (SQL)** API → Click **Create**
4. Basics tab:
   - **Account Name**: `cosmosdemo123`
   - **Resource Group**: `cosmos-demo-rg`
   - **Region**: `Australia East`
   - Leave default options enabled
5. Click **Review + create** → **Create**

🔸 **CLI:**

```bash
az group create --name cosmos-demo-rg --location australiaeast

az cosmosdb create \
  --name cosmosdemo123 \
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
  --account-name cosmosdemo123 \
  --resource-group cosmos-demo-rg \
  --name studentsdb

az cosmosdb sql container create \
  --account-name cosmosdemo123 \
  --resource-group cosmos-demo-rg \
  --database-name studentsdb \
  --name grades \
  --partition-key-path /studentId
```

---

### 3️⃣ Insert and Query JSON Documents

🔸 **Portal (Data Explorer):**

1. Expand `studentsdb` → `grades` → Click **Items**
2. Click **+ New Item** → Paste the following:

```json
{
  "id": "1",
  "studentId": "s1001",
  "name": "Ava Chen",
  "course": "Math",
  "grade": 88
}
```

3. Click **Save**
4. Run a query using **Query Explorer**:

```sql
SELECT * FROM grades g WHERE g.grade > 80
```

✅ The result will include students with grades over 80.

🔸 **CLI (Insert Document):**

```bash
az cosmosdb sql container item create \
  --account-name cosmosdemo123 \
  --resource-group cosmos-demo-rg \
  --database-name studentsdb \
  --container-name grades \
  --partition-key s1001 \
  --body '{
    "id": "1",
    "studentId": "s1001",
    "name": "Ava Chen",
    "course": "Math",
    "grade": 88
  }'
```

🔸 **CLI (Query Document):**

```bash
az cosmosdb sql query \
  --account-name cosmosdemo123 \
  --resource-group cosmos-demo-rg \
  --database-name studentsdb \
  --container-name grades \
  --query "SELECT * FROM grades g WHERE g.grade > 80"
```

✅ These CLI commands insert and query data directly from the Cosmos DB container.

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name cosmos-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have deployed Cosmos DB, created a container, inserted documents, and run NoSQL queries using both Portal and CLI!**

