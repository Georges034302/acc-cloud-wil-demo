# 🧪 Lab 4-B – Deploy Two Microservices (HTTP Communication with Azure App Service)

<img width="1024" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/5ab9979c-b072-41fb-aed4-551ce9482b48" />


## 🎯 Objective
Deploy two independent Python microservices — **Student Service (A)** and **Report Service (B)** — as separate Azure Web Apps sharing one App Service Plan.  
Each service runs its own Flask API and communicates via HTTPS.

---

## 🧭 Prerequisites
- Azure CLI ≥ 2.60  
- Logged in (`az login`) and subscription set  
- Python 3.11 + Flask (optional local test)  
- ZIP utility (`zip`)  
- [Azure Portal](https://portal.azure.com)

Ensure the provider is registered:
```bash
az provider register \
    --namespace Microsoft.Web

az provider show \
    --namespace Microsoft.Web \
    --query registrationState
```

---

## ⚙️ Step 1 – Define Variables


Set the following variables in your shell and store them into a `.env` file:
```bash
RG_NAME="microservice-demo-rg"
PLAN_NAME="microservice-plan25921"
LOCATION="australiaeast"
SKU="B1"
RUNTIME="PYTHON|3.11"
STUDENT_APP="studentservice$RANDOM"
REPORT_APP="reportservice$RANDOM"

cat <<EOF > .env
RG_NAME="$RG_NAME"
PLAN_NAME="$PLAN_NAME"
LOCATION="$LOCATION"
SKU="$SKU"
RUNTIME="$RUNTIME"
STUDENT_APP="$STUDENT_APP"
REPORT_APP="$REPORT_APP"
EOF
```

Then load the variables in your shell before running commands:
```bash
set -a
source .env
set +a
```

---

## 🧱 Step 2 – Create Resource Group and App Service Plan

### 2.1 – Create Resource Group
```bash
az group create \
    --name $RG_NAME \
    --location $LOCATION
```

### 2.2 – Create App Service Plan
```bash
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
mkdir studentservice && cd studentservice
```

**app.py**
```python
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def home():
    return "Student Service is running!"

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
    --runtime "$RUNTIME"
```

---

### 3.3 – Deploy via ZIP
```bash
# Package the app
cd studentservice
zip -r ../studentservice-deploy.zip .

# Upload ZIP to App Service
az webapp deploy \
    --resource-group "$RG_NAME" \
    --name "$STUDENT_APP" \
    --src-path ../studentservice-deploy.zip \
    --type zip

# Restart the student serivce
az webapp restart --name "$STUDENT_APP" --resource-group "$RG_NAME"

# Optional cleanup
rm ../studentservice-deploy.zip || true
```

---

## 🧠 Step 4 – Deploy Service B (Report Service)

### 4.1 – Create Local Folder and Files
```bash
cd ..
mkdir reportservice && cd reportservice
```

**app.py**
```python
import os, requests
from flask import Flask
app = Flask(__name__)

STUDENT_SERVICE_APP = os.environ.get("STUDENT_SERVICE_APP")

@app.route('/')
def home():
    return "Report Service is running!"

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
    --runtime "$RUNTIME"
```

---

### 4.3 – Configure Environment Variable
```bash
# Set the STUDENT_SERVICE_APP environment variable for the Report Service
az webapp config appsettings set \
    --resource-group $RG_NAME \
    --name $REPORT_APP \
    --settings STUDENT_SERVICE_APP=$STUDENT_APP

# Set the PYTHONPATH environment variable for the Report Service app.
# This tells Python where to look for additional packages, including those installed in the App Service's .python_packages directory.
az webapp config appsettings set \
  --resource-group "$RG_NAME" \  # Resource group containing the web app
  --name "$REPORT_APP" \         # Name of the Report Service web app
  --settings PYTHONPATH="/home/site/wwwroot/.python_packages/lib/site-packages"  # Path to extra Python packages
```

---

### 4.4 – Deploy via ZIP
```bash
# Package the app
cd reportservice
zip -r ../reportservice-deploy.zip .

# Upload ZIP to App Service
az webapp deploy \
    --resource-group "$RG_NAME" \
    --name "$REPORT_APP" \
    --src-path ../reportservice-deploy.zip \
    --type zip

# Restart the report service
az webapp restart --name "$REPORT_APP" --resource-group "$RG_NAME"

# Optional cleanup
rm ../reportservice-deploy.zip || true
```

---

## 🌐 Step 5 – Test Inter-Service Communication
Once both are deployed:
```bash
# Simple request to the report endpoint
curl \
    "https://$REPORT_APP.azurewebsites.net/report/101"

# Open the Report App in the host browser (useful in dev containers)
"$BROWSER" "https://$REPORT_APP.azurewebsites.net/report/101" || true
```

✅ Expected:
```
Student Ava is majoring in Computer Science
```

---

## 🧰 Step 6 – Troubleshooting and Logs
```bash
az webapp log tail \
    --name $STUDENT_APP \
    --resource-group $RG_NAME

az webapp log tail \
    --name $REPORT_APP \
    --resource-group $RG_NAME
```

Verify:
- Both apps **Running**
- App setting `STUDENT_SERVICE_APP` is correct
- Runtime = `PYTHON|3.11`

---

## 🧼 Step 7 – Clean Up (Optional)
```bash
az group delete \
    --name $RG_NAME \
    --yes \
    --no-wait
```

---

## ✅ Lab Summary

| Step | Description | Result |
|------|--------------|---------|
| 1 |Define variables |Service names & plan set |
| 2 |Create RG + plan |Shared App Service Plan ready |
| 3 |Deploy Student Service |Flask API providing student data |
| 4 |Deploy Report Service |Consumes Student API over HTTPS |
| 5 |Test communication |Returns formatted student report |
| 6 |Troubleshoot |Logs via CLI |
| 7 |Clean up |Deletes resources |

---

### 🧩 Result
Two Python Flask microservices are deployed under one App Service Plan using **ZIP deployment**, demonstrating **secure HTTP communication** between independent services hosted on Azure App Service.
