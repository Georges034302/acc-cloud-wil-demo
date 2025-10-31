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

  Learn how to securely manage access to Azure Blob Storage using authentication, RBAC, SAS, and geo-redundancy.

  **Labs for this week:**
  - [lab_2_a_rbac-blob.md](week2/lab_2_a_rbac-blob.md):  
    *Grant and test RBAC roles for Blob Storage using Azure CLI.*
  - [lab_2_b_sas-blob.md](week2/lab_2_b_sas-blob.md):  
    *Generate and use Shared Access Signatures (SAS) for delegated access to blobs.*
  - [lab_2_c_GRS-blob.md](week2/lab_2_c_GRS-blob.md):  
    *Configure geo-redundant storage and simulate failover for Azure Blob Storage.*

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

  This week focuses on hosting web applications and microservices in Azure. You'll learn the basics of Azure App Service (Linux & Windows), deploying microservices with App Service and designing architecture for background processing using queues and worker roles.

  **Labs for this week:**
  - [lab_4_a_appservice_webapp.md](week4/lab_4_a_appservice_webapp.md):  
    *Deploy a web application to Azure App Service, explore deployment slots, scale settings, and runtime diagnostics.*
  - [lab_4_b_microservice_deployment.md](week4/lab_4_b_microservice_deployment.md):  
    *Deploy two Python microservices to Azure App Service, enable secure HTTP communication, and troubleshoot deployment issues.*
  - [lab_4_c_web_queue_worker.md](week4/lab_4_c_web_queue_worker.md):  
    *Implement the Web + Queue Worker pattern using App Service and Azure Storage Queues. Practice message processing, retries, and idempotency.*
  - [lab_4_d_secure-appservice-keyvault.md](week4/lab_4_d_secure-appservice-keyvault.md):  
    *Securely inject secrets into Azure App Service using Azure Key Vault, Managed Identity, and App Settings—no hardcoded sensitive values.*

</details>
</details>

<details>
  <summary>Week 5: Containers & App Service Integration</summary>

  Deploy and manage containerized applications, API gateways, and integrate with Azure App Service, Azure Container Instances, and Azure Container Apps.

  **Labs for this week:**
  - [lab_5_a_api_gateway.md](week5/lab_5_a_api_gateway.md):  
    *Configure and deploy an API Gateway for secure routing and aggregation of microservices.*
  - [lab_5_b_local-docker-deployment.md](week5/lab_5_b_local-docker-deployment.md):  
    *Deploy a containerized application using Azure App Service for scalable web hosting.*
  - [lab_5_c_app_service_container.md](week5/lab_5_c_app_service_container.md):  
    *Build and run a Dockerized API locally for development and testing.*
  - [lab_5_d_aci_contianer_deploy.md](week5/lab_5_d_aci_contianer_deploy.md):  
    *Deploy containers to Azure Container Instances (ACI) for rapid, serverless compute.*
  - [lab_5_e_container_apps_deploy.md](week5/lab_5_e_container_apps_deploy.md):  
    *Deploy and manage microservices using Azure Container Apps for advanced orchestration.*

</details>

<details>
  <summary>Week 6: Serverless & Event-Driven Architectures</summary>

  Implement serverless and event-driven solutions using Azure Functions, API Management, AKS, and Microsoft Graph.

  **Labs for this week:**
  - [Lab_6_a_APIM_function_queue.md](week6/Lab_6_a_APIM_function_queue.md):  
    *Expose an HTTP-triggered Node.js Azure Function via API Management with Queue output binding. No subscription key required.*
  - [lab_6_b_azure_function_blob_trigger.md](week6/lab_6_b_azure_function_blob_trigger.md):  
    *Serverless data ingestion pipeline: Blob Storage trigger parses CSV and inserts records into Azure Table Storage.*
  - [lab_6_c_aks_scalable_app.md](week6/lab_6_c_aks_scalable_app.md):  
    *Deploy and scale a containerized application on Azure Kubernetes Service (AKS) using CLI, Portal, and ARM.*
  - [lab_6_d_email_to_sms_function.md](week6/lab_6_d_email_to_sms_function.md):  
    *Event-driven serverless system: Azure Function listens for new emails via Microsoft Graph webhook and sends SMS alerts using Twilio.*

</details>

---

#### 🧑‍🏫 Author: Georges Bou Ghantous
<sub><i>This repository delivers hands-on Azure training, guiding learners through scripting, networking, storage security, containers, and serverless computing using real-world scenarios and best practices.</i></sub>
