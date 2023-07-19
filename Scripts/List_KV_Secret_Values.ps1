# ----------------------------------------------------------------------------------------------------
# Pass in a KV Name and this script will return a list of the secrets and their values.
# ----------------------------------------------------------------------------------------------------
Function ListKeyVaultSecrets
{
  Param ([string] $KeyVaultName)

  Write-Output "Getting values of secrets in vault: $($KeyVaultName)..."
  $secretList = Get-AzureKeyVaultSecret -VaultName $KeyVaultName
  ForEach ($secret in $secretList) {
    if ($secret.Enabled) {
        $secretObject = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $secret.Name;
        $secretValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText
        Write-Output "  Secret $($secret.Name) = $($secretValue)";
    } else {
        Write-Output "  $($secret.Name) = KEY IS DISABLED!  (Version=NONE)";
    }
  }
}

ListKeyVaultSecrets -KeyVaultName xxxkvexistsdemovault
