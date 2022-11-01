# AHDS DICOM service demos
Deployment demos for the Azure Health Data Service (AHDS) DICOM service

This is very much a messy work in process.  I'm keeping notes here, extra files, etc. In other words, don't think this repo is cleanly usable.

### App Registration
For nearly every demo environment deployed here, you will need an App Registration, and information. There are several ways to approach the problem, but for these demos, we will assume that you have created the appropriate app registration.  

The following document provides guidance: https://learn.microsoft.com/en-us/azure/healthcare-apis/register-application-cli-rest 


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

