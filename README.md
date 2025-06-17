# acc-cloud-wil-demo
This guide provides a week-by-week overview of the `Cloud Computing` IATD course, focusing on practical Azure cloud skills:

- **Week 1:** Deploying and managing Azure Virtual Machines (VMs).
- **Week 2:** Working with Azure Storage solutions.
- **Week 3:** Exploring Azure Networking concepts and resources.
- **Week 4:** Building decoupled applications using Azure services.
- **Week 5:** Deploying and managing applications with Azure Container Apps.
- **Week 6:** Implementing serverless computing with Azure Functions and related services.
  
## Course Overview

Each week includes hands-on scripts, instructions, and best practices for working with Azure.

<details>
  <summary>Week 1: Shell Scripts and VM Setup</summary>

  ### Shell Scripts Overview

  - **setup.sh**: Sets up environment variables required for resource creation.
  - **vmcreate.sh**: Provisions Azure resources (resource group, network, VM, etc.) and deploys Apache on the VM.
  - **cleanup.sh**: Deletes all Azure resources created for this project.

  ### How to Run the Scripts

  1. **Set up environment variables:**
     ```bash
     ./setup.sh
     ```

  2. **Create the VM and related resources:**
     ```bash
     ./vmcreate.sh
     ```

  3. **Clean up resources when finished:**
     ```bash
     ./cleanup.sh
     ```

  ### SSH into the Virtual Machine

  After running `vmcreate.sh`, get your VM's public IP from the script output. Then connect using:

  ```bash
  ssh <VM_USERNAME>@<VM_PUBLIC_IP>
  ```

  Replace `<VM_USERNAME>` and `<VM_PUBLIC_IP>` with your actual VM username and public IP.

  ### Upload the MomPopCafe Project Using SCP

  To upload the entire `MomPopCafe` folder to your VM's home directory:

  ```bash
  scp -r MomPopCafe <VM_USERNAME>@<VM_PUBLIC_IP>:~/
  ```

  Replace `<VM_USERNAME>` and `<VM_PUBLIC_IP>` with your actual VM username and public IP.

</details>

<details>
  <summary>Week 2</summary>
  <!-- Content for Week 2 will be added here -->
</details>

<details>
  <summary>Week 3</summary>
  <!-- Content for Week 3 will be added here -->
</details>

<details>
  <summary>Week 4</summary>
  <!-- Content for Week 4 will be added here -->
</details>

<details>
  <summary>Week 5</summary>
  <!-- Content for Week 5 will be added here -->
</details>

<details>
  <summary>Week 6</summary>
  <!-- Content for Week 6 will be added here -->
</details>
