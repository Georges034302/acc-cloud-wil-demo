# 🗄️ Demo Guide: Deploying and Accessing Azure SQL Database

## 🎯 Objective

Provision an Azure SQL Database, configure firewall access, and connect using Azure Data Studio, SQL CLI, or MySQL Workbench.

---

## 🧭 Prerequisites

- Azure Portal access
- Azure CLI installed
- SQL client software installed:
  - Azure Data Studio or SQL Server Management Studio (SSMS)
  - OR MySQL Workbench (configured for SQL Server)
  - OR `sqlcmd` tool from Microsoft

---

## 👣 Step-by-Step Instructions (Azure Portal + Azure CLI)

### 1️⃣ Create a SQL Server and SQL Database

🔸 **Portal:**

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **SQL databases** → Click **+ Create**
3. Basics tab:
   - **Database name**: `studentdb`
   - **Server**: Click **Create new**
     - Name: `student-sql-server`
     - Admin login: `sqladmin`
     - Password: `ChooseASecurePassword!`
     - Location: `Australia East`
   - Choose **Basic** pricing tier
4. Click **Review + create** → **Create**

🔸 **CLI:**

```bash
az group create --name sql-demo-rg --location australiaeast

az sql server create \
  --name studentsqlserver123 \
  --resource-group sql-demo-rg \
  --location australiaeast \
  --admin-user sqladmin \
  --admin-password ChooseASecurePassword!

az sql db create \
  --resource-group sql-demo-rg \
  --server studentsqlserver123 \
  --name studentdb \
  --service-objective Basic
```

---

### 2️⃣ Configure Firewall to Allow Access

🔸 **Portal:**

1. After deployment, go to the SQL server: `student-sql-server`
2. Click **Networking** → **Add client IP** → Save

🔸 **CLI:**

```bash
az sql server firewall-rule create \
  --resource-group sql-demo-rg \
  --server studentsqlserver123 \
  --name allow-local-ip \
  --start-ip-address <your_public_ip> \
  --end-ip-address <your_public_ip>
```

💡 Get your public IP from: [https://whatismyipaddress.com](https://whatismyipaddress.com)

---

### 3️⃣ Connect to the SQL Database

🔸 **Using Azure Data Studio or SSMS:**

1. Open the app and click **New Connection**
2. Fill in the fields:
   - **Server**: `studentsqlserver123.database.windows.net`
   - **Authentication type**: SQL Login
   - **Login**: `sqladmin`
   - **Password**: `ChooseASecurePassword!`
   - **Database name**: `studentdb`
3. Click **Connect**
4. Run a test query:

```sql
SELECT GETDATE();
```

✅ You should see the current date/time from Azure SQL.

🔸 **Using MySQL Workbench (via ODBC Setup):**

1. Open MySQL Workbench → Click **+** to add a new connection
2. Choose **ODBC (Connector/ODBC)** as the connection method *(you must configure an ODBC Data Source first)*
3. Go to **Windows ODBC Data Sources (64-bit)** → Add a new System DSN:
   - Driver: **ODBC Driver 18 for SQL Server**
   - Server: `studentsqlserver123.database.windows.net`
   - Authentication: **SQL Server Authentication**
   - Login: `sqladmin`, Password: `ChooseASecurePassword!`
   - Encrypt: Yes
   - Trust Server Certificate: No (default)
4. Save DSN and test connection
5. Back in MySQL Workbench, use the DSN to connect

🔸 **Using sqlcmd:**

1. Install SQL Server Command Line Utilities (ODBC Driver + `sqlcmd`) from Microsoft docs:
   - [https://learn.microsoft.com/sql/tools/sqlcmd-utility](https://learn.microsoft.com/sql/tools/sqlcmd-utility)
2. Run:

```bash
sqlcmd -S studentsqlserver123.database.windows.net -U sqladmin -P ChooseASecurePassword! -d studentdb
```

3. In the `sqlcmd` prompt, enter:

```sql
SELECT GETDATE();
GO
```

✅ You will get the current timestamp from Azure SQL.

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name sql-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have successfully deployed and connected to an Azure SQL Database using multiple tools!**

