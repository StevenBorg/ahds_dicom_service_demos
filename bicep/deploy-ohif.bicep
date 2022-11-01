// Bicep file to deploy OHIF and connect to an existing DICOM service
//    Used by other deployments, such as deploying OHIF with a DICOM service

@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('Desired name of the storage account instance')
param storageAccountName string

@description('Your existing DICOM service URL (format: https://yourworkspacename-yourdicomservicename.dicom.azurehealthcareapis.com)')
param dicomServiceUrl string = '<The URL to your DICOM service>'

@description('Your existing Azure AD tenant ID (format: 72xxxxxf-xxxx-xxxx-xxxx-xxxxxxxxxxx)')
param aadTenantId string = '<Your Azure subscription AAD Tenant Id>'

@description('Your existing Application (client) ID (format: 1f8xxxxx-dxxx-xxxx-xxxx-9exxxxxxxxxx)')
param applicationClientId string = '<Your Application Client ID>'


// Create the necessary storage account resources to host a static web site
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_ZRS'
    //tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: '${storageAccountName}/default'
  // sku: {
  //   name: 'Standard_ZRS'
  //   tier: 'Standard'
  // }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
  dependsOn: [
    storageAccount
  ]
}

resource storageAccountName_default_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storageAccountName}/default/$web'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccountName_default
    storageAccount
  ]
}

resource UploadOhifFilesToBlob 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'UploadOhifFilesToBlob'
  location: location
  kind: 'AzureCLI'
  properties: {
    forceUpdateTag: '1'
    azCliVersion: '2.9.1'
    timeout: 'PT30M'
    arguments: '${storageAccountName} $web ${listKeys(storageAccount.id, '2022-05-01').keys[0].value} ${dicomServiceUrl} ${aadTenantId} ${applicationClientId}'
    scriptContent: 'wget -O ohif.zip https://github.com/microsoft/dicom-ohif/blob/main/build/ohif.zip?raw=true ; unzip ohif.zip -d ohiffiles ; sed -i "s|%dicom-service-url%|$4|g" ./ohiffiles/app-config.js ; sed -i "s|%aad-tenant-id%|$5|g" ./ohiffiles/app-config.js ; sed -i "s|%application-client-id%|$6|g" ./ohiffiles/app-config.js ; az storage blob upload-batch -d $2 -s ./ohiffiles --account-name $1 --account-key $3'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    storageAccountName_default_web
  ]
}

resource SetContainerAsWebSite 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'SetContainerAsWebSite'
  location: location
  kind: 'AzureCLI'
  properties: {
    forceUpdateTag: '1'
    azCliVersion: '2.9.1'
    timeout: 'PT30M'
    arguments: '${storageAccountName} $web ${listKeys(storageAccount.id, '2022-05-01').keys[0].value}'
    scriptContent: 'az storage blob service-properties update --static-website true --index-document \'index.html\' --404-document \'index.html\' --account-name $1 --account-key $3'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    storageAccountName_default_web
  ]
}

output storageAccountWebEndpoint string = reference(storageAccount.id, '2022-05-01').primaryEndpoints.web
output blobEndpoint string = reference(storageAccount.id, '2022-05-01').primaryEndpoints.blob
