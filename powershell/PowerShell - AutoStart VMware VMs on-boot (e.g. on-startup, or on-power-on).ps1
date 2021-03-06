# ------------------------------------------------------------
#  AutoStart one (or more) VMs on Windows Startup
# ------------------------------------------------------------
#
# 1) In your home-directory ( e.g. in %USERPROFILE% ), create a folder named ".vmware"
# 
# 2) Within the ".vmware" folder, create a file named "startup-vmx.txt"
# 
# 3) Within "startup-vmx.txt", place the fullpath locations of any VMs' [ .vmx ] files which you wish to start on-boot (such as "E:\Images\Windows10.vmx")
# 
# 4)Create a new basic scheduled Task via Windows' "Task Scheduler" to run the bottom one-liner to grab your newly created "startup-vmx.txt" and start them at-boot (select on pc startup as task trigger)
# 
# 
# ------------------------------------------------------------
#
# One-Liner Syntax
#

PowerShell.exe -Command "ForEach ($EachVMX In (Get-Content '~\.vmware\vmx-autostart-list.txt')) { If ((Test-Path (${EachVMX})) -And (([String]::IsNullOrEmpty(${EachVMX}.Trim())) -Eq $False)) { Start-Process -Filepath "vmrun" -ArgumentList (('-T wt start ')+(${EachVMX})); Start-Sleep 10; }; };"


# ------------------------------------------------------------
#
# Verbose Syntax
#

ForEach ($EachVMX In (Get-Content '~\.vmware\vmx-autostart-list.txt')) {
	If ((Test-Path (${EachVMX})) -And (([String]::IsNullOrEmpty(${EachVMX}.Trim())) -Eq $False)) {
		Start-Process -Filepath "vmrun" -ArgumentList (('-T wt start ')+(${EachVMX}));
		Start-Sleep 10;
	};
};


# ------------------------------------------------------------
# 
# Citation(s)
# 
#   superuser.com  |  "Is it possible to autostart a VMware virtual machine in background as a Windows service, and shut it down elegantly when Windows shuts down?"  |  https://superuser.com/a/1149081
# 
# ------------------------------------------------------------