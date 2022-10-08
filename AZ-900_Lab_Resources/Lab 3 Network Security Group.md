# Configure network access to a VM by using a network security group

## Task 1: Create a Cloud Shell account
-	Connect to the Azure portal and create a resource group:
  a.	Name: AZ900Lab3Rg-<your initials>
  b.	Tags: Name: CreatedBy, Value: <Your name no spaces>
  c.	Tags: Name: Course, Value: Baltic-AZ-900
-	One created select the resource group and click the Cloud Shell icon  
  In the top right of your Azure browser tab.
-	When you open the Cloud Shell for the first time you must configure a storage account to hold any files created or uploaded through it.
-	Once the split screen opens select PowerShell from the Welcome to Azure Cloud Shell.
-	On the ‘You have no storage mounted’ screen select Create storage.

## Task 2: Create a Linux Virtual machine and install an extension
Once the Cloud Shell has finished loading use the following code snippets to create a Linux virtual machine and deploy a VM extension to install and configure the VM as a web server. Replace all instances of [your resource group name] with the name of the resource group you created in Task 1.

- Run the following ```az vm create``` command to create the Linux VM:
```
az vm create `
  --resource-group [your resource group name] `
  --name my-vm `
  --image UbuntuLTS `
  --size Standard_B1ms `
  --public-ip-sku Basic `
  --storage-sku Standard_LRS `
  --admin-username azureuser `
  --generate-ssh-keys
```
- Your VM will take a few moments to come up. You have named the VM my-vm. You will use this name to refer to the VM in later steps.

- Run the following ```az vm extension set`` command to configure Nginx on your VM:
```
az vm extension set `
  --resource-group [your resource group name] `
  --vm-name my-vm `
  --name customScript `
  --publisher Microsoft.Azure.Extensions `
  --version 2.1 `
  --settings '{\"fileUris\":[\"https://raw.githubusercontent.com/balticapprenticeships/AzureTraining/main/AZ-900_Lab_Resources/Lab3-NSG/configure-nginx.sh\"]}' `
  --protected-settings '{\"commandToExecute\": \"./configure-nginx.sh\"}'
```
This command uses the Custom Script Extension to run a Bash script on your VM. The scripts can be stored on GitHub, inhected into our VMs and executed.
The script:

   - Runs apt-get update to download the latest package information from the internet. This step helps ensure that the next command can locate the latest version of the Nginx package.
   - Installs Nginx.
   - Sets the home page, /var/www/html/index.html, to print a welcome message that includes your VM's host name.


## Task 3: Access the web server
### Step 1 - Run the following ```az vm list-ip-addresses``` command to get your VM's IP address and store the result as a Bash variable:
```
$IPADDRESS="$(az vm list-ip-addresses `
  --resource-group [your resource group name] `
  --name my-vm `
  --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" `
  --output tsv)"
```
### Step 2 - Run the following curl command to download the home page:
```
curl --connect-timeout 5 http://$IPADDRESS
```
- The --connect-timeout argument specifies to allow up to five seconds for the connection to occur. After five seconds, you see an error message that states that the connection timed out:
curl: (28) Connection timed out after 5001 milliseconds

- This message means that the VM wasn't accessible within the timeout period.

### Step 3 - Run the following to display you IP Address
```
echo $IPADDRESS
```
## List the current network security group rules
### Step 1
az network nsg list `
  --resource-group [your resource group name] `
  --query '[].name' `
  --output tsv

- you should see
```
 my-vmNSG
```
### Step 2 - Run the following command to list the associated NSG rules
```
az network nsg rule list `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG
```
### Step 3
- Run the az network nsg rule list command a second time. This time, use the --query argument to retrieve only the name, priority, affected ports, and access (Allow or Deny) for each rule. 
- The --output argument formats the output as a table so that it's easy to read.
```
az network nsg rule list `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG `
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' `
  --output table
```
- You should see
```
Name               Priority    Port    Access
-----------------  ----------  ------  --------
default-allow-ssh  1000        22      Allow
```
## Create the network security group rule

### Step 1 Run the following az network nsg rule create command to create a rule called allow-http that allows inbound access on port 80:
```
az network nsg rule create `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG `
  --name allow-http `
  --protocol tcp `
  --priority 100 `
  --destination-port-ranges 80 `
  --access Allow
```
- For learning purposes, here you set the priority to 100. In this case, the priority doesn't matter. You would need to consider the priority if you had overlapping port ranges.

### Step 2 - To verify the configuration, run az network nsg rule list to see the updated list of rules:
```
az network nsg rule list `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG `
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' `
  --output table
```
- You see both the default-allow-ssh rule and your new rule, allow-http:
```
Name               Priority    Port    Access
-----------------  ----------  ------  --------
default-allow-ssh  1000        22      Allow
allow-http         100         80      Allow
```
## Access your web server again

## Now that you've configured network access to port 80, let's try to access the web server a second time.

### Step 1 - Run the same curl command that you ran earlier:
```
curl --connect-timeout 5 http://$IPADDRESS
```

- you should see:
```
<html><body><h2>Welcome to Azure! My name is my-vm.</h2></body></html>
```
## Try this again in your browser.