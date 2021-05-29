# install powershell 7 https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3
# install Azure powershell module with 'Install-Module -Name Az'

# Updating the following 4 lines is required to configure the script to your situation.
$SUBSCRIPTION = "<NameOfYourAzureSubscription>"
$RESOURCE_GROUP = "<yourresourcegroup>"
$WORLD_NAME="<NameOfYourValheimWorld>"
$VALHEIM_SERVER_NAME = "<ValheimServerName>"
$PASSWORD = "<YourServerPassword>"

# change this location to your nearest azure location.
$RESOURCE_GROUP_LOCATION = "westeurope"

$STORAGE_ACCOUNT_NAME = "sto" + $RESOURCE_GROUP
$CONTAINER_NAME = "con" + $RESOURCE_GROUP

az login
az account set --subscription $SUBSCRIPTION

If (!(Get-AzResourceGroup -ResourceGroupName $RESOURCE_GROUP)) {
    New-AzResourceGroup -Name $RESOURCE_GROUP -Location $RESOURCE_GROUP_LOCATION
    Write-Output "CREATED resource-group $RESOURCE_GROUP"
}

# From example https://docs.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files
Write-Output "CREATING storage account $STORAGE_ACCOUNT_NAME"
az storage account create `
    --resource-group $RESOURCE_GROUP `
    --name $STORAGE_ACCOUNT_NAME `
    --location $RESOURCE_GROUP_LOCATION `
    --access-tier HOT `
    --kind FileStorage `
    --sku Premium_LRS `

Write-Output "CREATED storage account $STORAGE_ACCOUNT_NAME"

$STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
Write-Output "Retrieved storage account key $STORAGE_KEY "

Write-Output "CREATING fileshare $CONFIGFILESHARENAME"
$CONFIGFILESHARENAME="valheimconfig"
az storage share create `
  --account-key $STORAGE_KEY `
  --name $CONFIGFILESHARENAME `
  --account-name $STORAGE_ACCOUNT_NAME

Write-Output "CREATED fileshare $CONFIGFILESHARENAME"



Write-Output "CREATING Azure Container Instance $CONTAINER_NAME "
# https://github.com/lloesche/valheim-server-docker
# https://docs.microsoft.com/en-US/cli/azure/container?view=azure-cli-latest#az_container_create
az container create `
    --resource-group $RESOURCE_GROUP `
    --name $CONTAINER_NAME `
    --image lloesche/valheim-server `
    --dns-name-label $VALHEIM_SERVER_NAME `
    --ports 80 2456 2457 `
    --protocol UDP `
    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME `
    --azure-file-volume-account-key $STORAGE_KEY `
    --azure-file-volume-share-name $CONFIGFILESHARENAME `
    --azure-file-volume-mount-path /config `
    --cpu 4 `
    --memory 8 `
    --environment-variables SERVER_NAME=ValheimNiek WORLD_NAME=$WORLD_NAME SERVER_PASS=$PASSWORD SERVER_PUBLIC=true

Write-Output "CREATED Azure Container Instance $CONTAINER_NAME "
Write-Output "To deploy your own world:"
Write-Output "1) try to have your valheim game connect to the server $VALHEIM_SERVER_NAME.$RESOURCE_GROUP_LOCATION.azurecontainer.io"
Write-Output "2) stop the container instance"
Write-Output "3) copy the .fwl and .db file  and .db.old files of your world form C:\Users\<username>\AppData\LocalLow\IronGate\Valheim\worlds to the fileshare."
Write-Output "4) Make sure you deployed the ran this script with the correct `$World_NAME` variable which is identical as the file you are copying."
