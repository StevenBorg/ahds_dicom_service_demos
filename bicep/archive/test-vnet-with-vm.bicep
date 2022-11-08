@description('VNet name')
param vnetName string = 'ContosoVnet'

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.0.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'radiologySubnet'

// @description('Subnet 2 Prefix')
// param subnet2Prefix string = '10.0.1.0/24'

// @description('Subnet 2 Name')
// param subnet2Name string = 'Subnet2'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Container group name')
param containerGroupName string = 'contoso-qvera-containergroup'

@description('Container name')
param containerName string = 'qie-container'

@description('Container image to deploy. Should be of the form accountName/imagename:tag for images stored in Docker Hub or a fully qualified URI for a private registry like the Azure Container Registry.')
param image string = 'qvera/qie:5.0.50'

@description('Port to open on the container.')
param port int = 80

@description('The number of CPU cores to allocate to the container. Must be an integer.')
param cpuCores int = 4

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 16

module vnet_deployment './deploy-vnet.bicep' = {
  name: 'vnet_deployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Name: subnet1Name
    subnet1Prefix: subnet1Prefix
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: containerName
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
              name: 'testEnvVar'
              value: 'testvalueEnvVar'
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
    osType: 'Linux'
    networkProfile: {
      id: vnet_deployment.outputs.networkProfileId 
    }
    restartPolicy: 'Always'
  }
}



output containerIPv4Address string = containerGroup.properties.ipAddress.ip
