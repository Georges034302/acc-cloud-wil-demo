# Lab 1_b: Create a Linux VM Using Azure CLI and Configure Apache HTTP Server

<img width="1536" height="1024" alt="Lab_1_b" src="https://github.com/user-attachments/assets/946d8abb-965c-4af2-8dda-580d4dad547d" />

---
## 🎯 Objective
Provision a Linux Virtual Machine using Azure CLI with password authentication, connect via SSH, and install Apache HTTP server.

---

## 📝 Requirements
- An active Azure subscription  
- Azure CLI installed and logged in (`az login`)  
- SSH client available (Linux/macOS: built-in, Windows: PowerShell or PuTTY/Microsoft Terminal)  

---

## 🚀 Step 1: Set Variables

Open your terminal and set environment variables:

```bash
RESOURCE_GROUP=linux-vm-demo-rg
VM_NAME=linux-vm-demo
LOCATION=australiaeast
ADMIN_USERNAME=azureuser
```

---

## 🚀 Step 2: Create Resource Group

```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

---

## 🚀 Step 3: Create Linux VM 


Run the following command. You will be prompted securely to enter a password for the VM admin account:

```bash
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --admin-username $ADMIN_USERNAME \
  --authentication-type password \
  --size Standard_B2s
```

👉 Notes:
- `--authentication-type password` disables SSH key authentication and uses password-based login.  
- The CLI will prompt for a secure password (not visible on screen or stored in history).  

---

## 🚀 Step 4: Open HTTP and SSH Ports

Allow inbound access for SSH (22) and HTTP (80):

```bash
az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 22 \
  --priority 900

az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 80 \
  --priority 910
```

---

## 🚀 Step 5: Get Public IP Address


Retrieve the public IP of your VM:

```bash
PUBLIC_IP=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  -d \
  --query publicIps \
  -o tsv)
```

Save this value for use in the next steps.

---

## 🚀 Step 6: SSH into the VM


Connect using the username and password you provided earlier:

```bash
ssh $ADMIN_USERNAME@$PUBLIC_IP
```

When prompted, enter the password you set during VM creation.

---

## 🚀 Step 7: Install Apache HTTP Server


Inside the VM, run:

```bash
sudo apt-get update \
  && sudo apt-get install -y apache2
```

---

## 🚀 Step 8: Test Apache


Check Apache locally inside the VM:

```bash
curl http://localhost
```

From your local machine, open a browser and go to:

```
http://<public-ip>
```

You should see the **Apache2 Ubuntu Default Page**.

---

## 🚀 Step 9: Upload a Custom index.html

1. On your local machine, create a simple `index.html` file, for example:

```html
<html>
  <body><h1>Hello from Azure VM (Lab 3)</h1></body>
</html>
```


2. Upload it to the VM using `scp`:

```bash
scp index.html $ADMIN_USERNAME@$PUBLIC_IP:~/
```

3. SSH back into the VM if not already connected:

```bash
ssh $ADMIN_USERNAME@$PUBLIC_IP
```


4. Replace the default Apache page:

```bash
sudo mv ~/index.html /var/www/html/index.html \
  && sudo chown www-data:www-data /var/www/html/index.html \
  && sudo chmod 644 /var/www/html/index.html
```

5. Refresh `http://<public-ip>` in your browser to see your custom page.

---

## 🚀 Step 10: Clean Up Resources
To avoid ongoing charges, delete the resource group and all resources created in this lab:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

This will remove the VM and all related resources.

---

## ✅ Lab Summary

You successfully:
- Created a Linux VM (Ubuntu 22.04) using Azure CLI with password authentication  
- Connected to the VM via SSH  
- Installed Apache HTTP server  
- Replaced the default page with a custom `index.html`  
- Cleaned up all resources to avoid charges
