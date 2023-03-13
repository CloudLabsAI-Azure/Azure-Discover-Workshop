Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: SSIS LAB BULD SCRIPT ######################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "This script will setup and install the SSIS Lab Databases."
Write-Host -BackgroundColor Black -ForegroundColor Yellow "IMPORTANT: Please only run after the build is complete"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

###############################################################################
# Set up and install AZ and SQL Modules used by this script
###############################################################################
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Install-Module -Name Az -Force -AllowClobber

sleep 5

Install-Module SQLServer -Confirm:$False -Repository PSGallery -Force -AllowClobber

###############################################################################
# Connect to Azure with Subscription and Tenant
###############################################################################

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Connecting Powershell to your Subscription......................................."
#Az Login

. C:\LabFiles\AzureCreds.ps1

$userName = $AzureUserName
$password = $AzurePassword
$subscriptionId = $AzureSubscriptionID
$TenantID = $AzureTenantID
$DID = $DeploymentID


$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null
Write-Host "Installing Microsoft Integration Services Projects" -ForegroundColor Cyan

$vsixPath = "C:\data-tools.exe"
Write-Host "Downloading VS extension package..."
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/0/4/f/04f1e61f-3f4d-4447-8a8a-12a23fb2e8b9/SSDT-Setup-ENU.exe', $vsixPath)



Start-Process "C:\data-tools.exe" 





Write-Host -BackgroundColor Black -ForegroundColor Yellow "Setting Enviroment Varibales....................................................."
$subscriptionID = (Get-AzContext).Subscription.id
$subscriptionName = (Get-AzContext).Subscription.Name

if(-not $subscriptionID) {   `
    $subscriptionMessage = "There is no selected Azure subscription. Please use Select-AzSubscription to select a default subscription";  `
    Write-Warning $subscriptionMessage ; return;}  `
else {   `
    $subscriptionMessage = ("Targeting Azure subscription: {0} - {1}." -f $subscriptionID, $subscriptionName)}
Write-Host -BackgroundColor Black -ForegroundColor Yellow $subscriptionMessage

###############################################################################
# Set variables for storage account RG 
##############################################################################

$labrg = "Azure-Discover-RG-deploymentidvalue"


###############################################################################
# Setup Storage Account
###############################################################################

# First find and setup the Storage acocunt

# Setup Storage Conext
$StorageAccount = "sqlhacksadeploymentidvalue"
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName "$labrg" -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0

#Create Container Build
If(-not (Get-AzStorageContainer -Context $Context -Name build -ErrorAction Ignore)){
    $output = New-AzStorageContainer -Context $Context -Name build
}

#Create SASUri for Build Container
$storagePolicyName = "Build-Policy"
$expiryTime = (Get-Date).AddYears(1)

If(-not (Get-AzStorageContainerStoredAccessPolicy -Context $Context -Name build)){
    New-AzStorageContainerStoredAccessPolicy -Container build -Policy $storagePolicyName -Permission rwld -ExpiryTime $expiryTime -Context $Context -StartTime(Get-Date) 
}
$SASUri = (New-AzStorageContainerSASToken -Name "build" -FullUri -Policy $storagePolicyName -Context $Context)

#Copy Files from github to Local machine

$Temp = "C:\LabFiles"
$output = md $Temp -ErrorAction Ignore

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Copying Backups to Blob storage....................................................."

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/CloudLabsAI-Azure/Azure-Discover-Workshop/blob/main/hands-on-lab/lab-files/WideWorldImporters.bak?raw=true' -UseBasicParsing -OutFile "$temp\WideWorldImporters.bak" | Wait-Process

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/sk-bln/SQL-Hackathon/blob/master/Build/SQL%20SSIS%20Databases/2008DW.bak?raw=true' -UseBasicParsing -OutFile "$temp\2008DW.bak" | Wait-Process

# Copy Files to Blob
cd $Temp
$output = Get-ChildItem -File -Recurse -Filter "*.bak" |  Set-AzStorageBlobContent -Container "build" -Context $Context -Force

###############################################################################
# Set Variables for SQLMI RG
##############################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "################################# BUILD ENVIROMENT #########################################################"


$adminUsername = "contosoadmin"
$securePassword = "IAE5fAijit0w^rDM" | ConvertTo-SecureString -AsPlainText -Force
$adminPassword = $securePassword
$SharedRG = "SQLMI-Shared-RG"

###############################################################################
# Find Managed Instance
###############################################################################
$sqlmiFDQN = "sqlmi--cus.cb0c7139b099.database.windows.net"

###############################################################################
# Restore Databases
###############################################################################
$Credentials = New-Object PSCredential $adminUsername, $adminPassword

Write-Host -BackgroundColor Black -ForegroundColor Yellow "################################# RESTOING DATABASES #######################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "SSIS Databases will be restored and CLR will be enabled on the Managed Instance"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

# Set SQL MI CLR
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting to enable CLR on the Managed Instance $sqlmiFDQN"
$Query = "EXEC sp_configure ""CLR Enabled"", 1; RECONFIGURE WITH OVERRIDE"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Set SQL MI Credential
$Query = "if not exists (select 1 from sys.credentials where name = '" + $SASUri.split('?')[0,2] + "') CREATE CREDENTIAL [" + $SASUri.split('?')[0,2] + "] WITH IDENTITY='Shared Access Signature', SECRET='" + $SASUri.split('?')[1,2] + "'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password

# Restore Database WideWorldImporters
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore WideWorldImporters database on Managed Instance $sqlmiFDQN"
$blob = (Get-AzStorageBlob -Container build -Context $Context -Blob 'WideWorldImporters.bak').ICloudBlob.Uri.AbsoluteUri
$Query = "if not exists (select 1 from sysdatabases where name = 'WideWorldImporters') RESTORE DATABASE [WideWorldImporters] FROM URL = '$blob'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Restore Database 2008DW
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore 2008DW database on Managed Instance $sqlmiFDQN"
$blob = (Get-AzStorageBlob -Container build -Context $Context -Blob '2008DW.bak').ICloudBlob.Uri.AbsoluteUri
$Query = "if not exists (select 1 from sysdatabases where name = '2008DW$DID') RESTORE DATABASE [2008DW$DID] FROM URL = '$blob'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."
