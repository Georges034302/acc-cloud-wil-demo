# ☸️ Lab 5-E: Deploy a Containerized API to Azure Container Apps (ACA)

## 🎯 Objective
Deploy a cool **Joke API** container image from scratch to **Azure Container Apps (ACA)**. This lab will guide you through creating all resources, building your app, and deploying it on a scalable, serverless platform.

---

## 🧭 Prerequisites
- Azure CLI installed and logged in (`az login`)
- Docker installed and running
- Azure subscription access
- Azure CLI **Container Apps** extension installed:
  ```bash
  az extension add --name containerapp --upgrade
  ```
- Register required Azure providers:
  ```bash
  az provider register \
      --namespace Microsoft.App

  az provider register \
      --namespace Microsoft.OperationalInsights
  ```

---

## ⚙️ Step-by-Step Instructions (Fully Parameterized)

### 1️⃣ Set Variables
```bash
RG_NAME="aca-demo-rg"
LOCATION="australiaeast"
ACR_NAME="acajokesacr$RANDOM"
ACA_ENV="jokeapi-env$RANDOM"
ACA_APP="jokeapi-app$RANDOM"
LOG_WS="jokeapi-logs"
IMAGE_NAME="webapp:v1"
WEBAPP_DIR="webapp"
```

### 2️⃣ Create Resource Group
```bash
az group create \
    --name "$RG_NAME" \
    --location "$LOCATION"
```

### 3️⃣ Create Azure Container Registry (ACR)
```bash
az acr create \
    --resource-group "$RG_NAME" \
    --name "$ACR_NAME" \
    --sku Basic \
    --admin-enabled true
```

### 4️⃣ Create Joke API App Files
```bash
mkdir -p "$WEBAPP_DIR"
touch "$WEBAPP_DIR/app.py" "$WEBAPP_DIR/requirements.txt" "$WEBAPP_DIR/Dockerfile"
```

Add the following content to each file:

#### `app.py` (Simple & Cool Joke API)
```python
from flask import Flask, jsonify, request
import random

app = Flask(__name__)

jokes = [
    "Why do Java developers wear glasses? Because they don't C#.",
    "Why did the computer show up at work late? It had a hard drive.",
    "Why do programmers hate nature? It has too many bugs.",
    "Why did the developer go broke? Because he used up all his cache.",
    "Why do Python devs love snakes? Because they love to import them!"
]

@app.route("/jokes", methods=["GET"])
def get_jokes():
    return jsonify({"jokes": jokes, "count": len(jokes)})

@app.route("/joke", methods=["GET"])
def get_joke():
    return jsonify({"joke": random.choice(jokes)})

@app.route("/")
def home():
    return "<h2>Welcome to the Cool Joke API! Try /joke or /jokes</h2>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

#### `requirements.txt`
```
flask
```

#### `Dockerfile`
```Dockerfile
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 80
CMD ["python", "app.py"]
```

---

### 5️⃣ Build and Push Docker Image
```bash
docker build -t $IMAGE_NAME $WEBAPP_DIR
docker tag $IMAGE_NAME $ACR_NAME.azurecr.io/$IMAGE_NAME
az acr login --name "$ACR_NAME"
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME
```

#### Verify ACR Image Exists
```bash
az acr repository list \
    --name "$ACR_NAME" \
    --output table
```

---

### 6️⃣ Create Log Analytics Workspace
```bash
az monitor.log-analytics workspace create \
    --resource-group "$RG_NAME" \
    --workspace-name "$LOG_WS" \
    --location "$LOCATION"
```
Retrieve the workspace ID:
```bash
LOG_ID=$(az monitor log-analytics workspace show \
    --resource-group "$RG_NAME" \
    --workspace-name "$LOG_WS" \
    --query customerId -o tsv)
```

---

### 7️⃣ Create Container Apps Environment
```bash
az containerapp env create \
    --name "$ACA_ENV" \
    --resource-group "$RG_NAME" \
    --logs-workspace-id $LOG_ID \
    --location "$LOCATION"
```

---

### 8️⃣ Deploy the Container App
```bash
az containerapp create \
    --name "$ACA_APP" \
    --resource-group "$RG_NAME" \
    --environment "$ACA_ENV" \
    --image $ACR_NAME.azurecr.io/$IMAGE_NAME \
    --target-port 80 \
    --ingress external \
    --registry-server $ACR_NAME.azurecr.io \
    --registry-username $(az acr credential show --name $ACR_NAME --query username -o tsv) \
    --registry-password $(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)
```
✅ This command deploys your container image to ACA and exposes a public endpoint.

---

### 9️⃣ Verify Deployment
Check status and get the public URL:
```bash
az containerapp show \
    --name "$ACA_APP" \
    --resource-group "$RG_NAME" \
    --query properties.configuration.ingress.fqdn \
    -o tsv
```
Visit the URL in your browser (e.g., `https://$ACA_APP.$LOCATION.azurecontainerapps.io`).

---

### 🔟 Test the API Routes
Use your browser to test routes:
```bash
# Get a Random Joke
"$BROWSER" "https://$ACA_APP.$LOCATION.azurecontainerapps.io/joke"

# Get all Jokes
"$BROWSER" "https://$ACA_APP.$LOCATION.azurecontainerapps.io/jokes"
```
✅ You should see JSON responses from your containerized Joke API.

---

### 1️⃣1️⃣ (Optional) Configure Autoscaling
Add autoscaling based on concurrent requests:
```bash
az containerapp update \
    --name "$ACA_APP" \
    --resource-group "$RG_NAME" \
    --scale-rule-name http-rule \
    --scale-rule-type http \
    --scale-rule-metadata concurrentRequests=5 \
    --min-replicas 1 \
    --max-replicas 5
```
✅ ACA will now automatically scale out/in based on load.

---

### 🧼 Clean Up Resources
```bash
az group delete \
    --name "$RG_NAME" \
    --yes \
    --no-wait
```

---

✅ **Lab Complete** – You successfully built a cool containerized API from scratch, deployed it to Azure Container Apps, validated routes, and configured autoscaling on a modern, serverless Kubernetes-backed platform.
