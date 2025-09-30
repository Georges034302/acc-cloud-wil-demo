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



Set your variables first:

```bash
RESOURCE_GROUP=arm-vm-demo-rg
VM_NAME=armdemo-vm
LOCATION=australiaeast
ADMIN_USERNAME=azureuser
```

Run the following commands:

```bash
# Create a resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Deploy ARM template (password will be prompted securely)
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file linux-vm-arm.json \
  --parameters \
    vmName=$VM_NAME \
    adminUsername=$ADMIN_USERNAME
```

👉 At this point, Azure CLI will prompt you to enter the `adminPassword` securely. The password will not be visible or stored in your shell history.

---

## 🚀 Step 3: Connect to the VM


1. Retrieve the public IP of your VM and store it in a variable:

```bash
PUBLIC_IP=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  -d \
  --query publicIps \
  -o tsv)
```

2. Connect via SSH:

```bash
ssh $ADMIN_USERNAME@$PUBLIC_IP
```

---

## 🚀 Step 4: Install Apache Web Server


Inside the VM:

```bash
sudo apt-get update && sudo apt-get install -y apache2
```

To test, open a browser and navigate to:

```
http://<public-ip>
```


You should see the **Apache2 Ubuntu Default Page**.

---

## 🚀 Step 5: Upload a Custom index.html

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

5. Refresh `http://$PUBLIC_IP` in your browser to see your custom page.

---

## 🚀 Step 5: Clean Up Resources
To avoid ongoing charges, delete the resource group and all resources created in this lab:


```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
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
