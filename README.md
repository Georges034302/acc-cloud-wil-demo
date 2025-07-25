# Course Guide

This guide provides a week-by-week overview of the `Advanced Cloud Computing` IATD course, focusing  Azure cloud services. Each week includes hands-on scripts, instructions, and best practices for working with Azure.

---

<details>
  <summary>Week 1: Shell Scripts and VM Setup</summary>

  Learn how to provision and configure Azure Virtual Machines using the Azure Portal, CLI, and ARM templates.

  **Labs for this week:**
  - [windows-vm-portal.md](week1/windows-vm-portal.md):  
    *Create a Windows VM using the Azure Portal and connect to it via RDP.*
  - [linux-vm-cli-apache.md](week1/linux-vm-cli-apache.md):  
    *Deploy a Linux VM using Azure CLI, SSH into it, and install Apache HTTP server.*
  - [linux-vm-arm-nsg.md](week1/linux-vm-arm-nsg.md):  
    *Deploy a Linux VM using an ARM template, attach a Network Security Group (NSG) to the NIC, and configure rules for SSH, HTTP, and HTTPS.*

</details>

<details>
  <summary>Week 2: Securing Access to Azure Blob Storage</summary>

  Learn how to securely manage access to Azure Blob Storage using role-based access control (RBAC), shared access signatures (SAS), and storage account keys.

  **Labs for this week:**
  - [blob-rbac-cli.md](week2/blob-rbac-cli.md):  
    *Grant and test RBAC roles for Blob Storage using Azure CLI.*
  - [blob-sas-cli.md](week2/blob-sas-cli.md):  
    *Generate and use Shared Access Signatures (SAS) for delegated access to blobs.*
  - [blob-key-management.md](week2/blob-key-management.md):  
    *Rotate and manage storage account keys securely with scripts.*

</details>

<details>
  <summary>Week 3: Azure Networking</summary>

  Explore Azure networking fundamentals and best practices.

  **Labs for this week:**
  - [vnet-basic.md](week3/vnet-basic.md):  
    *Create and configure a virtual network and subnets.*
  - [nsg-rules.md](week3/nsg-rules.md):  
    *Deploy and test Network Security Groups and custom rules.*
  - [vnet-peering.md](week3/vnet-peering.md):  
    *Set up VNet peering and test connectivity between VNets.*

</details>

<details>
  <summary>Week 4: Building Decoupled Applications</summary>

  Learn how to design and deploy decoupled applications using Azure services.

  **Labs for this week:**
  - [web_queue_worker.md](week4/web_queue_worker.md):  
    *Implement the Web-Queue-Worker pattern using App Service, Storage Queue, and Azure Functions.*
  - [event-grid-demo.md](week4/event-grid-demo.md):  
    *Build an event-driven workflow using Azure Event Grid and Functions.*

</details>

<details>
  <summary>Week 5: Azure Container Apps</summary>

  Deploy and manage containerized applications with Azure Container Apps.

  **Labs for this week:**
  - [container-apps-quickstart.md](week5/container-apps-quickstart.md):  
    *Deploy your first container app and expose it to the internet.*
  - [container-apps-scale.md](week5/container-apps-scale.md):  
    *Configure scaling rules and test auto-scaling for container apps.*

</details>

<details>
  <summary>Week 6: Serverless Computing with Azure Functions</summary>

  Implement serverless solutions using Azure Functions and related services.

  **Labs for this week:**
  - [function-http-trigger.md](week6/function-http-trigger.md):  
    *Create and deploy an HTTP-triggered Azure Function.*
  - [logicapp_email_to_blob.md](week6/logicapp_email_to_blob.md):  
    *Automate email attachment uploads to Blob Storage using Logic Apps and Functions.*
</details>

---
#### 🧑‍🏫 Author: Georges Bou Ghantous
<sub><i>This repository delivers hands-on Azure training, guiding learners through scripting, networking, storage security, containers, and serverless computing using real-world scenarios and best practices.</i></sub>
