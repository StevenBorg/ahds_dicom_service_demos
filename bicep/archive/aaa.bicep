@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Subnet 1 Name')
param vnetName string = 'ContosoVnet'


// Deploy the jumpbox and vnet
module jumpbox_deployment './deploy-vnet-with-jump-vm.bicep' = {
  name: 'jumpbox_deployment'
  params: {
    location: location
    adminPassword: adminPassword
    vnetName: vnetName
  }
}

// This defines a resource for the vnet created above
resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
}

// Deploy the jumpbox and vnet
module qvera_subnet './add-subnet-for-containters-to-existing-vnet.bicep' = {
  name: 'qvera_subnet'
  params: {
    location: location
    subnet1Name: 'qveraSubnet'
    subnet1Prefix: '10.0.1.0/24'
    vnet_name: vnetName
  }
}

