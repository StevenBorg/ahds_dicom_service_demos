// This script deploys the on-prem solution 


@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location


// Deploy the jumpbox and vnet
module jumpbox_deployment './deploy-vnet-with-jump-vm.bicep' = {
  name: 'jumpbox_deployment'
  params: {
    location: location
    adminPassword: adminPassword
    vnetName: 'ContosoVnet'
    adminUsername: 'student'
  }
}

// This defines a resource for the vnet created above
resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: jumpbox_deployment.outputs.vnetName    
}

// Deploy qvera into a new subnet
module qvera_subnet './deploy-qvera-subnet.bicep' = {
  name: 'qvera_subnet'
  dependsOn: [
    vnet
  ]
  params: {
    location: location
    vnetName: jumpbox_deployment.outputs.vnetName
    adminPassword: adminPassword
    adminLogin: 'student'
    containerName: 'qie-container'
    cpuCores: 4
    memoryInGb: 8
    subnetName: 'qveraSubnet'
    subnetPrefix: '10.0.1.0/24'
  }
}

// Deploy qvera into a new subnet
module orthanc_subnet './deploy-orthanc-subnet.bicep' = {
  name: 'orthanc_subnet'
  dependsOn: [
    vnet
    qvera_subnet
  ]
  params: {
    location: location
    vnetName: jumpbox_deployment.outputs.vnetName
    containerName: 'orthanc-container'
    cpuCores: 2
    memoryInGb: 4
    subnetName: 'orthancSubnet'
    subnetPrefix: '10.0.2.0/24'

  }
}
