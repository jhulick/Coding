# ------------------------------------------------------------
#
# PowerShell - Download File from URL (to the Desktop)
#


$ProtoBak=[System.Net.ServicePointManager]::SecurityProtocol; [System.Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; <# Force TLS1.2 (otherwise often throws error in Win2016) #>

$Download_RemoteUrl = "https://github.com/winsw/winsw/releases/download/v2.7.0/WinSW.NET4.exe";
$Download_LocalPath = "${Home}\Desktop\NGINX-Service.exe";
$(New-Object Net.WebClient).DownloadFile(([Net.HttpWebRequest]::Create("${Download_RemoteUrl}").GetResponse().ResponseUri.AbsoluteUri),"${Download_LocalPath}");

[System.Net.ServicePointManager]::SecurityProtocol=$ProtoBak; <# Revert to previous (pre-run) configuration #>


# ------------------------------------------------------------
#
# Ex) Download "NotepadReplacer.exe" to the current user's "Downloads" directory
#

$ProtoBak=[System.Net.ServicePointManager]::SecurityProtocol; [System.Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $(New-Object Net.WebClient).DownloadFile(([Net.HttpWebRequest]::Create("https://www.binaryfortress.com/Data/Download/?package=notepadreplacer").GetResponse().ResponseUri.AbsoluteUri),"${Home}\Downloads\NotepadReplacerSetup.exe"); [System.Net.ServicePointManager]::SecurityProtocol=$ProtoBak;



# ------------------------------------------------------------
#
# Invoke-WebRequest
#   |
#   |--> Has pre-built-in timeout parameter [ -TimeoutSec ]
#

Invoke-WebRequest -Uri ("https://www.binaryfortress.com/Data/Download/?package=notepadreplacer") -OutFile ("${Home}\Downloads\NotepadReplacerSetup.exe") -TimeoutSec (7.5);


# ------------------------------------------------------------
#
# Citation(s)
#
#   docs.microsoft.com  |  "Invoke-WebRequest (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1
#
#   docs.microsoft.com  |  "WebClient.DownloadFile Method (System.Net) | Microsoft Docs"  |  https://docs.microsoft.com/en-us/dotnet/api/system.net.webclient.downloadfile
#
# ------------------------------------------------------------