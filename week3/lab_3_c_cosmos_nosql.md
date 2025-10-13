# 🌌 **Lab 3-C: Deploying and Querying Azure Cosmos DB (NoSQL)**

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/8569bba0-dbab-4511-84c0-55fe62bb56db" />

## 🎯 **Objective**

Provision an **Azure Cosmos DB (Core / SQL API)** account, create a **database and container**, and run **NoSQL queries** using **Azure Portal**, **Visual Studio Code**, or **Azure CLI**.

---

## 🛍️ **Prerequisites**

- Access to the **Azure Portal** or **Azure Cloud Shell**
- **Azure CLI** installed (latest version)
- **Visual Studio Code** with the **Azure Databases extension**
- A valid **Azure subscription** with permissions to create resources
- Optional: A **sample JSON** file or JSON snippet to insert into the container

---

## 👣 **Step-by-Step Instructions**

### 1️⃣ **Register Cosmos DB Provider and Set Up Parameters**

Before creating Cosmos DB resources, ensure the provider is registered in your subscription.

```bash
# ==== VARIABLES ====
location="australiaeast"
rg="cosmos-demo-rg"
cosmos_account="cosmosdemo$RANDOM"
db_name="studentsdb"
container_name="grades"
partition_key="/studentId"

# ==== REGISTER COSMOS PROVIDER ====
az provider register \
   --namespace Microsoft.DocumentDB

# Verify registration
az provider show \
   --namespace Microsoft.DocumentDB \
   --query "registrationState"
```

✅ Expected output: `"Registered"`

Then, create a **resource group** for this lab:

```bash
az group create \
   --name "$rg" \
   --location "$location"
```

---

### 2️⃣ **Create an Azure Cosmos DB Account**

Use either the **Azure Portal** or the **CLI** to create a new account.

#### 🔹 **Using Azure Portal**

1. Go to the [Azure Portal](https://portal.azure.com).  
2. Search for **Azure Cosmos DB** → Click **+ Create**.  
3. Select **Azure Cosmos DB for NoSQL** (Core SQL API).  
4. Fill in the **Basics** tab:  
   - **Subscription:** your subscription  
   - **Resource Group:** `cosmos-demo-rg`  
   - **Account Name:** `cosmosdemo<unique>`  
   - **Location:** `Australia East`  
5. Leave defaults for capacity and networking.  
6. Click **Review + Create** → **Create**.

#### 🔹 **Using Azure CLI**

```bash
az cosmosdb create \
   --name "$cosmos_account" \
   --resource-group "$rg" \
   --kind GlobalDocumentDB \
   --locations regionName="$location" failoverPriority=0 isZoneRedundant=False
```

---

### 3️⃣ **Create a Database and Container**

#### 🔹 **Using Azure Portal**

1. Open your Cosmos DB account in the portal.  
2. Navigate to **Data Explorer** → Click **New Container**.  
3. Configure the following:  
   - **Database ID:** `studentsdb` → *Create new*  
   - **Container ID:** `grades`  
   - **Partition key:** `/studentId`  
4. Click **OK** to create.

#### 🔹 **Using Azure CLI**

```bash
# Create Database
az cosmosdb sql database create \
   --account-name "$cosmos_account" \
   --resource-group "$rg" \
   --name "$db_name"

# Create Container
az cosmosdb sql container create \
   --account-name "$cosmos_account" \
   --resource-group "$rg" \
   --database-name "$db_name" \
   --name "$container_name" \
   --partition-key-path "$partition_key"
```

---

### 4️⃣ **Insert and Query JSON Documents**

#### 📥 **Option 1: Insert via Azure Portal**

1. Open the Cosmos DB account → **Data Explorer**.  
2. Expand `studentsdb > grades`.  
3. Click **+ New Item** and paste:  

```json
{
  "id": "1",
  "studentId": "s1001",
  "name": "Ava Chen",
  "course": "Math",
  "grade": 88
}
```

4. Click **Save** to insert the document.

---

#### 💻 **Option 2: Insert and Query via Visual Studio Code**

1. Open **VS Code** and install the **Azure Databases** extension.  
2. Sign in to your Azure account from the extension panel.  
3. Locate your Cosmos DB account → Expand `studentsdb > grades`.  
4. Right-click **grades** → Select **Create Document** → Paste JSON.  
5. Click **Query** tab → Run:  

```sql
SELECT * FROM grades g WHERE g.grade > 80
```

✅ Results showing all students with grades above 80 will appear in the query pane.

---

#### ⚙️ **CLI Limitation**

The current Azure CLI does **not support** inserting or querying documents (`az cosmosdb sql container item create`).  
Use the **Azure Portal** or **VS Code extension** for data operations.

---

### 5️⃣ **Validate and Explore**

You can explore container metadata using Azure CLI:  

```bash
az cosmosdb sql container show \
   --account-name "$cosmos_account" \
   --resource-group "$rg" \
   --database-name "$db_name" \
   --name "$container_name" \
   --query "{id:id, partitionKey:partitionKey, defaultTtl:defaultTtl}"
```

---

### 6️⃣ **Clean Up (Optional)**

When finished, delete all resources to avoid ongoing costs:

```bash
az group delete \
   --name "$rg" \
   --yes \
   --no-wait
```

---

## 🧩 **Outcome**

Students have successfully:  
- Registered the **Cosmos DB provider** and deployed a **Cosmos DB account**  
- Created a **database** and **container** using both Portal and CLI  
- Inserted and queried **JSON documents** through **Data Explorer** and **VS Code**  
- Validated data operations and resource configuration  
