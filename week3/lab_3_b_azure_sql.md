# 💾 **Lab 3-B: Deploying and Accessing Azure SQL Database**

## 🎯 **Objective**

Provision an **Azure SQL Database**, configure **firewall access**, and connect using **Azure Cloud Shell**, **Docker (sqlcmd)**, or **Azure Data Studio/SSMS**.

---

## 🛍️ **Prerequisites**

- Access to the **Azure Portal** or **Azure Cloud Shell**
- **Azure CLI** installed (for local use)
- Optional SQL client software:
  - **Azure Data Studio** or **SQL Server Management Studio (SSMS)**
  - Or `sqlcmd` (available in Cloud Shell or via Docker)

---

## 👣 **Step-by-Step Instructions**

### 1️⃣ Create a Resource Group, SQL Server, and Database

#### 🔹 Using the Azure Portal

1. Sign in to the [Azure Portal](https://portal.azure.com)  
2. Search for **SQL databases** → Click **+ Create**
3. In the **Basics** tab:
   - **Database name:** `studentdb`
   - **Server:** Click **Create new**
     - **Server name:** `studentsqlserver<unique>` (e.g., `studentsqlserver12345`)
     - **Admin login:** `sqladmin`
     - **Password:** `ChooseASecurePassword!`
     - **Location:** `Australia East`
   - **Compute + Storage:** Select **Basic**
4. Click **Review + Create** → **Create**

#### 🔹 Using Azure CLI (Cloud Shell or Local)

```bash
# ==== Parameters ====
location="australiaeast"
rg="sql-demo-rg"
server="studentsqlserver$RANDOM"    # Must be globally unique
admin_user="sqladmin"
db_name="studentdb"

# Create Resource Group
az group create \
  --name "$rg" \
  --location "$location"

# Create SQL Server (you’ll be prompted for password)
read -s -p "🔑 Enter a strong SQL admin password: " SQL_PASSWORD
echo

az sql server create \
  --name "$server" \
  --resource-group "$rg" \
  --location "$location" \
  --admin-user "$admin_user" \
  --admin-password "$SQL_PASSWORD"

# Create SQL Database
az sql db create \
  --resource-group "$rg" \
  --server "$server" \
  --name "$db_name" \
  --service-objective Basic
```

---

### 2️⃣ Configure Firewall Access

#### 🔹 Azure Portal
1. Navigate to your newly created **SQL Server** (e.g., `studentsqlserver12345`)
2. Select **Networking**
3. Click **Add client IP** → **Save**

#### 🔹 Azure CLI
```bash
# Replace <your_public_ip> with your actual public IP
az sql server firewall-rule create \
  --resource-group "$rg" \
  --server "$server" \
  --name allow-local-ip \
  --start-ip-address <your_public_ip> \
  --end-ip-address <your_public_ip>
```

💡 Find your public IP: [https://whatismyipaddress.com](https://whatismyipaddress.com)

> ⚠️ For demos, you can temporarily open full access (not recommended for production):
> ```bash
> az sql server firewall-rule create >   --resource-group "$rg" >   --server "$server" >   --name allow-all >   --start-ip-address 0.0.0.0 >   --end-ip-address 255.255.255.255
> ```
> ```bash
> az sql server firewall-rule create \
>   --resource-group "$rg" \
>   --server "$server" \
>   --name allow-all \
>   --start-ip-address 0.0.0.0 \
>   --end-ip-address 255.255.255.255
> ```

---

### 3️⃣ Connect to the SQL Database

#### 🐳 **Option 1: Docker (in GitHub Codespaces or Local)**
```bash
docker run -it --rm mcr.microsoft.com/mssql-tools \
  /opt/mssql-tools/bin/sqlcmd \
    -S "$server.database.windows.net" \
    -U "$admin_user" \
    -d "$db_name"
```

✅ You’ll be prompted for your password.

📌 (Automation only) Supply password inline:
```bash
docker run -it --rm mcr.microsoft.com/mssql-tools \
  /opt/mssql-tools/bin/sqlcmd \
    -S "$server.database.windows.net" \
    -U "$admin_user" \
    -P 'YourPassword' \
    -d "$db_name"
```

> ⚠️ Avoid storing passwords in scripts; use **Azure Key Vault** or **GitHub Secrets** in production.

---

#### 🧰 **Option 2: Azure Data Studio / SSMS**

1. Launch **Azure Data Studio** or **SQL Server Management Studio**  
2. Connect using:
   - **Server:** `<your-server-name>.database.windows.net`
   - **Authentication:** SQL Login  
   - **Username:** `sqladmin`  
   - **Password:** your secure password  
   - **Encrypt:** Yes → **Trust Server Certificate:** No  
3. Select the `studentdb` database once connected.

---

### 4️⃣ Validate Connection and Run Queries

Once connected, run the following commands to test:

**Check active database**
```sql
SELECT DB_NAME();
```

**Create a sample table**
```sql
CREATE TABLE students (
  id INT PRIMARY KEY,
  name NVARCHAR(100),
  enrolled_date DATE
);
```

**Insert a record**
```sql
INSERT INTO students (id, name, enrolled_date)
VALUES (1, 'Alice Smith', '2024-06-01');
```

**View table data**
```sql
SELECT * FROM students;
```

✅ You should see one record: *Alice Smith*.

---

### 5️⃣ (Optional) Clean Up Resources

When finished, delete all resources to avoid charges:

```bash
az group delete \
  --name sql-demo-rg \
  --yes \
  --no-wait
```

---

## 🧩 **Outcome**

Students have successfully:
- Created and configured an **Azure SQL Database**
- Managed firewall access
- Connected via **Docker**, **Cloud Shell**, and **Azure Data Studio**
- Executed SQL queries to validate deployment  
