# ValheimInAzure
A small powershell script that provisions Azure to run your own Valheim server.

# Requirements
* An Azure subscription
* Powershell 7
* AZ powershell module.
See the ps1 file for instructions.

# Customize to your needs
change the following variables in this script:
* SUBSCRIPTION
* RESOURCE_GROUP 
* RESOURCE_GROUP_LOCATION
* WORLD_NAME

# Execute the script
run the valheimResources.ps1 file from your powershell commandline with admin rights.

# Play
Start Valheim and start playing your server name is shown in the console. A new world was created during startup of the server.

# Load an already created world
The console output also provides instructions how to load your own already created world. 
