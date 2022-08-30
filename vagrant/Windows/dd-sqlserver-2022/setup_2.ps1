. C:\vm_info\.sandbox.conf.ps1

msiexec /i C:\vm_info\ddagent-cli-latest.msi /l*v C:\vm_info\installation_log.txt /quiet APIKEY="$DD_API_KEY" HOSTNAME="$HOSTNAME_BASE.windows.basic" TAGS="$TAG_DEFAULTS" LOGS_ENABLED="true"

Start-Sleep -s 60

# stop-service datadogagent
# The following long form of the above command is necessary to avoid a Windows error that prevents the service from stopping
& "C:\Program Files\Datadog\Datadog Agent\embedded\agent.exe" stopservice

Copy-Item -Path C:\vm_info\wmi_check.yaml -Destination C:\ProgramData\Datadog\conf.d\wmi_check.d\conf.yaml
# Copy-Item -Path C:\vm_info\iis.yaml -Destination C:\ProgramData\Datadog\conf.d\iis.d\conf.yaml
Copy-Item -Path C:\vm_info\win32_event_log.yaml -Destination C:\ProgramData\Datadog\conf.d\win32_event_log.d\conf.yaml
Copy-Item -Path C:\vm_info\windows_service.yaml -Destination C:\ProgramData\Datadog\conf.d\windows_service.d\conf.yaml
Copy-Item -Path C:\vm_info\sqlserver.yaml -Destination C:\ProgramData\Datadog\conf.d\sqlserver.d\conf.yaml

# Enabling logs
#Add-Content C:\ProgramData\Datadog\datadog.yaml "`nlogs_enabled: true"

# Create new SQL login for windows authentication (i.e. connection_string: "Trusted_Connection=Yes")
Invoke-Sqlcmd -ServerInstance $DD_hostname -Query "CREATE LOGIN [$DD_hostname\ddagentuser] FROM WINDOWS;
CREATE USER ddagentuser FOR LOGIN ddagentuser;
GRANT CONNECT ANY DATABASE to ddagentuser;
GRANT VIEW SERVER STATE to ddagentuser;
GRANT VIEW ANY DEFINITION to ddagentuser;"

# start-service datadogagent
& "C:\Program Files\Datadog\Datadog Agent\embedded\agent.exe" start-service