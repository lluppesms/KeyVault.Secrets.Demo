// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret for a IoT Hub Connection
//   but ONLY if not in the vault OR it does not match the value in the vault
// --------------------------------------------------------------------------------
param keyVaultName string = 'myKeyVault'
param secretName string = 'mySecretName'
param iotHubName string = 'myiothubname'
param enabledDate string = utcNow()
param expirationDate string = dateTimeAdd(utcNow(), 'P2Y')
param location string = resourceGroup().location
param utcValue string = utcNow()
param userManagedIdentityId string = ''

// --------------------------------------------------------------------------------
resource iotHubResource 'Microsoft.Devices/IotHubs@2021-07-02' existing = { name: iotHubName }
var iotKey = iotHubResource.listKeys().value[0].primaryKey
var secretValue = 'HostName=${iotHubResource.name}.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=${iotKey}'
// Note: the Powershell scripts that check for duplicate key values in the KeyVault do not like the & and ; characters at all so remove them for the check
var secretValueSanitized = replace(replace(secretValue, '&', '_'), ';', '_')

resource keyVaultSecretUpdateVerify 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'checkSecretValueAndUpdateIfChanged'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${ userManagedIdentityId }': {} }
  }
  properties: {
    azPowerShellVersion: '8.1'
    forceUpdateTag: utcValue
    retentionInterval: 'PT1H'
    timeout: 'PT5M'
    cleanupPreference: 'Always' // cleanupPreference: 'OnSuccess' or 'Always'
    arguments: ' -KeyVaultName ${keyVaultName} -SecretName ${secretName} -SecretValue ${secretValueSanitized} -EnabledDate ${enabledDate} -ExpirationDate ${expirationDate}'
    scriptContent: '''
      Param ([string] $KeyVaultName, [string] $SecretName, [string] $SecretValue, [string] $EnabledDate, [string] $ExpirationDate)
      $startDate = Get-Date
      $startTime = [System.Diagnostics.Stopwatch]::StartNew()
      $action = "SKIP"
      $message = "Evaluating $($KeyVaultName).$($SecretName)... "
      $SecretValue = $SecretValue.Replace('&','_').Replace(';','_')
      $secureStringValue = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
      $secretObject = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName
      $currentValue = ""
      $existingId = ""
      $existingVersion = ""
      if ($secretObject) {
        if ($secretObject.enabled) {
          $currentValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText
          $currentValue = $currentValue.Replace('&','_').Replace(';','_')
          $existingId = $secretObject.id
          $existingVersion = $secretObject.version
        }
      }
      if ($currentValue) {
        if ($currentValue.IndexOf($SecretValue) -eq 0 -and ($SecretValue.Length) -eq $currentValue.Length) {
          $message += "Value for $($KeyVaultName).$($SecretName) is already the supplied value!";
          $action = "SKIP"
        }
        else {
          $message += "A new version of should be created! The current version ($($existingVersion)) will be disabled!";
          $action = "UPDATE"
          Update-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Enable $False -Version $existingVersion
        }
      }
      else {
        $message = "Secret does not exist and a new secret should be created!";
        $action = "ADD"
      }

      if ($action -eq "ADD" -or $action -eq "UPDATE" ) {
        $notBeforeValue = [DateTime]::ParseExact($EnabledDate, "yyyyMMddTHHmmssZ", $null)
        $expiresValue = [DateTime]::ParseExact($ExpirationDate, "yyyy-MM-ddTHH:mm:ssZ", $null)
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureStringValue -NotBefore $notBeforeValue -Expires $expiresValue
      }

      $endDate = Get-Date
      $endTime = $startTime.Elapsed;
      $elapsedTime = "Elapsed Time: {0:HH:mm:ss}" -f ([datetime]$endTime.Ticks)
      $elapsedTime += "; Start: {0:HH:mm:ss}" -f ([datetime]$startDate)
      $elapsedTime += "; End: {0:HH:mm:ss}" -f ([datetime]$endDate)
      Write-Output $message
      Write-Output $action
      Write-Output $elapsedTime
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['message'] = $message
      $DeploymentScriptOutputs['action'] = $action
      $DeploymentScriptOutputs['elapsed'] = $elapsedTime
      '''
  }
}

output processingMessage string = keyVaultSecretUpdateVerify.properties.outputs.message
output actionTaken string = keyVaultSecretUpdateVerify.properties.outputs.action
output elapsedTime string = keyVaultSecretUpdateVerify.properties.outputs.elapsed
