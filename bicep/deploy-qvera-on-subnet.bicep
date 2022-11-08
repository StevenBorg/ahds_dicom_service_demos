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

@description('Container group name')
param containerGroupName string = 'contoso-qvera-containergroup'

@description('Container name')
param containerName string = 'qie-container'

@description('Container image to deploy. Should be of the form accountName/imagename:tag for images stored in Docker Hub or a fully qualified URI for a private registry like the Azure Container Registry.')
param image string = 'qvera/qie:5.0.50'

@description('Port to open on the container.')
param port int = 80

@description('The number of CPU cores to allocate to the container. Must be an integer.')
param cpuCores int = 2 //4

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 8 //16

@description('Vnet name')
param vnet_name string = 'ContosoVnet'

// var networkProfileName = 'aci-networkProfile'
// var interfaceConfigName = 'eth0'
// var interfaceIpConfig = 'ipconfigprofile1'



module jumpbox_deployment './deploy-vnet-with-jump-vm.bicep' = {
  name: 'jumpbox_deployment'
  params: {
    location: location
    adminPassword: adminPassword
    vnetName: vnet_name

  }
}

module add_container_subnet './add-subnet-for-containters-to-existing-vnet.bicep' = {
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


resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  dependsOn: [
    jumpbox_deployment
    add_container_subnet
  ]
  properties: {
    containers: [
      // {
      //   name: containerName
      //   properties: {
      //     image: image
      //     ports: [
      //       {
      //         port: port
      //         protocol: 'TCP'
      //       }
      //     ]
      //     environmentVariables: [
      //       {
      //         name: 'JAVA_OPTIONS'
      //         value: '-Xmx4096m'
      //       }
      //       {
      //         name: 'connection_driver'
      //         value: 'org.mariadb.jdbc.Driver'
      //       }
      //       {
      //         name: 'connection_url'
      //         value: 'jdbc:mariadb://10.0.1.4:3306/qie'
      //       }
      //       {
      //         name: 'connection_username'
      //         value: 'root'
      //       }
      //       {
      //         name: 'connection_password'
      //         value: 'root'
      //       }
      //       {
      //         name: 'hibernate_dialect'
      //         value: 'com.qvera.qie.persistence.MariaDB103UnicodeDialect'
      //       }
      //       {
      //         name: 'qie_haEngine'
      //         value: 'EnterpriseHAServiceImpl'
      //       }
      //     ]
      //     volumeMounts: [
      //       {
      //         name: 'myvolume'
      //         mountPath: '/tmp/database/'
      //       }
      //       {
      //         name: 'mariadbbackup'
      //         mountPath: '/java/qie/backup/'

      //       }
      //     ]
      //     resources: {
      //       requests: {
      //         cpu: cpuCores
      //         memoryInGB: memoryInGb
      //       }
      //     }
      //   }
      // }
      {
        name: 'mariadb'
        properties: {
          image: 'mariadb:10.5.1'
          ports: [
            {
              port: 3310
              protocol: 'TCP'
            }
          ]
          environmentVariables: [
            {
              name: 'MYSQL_DATABASE'
              value: 'qie'
            }
            {
              name: 'MYSQL_ROOT_PASSWORD'
              value: 'root'
            }
          ]
          volumeMounts: [
            {
              name: 'myvolume'
              mountPath: '/tmp/config/'
            }
            {
              name: 'mariadbvolume'
              mountPath: '/var/lib/mysql/'

            }
          ]
          resources: {
            requests: {
              cpu: 2
              memoryInGB: 4
            }
          }
          command: [
            '--init-file=/tmp/database/create_db.sql'
          ]
        }
      }
    ]
    volumes: [
      {
        name: 'myvolume'
        gitRepo: {
          repository: 'https://github.com/StevenBorg/ahds_demo_config'
          directory: '.'
        } 
      }
      {
        name: 'mariadbvolume'
        emptyDir: {}
      }
      {
        name: 'mariadbbackup'
        emptyDir: {}
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


