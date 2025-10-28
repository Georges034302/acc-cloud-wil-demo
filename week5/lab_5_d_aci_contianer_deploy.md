# ⚙️ Lab 5-D: Deploy the Container to Azure Container Instances (ACI)

## 🎯 Objective
Deploy the **Joke API** container image from **Azure Container Registry (ACR)** to **Azure Container Instances (ACI)**.  
This lab demonstrates how to run a serverless container without managing infrastructure.

---


## 🧭 Prerequisites
- Azure CLI installed and logged in (`az login`)
- Docker installed and running

---

## ⚙️ Step-by-Step Instructions (CLI + Portal)

### 1️⃣ Set Variables
```bash
RG_NAME="aci-demo-rg"
LOCATION="australiaeast"
ACR_NAME="acidemoacr$RANDOM"
ACI_NAME="jokeapi-aci"
DNS_LABEL="jokeapi$(openssl rand -hex 2)"
IMAGE_NAME="webapp:v1"
WEBAPP_DIR="webapp"
```

### 2️⃣ Create Resource Group
```bash
az group create \
	--name "$RG_NAME" \
	--location "$LOCATION"
```
---

### 3️⃣ Create Azure Container Registry (ACR)
```bash
az acr create \
	--resource-group "$RG_NAME" \
	--name "$ACR_NAME" \
	--sku Basic \
	--admin-enabled true
```
---

### 4️⃣ Create Joke API App Files

**Create the directory and files:**
```bash
mkdir -p "$WEBAPP_DIR"
touch "$WEBAPP_DIR/app.py" "$WEBAPP_DIR/requirements.txt" "$WEBAPP_DIR/Dockerfile"
```

**Then add the following content to each file:**

#### `app.py`
```python
from flask import Flask, jsonify
import random

app = Flask(__name__)

jokes = [
	"Why don’t developers like nature? It has too many bugs.",
	"Why did the developer go broke? Because he used up all his cache.",
	"Why do programmers prefer dark mode? Because light attracts bugs.",
	"What is a programmer’s favorite hangout place? The Foo Bar."
]

@app.route("/jokes")
def get_jokes():
	return jsonify({"jokes": jokes})

@app.route("/joke")
def get_joke():
	return jsonify({"joke": random.choice(jokes)})

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

####  Verify ACR Image Exists
```bash
az acr repository list \
	--name "$ACR_NAME" \
	--output table
```
You should see your image `$IMAGE_NAME` in the list.

---

### 5️⃣ Create Azure Container Instance (ACI)
Deploy the image from ACR into a lightweight container instance.

```bash
az container create \
	--resource-group "$RG_NAME" \
	--name "$ACI_NAME" \
	--image $ACR_NAME.azurecr.io/$IMAGE_NAME \
	--cpu 1 \
	--memory 1 \
	--registry-login-server $ACR_NAME.azurecr.io \
	--registry-username $(az acr credential show --name $ACR_NAME --query username -o tsv) \
	--registry-password $(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv) \
	--ports 80 \
	--dns-name-label "$DNS_LABEL" \
	--location "$LOCATION"
```
✅ This will create a publicly accessible endpoint like:
`https://$DNS_LABEL.$LOCATION.azurecontainer.io`


####  Verify Deployment
Check the container status:

```bash
az container show \
	--name "$ACI_NAME" \
	--resource-group "$RG_NAME" \
	--query "{Status:instanceView.state, IP:ipAddress.fqdn}" \
	--output table
```
Once `Status` = **Running**, open the FQDN in your browser.

---

### 6️⃣ Test the API Routes
Use your browser or `curl`:

```bash
"$BROWSER" "https://$DNS_LABEL.$LOCATION.azurecontainer.io/joke"
"$BROWSER" "https://$DNS_LABEL.$LOCATION.azurecontainer.io/jokes"
```
✅ You should see JSON responses from your containerized Joke API.

#### View Logs
Inspect logs to verify successful container startup and requests:

```bash
az container logs \
	--name "$ACI_NAME" \
	--resource-group "$RG_NAME"
```

---

### 7️⃣ Clean Up Resources
```bash
az group delete \
	--name "$RG_NAME" \
	--yes \
	--no-wait
```

---

✅ **Lab Complete** – You successfully built and pushed a container image, deployed it to Azure Container Instances, tested endpoints, viewed logs, and learned how to manage lightweight, serverless containers on Azure.

---
