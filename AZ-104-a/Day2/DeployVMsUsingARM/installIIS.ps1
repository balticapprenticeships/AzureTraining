##############################################
# AZ-104 Lab - basic script to install IIS   #
# Author: Baltic Apprenticeships             #
# Version: 1.0.0                             #
##############################################

# Import the server manager module
Import-Module servermanager

# Add the IIS server role and optional features
Add-WindowsFeature web-server -IncludeAllSubfeature
