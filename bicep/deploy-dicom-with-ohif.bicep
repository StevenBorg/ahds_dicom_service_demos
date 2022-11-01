@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Name of the AHDS workspace. This will appear in the API URL.')
param workspace_name string = 'workspace${uniqueString(resourceGroup().id)}'

@description('Name of the AHDS DICOM service. This will appear in the API URL.')
param dicom_service_name string = 'dicom${uniqueString(resourceGroup().id)}'

@description('Name of the AHDS FHIR service. This will appear in the API URL.')
param fhir_service_name string = 'fhir${uniqueString(resourceGroup().id)}'

@description('Should deploy FHIR')
param should_deploy_fhir bool = false

@description('Should deploy DICOM')
param should_deploy_dicom bool = true

@description('Storage account name')
param storage_account_name string = 'storage${uniqueString(resourceGroup().id)}'

// @description('Storage blob name')
// param storage_blob_name string = 'storage${uniqueString(resourceGroup().id)}'

// @description('Desired name of the storage account instance')
// param storageAccountName string

// @description('Your existing DICOM service URL (format: https://yourworkspacename-yourdicomservicename.dicom.azurehealthcareapis.com)')
// param dicomServiceUrl string = '<The URL to your DICOM service>'

@description('Your existing Azure AD tenant ID (format: 72xxxxxf-xxxx-xxxx-xxxx-xxxxxxxxxxx)')
param aadTenantId string //= '72xxxxxf-xxxx-xxxx-xxxx-xxxxxxxxxxx'

@description('Your existing Application (client) ID (format: 1f8xxxxx-dxxx-xxxx-xxxx-9exxxxxxxxxx)')
param applicationClientId string //= '1f8xxxxx-dxxx-xxxx-xxxx-9exxxxxxxxxx'


//var full_storage_name = '${storage_account_name}/${storage_blob_name}'

module ahds_deployment './deploy-dicom-and-fhir-services.bicep' = {
  name: 'ahds_deployment'
  params: {
    location: location
    workspace_name: workspace_name
    dicom_service_name: dicom_service_name
    fhir_service_name: fhir_service_name
    should_deploy_dicom: should_deploy_dicom
    should_deploy_fhir: should_deploy_fhir
  }
}

module ohif_deployment './deploy-ohif.bicep' = {
  name: 'ohif_deployment'
  params: {
    location: location
    storageAccountName: storage_account_name
    aadTenantId: aadTenantId
    applicationClientId: applicationClientId
    dicomServiceUrl: ahds_deployment.outputs.dicom_uri
  }
  dependsOn: [
    ahds_deployment
  ]
}

output workspace_name string = workspace_name
output dicom_service_name string = dicom_service_name
output fhir_service_name string = fhir_service_name
output dicom_uri string = ahds_deployment.outputs.dicom_uri
output fhir_uri string = ahds_deployment.outputs.fhir_uri
output fhir_deployed bool = should_deploy_fhir
output dicom_deployed bool = should_deploy_dicom
output ohif_uri string = ohif_deployment.outputs.storageAccountWebEndpoint

