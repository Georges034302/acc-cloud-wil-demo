# Lab 1_a: Create and Explore a Windows Virtual Machine in Azure Portal

<img width="1024" height="1024" alt="Lab_1_a" src="https://github.com/user-attachments/assets/7b45bf73-d066-4fd4-ae88-37a14537cf25" />

---
## 🎯 Objectives
- Create a Windows Virtual Machine (VM) in the Azure Portal  
- Connect to the VM using Remote Desktop Protocol (RDP)  
- Explore disk roles (OS and temporary disks) inside the VM  
- Understand VM sizes and scaling options  
- (Optional) Install IIS Web Server on the VM  
- Review how VM runtime affects costs  

---

## 📝 Requirements
- An active Azure subscription  
- A Windows computer with **Remote Desktop Connection (RDP)** client  
  - (Mac: install Microsoft Remote Desktop from App Store)  
  - (Linux: install `remmina` or Microsoft Remote Desktop client)  

---

## 🚀 Step 1: Sign In and Start VM Creation
1. Open a browser and go to [https://portal.azure.com](https://portal.azure.com).  
2. Sign in with your Azure account.  
3. In the **search bar** at the top, type **Virtual machines** and press Enter.  
4. On the **Virtual machines** blade, click **+ Create** → **Azure virtual machine**.  

---

## 🚀 Step 2: Configure Basics
1. **Subscription**: Leave your default subscription selected.  
2. **Resource group**:  
   - Click **Create new**.  
   - Enter: `rg-lab1`.  
   - Click **OK**.  
3. **Virtual machine name**: Enter `winvm01`.  
4. **Region**: Select **Australia East** (or nearest to you).  
5. **Availability options**: Leave default: **No infrastructure redundancy required**.  
6. **Security type**: Leave as **Standard**.  
7. **Image**: Select **Windows Server 2022 Datacenter: Azure Edition - x64 Gen2**.  
8. **VM architecture**: Leave default **x64**.  
9. **Size**:  
   - Click **See all sizes**.  
   - Choose **Standard_B2s** (2 vCPUs, 4 GiB memory).  
   - Click **Select**.  
10. **Administrator account**:  
    - Username: `azureuser`  
    - Password: enter a strong password.  
    - Confirm password.  
11. **Inbound port rules**:  
    - Select **Allow selected ports**.  
    - Under **Select inbound ports**, check **RDP (3389)**.  

Click **Next: Disks >**.  

---

## 🚀 Step 3: Configure Disks
1. **OS disk type**: Leave default **Premium SSD (LRS)** (or **Premium SSD v2** if shown).  
2. **Encryption type**: Leave default **Default (platform-managed key)**.  
3. **Data disks**: Leave empty.  
4. Click **Next: Networking >**.  

---

## 🚀 Step 4: Configure Networking
1. **Virtual network**: Leave the default automatically created one.  
2. **Subnet**: Leave default.  
3. **Public IP**: Leave default (new).  
4. **NIC network security group**: Leave as **Basic**.  
5. **Public inbound ports**: Confirm **Allow selected ports**.  
6. **Select inbound ports**: Ensure **RDP (3389)** is selected.  

Click **Next: Management >**.  

---

## 🚀 Step 5: Configure Management
1. **Boot diagnostics**: Leave enabled.  
2. **System assigned managed identity**: Leave default **Off**.  
3. **Auto-shutdown**: Leave disabled (or configure if desired).  
4. Leave other options as default.  

Click **Next: Monitoring >**.  

---

## 🚀 Step 6: Configure Monitoring
1. **Enable monitoring**: Leave default **Yes** for boot diagnostics.  
2. Leave Guest OS diagnostics as **Off**.  
3. Leave others as default.  

Click **Next: Advanced >**.  

---

## 🚀 Step 7: Advanced Settings
Leave all defaults. Click **Next: Tags >**.  

---

## 🚀 Step 8: Tags
Optional: Add a tag. Example:  
- Name: `Environment`  
- Value: `Lab`  

Click **Next: Review + create >**.  

---

## 🚀 Step 9: Review + Create
1. The portal will validate your configuration.  
2. Once you see **Validation passed**, click **Create**.  
3. Deployment will begin — wait until status shows **Your deployment is complete** (≈2–3 minutes).  
4. Click **Go to resource** to open your VM.  

---

## 🚀 Step 10: Connect to VM via RDP
1. In the VM overview page, click **Connect** (top menu).  
2. Select **RDP**.  
3. Under **Connect via RDP**, ensure **Public IP address** is selected and Port is `3389`.  
   > If **Connect** is disabled or Public IP is empty, wait until the VM **Status = Running** and a **Public IP** is assigned on the Overview blade.
4. Click **Download RDP File**.  
5. Open the `.rdp` file:  
   - On Windows: it opens in Remote Desktop Connection.  
   - On Mac: open Microsoft Remote Desktop app.  
6. Enter credentials:  
   - Username: `azureuser`  
   - Password: the one you set.  
7. Accept the certificate warning.  
8. The VM desktop will open in a new window.  

---

## 🚀 Step 11: Explore VM Disks
1. Inside the VM, open **File Explorer**.  
2. Look at **This PC**:  
   - **C:** drive = OS disk (persistent).  
   - **D:** drive = Temporary disk **(if present; some VM sizes don’t include temp storage and D: won’t appear)**. Data on a temporary disk can be lost on redeploy/maintenance.  

---

## 🚀 Step 12: Install IIS Web Server
1. Inside VM, click **Start** → type **Server Manager** → open it.  
2. In **Server Manager**, click **Manage** → **Add Roles and Features**.  
3. In the wizard:  
   - Click **Next** until you reach **Server Roles**.  
   - Check **Web Server (IIS)**.  
   - Accept required features → click **Add Features**.  
   - Click **Next** through remaining screens → **Install**.  
4. Wait for installation to complete.  
5. Back on your local machine, open a browser.  
6. Enter: `http://<PublicIP>` of your VM.  
7. You should see the **IIS Welcome Page**.  

---

## 🚀 Step 13: Stop VM and Observe Cost
1. Go back to the Azure Portal.  
2. In your VM **Overview**, click **Stop** at the top.  
3. Wait until the status changes to **Stopped (deallocated)**.  
4. Note:  
   - Compute charges stop when VM is stopped.  
   - You still pay for storage (OS disk, Public IP if static).  

---

## 🚀 Step 14: Clean Up Resources
To avoid ongoing charges, delete the resource group and all resources created in this lab:

1. In the Azure Portal, search for **Resource groups**.
2. Select `rg-lab1`.
3. Click **Delete resource group** at the top.
4. Type `rg-lab1` to confirm and click **Delete**.


This will remove the VM and all related resources.

---

## ✅ Lab Summary
You have successfully:  
- Created a Windows VM in Azure Portal  
- Configured VM size, region, and login credentials  
- Connected via RDP  
- Explored OS and temporary disks  
- Installed IIS Web Server and tested it  
- Observed how costs behave when VM is stopped  
