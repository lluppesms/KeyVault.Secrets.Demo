Function SetKeyVaultSecret
{
  Param ([string] $KeyVaultName, [string] $SecretName, [string] $SecretValue)
  $SecretValue = $SecretValue.Replace('&','_').Replace(';','_')
  $secureStringValue = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
  $secretObject = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName
  $currentValue = ""
  $existingVersion = ""
  if ($secretObject) {
    $currentValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText
    $currentValue = $currentValue.Replace('&','_').Replace(';','_')
    $existingVersion = $secretObject.version
  }
  if ($currentValue) {
    if (!($currentValue.IndexOf($SecretValue) -eq 0 -and ($SecretValue.Length) -eq $currentValue.Length)) {
      Update-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Enable $False -Version $existingVersion
    }
  }
  else {
    $notBeforeValue = Get-Date
    $expiresValue = $notBeforeValue.AddYears(2)
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureStringValue -NotBefore $notBeforeValue -Expires $expiresValue
  }
}

SetKeyVaultSecret -KeyVaultName myVault -SecretName mySecret1 -SecretValue myValue1
SetKeyVaultSecret -KeyVaultName myVault -SecretName mySecret2 -SecretValue myValue2
SetKeyVaultSecret -KeyVaultName myVault -SecretName mySecret3 -SecretValue myValue3
