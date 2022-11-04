@description('Username for the Virtual Machine.')
param adminUsername string = 'student'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('VNet name')
param vnetName string = 'ContosoVnet'

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.0.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'radiologySubnet'

@description('Location for all resources.')
param location string = resourceGroup().location

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

@description('Name of the virtual machine.')
param vmName string = 'jump-vm'

module vnet_deployment './deploy-vnet-with-jump-vm-test.bicep' = {
  name: 'vnet_deployment'
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Name: subnet1Name
    subnet1Prefix: subnet1Prefix
    vmName: vmName
  }
}

// module vnet_deployment './deploy-vnet.bicep' = {
//   name: 'vnet_deployment'
//   params: {
//     location: location
//     // adminUsername: adminUsername
//     // adminPassword: adminPassword
//     vnetName: vnetName
//     vnetAddressPrefix: vnetAddressPrefix
//     subnet1Name: subnet1Name
//     subnet1Prefix: subnet1Prefix
//   }
// }

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  dependsOn: [
    vnet_deployment
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
    // With this commented out, we can't get the containerGroup.properties.ipAddress.ip value
    //  But this causes an error with the jump vm script
    //  WHOOAA!!!  Without this the container-group doesn't GET an ip address!
    // networkProfile: {
    //   //id: vnet_deployment.outputs.networkProfileId 
      
    // }

    restartPolicy: 'Always'
  }
}

//output qvera_ip_address string = containerGroup.properties.ipAddress.ip
//output jump_vm_hostname string = vnet_deployment.outputs.hostname
//output jump_vm_hostip string = vnet_deployment.outputs.hostip



