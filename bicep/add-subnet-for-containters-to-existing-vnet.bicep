@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.0.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'radiologySubnet'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Vnet name')
param vnet_name string = 'ContosoVnet'

var networkProfileName = 'aci-networkProfile'
var interfaceConfigName = 'eth0'
var interfaceIpConfig = 'ipconfigprofile1'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnet_name
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
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
                  id: subnet1.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

output subnetName string = subnet1.name
output subnetId string = subnet1.id
output networkProfileName string = networkProfile.name
output networkProfileId string = networkProfile.id
