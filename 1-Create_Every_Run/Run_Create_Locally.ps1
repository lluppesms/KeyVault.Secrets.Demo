# To deploy these bicep files manually, run these commands at a PowerShell prompt:

# 1. Create a resource group 
#az login
#az account set --subscription 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
az group create -l eastus -n 'rv-kv-create-demo'

# 2. Edit the main-secrets-create.parms.json file to have your secret values

# 3. Deploy the resources used for this example
az deployment group create --resource-group 'rv-kv-create-demo' --template-file '../infra/main-create-resources.bicep'   --parameters 'Bicep/main-secrets-create.parms.json' -n 'manual-create-resources-20230718T1000'

# 4. Deploy the secrets -- run this multiple times to test the process
az deployment group create --resource-group 'rv-kv-create-demo' --template-file 'Bicep/main-secrets-create.bicep' --parameters 'Bicep/main-secrets-create.parms.json' -n 'manual-secrets-create-20230718T1000'
