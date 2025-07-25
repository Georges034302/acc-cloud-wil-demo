# Lab 1b: Create a Linux VM from CLI, SSH into It, and Install Apache HTTP Server

## 🎯 Objective
Provision a Linux Virtual Machine using Azure CLI, connect via SSH, and install Apache HTTP server.

---

## 📝 Instructions

### 1️⃣ Set Variables

```bash
RESOURCE_GROUP=linux-vm-demo-rg
VM_NAME=linux-vm-demo
LOCATION=australiaeast
```

### 2️⃣ Create Resource Group

```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### 3️⃣ Create Linux VM (Ubuntu)

```bash
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys
```

### 4️⃣ Open HTTP and SSH Ports

```bash
az vm open-port --resource-group $RESOURCE_GROUP --name $VM_NAME --port 22
az vm open-port --resource-group $RESOURCE_GROUP --name $VM_NAME --port 80
```

### 5️⃣ Get Public IP

```bash
az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME -d --query publicIps -o tsv
```

### 6️⃣ SSH into the VM

```bash
ssh azureuser@<public-ip>
```
*(Replace `<public-ip>` with the value from the previous step.)*

### 7️⃣ Install Apache HTTP Server

```bash
sudo apt-get update
sudo apt-get install -y apache2
```

### 8️⃣ Test Apache

```bash
curl http://localhost
```
Or, open `http://<public-ip>` in your browser.

---

✅ **You have successfully created a Linux VM, connected via SSH, and installed Apache!**