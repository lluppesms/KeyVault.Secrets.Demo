# Key Vault Secrets - Create Every Pipeline Run

This folder is the very basic version that shows how to find secrets for a variety of resource types including Storage Account, CosmosDB, IoT Hub, Service Bus, SignalR, and a Generic String.

The pipeline will create the secrets every time the pipeline is run. This is the most basic version of the pipeline and is the fastest but has a big drawback in that it creates multiple duplicate enabled versions of every secret.

---

## Running this demo

To run this locally, edit the main-secrets-create.parms.json to have the appropriate values for your environment, then run the commands in the Run_Create_Locally.ps1 file (shown below).

``` Powershell
# 1. Create a resource group 
#az login
#az account set --subscription 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
az group create -l eastus -n 'rg-kv-exists-demo'

# 2. Deploy the resources used for this example
az deployment group create --resource-group 'rg-kv-exists-demo' --template-file '../infra/main-create-resources.bicep'  --parameters 'Bicep/main-secrets-exists.parms.json' -n 'manual-create-resources-20230718T1300'

# 3. Deploy the secrets -- run this multiple times to test the process
# Set the forceSecretCreation to true if you want to test ALWAYS creating the secret
az deployment group create --resource-group 'rg-kv-exists-demo' --template-file 'Bicep/main-secrets-exists.bicep' --parameters 'Bicep/main-secrets-exists.parms.json' -n 'manual-secrets-exists-20230718T1300'
```
