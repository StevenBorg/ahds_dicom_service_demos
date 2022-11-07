@description('Location for all resources.')
param location string = resourceGroup().location

@description('Vnet Name')
param vnetName string

// This defines a resource for an EXISTING vnet! (must already exist)
resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
}

//Create a subnet for qvera on existing vnet
module add_subnet './add-subnet-for-containters-to-existing-vnet.bicep' = {
  name: 'qvera_subnet'
  dependsOn: [
    vnet
  ]
  params: {
    location: location
    vnet_name: vnetName
    subnetName: 'qveraSubnet'
    subnetPrefix: '10.0.0.0/24'
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


resource qveraContainerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: 'qveraContainerGroup'
  location: location
  dependsOn: [
    add_subnet
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
              cpu: 2
              memoryInGB: 8
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
