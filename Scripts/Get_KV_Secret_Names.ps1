# ----------------------------------------------------------------------------------------------------
# Pass in a KV Name and this script will return a semi-colon delimited list of secret names.
# ----------------------------------------------------------------------------------------------------
Function GettKeyVaultSecretNames
{
    Param ([string] $KeyVaultName)

    Write-Output "Getting names of secrets in vault: $($KeyVaultName)..."
    $secretList = Get-AzKeyVaultSecret -VaultName $KeyVaultName | Select Name
    $secretListFull = ";" + ((-split $secretList) -join ";") + ";"
    $secretListString = $secretListFull.replace("@{Name=", "").replace("}", "")

    Write-Output $secretListString
}

GettKeyVaultSecretNames -KeyVaultName xxxkvexistsdemovault
