# The following command endable the Azure Graph Client for PowerShell
Add-Type -Path 'C:\Program Files\WindowsPowerShell\Modules\AzureAD\<input your version number here>\Microsoft.Open.AzureAD16.Graph.Client.dll'

# This command connect PowerShell to AzureAD. You must have the correct permissions to use this command to manage Azure AD
Connect-AzureAD

# Creates a variable that allowus to submit a password to AzureAD
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
# This sets the password
$PasswordProfile.Password = "P@ssw0rd"
# This command forces the user to change the password when they first login
$PasswordProfile.ForceChangePasswordNextLogon

#This command creates the new user account with the using the PasswordProfile
New-AzureADUser -DisplayName "Jason Bourne" -GivenName "Jason" -Surname "Bourne" -PasswordProfile $PasswordProfile -UserPrincipalName "jason.bourne@<your domain suffix e.g somethin.onmicrosoft.com>" -AccountEnabled $true -MailNickName "Jason.Bourne" -Country "United Kingdom"

# This command disconnects the PowerShell session from AzureAD
Disconnect-AzureAD