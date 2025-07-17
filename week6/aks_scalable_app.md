# ☸️ Demo 2 Guide: Deploy a Scalable App Using Azure Kubernetes Service (AKS)

## 🎯 Objective

Provision an AKS cluster, deploy a sample app, and scale it using Azure CLI, Portal, and ARM templates.

---

## 🧭 Prerequisites

- Azure CLI installed and logged in
- Docker and `kubectl` installed
- A sample container image (e.g., from Docker Hub or ACR)

---

## 👣 Step-by-Step Instructions (CLI + Portal + ARM)

### 1️⃣ Create Resource Group and AKS Cluster

🔸 **CLI:**

```bash
az group create --name aks-demo-rg --location australiaeast

az aks create \
  --resource-group aks-demo-rg \
  --name aks-demo-cluster \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys
```

🔸 **Portal:**

1. Go to **Kubernetes Services** → **+ Create**
2. Resource Group: `aks-demo-rg`
3. Cluster name: `aks-demo-cluster`
4. Region: `Australia East`
5. Node size: Standard B2s → Node count: 2
6. Enable monitoring → Create

🔸 **ARM Template Deployment:** Save `aks-arm.json` and deploy:

```bash
az deployment group create \
  --resource-group aks-demo-rg \
  --template-file aks-arm.json
```

---

### 2️⃣ Connect to AKS and Deploy App

🔸 **CLI:**

```bash
az aks get-credentials \
  --resource-group aks-demo-rg \
  --name aks-demo-cluster
```

Create a simple deployment (e.g., with nginx):

```bash
kubectl create deployment webdemo --image=nginx
kubectl expose deployment webdemo --port=80 --type=LoadBalancer
```

Check status:

```bash
kubectl get svc
```

✅ Copy the `EXTERNAL-IP` and open in browser.

---

### 3️⃣ Scale the App

🔸 **CLI – Manual Scaling:**

```bash
kubectl scale deployment webdemo --replicas=4
```

🔸 **CLI – Enable Autoscaler:**

```bash
az aks update \
  --resource-group aks-demo-rg \
  --name aks-demo-cluster \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5
```

---

### 4️⃣ Clean Up

```bash
az group delete --name aks-demo-rg --yes --no-wait
```

✅ **Demo complete – students deployed and scaled a containerized app using AKS via CLI, Portal, and ARM.**

