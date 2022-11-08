@description('Location for all resources.')
param location string = resourceGroup().location

@description('Vnet Name')
param vnetName string

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

@description('Subnet Prefix')
param subnetPrefix string = '10.0.1.0/24'

@description('Subnet Name')
param subnetName string = 'radiologySubnet'

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
    subnetName: subnetName
    subnetPrefix: subnetPrefix
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

// resource qveraContainerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
//   name: qveraContainerGroupName
//   location: location
//   dependsOn: [
//     add_subnet
//   ]
//   properties: {
//     containers: [
//       {
//         name: containerName
//         properties: {
//           image: image
//           ports: [
//             {
//               port: port
//               protocol: 'TCP'
//             }
//           ]
//           resources: {
//             requests: {
//               cpu: cpuCores
//               memoryInGB: memoryInGb
//             }
//           }
//         }
//       } 
//     ]
//     volumes: [
//       {
//         name: 'myvolume'
//         gitRepo: {
//           repository: 'https://github.com/StevenBorg/ahds_demo_config'
//           directory: '.'
//         } 
//       }
//     ]
//     osType: 'Linux'
//     // With this commented out, we can't get the containerGroup.properties.ipAddress.ip value
//     //  But this causes an error with the jump vm script
//     //  WHOOAA!!!  Without this the container-group doesn't GET an ip address!
//     networkProfile: {
//       id: add_subnet.outputs.networkProfileId  //qveraNetworkProfile.id
//     }
//     restartPolicy: 'Always'
//   }
// }


//output vm string = jumpbox_deployment.outputs.hostname
//output vnet string = jumpbox_deployment.outputs.vnetName
output qveraSubnetName string = add_subnet.outputs.subnetName
output qveraSubnetId string = add_subnet.outputs.subnetId
