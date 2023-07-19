# Key Vault Secrets - Create If They Don't Exist Demo

Normally each time a deploy pipeline is run, the secrets are (unfortunately) redeployed and the result is a vault with multiple duplicate versions of the same secret.

This project explores the use of the a PowerShell script to get a list of secrets at the start of the process, then uses that list to determine if the secret already exists and only creates the secret if it is new.

## Notes

**Force Creation Parameter:**
If you *WANT* the secret to be *UPDATED*, you should specify the forceSecretCreation parameter on each secret that should be updated.

**KeyVault Definition:** In order to make this work, you have to have a UserAssignedManagedIdentity added to the Key Vault. This identity is needed in order for the DeploymentScript to authenticate to the Key Vault and get the list of existing secret names. This is built into the Bicep for this example.

---

## Running this demo

To run this locally, edit the main-secrets-exists.parms.json to have the appropriate values for your environment, then run the commands in the Run_Exists_Locally.ps1 file (shown below).

``` PowerShell
# 1. Create a resource group 
#az login
#az account set --subscription 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
az group create -l eastus -n 'rg-kv-exists-demo'

# 2. Deploy the resources used for this example
az deployment group create --resource-group 'rg-kv-exists-demo' --template-file '../infra/main-create-resources.bicep'  --parameters 'Bicep/main-secrets-exists.parms.json' -n 'manual-create-resources-20230718T1300'

# 3. Deploy the secrets -- run this multiple times to test the process
# Note: set the forceSecretCreation to true if you want to test ALWAYS creating the secret
az deployment group create --resource-group 'rg-kv-exists-demo' --template-file 'Bicep/main-secrets-exists.bicep' --parameters 'Bicep/main-secrets-exists.parms.json' -n 'manual-secrets-exists-20230718T1300'
```
