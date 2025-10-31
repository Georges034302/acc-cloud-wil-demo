# ☸️ Lab 6-C: Deploy a Scalable App Using Azure Kubernetes Service (AKS)

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/10f764d3-26d1-446e-8e8b-d25652c2a018" />

## 🎯 Objective
Provision an **Azure Kubernetes Service (AKS)** cluster, deploy a sample containerized application, and scale it manually and automatically using Azure CLI, Portal, and Infrastructure as Code (ARM).

---

## ⏱ Estimated Duration
**60–75 minutes**

---

## 🧭 Prerequisites
- Azure subscription with Owner or Contributor role  
- Azure CLI installed and logged in (`az login`)  
- Docker and `kubectl` installed  
- Optional: Visual Studio Code with Kubernetes extension

---

## 1️⃣ Create Resource Group and AKS Cluster

### 🔹 CLI Method

```bash
LOCATION="australiaeast"
RG="aks-lab-rg"
AKSNAME="aks-demo-cluster"

az group create --name $RG --location $LOCATION

az aks create \
  --resource-group $RG \
  --name $AKSNAME \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys
```

### 🔹 Portal Method

1. Go to **Azure Portal → Kubernetes Services → + Create**
2. **Basics:**
   - Resource Group: `aks-lab-rg`
   - Cluster name: `aks-demo-cluster`
   - Region: `Australia East`
   - Node size: `Standard_B2s`
   - Node count: `2`
3. **Monitoring:** Enable Container Insights  
4. **Review + Create → Create**

### 🔹 ARM Template Method

Save the following as `aks-arm.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2023-01-01",
      "name": "aks-demo-cluster",
      "location": "australiaeast",
      "properties": {
        "dnsPrefix": "aksdemo",
        "agentPoolProfiles": [
          {
            "name": "nodepool1",
            "count": 2,
            "vmSize": "Standard_B2s",
            "osType": "Linux"
          }
        ],
        "enableRBAC": true
      }
    }
  ]
}
```

Deploy using CLI:

```bash
az deployment group create \
  --resource-group $RG \
  --template-file aks-arm.json
```

---

## 2️⃣ Connect to AKS Cluster

```bash
az aks get-credentials \
  --resource-group $RG \
  --name $AKSNAME
```

Verify connection:

```bash
kubectl get nodes
```

---

## 3️⃣ Deploy the Sample Application

Deploy a simple Nginx app:

```bash
kubectl create deployment webdemo --image=nginx
kubectl expose deployment webdemo --port=80 --type=LoadBalancer
```

Check the service status:

```bash
kubectl get svc webdemo
```

Once the `EXTERNAL-IP` is assigned, open it in a web browser to confirm the Nginx welcome page.

---

## 4️⃣ Scale the Application

### 🔹 Manual Scaling (via CLI)

```bash
kubectl scale deployment webdemo --replicas=4
kubectl get pods -o wide
```

You should now see **4 replicas** of the webdemo pods.

### 🔹 Autoscaling (via CLI)

Enable AKS autoscaler at the cluster level:

```bash
az aks update \
  --resource-group $RG \
  --name $AKSNAME \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5
```

Create a Horizontal Pod Autoscaler (HPA):

```bash
kubectl autoscale deployment webdemo \
  --cpu-percent=50 \
  --min=2 \
  --max=5
```

View autoscaler status:

```bash
kubectl get hpa
```

---

## 5️⃣ Monitor the Cluster (Portal)

1. Navigate to **Azure Portal → Monitor → Insights → Containers**
2. Review metrics:
   - Node CPU & memory usage
   - Pod count and scaling activity
   - LoadBalancer and request throughput

---

## 6️⃣ Clean Up Resources

```bash
az group delete --name $RG --yes --no-wait
```

---

## ✅ Success Criteria

| Verification Step | Expected Result |
|--------------------|------------------|
| Resource group and AKS cluster created | ✅ |
| Nginx app deployed and reachable via LoadBalancer | ✅ |
| Manual scaling to 4 replicas successful | ✅ |
| Cluster autoscaler and HPA operational | ✅ |
| All resources cleaned up at the end | ✅ |

---

## 🧩 Optional Enhancements

- Replace Nginx with a custom container from **Azure Container Registry (ACR)**.  
- Integrate Azure Monitor to view scaling behavior.  
- Automate AKS deployment via **Bicep** instead of ARM.  
- Implement PodDisruptionBudget for better resilience during scale events.

