
// This script deploys the on-prem solution 
@description('Administrator Password for Orthanc.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

// @description('Subnet Name')
// param vnetName string = 'ContosoVnet'

@description('Login name for Jump VM and SQL.')
param adminLogin string = 'student'

// @description('Qvera QIE ontainer image to deploy.')
// param image string = 'qvera/qie:latest'

// @description('Port to open on the container.')
// param port int = 80

// @description('The number of CPU cores to allocate to the container. Must be an integer.')
// param qveraCpuCores int = 4

// @description('The amount of memory to allocate to the container in gigabytes.')
// param qveraMemoryInGb int = 16

@description('Size of the virtual machine.')
@allowed([
  'Standard_DS1_v2'
  'Standard_D2s_v5'
])
param vmSize string = 'Standard_D2s_v5' //'Standard_D2s_v5'

@description('Azure Blob Connection string for shared Orthanc')
@secure()
param ORTHANC__AZURE_BLOB_STORAGE__CONNECTION_STRING string 

@description('PostgresSQL Password for shared Orthanc')
@secure()
param ORTHANC__POSTGRESQL__PASSWORD string 

@description('Name of the AHDS workspace. This will appear in the API URL.')
param workspace_name string = 'workspace${uniqueString(resourceGroup().id)}'

@description('Name of the AHDS DICOM service. This will appear in the API URL.')
param dicom_service_name string = 'dicom${uniqueString(resourceGroup().id)}'

@description('Your existing Azure AD tenant ID (format: 72xxxxxf-xxxx-xxxx-xxxx-xxxxxxxxxxx)')
@secure()
param aadTenantId string 

@description('Your existing Application (client) ID (format: 1f8xxxxx-dxxx-xxxx-xxxx-9exxxxxxxxxx)')
@secure()
param applicationClientId string 

@description('Your existing Application (client) secret')
@secure()
param applicationClientSecret string 

// This is VERY confusing! And you can't get the Principal Object ID from the Portal UI. 
//    See https://github.com/Azure/terraform-azurerm-appgw-ingress-k8s-cluster/issues/1 ') for how to get it

// When adding role assignments, and get an error: Principals of type Application cannot validly be used in role as...
// 	that means you're using the Application's Object ID. You need to find the Application's associated Principal Object ID...  
// see: https://github.com/Azure/terraform-azurerm-appgw-ingress-k8s-cluster/issues/1
// and: https://github.com/Azure/azure-cli/issues/5340
// Basically run: az ad sp list --filter "displayName eq 'rsna-demo-viewer-app1'" and get the id provided there - of course with your Application ID name
@description('Object ID of the Principal of the Application - confusing - see https://github.com/Azure/terraform-azurerm-appgw-ingress-k8s-cluster/issues/1 ')
@secure()
param dicom_principalId string //= '7e086154-4646-4550-b350-f94fadc6720b' // Object ID of rsna app reg

// Deploy the on prem solution
module onprem './deploy-rsna-demo-on-prem-shared-orthanc-options.bicep' = {
  name: 'onprem'
  params: {
    location: location
    adminPassword: adminPassword
    adminLogin: adminLogin
    ORTHANC__AZURE_BLOB_STORAGE__CONNECTION_STRING: ORTHANC__AZURE_BLOB_STORAGE__CONNECTION_STRING
    ORTHANC__POSTGRESQL__PASSWORD: ORTHANC__POSTGRESQL__PASSWORD
    vmSize: vmSize
  }
}

// Deploy the 'cloud' parts
module cloud '../dicom-service-with-meddream/deploy-dicom-with-meddream.bicep' = {
  name: 'cloud'
  params: {
    location: location
    aadTenantId: aadTenantId
    applicationClientId: applicationClientId
    applicationClientSecret: applicationClientSecret
    dicom_principalId: dicom_principalId
    dicom_service_name: dicom_service_name
    workspace_name: workspace_name
  }
}

output dicom_uri string = cloud.outputs.dicom_uri
output meddreamIp string = cloud.outputs.meddreamIp
output meddreamPort string = cloud.outputs.meddreamPort[0]



