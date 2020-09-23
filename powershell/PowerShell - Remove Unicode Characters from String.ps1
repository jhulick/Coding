If ($True) {

<# Include module "Get-FileMetadata" #>
$ProtoBak=[System.Net.ServicePointManager]::SecurityProtocol;	[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Clear-DnsClientCache; Set-ExecutionPolicy "RemoteSigned" -Scope "CurrentUser" -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mcavallo-git/Coding/master/powershell/_WindowsPowerShell/Modules/Get-FileMetadata/Get-FileMetadata.psm1')); [System.Net.ServicePointManager]::SecurityProtocol=$ProtoBak; Get-Command Get-FileMetadata;


$Each_Metadata = (Get-FileMetadata -File "${Home}\Desktop\IMG_0008.JPG");

$Each_DateTaken_Unmodified = (${Each_Metadata}."Date taken");

$Each_DateTaken_NoUnicodeChars = "";
[System.Text.Encoding]::Convert([System.Text.Encoding]::UNICODE, ([System.Text.Encoding]::ASCII), ([System.Text.Encoding]::UNICODE).GetBytes(${Each_DateTaken_Unmodified})) | ForEach-Object { If (([Char]$_) -NE ([Char]"?")) { $Each_DateTaken_NoUnicodeChars += [char]$_; };};

Write-Host "";
Write-Host "`$Each_DateTaken_Unmodified = `"${Each_DateTaken_Unmodified}`"";
Write-Host "";
Write-Host "`$Each_DateTaken_NoUnicodeChars = `"${Each_DateTaken_NoUnicodeChars}`"";
Write-Host "";

};



# ------------------------------------------------------------
#
# Citation(s)
#
#   social.technet.microsoft.com  |  "PS Unicode to Ascii conversion"  |  https://social.technet.microsoft.com/Forums/windowsserver/en-US/1a20e518-64bf-4536-b961-388e2e46eb00/ps-unicode-to-ascii-conversion
#
# ------------------------------------------------------------