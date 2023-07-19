# To deploy these bicep files manually, run these commands at a PowerShell prompt:

# 1. Create a resource group 
#az login
#az account set --subscription 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
az group create -l eastus -n 'rg-kv-exists-demo'

# 2. Edit the main-secrets-exists.parms.json file to have your secret values

# 3. Deploy the resources used for this example
az deployment group create --resource-group 'rg-kv-exists-demo' --template-file '../infra/main-create-resources.bicep'  --parameters 'Bicep/main-secrets-exists.parms.json' -n 'manual-create-resources-20230718T1300'

# 4. Deploy the secrets -- run this multiple times to test the process
# set the forceSecretCreation to true if you want to test ALWAYS creating the secret
az deployment group create --resource-group 'rg-kv-exists-demo' --template-file 'Bicep/main-secrets-exists.bicep' --parameters 'Bicep/main-secrets-exists.parms.json' -n 'manual-secrets-exists-20230718T1300'
