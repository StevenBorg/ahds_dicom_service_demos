# Create a single environment

Create a JSON file with the appropriate parameters stored outside of any git repo. In my case, I've named the file `odl.parameters.json` and it looks like this:

`{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "aadTenantId": {
      "value": "copy and paste here"
    },
    "applicationClientId": {
      "value": "copy and paste here"
    },
    "applicationClientSecret": {
      "value": "copy and paste here"
    },
    "dicom_principalId": {
      "value": "copy and paste here"
    },
    "adminPassword": {
      "value": "create memorable but secure password here that is > 12 characters"
    }
  }
}`


Open an Azure CLI enabled command line

Type `az group create --location eastus --name sjbDeleteMe1` to create a resource froup

Ensure you're in the the directory where the all-up-standalone.bicep file exists.

type `az deployment group create --template-file all-up-standalone.bicep  --parameters @C:\Temp\odl.parameters.json --resource-group sjbDeleteMe1` to deploy a standalone deployment.

