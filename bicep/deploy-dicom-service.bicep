// Simple bicep file to deploy Azure Health Data Services DICOM service

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Name of the AHDS workspace. This will appear in the API URL.')
param workspace_name string = 'workspace${uniqueString(resourceGroup().id)}'

@description('Name of the AHDS DICOM service. This will appear in the API URL.')
param dicom_service_name string = 'dicom${uniqueString(resourceGroup().id)}'

var full_dicom_name = '${workspace_name}/${dicom_service_name}'


resource workspace 'Microsoft.HealthcareApis/workspaces@2022-06-01' = {
  name: workspace_name
  location: location
}

resource dicom 'Microsoft.HealthcareApis/workspaces/dicomservices@2022-06-01' = {
  name: full_dicom_name
  dependsOn: [workspace]
  location: location
}


output workspace_name string = workspace_name
output dicom_service_name string = dicom_service_name
output dicom_uri string = dicom.properties.serviceUrl
output dicom_uri2 object = dicom.properties
