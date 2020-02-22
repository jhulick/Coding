

If ($True) {

$vSphere_Server=(Read-Host "Enter FQDN/IP of vSphere Server");  # DNS name (Fully Qualified Domain Name) or IP address of the vCenter Server system which will have the new VM host added to it
$VM_Name=(Read-Host "Enter Name for the new VM");  # Sets the VM Title/Name and Datastore directory name
$vSphere_Datastore=(Read-Host "Enter Datastore name which should contain this VM (enter only the top-level datastore name/nickname)");  # Specifies a datacenter or folder where you want to place the host
$vSphere_User = (Read-Host "Enter vSphere Login-Username");
$vSphere_Pass = ([System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($(Read-Host -AsSecureString "Enter vSphere Login-Password"))));

$vSphere_ConnectionStream = Connect-VIServer -Server "${vSphere_Server}" -Credential "" -Port "443" -Protocol "https";

Get-Datastore;

Add-VMHost -Server ${vSphere_ConnectionStream} -Name ${VM_Name} -Location ${vSphere_Datastore} -User ${vSphere_User} -Password ${vSphere_Pass};
Clear-Variable -Name "vSphere_Pass" -Force;
Clear-Variable -Name "vSphere_User" -Force;

Disconnect-VIServer -Server * -Force;

}


# ------------------------------------------------------------
#
# Citation(s)
#
#   docs.microsoft.com  |  "Clear-Variable - Deletes the value of a variable"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/clear-variable
#
#   powercli-core.readthedocs.io  |  "Add-VMHost"  |  https://powercli-core.readthedocs.io/en/latest/cmd_add.html#add-vmhost
#
#   powercli-core.readthedocs.io  |  "Connect-VIServer"  |  https://powercli-core.readthedocs.io/en/latest/cmd_connect.html#connect-viserver
#
#   powercli-core.readthedocs.io  |  "Disconnect-VIServer"  |  https://powercli-core.readthedocs.io/en/latest/cmd_disconnect.html#disconnect-viserver
#
# ------------------------------------------------------------