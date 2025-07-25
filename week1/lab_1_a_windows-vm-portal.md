# Demo Guide: Create a Windows VM from Azure Portal and RDP to It

## 🎯 Objective
Provision a Windows Virtual Machine using the Azure Portal and connect to it via Remote Desktop Protocol (RDP).

---

## 📝 Instructions

### 1️⃣ Sign in to Azure Portal
- Go to [https://portal.azure.com](https://portal.azure.com)

### 2️⃣ Create a Resource Group
1. In the left menu, select **Resource groups** > **+ Create**.
2. Fill in:
   - **Subscription**: Your active subscription
   - **Resource group name**: e.g. `win-vm-demo-rg`
   - **Region**: e.g. `Australia East`
3. Click **Review + create** > **Create**.

### 3️⃣ Create a Windows Virtual Machine
1. In the left menu, select **Virtual Machines** > **+ Create** > **Azure virtual machine**.
2. Fill in the **Basics** tab:
   - **Subscription**: Your subscription
   - **Resource group**: `win-vm-demo-rg`
   - **Virtual machine name**: e.g. `winvm`
   - **Region**: `Australia East`
   - **Image**: Windows Server 2022 Datacenter (or latest)
   - **Size**: Standard B1s (or any allowed size)
   - **Administrator account**: Enter username and password
3. Under **Inbound port rules**, select **RDP (3389)** to allow remote desktop access.
4. Click **Review + create** > **Create**.

### 4️⃣ Connect via RDP
1. After deployment, go to your VM’s **Overview** page.
2. Click **Connect** > **RDP**.
3. Download the RDP file and open it.
4. Enter your username and password to connect.

---

✅ **You have successfully created and connected to a Windows VM using the Azure Portal!**