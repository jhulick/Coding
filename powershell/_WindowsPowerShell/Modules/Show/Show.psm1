#
#	PowerShell - Show
#		|
#		|--> Description:  Shows extended variable information to user
#		|
#		|--> Example:     PowerShell -Command ("Show `$MyInvocation -Methods")
#
Function Show() {
	Param(
		[Switch]$NoMethods,
		[Switch]$NoOther,
		[Switch]$NoProperties,
		[Switch]$NoRegistry,
		[Switch]$NoValue,
		[Parameter(Position=0, ValueFromRemainingArguments)]$inline_args
	)

	$ShowMethods = (-Not $PSBoundParameters.ContainsKey('NoMethods'));
	$ShowOther = (-Not $PSBoundParameters.ContainsKey('NoOther'));
	$ShowProperties = (-Not $PSBoundParameters.ContainsKey('NoProperties'));
	$ShowRegistry = (-Not $PSBoundParameters.ContainsKey('NoRegistry'));
	$ShowValue = (-Not $PSBoundParameters.ContainsKey('NoValue'));

	ForEach ($EachArg in ($inline_args+$args)) {
		If ($EachArg -Eq $Null) {
			Write-Output "`$Null"
		} Else {
			If ($ShowMethods -Eq $True) {
				#
				# METHODS
				#
				$ListMethods = (`
					Get-Member -InputObject ($EachArg) -View ("All") `
						| Where-Object { ("$($_.MemberType)".Contains("Method")) -Eq $True } `
				);
				Write-Output "`n=====  METHODS  =====  ( hide via -NoMethods )  ============`n";
				If ($ListMethods -Ne $Null) {
					$ListMethods | ForEach-Object { Write-Output "    $($_.Name)"; };
				} Else {
					Write-Output "    (no methods found)";
				}
			}
			If ($ShowOther -Eq $True) {
				#
				# OTHER MEMBERTYPES
				#
				$ListOthers = (`
					Get-Member -InputObject ($EachArg) -View ("All") `
						| Where-Object { ("$($_.MemberType)".Contains("Propert")) -Eq $False } `
						| Where-Object { ("$($_.MemberType)".Contains("Method")) -Eq $False } `
				);
				If ($ListOthers -Ne $Null) {
					Write-Output "`n=====  OTHER TYPES  =====  ( hide via -NoOther )  ==========`n";
					$ListOthers | ForEach-Object { Write-Output $_; };
				}
			}
			If ($ShowProperties -Eq $True) {
				#
				# PROPERTIES
				#
				$ListProperties = (`
					Get-Member -InputObject ($EachArg) -View ("All") `
						| Where-Object { ("$($_.MemberType)".Contains("Propert")) -Eq $True } ` <# Matches *Property* and *Properties* #>
				);
				Write-Output "`n=====  PROPERTIES  =====  ( hide via -NoProperties )  ======`n";
				If ($ListProperties -Ne $Null) {
					$ListProperties | ForEach-Object {
						$EachVal = If ($EachArg.($($_.Name)) -eq $Null) { "`$NULL" } Else { $EachArg.($($_.Name)) };
						Write-Output "    $($_.Name) = $($EachVal)";
					};
				} Else {
					Write-Output "    (no properties found)";
				}
			}
			If ($ShowRegistry -eq $True) {
				If ($EachArg.GetType().Name -Eq "String") {
					$Pattern_UUID  = '^{[0-9A-Fa-f]{8}\b-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-\b[0-9A-Fa-f]{12}}$';
					If (([Regex]::Match(${EachArg}, ${Pattern_UUID}).Success -ne $False) {
						Write-Output "`n=====  REGISTRY  =====  ( hide via -NoValue )  ================`n";
						# Check for Registry Key
						$Revertable_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue';
						$RegistryKey_CLSID = Get-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{8D8F4F83-3594-4F07-8369-FC3C3CAE4919}";
						$RetCode_CLSID = If($?){0}Else{1};
						$RegistryKey_APPID = Get-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AppID\{4839DDB7-58C2-48F5-8283-E1D1807D0D7D}";
						$RetCode_APPID = If($?){0}Else{1};
						$ErrorActionPreference = $Revertable_ErrorActionPreference;

[Regex]::Match("{2593F8B9-4EAF-457C-B68A-50F6B8EA6B54}", '^\b[0-9A-Fa-f]{8}\b-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-\b[0-9A-Fa-f]{12}\b$'
[Regex]::Match(${EachArg}, '^\b[0-9A-Fa-f]{8}\b-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-\b[0-9A-Fa-f]{12}\b$'


						Get-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{2593F8B9-4EAF-457C-B68A-50F6B8EA6B54}"
						HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{6B3B8D23-FA8D-40B9-8DBD-B950333E2C52}
						HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AppID\{4839DDB7-58C2-48F5-8283-E1D1807D0D7D}
					}
				}
			}
			If ($ShowValue -eq $True) {
				Write-Output "`n=====  VALUE  =====  ( hide via -NoValue )  ================`n";
				$EachArg | Format-List;
			}
		Write-Output "`n------------------------------------------------------------";
		}
	}

	Return;

}
Export-ModuleMember -Function "Show";
# Install-Module -Name "Show"


# ------------------------------------------------------------
# Citation(s)
#
#   docs.microsoft.com  |  "Get-Member"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-member?view=powershell-6
#
#   powershellexplained.com  |  "Powershell: Everything you wanted to know about arrays"  |  https://powershellexplained.com/2018-10-15-Powershell-arrays-Everything-you-wanted-to-know/#write-output--noenumerate
#
#   stackoverflow.com  |  "Searching for UUIDs in text with regex"  |  https://stackoverflow.com/a/6640851
#
# ------------------------------------------------------------