# SonarQube PoC
The objective was to deploy SonarQube on Azure VM, set up the necessary configurations, and integrate it with the CI/CD pipeline to build, test, generate analysis results, and publish them to SonarQube.

### Steps Followed:

- **Infrastructure Provisioning & Configuration Setup :** 
1. Used Terraform script to deploy Azure VM.
2. Configured Docker, SonarQube on VM via bash script (provided the start.sh script in base64 format to azurerm_virtual_machine_extension resource in terraform for setting up the configuration)

- **Integrate SonarQube with Azure DevOps Pipeline :** 
1. Used a Dockerfile
that installs the required dependencies, including the SonarScanner and Java runtime.
2. The Dockerfile also includes steps to build the project, run tests, generate coverage reports and publish it to SonarQube.
3. Set up an Azure Pipeline to build the DockerFile and pass the necessary configuration details required for SonarQube.
