<#
 .SYNOPSIS
    Deploy template to Azure subscription
 .DESCRIPTION
    Deploy parameterized template using encryption and a unique name to an Azure subscription
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,                                # existing and valid Azure subscription

 [string]
 $resourceGroupName = "sentia",                  # resource group name or default (sentia)

 [string]
 $resourceGroupLocation = "westeurope",          # resource group location or default (westeurope)

 [string]
 $deploymentName = "deploy",                     # deployment name or default (deploy)

 [string]
 $templateFilePath = "deploy_template.json",     # deployment file or default (deploy_template.json)

 [string]
 $parametersFilePath = "deploy_parameters.json", # parameters file or default (deploy_parameters.json)

 [string]
 $policyFilePAth = "deploy_policy.json"          # policy file or default (deploy_policy.json)
)

# sign in
Function SignIn {
  Write-Host "Signing in...";
  Login-AzureRmAccount;
}

# select subscription
Function SelectSubscription {
  Write-Host "Selecting subscription: '$subscriptionId'";
  Select-AzureRmSubscription -SubscriptionID $subscriptionId;
}

# register resource types
Function RegisterResourceTypes {
  $resourceTypes = @("microsoft.compute","microsoft.network","microsoft.storage");
  if($resourceTypes.length) {
    Write-Host "Registering resource types"
    foreach($resourceType in $resourceTypes) {
      Write-Host "Registering resource type '$resourceType'";
      Register-AzureRmResourceProvider -ProviderNamespace $resourceType;
    }
  }
}

# create new or lookup existing resource group
Function CreateResourceGroup {
  $resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
  if(!$resourceGroup) {
    Write-Host "No resource group '$resourceGroupName'. Enter location to create a new resource group:";
    if(!$resourceGroupLocation) {
      $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
  } else {
    Write-Host "Using existing resource group '$resourceGroupName'";
  }
}

# create resource group tags
Function CreateResourceGroupTags {
  Write-Host "Creating tags for resource group '$resourceGroupName'";
  $Tags = (Get-AzureRmResourceGroup -Name $resourceGroupName).Tags;
  $Tags += @{"Environment"="Test"; "Company"="Sentia"};
  Set-AzureRmResourceGroup -Name $resourceGroupName -Tag $Tags;
}

# deploy
Function Deploy {
  Write-Host "Deploying...";
  if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
  } else {
    New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath;
  }
}

# assign policy definition to subscription and resource group
Function AssignPolicy {
  Write-Host "Registering policy definition and assigning to '$resourceGroupName'";
  New-AzureRmPolicyDefinition -Name policyDefinition -Policy $policyFilePath;
  New-AzureRmPolicyAssignment -Name policyAssignment -PolicyDefinition (Get-AzureRmPolicyDefinition -Name policyDefinition) -Scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName;
}

#******
# Body
#******

Import-Module AzureRM

$ErrorActionPreference = "Stop"

SignIn;
SelectSubscription;
RegisterResourceTypes;
CreateResourceGroup;
CreateResourceGroupTags;
Deploy;
AssignPolicy;
