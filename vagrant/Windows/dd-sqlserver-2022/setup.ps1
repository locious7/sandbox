. C:\vm_info\.sandbox.conf.ps1

$DD_hostname = [System.Net.Dns]::GetHostName()
$DD_password = 'WithoutMeYoureLocked0ut'

Write-Host "Provisioning!"

# The Datadog Agent requires read-only access to the database server in order to collect statistics and queries.
# Create a read-only login to connect to your server and grant the required permissions (if not using connection_string: Trusted_Connection=Yes):
Invoke-Sqlcmd -ServerInstance $DD_hostname -Query "CREATE LOGIN datadog WITH PASSWORD = '$DD_password';
CREATE USER datadog FOR LOGIN datadog;
GRANT CONNECT ANY DATABASE to datadog;
GRANT VIEW SERVER STATE to datadog;
GRANT VIEW ANY DEFINITION to datadog;"

# Enable TCP/IP Network Protocol for SQL Server 
$DD_hostname = [System.Net.Dns]::GetHostName()

Import-Module "sqlps"

$smo = 'Microsoft.SqlServer.Management.Smo.'  
$wmi = new-object ($smo + 'Wmi.ManagedComputer').  

# List the object properties, including the instance names.  
$Wmi 

$uri = "ManagedComputer[@Name='$DD_hostname']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"  
$Tcp = $wmi.GetSmoObject($uri)  
$Tcp.IsEnabled = $true  
$Tcp.Alter()  
$Tcp

# Restart SQL Sever
# Get a reference to the ManagedComputer class.
CD SQLSERVER:\SQL\computername
$Wmi = (get-item .).ManagedComputer
$DfltInstance = $Wmi.Services['MSSQLSERVER']
# Display the state of the service.
$DfltInstance
# Start the service.
$DfltInstance.Start();
# Wait until the service has time to start.
# Refresh the cache.  
$DfltInstance.Refresh();
# Display the state of the service.
$DfltInstance
# Stop the service.
$DfltInstance.Stop();
# Wait until the service has time to stop.
# Refresh the cache.
$DfltInstance.Refresh();
# Display the state of the service.
$DfltInstance
cd ~

# Download datadog agent image 
Write-Host "Downloading DD-agent installation image."
$image_url = "https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi"
$destin = "C:\vm_info\ddagent-cli-latest.msi"
(New-Object System.Net.WebClient).DownloadFile($image_url, $destin)

# Write-Host "Installing DD-agent from api_key: $DD_API_KEY"

# Set-Content -Path "C:\vm_info\datadog_install.ps1" -Value "msiexec /i C:\vm_info\ddagent-cli-latest.msi /l*v C:\vm_info\installation_log.txt /quiet APIKEY=`"$DD_API_KEY`" HOSTNAME=`"$HOSTNAME_BASE.windows.basic`" TAGS=`"$TAG_DEFAULTS,tester:windows_basics`""

$nowp = (Get-Date).AddMinutes(1)
$runat = Get-Date -date $nowp -format "HH:mm"

Write-Host "Scheduling install of datadog agent at time ${runat}"

# schtasks /create /RU "NT AUTHORITY\SYSTEM" /sc once /tn "Install_Datadog" /tr "Powershell.exe -File C:\vm_info\datadog_install.ps1" /st ${runat} /RL HIGHEST 
schtasks /create /RU "NT AUTHORITY\SYSTEM" /sc once /tn "Install_Datadog" /tr "Powershell.exe -File C:\vm_info\setup_2.ps1" /st ${runat} /RL HIGHEST 


