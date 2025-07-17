# 🚀 Demo 1: Project Setup Guide — Student CSV Processor (Azure Function App)

This guide will help you set up, configure, and deploy the Student CSV Processor Azure Function App from scratch.

---

## 1. Prerequisites

- **Azure Subscription**
- **Node.js 18 or later**
- **Azure Functions Core Tools v4**
  ```bash
  npm i -g azure-functions-core-tools@4 --unsafe-perm true
  func --version  # Should start with 4.x
  ```
- **Azure CLI** (for resource provisioning)
- **Bash** (for running setup scripts)

---

## 2. Clone the Repository

```bash
git clone <repo-url>
cd az-function-app-nodejs
```

---

## 3. Install Dependencies

```bash
cd student-app
npm install
npm install @azure/data-tables csv-parse uuid
```

---

## 4. Configure Azure Resources

Provision all required Azure resources (resource group, storage account, blob container, function app) using the provided script:

```bash
bash config-app.sh
```

This script will:
- Create a resource group
- Create a storage account and blob container
- Create a Function App

---

## 5. Assign Required Roles

Ensure your user/service principal has the following roles on the storage account:
- `Storage Blob Data Contributor`
- `Storage Table Data Contributor`

Example (replace placeholders):

```bash
az role assignment create --assignee <your-user-object-id> \
    --role "Storage Table Data Contributor" \
    --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>"
```

---

## 6. Deploy the Function App

From the `student-app` directory, publish your function to Azure:

```bash
func azure functionapp publish student-app --javascript
```

Replace `student-app` with your actual Azure Function App name if different.

---

## 7. Test the Function

Upload a sample CSV `students.csv` to the blob container using the provided script:

```bash
bash upload.sh
```

Monitor logs:

```bash
func azure functionapp log-stream student-app
```

---

## 8. Notes

- The function is triggered by CSV uploads to the `student-files` container.
- Each student record is parsed and inserted into the `StudentGrades` table in Azure Table Storage.
- Configuration values (like connection strings) are managed in `local.settings.json` for local development.

---

## 📄 Reference

- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [@azure/data-tables](https://www.npmjs.com/package/@azure/data-tables)
- [csv-parse](https://www.npmjs.com/package/csv-parse)