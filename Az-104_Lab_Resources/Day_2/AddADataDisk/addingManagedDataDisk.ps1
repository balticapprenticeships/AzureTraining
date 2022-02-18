##############################################
# AZ-104 Lab 6 - adding managed data disks   #
# Author: Baltic Apprenticeships             #
# Version: 1.0.0                             #
##############################################

# Set the environment variable. Add the *REQUIRED* information.

# The resource group where the VM is located. *REQUIRED*
$rg = "AZ-104Lab6Rg-<your initials>"

# This is the name of the VM to attach the disk to. *REQUIRED*
$vmName = "<VM Name>"

# This the location of the resource group where the VM and resources are located
$location = "UK West"

## DO NOT EDIT BELOW ##
# Here we select the type of disk to attach Premium SSD, Standard SSD or Standard HDD
$storageType = "Standard_LRS"

# The will be te name of the additional disk
$dataDiskName = "$vmName-datadisk"

# This is the size of the additional disk in GB
$dataDiskSize = "20"


## Create the disk
# Here we create the data disk config and store it as a variable for later use.
$dataDiskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB $dataDiskSize

# Here we create the disk
$dataDisk01 = New-AzDisk -ResourceGroupName $rg -DiskName $dataDiskName -Disk $dataDiskConfig

# We not get the VM Id in order to associate the disk with the VM
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName

# Now we add the disk to the VM
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption attach -ManagedDiskId $dataDisk01.Id -Lun 1

# Here we update the VM configuration to show the attached data disk
Update-AzVm -VM $vm -ResourceGroupName $rg