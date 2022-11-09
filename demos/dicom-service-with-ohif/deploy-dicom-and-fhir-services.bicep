// Bicep file to deploy Azure Health Data Services DICOM and FHIR services
//    Defaults to deploying a single DICOM service
//    Used by other deployments, such as deploying OHIF with a DICOM service

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

var tenantId = tenant().tenantId
var loginURL = environment().authentication.loginEndpoint
var authority = '${loginURL}${tenantId}'
var audience = 'https://${workspace_name}-${fhir_service_name}.fhir.azurehealthcareapis.com'


resource workspace 'Microsoft.HealthcareApis/workspaces@2022-06-01' = {
  name: workspace_name
  location: location

  resource dicom 'dicomservices' = if (should_deploy_dicom) {
    name: dicom_service_name
    location: location
  }

  resource fhir 'fhirservices' = if (should_deploy_fhir) {
    name: fhir_service_name
    location: location
    kind: 'fhir-R4'
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      accessPolicies: []
      authenticationConfiguration: {
        authority: authority
        audience: audience
        smartProxyEnabled: false
      }
    }
  }


}


output workspace_name string = workspace_name
output dicom_service_name string = dicom_service_name
output fhir_service_name string = fhir_service_name
output dicom_uri string = workspace::dicom.properties.serviceUrl
output fhir_uri string = audience
output fhir_deployed bool = should_deploy_fhir
output dicom_deployed bool = should_deploy_dicom
