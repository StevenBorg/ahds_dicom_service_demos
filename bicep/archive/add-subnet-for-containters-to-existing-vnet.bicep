@description('Subnet Prefix')
param subnetPrefix string = '10.0.0.0/24'

@description('Subnet Name')
param subnetName string = 'radiologySubnet'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Vnet name')
param vnet_name string

@description('delegations')
param delegations array = [
  {
    name: 'DelegationService'
    properties: {
      serviceName: 'Microsoft.ContainerInstance/containerGroups'
    }
  }
]

var networkProfileName = '${subnetName}-networkProfile' //'aci-networkProfile'
var interfaceConfigName = 'eth0'
var interfaceIpConfig = '${subnetName}-ipconfigprofile1'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnet_name
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefix
    delegations: delegations 
    // [
    //   {
    //     name: 'DelegationService'
    //     properties: {
    //       serviceName: 'Microsoft.ContainerInstance/containerGroups'
    //     }
    //   }
    // ]
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

output subnetName string = subnet.name
output subnetId string = subnet.id
output networkProfileName string = networkProfile.name
output networkProfileId string = networkProfile.id
