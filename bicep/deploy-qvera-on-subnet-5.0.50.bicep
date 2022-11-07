@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.1.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'qveraSubnet'

@description('Container group name')
param containerGroupName string = 'contoso-containergroup'

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



var networkProfileName = 'aci-networkProfile'
var interfaceConfigName = 'eth0'
var interfaceIpConfig = 'ipconfigprofile1'



module jumpbox_deployment './deploy-vnet-with-jump-vm.bicep' = {
  name: 'jumpbox_deployment'
  params: {
    location: location
    adminPassword: adminPassword
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: 'ContosoVnet'
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: subnet1Name
  parent: vnet
  dependsOn: [
    jumpbox_deployment
  ]
  properties: {
    addressPrefix: subnet1Prefix
    delegations: [
      {
        name: 'DelegationService'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}

// Network profiles are automatically created, but it was in the demo, so I copied it over...
resource networkProfile 'Microsoft.Network/networkProfiles@2020-11-01' = {
  name: networkProfileName
  location: location
  properties: {
    containerNetworkInterfaceConfigurations: [
      {
        name: interfaceConfigName
        properties: {
          ipConfigurations: [
            {
              name: interfaceIpConfig
              properties: {
                subnet: {
                  id: subnet1.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  dependsOn: [
    jumpbox_deployment
    subnet1
  ]
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
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      } }
    ]
    volumes: [
      {
        name: 'myvolume'
        gitRepo: {
          repository: 'https://github.com/StevenBorg/ahds_dicom_service_demos/tree/main/qvera/mariadb-init'
          directory: '.'
        } 
      }
    ]
    osType: 'Linux'
    // With this commented out, we can't get the containerGroup.properties.ipAddress.ip value
    //  But this causes an error with the jump vm script
    //  WHOOAA!!!  Without this the container-group doesn't GET an ip address!
    networkProfile: {
      id: networkProfile.id
      
    }

    restartPolicy: 'Always'
  }
}

output vm string = jumpbox_deployment.outputs.hostname
output vnet string = jumpbox_deployment.outputs.vnetName
output subnetName string = subnet1.name
output subnetId string = subnet1.id


