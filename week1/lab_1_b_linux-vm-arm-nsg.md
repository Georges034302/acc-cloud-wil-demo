# Lab 1c: Create a Linux VM Using ARM Template with NSG and Rules

## 🎯 Objective
Deploy a Linux VM using an ARM template, attach a Network Security Group (NSG) to the VM NIC, and configure rules for HTTP, HTTPS, and SSH.

---

## 📝 Instructions

### 1️⃣ Save the ARM Template

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
      "type": "Microsoft.Network/networkSecurityGroups",
      "apiVersion": "2020-11-01",
      "name": "[concat(parameters('vmName'), '-nsg')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "securityRules": [
          {
            "name": "Allow-SSH",
            "properties": {
              "priority": 1000,
              "protocol": "Tcp",
              "access": "Allow",
              "direction": "Inbound",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "22"
            }
          },
          {
            "name": "Allow-HTTP",
            "properties": {
              "priority": 1010,
              "protocol": "Tcp",
              "access": "Allow",
              "direction": "Inbound",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "80"
            }
          },
          {
            "name": "Allow-HTTPS",
            "properties": {
              "priority": 1020,
              "protocol": "Tcp",
              "access": "Allow",
              "direction": "Inbound",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "443"
            }
          }
        ]
      }
    },
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
            "properties": {
              "addressPrefix": "10.0.0.0/24",
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups', concat(parameters('vmName'), '-nsg'))]"
              }
            }
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
            "offer": "UbuntuServer",
            "sku": "18.04-LTS",
            "version": "latest"
          },
          "osDisk": {
            "createOption": "FromImage"
          }
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

### 2️⃣ Deploy the Template

```bash
az group create --name arm-vm-demo-rg --location australiaeast

az deployment group create \
  --resource-group arm-vm-demo-rg \
  --template-file linux-vm-arm.json \
  --parameters vmName=armdemo-vm adminUsername=azureuser adminPassword=YourP@ssw0rd123
```

### 3️⃣ Connect and Test

- Get the public IP from the Portal or with:
  ```bash
  az vm show --resource-group arm-vm-demo-rg --name armdemo-vm -d --query publicIps -o tsv
  ```
- SSH to the VM:
  ```bash
  ssh azureuser@<public-ip>
  ```
- Install Apache:
  ```bash
  sudo apt-get update
  sudo apt-get install -y apache2
  ```
- Test by browsing to `http://<public-ip>`

---

✅ **You have deployed a Linux VM with NSG