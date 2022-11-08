@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Vnet Name')
param vnetName string = 'ContosoVnet'

@description('Subnet 1 Prefix')
param qveraSubnetPrefix string = '10.0.1.0/24'

@description('Subnet 1 Name')
param qveraSubnetName string = 'qveraSubnet'

@description('Container group name')
param qveraContainerGroupName string = 'contoso-qvera-containergroup'

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
    vnetName: vnetName
    vmName: 'jump-vm'
    adminUsername: 'student'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
}

resource qveraSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: qveraSubnetName
  parent: vnet
  dependsOn: [
    jumpbox_deployment
  ]
  properties: {
    addressPrefix: qveraSubnetPrefix
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
resource qveraNetworkProfile 'Microsoft.Network/networkProfiles@2020-11-01' = {
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
                  id: qveraSubnet.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

resource qveraContainerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: qveraContainerGroupName
  location: location
  dependsOn: [
    jumpbox_deployment
    qveraSubnet
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
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      } 
    ]
    volumes: [
      {
        name: 'myvolume'
        gitRepo: {
          repository: 'https://github.com/StevenBorg/ahds_demo_config'
          directory: '.'
        } 
      }
    ]
    osType: 'Linux'
    // With this commented out, we can't get the containerGroup.properties.ipAddress.ip value
    //  But this causes an error with the jump vm script
    //  WHOOAA!!!  Without this the container-group doesn't GET an ip address!
    networkProfile: {
      id: qveraNetworkProfile.id
      
    }

    restartPolicy: 'Always'
  }
}

output vm string = jumpbox_deployment.outputs.hostname
output vnet string = jumpbox_deployment.outputs.vnetName
output qveraSubnetName string = qveraSubnet.name
output qveraSubnetId string = qveraSubnet.id


