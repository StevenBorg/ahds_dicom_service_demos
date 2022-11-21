
@description('Generated from /subscriptions/49a8ebce-39d4-4b3d-85f4-8d81c9ebc6cb/resourceGroups/sjbUploader/providers/Microsoft.Web/serverFarms/sjbAppService')
resource sjbAppService 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'sjbAppService'
  kind: 'elastic'
  location: 'East US'
  properties: {
    serverFarmId: 16638
    name: 'sjbAppService'
    workerSize: 'D1'
    workerSizeId: 3
    currentWorkerSize: 'D1'
    currentWorkerSizeId: 3
    currentNumberOfWorkers: 1
    webSpace: 'sjbUploader-EastUSwebspace-Linux'
    planName: 'VirtualDedicatedPlan'
    computeMode: 'Dedicated'
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 1
    isSpot: false
    kind: 'elastic'
    reserved: true
    isXenon: false
    hyperV: false
    mdmId: 'waws-prod-blu-365_16638'
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    size: 'EP1'
    family: 'EP'
    capacity: 1
  }
}
@description('Generated from /subscriptions/49a8ebce-39d4-4b3d-85f4-8d81c9ebc6cb/resourceGroups/sjbUploader/providers/Microsoft.Web/sites/uploaderfa')
resource uploaderfa 'Microsoft.Web/sites@2022-03-01' = {
  name: 'uploaderfa'
  kind: 'functionapp,linux,container'
  location: 'East US'
  properties: {
    name: 'uploaderfa'
    webSpace: 'sjbUploader-EastUSwebspace-Linux'
    selfLink: 'https://waws-prod-blu-365.api.azurewebsites.windows.net:454/subscriptions/49a8ebce-39d4-4b3d-85f4-8d81c9ebc6cb/webspaces/sjbUploader-EastUSwebspace-Linux/sites/uploaderfa'
    enabled: true
    adminEnabled: true
    siteProperties: {
      metadata: null
      properties: [
        {
          name: 'LinuxFxVersion'
          value: 'DOCKER|dicomoss.azurecr.io/dicom-uploader:latest'
        }
        {
          name: 'WindowsFxVersion'
          value: null
        }
      ]
      appSettings: null
    }
    csrs: []
    hostNameSslStates: [
      {
        name: 'uploaderfa.azurewebsites.net'
        sslState: 'Disabled'
        ipBasedSslState: 'NotConfigured'
        hostType: 'Standard'
      }
      {
        name: 'uploaderfa.scm.azurewebsites.net'
        sslState: 'Disabled'
        ipBasedSslState: 'NotConfigured'
        hostType: 'Repository'
      }
    ]
    serverFarmId: '/subscriptions/49a8ebce-39d4-4b3d-85f4-8d81c9ebc6cb/resourceGroups/sjbUploader/providers/Microsoft.Web/serverfarms/sjbAppService'
    reserved: true
    isXenon: false
    hyperV: false
    storageRecoveryDefaultState: 'Running'
    contentAvailabilityState: 'Normal'
    runtimeAvailabilityState: 'Normal'
    dnsConfiguration: {
    }
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOCKER|dicomoss.azurecr.io/dicom-uploader:latest'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    deploymentId: 'uploaderfa'
    sku: 'ElasticPremium'
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '9852AE6C3F0A7816066A94935E682B27989ED412D393952B0CAFF36A9F0723A5'
    kind: 'functionapp,linux,container'
    inboundIpAddress: '20.119.8.25'
    possibleInboundIpAddresses: '20.119.8.25'
    ftpUsername: 'uploaderfa\\$uploaderfa'
    ftpsHostName: 'ftps://waws-prod-blu-365.ftp.azurewebsites.windows.net/site/wwwroot'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    siteDisabledReason: 0
    homeStamp: 'waws-prod-blu-365'
    httpsOnly: false
    redundancyMode: 'None'
    privateEndpointConnections: []
    eligibleLogCategories: 'FunctionAppLogs'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
    defaultHostNameScope: 'Global'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

