# To deploy these bicep files manually, run these commands at a PowerShell prompt:

# 1. Create a resource group 
#az login
#az account set --subscription 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
az group create -l eastus -n 'rg-kv-compare-demo'

# 2. Edit the main-secrets-compare.parms.json file to have your secret values

# 3. Deploy the resources used for this example
az deployment group create --resource-group 'rg-kv-compare-demo' --template-file '../infra/main-create-resources.bicep'    --parameters 'Bicep/main-secrets-compare.parms.json' -n 'manual-resources-20230718T1330'

# 4. Deploy the secrets -- run this multiple times to test the process
az deployment group create --resource-group 'rg-kv-compare-demo' --template-file 'Bicep/main-secrets-compare.bicep' --parameters 'Bicep/main-secrets-compare.parms.json' -n 'manual-compare-20230718T1330'
