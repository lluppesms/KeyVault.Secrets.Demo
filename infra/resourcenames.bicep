// --------------------------------------------------------------------------------
// Bicep file that builds all the resource names used by other Bicep templates
// --------------------------------------------------------------------------------
param appName string = ''
@allowed(['azd','gha','azdo','dev','demo','design','qa','stg','ct','prod'])
param environmentCode string = 'demo'

// --------------------------------------------------------------------------------
var lowerAppName = replace(toLower(appName), ' ', '')
var sanitizedAppName = replace(replace(lowerAppName, '-', ''), '_', '')
var sanitizedEnvironment = toLower(environmentCode)

// --------------------------------------------------------------------------------
output blobStorageConnectionName string     = toLower('${sanitizedAppName}-${sanitizedEnvironment}-blobconnection')
output cosmosAccountName string             = toLower('${sanitizedAppName}-${sanitizedEnvironment}-cosmos')
output serviceBusName string                = toLower('${sanitizedAppName}-${sanitizedEnvironment}-svcbus')
output iotHubName string                    = toLower('${sanitizedAppName}-${sanitizedEnvironment}-iothub')
output signalRName string                   = toLower('${sanitizedAppName}-${sanitizedEnvironment}-signal')

// Key Vaults and Storage Accounts can only be 24 characters long
var keyVaultName                            = take(toLower('${sanitizedAppName}${sanitizedEnvironment}vault'), 24)
output keyVaultName string                  = keyVaultName
output keyVaultUserAssignedIdentity string  = '${keyVaultName}-cicd'
var baseStorageName                         = toLower('${sanitizedAppName}${sanitizedEnvironment}str')
output blobStorageAccountName string        = take('${baseStorageName}blob', 24)
output iotStorageAccountName string         = take('${baseStorageName}iothub', 24)
