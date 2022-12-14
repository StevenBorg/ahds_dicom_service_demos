@description('Username for the Virtual Machine.')
param adminUsername string = 'student'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
param OSsku string = 'win10-21h2-pro-g2' 

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
param OSoffer string = 'Windows-10' 

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
param OSpublisher string = 'MicrosoftWindowsDesktop' 

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string = 'jump-vm'

@description('VNet name')
param vnetName string = 'ContosoVnet'

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.0.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'jumpSubnet'

var storageAccountName = 'bootdiags${uniqueString(resourceGroup().id)}'
var nicName = 'myVMNic'
var addressPrefix = vnetAddressPrefix
var subnetName = subnet1Name
var subnetPrefix = subnet1Prefix
var networkSecurityGroupName = 'default-NSG'

var networkProfileName = 'aci-networkProfile'
var interfaceConfigName = 'eth0'
var interfaceIpConfig = 'ipconfigprofile1'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-4545' //3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '4545' //'3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: securityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: OSpublisher
        offer: OSoffer
        sku: OSsku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stg.properties.primaryEndpoints.blob
      }
    }
  }
}

// // Network profiles are automatically created, but it was in the demo, so I copied it over...
// resource networkProfile 'Microsoft.Network/networkProfiles@2020-11-01' = {
//   name: networkProfileName
//   location: location
//   properties: {
//     containerNetworkInterfaceConfigurations: [
//       {
//         name: interfaceConfigName
//         properties: {
//           ipConfigurations: [
//             {
//               name: interfaceIpConfig
//               properties: {
//                 subnet: {
//                   id: vnet.properties.subnets[0].id 
//                 }
//               }
//             }
//           ]
//         }
//       }
//     ]
//   }
// }

output hostname string = pip.properties.dnsSettings.fqdn
//output hostip string = pip.properties.servicePublicIPAddress.properties.ipAddress
output vnetName string = vnetName
output vnetAddressPrefix string = addressPrefix
output vnetId string = vnet.id
output subnetName string = vnet.properties.subnets[0].name //subnet.name
output subnetId string = vnet.properties.subnets[0].id
output subnetAddressPrefix string = subnetPrefix
// output networkProfileName string = networkProfile.name
// output networkProfileId string = networkProfile.id
//output foo string = vnet.properties.subnets[0].properties.ipConfigurationProfiles[0].id

