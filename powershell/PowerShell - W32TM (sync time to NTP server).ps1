# ------------------------------------------------------------
#
#		W32TM  :::  Windows Time Service
#		|
#		|--> Set a workstation to sync to one or more NTP 'peers' (syntactically-correct name for an NTP server relative to W32TM)
#
# ------------------------------------------------------------
#
### Get current NTP Configuration (ADMIN REQUIRED)
w32tm.exe /query /configuration
w32tm.exe /query /status
CMD /C "Time /T"


# ------------------------------------------------------------
#
### Test NTP Servers
#
$NtpPeers = @();
$NtpPeers += "time.nist.gov";
$NtpPeers += "pool.ntp.org";
$NtpPeers += "time.google.com";
Write-Host "`n`n  Before Update to NTP-Config...`n   |";
ForEach ($EachPeer In $NtpPeers) {
	$DeltaTimeToPeer = (w32tm.exe /stripchart /computer:$EachPeer /dataonly /samples:1)[3].Split(' ')[1];
	Write-Host (("   |-->   Delta to `"$EachPeer`" = ")+($DeltaTimeToPeer));
}
Write-Host "`n`n";


# ------------------------------------------------------------
#
# Update NTP Server/Settings on target windows machine
#

If ($True) {

NET STOP W32TIME;
#  |
#  |-->  Stop the Windows Time Service


# $Ntp_SetSyncInterval_3600s=",0x9";
# $ManualPeerList=[String]::Join(" ",($NtpPeers | ForEach-Object {"$_$Ntp_SetSyncInterval_3600s"}));
# $ManualPeerList="time.nist.gov,0x9 time.google.com,0x9 north-america.pool.ntp.org,0x9 time.windows.com,0x9";
# w32tm.exe /config /manualpeerlist:"$ManualPeerList" /syncfromflags:manual;
# w32tm.exe /config /manualpeerlist:"time.nist.gov,0x9 time.google.com,0x9 north-america.pool.ntp.org,0x9 time.windows.com,0x9" /syncfromflags:manual;
w32tm.exe /config /manualpeerlist:"time.google.com,0x9 north-america.pool.ntp.org,0x9 time.windows.com,0x9 time.nist.gov,0x9" /syncfromflags:manual;
#  |
#  |-->  /syncfromflags   -->  "Sets what sources the NTP client should synchronize from"
#  |-->  /manualpeerlist  -->  "Set the manual peer list to peers, which is a space-delimited list of Domain Name System (DNS) and/or IP addresses"


NET START W32TIME;
#  |
#  |-->  Start the Windows Time Service


w32tm.exe /config /update;
#  |
#  |-->  /update  -->  "Notify the time service that the configuration has changed, causing the changes to take effect"


w32tm.exe /resync /rediscover;
#  |
#  |-->  /resync  -->  "Tell a computer that it should resynchronize its clock as soon as possible, discarding all accumulated error stats"
#  |-->  /rediscover  -->  "Redetect the network configuration and rediscover network sources; Then, resynchronize"

}

# ------------------------------------------------------------
If ($False) { # Some workstations may be unable to resolve the "FQDN,0x9" syntax - if-so, then use this, instead:


NET STOP W32TIME; `
w32tm.exe /config /manualpeerlist:"time.nist.gov pool.ntp.org time.google.com" /syncfromflags:manual; `
NET START W32TIME; `
w32tm.exe /config /update; `
w32tm.exe /resync /rediscover;


}
# ------------------------------------------------------------
#
#		Or if an all-in-one command is desired:
#
#

# In an Admin PowerShell prompt, enter:

NET STOP W32TIME; w32tm.exe /config /manualpeerlist:"time.nist.gov,0x9 pool.ntp.org,0x9 time.google.com,0x9" /syncfromflags:manual; NET START W32TIME; w32tm.exe /config /update; w32tm.exe /resync /rediscover;


#
#
# ------------------------------------------------------------

Write-Host "`n`n  After Update to NTP-Config...`n   |";
ForEach ($EachPeer In $NtpPeers) {
	$DeltaTimeToPeer = (w32tm.exe /stripchart /computer:$EachPeer /dataonly /samples:1)[3].Split(' ')[1];
	Write-Host (("   |-->   Delta to `"$EachPeer`" = ")+($DeltaTimeToPeer));
}
Write-Host "`n`n";


If ($WaitForKeypress -eq $true) {
	Write-Host -NoNewLine "`n`n-->  Press any key to exit... ";
	$AwaitKeypress = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

Exit;


# ------------------------------------------------------------
#
#	Citation(s)
#
#		Google Public NTP (developers.google.com) | 
#			"Configuring Clients" | https://developers.google.com/time/guides
#
# ------------------------------------------------------------