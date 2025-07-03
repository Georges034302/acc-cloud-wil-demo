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
- **[Recommended] Register the App Service provider (first-time users):**

  **Portal:**
  1. In the Azure Portal, search for **Subscriptions** and select your subscription.
  2. Under **Settings**, click **Resource providers**.
  3. Search for `Microsoft.Web`.
  4. Click **Register** if it is not already registered.

  **CLI:**
  Register with Miscroft.Web: *Azure Resource Provider that manages all web-based (PaaS) resources in Azure*
  ```bash
  az provider register --namespace Microsoft.Web
  ```
  Confirm the Registration:
  ```bash
  az provider show --namespace Microsoft.Web --query registrationState
  ```

---

### 🚀 Post-Service-Deployment Settings: Configuring Deployment Credentials for Azure Git Repos

After you create each web app in Azure (both microservices), you’ll use **local Git deployment**. To push your code, you must have Azure App Service deployment credentials set.

**Portal:**

- After creation, your new app (e.g., `studentservice-<unique>`, `reportservice-<unique>`) appears under **App Services** in the Azure Portal.
- The app’s **Status** will show as `Running`.
- The app’s **URL** (e.g., `https://studentservice-<unique>.azurewebsites.net`) will be displayed at the top of the overview page.

**CLI:**

- The Azure CLI will return a JSON output containing these important fields:
    ```json
    "defaultHostName": "<app-name>.azurewebsites.net",
    "deploymentLocalGitUrl": "https://<username>@<app-name>.scm.azurewebsites.net/<app-name>.git",
    ```
- **Copy the `deploymentLocalGitUrl` value** for each microservice—you’ll need this to set up your Git remote.

---

#### ⚠️ If Your Git Deployment URL Shows `None@`

If you see a URL like `https://None@<app-name>.scm.azurewebsites.net/<app-name>.git`, Azure CLI couldn’t detect your deployment username.  
**You must set App Service deployment credentials before pushing your code:**

**How to Set Your App Service Deployment Credentials:**

1. **In the Azure Portal:**
   - Go to **App Services** and select your web app.
   - In the left menu under **Deployment**, click **Deployment Center**.
   - Under the **Local Git/FTPS Credentials** tab, set a **username** and **password** (these are only for deployment, not your main Azure login).

2. **After setting your deployment credentials:**
   - Use the Git URL provided by Azure for your web app (even if it shows `None@`).
   - When you deploy your code with:
     ```bash
     git push azure main:master
     ```
     you will be prompted for a username and password.  
     **Enter the username and password you just set in the Portal.**

   - **Deployment URL format:**
     ```
     https://<your-username>@<app-name>.scm.azurewebsites.net/<app-name>.git
     ```
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

🗂️ **App structure:**
Create folder: studentservice with the correct file names
```
studentservice/
├── app.py
├── requirements.txt
```
CLI option:
```bash
mkdir studentservice
cd studentservice
touch app.py requirements.txt
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
STUDENT_SERVICE_APP=studentservice$RANDOM
az webapp create \
  --resource-group microservice-demo-rg \
  --plan microservice-plan \
  --name "$STUDENT_SERVICE_APP" \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```
Save the `deploymentLocalGitUrl` output from the command.

**Set Git Remote Deployment URL: (One Time Only Setup)**
```bash
cd studentservice
git init
git remote add azure https://<your-username>@"$STUDENT_SERVICE_APP".scm.azurewebsites.net/"$STUDENT_SERVICE_APP".git
```

**Deploy The service: (Reuse and deploy after every update to the service)**
```bash
git add .
git commit -m "Initial commit - Student Info Service"
git push azure main:master
```
Use your Azure App Service deployment credentials when prompted.  
Wait for deployment to complete.

### 🚦 Test the Student Info Service

### Test Student Service

Open this URL in your browser (replace with your app name):

`https://"$STUDENT_SERVICE_APP".azurewebsites.net/student/101`
### How It Works

When you visit `/student/101` in your browser, Flask runs the function with `id="101"`, creates a Python dictionary for the student, and returns it as a JSON response. The values are generated in the code—no database or file needed.

---

### 3️⃣ Microservice B: Report Service (Calls A)

Create folder: reportservice with the correct file names
```
reportservice/
├── app.py
├── requirements.txt
```
CLI option:
```bash
mkdir reportservice
cd reportservice
touch app.py requirements.txt
```

**app.py**
```python
import os

STUDENT_SERVICE_APP = os.environ.get("STUDENT_SERVICE_APP")

@app.route('/report/<id>')
def get_report(id):
    url = f"https://{STUDENT_SERVICE_APP}.azurewebsites.net/student/{id}"
    r = requests.get(url)
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
REPORT_SERVICE_APP=reportservice$RANDOM
az webapp create \
  --resource-group microservice-demo-rg \
  --plan microservice-plan \
  --name "$REPORT_SERVICE_APP" \
  --runtime "PYTHON|3.11" \
  --deployment-local-git
```
Save the `deploymentLocalGitUrl` output from the command.

**Set Git Remote Deployment URL: (One Time Only Setup)**
```bash
cd reportservice
git init
git remote add azure https://<your-username>@"$REPORT_SERVICE_APP".scm.azurewebsites.net/"$REPORT_SERVICE_APP".git
```

**Deploy The service: (Reuse and deploy after every update to the service)**
```bash
git add .
git commit -m "Initial commit - Report Service"
git push azure main:master
```
Use your Azure App Service deployment credentials when prompted.  
Wait for deployment to complete.

> **Note:**  
> You only need to set the `STUDENT_SERVICE_APP` environment variable **once per Report Service deployment** using this command:
> 
> ```bash
> az webapp config appsettings set \
>   --resource-group microservice-demo-rg \
>   --name "<your report service app name>"  \
>   --settings STUDENT_SERVICE_APP="<your student service app name>"
> ```
>
> This setting will persist through restarts and redeployments.
> Set it again only if you:
> - Change the Student Service app name,
> - Delete and recreate the Report Service,
> - Or want to point to a different Student Service instance.


---

### 4️⃣ Test the Integration

Visit:  
https://"$REPORT_SERVICE_APP".azurewebsites.net/report/101

**Expected output:**
```
Student Ava is majoring in CS
```

---

### 5️⃣ Troubleshooting & Tips

- If you get a timeout or error:
    - Confirm both web apps are deployed and running in Azure Portal under "App Services".
    - Test Microservice A directly at:  
      https://"$STUDENT_SERVICE_APP".azurewebsites.net/student/101
    - Check your `requirements.txt` for typos and ensure both services have the correct packages.
    - Use Azure logs for debugging:
      ```bash
      az webapp log tail --name "$STUDENT_SERVICE_APP" --resource-group microservice-demo-rg
      az webapp log tail --name "$REPORT_SERVICE_APP" --resource-group microservice-demo-rg
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

