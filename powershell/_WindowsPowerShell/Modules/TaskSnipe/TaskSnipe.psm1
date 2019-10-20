#
#	PowerShell - TaskSnipe
#		|
#		|--> Description:  Kill all processes whose name contains a given substring
#		|
#		|--> Example:     TaskSnipe -Name "Ping" -AndName "Jitter" -SkipConfirmation;
#
Function TaskSnipe {
	Param(

		[Parameter(Mandatory=$True)]
		[ValidateLength(2,255)]
		[String]$Name,

		[Parameter(Mandatory=$False)]
		[ValidateLength(2,255)]
		[String]$AndName,

		[Parameter(Mandatory=$False)]
		[ValidateLength(2,255)]
		[String]$AndAndName,

		[Switch]$CaseSensitive,

		[Switch]$CurrentUserMustOwn,

		[Switch]$MatchWholeName,

		[Switch]$Quiet,

		[Switch]$SkipConfirmation,
		[Switch]$Yes

	)

	If ((RunningAsAdministrator) -ne ($True)) {

		$CommandString = $MyInvocation.MyCommand.Name;
		$PSBoundParameters.Keys | ForEach-Object {
			$CommandString += " -$_";
			If (@('String','Integer','Double').Contains($($PSBoundParameters[$_]).GetType().Name)) {
				$CommandString += " `"$($PSBoundParameters[$_])`"";
			}
		}

		PrivilegeEscalation -Command ("${CommandString}");
		
	} Else {

		$SnipeList = @();

		$SkipConfirm = $False;
		If ($PSBoundParameters.ContainsKey('Yes') -Eq $True) {
			$SkipConfirm = $True;
		} ElseIf ($PSBoundParameters.ContainsKey('SkipConfirmation') -Eq $True) {
			$SkipConfirm = $True;
		}

		# Case Insensitive searching (default mode)
		If ($PSBoundParameters.ContainsKey('CaseSensitive') -Eq $False) {
			$Name = $Name.ToLower();
			If ($PSBoundParameters.ContainsKey('AndName') -Eq $True) {
				$AndName = $AndName.ToLower();
			}
			If ($PSBoundParameters.ContainsKey('AndAndName') -Eq $True) {
				$AndAndName = $AndAndName.ToLower();
			}
		}

		# Process must be owned by runtime (current) user
		$FI_USERNAME = "";
		If ($PSBoundParameters.ContainsKey('CurrentUserMustOwn') -Eq $True) {
			$FI_USERNAME = " /FI `"USERNAME eq ${Env:USERDOMAIN}\${Env:USERNAME}`"";
		}

		# Image Name must be Exact
		$FI_IMAGENAME = "";
		If ($PSBoundParameters.ContainsKey('MatchWholeName') -Eq $True) {
			$FI_IMAGENAME = " /FI `"IMAGENAME eq ${Name}`"";
		}

		# Parse the list of returned, matching tasks
		$TASK_FILTERS = "${FI_USERNAME}${FI_IMAGENAME}";
		(CMD /C "TASKLIST /NH${TASK_FILTERS}") <# | Select-Object -Unique #> | ForEach-Object {
			$Proc_Haystack = $_;
			$SEPR8="[\ \t]+"; $SEPEND="[\ \t]*";
			$Proc_RegexPattern = "^((?:[a-zA-Z\.]\ ?)+)(?<!\ )${SEPR8}([0-9]+)${SEPR8}([a-zA-Z]+)${SEPR8}([0-9]+)${SEPR8}([0-9\,]+\ [a-zA-Z])${SEPEND}$";
			$Proc_Needle = [Regex]::Match($Proc_Haystack, $Proc_RegexPattern);
			# Perform regular expression (Regex) capture-group matching to neatly recombine each line of space-delimited output into a workable form
			If ($Proc_Needle.Success -ne $False) {
				$Each_ImageName = $Proc_Needle.Groups[1].Value;
				# Case sensitive check
				If ($PSBoundParameters.ContainsKey('CaseSensitive') -Eq $False) {
					$Each_ImageName = $Each_ImageName.ToLower();
				}
				# Final checks for name-matching
				If ($Each_ImageName.Contains($Name) -Eq $True) {
					If (($PSBoundParameters.ContainsKey('AndName') -Eq $False) -Or ($Each_ImageName.Contains($AndName) -Eq $True)) {
						If (($PSBoundParameters.ContainsKey('AndAndName') -Eq $False) -Or ($Each_ImageName.Contains($AndAndName) -Eq $True)) {
							# Success - This item is determined to match all user-defined criteria
							$NewSnipe = @{};
							$NewSnipe.IMAGENAME   = $Proc_Needle.Groups[1].Value;
							$NewSnipe.PID         = $Proc_Needle.Groups[2].Value;
							$NewSnipe.SESSIONNAME = $Proc_Needle.Groups[3].Value;
							$NewSnipe.SESSION     = $Proc_Needle.Groups[4].Value;
							$NewSnipe.MEMUSAGE    = $Proc_Needle.Groups[5].Value;
							$NewSnipe.ServiceNames = @();
							# Get Service Info
							If (($NewSnipe.SESSIONNAME) -Eq ("Services")) {
								# $ServiceList = (Get-WmiObject Win32_Service -Filter "ProcessId='$($NewSnipe.PID)'" -ErrorAction "SilentlyContinue");
								# If ($ServiceList -ne $Null) {
								# 	$ServiceList | Where-Object { $_.State -eq "Running" } | ForEach-Object {
								# 		$NewSnipe.ServiceNames += $_.Name;
								# 	}
								# }
								Get-WmiObject Win32_Service -Filter "ProcessId='$($NewSnipe.PID)' AND State='Running'" -ErrorAction "SilentlyContinue" | ForEach-Object {
									$NewSnipe.ServiceNames += $_.Name;
								}
							}
							# Push the new object of values onto the final results array
							$SnipeList += $NewSnipe;
						} Else {
							# Skip - ImageName doesn't also match parameter 'AndAndName'
						}
					} Else {
						# Skip - ImageName doesn't also match parameter 'AndName'
					}
				}
			}
		}

		# Pipe the results through the snipe-handler
		If ($SnipeList.Count -ne 0) {
			#
			# At least one matching process was found
			#
			Write-Host (("`n`n$($MyInvocation.MyCommand.Name) - Info: Found ")+($SnipeList.Count)+(" PID(s) matching search criteria:`n")) -ForegroundColor "Green";
			$SnipeList | ForEach-Object {
				$EachIMAGENAME = $_.IMAGENAME;
				$EachPID = $_.PID;
				# $FI_PID  = " /FI `"PID eq ${EachPID}`"";
				# CMD /C "TASKLIST ${TASK_FILTERS}${FI_PID}";
				Write-Host ("  PID ${EachPID} - ${EachIMAGENAME}") -ForegroundColor "Red";
			}

			#
			# Make the user confirm before killing tasks (default, or call with or -Yes -SkipConfirmation to kill straight-away)
			#

			If ($SkipConfirm -Eq $False) {
				#
				# First Confirmation - Confirm via "Are you sure ... ?" (Default)
				#
				$ConfirmKeyList = "abcdefghijklmopqrstuvwxyz"; # removed 'n'
				$FirstConfKey = (Get-Random -InputObject ([char[]]$ConfirmKeyList));
				Write-Host -NoNewLine ("`n");
				Write-Host -NoNewLine ("$($MyInvocation.MyCommand.Name) - Confirm: Are you sure you want to kill these PID(s)?") -BackgroundColor "Black" -ForegroundColor "Yellow";
				Write-Host -NoNewLine ("`n`n");
				Write-Host -NoNewLine ("$($MyInvocation.MyCommand.Name) - Confirm: Press the `"") -ForegroundColor "Yellow";
				Write-Host -NoNewLine ($FirstConfKey) -ForegroundColor "Green";
				Write-Host -NoNewLine ("`" key to if you are sure:  ") -ForegroundColor "Yellow";
				$UserKeyPress = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); Write-Host (($UserKeyPress.Character)+("`n"));
				$FirstConfirm = (($UserKeyPress.Character) -eq ($FirstConfKey));
			}
			#
			# Check (or Skip) First Confirmation flag
			#
			If (($FirstConfirm -Eq $True) -Or ($SkipConfirm -Eq $True)) {
				If ($SkipConfirm -Eq $False) {
					#
					# Second Confirmation - Confirm via "Are you sure ... ?" (Default)
					#
					$SecondConfKey = (Get-Random -InputObject ([char[]]$ConfirmKeyList.Replace([string]$FirstConfKey,"")));
					Write-Host -NoNewLine ("$($MyInvocation.MyCommand.Name) - Confirm: Really really sure?") -BackgroundColor "Black" -ForegroundColor "Yellow";
					Write-Host -NoNewLine ("`n`n");
					Write-Host -NoNewLine ("$($MyInvocation.MyCommand.Name) - Confirm: Press the `"") -ForegroundColor "Yellow";
					Write-Host -NoNewLine ($SecondConfKey) -ForegroundColor "Green";
					Write-Host -NoNewLine ("`" key to confirm and kill:  ") -ForegroundColor "Yellow";
					$UserKeyPress = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
					$SecondConfirm = (($UserKeyPress.Character) -eq ($SecondConfKey));
				}
				#
				# Check (or Skip) Second Confirmation flag
				#
				If (($SecondConfirm -Eq $True) -Or ($SkipConfirm -Eq $True)) {
					If ($SkipConfirm -Eq $False) {
						#
						# MANUALLY CONFIRMED
						#
						Write-Host "`n`n$($MyInvocation.MyCommand.Name) - Info: Confirmed.`n";
					}
					$SnipeList | ForEach-Object {
						If (($_.SESSIONNAME) -Eq "Services") {
							$_.ServiceNames | ForEach-Object {
								Get-Service -Name ($_) -ErrorAction "SilentlyContinue" | Where-Object { $_.Status -eq "Running"} | ForEach-Object {
									#
									# STOP SERVICES BY NAME
									#
									Write-Host "`n$($MyInvocation.MyCommand.Name) - Task: Stopping Service `"$($_.Name)`" ...  " -ForegroundColor "Gray";
									Stop-Service -Name ($_.Name) -Force -NoWait -ErrorAction "SilentlyContinue";
								}
							}
						} Else {
							If (Get-Process -Id ($_.PID) -ErrorAction "SilentlyContinue") {
								#
								# KILL TASKS BY PID
								#
								Write-Host "`n$($MyInvocation.MyCommand.Name) - Task: Stopping Process `"$($_.IMAGENAME)`" (PID $($_.PID)) ...  " -ForegroundColor "Gray";
								Stop-Process -Id ($_.PID) -Force -ErrorAction "SilentlyContinue"; $last_exit_code = If($?){0}Else{1};
								If ($last_exit_code -ne 0) {
									### FALLBACK OPTION:
									$FI_PID  = " /FI `"PID eq $($_.PID)`"";
									CMD /C "TASKKILL ${TASK_FILTERS}${FI_PID}";
								}
							}
						}
					}
				} Else {
					#
					# User bailed-out of the confirmation, cancelling the kill PID(s) action
					#
					Write-Host "`n`n$($MyInvocation.MyCommand.Name) - Info: User bailed out @ Second confirmation - No Action(s) performed  `n`n" -ForegroundColor "Gray";
				}
			} Else {
				#
				# User bailed-out of the FIRST confirmation, cancelling the kill PID(s) action
				#
				Write-Host "`n`n$($MyInvocation.MyCommand.Name) - Info: User bailed out @ First confirmation - No Action(s) performed  `n`n" -ForegroundColor "Gray";
			}
		} Else {
			#
			# No results found
			#
			Write-Host "`n`n$($MyInvocation.MyCommand.Name) - Info: No processes/services found - No Action(s) performed  `n`n" -ForegroundColor "Gray";

		}

		If ($SkipConfirm -Eq $False) {
			# ------------------------------------------------------------
			#	### "Press any key to continue..."
			Write-Host -NoNewLine "`n`n$($MyInvocation.MyCommand.Name) - Press any key to continue...  `n`n" -ForegroundColor "Yellow" -BackgroundColor "Black";
			$KeyPress = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		}

	}

	Return;

}
Export-ModuleMember -Function "TaskSnipe";
# Install-Module -Name "TaskSnipe"



# ------------------------------------------------------------
#
#	Citation(s)
#
#		docs.microsoft.com | "Stop-Service - Microsoft Docs" | https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-service
#
#