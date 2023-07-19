# Key Vault Secrets Deduplication Demo

[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][1]

[1]: https://vscode.dev/github/lluppesms/KeyVault.Secrets.demo/

---

## Overview

Deploying Key Vault Secrets in a pipeline is a common task. This demo shows how to deploy a small variety of secrets to a Key Vault in several different ways in a pipeline.

Unfortunately, usually each time a deploy pipeline is run, the secrets are redeployed and the result is many duplicate versions of the same secret.

This project explores the use of the PowerShell scripts to determine if the secret already exists and/or if it has changed, then uses that information to intelligently create the secret.

There are three different versions of how to approach secret creation in the repository, each with their own pros and cons.

---

## 1. [Create Secrets Every Pipeline Run](1-Create_Every_Run/README.md)

This version of the workflow will create the secrets every time the pipeline is run. This is the most basic version of the pipeline and the fastest but has a big drawback in that it creates multiple duplicate enabled versions of every secret. If this pipeline is run nightly it will create hundreds of versions of each secret.

> It is possible to split out the secret creation steps into a separate pipeline and only run them as needed when things change.

---

## 2. [Create Secrets ONLY If They Have Changed](2-Create_If_Different/README.md)

This version of the workflow is the slowest but most comprehensive version of this repository.  It will validate each secret by checking to see if it exists, then comparing the supplied value with the current value.  If the secret does not exist or the value is different, a new version will be created and the old one disabled..

> The main drawback to this version is that it adds an addition ~90 seconds to the pipeline run time *FOR EVERY SECRET* to go and fetch the value of the secret from the vault before starting to create the secret.

---

## 3. [Create Secrets If They Don't Exist](3-Create_If_Not_Exists/README.md)

This version of the workflow will create the secrets only if they do not already exist in the key vault, which effectively means they will be created only the first time the pipeline is run.

If keys need to be updated, the 'forceKeyVaultEntryCreation' parameter can be used and can force the recreation of entries.

> The main drawback to this version is that it adds an addition ~90 seconds to the pipeline run time to go fetch the list of secret names currently in the vault, and it will not automatically update secrets if they change.

---


## References

[My Sample Key Vault Manipulation Scripts](Scripts/readme.md)

[Use deployment scripts in ARM templates - MS Learn](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template)

[Existing Issue: #4023 Check if resource exists (github.com/Azure/bicep)](https://github.com/Azure/bicep/issues/4023)

[Interesting Blog: Bicep to Create secret if not exists in KeyVault – Teching.nl](https://teching.nl/2022/08/bicep-create-secret-if-not-exists-in-keyvault/)
