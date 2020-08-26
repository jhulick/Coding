# @ECHO OFF
# ------------------------------------------------------------
# !!! Prerequisite !!!
# 	HandBrakeCLI must be installed for this script to function as-intended
# 	Download [ HandBrakeCLI ] Application from URL [ https://handbrake.fr/downloads2.php ]
# 	Extract [ HandBrakeCLI.exe ] from aforementioned URL (downloads as a .zip archive as-of 20191222-070342 CST)
# 	Place the extracted file at filepath [ C:\Program Files\HandBrake\HandBrakeCLI.exe ]
# ------------------------------------------------------------
#
If ($False) { # RUN THIS SCRIPT REMOTELY:


	$ProtoBak=[System.Net.ServicePointManager]::SecurityProtocol; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Clear-DnsClientCache; Set-ExecutionPolicy "RemoteSigned" -Scope "CurrentUser" -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mcavallo-git/Coding/master/windows/HandBrake/HandBrakeCLI-InputOutput/HandBrakeCLI-Encoder.ps1')); [System.Net.ServicePointManager]::SecurityProtocol=$ProtoBak;


}
#
# ------------------------------------------------------------
#
# Instantiate Runtime Variable(s)
#

<# Determine if running locally or remotely - handle both scenarios #>
$WorkingDir = "${Env:UserProfile}\Desktop\HandbrakeCLI";
If ((($MyInvocation.MyCommand).Source) -NE ("")) {
	$WorkingDir = (Split-Path $MyInvocation.MyCommand.Path -Parent);
}

$InputDir = ("${WorkingDir}\InputVideos");

$OutputDir = ("${WorkingDir}\OutputVideos");

$HandBrakeCLI = ("${WorkingDir}\HandBrakeCLI.exe");

$HandBrake_Preset = "Very Fast 1080p30";

$OutputExtension = "mp4";

$MaxRetries_NameCollision = 500;

$Framerate_MatchSource = $True;
# $Framerate_MatchSource = $False;

$AspectRatio_MatchSource = $True;
# $AspectRatio_MatchSource = $False;

$Timestamps_IncludeDecimalSeconds = $False;
# $Timestamps_IncludeDecimalSeconds = $True;

$DoEncoding_InSameWindow = $True;
# $DoEncoding_InSameWindow = $False;

Write-Output "";
Write-Output "Info:  Using working directory `"${WorkingDir}`"...";


# ------------------------------------------------------------
#
# Make sure the working-directory, input-directory, and output-directory all exist
#
$Dirnames_EnsureAllExist = @();
$Dirnames_EnsureAllExist += "${WorkingDir}";
$Dirnames_EnsureAllExist += "${InputDir}";
$Dirnames_EnsureAllExist += "${OutputDir}";
Write-Output "";
For ($i=0; ($i -LT $Dirnames_EnsureAllExist.Count); $i++) {
	$EachDirname_ToEnsureExists = ($Dirnames_EnsureAllExist[${i}]);
	If ((Test-Path -Path ("${EachDirname_ToEnsureExists}")) -Eq ($False)) {
		Write-Output "Info:  Creating Directory `"${EachDirname_ToEnsureExists}`"...";
		New-Item -ItemType "Directory" -Path ("${EachDirname_ToEnsureExists}\") | Out-Null;
		If ((Test-Path -Path ("${EachDirname_ToEnsureExists}")) -Eq ($False)) {
			Write-Output "";
			Write-Output "ERROR:  Unable to create directory `"${EachDirname_ToEnsureExists}`"";
			Write-Output "   |";
			Write-Output "   |-->  Please create this directory manually (via windows explorer, etc.), then re-run this script";
			Write-Output "";
			Start-Sleep 30;
			Exit 1;
		}
	}
}


# ------------------------------------------------------------
#
# Download Handbrake runtime executable (if it doesn't exist)
#
If ((Test-Path -Path ("${HandBrakeCLI}")) -Eq $False) {
	$ExeArchive_Url="https://download.handbrake.fr/releases/1.3.0/HandBrakeCLI-1.3.0-win-x86_64.zip";
	$ExeArchive_Local=("${Env:TEMP}\$(Split-Path ${ExeArchive_Url} -Leaf)");
	$ExeArchive_Unpacked=("${Env:TEMP}\$([IO.Path]::GetFileNameWithoutExtension(${ExeArchive_Local}))");
	# Download HandBrakeCLI
	Write-Output "";
	Write-Output "Info:  HandBrakeCLI Executable not found:  [ ${HandBrakeCLI} ]";
	Write-Output "";
	Write-Output "Info:  Downloading archive-version of HandBrakeCLI from  [ ${ExeArchive_Url} ]  to  [ ${ExeArchive_Local} ]...";
	$ProtoBak=[System.Net.ServicePointManager]::SecurityProtocol; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $(New-Object Net.WebClient).DownloadFile("${ExeArchive_Url}", "${ExeArchive_Local}"); [System.Net.ServicePointManager]::SecurityProtocol=$ProtoBak;
	# Unpack the downloaded archive
	Write-Output "";
	Write-Output "Info:  Unpacking archive:";
	Write-Output "  |";
	Write-Output "  |-->  Source (archive path):  `"${ExeArchive_Local}`"";
	Write-Output "  |";
	Write-Output "  |-->  Destination (unpacked directory):  `"${ExeArchive_Unpacked}`"";
	Write-Output "";
	Expand-Archive -LiteralPath ("${ExeArchive_Local}") -DestinationPath ("${ExeArchive_Unpacked}") -Force;
	# Clean-up the archive once it has been unpacked
	$ExeArchive_HandBrakeCLI = (Get-ChildItem -Path ("${ExeArchive_Unpacked}") -Depth (0) -File | Where-Object { $_.Name -Like "*HandBrakeCLI*.exe" } | Select-Object -First (1) -ExpandProperty ("FullName"));
	If ((Test-Path -Path ("${ExeArchive_HandBrakeCLI}")) -Ne $True) {
		Write-Output "";
		Write-Output "ERROR:  FILE NOT FOUND (HandBrakeCLI executable) at path `"${ExeArchive_HandBrakeCLI}`"`n`n";
		If ($True) {
			# Wait 60 seconds before proceeding
			Start-Sleep 60;
		} Else {
			# "Press any key to close this window..."
			Write-Output -NoNewLine "`n`n  Press any key to close this window...`n`n";
			$KeyPress = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		}
		Exit 1;
	} Else {
		Write-Output "";
		Write-Output "Info:  Moving downloaded/extracted executable from  [ ${ExeArchive_HandBrakeCLI} ]  to  [ ${HandBrakeCLI} ]";
		Move-Item -Path ("${ExeArchive_HandBrakeCLI}") -Destination ("${HandBrakeCLI}") -Force;
	}
}


# ------------------------------------------------------------
#
# Double-check that the Handbrake runtime executable exists
#
If ((Test-Path -Path ("${HandBrakeCLI}")) -Eq $True) {

	# ------------------------------------------------------------
	#
	# Prep the ActiveX Assemblies so we can later use its Recycle-Bin file-removal module in an effort to avoid using the "remove-item" module (which more-permanently deletes the files)
	#
	Add-Type -AssemblyName Microsoft.VisualBasic;

	# ------------------------------------------------------------
	#
	# Determine Video/Audio/Picture options (based on dynamic settings at the top of this script)
	#
	$ExtraOptions = "";
	If ($Framerate_MatchSource -Eq $True) {
		$ExtraOptions = "--vfr ${ExtraOptions}";
	}
	If ($AspectRatio_MatchSource -Eq $True) {
		$ExtraOptions = "--non-anamorphic ${ExtraOptions}";
	}

	$TotalVideoEncodes = 0;

	# Determine which files are video-files from within the input-directory (by using ActiveX Objects)
	$Directory_ToSearch = "${InputDir}";
	$Filetype_ToDetect = "video";
	$ActiveXDataObject_Connection = (New-Object -com ADODB.Connection);
	$ActiveXDataObject_RecordSet = (New-Object -com ADODB.Recordset);
	${ActiveXDataObject_Connection}.Open("Provider=Search.CollatorDSO;Extended Properties='Application=Windows';");
	${ActiveXDataObject_RecordSet}.Open("SELECT System.ItemPathDisplay FROM SYSTEMINDEX WHERE System.Kind = '${Filetype_ToDetect}' AND System.ItemPathDisplay LIKE '${Directory_ToSearch}\%'", ${ActiveXDataObject_Connection});
	If (${ActiveXDataObject_RecordSet}.EOF -Eq $False) {
		${ActiveXDataObject_RecordSet}.MoveFirst();
	}

	<# Walk through the input directory's contained video files, one-by-one #>
	  ### Set-Location -Path ("${WorkingDir}\");
	  ### Get-ChildItem -Path ("${InputDir}\") -Exclude (".gitignore") | ForEach-Object {
	  ### 	$EachInput_BasenameNoExt = "$($_.BaseName)";
	  ### 	$EachInput_FullName = "$($_.FullName)";
	While (${ActiveXDataObject_RecordSet}.EOF -NE $True) {
		$EachInput_FullName = (${ActiveXDataObject_RecordSet}.Fields.Item("System.ItemPathDisplay").Value);
		$EachInput_BasenameNoExt = ((Get-Item -Path ("${EachInput_FullName}")).Basename);

		Write-Output "------------------------------------------------------------";
		Write-Output "";
		Write-Output "Info:  Prepping input ${Filetype_ToDetect}-file  `"${EachInput_FullName}`"";
		Write-Output "";
		<# Determine unique output-filenames by timestamping the end of the output files' basenames (before extension) #>
		$FirstLoop_DoQuickNaming = $True;
		$NameCollision_LoopIterations = 0;
		Do {
			$EpochDate = ([Decimal](Get-Date -UFormat ("%s")));
			$EpochToDateTime = (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0).AddSeconds([Math]::Floor($EpochDate));
			$TimestampShort = ([String](Get-Date -Date ("${EpochToDateTime}") -UFormat ("%Y%m%d-%H%M%S")));
			$DecimalTimestampShort = ( ([String](Get-Date -Date ("${EpochToDateTime}") -UFormat ("%Y%m%d-%H%M%S"))) + (([String]((${EpochDate}%1))).Substring(1).PadRight(6,"0")) );
			If (${FirstLoop_DoQuickNaming} -Eq $True) {
				$EachOutput_BasenameNoExt = "${EachInput_BasenameNoExt}";
			} Else {
				# If ($Timestamps_IncludeDecimalSeconds -Eq $True) {
				# 	$EachOutput_BasenameNoExt = "${EachInput_BasenameNoExt}.${DecimalTimestampShort}";
				# } Else {
				# 	$EachOutput_BasenameNoExt = "${EachInput_BasenameNoExt}.${TimestampShort}";
				# }
				$EachOutput_BasenameNoExt = "${EachInput_BasenameNoExt}.${NameCollision_LoopIterations}";
			}
			$EachOutput_FullName = "${OutputDir}\${EachOutput_BasenameNoExt}.${OutputExtension}";
			$FirstLoop_DoQuickNaming = $False;
			Write-Output "Info:  Checking filename availability:  `"${EachOutput_FullName}`"...";
			$NameCollision_LoopIterations++;
		} While (((Test-Path "${EachOutput_FullName}") -Eq ($True)) -And (${NameCollision_LoopIterations} -LT ${MaxRetries_NameCollision}));

		If ((Test-Path -Path ("${EachOutput_FullName}")) -Eq $True) {
			Write-Output "";
			Write-Output "Error:  Max retries of ${MaxRetries_NameCollision} reached while trying to find a unique output filename"
			Write-Output "  |";
			Write-Output "  |-->  Input-File Fullpath:  `"${EachInput_FullName}`"";
			Write-Output "  |";
			Write-Output "  |-->  Input-File Basename (w/o extension):  `"${EachInput_BasenameNoExt}`"";
			Write-Output "";
			Start-Sleep 60;
			Exit 1;

		} Else {
			Write-Output "Info:  Output filename verified and set to:  [ ${EachOutput_FullName} ]...";
			Write-Output "";

			# ----------------------------------------------- #
			#                                                 #
			#   ! ! !   Perform the actual encoding   ! ! !   #
			#                                                 #
			If (${DoEncoding_InSameWindow} -Eq $False) {
				$EachConversion = (Start-Process -Filepath ("${HandBrakeCLI}") -ArgumentList ("--preset `"${HandBrake_Preset}`" ${ExtraOptions}-i `"${EachInput_FullName}`" -o `"${EachOutput_FullName}`"")  -Wait); $EachExitCode=$?;
			} Else {
				$EachConversion = (Start-Process -Filepath ("${HandBrakeCLI}") -ArgumentList ("--preset `"${HandBrake_Preset}`" ${ExtraOptions}-i `"${EachInput_FullName}`" -o `"${EachOutput_FullName}`"") -NoNewWindow  -Wait -PassThru); $EachExitCode=$?;
			}
			If ((Test-Path -Path ("${EachOutput_FullName}")) -Eq $True) {
				$TotalVideoEncodes++;
				Write-Output "`n`n";
				Write-Output "Info:  Output file exists with path:   `"${EachOutput_FullName}`"";
				Write-Output "  |-->  Removing input file from path:  `"${EachInput_FullName}`"";
				<# Send the input file to the recycle bin #>
				# Remove-Item -Path ("${EachInput_FullName}") -Force;
				# [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('d:\foo.txt','OnlyErrorDialogs','SendToRecycleBin');
				[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("${EachInput_FullName}",'OnlyErrorDialogs','SendToRecycleBin');
			}
			Write-Output "";

		}

		${ActiveXDataObject_RecordSet}.MoveNext(); <# Iterate onto the next ActiveX Input Item (Input Video File, if another exists) #>

	}

	# Open the exported-files directory
	If ($TotalVideoEncodes -GT 0) {
		Write-Output "";
		Write-Output "Info:   ENCODING COMPLETE";
		Write-Output "  |";
		Write-Output "  |-->  Total Encoding Count:  `"${TotalVideoEncodes}`"";
		Write-Output "  |";
		Write-Output "  |-->  Opening Output-Directory:  `"${OutputDir}`" ...";
		Write-Output "";
		Explorer.exe "${OutputDir}";
	} Else {
		Write-Output "";
		Write-Output "! ! !  INPUT DIRECTORY EMPTY";
		Write-Output "  |";
		Write-Output "  |-->  Copy your videos (to-compress) into Input-Directory:  `"${InputDir}`"";
		Write-Output "  |";
		Write-Output "  |-->  Opening Input-Directory, now ...";
		Write-Output "";
		Set-Content -Path ("${InputDir}\_Copy video-files here.txt") -Value ("");
		Set-Content -Path ("${InputDir}\_Then re-run script.txt") -Value ("");
		Start-Sleep -Seconds 3; <# Wait a few seconds (for user to read the terminal, etc.) before exiting #>
		Explorer.exe "${InputDir}";
	}

	Start-Sleep -Seconds 5; <# Wait a few seconds (for user to read the terminal, etc.) before exiting #>

}


# ------------------------------------------------------------
#
# Citation(s)
#
#   docs.microsoft.com  |  "Expand-Archive - Extracts files from a specified archive (zipped) file"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-6
#
#   docs.microsoft.com  |  "Get-ChildItem - Gets the items and child items in one or more specified locations"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem
#
#   docs.microsoft.com  |  "Move-Item - Moves an item from one location to another"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/move-item
#
#   docs.microsoft.com  |  "Split-Path - Returns the specified part of a path"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/split-path
#
#   handbrake.fr  |  "Command line reference"  |  https://handbrake.fr/docs/en/latest/cli/command-line-reference.html
#
#   reddit.com  |  "A HandBrake script to run through subfolders and convert to a custom preset"  |  https://www.reddit.com/r/PleX/comments/9anvle/a_handbrake_script_to_run_through_subfolders_and/
#
# ------------------------------------------------------------