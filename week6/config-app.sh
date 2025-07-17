RESOURCE_GROUP="student-rg"
LOCATION="australiaeast"
STORAGE_NAME="studentappstorage2025"
FUNCTION_APP="student-app"
CONTAINER_NAME="student-files"

echo "🚀 Starting Azure resource group creation..."
az group create --name $RESOURCE_GROUP --location $LOCATION
echo "⏳ Waiting 10 seconds for resource group propagation..."
sleep 10
echo "✅ Resource group created and propagation wait complete."

echo "🚀 Creating Azure storage account..."
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2
echo "✅ Storage account created."

echo "🚀 Creating Blob container '$CONTAINER_NAME'..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_NAME
echo "✅ Blob container '$CONTAINER_NAME' created."

echo "🚀 Creating Azure Function App..."
az functionapp create \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $LOCATION \
  --name $FUNCTION_APP \
  --storage-account $STORAGE_NAME \
  --runtime node \
  --runtime-version 22 \
  --functions-version 4 \
  --os-type Windows
echo "✅ Azure Function App created."