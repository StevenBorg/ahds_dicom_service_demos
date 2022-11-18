// This is not yet working.  Stopping work to do other things.



@description('Location for all resources.')
param location string = resourceGroup().location

@description('Administrator Password for Postres.')
@minLength(12)
@secure()
param adminPassword string

@description('Login name for Postgres.')
param adminLogin string = 'student'

@description('Name of PostresSQL server')
param postgresServer string = 'pg${uniqueString(resourceGroup().id)}' //'orthancpostgres2'

@description('Name of PostresSQL database')
param postgresDbName string = 'orthanc'

@description('Desired name of the storage account instance')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Desired name of the blob storage container')
param blobstorageName string = 'orthanc'


param serverEdition string = 'GeneralPurpose'
param skuSizeGB int = 128
param dbInstanceType string = 'Standard_D4ds_v4'
param haMode string = 'Disabled'
param availabilityZone string = '1'
param version string = '12'

// Create the necessary storage account resources to host Orthanc DICOM files
resource storageaccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storageaccount.name}/default/${blobstorageName}'
}


resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: postgresServer
  location: location
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword

    highAvailability: {
      mode: haMode
    }
    storage: {
      storageSizeGB: skuSizeGB
    }

    availabilityZone: availabilityZone
  }

  resource db 'databases@2022-03-08-preview' = {
    name: postgresDbName
  }
}

output name string = postgres.name
output id string = postgres.id
//output fqdn string = postgres.properties.fullyQualifiedDomainName
