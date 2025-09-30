# Lab 1_c: Provision a Linux VM Using an ARM Template

## 🎯 Objective
Deploy a Linux VM in Azure using an ARM template, connect via SSH, and configure it as a simple web server.

---

## 📝 Requirements
- An active Azure subscription  
- Azure CLI installed and logged in (`az login`)  
- SSH client available (Linux/macOS: built-in, Windows: PowerShell or PuTTY/Microsoft Terminal)  

---

## 🚀 Step 1: Save the ARM Template

Create a file named `linux-vm-arm.json` with the following content:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": { "type": "string" },
    "adminUsername": { "type": "string" },
    "adminPassword": { "type": "securestring" }
  },
  "resources": [
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "2020-11-01",
      "name": "[concat(parameters('vmName'), '-pip')]",
      "location": "[resourceGroup().location]",
      "properties": { "publicIPAllocationMethod": "Dynamic" }
    },
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2020-11-01",
      "name": "[concat(parameters('vmName'), '-vnet')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": { "addressPrefixes": [ "10.0.0.0/16" ] },
        "subnets": [
          {
            "name": "default",
            "properties": { "addressPrefix": "10.0.0.0/24" }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2020-11-01",
      "name": "[concat(parameters('vmName'), '-nic')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses', concat(parameters('vmName'), '-pip'))]",
        "[resourceId('Microsoft.Network/virtualNetworks', concat(parameters('vmName'), '-vnet'))]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "subnet": {
                "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', concat(parameters('vmName'), '-vnet'), 'default')]"
              },
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', concat(parameters('vmName'), '-pip'))]"
              }
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2021-07-01",
      "name": "[parameters('vmName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces', concat(parameters('vmName'), '-nic'))]"
      ],
      "properties": {
        "hardwareProfile": { "vmSize": "Standard_B1s" },
        "osProfile": {
          "computerName": "[parameters('vmName')]",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "Canonical",
            "offer": "0001-com-ubuntu-server-jammy",
            "sku": "22_04-lts",
            "version": "latest"
          },
          "osDisk": { "createOption": "FromImage" }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', concat(parameters('vmName'), '-nic'))]"
            }
          ]
        }
      }
    }
  ]
}
```

---

## 🚀 Step 2: Deploy the Template


Run the following commands in your terminal (replace parameters as needed):

```bash
# Create a resource group
az group create \
  --name arm-vm-demo-rg \
  --location australiaeast

# Deploy ARM template (password will be prompted securely)
az deployment group create \
  --resource-group arm-vm-demo-rg \
  --template-file linux-vm-arm.json \
  --parameters \
    vmName=armdemo-vm \
    adminUsername=azureuser
```

👉 At this point, Azure CLI will prompt you to enter the `adminPassword` securely. The password will not be visible or stored in your shell history.

---

## 🚀 Step 3: Connect to the VM

1. Retrieve the public IP of your VM:

```bash
az vm show --resource-group arm-vm-demo-rg --name armdemo-vm -d --query publicIps -o tsv
```

2. Connect via SSH:

```bash
ssh azureuser@<public-ip>
```

*(Replace `<public-ip>` with the actual IP returned above.)*

---

## 🚀 Step 4: Install Apache Web Server

Inside the VM:

```bash
sudo apt-get update
sudo apt-get install -y apache2
```

To test, open a browser and navigate to:

```
http://<public-ip>
```

You should see the **Apache2 Ubuntu Default Page**.

---

## ✅ Lab Summary


---

## 🚀 Step 5: Clean Up Resources
To avoid ongoing charges, delete the resource group and all resources created in this lab:

```bash
az group delete --name arm-vm-demo-rg --yes --no-wait
```

This will remove the VM and all related resources.

---

## ✅ Lab Summary

You successfully:

- Deployed a Linux VM (Ubuntu 22.04 LTS) using an ARM template  
- Entered the admin password securely at deployment time  
- Connected via SSH  
- Installed and tested Apache web server  
- Cleaned up all resources to avoid charges  
