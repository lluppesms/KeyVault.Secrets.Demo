// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret for a IoT Hub Connection
//   but ONLY if it does not exist in the existingSecretNames variable with ; before and aft.
// --------------------------------------------------------------------------------
param keyVaultName string = 'myKeyVault'
param secretName string = 'mySecretName'
param iotHubName string = 'myiothubname'
param existingSecretNames string = ''
param enabledDate string = utcNow()
param expirationDate string = dateTimeAdd(utcNow(), 'P2Y')
param forceSecretCreation bool = false

// --------------------------------------------------------------------------------
var secretExists = contains(toLower(existingSecretNames), ';${toLower(trim(secretName))};')

resource iotHubResource 'Microsoft.Devices/IotHubs@2021-07-02' existing = { name: iotHubName }
var iotKey = iotHubResource.listKeys().value[0].primaryKey
var iotHubConnectionString = 'HostName=${iotHubResource.name}.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=${iotKey}'

resource createSecretValue 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if (!secretExists || forceSecretCreation) {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: iotHubConnectionString
    attributes: {
      exp: dateTimeToEpoch(expirationDate)
      nbf: dateTimeToEpoch(enabledDate)
    }
  }
}

var createMessage = secretExists ? 'Secret ${secretName} already exists!' : 'Added secret ${secretName}!'
output message string = secretExists && forceSecretCreation ? 'Secret ${secretName} already exists but was recreated!' : createMessage
output secretCreated bool = !secretExists
