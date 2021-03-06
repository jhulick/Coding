#
#	EnsureFeatureIsEnabled
#		|--> Checks the status of a given windows feature, then makes sure it is enabled (if disabled)
#
function EnsureFeatureIsEnabled {
	#
	# Module to Fetch & Pull all Repositories in a given directory [ %USERPROFILE%\Documents\GitHub ] Directory 
	#
	Param(

		[String]$FeatureID = "",

		[String]$FeatureName = ""

	)

	$AllFeatures = (Get-WindowsOptionalFeature -Online);

	$AllFeatures | ForEach-Object {
		Show $_;
		# $_.FullName;

		# $CheckFeatures = (Get-WindowsOptionalFeature -Online);

		# (Get-WindowsOptionalFeature -Online -FeatureName "NetFx3").RestartRequired
	
		### Possible

	}
	#
	# ------------------------------------------------------------
	#
	Return;
}

<# Only export the module if the caller is attempting to import it #>
If (($MyInvocation.GetType()) -Eq ("System.Management.Automation.InvocationInfo")) {
	Export-ModuleMember -Function "EnsureFeatureIsEnabled";
}


# ------------------------------------------------------------
#
#	Citation(s)
#		
#		Icon file "GitSyncAll.ico" thanks-to:  https://www.iconarchive.com/download/i103479/paomedia/small-n-flat/sign-sync.ico
#
# ------------------------------------------------------------