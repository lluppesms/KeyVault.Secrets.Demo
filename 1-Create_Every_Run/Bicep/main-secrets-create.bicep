// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secrets EVERY time (making duplicates)
// --------------------------------------------------------------------------------
param appName string = 'keyvault-secrets'
@allowed(['azd','gha','azdo','dev','demo','design','qa','stg','ct','prod'])
param environmentCode string = 'demo'
param location string = 'eastus'
param keyVaultOwnerUserId string = ''
param runDateTime string = utcNow()

// --------------------------------------------------------------------------------
var deploymentSuffix = '-Create-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Application: appName
  Environment: environmentCode
}

// --------------------------------------------------------------------------------
module resourceNames '../../infra/resourcenames.bicep' = {
  name: 'resource-names${deploymentSuffix}'
  params: {
    appName: appName
    environmentCode: environmentCode
  }
}

// --------------------------------------------------------------------------------
module keyVaultModule '../../infra/keyvault.bicep' = {
  name: 'keyVault${deploymentSuffix}'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    adminUserObjectIds: [ keyVaultOwnerUserId ]
    applicationUserObjectIds: [ ]
    location: location
    commonTags: commonTags
  }
}

// --------------------------------------------------------------------------------
var storageAccountSecretName = 'BlobStorageConnectionString'
module keyVaultSecretStorageCreate 'keyvaultsecret-storageconnection-create.bicep' = {
  name: 'keyVaultSecret-Storage${deploymentSuffix}'
  dependsOn: [ keyVaultModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    storageAccountName: resourceNames.outputs.blobStorageAccountName
    secretName: storageAccountSecretName
  }
}

// --------------------------------------------------------------------------------
var serviceBusSecretName = 'ServiceBusConnectionString'
var serviceBusAccessKeyName = 'RootManageSharedAccessKey'
module keyVaultSecretServiceBusCreate 'keyvaultsecret-servicebusconnection-create.bicep' = {
  name: 'keyVaultSecret-ServiceBus${deploymentSuffix}'
  dependsOn: [ keyVaultModule, keyVaultSecretStorageCreate ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    serviceBusName: resourceNames.outputs.serviceBusName
    accessKeyName: serviceBusAccessKeyName
    secretName: serviceBusSecretName
  }
}

// --------------------------------------------------------------------------------
var signalRSecretName = 'SignalRConnectionString'
module keyVaultSecretSignalRCreate 'keyvaultsecret-signalrconnection-create.bicep' = {
  name: 'keyVaultSecret-SignalR${deploymentSuffix}'
  dependsOn: [ keyVaultModule, keyVaultSecretServiceBusCreate ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    signalRName: resourceNames.outputs.signalRName
    secretName: signalRSecretName
  }
}

// --------------------------------------------------------------------------------
var genericSecretName = 'GenericSecret'
var genericSecretValue = 'NotMuchOfASecret'
module keyVaultSecretGenericCreate 'keyvaultsecret-generic-create.bicep' = {
  name: 'keyVaultSecret-Generic${deploymentSuffix}'
  dependsOn: [ keyVaultModule, keyVaultSecretSignalRCreate ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: genericSecretName
    secretValue: genericSecretValue
  }
}

// // --------------------------------------------------------------------------------
// var iotHubSecretName = 'IotHubConnectionString'
// module keyVaultSecretIoTHubCreate 'keyvaultsecret-iothubconnection-create.bicep' = {
//   name: 'keyVaultSecret-IoTHub${deploymentSuffix}'
//   dependsOn: [ keyVaultModule, keyVaultSecretGenericCreate ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     iotHubName: resourceNames.outputs.iotHubName
//     secretName: iotHubSecretName
//   }
// }

// // --------------------------------------------------------------------------------
// var cosmosAccountSecretName = 'CosmosConnectionString'
// module keyVaultSecretCosmosCreate 'keyvaultsecret-cosmosconnection-create.bicep' = {
//   name: 'keyVaultSecret-Cosmos${deploymentSuffix}'
//   dependsOn: [ keyVaultModule, keyVaultSecretIoTHubCreate ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     cosmosAccountName: resourceNames.outputs.cosmosAccountName
//     secretName: cosmosAccountSecretName
//   }
// }

