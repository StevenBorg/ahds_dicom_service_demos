@description('Admin password for SQL.')
@minLength(12)
@secure()
param adminPassword string

@description('Log in name to use.')
param adminLogin string = 'student'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.1.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'qveraSubnet'

@description('Container group name')
param containerGroupName string = 'contoso-qvera-containergroup'

@description('Container name')
param containerName string = 'qie-container'

@description('Container image to deploy. Should be of the form accountName/imagename:tag for images stored in Docker Hub or a fully qualified URI for a private registry like the Azure Container Registry.')
param image string = 'qvera/qie:latest'

@description('Port to open on the container.')
param port int = 80

@description('The number of CPU cores to allocate to the container. Must be an integer.')
param cpuCores int = 4 //4

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 16 //16

@description('Vnet name')
param vnet_name string = 'ContosoVnet'

// var networkProfileName = 'aci-networkProfile'
// var interfaceConfigName = 'eth0'
// var interfaceIpConfig = 'ipconfigprofile1'



module jumpbox_deployment '../../../bicep/deploy-vnet-with-jump-vm.bicep' = {
  name: 'jumpbox_deployment'
  params: {
    location: location
    adminPassword: adminPassword
    vnetName: vnet_name

  }
}

module add_container_subnet '../../../bicep/add-subnet-for-containters-to-existing-vnet.bicep' = {
  name: 'container_subnet'
  dependsOn: [
    jumpbox_deployment
  ]
  params: {
    location: location
    subnet1Name: subnet1Name
    subnet1Prefix: subnet1Prefix
  }
}

// Deploy SQL (Please note that it's NOT secure as we're using a password to connect)
module sql './create-sql-db-for-qie.bicep' = {
  name: 'sqldb'
  params: {
    location: location
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    sqlDBName: 'qie'
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  dependsOn: [
    jumpbox_deployment
    add_container_subnet
    sql
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
              name: 'JAVA_OPTIONS'
              value: '-Xmx4096m'
            }
            {
              name: 'connection_driver'
              value: 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
            }
            {
              name: 'connection_url'
              value: 'jdbc:sqlserver://${sql.outputs.sqlServerName}.database.windows.net:1433;database=qie;integratedSecurity=false'
            }
            {
              name: 'connection_username'
              value: 'student@${sql.outputs.sqlServerName}'
            }
            {
              name: 'connection_password'
              value: adminPassword
            }
            {
              name: 'hibernate_dialect'
              value: 'com.qvera.qie.persistence.SQLServer2019UnicodeDialect'
            }
          ]
          volumeMounts: [
            {
              name: 'copygitrepo'
              mountPath: '/tmp/database/'
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
    volumes: [
      {
        name: 'copygitrepo'
        gitRepo: {
          repository: 'https://github.com/StevenBorg/ahds_demo_config'
          directory: '.'
        } 
      }
    ]
    osType: 'Linux'
    // With this commented out, we can't get the containerGroup.properties.ipAddress.ip value
    //  But this causes an error with the jump vm script
    //  WHOOAA!!!  Without this the container-group doesn't GET an ip address!
    networkProfile: {
      id: add_container_subnet.outputs.networkProfileId  //networkProfile.id
      
    }

    restartPolicy: 'Always'
  }
}

output vm string = jumpbox_deployment.outputs.hostname
output vnet string = jumpbox_deployment.outputs.vnetName
output subnetName string = add_container_subnet.outputs.subnetName
output subnetId string = add_container_subnet.outputs.subnetId


