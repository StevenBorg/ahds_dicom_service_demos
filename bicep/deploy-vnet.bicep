@description('Location for all resources.')
param location string = resourceGroup().location

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


var networkProfileName = 'aci-networkProfile'
var interfaceConfigName = 'eth0'
var interfaceIpConfig = 'ipconfigprofile1'


resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

// Delegation is required to allow ContainerGroups to have control over deployed containers
//  For more information see: https://learn.microsoft.com/en-us/azure/virtual-network/subnet-delegation-overview
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: subnet1Name
  parent: vnet
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
                  id: subnet.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

output vnetName string = vnetName
output vnetAddressPrefix string = vnetAddressPrefix
output vnetId string = vnet.id
output subnetName string = subnet.name
output subnetId string = subnet.id
output subnetAddressPrefix string = subnet1Prefix
output networkProfileName string = networkProfile.name
output networkProfileId string = networkProfile.id
//output vnetResourceGuid string = vnet.properties.resourceGuid
