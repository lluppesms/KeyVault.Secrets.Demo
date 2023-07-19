# Key Vault Secrets - Create Secrets ONLY If They Have Changed Demo

Normally each time a deploy pipeline is run, the secrets are (unfortunately) redeployed and the result is a vault with multiple duplicate versions of the same secret.

This project explores the use of the a PowerShell script to check if the value exists and matches the supplied value then creates that secret ONLY if the value is different.

## Notes

**This is very slow!** These scripts do work, but unfortunately each time you run a step to create a key, the process has to spin up a new PowerShell environment, which takes about 90 seconds, so that makes these scripts very slow if there are many secrets.

**KeyVault Definition:** In order to make this work, you have to have a UserAssignedManagedIdentity added to the Key Vault. This identity is needed in order for the DeploymentScript to authenticate to the Key Vault and get the list of existing secret names. This is built into the Bicep for this example.

---

## Running this demo

To run this locally, edit the main-secrets-exists.parms.json to have the appropriate values for your environment, then run the commands in the Run_Exists_Locally.ps1 file (shown below).

``` PowerShell
# 1. Create a resource group 
#az login
#az account set --subscription 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
az group create -l eastus -n 'rg-kv-compare-demo'

# 2. Deploy the resources used for this example
az deployment group create --resource-group 'rg-kv-compare-demo' --template-file '../infra/main-create-resources.bicep'    --parameters 'Bicep/main-secrets-compare.parms.json' -n 'manual-resources-20230718T1330'

# 3. Deploy the secrets -- run this multiple times to test the process
az deployment group create --resource-group 'rg-kv-compare-demo' --template-file 'Bicep/main-secrets-compare.bicep' --parameters 'Bicep/main-secrets-compare.parms.json' -n 'manual-compare-20230718T1330'
```
