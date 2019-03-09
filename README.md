# The assignment

- Sign up for a free Azure account at https://azure.microsoft.com/nl-nl/free/
- Create a deployment script, using template and parameter files, to deploy below-listed items, in a secure manner, to the Azure subscription:
	- a Resource Group in West Europe
	- a Storage Account in the above created Resource Group, using encryption and an unique name, starting with the prefix 'sentia'
	- a Virtual Network in the above created Resource Group with three subnets, using 172.16.0.0/12 as the address prefix
- Apply the following tags to the resource group: Environment='Test', Company='Sentia'
- Create a policy definition using the REST API to restrict the resourcetypes to only allow: compute, network and storage resourcetypes
- Assign the policy definition using the REST API to the subscription and resource group you created previously


# Outcome

- Microsoft .NET Framework 5 was required (PowerShell) to install module AzureRM (`Install-Module AzureRM`) and `Import-Module AzureRM`
- It took me roughly a week and ~5h of work to finalize the assignment
- In those 5h I did not account for the reading and learning to get familiar with the topic (Azure and PowerShell commands and syntax) of which I had no prior experience
- I have adopted some best practices regarding the subnets and policy definitions
- As a remaining step to fully automate the deployment procedure (the signing in is done manually) I would include the account username and password (as encrypted password file). Although it seems there is a [limitation](https://aventistech.com/connect-azurermaccount-sequence-contains-no-elements/).
