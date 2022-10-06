# Configure network access to a VM by using a network security group

## Create a Linux virtual machine and install Nginx
### Step 1 - From Cloud Shell, run the following az vm create command to create a Linux VM:
```
az vm create \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --name my-vm \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys
```
- Your VM will take a few moments to come up. You have named the VM my-vm. You use this name to refer to the VM in later steps.

### Step 2 - Run the following az vm extension set command to configure Nginx on your VM:
```
az vm extension set \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --vm-name my-vm \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --version 2.1 \
  --settings '{"fileUris":["https://raw.githubusercontent.com/MicrosoftDocs/mslearn-welcome-to-azure/master/configure-nginx.sh"]}' \
  --protected-settings '{"commandToExecute": "./configure-nginx.sh"}'
```
- This command uses the Custom Script Extension to run a Bash script on your VM. The script is stored on GitHub. While the command runs, you can choose to examine the Bash script from a separate browser tab.

- To summarize, the script:

    Runs apt-get update to download the latest package information from the internet. This step helps ensure that the next command can locate the latest version of the Nginx package.
    Installs Nginx.
    Sets the home page, /var/www/html/index.html, to print a welcome message that includes your VM's host name.


## Access the web server
### Step 1 - Run the following az vm list-ip-addresses command to get your VM's IP address and store the result as a Bash variable:
```
IPADDRESS="$(az vm list-ip-addresses \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --name my-vm \
  --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
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
az network nsg list \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --query '[].name' \
  --output tsv

- you should see
```
 my-vmNSG
```
### Step 2 - Run the following command to list the associated NSG rules
```
az network nsg rule list \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --nsg-name my-vmNSG
```
### Step 3
- Run the az network nsg rule list command a second time. This time, use the --query argument to retrieve only the name, priority, affected ports, and access (Allow or Deny) for each rule. 
- The --output argument formats the output as a table so that it's easy to read.
```
az network nsg rule list \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --nsg-name my-vmNSG \
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' \
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
az network nsg rule create \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --nsg-name my-vmNSG \
  --name allow-http \
  --protocol tcp \
  --priority 100 \
  --destination-port-ranges 80 \
  --access Allow
```
- For learning purposes, here you set the priority to 100. In this case, the priority doesn't matter. You would need to consider the priority if you had overlapping port ranges.

### Step 2 - To verify the configuration, run az network nsg rule list to see the updated list of rules:
```
az network nsg rule list \
  --resource-group learn-be2633a2-f735-4d54-8aa2-7aad530cd089 \
  --nsg-name my-vmNSG \
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' \
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