// Bicep file to deploy OHIF and connect to an existing DICOM service
//    Used by other deployments, such as deploying OHIF with a DICOM service

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Your existing DICOM service URL (format: https://yourworkspacename-yourdicomservicename.dicom.azurehealthcareapis.com)')
param dicomServiceUrls string //= 'https://sjbrsnadicomws-rsnadicom.dicom.azurehealthcareapis.com'

@description('whether the dicomServiceUrl contains multiple dicom servers')
param is_multiple_dicoms string = 'True'

@description('Your existing Azure AD tenant ID (format: 72xxxxxf-xxxx-xxxx-xxxx-xxxxxxxxxxx)')
//@secure()
param aadTenantId string //= '72f988bf-86f1-41af-91ab-2d7cd011db47'

@description('Your existing Application (client) ID (format: 1f8xxxxx-dxxx-xxxx-xxxx-9exxxxxxxxxx)')
//@secure()
param applicationClientId string //= 'fd1caac5-b104-4709-8bbf-747e3f39ce9a'

@description('Your existing Application (client) secret')
@secure()
param applicationClientSecret string 

@description('The connection string with everything needed to connect to the blob store')
@secure()
param sourceBlobConnStr string 

@description('The blob container name with DICOM files, and ONLY DICOM files')
@secure()
param sourceBlobContainerName string 

@description('Container image to deploy. Should be of the form accountName/imagename:tag for images stored in Docker Hub or a fully qualified URI for a private registry like the Azure Container Registry.')
param image string = 'stevenborg/uploader:latest'

@description('Port to open on the container.')
param port int = 8080

@description('The number of CPU cores to allocate to the container. Must be an integer.')
param cpuCores int = 4

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 16

resource uploader 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: 'uploaderACI'
  location: location
  properties: {
    containers: [
      {
        name: 'uploader'
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          environmentVariables: [
            {
              name: 'AZURE_CLIENT_ID'
              value: applicationClientId
            }
            {
              name: 'AZURE_TENANT_ID'
              value: aadTenantId
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              secureValue: applicationClientSecret
            }
            {
              name: 'STORAGE_CONNSTR'
              secureValue: sourceBlobConnStr
            }
            {
              name: 'BLOB_CONTAINER'
              value: sourceBlobContainerName
            }
            {
              name: 'DICOM_URL'
              value: dicomServiceUrls
            }
            {
              name: 'IS_MULTIPLE_DICOMS'
              value: is_multiple_dicoms
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      } 
    ]
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
    osType: 'Linux'

    restartPolicy: 'Always'
  }
}

output meddreamIp string = uploader.properties.ipAddress.ip
output meddreamPort array = uploader.properties.ipAddress.ports
