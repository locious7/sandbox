# Windows Server 2019/SQL Server 2019/agent7

## What this VM does

This VM will spin up a basic Windows Server 2019 with a SQL Server 2019 instance with DBM enabled and logging enabled. 
It will schedule an installation for the datadog agent 1 minute in the future and set `logs_enabled` to "true". 
It will then add three basic Windows-specific integrations: WMI, Windows Event Viewer, and Windows Services. The addition of these 3 integrations will be scheduled for one minute after the dd-agent is installed. 

WMI queries a few metrics specific to the ddagent process and Notepad process.

Windows Services check will be set up over `wmiApSrv`

Win32_event_log integration will collect events from the System log file if
they are of the "Error" type and the Agent will forward them to Datadog. If you want to collect frequent events, change
type to "Information".


## VM type: Windows Server 2019

### Setup
1. Make sure you have `.sandbox.conf.ps1` in your `~/` directory following [these instructions](https://datadoghq.atlassian.net/wiki/spaces/TS/pages/795345286/Sandboxes#Start-any-VM-in-2-min). Essentially, you need to make sure your `.sandbox.conf.ps1` has the following in it:
```
$DD_API_KEY="<YOUR_API_KEY>"
```

2. Check the architecture of your machine:
```shell
arch
```
* If the result is ***arm64***, please follow these [prerequisites](https://datadoghq.atlassian.net/wiki/spaces/SO/pages/2436368584/Sandboxes+in+Azure+using+vagrant-azure+for+SEs#How-to-spin-up-a-sandbox-with-vagrant-azure-plugin).

3. Start the VM by running:
```shell
./run.sh up
```

4. To see the Windows GUI:
* Install Microsoft Remote Desktop (From the APP Store)
* Go to the [Azure Portal](https://portal.azure.com/#home)
* Click on Virtual Machines
* Search for the VM using the name ***w16-a7-vm***
* Click on Connect > RDP
* Download the RDP file
* Open the file with Microsoft Remote Desktop

5. Destroy and Deallocate the VM by running:
```shell
./run.sh destroy
```

## Special Instructions

Make sure you have a properly configured ~/.sandbox.conf.ps1

 1. Important: make sure your laptop's power cable is plugged in, as the scheduled task to install the dd-agent will not run if you are not plugged in. 
 2. run `./run.sh up`
 3. Recommended: wait an extra few minutes (3-5) after the provisioning completes before you log in to your windows box. This will give the system time to install the dd-agent and its integrations.
 4. Once the Agent install completes, you should start seeing logs in your Log Explorer after about 1-2 minutes. They will be under service:`windowstest`.
 5. If you need to make changes to any settings, use `Ctrl` + `Alt` + `Delete` to log into the VM. (`Cmd` + `Fn` + `Delete` on Mac)
 6. NB: when launching the agent, you will want to launch it `as an administrator`.
 7. The password for the Vagrant user is `vagrant`.

Why does this VM provisioning "schedule" a dd-agent installation instead of
simply installing the dd-agent? Vagrant manages its connections to Windows
machines via WinRM. You can think of that like a Windows-Specific version of
"ssh", except one important difference is that it limits the privileges of
what the user can do over that connection. The dd-agent installation fails for
privilege-related reasons if you try installing over WinRM, so the workaround
is to instead _schedule_ a task that will install the dd-agent with the
required privileges. (And this scheduled task requires that your power cable
is plugged in at the moment. Looking for a workaround there.)