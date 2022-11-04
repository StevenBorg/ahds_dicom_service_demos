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





output vm string = jumpbox_deployment.outputs.hostname
output vnet string = jumpbox_deployment.outputs.vnetName
output subnet string = subnet1.name
output subnetId string = subnet1.id


