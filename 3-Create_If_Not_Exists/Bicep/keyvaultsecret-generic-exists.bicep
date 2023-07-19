// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret
//   but ONLY if it does not exist in the existingSecretNames variable with ; before and aft.
// --------------------------------------------------------------------------------
param keyVaultName string = 'myKeyVault'
param secretName string = 'mySecretName'
@secure()
param secretValue string = ''
param existingSecretNames string = ''
param enabledDate string = utcNow()
param expirationDate string = dateTimeAdd(utcNow(), 'P2Y')
param forceSecretCreation bool = false

// --------------------------------------------------------------------------------
var secretExists = contains(toLower(existingSecretNames), ';${toLower(trim(secretName))};')

resource createSecretValue 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if (!secretExists || forceSecretCreation) {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
    attributes: {
      exp: dateTimeToEpoch(expirationDate)
      nbf: dateTimeToEpoch(enabledDate)
    }
  }
}

var createMessage = secretExists ? 'Secret ${secretName} already exists!' : 'Added secret ${secretName}!'
output message string = secretExists && forceSecretCreation ? 'Secret ${secretName} already exists but was recreated!' : createMessage
output secretCreated bool = !secretExists
