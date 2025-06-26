# 💄️ Demo Guide: Deploying and Accessing Azure SQL Database

## 🎯 Objective

Provision an Azure SQL Database, configure firewall access, and connect using Azure Cloud Shell or MySQL Workbench.

---

## 🛍️ Prerequisites

- Azure Portal or Cloud Shell access
- Azure CLI installed (for local use)
- SQL client software (optional for GUI access):
  - MySQL Workbench with ODBC driver
  - OR `sql` client (in Azure Cloud Shell)

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

🔸 **CLI (Portal/Cloud Shell or local):**

```bash
az group create --name sql-demo-rg --location australiaeast

read -s -p "🔑 Enter a strong password for the SQL admin account: " SQL_PASSWORD

az sql server create \
  --name studentsqlserver123 \
  --resource-group sql-demo-rg \
  --location australiaeast \
  --admin-user sqladmin \
  --admin-password "$SQL_PASSWORD"

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

# For demo purposes  you can open the access to public
#  --start-ip-address 0.0.0.0 \
#  --end-ip-address 255.255.255.255
```

💡 Get your public IP from: [https://whatismyipaddress.com](https://whatismyipaddress.com)

---

### 3️⃣ Connect to the SQL Database

#### 🐳 Option 1: GitHub Codespaces using Docker

Use Docker in GitHub Codespaces to connect securely to your Azure SQL Database:

```bash
docker run -it --rm mcr.microsoft.com/mssql-tools \
  /opt/mssql-tools/bin/sqlcmd -S studentsqlserver123.database.windows.net -U sqladmin -d studentdb
```

✅ This command will **prompt you for your password** interactively.

📌 Alternatively, if you want to specify the password directly (for automation only):

```bash
docker run -it --rm mcr.microsoft.com/mssql-tools \
  /opt/mssql-tools/bin/sqlcmd -S studentsqlserver123.database.windows.net -U sqladmin -P 'YourPassword' -d studentdb
```

> ⚠️ Avoid hardcoding passwords in scripts. Use secrets management in production environments.

🔗 [Install sqlcmd locally (docs)](https://learn.microsoft.com/sql/tools/sqlcmd-utility)

---



#### 🧰 Option 2: MySQL Workbench via ODBC (Windows/Mac)

1. Install **ODBC Driver 18 for SQL Server** from Microsoft
2. Open **Windows ODBC Data Sources (64-bit)** → Add a **System DSN**:
   - Driver: **ODBC Driver 18 for SQL Server**
   - Server: `studentsqlserver123.database.windows.net`
   - Authentication: SQL Login → `sqladmin`
   - Password: `ChooseASecurePassword!`
   - Encrypt: Yes, Trust Server Certificate: No
3. Open **MySQL Workbench** → Add a new connection using the DSN
4. Connect to the database

---

### 4️⃣ Post Deployment Testing

After connecting to the database, run the following queries to test:

🔹 **Show current database:**

```sql
SELECT DB_NAME();
GO
```

🔹 **Create a sample table:**

```sql
CREATE TABLE students (
  id INT PRIMARY KEY,
  name NVARCHAR(100),
  enrolled_date DATE
);
GO
```

🔹 **Show the table:**

```sql
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO
```

🔹 **Insert a test row:**

```sql
INSERT INTO students (id, name, enrolled_date)
VALUES (1, 'Alice Smith', '2024-06-01');
GO
```

🔹 **Query the table:**

```sql
SELECT * FROM students;
GO
```

✅ You should see one student record displayed.

---

## 🪼 Clean Up (Optional)

```bash
az group delete --name sql-demo-rg --yes --no-wait
```

---

📉 **Demo complete – students have successfully deployed and connected to an Azure SQL Database using multiple tools!**

