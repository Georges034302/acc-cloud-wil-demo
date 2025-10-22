# 🧪 Lab 4-B – Deploy Two Microservices (HTTP Communication with Azure App Service)

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/09193f98-810f-4c3b-86d2-e059ea99cff4" />

## 🎯 Objective
Deploy two independent Python microservices — **Student Service (Service A)** and **Report Service (Service B)** — as separate Azure Web Apps.  
Each service maintains its own state and communicates securely using **HTTP/HTTPS**.

---

## 🧭 Prerequisites
- Azure CLI (≥ 2.60)
- Authenticated Azure session (`az login`)
- Python 3.11 + Flask installed locally (optional)
- Git installed
- [Azure Portal](https://portal.azure.com)
- **Registered App Service Provider (Microsoft.Web)**  
    ```bash
    az provider register \
        --namespace Microsoft.Web

    az provider show \
        --namespace Microsoft.Web \
        --query registrationState
    ```

---

## ⚙️ Step 1 – Define Variables
```bash
RG_NAME="microservice-demo-rg"
PLAN_NAME="microservice-plan"
LOCATION="australiaeast"
SKU="B1"
RUNTIME="PYTHON|3.11"

STUDENT_APP="studentservice$RANDOM"
REPORT_APP="reportservice$RANDOM"
```

---

## 🧱 Step 2 – Create Resource Group and App Service Plan
az appservice plan create   --name $PLAN_NAME   --resource-group $RG_NAME   --sku $SKU   --is-linux
```bash
az group create \
    --name $RG_NAME \
    --location $LOCATION

az appservice plan create \
    --name $PLAN_NAME \
    --resource-group $RG_NAME \
    --sku $SKU \
    --is-linux
```

---

## 🧩 Step 3 – Deploy Service A (Student Service)

### 3.1 – Create Local Folder and Files
```bash
mkdir studentservice
cd studentservice
```

**app.py**
```python
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/student/<id>')
def get_student(id):
    data = {"id": id, "name": "Ava", "major": "Computer Science"}
    return jsonify(data)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)
```

**requirements.txt**
```
flask
```

---

### 3.2 – Create Azure Web App
```bash
az webapp create \
    --resource-group $RG_NAME \
    --plan $PLAN_NAME \
    --name $STUDENT_APP \
    --runtime "$RUNTIME" \
    --deployment-local-git
```

---

### 3.3 – Deploy via Git
```bash
git init
git add .
git commit -m "Initial commit - Student Service"

# Set the local-git remote (use the URL printed by az webapp deployment source config-local-git)
git remote add azure \
    "https://<username>@$STUDENT_APP.scm.azurewebsites.net/$STUDENT_APP.git"

# Push the current branch to the app's master branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push azure "$BRANCH":master
```

✅ After deployment, test the service:  
`https://$STUDENT_APP.azurewebsites.net/student/101`  
Expected Output:  
```json
{"id": "101", "name": "Ava", "major": "Computer Science"}
```

---

## 🧠 Step 4 – Deploy Service B (Report Service)

### 4.1 – Create Local Folder and Files
```bash
cd ..
mkdir reportservice
cd reportservice
```

**app.py**
```python
import os
import requests
from flask import Flask

app = Flask(__name__)
STUDENT_SERVICE_APP = os.environ.get("STUDENT_SERVICE_APP")

@app.route('/report/<id>')
def get_report(id):
    url = f"https://{STUDENT_SERVICE_APP}.azurewebsites.net/student/{id}"
    r = requests.get(url)
    student = r.json()
    return f"Student {student['name']} is majoring in {student['major']}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)
```

**requirements.txt**
```
flask
requests
```

---

### 4.2 – Create Azure Web App
```bash
az webapp create \
    --resource-group $RG_NAME \
    --plan $PLAN_NAME \
    --name $REPORT_APP \
    --runtime "$RUNTIME" \
    --deployment-local-git
```

---

### 4.3 – Set Environment Variable for Inter-Service Communication
```bash
az webapp config appsettings set \
    --resource-group $RG_NAME \
    --name $REPORT_APP \
    --settings STUDENT_SERVICE_APP=$STUDENT_APP
```

---

### 4.4 – Deploy via Git
```bash
git init
git add .
git commit -m "Initial commit - Report Service"

git remote add azure \
    "https://<username>@$REPORT_APP.scm.azurewebsites.net/$REPORT_APP.git"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push azure "$BRANCH":master
```

---

## 🌐 Step 5 – Test Communication Between Services
Open in browser or use curl:  
```bash
curl \
    "https://$REPORT_APP.azurewebsites.net/report/101"
```

✅ Expected Output:  
```
Student Ava is majoring in Computer Science
```

---

## 🧰 Step 6 – Troubleshooting and Logs
If either service fails:
```bash
az webapp log tail \
    --name $STUDENT_APP \
    --resource-group $RG_NAME

az webapp log tail \
    --name $REPORT_APP \
    --resource-group $RG_NAME
```

Check:
- Both apps are **Running**
- Correct environment variable `STUDENT_SERVICE_APP` set
- Correct runtime (`PYTHON|3.11`)

---

## 🧼 Step 7 – Clean Up Resources (Optional)
```bash
az group delete \
    --name $RG_NAME \
    --yes \
    --no-wait
```

---

## ✅ Lab Summary

| Step | Description | Output |
|------|--------------|---------|
| 1 | Define variables | Service names and plan |
| 2 | Create RG + Plan | App Service Plan ready |
| 3 | Deploy Student Service | Independent Flask API |
| 4 | Deploy Report Service | Consumes Student API via HTTP |
| 5 | Test communication | Returns formatted report |
| 6 | Troubleshoot if needed | Use logs or portal |
| 7 | Clean up (optional) | Deletes resources |

---

### 🧩 Result
You have deployed:
- **Service A – Student Service:** Provides student data (API)  
- **Service B – Report Service:** Consumes Service A via HTTP  
Demonstrating **microservices with independent state and HTTP integration** using Azure App Service.
