# 🧩 Demo Guide: Microservices with Independent State (HTTP Communication)

## 🎯 Objective

Deploy two microservices as independent Azure Web Apps. Each service manages its own data and communicates with the other via HTTP.

---

## 🧭 Prerequisites

- Azure CLI installed
- Azure Portal access
- Python 3.11
- Two Flask apps simulating microservices

---

## 👣 Step-by-Step Instructions (Azure Portal + CLI)

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

📄 `app.py`

```python
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/student/<id>')
def get_student(id):
    data = {"id": id, "name": "Ava", "major": "CS"}
    return jsonify(data)
```

📄 `requirements.txt`

```
flask
```

🔸 Deploy to Azure:

```bash
az webapp create \
  --resource-group microservice-demo-rg \
  --plan microservice-plan \
  --name studentservice123 \
  --runtime "PYTHON|3.11"
```

Deploy via Git/Zip.

---

### 3️⃣ Microservice B: Report Service (Calls A)

📄 `app.py`

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

📄 `requirements.txt`

```
flask
requests
```

🔸 Deploy to Azure:

```bash
az webapp create \
  --resource-group microservice-demo-rg \
  --plan microservice-plan \
  --name reportservice123 \
  --runtime "PYTHON|3.11"
```

Deploy via Git/Zip.

---

### 4️⃣ Test the Integration

- Visit: `https://reportservice123.azurewebsites.net/report/101`
- It should fetch data from Microservice A and return a report

---

## 🧼 Clean Up (Optional)

```bash
az group delete --name microservice-demo-rg --yes --no-wait
```

---

✅ **Demo complete – students have deployed two microservices with independent state and HTTP-based communication!**

