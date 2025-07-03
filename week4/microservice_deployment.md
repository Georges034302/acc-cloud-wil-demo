# 🧩 Microservices with Independent State and HTTP Communication

## 🎯 Objective

Deploy two independent Python microservices as separate Azure Web Apps.  
Each service manages its own state and communicates with the other via HTTP requests.

---

## 🧭 Prerequisites

- Azure Portal access ([https://portal.azure.com](https://portal.azure.com))
- Azure CLI installed and authenticated (`az login`)
- Python 3.11+
- Git installed
- Codespaces or local dev environment

---

## 👣 Step-by-Step Instructions

### 1️⃣ Create Resource Group and App Service Plan

```bash
az group create --name microservice-demo-rg --location australiaeast

az appservice plan create \
  --name microservice-plan \
  --resource-group microservice-demo-rg \
  --sku B1 \
  --is-linux
```

---

### 2️⃣ Microservice A: Student Info Service

**App structure:**
```
studentservice/
├── app.py
├── requirements.txt
```

**app.py**
```python
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/student/<id>')
def get_student(id):
    data = {"id": id, "name": "Ava", "major": "CS"}
    return jsonify(data)
```

**requirements.txt**
```
flask
```

**Deploy to Azure:**
```bash
az webapp create \
  --resource-group microservice-demo-rg \
  --plan microservice-plan \
  --name studentservice123 \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```
Save the `deploymentLocalGitUrl` output from the command.

**Deploy code via Git:**
```bash
cd studentservice
git init
git remote add azure https://<your-username>@studentservice123.scm.azurewebsites.net/studentservice123.git
git add .
git commit -m "Initial commit - Student Info Service"
git push azure main:master
```
Use your Azure App Service deployment credentials when prompted.  
Wait for deployment to complete.

---

### 3️⃣ Microservice B: Report Service (Calls A)

**App structure:**
```
reportservice/
├── app.py
├── requirements.txt
```

**app.py**
```python
from flask import Flask
import requests
app = Flask(__name__)

@app.route('/report/<id>')
def get_report(id):
    r = requests.get(f"https://studentservice123.azurewebsites.net/student/{id}")
    student = r.json()
    return f"Student {student['name']} is majoring in {student['major']}"
```

**requirements.txt**
```
flask
requests
```

**Deploy to Azure:**
```bash
az webapp create \
  --resource-group microservice-demo-rg \
  --plan microservice-plan \
  --name reportservice123 \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```
Save the `deploymentLocalGitUrl` output from the command.

**Deploy code via Git:**
```bash
cd reportservice
git init
git remote add azure https://<your-username>@reportservice123.scm.azurewebsites.net/reportservice123.git
git add .
git commit -m "Initial commit - Report Service"
git push azure main:master
```
Use your Azure App Service deployment credentials when prompted.  
Wait for deployment to complete.

---

### 4️⃣ Test the Integration

Visit:  
https://reportservice123.azurewebsites.net/report/101

**Expected output:**
```
Student Ava is majoring in CS
```

---

### 5️⃣ Troubleshooting & Tips

- If you get a timeout or error:
    - Confirm both web apps are deployed and running in Azure Portal under "App Services".
    - Test Microservice A directly at:  
      https://studentservice123.azurewebsites.net/student/101
    - Check your `requirements.txt` for typos and ensure both services have the correct packages.
    - Use Azure logs for debugging:
      ```bash
      az webapp log tail --name studentservice123 --resource-group microservice-demo-rg
      az webapp log tail --name reportservice123 --resource-group microservice-demo-rg
      ```
    - Initial deployments may take 1–2 minutes to become responsive.

---

### 6️⃣ Clean Up Resources (Optional)

```bash
az group delete --name microservice-demo-rg --yes --no-wait
```
This deletes all resources created in this lab.

---

## ✅ Lab Complete!

You have:
- Deployed two independent Python microservices to Azure App Service
- Enabled one service to call the other over HTTP
- Validated microservices architecture with independent state and HTTP communication

---

