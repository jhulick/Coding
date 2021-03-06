# ------------------------------------------------------------
#
# Determine the version number of a given Windows ".iso" image-file
#
# ------------------------------------------------------------
If ($False) {

. "${Home}\Documents\GitHub\Coding\powershell\PowerShell - Determine Windows.iso's version number (build, release, windows OS).ps1";

}
# ------------------------------------------------------------

If ($True) {

	$ISO_Fullpath = "${Home}\Desktop\Windows.iso";

	$Possible_DriveLetters = @("D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");
	ForEach ($EachDriveLetter In (${Possible_DriveLetters})) {
		If ((Test-Path -Path ("${EachDriveLetter}:\")) -Eq $False) {
			Set-Variable -Name "DriveLetter" -Scope "Script" -Value "${EachDriveLetter}";
			Break;
		};
	};

	$Mounted_ISO = Mount-DiskImage -ImagePath ("${ISO_Fullpath}");

	Start-Sleep -Seconds (1);

	<# Get the version # of Windows (stored within the .iso file) #>
	$Install_Esd_MountPath = ( "${DriveLetter}:\sources\install.esd" );

	$DISM_Info = (Dism /Get-WimInfo /WimFile:${Install_Esd_MountPath} /index:1);

	$Regex_Win10_VersionNum = "Version\s+:\s+[\d]+\.[\d]+\.[\d]+\s*";
	$Regex_Win10_BuildNum = "ServicePack\s+Build\s+:\s+[\d]+\s*";
	
	$ISO_VersionNumber = ((((${DISM_Info} -match ${Regex_Win10_VersionNum}) -Replace "Version","") -Replace ":","") -Replace " ","");
	$ISO_BuildNumber = ((((${DISM_Info} -match ${Regex_Win10_BuildNum}) -Replace "ServicePack Build","") -Replace ":","") -Replace " ","");
	$ISO_Version_Combined = "${ISO_VersionNumber}.${ISO_BuildNumber}";

	Write-Output "${ISO_Version_Combined}";
	# Write-Output "${DISM_Info}";

	Start-Sleep -Seconds (1);

	${Mounted_ISO} | Dismount-DiskImage | Out-Null;

}


# ------------------------------------------------------------
#
# Citation(s)
#
#   answers.microsoft.com  |  "How to identify windows version and OS build of any windows disc image - Microsoft Community"  |  https://answers.microsoft.com/en-us/windows/forum/all/how-to-identify-windows-version-and-os-build-of/f8f8fe67-9554-4e63-a4d3-87f5dd58184e
#
# ------------------------------------------------------------