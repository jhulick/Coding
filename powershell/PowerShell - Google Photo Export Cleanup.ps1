# ------------------------------------------------------------
#
# GOOGLE PHOTOS EXPORTS --> UPDATE MEDIA'S DATE-CREATED TIMESTAMP/DATETIME ON MEDIA FILES BASED OFF OF THEIR ASSOCIATED METADATA (JSON) FILES' CONTENTS
#

If ($True) {

	<# Include module "Get-FileMetadata" #>
	$ProtoBak=[System.Net.ServicePointManager]::SecurityProtocol;	[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Clear-DnsClientCache; Set-ExecutionPolicy "RemoteSigned" -Scope "CurrentUser" -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mcavallo-git/Coding/master/powershell/_WindowsPowerShell/Modules/Get-FileMetadata/Get-FileMetadata.psm1')); [System.Net.ServicePointManager]::SecurityProtocol=$ProtoBak;

	<# Include module "JsonDecoder" #>
	Set-ExecutionPolicy -ExecutionPolicy "Bypass" -Scope "CurrentUser" -Force; New-Item -Force -ItemType "File" -Path ("${Env:TEMP}\JsonDecoder.psm1") -Value (($(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/mcavallo-git/Coding/master/powershell/_WindowsPowerShell/Modules/JsonDecoder/JsonDecoder.psm1"))) | Out-Null; Import-Module -Force ("${Env:TEMP}\JsonDecoder.psm1");

	<# Required to use Recycle Bin action 'SendToRecycleBin' #>
	Add-Type -AssemblyName Microsoft.VisualBasic;

	<# Prep all non-matching metadata files to match their associated media-files' basenames #>
	Write-Host "";
	Write-Host "Info: Prepping all non-matching metadata files to match their associated media-files' basenames";
	ForEach ($EachExt In @('GIF','HEIC','JPEG','JPG','MOV','MP4','PNG')) {
		For ($i = 0; $i -LT 10; $i++) {
			Get-ChildItem "./*/*.${EachExt}(${i}).json" | ForEach-Object {
				$Each_FullName = "$($_.FullName)";
				$Each_NewFullName = (("${Each_FullName}").Replace(".${EachExt}(${i}).json","(${i}).${EachExt}.json"));
				Write-Host "Renaming  `"${Each_FullName}`" to `"${Each_NewFullName}`" ...";
				Rename-Item -Path ("${Each_FullName}") -NewName ("${Each_NewFullName}");
			}
		}
	}

	<# Remove excess directory metadata files matching basic filenames such as "metadata.json", "metadata(1).json", "metadata(2).json", etc. #>
	Write-Host "";
	Write-Host "Info: Removing excess directory metadata files";
	$Parent_Directory = ".";
	$Filenames_To_Remove = @();
	$Filenames_To_Remove += ("metadata.json");
	For ($i = 0; $i -LT 50; $i++) {
		$Filenames_To_Remove += ("metadata(${i}).json");
	}
	Get-ChildItem -Path ("${Parent_Directory}") -File -Recurse -Depth (1) -Force -ErrorAction "SilentlyContinue" `
	| Where-Object { (${Filenames_To_Remove}) -Contains ("$($_.Name)"); } `
	| ForEach-Object { `
		$Each_Fullpath = ("$($_.FullName)");
		Write-Host "Removing `"${Each_Fullpath}`" ...";
		[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("${Each_Fullpath}",'OnlyErrorDialogs','SendToRecycleBin');
	}

	<# Update media files using metadata on associated .json file #>
	Write-Host "";
	Write-Host "Info: Updating media files based off of associated .json metadata file-content";
	(Get-Item ".\*\*.json") | ForEach-Object {
		$EachMetadata_Fullpath = ($_.FullName);
		$EachMetadata_BaseName = ($_.BaseName);
		$EachMetadata_DirectoryName = ($_.DirectoryName);
		$EachMetaData_GrandDirName = (Split-Path -Path ("${EachMetadata_DirectoryName}") -Parent);
		<# Parse the metadata file for media filename & date-created timestamp/datetime #>
		$EachMetadata_Contents = [IO.File]::ReadAllText("${EachMetadata_Fullpath}");
		$EachMetadata_Object = JsonDecoder -InputObject (${EachMetadata_Contents});
		$EachMediaFile_Name = $EachMetadata_Object.title;
		$EachCreation_EpochSeconds = $EachMetadata_Object.photoTakenTime.timestamp;
		$Original_CreationTime = $Null;
		$Updated_CreationTime = (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0).AddSeconds([Math]::Floor($EachCreation_EpochSeconds));
		<# By default, look for media-filename as the metadata-filename minus the ".json" extension #>
		$EachMediaFile_CurrentFullpath = "${EachMetadata_DirectoryName}\${EachMetadata_BaseName}";
		$EachMediaFile_FinalFullpath = "${EachMetaData_GrandDirName}\${EachMetadata_BaseName}";
		<# Handle boundary cases with differences between metadata filename and actual filename #>
		If ((Test-Path "${EachMediaFile_CurrentFullpath}") -Eq $False) {
			<# Fallback #1: Test for the metadata contents' contained filename (often has errors regarding duplicate filenames, etc.) #>
			If ((Test-Path "${EachMetadata_DirectoryName}\${EachMediaFile_Name}") -Eq $True) {
				$EachMediaFile_CurrentFullpath = "${EachMetadata_DirectoryName}\${EachMediaFile_Name}";
				$EachMediaFile_FinalFullpath = "${EachMetaData_GrandDirName}\${EachMediaFile_Name}";
			} Else {
				<# Fallback #1: Test for metadata contents' contained filename - BUT for filenames over max characters (see below) #>
				$Google_Filename_MaxCharsWithExt = 51;
				$EachMediaFile_BaseName = [IO.Path]::GetFileNameWithoutExtension("${EachMediaFile_Name}");
				$EachMediaFile_Ext = [IO.Path]::GetExtension("${EachMediaFile_Name}");
				$EachBaseName_MaxLength_NoExt = ($Google_Filename_MaxCharsWithExt - ("${EachMediaFile_Ext}".Length));
				<# Handle filenames which excede Google's maximum filename character-length (seems to be 51 including period + extension (as-of 20200922T213406) ) #>
				If (("${EachMediaFile_BaseName}".Length) -GT (${EachBaseName_MaxLength_NoExt})) {
					$Test_Sliced_BaseName = ("${EachMediaFile_BaseName}".Substring(0,${EachBaseName_MaxLength_NoExt}));
					If ((Test-Path "${EachMetadata_DirectoryName}\${Test_Sliced_BaseName}${EachMediaFile_Ext}") -Eq $True) {
						$EachMediaFile_CurrentFullpath = "${EachMetadata_DirectoryName}\${Test_Sliced_BaseName}${EachMediaFile_Ext}";
						$EachMediaFile_FinalFullpath = "${EachMetaData_GrandDirName}\${Test_Sliced_BaseName}${EachMediaFile_Ext}";
					}
				}
			}
		}
		<# Ensure associated media-file exists #>
		If ((Test-Path "${EachMediaFile_CurrentFullpath}") -Eq $True) {
			$Original_CreationTime = (Get-Item ${EachMediaFile_CurrentFullpath}).CreationTime;
			<# Copy files to the conjoined folder #>
			Copy-Item -Path ("${EachMediaFile_CurrentFullpath}") -Destination ("${EachMediaFile_FinalFullpath}") -Force;
			<# Update the date-created & last-modified timestamp/datetime on the target media file  #>
			Write-Host "Updating `"${EachMediaFile_Name}`".CreationTime from `"${Original_CreationTime}`" to `"${Updated_CreationTime}`"...";
			(Get-Item "${EachMediaFile_FinalFullpath}").CreationTime = (${Updated_CreationTime});
			(Get-Item "${EachMediaFile_FinalFullpath}").LastWriteTime = (${Updated_CreationTime});
			<# Delete old file(s) to the Recycle Bin #>
			Write-Host "Removing `"${EachMetadata_Fullpath}`" ...";
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("${EachMetadata_Fullpath}",'OnlyErrorDialogs','SendToRecycleBin');
			Write-Host "Removing `"${EachMediaFile_CurrentFullpath}`" ...";
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("${EachMediaFile_CurrentFullpath}",'OnlyErrorDialogs','SendToRecycleBin');
		}
	}

	<# Update media files using metadata on each file #>
	Write-Host "";
	Write-Host "Info: Updating media files based off of self-contained metadata (already on each file)";
	$Encoding_ASCII = ([System.Text.Encoding]::ASCII);
	$Encoding_UNICODE = ([System.Text.Encoding]::UNICODE)
	ForEach ($EachExt In @('GIF','HEIC','JPEG','JPG','MOV','MP4','PNG')) {
		(Get-Item ".\*\*.${EachExt}") | ForEach-Object {
			$EachMediaFile_CurrentFullpath = ($_.FullName);
			$EachMediaFile_Name= ($_.Name);
			$EachMediaFile_DirectoryName = ($_.DirectoryName);
			$EachMediaFile_GrandDirName = (Split-Path -Path ("${EachMediaFile_DirectoryName}") -Parent);
			$EachMediaFile_FinalFullpath = "${EachMediaFile_GrandDirName}\${EachMediaFile_Name}";
			$Original_CreationTime = (Get-Item ${EachMediaFile_CurrentFullpath}).CreationTime;
			$Updated_CreationTime = (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0);
			$Each_Metadata = (Get-FileMetadata -File "${EachMediaFile_CurrentFullpath}");
			$Each_DateTaken_Unicode = $Null;
			<# Check various metadata tag-names #>
			$PropName = "Date taken"; <# PNG, HEIC #>
			If ([Bool]($Each_Metadata.PSobject.Properties.name -match "${PropName}")) {
				$Each_DateTaken_Unicode = (${Each_Metadata}.${PropName});
			}
			$PropName = "Media created"; <# MP4s #>
			If ([Bool]($Each_Metadata.PSobject.Properties.name -match "${PropName}")) {
				$Each_DateTaken_Unicode = (${Each_Metadata}.${PropName});
			}
			<# Attempt to use metadata attached to the file, first #>
			If (${Each_DateTaken_Unicode} -NE $Null) {
				<# Remove Unicode Characters from string #>
				$Each_DateTaken_NoUnicodeChars = "";
				[System.Text.Encoding]::Convert([System.Text.Encoding]::UNICODE, ${Encoding_ASCII}, ${Encoding_UNICODE}.GetBytes(${Each_DateTaken_Unicode})) | ForEach-Object { If (([Char]$_) -NE ([Char]"?")) { $Each_DateTaken_NoUnicodeChars += [Char]$_; };};
				$Updated_CreationTime = (Get-Date -Date ("${Each_DateTaken_NoUnicodeChars}"));
				If (${Updated_CreationTime} -NE $Null) {
					<# Copy media file to the conjoined folder #>
					Copy-Item -Path ("${EachMediaFile_CurrentFullpath}") -Destination ("${EachMediaFile_FinalFullpath}") -Force;
					<# Update the date-created & last-modified timestamp/datetime on the new media file  #>
					Write-Host "Updating `"${EachMediaFile_Name}`".CreationTime from `"${Original_CreationTime}`" to `"${Updated_CreationTime}`"...";
					(Get-Item "${EachMediaFile_FinalFullpath}").CreationTime = ($Updated_CreationTime);
					(Get-Item "${EachMediaFile_FinalFullpath}").LastWriteTime = ($Updated_CreationTime);
					<# Delete old file(s) to recycle bin #>
					Write-Host "Removing `"${EachMediaFile_CurrentFullpath}`" ...";
					[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("${EachMediaFile_CurrentFullpath}",'OnlyErrorDialogs','SendToRecycleBin');
				}
			} Else {
				Write-Host "No valid metadata creation-dates found on `"${EachMediaFile_Name}`"";
			}
			$Each_Metadata = $Null;
		}
	}

	<# Update media files using directory name (in yyyy-mm-dd format) #>
	Write-Host "";
	Write-Host "Info: Updating media files based off of directory name (in yyyy-mm-dd format)";
	$Encoding_ASCII = ([System.Text.Encoding]::ASCII);
	$Encoding_UNICODE = ([System.Text.Encoding]::UNICODE)
	ForEach ($EachExt In @('GIF','HEIC','JPEG','JPG','MOV','MP4','PNG')) {
		(Get-Item ".\*\*.${EachExt}") | ForEach-Object {
			$EachMediaFile_CurrentFullpath = ($_.FullName);
			$EachMediaFile_Name= ($_.Name);
			$EachMediaFile_DirectoryName = ($_.DirectoryName);
			$EachMediaFile_GrandDirName = (Split-Path -Path ("${EachMediaFile_DirectoryName}") -Parent);
			$EachMediaFile_FinalFullpath = "${EachMediaFile_GrandDirName}\${EachMediaFile_Name}";
			$Original_CreationTime = (Get-Item ${EachMediaFile_CurrentFullpath}).CreationTime;
			$Updated_CreationTime = (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0);
			<# Fallback to regex-parsing out the date component from the media-file's dirname (in yyyy-mm-dd format) #>
			$EachMediaFile_Directory_BaseName = (Split-Path -Path ("${EachMediaFile_DirectoryName}") -Leaf);
			$Needle   = [Regex]::Match($EachMediaFile_Directory_BaseName, '^(\d\d\d\d)-(\d\d)-(\d\d).*');
			$DateComponent_yyyy=1970;
			$DateComponent_mm=1;
			$DateComponent_dd=1;
			If ($Needle.Success -ne $False) {
				$DateComponent_yyyy=($Needle.Groups[1]).Value;
				$DateComponent_mm=($Needle.Groups[2]).Value;
				$DateComponent_dd=($Needle.Groups[3]).Value;
			}
			$Updated_CreationTime = (New-Object -Type DateTime -ArgumentList ${DateComponent_yyyy}, ${DateComponent_mm}, ${DateComponent_dd}, 0, 0, 0, 0);
			If (${Updated_CreationTime} -NE $Null) {
				<# Copy media file to the conjoined folder #>
				Copy-Item -Path ("${EachMediaFile_CurrentFullpath}") -Destination ("${EachMediaFile_FinalFullpath}") -Force;
				<# Update the date-created & last-modified timestamp/datetime on the new media file  #>
				Write-Host "Updating `"${EachMediaFile_Name}`".CreationTime from `"${Original_CreationTime}`" to `"${Updated_CreationTime}`"...";
				(Get-Item "${EachMediaFile_FinalFullpath}").CreationTime = ($Updated_CreationTime);
				(Get-Item "${EachMediaFile_FinalFullpath}").LastWriteTime = ($Updated_CreationTime);
				<# Delete old file(s) to recycle bin #>
				Write-Host "Removing `"${EachMediaFile_CurrentFullpath}`" ...";
				[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("${EachMediaFile_CurrentFullpath}",'OnlyErrorDialogs','SendToRecycleBin');
			}
		}
	}

	<# Message to user to let them manually remove invalid "...(1).JPG" files #>
	Write-Host "`n`n"
	Write-Host "!!! Manual action required !!!";
	Write-Host "";
	Write-Host "    For some reason, Google leaves-in invalid photos with a (1) at the end of their name, while also mixing in other (1) photos/videos which are valid.";
	Write-Host "";
	Write-Host "    Please view the output directory and manually remove these files (view as folder using 'Large icons' view and locate .jpg files with no thumbnails)";
	Write-Host "`n`n";

};


# ------------------------------------------------------------
#
# Citation(s)
#
#   See "PowerShell - Copy-Item, Get-ChildItem. Get-Item, Remove-Item.ps1" (in same directory in repository)
#
# ------------------------------------------------------------