// --------------------------------------------------------------------------------
// Key Vault Secrets - Main Bicep File for deploying many Key Vault Secrets
// --------------------------------------------------------------------------------
param appName string = 'keyvault-secrets'
@allowed(['azd','gha','azdo','dev','demo','design','qa','stg','ct','prod'])
param environmentCode string = 'demo'
param location string = 'eastus'
param keyVaultOwnerUserId string = ''
param forceKeyVaultEntryCreation string = 'false'
param runDateTime string = utcNow()

// --------------------------------------------------------------------------------
var deploymentSuffix = '-Exists-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Application: appName
  Environment: environmentCode
}
var forceSecretCreation = contains(toLower(forceKeyVaultEntryCreation), 't') || contains(toLower(forceKeyVaultEntryCreation), 'y')

// --------------------------------------------------------------------------------
module resourceNames '../../infra/resourcenames.bicep' = {
  name: 'resource-names${deploymentSuffix}'
  params: {
    appName: appName
    environmentCode: environmentCode
  }
}

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

module keyVaultSecretList 'keyvault-list-secret-names.bicep' = {
  name: 'keyVault-Secret-List-Names${deploymentSuffix}'
  dependsOn: [ keyVaultModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    location: location
    userManagedIdentityId: keyVaultModule.outputs.userManagedIdentityId
  }
}

module keyVaultGeneric 'keyvaultsecret-generic-exists.bicep' = {
  name: 'keyVault-Generic${deploymentSuffix}'
  dependsOn: [ keyVaultSecretList ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'GenericSecret'
    secretValue: 'NotVerySecretForThisDemo'
    existingSecretNames: keyVaultSecretList.outputs.secretNameList
    forceSecretCreation: forceSecretCreation
  }
}

module keyVaultStorage 'keyvaultsecret-storageconnection-exists.bicep' = {
  name: 'keyVault-Storage${deploymentSuffix}'
  dependsOn: [ keyVaultSecretList, keyVaultGeneric ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'BlobStorageConnectionString'
    storageAccountName: resourceNames.outputs.blobStorageAccountName
    existingSecretNames: keyVaultSecretList.outputs.secretNameList
    forceSecretCreation: forceSecretCreation
  }
}

module keyVaultServiceBus 'keyvaultsecret-servicebusconnection-exists.bicep' = {
  name: 'keyVault-ServiceBus${deploymentSuffix}'
  dependsOn: [ keyVaultSecretList, keyVaultStorage ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'ServiceBusConnectionString'
    serviceBusName: resourceNames.outputs.serviceBusName
    existingSecretNames: keyVaultSecretList.outputs.secretNameList
    forceSecretCreation: forceSecretCreation
  }
}

module keyVaultSignalR 'keyvaultsecret-signalrconnection-exists.bicep' = {
  name: 'keyVault-SignalR${deploymentSuffix}'
  dependsOn: [ keyVaultSecretList, keyVaultServiceBus ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'SignalRConnectionString'
    signalRName: resourceNames.outputs.signalRName
    existingSecretNames: keyVaultSecretList.outputs.secretNameList
    forceSecretCreation: forceSecretCreation
  }
}

// module keyVaultIoTHub 'keyvaultsecret-iothubconnection-exists.bicep' = {
//   name: 'keyVault-IoTHub${deploymentSuffix}'
//   dependsOn: [ keyVaultSecretList, keyVaultSignalR ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     secretName: 'IotHubConnectionString'
//     iotHubName: resourceNames.outputs.iotHubName
//     existingSecretNames: keyVaultSecretList.outputs.secretNameList
//     forceSecretCreation: forceSecretCreationFlag
//   }
// }

// module keyVaultCosmos 'keyvaultsecret-cosmosconnection-exists.bicep' = {
//   name: 'keyVault-Cosmos${deploymentSuffix}'
//   dependsOn: [ keyVaultSecretList, keyVaultIoTHub ]
//   params: {
//     keyVaultName: keyVaultModule.outputs.name
//     secretName: 'CosmosConnectionString'
//     cosmosAccountName: resourceNames.outputs.cosmosAccountName
//     existingSecretNames: keyVaultSecretList.outputs.secretNameList
//     forceSecretCreation: forceSecretCreationFlag
//   }
// }

