# 🖥️🚀 Week 1: Shell Scripts and VM Setup

📝 This guide covers the shell scripts and steps required to provision an Azure Virtual Machine (VM) and deploy the initial web server for the project.

---

## 📜 Shell Scripts Overview

⚙️ **setup.sh**  
 Sets up environment variables required for resource creation.

🏗️ **vmcreate.sh**  
 Provisions Azure resources (resource group, network, VM, etc.) and deploys Apache on the VM.

🧹 **cleanup.sh**  
 Deletes all Azure resources created for this project.

---

## ▶️ How to Run the Scripts

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

## 🔑 SSH into the Virtual Machine

🔎 After running `vmcreate.sh`, get your VM's public IP from the script output. Then connect using:

```bash
ssh <VM_USERNAME>@<VM_PUBLIC_IP>
```

💡 Replace `<VM_USERNAME>` and `<VM_PUBLIC_IP>` with your actual VM username and public IP.

---

## 📂⬆️ Upload the MomPopCafe Project Using SCP

📤 To upload the entire `MomPopCafe` folder to your VM's home directory:

```bash
scp -r MomPopCafe <VM_USERNAME>@<VM_PUBLIC_IP>:~/
```

💡 Replace `<VM_USERNAME>` and `<VM_PUBLIC_IP>` with your actual VM username and public IP.