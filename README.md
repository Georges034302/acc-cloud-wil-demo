# Course Guide

This guide provides a week-by-week overview of the `Advanced Cloud Computing` IATD course, focusing on Azure cloud services. Each week includes hands-on scripts, instructions, and best practices for working with Azure.

---

<details>
  <summary>Week 1: Azure VM Provisioning (Portal, CLI, ARM)</summary>

  Learn how to provision and configure Azure Virtual Machines using the Azure Portal, CLI, and ARM templates.


  **Labs for this week:**
  - [lab_1_a_windows-vm-portal.md](week1/lab_1_a_windows-vm-portal.md):  
    *Create a Windows VM using the Azure Portal and connect to it via RDP.*
  - [lab_1_b_linux-vm-cli.md](week1/lab_1_b_linux-vm-cli.md):  
    *Create a Linux VM using Azure CLI, connect via SSH, install Apache, and upload a custom web page.*
  - [lab_1_c_linux-vm-arm.md](week1/lab_1_c_linux-vm-arm.md):  
    *Deploy a Linux VM using an ARM template, connect via SSH, and install Apache.*

</details>

<details>
  <summary>Week 2: Securing Access to Azure Blob Storage</summary>

  Learn how to securely manage access to Azure Blob Storage using authentication, RBAC, and SAS.

  **Labs for this week:**
  - [lab_2_a_authentication-blob.md](week2/lab_2_a_authentication-blob.md):  
    *Authenticate and access Azure Blob Storage securely.*
  - [lab_2_b_rbac-blob.md](week2/lab_2_b_rbac-blob.md):  
    *Grant and test RBAC roles for Blob Storage using Azure CLI.*
  - [lab_2_c_sas-blob.md](week2/lab_2_c_sas-blob.md):  
    *Generate and use Shared Access Signatures (SAS) for delegated access to blobs.*

</details>

<details>
  <summary>Week 3: Azure Databases & Networking</summary>

  Explore Azure networking and database fundamentals.

  **Labs for this week:**
  - [lab_3_a_networking_nsg.md](week3/lab_3_a_networking_nsg.md):  
    *Deploy and test Network Security Groups and custom rules.*
  - [lab_3_b_azure_sql.md](week3/lab_3_b_azure_sql.md):  
    *Provision and connect to Azure SQL Database.*
  - [lab_3_c_cosmos_nosql.md](week3/lab_3_c_cosmos_nosql.md):  
    *Deploy and interact with Azure Cosmos DB (NoSQL).*
  - [lab_3_d_vnet_peering.md](week3/lab_3_d_vnet_peering.md):  
    *Set up VNet peering and test connectivity between VNets.*

</details>

<details>
  <summary>Week 4: Building Decoupled Applications</summary>

  Learn how to design and deploy decoupled applications using Azure services.

  **Labs for this week:**
  - [lab_4_a_appservice_webapp.md](week4/lab_4_a_appservice_webapp.md):  
    *Deploy a web application using Azure App Service.*
  - [lab_4_b_microservice_deployment.md](week4/lab_4_b_microservice_deployment.md):  
    *Deploy and manage microservices on Azure.*
  - [lab_4_c_web_queue_worker.md](week4/lab_4_c_web_queue_worker.md):  
    *Implement the Web-Queue-Worker pattern using App Service, Storage Queue, and Azure Functions.*

</details>

<details>
  <summary>Week 5: Containers & App Service Integration</summary>

  Deploy and manage containerized applications and integrate with Azure App Service.

  **Labs for this week:**
  - [lab_5_a_local-docker-joke-api-demo.md](week5/lab_5_a_local-docker-joke-api-demo.md):  
    *Build and run a Dockerized API locally.*
  - [lab_5_b_app_service_container.md](week5/lab_5_b_app_service_container.md):  
    *Deploy a containerized app using Azure App Service.*
  - [lab_5_c_secure-appservice-keyvault-demo.md](week5/lab_5_c_secure-appservice-keyvault-demo.md):  
    *Secure App Service apps with Azure Key Vault integration.*

</details>

<details>
  <summary>Week 6: Serverless & Event-Driven Architectures</summary>

  Implement serverless and event-driven solutions using Azure Functions, Logic Apps, and AKS.

  **Labs for this week:**
  - [lab_6_a_aks_scalable_app.md](week6/lab_6_a_aks_scalable_app.md):  
    *Deploy and scale applications on Azure Kubernetes Service (AKS).*
  - [lab_6_b_azure_function_blob_trigger.md](week6/lab_6_b_azure_function_blob_trigger.md):  
    *Create and deploy a Node.js Azure Function app.*
  - [lab_6_c_email_to_sms_function.md](week6/lab_6_c_email_to_sms_function.md):  
    *Automate email processing and queue integration using Logic Apps and Functions.*

</details>

---

#### 🧑‍🏫 Author: Georges Bou Ghantous
<sub><i>This repository delivers hands-on Azure training, guiding learners through scripting, networking, storage security, containers, and serverless computing using real-world scenarios and best practices.</i></sub>
