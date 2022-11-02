@description('VNet name')
param vnetName string = 'VNet1'

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('QIE container name')
param qName string = 'QIE'

module vnet_deployment './deploy-simple-vnet.bicep' = {
  name: 'vnet_deployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
  }
}


resource qvera_container 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: qName
  properties: {
    containers: 
    osType: 
  }
}
