# Configure network access to a VM by using a network security group

## Task 1: Create a Cloud Shell account
Step 1 -	Connect to the Azure portal and create a resource group:
  - Name: AZ900Lab3Rg-\<your initials\>
  - Tags: Name: CreatedBy, Value: \<Your name no spaces\>
  - Tags: Name: Course, Value: Baltic-AZ-900

Step 2 -	One created select the resource group and click the Cloud Shell icon ![icon](https://learn.microsoft.com/en-us/azure/cloud-shell/media/overview/portal-launch-icon.png) in the top right of your Azure browser tab.

Step 3 -	When you open the Cloud Shell for the first time you must configure a storage account to hold any files created or uploaded through it.

Step 4 -	Once the split screen opens select ***PowerShell*** from the Welcome to Azure Cloud Shell.

Step 5 -	On the ***You have no storage mounted*** screen select ***Create storage***.

## Task 2: Create a Linux Virtual machine and install an extension
Once the Cloud Shell has finished loading use the following code snippets to create a Linux virtual machine and deploy a VM extension to install and configure the VM as a web server. Replace all instances of [your resource group name] with the name of the resource group you created in Task 1.

Step 1: Run the following ```az vm create``` command to create the Linux VM:
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
Your VM will take a few moments to come up. You have named the VM my-vm. You will use this name to refer to the VM in later steps.

Step 2: Run the following ```az vm extension set``` command to configure Nginx on your VM:
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
Step 1 - Run the following ```az vm list-ip-addresses``` command to get the public IP address of the VM and store it in a variable called IPADDRESSES:
```
$IPADDRESS="$(az vm list-ip-addresses `
  --resource-group [your resource group name] `
  --name my-vm `
  --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" `
  --output tsv)"
```
Step 2 - Run the following curl command to view the contents of the home page in the Azure CLI
```
curl --connect-timeout 5 http://$IPADDRESS
```
The --connect-timeout argument specifies to allow up to five seconds for the connection to occur. After five seconds, you see an error message that states that the connection timed out:
```
curl: (28) Connection timed out after 5001 milliseconds
```
This message means that the VM wasn't accessible within the timeout period.

### Step 3 - Try it from a web browser using the following echo command to display the public IP address:
```
echo $IPADDRESS
```

## Task 4: View the network security group and rules.
Step 1 - Run the following ```az network nsg list``` command to list the network security group associated with your VM:
```
az network nsg list `
  --resource-group [your resource group name] `
  --query '[].name' `
  --output tsv
```

You should see:
```
 my-vmNSG
```

Step 2 - Now use the following ```az network nsg``` command to list the associated rules
```
az network nsg rule list `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG
```
Step 3 - The JSON output can be difficult to read. We will re-run the ```az network nsg rule list``` command, but this time we will add the ```--query``` argument and output the results to a formatted table:
```
az network nsg rule list `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG `
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' `
  --output table
```
You should see:
```
Name               Priority    Port    Access
-----------------  ----------  ------  --------
default-allow-ssh  1000        22      Allow
```

## Task 5: Create a network security rule

Step 1 - Run the following ```az network nsg rule create``` command to create a new rule that will allow inbound HTTP traffic on TCP port 80:
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

Step 2 - To verify that the rule has been successfully created by running the az network nsg rule list command outputting to a formatted table:
```
az network nsg rule list `
  --resource-group [your resource group name] `
  --nsg-name my-vmNSG `
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' `
  --output table
```
You should now see both the default-allow-ssh rule and your new rule, allow-http:
```
Name               Priority    Port    Access
-----------------  ----------  ------  --------
default-allow-ssh  1000        22      Allow
allow-http         100         80      Allow
```

## Task 6: Access your web server again

Now that you've configured network access to port 80, let's try to access the web server a second time.

Step 1 - Run the same curl command that you ran earlier:
```
curl --connect-timeout 5 http://$IPADDRESS
```

You should now see the contents of the index.html file:
```
<html><body><h2>Welcome to the Baltic Apprenticeships Azure Fundamentals Course! This web servers host name is my-vm.</h2></body></html>
```
## Try this again in your browser.