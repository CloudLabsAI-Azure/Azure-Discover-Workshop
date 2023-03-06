Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $ODLID,

    [string]
    $DeploymentID,

    [string]
    $InstallCloudLabsShadow,

    [string]
    $vmAdminUsername,

    [string]
    $trainerUserName,

    [string]
    $trainerUserPassword

   
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
$adminUsername = "DemoUser"
[System.Environment]::SetEnvironmentVariable('DeploymentID', $DeploymentID,[System.EnvironmentVariableTarget]::Machine)

$trainerUserPassword = "Password.!!1"
#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID
InstallModernVmValidator
#choco install dotnetfx
sleep 10

Enable-CloudLabsEmbeddedShadow $vmAdminUsername $trainerUserName $trainerUserPassword



# Disable Internet Explorer Enhanced Security Configuration
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

# Download and extract the starter solution files
Invoke-WebRequest 'https://experienceazure.blob.core.windows.net/templates/migrating-sql-database-to-azure(2)/MCW.zip' -OutFile 'C:\MCW.zip'
Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\hands-on-lab' -Force

$directoryInfo = Get-ChildItem "C:\hands-on-lab\MCW-Migrating-SQL-databases-to-Azure-master" | Measure-Object
$dir = $directoryInfo.count

If ($dir -eq 0)
{
Remove-Item "C:\MCW.zip"
Invoke-WebRequest 'https://experienceazure.blob.core.windows.net/templates/migrating-sql-database-to-azure(2)/MCW.zip' -OutFile 'C:\MCW.zip'#Condition to check if the lab files are present

    Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\hands-on-lab' -Force

}

#Download and Install edge

        $WebClient = New-Object System.Net.WebClient

        $WebClient.DownloadFile("http://dl.delivery.mp.microsoft.com/filestreamingservice/files/6d88cf6b-a578-468f-9ef9-2fea92f7e733/MicrosoftEdgeEnterpriseX64.msi","C:\Packages\MicrosoftEdgeBetaEnterpriseX64.msi")

        sleep 5

        

                   Start-Process msiexec.exe -Wait '/I C:\Packages\MicrosoftEdgeBetaEnterpriseX64.msi /qn' -Verbose 

        sleep 5

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Azure Portal.lnk")

        $Shortcut.TargetPath = """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"""

        $argA = """https://portal.azure.com"""

        $Shortcut.Arguments = $argA 

        $Shortcut.Save()

#Download ssis script
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Azure-Discover-Workshop/main/hands-on-lab/lab-files/ssis.ps1","C:\LabFiles\ssis.ps1")


#adding deploymentid
$deploymentid = $env:DeploymentID

$path = "C:\LabFiles"
(Get-Content -Path "$path\ssis.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\ssis.ps1"
(Get-Content -Path "$path\ssis.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\ssis.ps1"



sleep 5

Invoke-WebRequest 'https://experienceazure.blob.core.windows.net/templates/migrating-sql-database-to-azure(2)/MCW.zip' -OutFile 'C:\MCW.zip'
Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\hands-on-lab' -Force

$directoryInfo = Get-ChildItem "C:\hands-on-lab\MCW-Migrating-SQL-databases-to-Azure-master" | Measure-Object
$dir = $directoryInfo.count

If ($dir -eq 0)
{
Remove-Item "C:\MCW.zip"
Invoke-WebRequest 'https://experienceazure.blob.core.windows.net/templates/migrating-sql-database-to-azure(2)/MCW.zip' -OutFile 'C:\MCW.zip'#Condition to check if the lab files are present

    Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\hands-on-lab' -Force

}

sleep 5

#Download SQL repo files
Invoke-WebRequest 'https://github.com/sk-bln/SQL-Hackathon/archive/refs/heads/master.zip' -OutFile 'C:\sql.zip'
Expand-Archive -LiteralPath 'C:\sql.zip' -DestinationPath 'C:\hands-on-lab' -Force

Expand-Archive -LiteralPath 'C:\hands-on-lab\SQL-Hackathon-master\Hands-On Lab\02 SSIS Migration\02-SSIS Migration.zip' -DestinationPath 'C:\LabFiles' -Force

sleep 5

# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile 'C:\DataMigrationAssistant.msi'
Start-Process -file 'C:\DataMigrationAssistant.msi' -arg '/qn /l*v C:\dma_install.txt' -passthru | wait-process


# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2043154&clcid=0x409' -OutFile 'C:\SSMS-Setup-ENU.exe'
$params = " /Install /Quiet SSMSInstallRoot=$install_path"
Start-Process -FilePath 'C:\SSMS-Setup-ENU.exe' -ArgumentList $params -Wait

sleep 5

# Download and install Visual Studio 2017 with data tools
Invoke-WebRequest -Uri https://aka.ms/vs/15/release/vs_community.exe -OutFile "$env:TEMP\vs_community.exe"
Start-Process -FilePath "$env:TEMP\vs_community.exe" -ArgumentList '--add', 'Microsoft.VisualStudio.Workload.DataStorage', '--wait', '--norestart' -PassThru | Wait-Process

sleep 5

choco install visualstudio2017community -y -force
sleep 5
choco install visualstudio2017sql

sleep 5
# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/0/4/f/04f1e61f-3f4d-4447-8a8a-12a23fb2e8b9/SSDT-Setup-ENU.exe' -OutFile 'C:\SSDT-Setup-ENU.exe'
sleep 5
$params = " /Install /Quiet SSMSInstallRoot=$install_path"
Start-Process -FilePath 'C:\SSDT-Setup-ENU.exe' -ArgumentList $params -Wait

Restart-Computer
