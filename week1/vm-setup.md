# 🖥️ Demo Guide: Shell Scripts and VM Setup (Portal + CLI)

## 🎯 Objective
This guide covers how to provision an Azure Virtual Machine (VM) using shell scripts and the Azure Portal. It also includes uploading and deploying the initial web server project.

---

## 📜 Shell Scripts Overview

⚙️ **setup.sh**  
 Sets up environment variables required for resource creation.

🏗️ **vmcreate.sh**  
 Provisions Azure resources (resource group, network, VM, etc.) and deploys Apache on the VM.

🧹 **cleanup.sh**  
 Deletes all Azure resources created for this project.

---

## ▶️ How to Run the Scripts (CLI)

1️⃣ **Set up environment variables:**  
```bash
./setup.sh
```

2️⃣ **Create the VM and related resources:**  
```bash
./vmcreate.sh
```

3️⃣ **Clean up resources when finished:**  
```bash
./cleanup.sh
```

---

## 🧭 How to Create the VM Using Azure Portal

### 1️⃣ Create a Resource Group
1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Search for **Resource groups** → Click **+ Create**
3. Fill in:
   - **Subscription**: Your active subscription
   - **Resource group name**: e.g. `vm-demo-rg`
   - **Region**: e.g. `Australia East`
4. Click **Review + create** → **Create**

---

### 2️⃣ Create a Virtual Machine
1. Go to **Virtual Machines** → Click **+ Create** → **Azure virtual machine**
2. Fill in the **Basics** tab:
   - Subscription & Resource Group: use `vm-demo-rg`
   - **VM name**: `webvm`
   - **Region**: `Australia East`
   - **Image**: Ubuntu LTS (e.g., Ubuntu 20.04 LTS)
   - **Size**: Standard B1s (or any size allowed)
   - **Authentication**: Choose **SSH public key**
     - Paste your local public key
   - **Username**: e.g. `azureuser`
3. In **Inbound ports**, select **Allow SSH (22)**
4. Click **Review + create** → **Create**

---

### 3️⃣ Install Apache Web Server (Portal Access)
1. After deployment, go to your VM → Click **Connect** → **SSH** tab
2. Copy the SSH command and run it in your terminal:
```bash
ssh azureuser@<VM_PUBLIC_IP>
```
3. Once connected:
```bash
sudo apt update
sudo apt install apache2 -y
```
4. Test by browsing to `http://<VM_PUBLIC_IP>`

✅ You should see the Apache default web page

---

## 🔑 SSH into the Virtual Machine

🔎 After running `vmcreate.sh` or deploying via Portal, get your VM’s public IP and connect:
```bash
ssh <VM_USERNAME>@<VM_PUBLIC_IP>
```
💡 Replace placeholders with actual values.

---

## 📂⬆️ Upload the MomPopCafe Project Using SCP

📤 To upload the `MomPopCafe` folder to your VM:
```bash
scp -r MomPopCafe <VM_USERNAME>@<VM_PUBLIC_IP>:~/
```

---

✅ **Demo complete – you now have a VM running Apache and ready for project deployment!**

