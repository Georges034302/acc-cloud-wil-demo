# ☸️ Lab 6-C: Deploy a Scalable App Using Azure Kubernetes Service (AKS)

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/10f764d3-26d1-446e-8e8b-d25652c2a018" />

## 🎯 Objective
Provision an **Azure Kubernetes Service (AKS)** cluster, deploy a sample containerized application, and scale it manually and automatically using Azure CLI, Portal, and Infrastructure as Code (ARM).

---

## 1️⃣ Create Resource Group and AKS Cluster

```bash
# Set location, resource group, and AKS cluster name variables
LOCATION="australiaeast"
RG="aks-lab-rg"
AKSNAME="aks-demo-cluster"
```

```bash
# Create the resource group in Azure
az group create --name $RG --location $LOCATION
```

```bash
# Create the AKS cluster with monitoring enabled and 2 nodes
az aks create \
  --resource-group $RG \
  --name $AKSNAME \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys
```

### 🔹 Portal Method (Optional)

1. Go to **Azure Portal → Kubernetes Services → + Create**
2. **Basics:**
   - Resource Group: `aks-lab-rg`
   - Cluster name: `aks-demo-cluster`
   - Region: `Australia East`
   - Node size: `Standard_B2s`
   - Node count: `2`
3. **Monitoring:** Enable Container Insights  
4. **Review + Create → Create**

### 🔹 ARM Template Method (Optional)

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

### Deploy using CLI:

```bash
# Deploy the AKS cluster using the ARM template
az deployment group create \
  --template-file aks-arm.json
```

---

## 2️⃣ Connect to AKS Cluster

```bash
# Connect your local kubectl to the AKS cluster
az aks get-credentials \
  --resource-group $RG \
  --name $AKSNAME
```

```bash
# Verify connection to AKS cluster
kubectl get nodes
```

---

## 3️⃣ Deploy the Sample Application

```bash
# Deploy a sample Nginx application
kubectl create deployment webdemo --image=nginx
kubectl expose deployment webdemo --port=80 --type=LoadBalancer
```

```bash
# Check the service status and get external IP
kubectl get svc webdemo
```

---

## 4️⃣ Test the Sample Application
```bash
# Get the external IP address of the Nginx service dynamically
EXTERNAL_IP=$(kubectl get svc webdemo --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Nginx External IP: $EXTERNAL_IP"

# Open the Nginx welcome page in your browser (Linux)
if [ -n "$EXTERNAL_IP" ]; then
  "$BROWSER" "http://$EXTERNAL_IP"
else
  echo "External IP not assigned yet. Please check again in a few moments."
fi
```

---

## 5️⃣ Scale the Application

### 🔹 Manual Scaling (via CLI)

```bash
# Manually scale the webdemo deployment to 4 replicas
kubectl scale deployment webdemo --replicas=4
kubectl get pods -o wide
```

> You should now see **4 replicas** of the webdemo pods.

### 🔹 Autoscaling (via CLI)

```bash
# Enable cluster autoscaler for AKS
az aks update \
  --resource-group $RG \
  --name $AKSNAME \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5
```

```bash
# Create a Horizontal Pod Autoscaler (HPA) for webdemo
kubectl autoscale deployment webdemo \
  --cpu-percent=50 \
  --min=2 \
  --max=5
```

```bash
# View autoscaler status
kubectl get hpa
```

---

## 6️⃣ Monitor the Cluster (Portal)

1. Navigate to **Azure Portal → Monitor → Insights → Containers**
2. Review metrics:
   - Node CPU & memory usage
   - Pod count and scaling activity
   - LoadBalancer and request throughput

---

## 🧹 Clean Up Resources

```bash
# Delete the resource group and all resources
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


---
