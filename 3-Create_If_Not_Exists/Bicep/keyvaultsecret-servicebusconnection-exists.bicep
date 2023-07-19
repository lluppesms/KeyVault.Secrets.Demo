// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret for a Service Bus connection
//   but ONLY if it does not exist in the existingSecretNames variable with ; before and aft.
// --------------------------------------------------------------------------------
param keyVaultName string = 'myKeyVault'
param secretName string = 'mySecretName'
param serviceBusName string = 'myservicebusname'
param accessKeyName string = 'RootManageSharedAccessKey'
param existingSecretNames string = ''
param enabledDate string = utcNow()
param expirationDate string = dateTimeAdd(utcNow(), 'P2Y')
param forceSecretCreation bool = false

// --------------------------------------------------------------------------------
var secretExists = contains(toLower(existingSecretNames), ';${toLower(trim(secretName))};')

resource serviceBusResource 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = { name: serviceBusName }
var serviceBusEndpoint = '${serviceBusResource.id}/AuthorizationRules/${accessKeyName}' 
var serviceBusKey = '${listKeys(serviceBusEndpoint, serviceBusResource.apiVersion).primaryKey}'
var serviceBusConnectionString = 'Endpoint=sb://${serviceBusResource.name}.servicebus.windows.net/;SharedAccessKeyName=${accessKeyName};SharedAccessKey=${serviceBusKey}' 

resource createSecretValue 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if (!secretExists || forceSecretCreation) {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: serviceBusConnectionString
    attributes: {
      exp: dateTimeToEpoch(expirationDate)
      nbf: dateTimeToEpoch(enabledDate)
    }
  }
}

var createMessage = secretExists ? 'Secret ${secretName} already exists!' : 'Added secret ${secretName}!'
output message string = secretExists && forceSecretCreation ? 'Secret ${secretName} already exists but was recreated!' : createMessage
output secretCreated bool = !secretExists
