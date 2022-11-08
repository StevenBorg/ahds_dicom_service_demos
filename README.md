# AHDS DICOM service demos
Deployment demos for the Azure Health Data Service (AHDS) DICOM service

This is very much a messy work in process.  I'm keeping notes here, extra files, etc. In other words, don't think this repo is cleanly usable.

## Requirements
### App Registration
For nearly every demo environment deployed here, you will need an App Registration, and information. There are several ways to approach the problem, but for these demos, we will assume that you have created the appropriate app registration.  

The following document provides guidance: https://learn.microsoft.com/en-us/azure/healthcare-apis/register-application-cli-rest 

Demo walkthrough (only Microsoft): https://microsoft.sharepoint.com/:w:/t/ProjectResolute/EfR03qdjIOpJqapRROvaNUABykS9MhKGGjYc5MO55Qn57w?e=fpqPpa&isSPOFile=1&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yMjEwMjgwNzIwMCIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D 

### Azure Command Line (or Powershell)
Many of these demos depend a local installation of the ACL in order to deploy Bicep files. Additionally, if you're using VS Code, I highly recommend the Bicep extension.

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install
- https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep

### Docker 
To build any of the DICOM files to run locally, or to rebuild the Docker files used, you'll need Docker installed and access to the Docker command line. Docker Desktop is no longer free for everyone, but is one of the more common tools. 

- Docker Desktop: https://www.docker.com/products/docker-desktop/


## RSNA Demo
The RSNA demo is a work in process. Go to demos/rsna and reference the readme.md there!

--- Nothing below this line applies right now --

To deploy the AHDS DICOM service with OHIF, run the following command:

`tbd`

To deploy the on-premises infrastructure run the following commands from an ACI command line in the /bicep subdirectory of the cloned git repo:

`az group create --location eastus --name uniqueResourceGroupName`

`az deployment group create --template-file .\deploy-qvera-on-subnet-5.0.50.bicep --resource-group uniqueResourceGroupName`

Today, this results in a vnet, 2 subnets, 1 VM for jump box to remote into Port 4545, and 1 containerized instance of Qvera QIE 5.0.50.











IGNORE below:


Steps:
az login --scope https://graph.microsoft.com//.default
az ad app create --display-name sjbAppReg


$clientid=$(az ad app create --display-name sjbAppReg --query appId --output tsv)
echo $clientid
$objectid=$(az ad app show --id $clientid --query id --output tsv)

_This part doesn't really work - need to install jq, etc_
$default_scope=$(az ad app show --id $clientid | jq '.oauth2Permissions[0.isEnabled = false' | jq -r '.oauth2Permissions')
az ad app update --id $clientid --set oauth2Permissions="$default_scope"
az ad app update --id $clientid --set oauth2Permissions="[]"


az rest -m post -u https://graph.microsoft.com/v1.0/applications  --headers 'Content-Type=application/json' --body '{"displayName": "xxx"}'

$clientid2=$(az rest -m post -u https://graph.microsoft.com/v1.0/applications  --headers 'Content-Type=application/json' --body '{"displayName": "sjbAppReg"}' --query appId --output tsv)

