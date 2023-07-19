// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secrets for many things
//   but ONLY if it does not already exist or the value is different.
// --------------------------------------------------------------------------------
// This has terrible performance.... each of the keys is taking about ~2 minutes 
// to check and run the create. It appears to be because of spinning up a 
// Powershell environment to run the script because the script runs in ~1 second.
// --------------------------------------------------------------------------------
param appName string = 'keyvault-secrets'
@allowed(['azd','gha','azdo','dev','demo','design','qa','stg','ct','prod'])
param environmentCode string = 'demo'
param location string = 'eastus'
param keyVaultOwnerUserId string = ''
param runDateTime string = utcNow()

// --------------------------------------------------------------------------------
var deploymentSuffix = '-Compare-${runDateTime}'
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
  name: 'keyVault-Create${deploymentSuffix}'
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
module keyVaultSecretStorageCompare 'keyvaultsecret-storageconnection-compare.bicep' = {
  name: 'keyVaultSecret-Storage${deploymentSuffix}'
  dependsOn: [ keyVaultModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    storageAccountName: resourceNames.outputs.blobStorageAccountName
    secretName: storageAccountSecretName
    location: location
    userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
  }
}

// --------------------------------------------------------------------------------
var serviceBusSecretName = 'ServiceBusConnectionString'
var serviceBusAccessKeyName = 'RootManageSharedAccessKey'
module keyVaultSecretServiceBusCompare 'keyvaultsecret-servicebusconnection-compare.bicep' = {
  name: 'keyVaultSecret-ServiceBus${deploymentSuffix}'
  dependsOn: [ keyVaultModule, keyVaultSecretStorageCompare ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    serviceBusName: resourceNames.outputs.serviceBusName
    accessKeyName: serviceBusAccessKeyName
    secretName: serviceBusSecretName
    location: location
    userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
  }
}

// --------------------------------------------------------------------------------
var signalRSecretName = 'SignalRConnectionString'
module keyVaultSecretSignalRCompare 'keyvaultsecret-signalrconnection-compare.bicep' = {
  name: 'keyVaultSecret-SignalR${deploymentSuffix}'
  dependsOn: [ keyVaultModule, keyVaultSecretServiceBusCompare ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    signalRName: resourceNames.outputs.signalRName
    secretName: signalRSecretName
    location: location
    userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
  }
}

// --------------------------------------------------------------------------------
var genericSecretName = 'GenericSecret'
var genericSecretValue = 'NotMuchOfASecret'
module keyVaultSecretGenericCompare 'keyvaultsecret-generic-compare.bicep' = {
  name: 'keyVaultSecret-Generic${deploymentSuffix}'
  dependsOn: [ keyVaultModule, keyVaultSecretSignalRCompare ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: genericSecretName
    secretValue: genericSecretValue
    location: location
    userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
  }
}

// // --------------------------------------------------------------------------------
// var iotHubSecretName = 'IotHubConnectionString'
// module keyVaultSecretIoTHubCompare 'keyvaultsecret-iothubconnection-compare.bicep' = {
//   name: 'keyVaultSecret-IoTHub${deploymentSuffix}'
//   dependsOn: [ keyVaultModule, keyVaultSecretGenericCompare ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     iotHubName: resourceNames.outputs.iotHubName
//     secretName: iotHubSecretName
//     location: location
//     userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
//   }
// }

// // --------------------------------------------------------------------------------
// var cosmosAccountSecretName = 'CosmosConnectionString'
// module keyVaultSecretCosmosCompare 'keyvaultsecret-cosmosconnection-compare.bicep' = {
//   name: 'keyVaultSecret-Cosmos${deploymentSuffix}'
//   dependsOn: [ keyVaultModule, keyVaultSecretIoTHubCompare ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     cosmosAccountName: resourceNames.outputs.cosmosAccountName
//     secretName: cosmosAccountSecretName
//     location: location
//     userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
//   }
// }

